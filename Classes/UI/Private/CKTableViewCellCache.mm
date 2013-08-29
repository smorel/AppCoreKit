//
//  CKTableViewCellCache.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellCache.h"
#include <ext/hash_map>

using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash< std::string >
    {
        size_t operator()( const std::string& x ) const{
            return hash< const char* >()( x.c_str() );
        }
    };
}

typedef hash_map<std::string, UIView* > CKTableViewCellCacheMap;
static CKTableViewCellCacheMap kCache;

 
@implementation CKTableViewCellCache

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [self clearCache];
    [super dealloc];
}

- (id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)clearCache{
    for(CKTableViewCellCacheMap::iterator it = kCache.begin(); it != kCache.end(); ++it){
        [it->second release];
    }
    kCache.clear();
}

- (UIView*)reusableViewWithIdentifier:(NSString*)identifier{
    CKTableViewCellCacheMap::iterator itFind = kCache.find([identifier UTF8String]);
    if(itFind != kCache.end()){
        return itFind->second;
    }
    return nil;
}

- (void)setReusableView:(UIView*)view forIdentifier:(NSString*)identifier{
    CKTableViewCellCacheMap::iterator itFind = kCache.find([identifier UTF8String]);
    if(itFind != kCache.end()){
        [itFind->second release];
    }
    kCache[[identifier UTF8String]] = [view retain];
}

@end
