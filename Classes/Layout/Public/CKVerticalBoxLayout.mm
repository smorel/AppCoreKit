//
//  CKVerticalBoxLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKVerticalBoxLayout.h"
#include <ext/hash_map>
#include <ext/hash_set>
#import "CKLayoutFlexibleSpace.h"

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


@implementation CKVerticalBoxLayout

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
    
    BOOL includesFlexispaces = (size.height < MAXFLOAT);
    
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    
    if([self.layoutBoxes count] > 0){
        
        //Compute flexible height
        CGFloat flexibleHeight = size.height;
        NSInteger flexibleCount = 0;
        NSInteger numberOfFlexiSpaces = NO;
        hash_set<id> appliedMargins;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                if([box isKindOfClass:[CKLayoutFlexibleSpace class]] && !includesFlexispaces){}
                //else if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        numberOfFlexiSpaces++;
                        flexibleCount++;
                        appliedMargins.insert(box);
                    }
                    else {
                        if(box.maximumSize.height == box.minimumSize.height){ //fixed size
                            flexibleHeight -= box.maximumSize.height;
                        }else{
                            flexibleCount++;
                        }
                        
                        CGFloat topMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1];
                            if(boxBottom && ![boxBottom isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                topMargin = MAX(box.margins.top,boxBottom.margins.bottom);
                            }else if(appliedMargins.find(boxBottom) == appliedMargins.end()){
                                topMargin = box.margins.top;
                            }
                        }else{
                            topMargin = box.margins.top;
                        }
                        appliedMargins.insert(box);
                        
                        flexibleHeight -= topMargin;
                    }
                }
            }
        }
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1];
        if(lastBox){
            flexibleHeight -= lastBox.margins.bottom;
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
                //else if([box isKindOfClass:[CKLayoutBox class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                    
                    CGSize subsize = CGSizeMake(0,0);
                    if(box.maximumSize.height == box.minimumSize.height){ //fixed size
                        precomputedSize[box] = CGSizeMake(width,box.minimumSize.height);
                    }else{
                        CGFloat preferedHeight = flexibleHeight / (flexibleCount - numberOfFlexiSpaces);
                        subsize = [box preferredSizeConstraintToSize:CGSizeMake(width,size.height/*(size.height >= MAXFLOAT) ? MAXFLOAT : (NSInteger)preferedHeight)*/ /*MAXFLOAT*/)];
                        if( numberOfFlexiSpaces > 0
                           || (subsize.height < preferedHeight && box.maximumSize.height == MAXFLOAT)
                           || (subsize.height <= preferedHeight && box.maximumSize.height == subsize.height)){
                            precomputedSize[box] = subsize;
                            flexibleSizeToRemove += subsize.height;
                            flexibleCountToRemove++;
                            
                            flexibleHeight -= subsize.height;
                            flexibleCount -= 1;
                        }
                    }
                }
            }
        }
        
        //Compute layout
        CGFloat y = 0;
        appliedMargins.clear();
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                if([box isKindOfClass:[CKLayoutFlexibleSpace class]] && !includesFlexispaces){}
               // else if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
                else{
                    if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        CGFloat topMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1];
                            if(boxBottom && ![boxBottom isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                topMargin = MAX(box.margins.top,boxBottom.margins.bottom);
                            }else if(appliedMargins.find(boxBottom) == appliedMargins.end()){
                                topMargin = box.margins.top;
                            }
                        }else{
                            topMargin = box.margins.top;
                        }
                        y += topMargin;
                    }
                    appliedMargins.insert(box);
                    
                    CGSize subsize = CGSizeMake(0,0);
                    hash_map<id, CGSize>::iterator it = precomputedSize.find(box);
                    if(it != precomputedSize.end()){
                        subsize = it->second;
                        box.lastComputedSize = subsize;
                        box.lastPreferedSize = subsize;
                    }else{
                        CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                        
                        CGFloat preferedHeight = flexibleHeight / flexibleCount;
                        subsize = [box preferredSizeConstraintToSize:CGSizeMake(width,(size.height >= MAXFLOAT) ? MAXFLOAT : (NSInteger)preferedHeight)];
                        flexibleHeight -= subsize.height;
                        flexibleCount--;
                    }
                    
                    CGFloat totalWidth = box.margins.left + box.margins.right + subsize.width;
                    if(maxWidth < totalWidth) maxWidth = totalWidth;
                    
                    y += subsize.height;
                }
            }
            
            maxHeight = y + lastBox.margins.bottom;
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
        
        //Compute layout
        CGFloat y = self.frame.origin.y + self.padding.top;
        hash_set<id> appliedMargins;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                //if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
                //else{
                    if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        CGFloat topMargin = 0;
                        if(i > 0){
                            NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1];
                            if(boxBottom && ![boxBottom isKindOfClass:[CKLayoutFlexibleSpace class]]){
                                topMargin = MAX(box.margins.top,boxBottom.margins.bottom);
                            }else if(appliedMargins.find(boxBottom) == appliedMargins.end()){
                                topMargin = box.margins.top;
                            }
                        }else{
                            topMargin = box.margins.top;
                        }
                        y += topMargin;
                    }
                    appliedMargins.insert(box);
                    
                    CGSize subsize = box.lastPreferedSize;
                    
                    CGRect boxframe = CGRectMake(box.margins.left,y,MAX(0,subsize.width),MAX(0,subsize.height));
                    [box setBoxFrameTakingCareOfTransform:boxframe];
                    
                    y += subsize.height;
               // }
            }
        }
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1];
        CGFloat totalHeight = y + (lastBox ? lastBox.margins.bottom : 0) - (self.frame.origin.y);
        
        //Handle Vertical alignment
        CGFloat totalWidth = (size.width - self.padding.left - self.padding.right);
        
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                //if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
               // else{
                    CGFloat offsetX = self.frame.origin.x + self.padding.left;
                    CGFloat offsetY = 0;
                    switch(self.horizontalAlignment){
                        case CKLayoutHorizontalAlignmentLeft:break; //this is already computed
                        case CKLayoutHorizontalAlignmentRight: offsetX += totalWidth - box.frame.size.width; break;
                        case CKLayoutVerticalAlignmentCenter:  offsetX += (totalWidth / 2) - (box.frame.size.width / 2); break;
                    }
                    
                    if(totalHeight < (size.height - self.padding.top - self.padding.bottom)){
                        switch(self.verticalAlignment){
                            case CKLayoutVerticalAlignmentTop: break; //default behaviour
                            case CKLayoutVerticalAlignmentCenter:  offsetY = (size.height - totalHeight) / 2; break;
                            case CKLayoutVerticalAlignmentBottom: offsetY = size.height - totalHeight; break;
                        }
                    }
                    
                    CGRect boxFrame = CGRectIntegral(CGRectMake(box.frame.origin.x + offsetX,box.frame.origin.y + offsetY,box.frame.size.width,box.frame.size.height));
                    [box setBoxFrameTakingCareOfTransform:boxFrame];
                    [box performLayoutWithFrame:box.frame];
                //}
            }
        }
    }
}

@end
