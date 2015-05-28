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
- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index includingFexiSpace:(BOOL)includingFexiSpace;

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
    self.flexibleSize = NO;
    self.verticalAlignment = CKLayoutVerticalAlignmentCenter;
    self.horizontalAlignment = CKLayoutHorizontalAlignmentCenter;
    return self;
}


- (void)computeFreeSpaceWithSize:(CGSize)size
            computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                       freeSpace:(CGFloat&)freeSpace
           numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
          numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    freeSpace = size.width;
    
    hash_set<id> appliedMargins;
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){ ++numberOfFlexibleSpaces; }
            else{
                //Computing free space taking care of size constraints on boxes
                if(box.maximumSize.width == box.minimumSize.width){ //fixed size
                    freeSpace -= box.maximumSize.width;
                    
                    CGFloat height = MIN(box.maximumSize.height,size.height - box.margins.top - box.margins.bottom);
                    CGSize size = [box preferredSizeConstraintToSize:CGSizeMake(box.minimumSize.width,height)];
                    computedSizePerBoxes[box] = size;
                }else{
                    numberOfFlexibleBoxes++;
                }
                
                //Computing free space taking care of margins on boxes
                CGFloat leftMargin = 0;
                if(i > 0){
                    NSObject<CKLayoutBoxProtocol>* boxLeft = [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
                    if(boxLeft && ![boxLeft isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        leftMargin = MAX(box.margins.left,boxLeft.margins.right);
                    }else if(appliedMargins.find(boxLeft) == appliedMargins.end()){
                        leftMargin = box.margins.left;
                    }
                }else{
                    leftMargin = box.margins.left;
                }
                appliedMargins.insert(box);
                
                freeSpace -= leftMargin;
            }
        }
    }
    
    NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
    if(lastBox){
        freeSpace -= lastBox.margins.right;
    }
}


- (void)computeFreeSpacePerBoxWithSize:(CGSize)size
                  computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                  flexibleWithPerBoxes:(hash_map<id, CGFloat> &)flexibleWithPerBoxes
                             freeSpace:(CGFloat&)freeSpace
                 numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
                numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){ }
            else{
                if(computedSizePerBoxes.find(box) == computedSizePerBoxes.end()){
                    
                    CGSize subsize = CGSizeMake(0,0);
                    if(box.maximumSize.width == box.minimumSize.width){
                        CGFloat height = MIN(box.maximumSize.width,size.height - box.margins.top - box.margins.bottom);
                        CGSize constrainedSize = [box preferredSizeConstraintToSize:CGSizeMake(box.minimumSize.width,height)];
                        computedSizePerBoxes[box] = CGSizeMake(box.minimumSize.width,constrainedSize.height);
                    }else{
                        CGFloat preferedWidth = MAX(0,(freeSpace / numberOfFlexibleBoxes)) ;
                        if(preferedWidth == 0){
                            numberOfFlexibleBoxes--;
                            flexibleWithPerBoxes[box] = 0;
                        }else if(box.minimumWidth > 0 && preferedWidth < box.minimumWidth){
                            preferedWidth = box.minimumWidth;
                            freeSpace -= preferedWidth;
                            numberOfFlexibleBoxes--;
                            flexibleWithPerBoxes[box] = preferedWidth;
                        }
                        else if (box.maximumWidth > 0 && preferedWidth > box.maximumWidth){
                            preferedWidth = box.maximumWidth;
                            freeSpace -= preferedWidth;
                            numberOfFlexibleBoxes--;
                            flexibleWithPerBoxes[box] = preferedWidth;
                        }else{
                            CGFloat height = MIN(box.maximumSize.width,size.height - box.margins.top - box.margins.bottom);
                            CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(/*preferedWidth*/size.width,height)];
                            if(preferedSize.width < preferedWidth){
                                preferedWidth = preferedSize.width;
                                freeSpace -= preferedWidth;
                                numberOfFlexibleBoxes--;
                                flexibleWithPerBoxes[box] = preferedWidth;
                                computedSizePerBoxes[box] = preferedSize;
                            }
                        }
                    }
                }
            }
        }
    }
}


