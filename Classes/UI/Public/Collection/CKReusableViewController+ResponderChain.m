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
        
        if([c hasResponder] || [c nestedReusableViewControllerChain].count > 0)
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
        
        if(tableView){
            [tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionNone
                                     animated:YES];
        }
        
        
        UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
        if(tableViewCell != nil){
            [[self class] activateAfterDelay:controller indexPath:indexPath];
        }
        else{
            [[self class]performSelector:@selector(activateAfterDelay:indexPath:) withObject:controller withObject:indexPath afterDelay:0.3];
        }
    }
}


- (CKReusableViewController*)rootReusableViewController{
    CKReusableViewController* c = self;
    while ([c.containerViewController isKindOfClass:[CKReusableViewController class]]) {
        c = (CKReusableViewController*)c.containerViewController;
    }
    return c;
}

- (NSArray*)nestedReusableViewControllerChain{
    CKReusableViewController* c = [self rootReusableViewController];
    
    if(![c isViewLoaded])
        return nil;
    
    NSMutableArray* chain = [NSMutableArray array];
    [CKReusableViewController addReusableViewControllerResponderFromController:c toChain:chain];
    
    NSInteger index = [chain indexOfObjectIdenticalTo:c];
    if(index != NSNotFound){
        [chain removeObjectAtIndex:index];
    }
    
    return chain;
}

+ (void)addReusableViewControllerResponderFromController:(CKReusableViewController*)controller toChain:(NSMutableArray*)chain{
    if([controller hasResponder]){
        NSInteger index = [chain indexOfObjectIdenticalTo:controller];
        if(index == NSNotFound){
            [chain addObject:controller];
        }
    }
    
    for(NSObject<CKLayoutBoxProtocol>* box in controller.view.layoutBoxes){
        [self addReusableViewControllerResponder:box toChain:chain];
    }
}

+ (void)addReusableViewControllerResponder:(NSObject<CKLayoutBoxProtocol>*)layoutBox toChain:(NSMutableArray*)chain{
    if([layoutBox isKindOfClass:[CKReusableViewController class]]){
        [self addReusableViewControllerResponderFromController:(CKReusableViewController*)layoutBox toChain:chain];
    }
    
    for(NSObject<CKLayoutBoxProtocol>* box in layoutBox.layoutBoxes){
        [self addReusableViewControllerResponder:box toChain:chain];
    }
}

- (BOOL)activateNextResponder{
    //TODO: handle multiple responders in [self responderChain]
    
    if(!self.indexPath){
        NSArray* nested = [self nestedReusableViewControllerChain];
        NSInteger index = [nested indexOfObjectIdenticalTo:self];
        if(index < nested.count - 1){
            CKReusableViewController* c = [nested objectAtIndex:index + 1];
            [c becomeFirstResponder];
        }else{
            CKReusableViewController* c = [self rootReusableViewController];
            NSIndexPath* nextIndexPath =  [c findNextResponderWithScrollEnabled:NO];
            if(nextIndexPath == nil)
                return NO;
            [CKReusableViewController activateResponderAtIndexPath:nextIndexPath controller:c];
        }
    }
    
    NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:YES];
    if(nextIndexPath == nil)
        return NO;
    [CKReusableViewController activateResponderAtIndexPath:nextIndexPath controller:self];
    
    return YES;
}


- (BOOL)hasNextResponder{
    if(!self.indexPath){
        //Handles nested reusable view controllers
        NSArray* nested = [self nestedReusableViewControllerChain];
        NSInteger index = [nested indexOfObjectIdenticalTo:self];
        if(index < nested.count - 1)
            return YES;
        else{
            CKReusableViewController* c = [self rootReusableViewController];
            NSIndexPath* nextIndexPath =  [c findNextResponderWithScrollEnabled:NO];
            return (nextIndexPath != nil);
        }
    }
    
    NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:NO];
    return (nextIndexPath != nil);
}

- (BOOL)activatePreviousResponder{
    //TODO: handle multiple responders in [self responderChain]
    
    if(!self.indexPath){
        NSArray* nested = [self nestedReusableViewControllerChain];
        NSInteger index = [nested indexOfObjectIdenticalTo:self];
        if(index > 0){
            CKReusableViewController* c = [nested objectAtIndex:index - 1];
            [c becomeFirstResponder];
        }else{
            CKReusableViewController* c = [self rootReusableViewController];
            NSIndexPath* previousIndexPath =  [c findPreviousResponderWithScrollEnabled:NO];
            if(previousIndexPath == nil)
                return NO;
            [CKReusableViewController activateResponderAtIndexPath:previousIndexPath controller:c];
        }
    }
    
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:YES];
    if(previousIndexPath == nil)
        return NO;
    [CKReusableViewController activateResponderAtIndexPath:previousIndexPath controller:self];
    
    return YES;
}

- (BOOL)hasPreviousResponder{
    if(!self.indexPath){
        //Handles nested reusable view controllers
        NSArray* nested = [self nestedReusableViewControllerChain];
        NSInteger index = [nested indexOfObjectIdenticalTo:self];
        if(index > 0)
            return YES;
        else{
            CKReusableViewController* c = [self rootReusableViewController];
            NSIndexPath* previousIndexPath =  [c findPreviousResponderWithScrollEnabled:NO];
            return (previousIndexPath != nil);
        }
    }
    
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:NO];
    return (previousIndexPath != nil);
}




- (void)addResponder:(UIView*)view toChain:(NSMutableArray*)chain{
    if(view.containerViewController != self)
        return;
    
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
    if(![self isViewLoaded])
        return nil;
    
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
    CKReusableViewController* previousResponder = (CKReusableViewController*)[self.containerViewController firstResponderController];
    
    NSIndexPath* previousIndexPath = previousResponder.indexPath;
    if(!previousIndexPath){
        CKReusableViewController* root = [previousResponder rootReusableViewController];
        previousIndexPath = root.indexPath;
    }
    
    NSIndexPath* indexPath = self.indexPath;
    
    NSInteger direction = 0;
    if(previousIndexPath.section == indexPath.section){
        direction = indexPath.row - previousIndexPath.row;
    }else{
        direction = indexPath.section - previousIndexPath.section;
    }
    
    [self.containerViewController setFirstResponderController:self];
    
    if(previousResponder != self){
        [previousResponder resignFirstResponder];
    }

    
    UIView* responder = [self nextResponder:nil];
    if(!responder){
        NSArray* nested = [self nestedReusableViewControllerChain];
        if(nested.count > 0){
            //todo if hit previous should become responder on last nested not 0!
            CKReusableViewController* c = direction >= 0 ? [nested objectAtIndex:0] : [nested objectAtIndex:nested.count-1];
            [c becomeFirstResponder];
        }else{
            [self didBecomeFirstResponder];
        }
    }else{
        if(responder && [responder isKindOfClass:[UIResponder class]]){
            [responder becomeFirstResponder];
        }
        
        [self didBecomeFirstResponder];
    }
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
