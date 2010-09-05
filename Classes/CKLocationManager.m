//
//  CKLocation.m
//  CloudKit
//
//  Created by Olivier Collet on 09-11-19.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKLocationManager.h"
#import <CloudKit/CKDebug.h>

#define K_LOCATION_VALID_TIME_THRESHOLD    60*3
#define K_LOCATION_ACCURACY_THRESHOLD      1000
#define K_LOCATION_ACQUISITION_TIMEOUT     5.0   // Timeout in secs before we cancel the request
#define K_LOCATION_ADDRESS_DISTANCE_DELTA  1000

@interface CKLocationManager (Private)

- (void)findCurrentCoordinateWithAddress:(BOOL)findAddress;
- (void)findAddressAtCurrentCoordinate;
- (BOOL)isAccurateLocation:(CLLocation *)location;
- (void)notifyLocation:(CLLocation *)newLocation;
- (void)setCachedLocation:(CLLocation *)newLocation;
- (void)setCachedPlacemark:(MKPlacemark *)newPlacemark;
- (void)locationManagerDidTimeout:(CLLocationManager *)locationManager;
- (void)locationManagerDidFailWithInvalidLocation:(CLLocationManager *)locationManager;

@end

//

@implementation CKLocationManager

@synthesize isActivated = _activated;
@synthesize location = _cachedLocation;
@synthesize placemark = _cachedPlacemark;
@synthesize timeToLive = _timeToLive;
@synthesize acquisitionTimeout = _acquisitionTimeout;
@synthesize accuracyThreshold = _accuracyThreshold;

#pragma mark Init

+ (CKLocationManager *)manager {
	static CKLocationManager *instance;
	if (instance == nil) {
		instance = [[CKLocationManager alloc] init];
	}
	return instance;
}

- (id)init {
	if (self = [super init]) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_activated = _locationManager.locationServicesEnabled;
		[self setCachedLocation:_locationManager.location];
		
		_findAddress = NO;
		self.timeToLive = K_LOCATION_VALID_TIME_THRESHOLD;
		self.acquisitionTimeout = K_LOCATION_ACQUISITION_TIMEOUT;
		self.accuracyThreshold = K_LOCATION_ACCURACY_THRESHOLD;
	}
	return self;
}

- (void)dealloc {
	[_locationManager release];
	[super dealloc];
}

#pragma mark Tests

- (BOOL)isAccurateLocation:(CLLocation *)location {
	NSAssert(location, @"location must not be nil");

	NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:location.timestamp];
	CLLocationAccuracy accuracy = location.horizontalAccuracy;
	
	if ((timeElapsed < (self.timeToLive)) && (accuracy < self.accuracyThreshold)) return YES;
	return NO;
}

- (BOOL)isValidLocation:(CLLocation *)location {
	NSAssert(location, @"location must not be nil");
	
	if (signbit(location.horizontalAccuracy) || ((location.coordinate.latitude == 0.0) && (location.coordinate.longitude == 0.0))) return NO;
	return YES;
}

#pragma mark Find

- (void)findCurrentCoordinate {
	[self findCurrentCoordinateWithAddress:NO];
}

- (void)findCurrentAddress {
	[self findCurrentCoordinateWithAddress:YES];
}

- (void)findCurrentCoordinateWithAddress:(BOOL)findAddress {
	_findAddress = findAddress;
	
	// Cancel the delayed request location information
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	_timeoutEnabled = NO;

	CLLocation *currentLocation = _locationManager.location;
	[self setCachedLocation:currentLocation];
	CKDebugLog(@"Location: %@", _cachedLocation);
	
	if (currentLocation == nil) {
		[_locationManager startUpdatingLocation];
		return;
	}

	if ([self isValidLocation:currentLocation] == NO) {
		[self locationManagerDidFailWithInvalidLocation:_locationManager];
		return;
	}
	
	if ([self isAccurateLocation:currentLocation]) {
		[self notifyLocation:currentLocation];
		return;
	}
	
	[_locationManager startUpdatingLocation];
}

- (void)stopUpdating {
	[_locationManager stopUpdatingLocation];
	[_reverseGeocoder cancel];
}

#pragma mark Current Location

- (void)notifyLocation:(CLLocation *)location {
	// Cancel the delayed request location information
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	
	// This class is a delayed class that allows sending of the location information to a delegate
	[_locationManager stopUpdatingLocation];
	
	// Post a notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:location forKey:@"location"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidFindCoordinateNotification object:nil userInfo:userInfo];
	
	if (_findAddress == YES) {
		[self findAddressWithLocation:location];
	}
}

#pragma mark Cached Location & Placemark

- (void)setCachedLocation:(CLLocation *)newLocation {
	[_cachedLocation release];
	_cachedLocation = [newLocation retain];
}

- (void)setCachedPlacemark:(MKPlacemark *)newPlacemark {
	[_cachedPlacemark release];
	_cachedPlacemark = [newPlacemark retain];
}

#pragma mark Core Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	CKDebugLog(@"Update Location New: %@ Old: %@", newLocation, oldLocation);

	if (_timeoutEnabled == NO) {
		[self performSelector:@selector(locationManagerDidTimeout:) withObject:_locationManager afterDelay:self.acquisitionTimeout];
		_timeoutEnabled = YES;
	}
	
	if ([self isValidLocation:newLocation] == NO) {
		[self locationManagerDidFailWithInvalidLocation:manager];
		return;
	}

	// FIXME: Triggers a "deprecation warning" but works on OS < 3.2
	if (_findAddress == YES) {
		if ((_cachedLocation == nil) || ([newLocation getDistanceFrom:_cachedLocation] > K_LOCATION_ADDRESS_DISTANCE_DELTA)) {
			[self findAddressWithLocation:newLocation];
		}
	}
	
	[self setCachedLocation:newLocation];

	if ([self isAccurateLocation:newLocation]) {
		if ((oldLocation == nil) || ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] > 1)) {
			[self notifyLocation:newLocation];
		}
	} 
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	CKDebugLog(@"Error: %@", [error description]);

	// Stop acquisition
	[_locationManager stopUpdatingLocation];
	
	// Cancel the delayed request location information
	[NSObject cancelPreviousPerformRequestsWithTarget: self];
	
	// We handle CoreLocation-related errors here
	if ([error domain] == kCLErrorDomain) {

		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				_activated = NO;
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				break;
		}
	}

	// Post a notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidFailCoordinateNotification object:nil userInfo:userInfo];
}

- (void)locationManagerDidTimeout:(CLLocationManager *)locationManager {
	if (locationManager.location) [self notifyLocation:locationManager.location];
	else [self locationManager:locationManager didFailWithError:[NSError errorWithDomain:CKLocationManagerErrorDomain code:ErrorTypeTimeOut userInfo:nil]];
}

- (void)locationManagerDidFailWithInvalidLocation:(CLLocationManager *)locationManager {
	[self locationManager:locationManager didFailWithError:[NSError errorWithDomain:CKLocationManagerErrorDomain code:ErrorTypeInvalidLocation userInfo:nil]];
}

#pragma mark MapKit ReverseGeocoder

- (void)findAddressWithLocation:(CLLocation *)location {
	[_reverseGeocoder release];
	_reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
	_reverseGeocoder.delegate = self;
	[_reverseGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	CKDebugLog(@"Placemark : %@, %@, %@, %@, %@", placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare, placemark.subThoroughfare);
	[self setCachedPlacemark:placemark];

	// Post a notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:placemark forKey:@"placemark"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidFindAddressNotification object:nil userInfo:userInfo];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	// Post a notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidFailAddressNotification object:nil userInfo:userInfo];
}

@end
