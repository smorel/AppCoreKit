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
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellNextResponder.h"
#import "CKObjectTableViewController.h"

#define CKNSStringMultilinePropertyCellControllerDefaultHeight 60

@interface CKMultilineNSStringPropertyCellController()
@property(nonatomic,retain,readwrite)CKTextView* textView;
@end

@implementation CKMultilineNSStringPropertyCellController
@synthesize textView = _textView;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
	return self;
}

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
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_textView.backgroundColor = [UIColor clearColor];
    _textView.tag = 50000;
	_textView.maxStretchableHeight = CGFLOAT_MAX;
    _textView.scrollEnabled = NO;
    _textView.placeholderOffset = CGPointMake(10,8);
    
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.placeholderLabel.font = [UIFont systemFontOfSize:17];
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textView.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        }  
        else{
            _textView.textColor = [UIColor blackColor];
        }
    }  
    
	[cell.contentView addSubview:_textView];
}

- (void)layoutCell:(UITableViewCell *)cell{
	[super layoutCell:cell];
    
    _textView.autoresizingMask = UIViewAutoresizingNone;
    if(self.cellStyle == CKTableViewCellStyleValue3){
        _textView.frame = [self value3DetailFrameForCell:cell];
    }
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if(cell.textLabel.text == nil || 
               [cell.textLabel.text isKindOfClass:[NSNull class]] ||
               [cell.textLabel.text length] <= 0){
                CGRect textViewFrame = CGRectMake(3,0,cell.contentView.bounds.size.width - 6,cell.contentView.bounds.size.height);
                _textView.frame = textViewFrame;
            }
            else{
                //sets the textLabel on one full line and the textView beside
                CGRect textFrame = [self propertyGridTextFrameForCell:cell];
                textFrame = CGRectMake(10,0,cell.contentView.bounds.size.width - 20,28);
                cell.textLabel.frame = textFrame;
                
                CGRect textViewFrame = CGRectMake(3,30,cell.contentView.bounds.size.width - 6,cell.contentView.bounds.size.width - 30);
                _textView.frame = textViewFrame;
            }
        }
        else{
            CGRect f = [self propertyGridDetailFrameForCell:cell];
            _textView.frame = CGRectMake(f.origin.x - 8,f.origin.y + 3,f.size.width + 8,f.size.height);
        }
    }
}


+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
    UIViewController* controller = [params parentController];
    NSAssert([controller isKindOfClass:[CKObjectTableViewController class]],@"invalid parent controller");
    
    CGFloat rowWidth = 0;
    CKObjectTableViewController* parentTableViewController = (CKObjectTableViewController*)controller;
    NSArray* visibleViews = [parentTableViewController visibleViews];
    if([visibleViews count] > 0){
        rowWidth = [(UITableViewCell*)[visibleViews objectAtIndex:0]bounds].size.width;
    }
    
    CKObjectProperty* property = (CKObjectProperty*)object;
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    NSString* text = _(descriptor.name);
    NSString* detail = [NSString stringWithFormat:@"%@%@",[property value],
                        ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? @"\nFAKE\nFAKE" : @"\nFAKE"];
    //always have one or two lines more to avoid animation vs. carret glitch.
    
    //SEE how to get the real font ...
    CGSize detailSize = [detail sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(rowWidth - 6,CGFLOAT_MAX)];
    CGFloat detailHeight = MAX(CKNSStringMultilinePropertyCellControllerDefaultHeight,detailSize.height);
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(text == nil || 
           [text isKindOfClass:[NSNull class]] ||
           [text length] <= 0){
            return [NSValue valueWithCGSize:CGSizeMake(100,detailHeight)];
        }
        else{
            return [NSValue valueWithCGSize:CGSizeMake(100,detailHeight + 30)];
        }
    }
    return [NSValue valueWithCGSize:CGSizeMake(100,detailHeight)];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}
 
- (void)textViewChanged:(id)value{
	CKObjectProperty* model = self.value;
	NSString* strValue = [model value];
	if(value && ![value isKindOfClass:[NSNull class]] &&
	   ![value isEqualToString:strValue]){
		[model setValue:value];
		[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
	}
    
    [[self parentTableView]beginUpdates];
    [[self parentTableView]endUpdates];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
    
    CKObjectProperty* property = (CKObjectProperty*)self.value;
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        cell.textLabel.text = _(descriptor.name);
    }
	
	_textView.delegate = self;
	_textView.placeholder =  _(descriptor.name);
	_textView.text = [property value];
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [property.object bind:property.keyPath toObject:_textView withKeyPath:@"text"];
    [self endBindingsContext];
}


#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
                                  atScrollPosition:UITableViewScrollPositionNone
                                          animated:YES];
    
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self didResignFirstResponder];
    //Do not call the following code from here as we have a return button not next and textViewShouldEndEditing could be called when scrolling. 
    /*if([CKTableViewCellNextResponder activateNextResponderFromController:self] == NO){
        [textView resignFirstResponder];
    }*/
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    return YES;
}

-(void)textViewValueChanged:(NSString*)text{
    [self textViewChanged:text];
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
                                  atScrollPosition:UITableViewScrollPositionNone
                                          animated:YES];
}


+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return YES;
}

+ (UIResponder*)responderInView:(UIView*)view{
	UITextView *textView = (UITextView*)[view viewWithTag:50000];
	return textView;
}

@end
