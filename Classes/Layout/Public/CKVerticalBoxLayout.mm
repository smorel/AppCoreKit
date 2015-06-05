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


@implementation CKVerticalBoxLayout

+ (void)load{
    [CKCascadingTree registerAlias:[[self class]description] forKey:@"VBox"];
    [CKCascadingTree registerAlias:[[self class]description] forKey:@"Vertical"];
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
    freeSpace = size.height;
    
    hash_set<id> appliedMargins;
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){ ++numberOfFlexibleSpaces; }
            else{
                //Computing free space taking care of size constraints on boxes
                if(box.maximumSize.height == box.minimumSize.height){ //fixed size
                    freeSpace -= box.maximumSize.height;
                    
                    CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                    CGSize size = [box preferredSizeConstraintToSize:CGSizeMake(width,box.minimumSize.height)];
                    computedSizePerBoxes[box] = size;
                }else{
                    numberOfFlexibleBoxes++;
                }
                
                //Computing free space taking care of margins on boxes
                CGFloat topMargin = 0;
                if(i > 0){
                    NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
                    if(boxBottom && ![boxBottom isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        topMargin = MAX(box.margins.top,boxBottom.margins.bottom);
                    }else if(appliedMargins.find(boxBottom) == appliedMargins.end()){
                        topMargin = box.margins.top;
                    }
                }else{
                    topMargin = box.margins.top;
                }
                appliedMargins.insert(box);
                
                freeSpace -= topMargin;
            }
        }
    }
    
    NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
    if(lastBox){
        freeSpace -= lastBox.margins.bottom;
    }
}


- (void)computeFreeSpacePerBoxWithSize:(CGSize)size
                  computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                flexibleHeightPerBoxes:(hash_map<id, CGFloat> &)flexibleHeightPerBoxes
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
                    if(box.maximumSize.height == box.minimumSize.height){
                        CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                        CGSize constrainedSize = [box preferredSizeConstraintToSize:CGSizeMake(width,box.minimumSize.height)];
                        computedSizePerBoxes[box] = CGSizeMake(constrainedSize.width,box.minimumSize.height);
                    }else{
                        CGFloat preferedHeight = MAX(0,(freeSpace / numberOfFlexibleBoxes)) ;
                        if(preferedHeight == 0){
                            numberOfFlexibleBoxes--;
                            flexibleHeightPerBoxes[box] = 0;
                            
                        }else if(box.minimumHeight > 0 && preferedHeight < box.minimumHeight){
                            preferedHeight = box.minimumHeight;
                            freeSpace -= preferedHeight;
                            numberOfFlexibleBoxes--;
                            flexibleHeightPerBoxes[box] = preferedHeight;
                        }
                        else if (box.maximumHeight > 0 && preferedHeight > box.maximumHeight){
                            preferedHeight = box.maximumHeight;
                            freeSpace -= preferedHeight;
                            numberOfFlexibleBoxes--;
                            flexibleHeightPerBoxes[box] = preferedHeight;
                        }else{
                            CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                            CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(width,size.height)];
                            if(preferedSize.height < preferedHeight){
                                preferedHeight = preferedSize.height;
                                freeSpace -= preferedHeight;
                                numberOfFlexibleBoxes--;
                                flexibleHeightPerBoxes[box] = preferedHeight;
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
             flexibleHeightPerBoxes:(hash_map<id, CGFloat> &)flexibleHeightPerBoxes
                          freeSpace:(CGFloat&)freeSpace
              numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
             numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){ }
            else{
                if(computedSizePerBoxes.find(box) == computedSizePerBoxes.end()){
                    CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                    
                    CGFloat preferedHeight = 0;
                    if(flexibleHeightPerBoxes.find(box) == flexibleHeightPerBoxes.end()){
                        
                        preferedHeight = MAX(0,(freeSpace / numberOfFlexibleBoxes));
                        --numberOfFlexibleBoxes;
                    }else{
                        preferedHeight = flexibleHeightPerBoxes[box];
                    }
                    
                    CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(width,preferedHeight)];
                    computedSizePerBoxes[box] = preferedSize;
                    
                    if(flexibleHeightPerBoxes.find(box) == flexibleHeightPerBoxes.end()){
                        flexibleHeightPerBoxes[box] = preferedSize.height;
                        freeSpace -= preferedSize.height;
                    }
                }
            }
        }
    }
}

