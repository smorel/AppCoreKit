//
//  UIView+InlineDebugger.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//


#import "UIView+InlineDebugger.h"
#import "CKArrayCollection.h"
#import "CKDebug.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Transformations.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKCascadingTree.h"
#import "UIColor+ValueTransformer.h"
#import "NSObject+Bindings.h"
#import "CKConfiguration.h"
#import "CKStandardContentViewController.h"

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
        [subTitle appendFormat:@"%@(tag:%ld)",([subTitle length] > 0) ? @"," : @"",(long)view.tag];
    }
    [subTitle appendFormat:@"%@(frame:%@)",([subTitle length] > 0) ? @"," : @"",NSStringFromCGRect(view.frame)];
    
    BOOL hasNoStylesheet = NO;

    hasNoStylesheet = [view appliedStyle] == nil || [[view appliedStyle]isEmpty];
    
    if(hasNoStylesheet){
        [subTitle appendFormat:@"%@(No Stylesheet)",([subTitle length] > 0) ? @"," : @""];
    }
    return subTitle;
}

+ (CKReusableViewControllerFactory*)factoryForViewInView:(UIView*)view subView:(BOOL)subview{
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    [factory registerFactoryForObjectOfClass:[UIView class] factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        CKStandardContentViewController* controller = [CKStandardContentViewController controller];
        
        controller.title = [UIView titleForView:object];
        controller.subtitle = [UIView subTitleForView:object];
        controller.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        __block CKStandardContentViewController* bcontroller = controller;
        __block UIView* bsubView = object;
        
        [controller beginBindingsContextByRemovingPreviousBindings];
        CKProperty* nameProperty = [CKProperty propertyWithObject:object keyPath:@"name"];
        if([nameProperty descriptor]){
            [nameProperty.object bind:nameProperty.keyPath withBlock:^(id value) {
                bcontroller.title = [UIView titleForView:bsubView];
            }];
            [bsubView bind:@"hidden" withBlock:^(id value) {
                bcontroller.subtitle = [UIView subTitleForView:bsubView];
            }];
            [bsubView bind:@"tag" withBlock:^(id value) {
                bcontroller.subtitle = [UIView subTitleForView:bsubView];
            }];
        }
        [controller endBindingsContext];
        
        NSInteger indent = 0;
        
        if(subview){
            UIView* v = object;
            while(v && v != view){
                indent++;
                v = [v superview];
            }
        }else{
            UIView* v = view;
            while(v && v != object){
                indent++;
                v = [v superview];
            }
        }
        
        controller.viewWillAppearBlock = ^(UIViewController* controller, BOOL animated){
            CKStandardContentViewController* sc = (CKStandardContentViewController*)controller;
            
            sc.tableViewCell.indentationLevel = indent;
            sc.tableViewCell.imageView.layer.shadowColor = [[UIColor blackColor]CGColor];
            sc.tableViewCell.imageView.layer.shadowOpacity = 0.6;
            sc.tableViewCell.imageView.layer.shadowOffset = CGSizeMake(0,2);
            sc.tableViewCell.imageView.layer.shadowRadius = 2;
            sc.tableViewCell.imageView.layer.cornerRadius = 3;
            sc.tableViewCell.imageView.layer.borderWidth = 0.5;
            sc.tableViewCell.imageView.layer.borderColor = [[UIColor convertFromNSString:@"0.7 0.7 0.7 1"]CGColor];
            sc.tableViewCell.alpha = view.alpha;
            
            UIImageView* ImageView = [controller.view viewWithName:@"ImageView"];
            ImageView.image = [UIView createsThumbnailForView:object];
        };
        
        controller.didSelectBlock = ^(CKReusableViewController* controller){
            UIView* subView = (UIView*)object;
            
            CKViewController* slideshow = [CKViewController controller];
            slideshow.viewDidLoadBlock = ^(UIViewController* controller){
                UIImageView* imageView = [[[UIImageView alloc]initWithFrame:controller.view.bounds]autorelease];
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                imageView.image = [UIView createsImageForView:subView];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [controller.view addSubview:imageView];
                controller.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            };
            [controller.navigationController pushViewController:slideshow animated:YES];
        };
        
        /*
        [controller setAccessorySelectionBlock:^(CKTableViewCellController *controller) {
            UIView* subView = (UIView*)controller.value;
            
            CKFormTableViewController* subViewDebugger = [[subView class]inlineDebuggerForObject:subView];
            [controller.containerController.navigationController pushViewController:subViewDebugger animated:YES];
        }];
         */
        
        return controller;
    }];
    return factory;
}

