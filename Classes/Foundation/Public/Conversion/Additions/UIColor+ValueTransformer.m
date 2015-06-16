//
//  UIColor+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIColor+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"
#import "UIColor+Additions.h"
#import "CKResourceManager.h"
#import "UIColor+Components.h"

#import "CKResourceDependencyContext.h"

#import "CKDebug.h"


@implementation UIColor (CKUIColor_ValueTransformer)

+ (UIColor*)convertFromNSString:(NSString*)str{
    //CKResourceDependencyContext for color palettes
    
	NSArray* components = [str componentsSeparatedByString:@" "];
	if([components count] >= 3){
        CGFloat r = [[components objectAtIndex:0]floatValue];
        CGFloat g = [[components objectAtIndex:1]floatValue];
        CGFloat b = [[components objectAtIndex:2]floatValue];
        if(r > 1 || g > 1 || b > 1){
            CGFloat a = [components count] == 4 ? [[components objectAtIndex:3]floatValue] : 255;
            return [UIColor colorWithRedInt:r
                                   greenInt:g
                                    blueInt:b
                                   alphaInt:a];
        }else{
            CGFloat a = [components count] == 4 ? [[components objectAtIndex:3]floatValue] : 1;
            return [UIColor colorWithRed:r
                                   green:g
                                    blue:b
                                   alpha:a];
        }
       
	}
	else {
		str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        
		if([str hasPrefix:@"0x"]){
			NSArray* components = [str componentsSeparatedByString:@" "];
			CKAssert([components count] >= 1,@"Invalid format for color");
			unsigned outVal;
			NSScanner* scanner = [NSScanner scannerWithString:[components objectAtIndex:0]];
			[scanner scanHexInt:&outVal];
			UIColor* color = [UIColor colorWithRGBValue:outVal];
			
			if([components count] > 1){
				color = [color colorWithAlphaComponent:[[components objectAtIndex:1] floatValue] ];
			}
			return color;
		}
		else{
			SEL colorSelector = NSSelectorFromString(str);
			if(colorSelector && [[UIColor class] respondsToSelector:colorSelector]){
				UIColor* color = [[UIColor class] performSelector:colorSelector];
				return color;
			}
			else{
                UIImage* image = [CKResourceManager imageNamed:str];
                if(image){
                    UIColor* color = [UIColor colorWithPatternImage:image];
                    return color;
                }
                else{
                    NSLog(@"Couldn't a valid format for converting color '%@'",str);
                    //CKAssert(NO,@"invalid format for color with text : %@",str);
                }
			}
		}
	}
	
	return [UIColor clearColor];
}

+ (UIColor*)convertFromNSNumber:(NSNumber*)n{
	UIColor* result = [UIColor colorWithRGBValue:[n integerValue]];
	return result;
}

+ (UIColor*)convertFromNSValue:(NSValue*)v{
    return [UIColor clearColor];
}

+ (NSString*)convertToNSString:(UIColor*)color{
    return [NSString stringWithFormat:@"%g %g %g %g",color.red,color.green,color.blue,color.alpha ];
}

@end
