//
//  CKLocationManager.m
//  CloudKit
//
//  Created by Fred Brunel on 10-09-04.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKLocationManager.h"
#import "CKLocalization.h"
#import "CKDebug.h"

NSString * const CKLocationManagerUserDeniedNotification = @"CKLocationManagerUserDeniedNotification";
NSString * const CKLocationManagerServiceDidDisableNotification = @"CKLocationManagerServiceDidDisableNotification";

#define kAlertViewNoLocationServicesMessage 1

@interface CKLocationManager ()
@property (nonatomic, retain, readwrite) NSMutableSet *delegates;
@property (nonatomic, retain, readwrite) CLLocationManager *locationManager;
@property (nonatomic, retain, readwrite) CLHeading *heading;

- (void)registerNotifications;
- (void)displayLocationServicesAlert;

@end

//

@implementation CKLocationManager

@synthesize delegates = _delegates;
@synthesize locationManager = _locationManager;
@synthesize updating = _updating;
@synthesize shouldDisplayHeadingCalibration = _shouldDisplayHeadingCalibration;
@synthesize shouldDisplayLocationServicesAlert = _shouldDisplayLocationServicesAlert;
@synthesize location = _location;
@synthesize heading = _heading;

+ (id)sharedManager {
	static CKLocationManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CKLocationManager alloc] init];
    });
	return _instance;
}

- (id)init {
	if (self = [super init]) {
		self.delegates = [NSMutableSet set];
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.headingFilter = 5.0f; // kCLHeadingFilterNone
		self.locationManager.distanceFilter = 20.0f; // kCLDistanceFilterNone
		_locationAvailable = self.locationManager.locationServicesEnabled;
		
		[self registerNotifications];
	}
	return self;
}

- (void)dealloc {
	self.delegates = nil;
	self.locationManager = nil;
	self.heading = nil;
	[super dealloc];
}

#pragma mark Public API

- (CLLocation *)location {
	return self.locationManager.location;
}

- (CLHeading *)heading {
	// The heading property on CLLocationManager is only available on iOS 4.0,
	// so, we need to store it.
	return _heading;
}

- (BOOL)locationAvailable {
	return _locationAvailable;
}

- (BOOL)headingAvailable {
	// On iOS 4.0, this property is deprecated, we should use the class method +headingAvailable
	return self.locationManager.headingAvailable;
}

- (void)startUpdatingAndStopAfterDelay:(NSTimeInterval)delay {
	[self startUpdating];
	[self performSelector:@selector(stopUpdating) withObject:nil afterDelay:delay];
}

- (void)startUpdating {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.locationManager startUpdatingLocation];
	[self.locationManager startUpdatingHeading];
	_updating = YES;
}

- (void)stopUpdating {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.locationManager stopUpdatingLocation];
	[self.locationManager stopUpdatingHeading];
	_updating = NO;
}

- (void)addDelegate:(id<CKLocationManagerDelegate>)delegate {
	[self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
	[self startUpdating];
}

- (void)removeDelegate:(id<CKLocationManagerDelegate>)delegate {
	[self.delegates removeObject:[NSValue valueWithNonretainedObject:delegate]];
	if (self.delegates.count == 0) {
		[self stopUpdating];
	}
}

- (BOOL)checkLocationAvailabilityWithAlert {
	if ([self locationAvailable] == YES)
		return YES;
	
	[self displayLocationServicesAlert];
	return NO;
}

#pragma mark CoreLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	_locationAvailable = YES;
	for (NSValue *value in self.delegates) {
		id<CKLocationManagerDelegate> delegate = [value nonretainedObjectValue];
		if ([delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
			[delegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	self.heading = newHeading;
	for (NSValue *value in self.delegates) {
		id<CKLocationManagerDelegate> delegate = [value nonretainedObjectValue];
		if ([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
			[delegate locationManager:self didUpdateHeading:newHeading];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//	[self stopUpdating];
	if ([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied) {
		_locationAvailable = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:CKLocationManagerUserDeniedNotification object:self];
		
		if (_shouldDisplayLocationServicesAlert) {
			[self displayLocationServicesAlert];
		}
	}
	
	for (NSValue *value in self.delegates) {
		id<CKLocationManagerDelegate> delegate = [value nonretainedObjectValue];
		if ([delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
			[delegate locationManager:self didFailWithError:error];
		}
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return _shouldDisplayHeadingCalibration;
}

- (void)displayLocationServicesAlert {
	UIAlertView *alertView = 
	  [[[UIAlertView alloc] initWithTitle:_(@"No Location Services")
								  message:_(@"We could not find your location")
								 delegate:self
						cancelButtonTitle:_(@"Dismiss")
						otherButtonTitles:nil] autorelease];
	alertView.tag = kAlertViewNoLocationServicesMessage;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == kAlertViewNoLocationServicesMessage) {
		[[NSNotificationCenter defaultCenter] postNotificationName:CKLocationManagerServiceDidDisableNotification object:self];
	}
}

#pragma mark Multitasking Notifications

- (void)registerNotifications {
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [UIDevice currentDevice].multitaskingSupported) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationWillEnterForeground:)
													 name:UIApplicationWillEnterForegroundNotification
												   object:nil];
	}
}

// Workaround to detect location availability after the application enters foreground, it seems that the
// property -locationServicesEnabled is not reliable at this step. So, we'll do another run of update to 
// check if it will fail.

- (void)applicationWillEnterForeground:(NSNotification *)notification {
	if (_updating) {
		[self startUpdating];
	} else {
		[self startUpdatingAndStopAfterDelay:1.0];
	}
}

@end
