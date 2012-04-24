//
//  CKUIView+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIView+InlineDebugger.h"
#import "CKTableViewCellController+CKBlockBasedInterface.h"
#import "CKArrayCollection.h"
#import "CKDebug.h"
#import "CKCache.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIImage+Transformations.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKCascadingTree.h"
#import "CKUIColor+ValueTransformer.h"
#import "CKNSObject+Bindings.h"

@implementation UIView (CKInlineDebugger)

+ (UIImage*)createsImageForView:(UIView*)view{
    if(view.layer.contents){
        return [UIImage imageWithCGImage:(CGImageRef)view.layer.contents];
    }
    
    //NSString* key = [NSString stringWithFormat:@"image<%p>",view];
    UIImage* image = nil;//[[CKCache sharedCache] imageForKey:key];
    //if(image){
    //    return image;
    //}

    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawRect:view.bounds];
    image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //if(image){
    //    [[CKCache sharedCache] setImage:image  forKey:key];
    //}
    
    return image;
}

+ (UIImage*)createsThumbnailForView:(UIView*)view{
    //NSString* key = [NSString stringWithFormat:@"thumbnail<%p>",view];
    UIImage* thumbnail = nil;//[[CKCache sharedCache] imageForKey:key];
    //if(thumbnail){
    //    return thumbnail;
    //}
    
    UIImage* image = [UIView createsImageForView:view];
    if(image){
        thumbnail = [image imageThatFits:CGSizeMake(40,40) crop:NO];
        
        //if(thumbnail){
        //    [[CKCache sharedCache] setImage:thumbnail  forKey:key];
        //}
    }

    return thumbnail;
}

+ (NSString*)titleForView:(UIView*)view{
    NSString *title = NSStringFromClass([view class]);
    CKProperty* nameProperty = [CKProperty propertyWithObject:view keyPath:@"name"];
    NSString *name = ([nameProperty descriptor] && [NSObject isClass:[[nameProperty descriptor]type] kindOfClass:[NSString class]] )? [nameProperty value] : nil;
    if([name length] <= 0){
        name = nil;
    }
    return name ? [NSString stringWithFormat:@"%@ - %@",title,name] : title;
}

+ (NSString*)subTitleForView:(UIView*)view{
    NSMutableString* subTitle = [NSMutableString string];
    if(view.hidden){
        [subTitle appendFormat:@"(hidden)"];
    }
    if(view.tag != 0){
        [subTitle appendFormat:@"%@(tag:%d)",([subTitle length] > 0) ? @"," : @"",view.tag];
    }
    if([view appliedStyle] == nil || [[view appliedStyle]isEmpty]){
        [subTitle appendFormat:@"%@(No Stylesheet)",([subTitle length] > 0) ? @"," : @""];
    }
    return subTitle;
}

