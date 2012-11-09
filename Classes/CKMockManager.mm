//
//  CKMockManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKMockManager.h"
#import "CKObject.h"
#import "CKRuntime.h"
#import "NSValueTransformer+Additions.h"

static CKMockManager* CKMockManagerDefault = nil;

@implementation CKMockManager

+ (CKMockManager*)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKMockManagerDefault = [[CKMockManager alloc]init];
    });
	return CKMockManagerDefault;
}

- (void)loadContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"mock"];
	[self loadContentOfFile:path];
}

- (BOOL)importContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"mock"];
	return [self appendContentOfFile:path];
}

@end


@interface CKObject(CKMockObject)
@end

@implementation CKObject(CKMockObject)

- (void)swizzle_CKObject_postInit{
    [self swizzle_CKObject_postInit];
    
    NSDictionary* dico = [[CKMockManager defaultManager]dictionaryForClass:[self class]];
    if(dico){
        [NSValueTransformer transform:dico toObject:self];
    }
}

@end

bool swizzle_CKObject(){
#ifdef DEBUG
    CKSwizzleSelector([CKObject class],@selector(postInit),@selector(swizzle_CKObject_postInit));
#endif
    return 1;
}

static bool bo_swizzle_CKObject = swizzle_CKObject();