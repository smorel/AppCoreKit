//
//  UIImage+Transformations.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "UIImage+Transformations.h"

static inline double radians(double degrees) { return degrees * M_PI/180; }

static void CKCGAddRoundedRectToPath(CGContextRef gc, CGRect rect, CGFloat radius) {
    CGContextBeginPath(gc);
	CGContextSaveGState(gc);
	
	if (radius == 0) {
        CGContextAddRect(gc, rect);
    } else {
		CGContextTranslateCTM(gc, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextScaleCTM(gc, radius, radius);
		CGFloat fw = CGRectGetWidth(rect) / radius;
		CGFloat fh = CGRectGetHeight(rect) / radius;
		CGContextMoveToPoint(gc, fw, fh/2);
		CGContextAddArcToPoint(gc, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(gc, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(gc, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(gc, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(gc);
	CGContextRestoreGState(gc);
}

@implementation UIImage (CKUIImageTransformationsAdditions)


- (UIImage *)imageThatFits:(CGSize)theSize crop:(BOOL)crop
{
    if(crop){
        return [self scaleRotateAndCropImageToFitSize:theSize];
    }
    
    return [self scaleImageToFitSize:theSize];
}


- (UIImage *)imageByAddingBorderWithColor:(UIColor *)strokeColor cornerRadius:(CGFloat)radius {
	int w = self.size.width;
	int h = self.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef gc = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	// Clip the image
	CGContextSaveGState(gc);
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	CKCGAddRoundedRectToPath(gc, rect, radius);
	CGContextClip(gc);
	CGContextDrawImage(gc, CGRectMake(0, 0, w, h), self.CGImage);
	CGContextRestoreGState(gc);
	
	// Stroke the contour
	if ((strokeColor != nil) && (strokeColor != [UIColor clearColor])) {
		CGContextSaveGState(gc);
		CGContextSetStrokeColorWithColor(gc, strokeColor.CGColor);
		CGContextSetLineWidth(gc, 1.0);
		CKCGAddRoundedRectToPath(gc, CGRectInset(rect, 0.5, 0.5), radius);
		CGContextStrokePath(gc);
		CGContextRestoreGState(gc);
	}
	
	// Get the final image
	CGImageRef contextImage = CGBitmapContextCreateImage(gc);
	CGContextRelease(gc);
	CGColorSpaceRelease(colorSpace);
		
	UIImage *result = [UIImage imageWithCGImage:contextImage];
	CGImageRelease(contextImage);
	
    return result;
}


+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)imageInRect:(CGRect)rect{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    CGRect r = CGRectMake(rect.origin.x * scale,rect.origin.y * scale,rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], r);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:cropped.CGImage scale:scale orientation:cropped.imageOrientation]autorelease];
    }
    
    return cropped;
    
}

- (UIImage*)scaleRotateAndCropImageToFitSize:(CGSize)size{
    UIImage* image = self;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat scaleRatioH = bounds.size.width / width;
    CGFloat scaleRatioV = bounds.size.height / height;
    
    CGFloat uniformScale = MAX(scaleRatioH,scaleRatioV);
    CGFloat offsetH = (scaleRatioH < scaleRatioV) ? ((bounds.size.width / uniformScale ) - width) / 2.0 : 0;
    CGFloat offsetV = (scaleRatioV < scaleRatioH) ? ((bounds.size.height / uniformScale) - height) / 2.0 : 0;
    
    scaleRatioH = scaleRatioV = uniformScale;
    
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // [[UIColor redColor]setFill];
    //CGContextFillRect(context, CGRectMake(0, 0, bounds.size.width, bounds.size.height));
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatioH, scaleRatioV);
        CGContextTranslateCTM(context, -height-offsetV, -offsetH);
    }
    else {
        CGContextScaleCTM(context, scaleRatioH, -scaleRatioV);
        CGContextTranslateCTM(context, -offsetH, -height - offsetV);
    }
    
    CGContextConcatCTM(context, transform);
    
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage*)scaleImageToFitSize:(CGSize)size{
    UIImage* image = self;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGFloat scaleRatioH = (CGFloat)size.width  / (CGFloat)width;
    CGFloat scaleRatioV = (CGFloat)size.height / (CGFloat)height;
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatioH, scaleRatioV);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatioH, -scaleRatioV);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;

}


@end


