//
//  CKPropertyStringViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyStringViewController.h"
#import "CKTextView.h"
#import "CKLocalization.h"
#import "CKReusableViewController+ResponderChain.h"
#import "CKPropertyNumberViewController.h"
#import "NSValueTransformer+Additions.h"

@interface CKPropertyStringViewController ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation CKPropertyStringViewController

- (void)dealloc{
    [_textInputFormatter release];
    [_propertyNameLabel release];
    [_valuePlaceholderLabel release];
    [super dealloc];
}

#pragma mark ViewController Life Cycle

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.multiline = attributes.multiLineEnabled;
    self.minimumLength = attributes.minimumLength;
    self.maximumLength = attributes.maximumLength;
    self.textInputFormatter = attributes.textInputFormatterBlock;
    self.propertyNameLabel = _(property.name);
    self.flags = CKViewControllerFlagsNone;
    
    if([self.property isNumber]){
        if(attributes.placeholderValue){
            self.valuePlaceholderLabel = [NSValueTransformer transform:attributes.placeholderValue toClass:[NSString class]];
        }
    }
    
    if(self.valuePlaceholderLabel == nil){
        NSString* placeholderKey = [NSString stringWithFormat:@"%@_placeholder",property.name];
        self.valuePlaceholderLabel = _(placeholderKey);
    }
    
    return self;
}

- (NSString*)reuseIdentifier{
    NSString* parent = [super reuseIdentifier];
    return [NSString stringWithFormat:@"%@_%d",parent,[self.property isNumber]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UILabel* PropertyNameLabel = [[[UILabel alloc]init]autorelease];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    
    UITextField* ValueTextField = [[[UITextField alloc]init]autorelease];
    ValueTextField.name = @"ValueTextField";
    ValueTextField.font = [UIFont systemFontOfSize:14];
    ValueTextField.minimumWidth = 100;
    ValueTextField.textAlignment = UITextAlignmentRight;
    ValueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    CKTextView* ValueTextView = [[[CKTextView alloc]init]autorelease];
    ValueTextView.name = @"ValueTextView";
    ValueTextView.font = [UIFont systemFontOfSize:14];
    ValueTextView.marginTop = 10;
    
    if([self.property isNumber]){
        ValueTextField.keyboardType = ValueTextView.keyboardType = UIKeyboardTypeDecimalPad;
        ValueTextField.autocorrectionType =  ValueTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    CKHorizontalBoxLayout* hBox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,ValueTextField]];
    
    CKVerticalBoxLayout* vBox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vBox.horizontalAlignment = CKLayoutHorizontalAlignmentLeft;
    vBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox,ValueTextView]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vBox]];
}


#pragma mark Setup MVC and bindings

- (void)setupBindings{
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UITextField* ValueTextField = [self.view viewWithName:@"ValueTextField"];
    ValueTextField.placeholder = _(self.valuePlaceholderLabel);
    ValueTextField.delegate = self;
    
    CKTextView* ValueTextView = [self.view viewWithName:@"ValueTextView"];
    ValueTextView.placeholder = _(self.valuePlaceholderLabel);
    ValueTextView.delegate = self;
    
    //verify if cells are added after it has been setup !
    UIToolbar* toolbar = [self editionToolbar];
    if(toolbar){
        ValueTextView.inputAccessoryView = toolbar;
        ValueTextField.inputAccessoryView = toolbar;
    }
    
    ValueTextField.hidden = self.multiline;
    ValueTextView.hidden = !self.multiline;
    
    __unsafe_unretained CKPropertyStringViewController* bself = self;
    
    [self bind:@"readOnly" executeBlockImmediatly:YES withBlock:^(id value) {
        ValueTextField.userInteractionEnabled = ValueTextView.userInteractionEnabled = !bself.readOnly;
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];

        if(ValueTextField.hidden == NO && ![ValueTextField.text isEqualToString:str]){
            ValueTextField.text = str;
        }
        if(ValueTextView.hidden == NO && ![ValueTextView.text isEqualToString:str]){
            ValueTextView.text = str;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] bindNotificationName:UITextFieldTextDidChangeNotification
                                                        object:ValueTextField
                                                     withBlock:^(NSNotification *notification) {
                                                         [bself updatePropertyWithValue:ValueTextField.text];
                                                     }];

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
    
    NSInteger min = [attributes minimumLength];
    NSInteger max = [attributes maximumLength];
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
            
            return ([string stringByTrimmingCharactersInSet:[numberSet invertedSet]].length > 0);
        }
        
        return YES;
    }
    return YES;
}


#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField { return YES; }

- (void)textFieldDidEndEditing:(UITextField *)textField { [self didResignFirstResponder]; }

- (BOOL)textFieldShouldClear:(UITextField *)textField { return YES; }

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [self textInputView:textField shouldChangeTextInRange:range replacementText:string];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([self hasNextResponder]){
        textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        textField.returnKeyType = UIReturnKeyDone;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToCell];
    });
    
    [self didBecomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.returnKeyType == UIReturnKeyNext ){
        [self activateNextResponder];
    }else{
        if(self.returnKeyHasBeenTapped){
            self.returnKeyHasBeenTapped(self);
        }else{
            [textField resignFirstResponder];
        }
    }
    return YES;
}



#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView { return YES; }

- (void)textViewValueChanged:(NSString*)text{ [self updatePropertyWithValue:text]; }

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    return [self textInputView:textView shouldChangeTextInRange:range replacementText:string];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{ [self didResignFirstResponder]; return YES; }

- (void)textViewDidBeginEditing:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToCell];
    });
    [self didBecomeFirstResponder];
}


@end


/**
 */
@implementation CKPropertyExtendedAttributes (CKPropertyStringViewController)
@dynamic textInputFormatterBlock,minimumLength,maximumLength;

- (void)setTextInputFormatterBlock:(CKInputTextFormatterBlock)textInputFormatterBlock{
    [self.attributes setObject:[[textInputFormatterBlock copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_textInputFormatterBlock"];
}

- (CKInputTextFormatterBlock)textInputFormatterBlock{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_textInputFormatterBlock"];
    return value;
}

- (void)setMinimumLength:(NSInteger)minimumLength{
    [self.attributes setObject:[NSNumber numberWithInteger:minimumLength] forKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_minimumLength"];
}

- (NSInteger)minimumLength{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_minimumLength"];
    if(value) return [value integerValue];
    return -1;
}

- (void)setMaximumLength:(NSInteger)maximumLength{
    [self.attributes setObject:[NSNumber numberWithInteger:maximumLength] forKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_maximumLength"];
}

- (NSInteger)maximumLength{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyStringViewController_maximumLength"];
    if(value) return [value integerValue];
    return -1;
}

@end
