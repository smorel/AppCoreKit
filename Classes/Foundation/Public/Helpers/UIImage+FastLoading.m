//
//  UIImage+FastLoading.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIImage+FastLoading.h"


typedef struct
{
    int width;
    int height;
    int scale;
    
    size_t bitsPerComponent;
    size_t bitsPerPixel;
    size_t bytesPerRow;
    CGBitmapInfo bitmapInfo;
} FatsLoadingImageInfo;

@implementation UIImage (FastLoading)

- (void) writeFastLoadingContentsToFile:(NSString *)outputPath{
    NSData * pixelData = ( NSData *)CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage));
    CGSize size;
    size.width = CGImageGetWidth(self.CGImage);
    size.height = CGImageGetHeight(self.CGImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(self.CGImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(self.CGImage);
    int scale = self.scale;
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(self.CGImage);
    
    FatsLoadingImageInfo info;
    info.width = size.width;
    info.height = size.height;
    info.bitsPerComponent = bitsPerComponent;
    info.bitsPerPixel = bitsPerPixel;
    info.bytesPerRow = bytesPerRow;
    info.bitmapInfo = bitmapInfo;
    info.scale = scale;
    
    //kCGColorSpaceGenericRGB
    NSMutableData * fileData = [NSMutableData data];
    
    [fileData appendBytes:&info length:sizeof(info)];
    [fileData appendData:pixelData];
    
    [fileData writeToFile:outputPath atomically:YES];
    
    CFRelease(pixelData);
}

+ (UIImage *)fastLoadingImageWithContentsOfFile:(NSString *)inputPath{
    FILE * f = fopen([inputPath cStringUsingEncoding:NSASCIIStringEncoding],"rb");
    if (!f) return nil;
    
    fseek(f, 0, SEEK_END);
    size_t length = ftell(f) - sizeof(FatsLoadingImageInfo);
    fseek(f, 0, SEEK_SET);
    
    FatsLoadingImageInfo info;
    fread(&info, 1, sizeof(FatsLoadingImageInfo), f);
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       info.width,
                                                       info.height,
                                                       info.bitsPerComponent,
                                                       info.bytesPerRow,
                                                       cs,
                                                       info.bitmapInfo
                                                       );
    if(!bitmapContext){
        CGColorSpaceRelease(cs);
        return nil;
    }
    
    void * targetData = CGBitmapContextGetData(bitmapContext);
    fread(targetData,1,length,f);
    
    fclose(f);
    
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
    
    UIImage * result = [UIImage imageWithCGImage:decompressedImageRef scale:info.scale orientation:UIImageOrientationUp];
    
    CGContextRelease(bitmapContext);
    CGImageRelease(decompressedImageRef);
    CGColorSpaceRelease(cs);
    
    return result;

}

@end
