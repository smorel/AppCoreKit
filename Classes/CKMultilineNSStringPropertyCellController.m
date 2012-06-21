//
//  CKNSStringMultilinePropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-03.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKMultilineNSStringPropertyCellController.h"
#import "CKProperty.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKTableCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Positioning.h"

#define CKNSStringMultilinePropertyCellControllerDefaultHeight 60

#define TEXTVIEW_TAG 50000

@interface CKTableViewCellController()
- (CGFloat)computeContentViewSize;
@end

@interface CKMultilineNSStringPropertyCellController()
@property(nonatomic,retain,readwrite)CKTextView* textView;
@end

@implementation CKMultilineNSStringPropertyCellController
@synthesize textView = _textView;

- (void)dealloc {
	[_textView release];
    _textView = nil;
	[super dealloc];
}

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)initTableViewCell:(UITableViewCell*)cell{
    [super initTableViewCell:cell];
    
	self.accessoryView = nil;
	self.accessoryType = UITableViewCellAccessoryNone;
	cell.clipsToBounds = NO;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	
    self.textView = [[[CKTextView alloc] initWithFrame:cell.contentView.bounds] autorelease];
	_textView.backgroundColor = [UIColor clearColor];
    _textView.tag = TEXTVIEW_TAG;
	_textView.maxStretchableHeight = CGFLOAT_MAX;
    _textView.scrollEnabled = NO;
    _textView.placeholderOffset = CGPointMake(10,8);
    
    _textView.font = cell.detailTextLabel.font;
    _textView.placeholderLabel.font =  _textView.font;
    
    _textView.hidden = YES;//will get displayed in setup depending on the model
    [cell.contentView addSubview:_textView];
    
    if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textView.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
       // }  
        //else{
       //     _textView.textColor = [UIColor blackColor];
       //     cell.detailTextLabel.numberOfLines = 0;
       //     cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
       // }
    }  
    
    _textView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)textViewChanged:(id)value{
    [self setValueInObjectProperty:value];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
    [cell clearBindingsContext];
    
    self.textView = (CKTextView*)[cell.contentView viewWithTag:TEXTVIEW_TAG];
    
    CKProperty* property = (CKProperty*)self.value;
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad
       || self.cellStyle == CKTableViewCellStyleIPadForm){
        self.text = _(descriptor.name);
    }
    
    if([property isReadOnly] || self.readOnly){
        self.fixedSize = YES;
        _textView.hidden = YES;
        
        [cell beginBindingsContextByRemovingPreviousBindings];
		[property.object bind:property.keyPath toObject:self withKeyPath:@"detailText"];
		[cell endBindingsContext];
	}
	else{
        self.fixedSize = NO;
        NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
        _textView.placeholder =  _(placeholerText);
        _textView.frameChangeDelegate = nil;
        _textView.delegate = nil;
        [_textView setText:[property value] animated:NO];
        _textView.delegate = self;
        
        __block CKMultilineNSStringPropertyCellController* bself = self;
        
        [cell beginBindingsContextByRemovingPreviousBindings];
        [property.object bind:property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
            if(![_textView.text isEqualToString:value]){
                if(!_textView.frameChangeDelegate){//that means we are not currently editing the value
                    _textView.frameChangeDelegate = bself;
                    _textView.delegate = nil;
                    [_textView setText:[property value] animated:YES];
                    _textView.delegate = bself;
                    _textView.frameChangeDelegate = nil;
                }
            }
        }];
        [cell endBindingsContext];
        
        _textView.hidden = NO;
    }
}


#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _textView.frameChangeDelegate = self;
	[self scrollToRow];
    
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self didResignFirstResponder];
    //Do not call the following code from here as we have a return button not next and textViewShouldEndEditing could be called when scrolling. 
    /*if([CKTableViewCellNextResponder activateNextResponderFromController:self] == NO){
        [textView resignFirstResponder];
     }*/
    _textView.frameChangeDelegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

-(void)textViewValueChanged:(NSString*)text{
    [self textViewChanged:text];
}


-(void)textViewFrameChanged:(CGRect)frame{
    //[[self parentTableView]beginUpdates];
    //[[self parentTableView]endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
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
	return YES;
}

- (UIView*)nextResponder:(UIView*)view{
    if(view == nil){
        return [self.tableViewCell viewWithTag:50000];
    }
	return nil;
}

@end
