//
//  CIFilter+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-14.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CIFilter+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"
#import "NSValueTransformer+CGTypes.h"
#import <UIKit/UIKit.h>
#import "CKVersion.h"

@implementation CIFilter (ValueTransformer)

+ (NSDictionary*)predefinedKeysDictionary{
    static NSMutableDictionary* keys = nil;
    if(!keys){
        
        if([CKOSVersion() floatValue] >= 5){
            [keys addEntriesFromDictionary:@{
                @"kCIInputImageKey" : kCIInputImageKey,
                @"kCIInputBackgroundImageKey" : kCIInputBackgroundImageKey,
                @"kCIOutputImageKey" : kCIOutputImageKey
            }];
        }
        
        if([CKOSVersion() floatValue] >= 6){
            [keys addEntriesFromDictionary:@{
                @"kCIInputVersionKey" : kCIInputVersionKey
            }];
        }
        
        if([CKOSVersion() floatValue] >= 7){
            [keys addEntriesFromDictionary:@{
                @"kCIInputExtentKey" : kCIInputExtentKey,
                @"kCIInputTargetImageKey" : kCIInputTargetImageKey,
                @"kCIInputMaskImageKey" : kCIInputMaskImageKey,
                @"kCIInputContrastKey" : kCIInputContrastKey,
                @"kCIInputBrightnessKey" : kCIInputBrightnessKey,
                @"kCIInputColorKey" : kCIInputColorKey,
                @"kCIInputSaturationKey" : kCIInputSaturationKey,
                @"kCIInputEVKey" : kCIInputEVKey,
                @"kCIInputIntensityKey" : kCIInputIntensityKey,
                @"kCIInputSharpnessKey" : kCIInputSharpnessKey,
                @"kCIInputWidthKey" : kCIInputWidthKey,
                @"kCIInputAngleKey" : kCIInputAngleKey,
                @"kCIInputRadiusKey" : kCIInputRadiusKey,
                @"kCIInputCenterKey" : kCIInputCenterKey,
                @"kCIInputAspectRatioKey" : kCIInputAspectRatioKey,
                @"kCIInputScaleKey" : kCIInputScaleKey,
                @"kCIInputTransformKey" : kCIInputTransformKey,
                @"kCIInputTimeKey" : kCIInputTimeKey
            }];
        }
    }
    
    return keys;
}

+ (CIFilter*)convertFromNSString:(NSString*)str{
    CIFilter* filter = [[self class] filterWithName:str];
    [filter setDefaults];
    return filter;
}

+ (CIFilter*)convertFromNSDictionary:(NSDictionary*)dictionary{
    NSString* name = [dictionary objectForKey:@"name"];
    CIFilter* filter = [[self class] filterWithName:name];
    
    if(!filter){
        NSLog(@"Could not create CIFilter with name : '%@'",name);
        return nil;
    }
    
    [filter setDefaults];
    
    NSDictionary* filterAttributes = [filter attributes];
    
    NSDictionary* attributes = [dictionary objectForKey:@"attributes"];
    if(attributes && [attributes isKindOfClass:[NSDictionary class]]){
        for(NSString* key in [attributes allKeys]){
            id value = [attributes objectForKey:key];
            
            id predefKey = [[self predefinedKeysDictionary]objectForKey:key];
            if(predefKey){
                key = predefKey;
            }
            
            NSDictionary* attributeConfig = [filterAttributes objectForKey:key];
            if(attributeConfig){
                NSString* attributesClass = [attributeConfig objectForKey:kCIAttributeClass];
                
                if([attributesClass isEqualToString:@"NSNumber"]){
                    NSNumber* number = [NSValueTransformer transform:value toClass:[NSNumber class]];
                    value = number;
                }else if([attributesClass isEqualToString:@"CIVector"]){
                    
                    if([value isKindOfClass:[NSString class]]){
                        NSArray* components = [value componentsSeparatedByString:@" "];
                        CGFloat values[components.count];
                        
                        int i =0;
                        for(NSString* c in components){
                            values[i] = [c floatValue];
                            ++i;
                        }
                        
                        value = [CIVector vectorWithValues:&values[0] count:components.count];
                    }else{
                        value  = nil;
                    }

                }else if([attributesClass isEqualToString:@"CIColor"]){
                    UIColor* color = [NSValueTransformer transform:value toClass:[UIColor class]];
                    value = color.CIColor;
                }else if([attributesClass isEqualToString:@"CIImage"]){
                    UIImage* image = [NSValueTransformer transform:value toClass:[UIImage class]];
                    value = image.CIImage;
                }else if([attributesClass isEqualToString:@"CGAffineTransform"]){
                    CGAffineTransform transform = [NSValueTransformer convertCGAffineTransformFromObject:value];
                    value = [NSValue valueWithCGAffineTransform:transform];
                }
                
                if(value){
                    [filter setValue:value forKey:key];
                }
            }
            
        }
    }
    
    return filter;
}

@end
