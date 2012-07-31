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


- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)set{
    NSMutableString* str = [NSMutableString string];
    for(int i =0;i<[self length];++i){
        unichar c = [self characterAtIndex:i]; 
        if(![set characterIsMember:c]){
            [str appendFormat:@"%c",c];
        }
    }
    return str;
}

+ (void)setCursorPosition:(NSInteger)position inTextField:(UITextField*)textField{
    UITextPosition *start = [textField positionFromPosition:[textField beginningOfDocument] 
                                                     offset:position];
    UITextPosition *end = [textField positionFromPosition:start
                                                   offset:0];
    [textField setSelectedTextRange:[textField textRangeFromPosition:start toPosition:end]];
}

+ (BOOL)formatAsPhoneNumberUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string{
    NSMutableCharacterSet* formattingCharacterSet = [[[NSMutableCharacterSet alloc]init]autorelease];
    [formattingCharacterSet addCharactersInString:@"("];
    [formattingCharacterSet addCharactersInString:@")"];
    [formattingCharacterSet addCharactersInString:@"-"];
    [formattingCharacterSet addCharactersInString:@"+"];
    
    NSMutableString* textFieldText = [NSMutableString stringWithString:textField.text];
    
    
    NSInteger offset = 0;
    NSString* text = nil;
    
    if([string length] <= 0){ //this means delete
        
        [textFieldText deleteCharactersInRange:range];
        text = [[textFieldText stringByRemovingCharactersInSet:[NSMutableCharacterSet whitespaceCharacterSet] ]
                stringByRemovingCharactersInSet:formattingCharacterSet];
        
        switch(range.location){
            case 0: case 1: offset = 1; break;
            case 2: offset = 2; break;
            case 3: offset = 3; break;
            case 4: offset = 4; break;
            case 5: case 6: offset = 4; break;
            case 7: offset = 7; break;
            case 8: offset = 8; break;
            case 9: case 10: offset = 9; break;
            case 11: offset = 11; break;
            case 12: offset = 12; break;
            case 13: offset = 13; break;
        }
    }else{
        NSMutableCharacterSet *phoneNumberSet = [NSMutableCharacterSet decimalDigitCharacterSet] ;
        NSString* filteredReplacement = [string stringByRemovingCharactersInSet:[phoneNumberSet invertedSet]];
        if([filteredReplacement length] <= 0)
            return NO;
        
        [textFieldText insertString:filteredReplacement atIndex:range.location];
        text = [[textFieldText stringByRemovingCharactersInSet:[NSMutableCharacterSet whitespaceCharacterSet] ]
                          stringByRemovingCharactersInSet:formattingCharacterSet];
        
        switch(range.location){
            case 0: case 1:offset = 2; break;
            case 2: offset = 3; break;
            case 3: offset = 6; break;
            case 4:case 5: case 6: offset = 7; break;
            case 7: offset = 8; break;
            case 8: offset = 9; break;
            case 9: case 10: offset = 11; break;
            case 11: offset = 12; break;
            case 12: offset = 13; break;
            case 13: offset = 14; break;
        }
    }
    
    int length = [text length];
    if(length > 10){
        return NO;
    }
    
    NSString* newText = text;
    if(length <= 0){
        offset = 0;
        newText = nil;
    }
    else if(length < 3)
        newText = [NSString stringWithFormat:@"(%@",
                          text];
    else if(length <= 6){
        newText = [NSString stringWithFormat:@"(%@) %@",
                          [text substringWithRange:NSMakeRange(0, 3)],
                          [text substringWithRange:NSMakeRange(3, [text length] - 3)]];
    }
    else{
        newText = [NSString stringWithFormat:@"(%@) %@-%@",
                          [text substringWithRange:NSMakeRange(0, 3)],
                          [text substringWithRange:NSMakeRange(3, 3)],
                          [text substringWithRange:NSMakeRange(6, [text length] - 6)]];
    }
    textField.text = newText;
    
    [self setCursorPosition:offset inTextField:textField];
    
    return NO;
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
