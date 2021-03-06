//
//  UIImage+Transformations.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "UIImage+Transformations.h"
#import "UIColor+Additions.h"
#import "UIColor+Components.h"

void CKCGAddRoundedRectToPath(CGContextRef gc, CGRect rect, CGFloat radius);

static inline double radians(double degrees) { return degrees * M_PI/180; }

void CKCGAddRoundedRectToPath(CGContextRef gc, CGRect rect, CGFloat radius) {
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

- (UIImage *)greyscaleImage
{
    UIImage* source = self;
    
    CIImage * beginImage = [ self CIImage ] ;
    CIImage * evAdjustedCIImage = nil ;
    {
        CIFilter * filter = [ CIFilter filterWithName:@"CIColorControls"
                                        keysAndValues:kCIInputImageKey, beginImage
                             , @"inputBrightness", @0.0
                             , @"inputContrast", @1.1
                             , @"inputSaturation", @0.0
                             , nil ] ;
        evAdjustedCIImage = [ filter outputImage ] ;
    }
    
    CIImage * resultCIImage = nil ;
    {
        CIFilter * filter = [ CIFilter filterWithName:@"CIExposureAdjust"
                                        keysAndValues:kCIInputImageKey, evAdjustedCIImage
                             , @"inputEV", @0.7
                             , nil ] ;
        resultCIImage = [ filter outputImage ] ;
    }
    
    CIContext * context = [ CIContext contextWithOptions:nil ] ;
    CGImageRef resultCGImage = [ context createCGImage:resultCIImage
                                              fromRect:resultCIImage.extent ] ;
    UIImage * result = [ UIImage imageWithCGImage:resultCGImage ] ;
    CGImageRelease( resultCGImage ) ;
    
    return result;
}

- (UIImage*)tintedImageWithColor:(UIColor *)tintColor{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    
    UIGraphicsBeginImageContextWithOptions (self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // draw black background to preserve color of transparent pixels
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    // tint image (loosing alpha) - the luminosity of the original image is preserved
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, self.CGImage);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}


- (UIImage *)imageByAddingBorderWithColor:(UIColor *)strokeColor cornerRadius:(CGFloat)radius {
	CGFloat w = self.size.width;
	CGFloat h = self.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef gc = CGBitmapContextCreate(NULL, (size_t)w, (size_t)h, 8, (size_t)(4 * w), colorSpace, 0);
	
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
    CGFloat offsetH = (scaleRatioH < scaleRatioV) ? ((bounds.size.width / uniformScale ) - width) / 2.0f : 0;
    CGFloat offsetV = (scaleRatioV < scaleRatioH) ? ((bounds.size.height / uniformScale) - height) / 2.0f : 0;
    
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
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI);
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
            transform = CGAffineTransformRotate(transform, 3.0f * (CGFloat)M_PI / 2.0f);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0f * (CGFloat)M_PI / 2.0f);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI / 2.0f);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI / 2.0f);
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
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI);
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
            transform = CGAffineTransformRotate(transform, 3.0f *(CGFloat) M_PI / 2.0f);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0f * (CGFloat)M_PI / 2.0f);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform,(CGFloat) M_PI / 2.0f);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI / 2.0f);
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


+ (UIColor *)colorAtPoint:(CGPoint)pixelPoint data:(const UInt8*) data imageSize:(CGSize)imageSize{
    if (pixelPoint.x >= imageSize.width ||
       pixelPoint.y >= imageSize.height) {
        return nil;
    }
    
    
    NSInteger numberOfColorComponents = 4; // R,G,B, and A
    CGFloat x = pixelPoint.x;
    CGFloat y = pixelPoint.y;
    CGFloat w = imageSize.width;
    NSInteger pixelInfo = (NSInteger)( ((w * y) + x) * numberOfColorComponents);
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    
    // RGBA values range from 0 to 255
    return [UIColor colorWithRed:MAX(0,MIN(1,red/255.0f))
                           green:MAX(0,MIN(1,green/255.0f))
                            blue:MAX(0,MIN(1,blue/255.0f))
                           alpha:alpha/255.0f];

}


