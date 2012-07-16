//
//  CKCLLocationAdditions.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** TODO
 */
@interface CLLocation (Additions)

- (double)bearingTowardsLocation:(CLLocation *)location;

@end
