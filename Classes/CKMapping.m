//
//  NFBDataSourceMapper.m
//  NFB
//
//  Created by Sebastien Morel on 11-02-24.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMapping.h"
#import "CKNSString+Parsing.h"
#import "RegexKitLite.h"
#import "CKDebug.h"


@implementation CKMapping
@synthesize key;
@synthesize mapperBlock;
@synthesize policy;

- (void)dealloc{
	self.key = nil;
	self.mapperBlock = nil;
	[super dealloc];
}

@end

@implementation NSObject (CKMapping)

- (id)initWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error{
	[self init];
	[self mapWithDictionary:sourceDictionary withMappings:mappings error:error];
	return self;
}

- (void)mapWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error{
	if(![sourceDictionary isKindOfClass:[NSDictionary class]]){
		//TODO : fill error
		CKDebugLog(@"source for mapping is not a dictionary but a %@ when mapping on object %@",sourceDictionary,self);
		return;
	}
	
	[mappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
		NSAssert([obj isKindOfClass:[CKMapping class]],@"The mapper object is not a CKMapping");
		NSAssert([key isKindOfClass:[NSString class]],@"The mapper key is not a string");
		
		CKMapping* mappingObject = (CKMapping*)obj;
		id sourceObject = [sourceDictionary objectForKey:mappingObject.key];
		if(sourceObject == nil){
			//TODO : fill error
			CKDebugLog(@"Could not find %@ key in source\n",mappingObject.key);
			if(mappingObject.policy == CKMappingPolicyRequired){
				NSAssert(NO,@"Field %@ not found in dataSource for object %@",mappingObject.key,self);
			}
		}
		else{
			mappingObject.mapperBlock(sourceObject,self,key,error);
		}
	}];
}

@end


@implementation NSMutableDictionary (CKMapping)

- (void)mapKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo withBlock:(CKMappingBlock)block{
	CKMapping* mapperObject = [[[CKMapping alloc]init]autorelease];
	mapperObject.key = keyPath;
	mapperObject.mapperBlock = block;
	mapperObject.policy = bo ? CKMappingPolicyRequired : CKMappingPolicyOptional;
	[self setObject:mapperObject forKey:destination];
}

- (void)mapURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSURL* url = [NSURL URLWithString:[sourceObject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[object setValue:url forKeyPath:keyPath];
	}];
}

- (void)mapHttpURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSURL* url = [NSURL URLWithString:[sourceObject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if([[url scheme] isMatchedByRegex:@"^(http|https)$"]){
			[object setValue:url forKeyPath:keyPath];
		}
		else{
			CKDebugLog(@"%@ is not an httpUrl from %@ to %@",url,keyPath,destination);
			//TODO : fill error
		}
	}];
}

- (void)mapStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSString* str = sourceObject;
		[object setValue:str forKeyPath:keyPath];
	}];
}

- (void)mapStringWithoutHTMLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSString* str = [sourceObject stringByDeletingHTMLTags];
		[object setValue:str forKeyPath:keyPath];
	}];
}

- (void)mapTrimmedStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSString* str = [sourceObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[object setValue:str forKeyPath:keyPath];
	}];
}

- (void)mapIntForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo{
	[self mapKeyPath:keyPath toKeyPath:destination required:bo withBlock:^(id sourceObject,id object,NSString* keyPath,NSError** error){
		NSInteger i = [sourceObject intValue];
		[object setValue:[NSNumber numberWithInt:i] forKeyPath:keyPath];
	}];
}

@end