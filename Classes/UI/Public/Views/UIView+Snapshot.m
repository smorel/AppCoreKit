//
//  UIView+Snapshot.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/28/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIView+Snapshot.h"
#import "CKVersion.h"
#import "CKStyleView.h"

@implementation UIView(Snaphot)

- (UIImage*)snapshot{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    [self.layer renderInContext:contextRef];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}


- (UIImage*)snapshotWithoutSubviews{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    //- I don't like this cause it will invalidate layouts
   NSMutableArray* viewsToShow = [NSMutableArray array];
    for(UIView* v in self.subviews){
        if(![v isKindOfClass:[CKStyleView class]]){
            if(!v.hidden){
                [viewsToShow addObject:v];
                v.hidden = YES;
            }
        }
    }
    
    [self.layer renderInContext:contextRef];
    
    for(UIView* v in viewsToShow){
        v.hidden = NO;
    }
    //-
    
    /* This doesn't draw background properly
    UIView* firstSubView = self.subviews.count > 0 ? [self.subviews objectAtIndex:0] : nil;
    CKStyleView* styleView = ([firstSubView isKindOfClass:[CKStyleView class]]) ? (CKStyleView*)firstSubView : nil;
    
    [self.layer drawInContext:contextRef];
    
    if(styleView){
        [styleView.layer drawInContext:contextRef];
    }*/
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end



@implementation UIScrollView(Snaphot)

- (UIImage*)snapshot{
    UIScrollView *renderedView = (UIScrollView *)self;
    CGPoint offset = renderedView.contentOffset;
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, -offset.x, -offset.y);
    
    [self.layer renderInContext:contextRef];
    
    CGContextRestoreGState(contextRef);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end

CGImageRef UIGetScreenImage(void);

@implementation UIScreen(Snaphot)

- (UIImage*)snapshot{
    /* Private API
    CGImageRef screen = UIGetScreenImage();
    UIImage *image = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    
    return image;
     */
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            

            [window.layer renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return  [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end