- (void)computeSizeForFlexibleSpacesWithSize:(CGSize)size
                        computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
                      flexibleHeightPerBoxes:(hash_map<id, CGFloat> &)flexibleHeightPerBoxes
                                   freeSpace:(CGFloat&)freeSpace
                       numberOfFlexibleBoxes:(NSInteger&)numberOfFlexibleBoxes
                      numberOfFlexibleSpaces:(NSInteger&)numberOfFlexibleSpaces{
    
    BOOL bypass = (size.height >= MAXFLOAT);
    
    for(int i =0;i < [self.layoutBoxes count]; ++i){
        NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
        if(!box.hidden){
            if([box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                CGFloat width = MIN(size.width - box.margins.left - box.margins.right,box.maximumSize.width);
                
                CGFloat preferedHeight = 0;
                if(!bypass){
                    preferedHeight = MAX(0,(freeSpace / numberOfFlexibleSpaces) );
                }
                --numberOfFlexibleSpaces;
                
                CGSize preferedSize = [box preferredSizeConstraintToSize:CGSizeMake(width,preferedHeight)];
                computedSizePerBoxes[box] = preferedSize;
                
                if(flexibleHeightPerBoxes.find(box) == flexibleHeightPerBoxes.end()){
                    flexibleHeightPerBoxes[box] = preferedSize.height;
                    freeSpace -= preferedSize.height;
                }
            }
        }
    }
}


- (CGSize)computeMaximumSizeWithSize:(CGSize)size
                computedSizePerBoxes:(hash_map<id, CGSize> &)computedSizePerBoxes
              flexibleHeightPerBoxes:(hash_map<id, CGFloat> &)flexibleHeightPerBoxes
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
            if(size.width > width && size.width < MAXFLOAT) { width = size.width; }
            
            height += size.height;
            
            if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                CGFloat topMargin = 0;
                if(i > 0){
                    NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
                    if(boxBottom && ![boxBottom isKindOfClass:[CKLayoutFlexibleSpace class]]){
                        topMargin = MAX(box.margins.top,boxBottom.margins.bottom);
                    }else if(appliedMargins.find(boxBottom) == appliedMargins.end()){
                        topMargin = box.margins.top;
                    }
                }else{
                    topMargin = box.margins.top;
                }
                height += topMargin;
            }
        }
    }
    
    NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
    if(lastBox){
        height += lastBox.margins.bottom;
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
    
    BOOL includesFlexispaces = (size.height < MAXFLOAT);
    
    hash_map<id, CGSize> computedSizePerBoxes;
    
    CGFloat freeSpace = 0;
    NSInteger numberOfFlexibleBoxes = 0;
    NSInteger numberOfFlexibleSpaces = 0;
    hash_map<id, CGFloat> flexibleHeightPerBoxes;
    
    if([self.layoutBoxes count] > 0){
        
        //1. computes free space + fixes sized boxes
        [self computeFreeSpaceWithSize:size computedSizePerBoxes:computedSizePerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //2. compute free space per box taking care of min/max size
        
        [self computeFreeSpacePerBoxWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleHeightPerBoxes:flexibleHeightPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //3. compute size for boxes using their own free space
        [self computeSizeForBoxesWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleHeightPerBoxes:flexibleHeightPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
        //4. compute flexi space sizes
        [self computeSizeForFlexibleSpacesWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleHeightPerBoxes:flexibleHeightPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
        
    }
    
    CGSize maxSize = [self computeMaximumSizeWithSize:size computedSizePerBoxes:computedSizePerBoxes flexibleHeightPerBoxes:flexibleHeightPerBoxes freeSpace:freeSpace numberOfFlexibleBoxes:numberOfFlexibleBoxes numberOfFlexibleSpaces:numberOfFlexibleSpaces];
    
    if(self.flexibleWidth && constraintSize.width < MAXFLOAT){
        maxSize.width = constraintSize.width - (self.padding.left + self.padding.right);
    }
    
    if(self.flexibleHeight && constraintSize.height < MAXFLOAT){
        maxSize.height = constraintSize.height - (self.padding.bottom + self.padding.top);
    }
    
    CGSize ret = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(MIN(maxSize.width,size.width),MIN(maxSize.height,size.height)) forBox:self];
    self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(ret.width + self.padding.left + self.padding.right,
                                                                                  ret.height + self.padding.bottom + self.padding.top)
                                                                forBox:self];
    
    
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
        CGFloat y = self.frame.origin.y + self.padding.top;
        hash_set<id> appliedMargins;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                if(![box isKindOfClass:[CKLayoutFlexibleSpace class]]){
                    CGFloat topMargin = 0;
                    if(i > 0){
                        NSObject<CKLayoutBoxProtocol>* boxBottom = [self previousVisibleBoxFromIndex:i-1 includingFexiSpace:NO];
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
                
                CGRect boxframe = CGRectMake(box.margins.left,y,MAX(0,MIN(size.width,subsize.width)),MAX(0,MIN(size.height,subsize.height)));
                framePerBox[box] = boxframe;
                
                y += subsize.height;
            }
        }
        
        NSObject<CKLayoutBoxProtocol>* lastBox = [self previousVisibleBoxFromIndex:[self.layoutBoxes count] - 1 includingFexiSpace:NO];
        CGFloat totalHeight = y + (lastBox ? lastBox.margins.bottom : 0) - (self.frame.origin.y);
        
        //Handle Vertical alignment
        CGFloat totalWidth = (size.width - self.padding.left - self.padding.right);
        
        CKLayoutHorizontalAlignment hAlign = size.width >= MAXFLOAT ? CKLayoutHorizontalAlignmentLeft : self.horizontalAlignment;
        CKLayoutVerticalAlignment vAlign = size.height >= MAXFLOAT ? CKLayoutVerticalAlignmentTop : self.horizontalAlignment;
        for(int i =0;i < [self.layoutBoxes count]; ++i){
            NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
            if(!box.hidden){
                
                hash_map<id, CGRect>::iterator it = framePerBox.find(box);
                CGRect boxFrame = it->second;
                
                    CGFloat offsetX = self.frame.origin.x + self.padding.left;
                    CGFloat offsetY = 0;
                    switch(hAlign){
                        case CKLayoutHorizontalAlignmentLeft:break; //this is already computed
                        case CKLayoutHorizontalAlignmentRight: offsetX += totalWidth - boxFrame.size.width; break;
                        case CKLayoutVerticalAlignmentCenter:  offsetX += (totalWidth / 2) - (boxFrame.size.width / 2); break;
                    }
                    
                    if(totalHeight < (size.height - self.padding.top - self.padding.bottom)){
                        switch(vAlign){
                            case CKLayoutVerticalAlignmentTop: break; //default behaviour
                            case CKLayoutVerticalAlignmentCenter:  offsetY = (size.height - totalHeight) / 2; break;
                            case CKLayoutVerticalAlignmentBottom: offsetY = size.height - totalHeight; break;
                        }
                    }
                    
                    CGRect newboxFrame = CGRectIntegral(CGRectMake(boxFrame.origin.x + offsetX,boxFrame.origin.y + offsetY,boxFrame.size.width,boxFrame.size.height));
                    [box setBoxFrameTakingCareOfTransform:newboxFrame];
                    [box performLayoutWithFrame:newboxFrame];
            }
        }
        
        CGRect f = self.frame;
        if(size.width >= MAXFLOAT){ f.size.width = totalWidth; }
        if(size.height >= MAXFLOAT){ f.size.height = totalHeight; }
        [self setBoxFrameTakingCareOfTransform:f];
    }
}

@end



@implementation CKVerticalBoxLayout(CKLayout_Deprecated)

- (void)setSizeToFitLayoutBoxes:(BOOL)sizeToFitLayoutBoxes{
    self.flexibleSize = !sizeToFitLayoutBoxes;
}

- (BOOL)sizeToFitLayoutBoxes{
    return !self.flexibleSize;
}

@end
