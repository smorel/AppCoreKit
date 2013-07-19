//
//  CKColorPalette.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-18.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKColorPalette.h"

@interface CKCascadingTree()
@property (nonatomic,retain,readwrite) NSMutableDictionary* tree;
@property (nonatomic,retain) NSMutableSet* loadedFiles;
@end

@interface CKColorPalette()
@property(nonatomic,retain) NSMutableDictionary* colorPalettes;
@end

@implementation CKColorPalette

+ (id)newSharedInstance{
    CKColorPalette* palette = [[[CKColorPalette alloc]init]autorelease];
    [palette reload];
    
    return palette;
}

- (void)reloadAfterFileUpdate{
    //Do Nothing as it is managed by observing all the .colors files
}
                       
- (void)reload{
    NSLog(@"reloading color palettes");
    
    NSArray* colorFilePaths = [CKResourceManager pathsForResourcesWithExtension:@"colors"];
    [CKResourceManager removeObserver:self];
    
    [self.loadedFiles removeAllObjects];
    [self.tree removeAllObjects];

    for(NSString* path in colorFilePaths){
        [self loadContentOfFile:path];
    }
    
    [self processColors];
    
    __unsafe_unretained CKColorPalette* bself = self;
    [CKResourceManager addObserverForResourcesWithExtension:@"colors" object:self usingBlock:^(id observer, NSArray *paths) {
        [bself reload];
    }];
}

+ (NSDictionary*)colorPaletteWithKey:(NSString*)key{
    return [[[CKColorPalette sharedInstance]colorPalettes] objectForKey:key];
}

/** PaletteKey.ColorKey
 */
+ (UIColor*)colorWithKeyPath:(NSString*)keyPath{
    NSArray* components = [keyPath componentsSeparatedByString:@"."];
    if([components count] != 2)
        return nil;
    
    NSDictionary* palette = [self colorPaletteWithKey:[components objectAtIndex:0]];
    return [palette objectForKey:[components objectAtIndex:1]];
}


- (void)processColors{
    self.colorPalettes = [NSMutableDictionary dictionary];
    
    for(NSString* key in [self.tree allKeys]){
        NSDictionary* rawColors = [self.tree objectForKey:key];
        if(![rawColors isKindOfClass:[NSDictionary class]]){
            NSLog(@"Color palette '%@' should be a dictionary",key);
            continue;
        }
        
        NSMutableDictionary* colors = [NSMutableDictionary dictionary];
        for(NSString* colorKey in [rawColors allKeys]){
            id value = [rawColors objectForKey:colorKey];
            UIColor* theColor = [NSValueTransformer transform:value toClass:[UIColor class]];
            if(theColor){
                [colors setObject:theColor forKey:colorKey];
            }
        }
        
        [self.colorPalettes setObject:colors forKey:key];
    }
}

@end