+ (void)addView:(UIView*)view toCollection:(CKCollection*)collection{
    if(view.tag == CKInlineDebuggerControllerHighlightViewTag)
        return;
    
    [collection addObject:view];
    
    for(UIView* subView in view.subviews){
        [UIView addView:subView toCollection:collection];
    }
}

+ (CKTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view{
    CKTableViewController* debugger = [[[CKTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
    debugger.name = @"CKInlineDebuggerForSubViews";
    
    CKArrayCollection* collection = [CKArrayCollection collection];
    [UIView addView:view toCollection:collection];
    
    CKReusableViewControllerFactory* factory = [UIView factoryForViewInView:view subView:YES];
    
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:collection factory:factory];
    [debugger addSections:@[section] animated:NO];
    return debugger;
}

+ (CKTableViewController*)inlineDebuggerForSuperViewsOfView:(UIView*)view{
    CKTableViewController* debugger = [[[CKTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
    debugger.name = @"CKInlineDebuggerForSuperViews";
    
    CKArrayCollection* collection = [CKArrayCollection collection];
    UIView* v = view;
    while(v){
        [collection addObject:v];
        v = [v superview];
    }
    
    CKReusableViewControllerFactory* factory = [UIView factoryForViewInView:view subView:YES];
    
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:collection factory:factory];
    [debugger addSections:@[section] animated:NO];
    return debugger;
}


+ (CKTableViewController*)inlineDebuggerForObject:(id)object{
    CKTableViewController* debugger = [NSObject inlineDebuggerForObject:object];
    UIView* view = (UIView*)object;
    
    __block CKTableViewController* bController = debugger;
    
    CKSection* superViewSection = [[[CKSection alloc]init]autorelease];
    superViewSection.headerTitle = @"View Hierarchy";
    
    if([view superview]){
        NSString* title = [NSString stringWithFormat:@"%@ <%p>",[[view superview] class],[view superview]];
        CKStandardContentViewController* superViewCell = [CKStandardContentViewController controllerWithTitle:@"Super View" subtitle:title action:^(CKStandardContentViewController* controller){
            CKTableViewController* superViewForm = [[[view superview]class] inlineDebuggerForObject:[view superview]];
            superViewForm.title = title;
            [bController.navigationController pushViewController:superViewForm animated:YES];
        }];
        [superViewSection addController:superViewCell animated:NO];
    }
    
    CKStandardContentViewController* subhierarchyCell = [CKStandardContentViewController controllerWithTitle:@"Subviews Hierarchy" action:^(CKStandardContentViewController* controller){
        CKTableViewController* hierarchyController = [UIView inlineDebuggerForSubViewsOfView:(UIView*)object];
        hierarchyController.title = @"Subviews Hierarchy";
        [bController.navigationController pushViewController:hierarchyController animated:YES];
    }];
    [superViewSection addController:subhierarchyCell animated:NO];
    
    CKStandardContentViewController* superhierarchyCell = [CKStandardContentViewController controllerWithTitle:@"Superviews Hierarchy" action:^(CKStandardContentViewController* controller){
        CKTableViewController* hierarchyController = [UIView inlineDebuggerForSuperViewsOfView:(UIView*)object];
        hierarchyController.title = @"Superviews Hierarchy";
        [bController.navigationController pushViewController:hierarchyController animated:YES];
    }];
    [superViewSection addController:superhierarchyCell animated:NO];
    
    int i =0;
    for(CKAbstractSection* section in debugger.sectionContainer.sections){
        if([section.name isEqualToString:@"ClassHierarchy"]){
            break;
        }
        ++i;
    }
    
    [debugger insertSection:superViewSection atIndex:i animated:NO];
    return debugger;
}

@end
