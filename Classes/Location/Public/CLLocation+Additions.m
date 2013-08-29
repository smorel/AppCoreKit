//
//  CLLocation+Additions.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CLLocation+Additions.h"
#import "CKUnit.h"

@implementation CLLocation (Additions)

- (double)bearingTowardsLocation:(CLLocation *)location {
	
	// calculate the bearing in the direction of towardsLocation from this location's coordinate
	// Formula:	θ =	atan2(sin(Δlong).cos(lat2), cos(lat1).sin(lat2) − sin(lat1).cos(lat2).cos(Δlong))
	// Based on the formula as described at http://www.movable-type.co.uk/scripts/latlong.html
	// original JavaScript implementation © 2002-2006 Chris Veness
	
	double lat1 = CKUnitConvertDegreesToRadians(self.coordinate.latitude);
	double lon1 = CKUnitConvertDegreesToRadians(self.coordinate.longitude);
	double lat2 = CKUnitConvertDegreesToRadians(location.coordinate.latitude);
	double lon2 = CKUnitConvertDegreesToRadians(location.coordinate.longitude);
	double dLon = lon2 - lon1;
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double bearing = atan2(y, x) + (2 * M_PI);
	// atan2 works on a range of -π to 0 to π, so add on 2π and perform a modulo check
	if (bearing > (2 * M_PI)) {
		bearing = bearing - (2 * M_PI);
	}
	
	return bearing;	
}

@end
