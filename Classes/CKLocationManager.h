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


/** TODO
 */
#define kLocationManagerDidFindCoordinateNotification @"kLocationManagerDidFindCoordinateNotification"

/** TODO
 */
#define kLocationManagerDidFindAddressNotification @"kLocationManagerDidFindAddressNotification"

/** TODO
 */
#define kLocationManagerDidFailCoordinateNotification @"kLocationManagerDidFailCoordinateNotification"

/** TODO
 */
#define kLocationManagerDidFailAddressNotification @"kLocationManagerDidFailAddressNotification"


/** TODO
 */
typedef enum {
	ErrorTypeTimeOut = 101,
	ErrorTypeInvalidLocation
} CKLocationManagerErrorType;


/** TODO
 */
static NSString *const CKLocationManagerErrorDomain = @"CKLocationManagerErrorDomain";


/** TODO
 */
@interface CKLocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	CLLocationManager *_locationManager;
	MKReverseGeocoder *_reverseGeocoder;
	
	CLLocation *_cachedLocation;
	MKPlacemark *_cachedPlacemark;
	
	BOOL _activated;
	BOOL _findAddress;
	BOOL _timeoutEnabled;

	NSTimeInterval _timeToLive;
	NSTimeInterval _acquisitionTimeout;
	NSUInteger _accuracyThreshold;
}

@property (nonatomic, readonly) BOOL isActivated;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, assign) NSTimeInterval timeToLive;
@property (nonatomic, assign) NSTimeInterval acquisitionTimeout;
@property (nonatomic, assign) NSUInteger accuracyThreshold;

+ (CKLocationManager *)manager;

- (void)findCurrentCoordinate;
- (void)findCurrentAddress;
- (void)stopUpdating;
- (void)findAddressWithLocation:(CLLocation *)location;

@end