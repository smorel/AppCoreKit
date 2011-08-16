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

#define CKNSStringMultilinePropertyCellControllerDefaultHeight 60

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
    _textView.tag = 50000;
	_textView.maxStretchableHeight = CGFLOAT_MAX;
    _textView.scrollEnabled = NO;
    _textView.placeholderOffset = CGPointMake(10,8);
    
    _textView.font = cell.detailTextLabel.font;
    _textView.placeholderLabel.font =  _textView.font;
    
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
}

- (id)performStandardLayout:(CKMultilineNSStringPropertyCellController*)controller{
    [super performStandardLayout:controller];
    
    UITableViewCell* cell = controller.tableViewCell;
    controller.textView.autoresizingMask = UIViewAutoresizingNone;
    if(controller.cellStyle == CKTableViewCellStyleValue3){
        controller.textView.frame = [controller value3DetailFrameForCell:cell];
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
                CGRect textFrame = [controller propertyGridTextFrameForCell:cell];
                textFrame = CGRectMake(10,0,cell.contentView.bounds.size.width - 20,28);
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
    
    
    CALayer* layer = [controller.textView layer];
    //layer.borderColor = [[UIColor darkGrayColor]CGColor];
    //layer.backgroundColor = [[UIColor redColor]CGColor];
    /*layer.borderWidth = 3;
    layer.cornerRadius = 10;*/
    
    NSLog(@"CKMultilineNSStringPropertyCellController Layer backColor : %@ borderWidth : %f borderColor : %@ cornerRadius : %f",
          layer.backgroundColor,layer.borderWidth,layer.borderColor,layer.cornerRadius);
    
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
        NSString* text = staticController.tableViewCell.textLabel.text;
        NSString* detail = [property value];
        
        CGRect newFrame = [staticController.textView frameForText:detail];      
		CGFloat bottomTextView = newFrame.origin.y + newFrame.size.height;
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
    
    CKObjectProperty* property = (CKObjectProperty*)self.value;
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        cell.textLabel.text = _(descriptor.name);
    }
    
    if([property isReadOnly] || self.readOnly){
        [self.textView removeFromSuperview];
        
		[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[property.object bind:property.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
		[NSObject endBindingsContext];
	}
	else{
        _respondsToFrameChange = NO;
        NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
        _textView.placeholder =  _(placeholerText);
        _textView.text = [property value];
        _textView.delegate = self;
        
        [self beginBindingsContextByRemovingPreviousBindings];
        [property.object bind:property.keyPath withBlock:^(id value) {
            if(![_textView.text isEqualToString:value]){
                _respondsToFrameChange = YES;
                _textView.text = value;
                _respondsToFrameChange = NO;
            }
        }];
        [self endBindingsContext];
        
        [cell.contentView addSubview:self.textView];
    }
}


#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _respondsToFrameChange = YES;
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
    _respondsToFrameChange = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

-(void)textViewValueChanged:(NSString*)text{
    [self textViewChanged:text];
}


-(void)textViewFrameChanged:(CGRect)frame{
    if(!_respondsToFrameChange)
        return;
    
    [[self parentTableView]beginUpdates];
    [[self parentTableView]endUpdates];
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
