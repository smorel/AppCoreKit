//
//  CLLocation+Additions.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 */
@interface CLLocation (Additions)

///-----------------------------------
/// @name Measuring using Coordinates
///-----------------------------------

/** calculate the bearing in the direction of towardsLocation from this location's coordinate
    Formula:	θ =	atan2(sin(Δlong).cos(lat2), cos(lat1).sin(lat2) − sin(lat1).cos(lat2).cos(Δlong))
 */
- (double)bearingTowardsLocation:(CLLocation *)location;

@end