- (BOOL)doesImageLine:(NSInteger)line matchesColor:(UIColor*)letterBoxingColor precision:(NSInteger)precision tolerance:(CGFloat)tolerance
            imageData:(const UInt8*) imageData imageSize:(CGSize)imageSize{
    CGFloat sumR = 0;
    CGFloat sumG = 0;
    CGFloat sumB = 0;
    CGFloat n = 0;
    
    NSInteger increment = (NSInteger)(imageSize.width / ((precision == 0) ? 2 : precision));
    
    for(NSInteger x = 0; x < imageSize.width; x += increment){
        UIColor* color = [UIImage colorAtPoint:CGPointMake(x,line) data:imageData imageSize:imageSize];
        sumR += color.red;
        sumG += color.green;
        sumB += color.blue;
        n += 1;
    }
    UIColor* color = [UIColor colorWithRed:sumR/n green:sumG/n blue:sumB/n alpha:1];
    CGFloat d = [self RGBDistance:letterBoxingColor color:color];
    if(d > tolerance){
        return NO;
    }
    
    return YES;
}


- (BOOL)doesImageColumn:(NSInteger)column matchesColor:(UIColor*)letterBoxingColor precision:(NSInteger)precision tolerance:(CGFloat)tolerance
            imageData:(const UInt8*) imageData imageSize:(CGSize)imageSize{
    CGFloat sumR = 0;
    CGFloat sumG = 0;
    CGFloat sumB = 0;
    CGFloat n = 0;
    
    NSInteger increment = (NSInteger)(imageSize.height / ((precision == 0) ? 2 : precision));
    
    for(NSInteger y = 0; y < imageSize.height; y += increment){
        UIColor* color = [UIImage colorAtPoint:CGPointMake(column,y) data:imageData imageSize:imageSize];
        sumR += color.red;
        sumG += color.green;
        sumB += color.blue;
        n += 1;
    }
    UIColor* color = [UIColor colorWithRed:sumR/n green:sumG/n blue:sumB/n alpha:1];
    CGFloat d = [self RGBDistance:letterBoxingColor color:color];
    if(d > tolerance){
        return NO;
    }
    
    return YES;
}

- (UIImage*)imageByRemovingLetterBoxingWithColors:(NSArray*)potentialLetterBoxingColors precision:(NSInteger)precision tolerance:(CGFloat)tolerance{
    CGSize realSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    
    CGRect finalRect = CGRectMake(0,0,realSize.width,realSize.height);
    
    CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    UIColor* letterBoxingColor = [UIImage colorAtPoint:CGPointZero data:data imageSize:realSize];
    
    //todo compute color mean on line and compare with tolerance at the end
    BOOL stop = YES;
    if(potentialLetterBoxingColors.count > 0){
        for(UIColor* p in potentialLetterBoxingColors){
            CGFloat d = [self RGBDistance:letterBoxingColor color:p];
            if(d < tolerance){
                stop = NO;
                break;
            }
        }
    }else{
        stop = NO;
    }
    
    if(stop){
        CFRelease(pixelData);
        return self;
    }
    
    NSInteger increment = (NSInteger)(realSize.width / ((precision == 0) ? 2 : precision));
    
    //Searching for top letter box
    NSInteger top = 0;
    NSInteger bottom = (NSInteger)realSize.height;
    NSInteger left = 0;
    NSInteger right = (NSInteger)realSize.width;
    
    //Searching for top letter box
    stop = NO;
    for(NSInteger y = 0; y < realSize.height /2 && !stop; y += 1){
        BOOL match = [self doesImageLine:y matchesColor:letterBoxingColor precision:precision tolerance:tolerance imageData:data imageSize:realSize];
        stop = !match;
        if(!stop){ top = y; }
    }
    top += 1;
    
    //Searching for bottom letter box
    stop = NO;
    for(NSInteger y = (NSInteger)(realSize.height-1); y > (NSInteger)(realSize.height /2) && !stop; y -= 1){
        BOOL match = [self doesImageLine:y matchesColor:letterBoxingColor precision:precision tolerance:tolerance imageData:data imageSize:realSize];
        stop = !match;
        if(!stop){ bottom = y; }
    }
    bottom -= 1;
    
    //Searching for left letter box
    stop = NO;
    for(NSInteger x = 0; x < realSize.width /2 && !stop; x += 1){
        BOOL match = [self doesImageColumn:x matchesColor:letterBoxingColor precision:precision tolerance:tolerance imageData:data imageSize:realSize];
        stop = !match;
        if(!stop){ left = x; }
    }
    left += 1;
    
    //Searching for right letter box
    stop = NO;
    for(NSInteger x = (NSInteger)(realSize.width-1); x > (NSInteger)(realSize.width /2) && !stop; x -= 1){
        BOOL match = [self doesImageColumn:x matchesColor:letterBoxingColor precision:precision tolerance:tolerance imageData:data imageSize:realSize];
        stop = !match;
        if(!stop){ right = x; }
    }
    right -= 1;
    
    finalRect = CGRectMake(left/ self.scale,top/ self.scale,(right - left) / self.scale,(bottom  - top) / self.scale);
    
    CFRelease(pixelData);
    
    return [self imageInRect:finalRect];
}