- (void)computeSizeForBoxesWithSize:(CGSize)size
               computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
               flexibleWithPerBoxes:(hash_map<id, CGFloat> &)flexibleWithPerBoxes
                          freeSpace:(CGFloat&)freeSpace
              numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
             numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){ }
            else{
                if(computedSizePerBoxes.find(box) == computedSizePerBoxes.end()){
                    CGFloat height = MIN(box.maximumSize.width,size.height - box.margins.top - box.margins.bottom);
                    
                    CGFloat preferedWidth = 0;
                    if(flexibleWithPerBoxes.find(box) == flexibleWithPerBoxes.end()){
                        preferedWidth = MAX(0,(freeSpace / numberOfFlexibleBoxes));
                        --numberOfFlexibleBoxes;
                    }else{
                        preferedWidth = flexibleWithPerBoxes[box];
                    }
                    
                    CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(preferedWidth,height)];
                    computedSizePerBoxes[box] = preferedSize;
                    
                    if(flexibleWithPerBoxes.find(box) == flexibleWithPerBoxes.end()){
                        flexibleWithPerBoxes[box] = preferedSize.width;
                        freeSpace -= preferedSize.width;
                    }
                }
            }
        }
    }
}

- (void)computeSizeForFlexibleSpacesWithSize:(CGSize)size
                        computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                        flexibleWithPerBoxes:(hash_map<id, CGFloat> &)flexibleWithPerBoxes
                                   freeSpace:(CGFloat&)freeSpace
                       numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
                      numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                CGFloat height = MIN(box.maximumSize.width,size.height - box.margins.top - box.margins.bottom);
                
                CGFloat preferedWidth = 0;
                preferedWidth = MAX(0,(freeSpace / numberOfFlexibleSpaces) );
                --numberOfFlexibleSpaces;
                
                CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(preferedWidth,height)];
                computedSizePerBoxes[box] = preferedSize;
                
                if(flexibleWithPerBoxes.find(box) == flexibleWithPerBoxes.end()){
                    flexibleWithPerBoxes[box] = preferedSize.width;
                    freeSpace -= preferedSize.width;
                }
            }
        }
    }
}


