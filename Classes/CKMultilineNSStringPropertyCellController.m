//
//  CKNSStringMultilinePropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-03.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKMultilineNSStringPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellNextResponder.h"
#import "CKObjectTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Positioning.h"

#define CKNSStringMultilinePropertyCellControllerDefaultHeight 60

#define TEXTVIEW_TAG 50000

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
//

- (void)initTableViewCell:(UITableViewCell*)cell{
    [super initTableViewCell:cell];
    
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.clipsToBounds = NO;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
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
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textView.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }  
        else{
            _textView.textColor = [UIColor blackColor];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  
    
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        _textView.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (id)performStandardLayout:(CKMultilineNSStringPropertyCellController*)controller{
    [super performStandardLayout:controller];
    
    UITableViewCell* cell = controller.tableViewCell;
    if(controller.cellStyle == CKTableViewCellStyleValue3){
        CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[self parentController]];
        CGFloat realWidth = rowWidth;
        CGFloat width = realWidth * self.componentsRatio;
        
        CGFloat textFieldWidth = width - (self.contentInsets.right + self.componentsSpace);
        CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
        
        CGFloat textFieldY = self.contentInsets.top;
        CGFloat textFieldHeight = cell.contentView.height - (self.contentInsets.top + self.contentInsets.bottom);
        controller.textView.frame = CGRectMake(textFieldX,textFieldY,textFieldWidth,textFieldHeight);
    }
    else if(controller.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if(cell.textLabel.text == nil || 
               [cell.textLabel.text isKindOfClass:[NSNull class]] ||
               [cell.textLabel.text length] <= 0){
                CGRect textViewFrame = CGRectMake(3,0,cell.contentView.bounds.size.width - 6,controller.textView.frame.size.height);
                controller.textView.frame = textViewFrame;
            }
            else{
                //sets the textLabel on one full line and the textView beside
                CGRect textFrame = CGRectMake(10,0,cell.contentView.bounds.size.width - 20,28);
                cell.textLabel.frame = textFrame;
                
                CGRect textViewFrame = CGRectMake(3,30,cell.contentView.bounds.size.width - 6,controller.textView.frame.size.height);
                controller.textView.frame = textViewFrame;
            }
        }
        else{
            CGRect f = [controller propertyGridDetailFrameForCell:cell];
            controller.textView.frame = CGRectMake(f.origin.x - 8,f.origin.y - 8 ,f.size.width + 8,controller.textView.frame.size.height);
        }
    }
    else if(controller.cellStyle == CKTableViewCellStyleSubtitle2){
        CGRect textViewFrame = CGRectMake(MAX(self.contentInsets.left,cell.textLabel.x),MAX(self.contentInsets.top,cell.textLabel.y + cell.textLabel.height + 10),cell.contentView.width - (cell.imageView.x + 10) - 10,controller.textView.frame.size.height);
        controller.textView.frame = textViewFrame;
    }

    return (id)nil;
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
    UIViewController* controller = [params parentController];
    NSAssert([controller isKindOfClass:[CKObjectTableViewController class]],@"invalid parent controller");
    
    CKObjectProperty* property = (CKObjectProperty*)object;
    
    CKMultilineNSStringPropertyCellController* staticController = (CKMultilineNSStringPropertyCellController*)[params staticController];
    if([property isReadOnly] || staticController.readOnly){
        return [CKTableViewCellController viewSizeForObject:object withParams:params];
    }
    else{    
		CGFloat bottomTextView = staticController.textView.frame.origin.y + staticController.textView.frame.size.height;
		CGFloat bottomTextLabel = staticController.tableViewCell.textLabel.frame.origin.y + staticController.tableViewCell.textLabel.frame.size.height;
		CGFloat maxHeight = MAX(bottomTextView,bottomTextLabel) + 10;
		return [NSValue valueWithCGSize:CGSizeMake(100,maxHeight)];
    }
    return nil;
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}
 
- (void)textViewChanged:(id)value{
    [self setValueInObjectProperty:value];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
    
    self.textView = (CKTextView*)[cell.contentView viewWithTag:TEXTVIEW_TAG];
    
    CKObjectProperty* property = (CKObjectProperty*)self.value;
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        cell.textLabel.text = _(descriptor.name);
    }
    
    if([property isReadOnly] || self.readOnly){
        self.fixedSize = YES;
        _textView.hidden = YES;
        
        [cell beginBindingsContextByRemovingPreviousBindings];
		[property.object bind:property.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
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
        
        [cell beginBindingsContextByRemovingPreviousBindings];
        [property.object bind:property.keyPath withBlock:^(id value) {
            if(!_textView.frameChangeDelegate){//that means we are not currently editing the value
                _textView.frameChangeDelegate = self;
                _textView.delegate = nil;
                [_textView setText:[property value] animated:YES];
                _textView.delegate = self;
                _textView.frameChangeDelegate = nil;
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
    [[self parentTableView]beginUpdates];
    [[self parentTableView]endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    CKObjectPropertyMetaData* metaData = [[self objectProperty]metaData];
    NSInteger min = [metaData.options minimumLength];
    NSInteger max = [metaData.options maximumLength];
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


+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return YES;
}

+ (UIView*)responderInView:(UIView*)view{
	UITextView *textView = (UITextView*)[view viewWithTag:50000];
	return textView;
}

@end
