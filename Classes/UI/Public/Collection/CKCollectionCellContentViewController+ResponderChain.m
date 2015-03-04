//
//  CKCollectionCellContentViewController+ResponderChain.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionCellContentViewController+ResponderChain.h"


//TODO: add support for any type of CKCollectionViewController not only CKTableViewController

@implementation CKCollectionCellContentViewController (ResponderChain)

+ (BOOL)hasResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKCollectionViewController*)controller{
    if([controller isKindOfClass:[CKTableCollectionViewController class]]){
        CKTableCollectionViewController* tableViewController = (CKTableCollectionViewController*)controller;
        CKTableViewCellController* cellController = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
        if([cellController hasResponder] == YES)
            return YES;
    }
    else{
        CKAssert(NO,@"CKTableViewCellNextResponder is supported only for CKTableCollectionViewController yet");
    }
    return NO;
}


- (NSIndexPath*)findNextResponderWithScrollEnabled:(BOOL)enableScroll{
    if([self.collectionViewController isKindOfClass:[CKTableViewController class]]){
        CKCollectionViewController* parentController = (CKCollectionViewController*)self.collectionViewController;
        
        NSIndexPath* indexPath = self.indexPath;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        while(nextIndexPath != nil){
            NSInteger rowCountForSection = [parentController numberOfObjectsForSection:section];
            if((NSInteger)nextIndexPath.row >= (rowCountForSection - 1)){
                NSInteger sectionCount = [parentController numberOfSections];
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
            if([CKCollectionCellContentViewController hasResponderAtIndexPath:nextIndexPath controller:parentController]){
                return nextIndexPath;
            }
        }
    }
    return nil;
}

- (NSIndexPath*)findPreviousResponderWithScrollEnabled:(BOOL)enableScroll{
    if([self.collectionViewController isKindOfClass:[CKTableViewController class]]){
        CKCollectionViewController* parentController = (CKCollectionViewController*)self.collectionViewController;
        
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
                row = [parentController numberOfObjectsForSection:section] - 1;
            }
            else{
                row--;
            }
            
            previousIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if([CKCollectionCellContentViewController hasResponderAtIndexPath:previousIndexPath controller:parentController]){
                return previousIndexPath;
            }
        }
    }
    return nil;
}


+ (void)activateAfterDelay:(CKCollectionCellContentViewController*)controller indexPath:(NSIndexPath*)indexPath{
    if([controller.collectionCellController isKindOfClass:[CKTableCollectionViewController class]]){
        CKTableCollectionViewController* tableViewController = (CKTableCollectionViewController*)controller.collectionCellController;
        
        CKTableViewCellController* controllerNew = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
        if(controller != nil){
            [controller becomeFirstResponder];
        }
    }
}

+ (void)activateResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKCollectionCellContentViewController*)controller{
    UITableView* tableView = (UITableView*)[controller contentView];
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

- (BOOL)activateNextResponder{
    NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:YES];
    if(nextIndexPath == nil)
        return NO;
    [CKCollectionCellContentViewController activateResponderAtIndexPath:nextIndexPath controller:self];
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
    [CKCollectionCellContentViewController activateResponderAtIndexPath:previousIndexPath controller:self];
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
        UIResponder* responder = (UIResponder*)view;
        if([responder canBecomeFirstResponder]){
            [chain addObject:view];
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


- (void)becomeFirstResponder{
    UIView* responder = [self nextResponder:nil];
    if(responder && [responder isKindOfClass:[UIResponder class]]){
        [responder becomeFirstResponder];
    }
}

- (void)resignFirstResponder{
    NSArray* chain = [self responderChain];
    for(UIResponder* responder in chain){
        if([responder isFirstResponder]){
            [responder resignFirstResponder];
            [self didResignFirstResponder];
            return;
        }
    }
}

- (UIView*)nextResponder:(UIView*)view{
    NSArray* chain = [self responderChain];
    NSInteger index = ((view == nil) ? -1 : [chain indexOfObjectIdenticalTo:view]) + 1;
    if(index >= chain.count)
        return nil;
    
    return [chain objectAtIndex:index];
}

@end
