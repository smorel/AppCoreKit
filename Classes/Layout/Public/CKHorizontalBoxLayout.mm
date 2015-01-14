//
//  CKHorizontalBoxLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKHorizontalBoxLayout.h"
#include <ext/hash_map>
#include <ext/hash_set>
#import "CKLayoutFlexibleSpace.h"
#import "CKCascadingTree.h"

using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash< id >
    {
        size_t operator()( id x) const{
            return (size_t)x;
        }
    };
}


@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;
- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index;

#ifdef LAYOUT_DEBUG_ENABLED
@property(nonatomic,assign,readwrite) UIView* debugView;
#endif

@end


@implementation CKHorizontalBoxLayout

+ (void)load{
    [CKCascadingTree registerAlias:[[self class]description] forKey:@"HBox"];
    [CKCascadingTree registerAlias:[[self class]description] forKey:@"Horizontal"];
}

- (id)init{
    self = [super init];
    self.sizeToFitLayoutBoxes = YES;
    return self;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)constraintSize{
    if([self.layoutBoxes count] <= 0 && self.sizeToFitLayoutBoxes)
        return CGSizeMake(0,0);
    
    CGSize size = [CKLayoutBox preferredSizeConstraintToSize:constraintSize forBox:self];
    size = CGSizeMake(size.width - self.padding.left - self.padding.right,size.height - self.padding.top - self.padding.bottom);
    
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    BOOL includesFlexispaces = (size.width < MAXFLOAT);
    
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    
    if([self.layoutBoxes count] > 0){
        
        //Compute flexible width
        CGFloat flexiblewidth = size.width;
        NSInteger flexibleCount = 0;
        NSInteger numberOfFlexiSpaces = NO;
        hash_set<id> appliedMargins;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            
            if(!box.hidden){
                if([box isKindOfClass:[CKLayoutFlexibleSpace class]] && !includesFlexispaces){}
               // else if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        numberOfFlexiSpaces++;
                        flexibleCount++;
                        appliedMargins.insert(box);
                    }else{
                        if(box.maximumSize.width == box.minimumSize.width){ //fixed size
                            flexiblewidth -= box.maximumSize.width;
                        }else{
                            flexibleCount++;
                        }
                        
                        CGFloat leftMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxLeft = [self previousVisibleBoxFromIndex:i-1];
                            if(boxLeft && ![boxLeft isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                leftMargin = MAX(box.margins.left,boxLeft.margins.right);
                            }else if(appliedMargins.find(boxLeft) == appliedMargins.end()){
                                leftMargin = box.margins.left;
                            }
                        }else{
                            leftMargin = box.margins.left;
                        }
                        appliedMargins.insert(box);
                        
                        flexiblewidth -= leftMargin;
                    }
                }
            }
        }
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1];
        if(lastBox){
            flexiblewidth -= lastBox.margins.right;
        }
        
        //Adjust Flexible boxes using minimum/maximum sizes
        hash_map<id, CGSize> precomputedSize;
        CGFloat flexibleSizeToRemove = 0;
        NSInteger flexibleCountToRemove = 0;
        
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                }
               // else if([box isKindOfClass:[CKLayoutBox class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    
                    CGFloat height = MIN(size.height - box.margins.top - box.margins.bottom,box.maximumSize.height);
                    
                    CGSize subsize = CGSizeMake(0,0);
                    if(box.maximumSize.width == box.minimumSize.width){ //fixed size
                        CGSize constrainedSize = [box preferredSizeConstraintToSize:CGSizeMake(box.minimumSize.width,/*(NSInteger)preferedWidth*/ /*MAXFLOAT,*/height)];
                        precomputedSize[box] = CGSizeMake(box.minimumSize.width,constrainedSize.height);
                    }else{
                        CGFloat preferedWidth = flexiblewidth / (flexibleCount - numberOfFlexiSpaces);
                        subsize = [box preferredSizeConstraintToSize:CGSizeMake(size.width,/*(NSInteger)preferedWidth*/ /*MAXFLOAT,*/height)];
                        
                        if( numberOfFlexiSpaces > 0
                           || (subsize.width < preferedWidth && box.maximumSize.width == MAXFLOAT)
                           || (subsize.width <= preferedWidth && box.maximumSize.width == subsize.width)){
                            precomputedSize[box] = subsize;
                            flexibleSizeToRemove += subsize.width;
                            flexibleCountToRemove++;
                            
                            
                            flexiblewidth -= subsize.width;
                            flexibleCount -= 1;
                        }
                    }
                }
            }
        }
        
        //Compute layout
        CGFloat x =  0;
        appliedMargins.clear();
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                if([box isKindOfClass:[CKLayoutFlexibleSpace class]] && !includesFlexispaces){}
                //else if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        CGFloat leftMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxLeft = [self previousVisibleBoxFromIndex:i-1];
                            if(boxLeft && ![boxLeft isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                leftMargin = MAX(box.margins.left,boxLeft.margins.right);
                            }else if(appliedMargins.find(boxLeft) == appliedMargins.end()){
                                leftMargin = box.margins.left;
                            }
                        }else{
                            leftMargin = box.margins.left;
                        }
                        
                        x += leftMargin;
                    }
                    appliedMargins.insert(box);
                    
                    CGSize subsize = CGSizeMake(0,0);
                    hash_map<id, CGSize>::iterator it = precomputedSize.find(box);
                    if(it != precomputedSize.end()){
                        subsize = it->second;
                        box.lastComputedSize = subsize;
                        box.lastPreferedSize = subsize;
                    }else{
                        CGFloat height = MIN(size.height - box.margins.top - box.margins.bottom,box.maximumSize.height);
                        
                        CGFloat preferedWidth = flexiblewidth / flexibleCount;
                        subsize = [box preferredSizeConstraintToSize:CGSizeMake((NSInteger)preferedWidth,height)];
                        flexiblewidth -= subsize.width;
                        flexibleCount--;
                    }
                    
                    CGFloat totalHeight = box.margins.top + box.margins.bottom + subsize.height;
                    if(maxHeight < totalHeight) maxHeight = totalHeight;
                    
                    x += subsize.width;
                }
            }
            
            maxWidth = x + lastBox.margins.right;
        }
    }
    
    if(self.sizeToFitLayoutBoxes){
        CGSize ret = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(MIN(maxWidth,size.width),MIN(maxHeight,size.height)) forBox:self];
        self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(ret.width + self.padding.left + self.padding.right,
                                                                                 ret.height + self.padding.bottom + self.padding.top)
                                                               forBox:self];
    }else{
        self.lastPreferedSize = constraintSize;
    }
    
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize size = [self preferredSizeConstraintToSize:theframe.size];
    [self setBoxFrameTakingCareOfTransform:CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height)];
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView.frame = self.frame;
#endif
    
    if([self.layoutBoxes count] > 0){
        
        hash_map<id, CGRect> framePerBox;
        
        //Compute layout
        CGFloat x =  self.frame.origin.x + self.padding.left;
        hash_set<id> appliedMargins;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
              //  if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
               // else{
                    if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        CGFloat leftMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxLeft = [self previousVisibleBoxFromIndex:i-1];
                            if(boxLeft && ![boxLeft isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                leftMargin = MAX(box.margins.left,boxLeft.margins.right);
                            }else if(appliedMargins.find(boxLeft) == appliedMargins.end()){
                                leftMargin = box.margins.left;
                            }
                        }else{
                            leftMargin = box.margins.left;
                        }
                        
                        x += leftMargin;
                    }
                    appliedMargins.insert(box);
                    
                    CGSize subsize = box.lastPreferedSize;
                    
                    CGRect boxframe = CGRectMake(x,box.margins.top,MAX(0,subsize.width),MAX(0,subsize.height));
                    framePerBox[box] = boxframe;
                    //[box setBoxFrameTakingCareOfTransform:CGRectIntegral(boxframe)];
                    
                    x += subsize.width;
               // }
            }
        }
        
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1];
        CGFloat totalWidth = x + (lastBox ? lastBox.margins.right : 0) -  self.frame.origin.x;
        
        //Handle Horizontal alignment
        CGFloat totalHeight = (size.height - self.padding.top - self.padding.bottom);
        
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
              //  if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
              //  else{
                
                hash_map<id, CGRect>::iterator it = framePerBox.find(box);
                CGRect boxFrame = it->second;
                    
                    CGFloat offsetX = 0;
                    CGFloat offsetY = self.frame.origin.y + self.padding.top;
                    switch(self.verticalAlignment){
                        case CKLayoutVerticalAlignmentTop:break; //this is already computed
                        case CKLayoutVerticalAlignmentBottom: offsetY += totalHeight - boxFrame.size.height; break; //this is already computed
                        case CKLayoutVerticalAlignmentCenter: offsetY += (totalHeight  / 2) - (boxFrame.size.height / 2); break; //this is already computed
                    }
                    
                    
                    if(totalWidth < (size.width - self.padding.left - self.padding.right)){
                        switch(self.horizontalAlignment){
                            case CKLayoutHorizontalAlignmentLeft: break; //default behaviour
                            case CKLayoutHorizontalAlignmentCenter:  offsetX = (self.frame.size.width - totalWidth) / 2; break;
                            case CKLayoutHorizontalAlignmentRight:   offsetX = (self.frame.size.width - totalWidth); break;
                        }
                    }
                    
                    CGRect newboxFrame = CGRectIntegral(CGRectMake(boxFrame.origin.x + offsetX,boxFrame.origin.y + offsetY,boxFrame.size.width,boxFrame.size.height));
                    [box setBoxFrameTakingCareOfTransform:newboxFrame];
                    [box performLayoutWithFrame:newboxFrame];
               // }
            }
        }
    }
}

@end