- (UIImage*)imageByRemovingLetterBoxing{
    return [self imageByRemovingLetterBoxingWithColors:@[ [UIColor blackColor], [UIColor whiteColor]] precision:20 tolerance:0.2];
}

- (CGFloat)RGBDistance:(UIColor*)c1 color:(UIColor*)c2{
    CGFloat rDiff = c1.red - c2.red;
    CGFloat gDiff = c1.green - c2.green;
    CGFloat bDiff = c1.blue - c2.blue;
    return sqrt((rDiff*rDiff) + (gDiff*gDiff) + (bDiff * bDiff));
}

+ (UIImage*)radialGradientImageWithRadius:(CGFloat)radius
                               startColor:(UIColor*)startColor
                                 endColor:(UIColor*)endColor
                                  options:(CGGradientDrawingOptions)options{
    
    CGSize size = CGSizeMake(2*radius,2*radius);
    CGPoint center = CGPointMake(radius, radius);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t gradLocationsNum = 2;
    
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    
    CGFloat colors [] = {
        startColor.red, startColor.green, startColor.blue, startColor.alpha,
        endColor.red, endColor.green, endColor.blue, endColor.alpha
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, options);
    
    CGGradientRelease(gradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)linearGradientImageWithColors:(NSArray*)colors locations:(NSArray*)locations  startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint  size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
  
    
    CGFloat colorLocations[locations.count];
    int i = 0;
    for (NSNumber *n in locations) {
        colorLocations[i++] = [n floatValue];
    }
    
    NSMutableArray *cgcolors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgcolors addObject:(id)([[color RGBColor]CGColor])];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)cgcolors, colorLocations);
    CFRelease(colorSpace);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)maskImageWithPath:(CGPathRef)path size:(CGSize)size drawingMode:(CGPathDrawingMode)drawingMode{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, path);
    
    [[UIColor blackColor]setFill];
    CGContextDrawPath(context, drawingMode);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)maskImageWithEvenOddPath:(CGPathRef)path size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(context, rect);
    CGContextAddPath(context, path);
    
    [[UIColor blackColor]setFill];
    CGContextDrawPath(context, kCGPathEOFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;

}

+ (UIImage*)maskImageWithPath:(CGPathRef)path size:(CGSize)size{
    return [self maskImageWithPath:path size:size drawingMode:kCGPathFill];
}


+ (UIImage*)maskImageWithStrokePath:(CGPathRef)path width:(CGFloat)width size:(CGSize)size{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef thickPath = CGPathCreateCopyByStrokingPath(path, NULL, width, kCGLineCapRound, kCGLineJoinRound, 0);
    CGContextAddPath(context, thickPath);
    
    [[UIColor blackColor]setFill];
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPathRelease(thickPath);
    
    return image;
}

+ (UIImage*)filledImageWithColor:(UIColor*)color path:(CGPathRef)path size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, path);
    
    [color setFill];
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;

}

+ (UIImage*)strokePathImageWithColor:(UIColor*)color path:(CGPathRef)path width:(CGFloat)width size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef thickPath = CGPathCreateCopyByStrokingPath(path, NULL, width, kCGLineCapRound, kCGLineJoinRound, 0);
    CGContextAddPath(context, thickPath);
    
    [color setFill];
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPathRelease(thickPath);
    
    return image;
}

@end


