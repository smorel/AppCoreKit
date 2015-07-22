//
//  CKPropertyTextView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-07-21.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyTextView.h"
#import "CKLocalization.h"
#import "CKBinding.h"
#import "NSValueTransformer+Additions.h"

#import "CKPropertyStringViewController.h"
#import "CKPropertyNumberViewController.h"


@interface CKPropertyTextView()
@property(nonatomic,retain) UIColor* defaultTextColor;
@end

@implementation CKPropertyTextView

- (instancetype)init{
    self = [super init];
    [self postInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self postInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self postInit];
    return self;
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super init];
    
    self.readOnly = readOnly;
    self.property = property;
    
    return self;
}

- (void)setTextColor:(UIColor *)textColor{
    if(![textColor isEqual:self.readOnlyTextColor]){
        self.defaultTextColor = textColor;
    }
    
    if(self.readOnlyTextColor && self.readOnly){
        [super setTextColor:self.readOnlyTextColor];
        return;
    }
    
    [super setTextColor:textColor];
}


- (void)setProperty:(CKProperty *)property{
    [_property release];
    _property = [property retain];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.minimumLength = attributes.minimumLength;
    self.maximumLength = attributes.maximumLength;
    self.textInputFormatter = attributes.textInputFormatterBlock;
    
    if([self.property isNumber]){
        if(attributes.placeholderValue){
            self.valuePlaceholderLabel = [NSValueTransformer transform:attributes.placeholderValue toClass:[NSString class]];
        }
    }
    
    if(self.valuePlaceholderLabel == nil){
        NSString* placeholderKey = [NSString stringWithFormat:@"%@_placeholder",property.name];
        self.valuePlaceholderLabel = _(placeholderKey);
    }
    
    if([self.property isNumber]){
        self.keyboardType = UIKeyboardTypeDecimalPad;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    __block CKPropertyTextView* bself = self;
    
    self.placeholder = _(self.valuePlaceholderLabel);
    
    [self beginBindingsContextWithScope:@"CKPropertyTextView"];
    
    [self bind:@"readOnly" executeBlockImmediatly:YES withBlock:^(id value) {
        bself.userInteractionEnabled = !bself.readOnly;
        bself.textColor = bself.readOnly ? (bself.readOnlyTextColor ? bself.readOnlyTextColor : bself.defaultTextColor ) : bself.defaultTextColor;
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];
        str = str ? [NSString stringWithFormat:bself.textFormat,str] : nil;
        
        if(bself.hidden == NO && ![bself.text isEqualToString:str]){
            bself.text = str;
        }
    }];
    
    
    [[NSNotificationCenter defaultCenter] bindNotificationName:UITextViewTextDidChangeNotification
                                                        object:self
                                                     withBlock:^(NSNotification *notification) {
                                                         [bself updatePropertyWithValue:bself.text];
                                                     }];
    
    [[NSNotificationCenter defaultCenter] bindNotificationName:UITextViewTextDidEndEditingNotification
                                                        object:self
                                                     withBlock:^(NSNotification *notification) {
                                                         [bself updatePropertyWithValue:bself.text];
                                                     }];
    
    [self endBindingsContext];
}

- (void)dealloc{
    [self clearBindingsContextWithScope:@"CKPropertyTextView"];
    
    [_property release];
    [_textInputFormatter release];
    [_textFormat release];
    [_didResignFirstResponder release];
    [_didBecomeFirstResponder release];
    [_valuePlaceholderLabel release];
    [_readOnlyTextColor release];
    [_defaultTextColor release];
    [super dealloc];
}

- (void)postInit{
    self.delegate = self;
    self.flexibleWidth = YES;
    self.textFormat = @"%@";
}

- (void)updatePropertyWithValue:(id)value{
    id result = [NSValueTransformer transform:value toClass:[self.property isNumber] ? [NSNumber class] : self.property.type];
    [self.property setValue:([self.property isNumber] && !result) ? @(0) : result];
}

- (BOOL)textInputView:(UIView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    CKPropertyExtendedAttributes* attributes = [[self property]extendedAttributes];
    
    CKInputTextFormatterBlock formatterBlock = self.textInputFormatter;
    if(!formatterBlock){
        formatterBlock = [attributes textInputFormatterBlock];
    }
    
    if(formatterBlock){
        BOOL bo = formatterBlock(view,range,string);
        [self updatePropertyWithValue:[view valueForKey:@"text"]];
        return bo;
    }
    
    NSInteger min = attributes ? [attributes minimumLength] : -1;
    NSInteger max = attributes ? [attributes maximumLength] : -1;
    if (range.length>0) {
        if(min >= 0 && range.location < min){
            return NO;
        }
        return YES;
    } else {
        if(max >= 0 && range.location >= max){
            return NO;
        }
        
        
        if([self.property isNumber]){
            NSMutableCharacterSet *numberSet = [NSMutableCharacterSet decimalDigitCharacterSet] ;
            
            CKClassPropertyDescriptor* descriptor = [[self property] descriptor];
            switch(descriptor.propertyType){
                case CKClassPropertyDescriptorTypeFloat:
                case CKClassPropertyDescriptorTypeDouble:{
                    [numberSet addCharactersInString:@".,"];
                }
            }
            
            NSString* result = [string stringByTrimmingCharactersInSet:[numberSet invertedSet]];
            return result.length > 0;
        }
        
        return YES;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    return [self textInputView:textView shouldChangeTextInRange:range replacementText:string];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{ if(self.didResignFirstResponder){ self.didResignFirstResponder(self); } return YES; }

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(self.didBecomeFirstResponder){ self.didBecomeFirstResponder(self); }
}


@end
