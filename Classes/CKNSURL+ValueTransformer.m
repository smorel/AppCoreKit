//
//  CKNSURL+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSURL+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


@implementation NSURL (CKValueTransformer)

+ (NSURL*)convertFromNSString:(NSString*)str{
	return [NSURL URLWithString:str];
}

+ (NSString*)convertToNSString:(NSURL*)url{
	return [url absoluteString];
}

@end
