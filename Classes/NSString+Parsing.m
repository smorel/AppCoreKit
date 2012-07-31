//
//  NSString+Parsing.m
//  AppCoreKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSString+Parsing.h"


@implementation NSString (Parsing)

- (NSString *)stringByDeletingHTMLTags {
	
	NSString *parsedText = [[self copy] autorelease];
	NSScanner *s = [NSScanner scannerWithString:parsedText];
	
	while (![s isAtEnd]) {
		
		NSString *text = @"";
		[s scanUpToString:@"<" intoString:NULL];
		[s scanUpToString:@">" intoString:&text];
		
		parsedText = [parsedText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
	}
	
	return parsedText;
}

+(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    
    return mobileNumber;
}


+(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
}

+ (BOOL)formatAsPhoneNumberUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string{
    int length = [self getLength:textField.text];
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string allowingFloatingSeparators:(BOOL)allowingFloatingSeparators{
    return [self formatAsAlphanumericUsingTextField:textField range:range replacementString:string minimumLength:-1 maximumLength:-1 allowingFloatingSeparators:allowingFloatingSeparators];
}


+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string minimumLength:(NSInteger)min allowingFloatingSeparators:(BOOL)allowingFloatingSeparators{
    return [self formatAsAlphanumericUsingTextField:textField range:range replacementString:string minimumLength:min maximumLength:-1 allowingFloatingSeparators:allowingFloatingSeparators];
}

+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string maximumLength:(NSInteger)max allowingFloatingSeparators:(BOOL)allowingFloatingSeparators{
    return [self formatAsAlphanumericUsingTextField:textField range:range replacementString:string minimumLength:-1 maximumLength:max allowingFloatingSeparators:allowingFloatingSeparators];
}

+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string minimumLength:(NSInteger)min maximumLength:(NSInteger)max allowingFloatingSeparators:(BOOL)allowingFloatingSeparators{
    if (range.length>0) {
        if(min >= 0 && range.location < min){
            return NO;
        }
        return YES;
    } else {
        if(max >= 0 && range.location >= max){
            return NO;
        }    
        NSMutableCharacterSet *numberSet = [NSMutableCharacterSet decimalDigitCharacterSet] ;
        
        if(allowingFloatingSeparators){
            [numberSet addCharactersInString:@".,"];
        }
        
        return ([string stringByTrimmingCharactersInSet:[numberSet invertedSet]].length > 0);
    }
    return YES;
    
}

@end
