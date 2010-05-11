//
//  CKLocation.h
//  CloudKit
//
//  Created by Olivier Collet on 09-11-19.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kLocationManagerDidFindCoordinateNotification @"kLocationManagerDidFindCoordinateNotification"
#define kLocationManagerDidFindAddressNotification @"kLocationManagerDidFindAddressNotification"
#define kLocationManagerDidFailCoordinateNotification @"kLocationManagerDidFailCoordinateNotification"
#define kLocationManagerDidFailAddressNotification @"kLocationManagerDidFailAddressNotification"

typedef enum {
	ErrorTypeTimeOut = 101,
	ErrorTypeInvalidLocation
} CKLocationManagerErrorType;

static NSString *const CKLocationManagerErrorDomain = @"CKLocationManagerErrorDomain";

@interface CKLocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	CLLocationManager *_locationManager;
	MKReverseGeocoder *_reverseGeocoder;
	
	CLLocation *_cachedLocation;
	MKPlacemark *_cachedPlacemark;
	
	BOOL _activated;
	BOOL _findAddress;
	BOOL _timeoutEnabled;
}

@property (nonatomic, readonly) BOOL isActivated;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) MKPlacemark *placemark;

+ (CKLocationManager *)manager;

- (void)findCurrentCoordinate;
- (void)findCurrentAddress;
- (void)stopUpdating;
- (void)findAddressWithLocation:(CLLocation *)location;

@end