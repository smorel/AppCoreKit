//
//  CKItem.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKItem.h"
#import "CKAttribute.h"
#import "CKAttributesDictionary.h"
#import "CKStore.h"
#import "CKDomain.h"
#import "CKItemAttributeReference.h"

@implementation CKItem

@dynamic name;
@dynamic createdAt;
@dynamic domain;
@dynamic attributes;
@dynamic refAttributes;
@dynamic references;

@end

@implementation CKItem (CKItemsRepresentation)

- (NSDictionary *)propertyListRepresentation {
	return [[[CKAttributesDictionary alloc] initWithItem:self] autorelease];
}

- (NSDictionary *)attributesDictionary {
	return [self propertyListRepresentation];
}

@end


@implementation CKItem (CKItemModification)

- (void)updateAttributes:(NSDictionary*)attributes{
	for (id key in [attributes allKeys]) {
		NSAssert([key isKindOfClass:[NSString class]], @"Attribute key must be of class NSString");
		id value = [attributes objectForKey:key];
		if(value != nil){
			if([value isKindOfClass:[NSString class]]){
				[self updateAttributeNamed:(NSString*)key value:(NSString*)value];
			}
			else if([value isKindOfClass:[NSArray class]]){
				[self updateAttributeNamed:(NSString*)key items:(NSArray*)value];
			}
		}
	}
}

- (void)updateAttributeNamed:(NSString*)name value:(NSString*)value{
	CKStore* store = [CKStore storeWithDomainName:self.domain.name];
	BOOL created = NO;
	
	CKAttribute *attribute = [store fetchAttributeWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (item == %@)", name, self] 
											   createIfNotFound:YES wasCreated:&created];

	attribute.name = name;
	attribute.value = value;	
	if (created) {
		[self addAttributesObject:attribute];
	}
}

- (void)updateAttributeNamed:(NSString*)name items:(NSArray*)items{
	CKStore* store = [CKStore storeWithDomainName:self.domain.name];
	BOOL created = NO;
	
	CKAttribute *attribute = [store fetchAttributeWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (item == %@)", name, self] 
											   createIfNotFound:YES wasCreated:&created];
	
	attribute.name = name;
	[attribute removeItemReferences:attribute.itemReferences];
	for(CKItem* item in items){
		CKItemAttributeReference* reference = [store insertNewObjectForEntityForName:@"CKItemAttributeReference"];
		reference.item = item;
		[attribute addItemReferencesObject:reference];
	}
	if (created) {
		[self addAttributesObject:attribute];
	}
}

- (CKAttribute*)attributeNamed:(NSString*)name createIfNotFound:(BOOL)createIfNotFound{
	CKStore* store = [CKStore storeWithDomainName:self.domain.name];
	BOOL created = NO;
	CKAttribute *attribute = [store fetchAttributeWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (item == %@)", name, self] 
											   createIfNotFound:createIfNotFound wasCreated:&created];
	if (created) {
		attribute.name = name;
		[self addAttributesObject:attribute];
	}
	return attribute;
}

@end