- (CGSize)computeMaximumSizeWithSize:(CGSize)size
                computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                flexibleWithPerBoxes:(hash_map<id, CGFloat> &)flexibleWithPerBoxes
                           freeSpace:(CGFloat&)freeSpace
               numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
              numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    hash_set<id> appliedMargins;
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            CGSize size = computedSizePerBoxes[box];
            if(size.height > height && size.height < MAXFLOAT) { height = size.height; }
            
            width += size.width;
            
            if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                CGFloat leftMargin = 0;
                if(i > 0){
                    NSObject<CKLayoutBoxProtocol>* boxLeft= [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
                    if(boxLeft && ![boxLeft isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        leftMargin = MAX(box.margins.left,boxLeft.margins.right);
                    }else if(appliedMargins.find(boxLeft) == appliedMargins.end()){
                        leftMargin = box.margins.left;
                    }
                }else{
                    leftMargin = box.margins.left;
                }
                width += leftMargin;
            }
        }
    }
    
    NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
    if(lastBox){
        width += lastBox.margins.right;
    }
    
    return CGSizeMake(width,height);
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)constraintSize{
    if([self.layoutBoxes count] <= 0 && !self.flexibleSize)
        return CGSizeMake(0,0);
    
    CGSize size = [CKLayoutBox preferredSizeConstraintToSize:constraintSize forBox:self];
    size = CGSizeMake(size.width - self.padding.left - self.padding.right,size.height - self.padding.top - self.padding.bottom);
    
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    BOOL includesFlexispaces = (size.width < MAXFLOAT);
    
    hash_map<id, CGSize> computedSizePerBoxes;
    
    CGFloat freeSpace = 0;
    NSInteger numberOfFlexibleBoxes = 0;
    NSInteger numberOfFlexibleSpaces = 0;
    hash_map<id, CGFloat> flexibleWithPerBoxes;
    
    if([self.layoutBoxes count] > 0){
        
        //1. computes free space + fixes sized boxes
        [self computeFreeSpaceWithSize:size computedSizePerBoxes:computedSizePerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //2. compute free space per box taking care of min/max size
        
        [self computeFreeSpacePerBoxWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleWithPerBoxes:flexibleWithPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //3. compute size for boxes using their own free space
        [self computeSizeForBoxesWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleWithPerBoxes:flexibleWithPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //4. compute flexi space sizes
        if(includesFlexispaces){
            [self computeSizeForFlexibleSpacesWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleWithPerBoxes:flexibleWithPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        }
        
    }
    
    if(!self.flexibleSize){
        CGSize maxSize = [self computeMaximumSizeWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleWithPerBoxes:flexibleWithPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        CGSize ret = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(MIN(maxSize.width,size.width),MIN(maxSize.height,size.height)) forBox:self];
        self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(ret.width + self.padding.left + self.padding.right,
                                                                                      ret.height + self.padding.bottom + self.padding.top)
                                                                    forBox:self];
        
    }else{
        self.lastPreferedSize = constraintSize;
    }
    
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize size = theframe.size;
    [self setBoxFrameTakingCareOfTransform:theframe];
    
    // CGSize size = [self preferredSizeConstraintToSize:theframe.size];
    // [self setBoxFrameTakingCareOfTransform:CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height)];
    
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
                            NSObject<CKLayoutBoxProtocol>* boxLeft = [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
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
                    
                    CGRect boxframe = CGRectMake(x,box.margins.top,MAX(0,MIN(size.width,subsize.width)),MAX(0,MIN(size.height,subsize.height)));
                    framePerBox[box] = boxframe;
                    //[box setBoxFrameTakingCareOfTransform:CGRectIntegral(boxframe)];
                    
                    x += subsize.width;
               // }
            }
        }
        
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
        CGFloat totalWidth = x + (lastBox ? lastBox.margins.right : 0) -  self.frame.origin.x;
        
        //Handle Horizontal alignment
        CGFloat totalHeight = (size.height - self.padding.top - self.padding.bottom);
        
        
        CKLayoutHorizontalAlignment hAlign = size.width >= MAXFLOAT ? CKLayoutHorizontalAlignmentLeft : self.horizontalAlignment;
        CKLayoutVerticalAlignment vAlign = size.height >= MAXFLOAT ? CKLayoutVerticalAlignmentTop : self.horizontalAlignment;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
              //  if([box isKindOfClass:[CKLayoutBox class]] && ![box isKindOfClass:[CKLayoutFlexibleSpace class]] && [[box layoutBoxes]count] <= 0){}
              //  else{
                
                hash_map<id, CGRect>::iterator it = framePerBox.find(box);
                CGRect boxFrame = it->second;
                    
                    CGFloat offsetX = 0;
                    CGFloat offsetY = self.frame.origin.y + self.padding.top;
                    switch(vAlign){
                        case CKLayoutVerticalAlignmentTop:break; //this is already computed
                        case CKLayoutVerticalAlignmentBottom: offsetY += totalHeight - boxFrame.size.height; break; //this is already computed
                        case CKLayoutVerticalAlignmentCenter: offsetY += (totalHeight  / 2) - (boxFrame.size.height / 2); break; //this is already computed
                    }
                    
                    
                    if(totalWidth < (size.width - self.padding.left - self.padding.right)){
                        switch(hAlign){
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
        
        CGRect f = self.frame;
        if(size.width >= MAXFLOAT){ f.size.width = totalWidth; }
        if(size.height >= MAXFLOAT){ f.size.height = totalHeight; }
        [self setBoxFrameTakingCareOfTransform:f];
    }
}

@end


@implementation CKHorizontalBoxLayout(CKLayout_Deprecated)

- (void)setSizeToFitLayoutBoxes:(BOOL)sizeToFitLayoutBoxes{
    self.flexibleSize = !sizeToFitLayoutBoxes;
}

- (BOOL)sizeToFitLayoutBoxes{
    return !self.flexibleSize;
}

@end
