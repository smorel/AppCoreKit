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
#import "CKCollectionCellContentViewController+ResponderChain.h"

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
    
    NSString* placeholderKey = [NSString stringWithFormat:@"%@_placeholder",property.name];
    self.valuePlaceholderLabel = _(placeholderKey);
    
    return self;
}

- (void)postInit{
    self.collectionCellController.flags = CKItemViewFlagNone;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    //self.view.minimumHeight = 44;
    
    UILabel* PropertyNameLabel = [[UILabel alloc]init];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    
    UITextField* ValueTextField = [[UITextField alloc]init];
    ValueTextField.name = @"ValueTextField";
    ValueTextField.font = [UIFont systemFontOfSize:14];
    ValueTextField.minimumWidth = 100;
    ValueTextField.textAlignment = UITextAlignmentRight;
    
    CKTextView* ValueTextView = [[CKTextView alloc]init];
    ValueTextView.name = @"ValueTextView";
    ValueTextView.font = [UIFont systemFontOfSize:14];
    ValueTextView.marginTop = 10;
    
    CKHorizontalBoxLayout* hBox = [[CKHorizontalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,ValueTextField]];
    
    CKVerticalBoxLayout* vBox = [[CKVerticalBoxLayout alloc]init];
    vBox.horizontalAlignment = CKLayoutHorizontalAlignmentLeft;
    vBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox,ValueTextView]];
    
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vBox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setup];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContext];
}

- (void)setup{
    if(!self.view)
        return;
    
    [self.view beginBindingsContextByRemovingPreviousBindings];
    [self setupBindings];
    [self.view endBindingsContext];
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UITextField* ValueTextField = [self.view viewWithName:@"ValueTextField"];
    ValueTextField.placeholder = self.valuePlaceholderLabel;
    ValueTextField.delegate = self;
    
    CKTextView* ValueTextView = [self.view viewWithName:@"ValueTextView"];
    ValueTextView.placeholder = self.valuePlaceholderLabel;
    ValueTextView.delegate = self;
    
    ValueTextField.hidden = self.multiline;
    ValueTextView.hidden = !ValueTextField.hidden;
    ValueTextField.userInteractionEnabled = ValueTextView.userInteractionEnabled = !self.readOnly;
    
    __unsafe_unretained CKPropertyStringViewController* bself = self;
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];
        if(![ValueTextField.text isEqualToString:str]){
            ValueTextField.text = str;
        }
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];
        if(![ValueTextView.text isEqualToString:str]){
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
    id result = [NSValueTransformer transform:value toClass:self.property.type];
    [self.property setValue:result];
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
    UIToolbar* toolbar = [self navigationToolbar];
    if(toolbar){
        textField.inputAccessoryView = toolbar;
    }
    
    if([self hasNextResponder]){
        textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        textField.returnKeyType = UIReturnKeyDone;
    }
    
    [self scrollToCell];
    
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
    UIToolbar* toolbar = [self navigationToolbar];
    if(toolbar){
        textView.inputAccessoryView = toolbar;
    }
    
    [self scrollToCell];
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
