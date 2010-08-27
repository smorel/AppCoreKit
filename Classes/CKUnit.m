//
//  CKUnit.m
//  CloudKit
//
//  Created by Olivier Collet on 10-08-27.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUnit.h"

// Distance

inline CGFloat CKUnitConvertMetersToMiles(CGFloat meters) { return meters * 0.000621371192f; }
inline CGFloat CKUnitConvertMetersToYards(CGFloat meters) { return meters * 1.0936133f; }

// Angle

inline CGFloat CKUnitConvertDegreesToRadians(CGFloat degrees) { return degrees * 0.0174532925f; }
inline CGFloat CKUnitConvertRadiansToDegrees(CGFloat radians) { return radians * 57.2957795f; }
