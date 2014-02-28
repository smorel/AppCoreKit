//
//  UIView+Snapshot.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/28/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView(Snaphot)

- (UIImage*)snapshot{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else{
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
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
    
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else{
        [self.layer renderInContext:contextRef];
    }
    
    CGContextRestoreGState(contextRef);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end


//WORKS PEFECTLY IN SIMULATOR, RETURNS A BLACK IMAGE ON DEVICE
@implementation UIScreen(Snaphot)

- (UIImage*)snapshot{
    UIView* view = [[UIScreen mainScreen]snapshotViewAfterScreenUpdates:YES];
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,view.bounds.size.width,view.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,view.bounds.size.width,view.bounds.size.height));
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return  [[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation];
    }
    
    return resultingImage;
}

@end
