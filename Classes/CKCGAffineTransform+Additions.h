//
//  CKCGAffineTransform+Additions.h
//  CloudKit
//
//  Created by Martin Dufort on 12-02-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform);
CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform);
CGFloat CGAffineTransformGetShearX(CGAffineTransform transform);
CGFloat CGAffineTransformGetShearY(CGAffineTransform transform);
CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform);
CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform);
CGFloat CGAffineTransformGetScaleX0(CGAffineTransform transform);
CGFloat CGAffineTransformGetScaleY0(CGAffineTransform transform);
CGFloat CGAffineTransformGetRotation(CGAffineTransform transform);

//ratio between 0 and 1 interpolate from t1 to t2
CGAffineTransform CGAffineTransformInterpolate(CGAffineTransform t1,CGAffineTransform t2, CGFloat ratio);