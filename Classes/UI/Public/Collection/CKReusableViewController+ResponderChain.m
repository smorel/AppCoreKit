//
//  CKReusableViewController+ResponderChain.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController+ResponderChain.h"
#import <objc/runtime.h>
#import "NSObject+Invocation.h"

@interface UIViewController(ResponderChain)
@property (nonatomic,retain) UIViewController* firstResponderController;
@end

@implementation UIViewController(ResponderChain)

static char UIViewControllerFirstResponderControllerKey;
- (void)setFirstResponderController:(UIViewController*)firstResponderController{
    objc_setAssociatedObject(self, &UIViewControllerFirstResponderControllerKey, firstResponderController, OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController*)firstResponderController{
    return objc_getAssociatedObject(self, &UIViewControllerFirstResponderControllerKey);
}

- (BOOL)isFirstResponderController:(UIViewController*)controller{
    return [self firstResponderController] == controller;
}

@end



//TODO: add support for any type of CKViewController not only controllers with tableView property

@implementation CKReusableViewController (ResponderChain)

+ (BOOL)hasResponderAtIndexPath:(NSIndexPath*)indexPath controller:(UIViewController*)controller{
    if([controller respondsToSelector:@selector(controllerAtIndexPath:)]){
        id c = [controller performSelector:@selector(controllerAtIndexPath:) withObject:indexPath];
        if([c hasResponder] == YES)
            return YES;
    }
    
    return NO;
}


- (NSIndexPath*)findNextResponderWithScrollEnabled:(BOOL)enableScroll{
    if([self.containerViewController hasPropertyNamed:@"tableView"]){
        UITableView* tableView = (UITableView*)[self.containerViewController valueForKey:@"tableView"];
        
        NSIndexPath* indexPath = self.indexPath;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        while(nextIndexPath != nil){
            NSInteger rowCountForSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:section];
            if((NSInteger)nextIndexPath.row >= (rowCountForSection - 1)){
                NSInteger sectionCount = [tableView.dataSource numberOfSectionsInTableView:tableView];
                if((NSInteger)nextIndexPath.section >= (sectionCount - 1)){
                    return nil;
                }
                section++;
                row = 0;
            }
            else{
                row++;
            }
            
            nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if([CKReusableViewController hasResponderAtIndexPath:nextIndexPath controller:self.containerViewController]){
                return nextIndexPath;
            }
        }
    }
    return nil;
}

- (NSIndexPath*)findPreviousResponderWithScrollEnabled:(BOOL)enableScroll{
    if([self.containerViewController hasPropertyNamed:@"tableView"]){
        UITableView* tableView = (UITableView*)[self.containerViewController valueForKey:@"tableView"];
        
        NSIndexPath* indexPath = self.indexPath;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        NSIndexPath* previousIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        while(previousIndexPath != nil){
            if(row-1 < 0){
                if((NSInteger)section == 0){
                    return nil;
                }
                section--;
                row = [tableView.dataSource tableView:tableView numberOfRowsInSection:section] - 1;
            }
            else{
                row--;
            }
            
            previousIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if([CKReusableViewController hasResponderAtIndexPath:previousIndexPath controller:self.containerViewController]){
                return previousIndexPath;
            }
        }
    }
    return nil;
}


+ (void)activateAfterDelay:(CKReusableViewController*)controller indexPath:(NSIndexPath*)indexPath{
    if([controller.containerViewController respondsToSelector:@selector(controllerAtIndexPath:)]){
        id c = [controller.containerViewController performSelector:@selector(controllerAtIndexPath:) withObject:indexPath];
        if(c != nil){
            [c performSelector:@selector(becomeFirstResponder)];
            
            [controller resignFirstResponder];
        }
    }
}

+ (void)activateResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKReusableViewController*)controller{
    if([controller.containerViewController hasPropertyNamed:@"tableView"]){
        UITableView* tableView = (UITableView*)[controller.containerViewController valueForKey:@"tableView"];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionNone
                                 animated:YES];
        
        UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
        if(tableViewCell != nil){
            [[self class] activateAfterDelay:controller indexPath:indexPath];
        }
        else{
            [[self class]performSelector:@selector(activateAfterDelay:indexPath:) withObject:controller withObject:indexPath afterDelay:0.3];
        }
    }
}

- (BOOL)activateNextResponder{
    NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:YES];
    if(nextIndexPath == nil)
        return NO;
    [CKReusableViewController activateResponderAtIndexPath:nextIndexPath controller:self];
    
    return YES;
}


- (BOOL)hasNextResponder{
    NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:NO];
    if(nextIndexPath == nil)
        return NO;
    return YES;
}


- (BOOL)activatePreviousResponder{
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:YES];
    if(previousIndexPath == nil)
        return NO;
    [CKReusableViewController activateResponderAtIndexPath:previousIndexPath controller:self];
    
    return YES;
}

- (BOOL)hasPreviousResponder{
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:NO];
    if(previousIndexPath == nil)
        return NO;
    return YES;
}

- (void)addResponder:(UIView*)view toChain:(NSMutableArray*)chain{
    if([view isKindOfClass:[UIResponder class]]){
        if(view.hidden == NO && view.userInteractionEnabled == YES){
            UIResponder* responder = (UIResponder*)view;
            if([responder canBecomeFirstResponder]){
                [chain addObject:view];
            }
        }
    }
    
    for(UIView* sub in view.subviews){
        [self addResponder:sub toChain:chain];
    }
}

- (NSArray*)responderChain{
    NSMutableArray* ar = [NSMutableArray array];
    [self addResponder:self.view toChain:ar];
    return ar;
}

- (BOOL)hasResponder{
    return [[self responderChain]count] > 0;
}

- (BOOL)isFirstResponder{
    return [self.containerViewController firstResponderController] == self;
}

- (void)didBecomeFirstResponder{
    if([self.containerViewController firstResponderController] && ![self.containerViewController isFirstResponderController:self]){
        [[self.containerViewController firstResponderController]resignFirstResponder];
    }
    
    [self.containerViewController setFirstResponderController:self];
}

- (void)becomeFirstResponder{
    UIViewController* previousResponder = [self.containerViewController firstResponderController];
    
    [self.containerViewController setFirstResponderController:self];
    
    if(previousResponder != self){
        [previousResponder resignFirstResponder];
    }

    
    UIView* responder = [self nextResponder:nil];
    if(responder && [responder isKindOfClass:[UIResponder class]]){
        [responder becomeFirstResponder];
    }
    
    [self didBecomeFirstResponder];
    
}

- (void)didResignFirstResponder{
    if([self.containerViewController isFirstResponderController:self]){
        [self.containerViewController setFirstResponderController:nil];
    }
}

- (void)resignFirstResponder{
    NSArray* chain = [self responderChain];
    for(UIResponder* responder in chain){
        if([responder isFirstResponder]){
            [responder resignFirstResponder];
            break;
        }
    }
    [self didResignFirstResponder];
}

- (UIView*)nextResponder:(UIView*)view{
    NSArray* chain = [self responderChain];
    NSInteger index = ((view == nil) ? -1 : [chain indexOfObjectIdenticalTo:view]) + 1;
    if(index >= chain.count)
        return nil;
    
    return [chain objectAtIndex:index];
}

@end
