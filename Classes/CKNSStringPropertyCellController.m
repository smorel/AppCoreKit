//
//  CKNSStringPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


#import "CKNSStringPropertyCellController.h"
#import "CKProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKNSValueTransformer+Additions.h"

#import "CKSheetController.h"
#import "CKUIView+Positioning.h"

#define TEXTFIELD_TAG 50000

@interface CKNSStringPropertyCellController()
@property (nonatomic,retain,readwrite) UITextField* textField;
@end

@implementation CKNSStringPropertyCellController
@synthesize textField = _textField;

-(void)dealloc{
	[_textField release];
	[super dealloc];
}


- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}


//HERE SIZE DEPENDS ON VALUE &&& STYLESHEET !
/*
+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
    CKNSStringPropertyCellController* staticController = (CKNSStringPropertyCellController*)[params staticController];
    
	UITextField *textField = staticController.textField;
    
    CGFloat bottomTextField = textField ? (textField.frame.origin.y + textField.frame.size.height) : 0;
    CGFloat bottomTextLabel = staticController.tableViewCell.textLabel.frame.origin.y + staticController.tableViewCell.textLabel.frame.size.height;
    CGFloat bottomDetailTextLabel = [staticController.tableViewCell.detailTextLabel text] ? (staticController.tableViewCell.detailTextLabel.frame.origin.y + staticController.tableViewCell.detailTextLabel.frame.size.height) : 0;
    CGFloat maxHeight = MAX(bottomTextField,MAX(bottomTextLabel,bottomDetailTextLabel)) + staticController.contentInsets.bottom;
    return [NSValue valueWithCGSize:CGSizeMake(100,maxHeight)];
}*/

//pas utiliser load cell mais initCell pour application des styles ...
- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    UITextField *txtField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
    self.textField = txtField;
    
	_textField.tag = TEXTFIELD_TAG;
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_textField.textAlignment = UITextAlignmentLeft;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //_textField.hidden = YES; //will get displayed in setup depending on the model
    [cell.contentView addSubview:_textField];
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }  
        else{
            _textField.textColor = [UIColor blackColor];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  
    
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        _textField.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (id)performStandardLayout:(CKNSStringPropertyCellController*)controller{
	[super performStandardLayout:controller];
    UITableViewCell* cell = controller.tableViewCell;
	UITextField *textField = controller.textField;
	if(textField){
        if(controller.cellStyle == CKTableViewCellStyleValue3
           || controller.cellStyle == CKTableViewCellStylePropertyGrid){
            textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
            CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - ((textField.font.lineHeight + 10) / 2.0)) : self.contentInsets.top;
            
            CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[self containerController]];
            CGFloat realWidth = rowWidth;
            CGFloat width = realWidth * self.componentsRatio;
            
            CGFloat textFieldWidth = width - (self.contentInsets.right + self.componentsSpace);
            CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
            if(![cell.textLabel.text isKindOfClass:[NSString class]] || [cell.textLabel.text length] <= 0){
                textFieldWidth = realWidth - (self.contentInsets.left + self.contentInsets.right);
                textFieldX = self.contentInsets.left;
            }
			textField.frame = CGRectIntegral(CGRectMake(textFieldX,y,textFieldWidth,(textField.font.lineHeight + 10)));
            
            //align textLabel on y
            CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
            CGFloat txtLabelHeight = cell.textLabel.height;
            CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
            cell.textLabel.y = txtLabelY;
        }
        else if(controller.cellStyle == CKTableViewCellStyleSubtitle2){
            textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            CGFloat x = cell.textLabel.x;
            CGRect textFrame = cell.textLabel.frame;
            CGFloat width = cell.contentView.width - x - 10;
            
			textField.frame = CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,(textField.font.lineHeight + 10)));
        }
    }
    return (id)nil;
}

- (void)textFieldChanged:(id)value{
    [self setValueInObjectProperty:value];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[cell clearBindingsContext];
    
    self.textField = (UITextField*)[cell.contentView viewWithTag:TEXTFIELD_TAG];
	
	CKProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad
       || self.cellStyle != CKTableViewCellStylePropertyGrid){
        cell.textLabel.text = _(descriptor.name);
    }
	
	cell.detailTextLabel.text = nil;
	
	if([model isReadOnly] || self.readOnly){
        self.textField.hidden = YES;
        
        self.fixedSize = YES;
        [cell beginBindingsContextByRemovingPreviousBindings];
		[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
		[cell endBindingsContext];
        _textField.delegate = nil;
	}
	else{
        if(_textField){
            if(self.cellStyle == CKTableViewCellStylePropertyGrid
               && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                self.fixedSize = YES;
            }
            else{
                self.fixedSize = NO;
            }
            [cell beginBindingsContextByRemovingPreviousBindings];
            [model.object bind:model.keyPath toObject:self.textField withKeyPath:@"text"];
            [[NSNotificationCenter defaultCenter] bindNotificationName:UITextFieldTextDidChangeNotification object:self.textField 
                                                             withBlock:^(NSNotification *notification) {
                                                                 [self textFieldChanged:self.textField.text];
                                                             }];
            [cell endBindingsContext];
            
            NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
            self.textField.placeholder = _(placeholerText);
            self.textField.hidden = NO;
            _textField.delegate = self;
            
            cell.detailTextLabel.text = nil;
        }
	}
}

- (void)rotateCell:(UITableViewCell*)cell  animated:(BOOL)animated{
	[super rotateCell:cell animated:animated];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.inputAccessoryView = [self navigationToolbar];

    if([self needsNextKeyboard]){
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        self.textField.returnKeyType = UIReturnKeyDone;
    }
    
	[self scrollToRow];
    
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[self didResignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([self activateNextResponder] == NO){
		[textField resignFirstResponder];
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CKPropertyExtendedAttributes* attributes = [[self objectProperty]extendedAttributes];
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

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToRowAfterDelay:0];
}


- (BOOL)hasResponder{
	return ![self.objectProperty isReadOnly];
}

- (UIView*)nextResponder:(UIView*)view{
    if(view == nil){
        return [view viewWithTag:TEXTFIELD_TAG];
    }
	return nil;
}

@end