+ (CKItemViewControllerFactoryItem*)factoryItemForSubViewInView:(UIView*)view{
    return [CKItemViewControllerFactoryItem itemForObjectOfClass:[UIView class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {
        CKTableViewCellController* controller = [CKTableViewCellController cellController];
        
        controller.text = [UIView titleForView:object];
        controller.detailText = [UIView subTitleForView:object];
        controller.image = [UIView createsThumbnailForView:object];
        controller.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        __block CKTableViewCellController* bcontroller = controller;
        __block UIView* bsubView = object;
        [controller beginBindingsContextByRemovingPreviousBindings];
        CKProperty* nameProperty = [CKProperty propertyWithObject:object keyPath:@"name"];
        if([nameProperty descriptor]){
            [nameProperty.object bind:nameProperty.keyPath withBlock:^(id value) {
                bcontroller.text = [UIView titleForView:bsubView];
            }];
            [bsubView bind:@"hidden" withBlock:^(id value) {
                bcontroller.detailText = [UIView subTitleForView:bsubView];
            }];
            [bsubView bind:@"tag" withBlock:^(id value) {
                bcontroller.detailText = [UIView subTitleForView:bsubView];
            }];
            [bsubView.layer bind:@"contents" withBlock:^(id value) {
                bcontroller.image = [UIView createsThumbnailForView:bsubView];
            }];
        }
        [controller.tableViewCell endBindingsContext];
        
        NSInteger indent = 0;
        
        UIView* v = object;
        while(v && v != view){
            indent++;
            v = [v superview];
        }
        
        controller.indentationLevel = indent;
        
        [controller setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
            controller.tableViewCell.imageView.layer.shadowColor = [[UIColor blackColor]CGColor];
            controller.tableViewCell.imageView.layer.shadowOpacity = 0.6;
            controller.tableViewCell.imageView.layer.shadowOffset = CGSizeMake(0,2);
            controller.tableViewCell.imageView.layer.shadowRadius = 2;
            controller.tableViewCell.imageView.layer.cornerRadius = 3;
            controller.tableViewCell.imageView.layer.borderWidth = 0.5;
            controller.tableViewCell.imageView.layer.borderColor = [[UIColor convertFromNSString:@"0.7 0.7 0.7 1"]CGColor];
        }];
        
        [controller setSelectionBlock:^(CKTableViewCellController *controller) {
            UIView* subView = (UIView*)controller.value;
            
            CKUIViewController* slideshow = [CKUIViewController controller];
            slideshow.viewDidLoadBlock = ^(CKUIViewController* controller){
                UIImageView* imageView = [[[UIImageView alloc]initWithFrame:controller.view.bounds]autorelease];
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                imageView.image = [UIView createsImageForView:subView];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [controller.view addSubview:imageView];
                controller.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            };
            [controller.containerController.navigationController pushViewController:slideshow animated:YES];
        }];
        
        [controller setAccessorySelectionBlock:^(CKTableViewCellController *controller) {
            UIView* subView = (UIView*)controller.value;
            
            CKFormTableViewController* subViewDebugger = [[subView class]inlineDebuggerForObject:subView];
            [controller.containerController.navigationController pushViewController:subViewDebugger animated:YES];
        }];
        return controller;
    }];
}

+ (void)addView:(UIView*)view toCollection:(CKCollection*)collection{
    if(view.tag == CKInlineDebuggerControllerHighlightViewTag)
        return;
    
    [collection addObject:view];
    
    for(UIView* subView in view.subviews){
        [UIView addView:subView toCollection:collection];
    }
}

+ (CKFormTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view{
    CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
    debugger.name = @"CKInlineDebuggerForSubViews";
    
    CKArrayCollection* collection = [CKArrayCollection object];
    [UIView addView:view toCollection:collection];
    
    CKItemViewControllerFactory* factory = [CKItemViewControllerFactory factory];
    [factory addItem:[UIView factoryItemForSubViewInView:view]];
    
    CKFormBindedCollectionSection* section = [CKFormBindedCollectionSection sectionWithCollection:collection factory:factory];
    [debugger addSections:[NSArray arrayWithObject:section]];
    return debugger;
}

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [NSObject inlineDebuggerForObject:object];
    UIView* view = (UIView*)object;
    
    __block CKFormTableViewController* bController = debugger;
    
    CKFormSection* superViewSection = [CKFormSection section];
    superViewSection.headerTitle = @"Views";
    
    if([view superview]){
        NSString* title = [NSString stringWithFormat:@"%@ <%p>",[[view superview] class],[view superview]];
        CKTableViewCellController* superViewCell = [CKTableViewCellController cellControllerWithTitle:@"Super View" subtitle:title action:^(CKTableViewCellController* controller){
            CKFormTableViewController* superViewForm = [[[view superview]class] inlineDebuggerForObject:[view superview]];
            superViewForm.title = title;
            [bController.navigationController pushViewController:superViewForm animated:YES];
        }];
        [superViewSection addCellController:superViewCell];
    }
    
    CKTableViewCellController* hierarchyCell = [CKTableViewCellController cellControllerWithTitle:@"Hierarchy" action:^(CKTableViewCellController* controller){
        CKFormTableViewController* hierarchyController = [UIView inlineDebuggerForSubViewsOfView:(UIView*)object];
        hierarchyController.title = @"Hierarchy";
        [bController.navigationController pushViewController:hierarchyController animated:YES];
    }];
    [superViewSection addCellController:hierarchyCell];
    
    [debugger insertSection:superViewSection atIndex:0];
    return debugger;
}

@end
