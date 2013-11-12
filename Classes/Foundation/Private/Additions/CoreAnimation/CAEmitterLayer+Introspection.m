//
//  CAEmitterLayer+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CAEmitterLayer+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation CAEmitterLayer (Introspection)

/* A string defining the type of emission shape used. Current options are:
 * `point' (the default), `line', `rectangle', `circle', `cuboid' and
 * `sphere'.
 
 CA_EXTERN NSString * const kCAEmitterLayerPoint
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerLine
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerRectangle
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerCuboid
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerCircle
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerSphere
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 */
- (void)emitterShapeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.valuesAndLabels = @{ @"kCAEmitterLayerPoint" : kCAEmitterLayerPoint,
                                    @"kCAEmitterLayerLine" : kCAEmitterLayerLine,
                                    @"kCAEmitterLayerRectangle" : kCAEmitterLayerRectangle,
                                    @"kCAEmitterLayerCuboid" : kCAEmitterLayerCuboid,
                                    @"kCAEmitterLayerCircle" : kCAEmitterLayerCircle,
                                    @"kCAEmitterLayerSphere" : kCAEmitterLayerSphere};
}

/* A string defining how particles are created relative to the emission
 * shape. Current options are `points', `outline', `surface' and
 * `volume' (the default).
 
 CA_EXTERN NSString * const kCAEmitterLayerPoints
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerOutline
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerSurface
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerVolume
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 */
- (void)emitterModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.valuesAndLabels = @{ @"kCAEmitterLayerPoints" : kCAEmitterLayerPoints,
                                    @"kCAEmitterLayerOutline" : kCAEmitterLayerOutline,
                                    @"kCAEmitterLayerSurface" : kCAEmitterLayerSurface,
                                    @"kCAEmitterLayerVolume" : kCAEmitterLayerVolume};
}

/* A string defining how particles are composited into the layer's
 * image. Current options are `unordered' (the default), `oldestFirst',
 * `oldestLast', `backToFront' (i.e. sorted into Z order) and
 * `additive'. The first four use source-over compositing, the last
 * uses additive compositing.
 
 CA_EXTERN NSString * const kCAEmitterLayerUnordered
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerOldestFirst
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerOldestLast
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerBackToFront
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 CA_EXTERN NSString * const kCAEmitterLayerAdditive
 __OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_5_0);
 */
- (void)renderModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.valuesAndLabels = @{ @"kCAEmitterLayerUnordered" : kCAEmitterLayerUnordered,
                                    @"kCAEmitterLayerOldestFirst" : kCAEmitterLayerOldestFirst,
                                    @"kCAEmitterLayerOldestLast" : kCAEmitterLayerOldestLast,
                                    @"kCAEmitterLayerBackToFront" : kCAEmitterLayerBackToFront,
                                    @"kCAEmitterLayerAdditive" : kCAEmitterLayerAdditive};
}

@end
