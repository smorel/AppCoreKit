//
//  CKStore.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <stdarg.h>

#import "CKStore.h"
#import "CKCoreDataManager.h"

#import "CKDomain.h"
#import "CKItem.h"
#import "CKAttribute.h"

#import "CKNSString+Additions.h"

static CKCoreDataManager* CKStoreCoreDataManager = nil;
static NSMutableDictionary* CKStoreCache = nil;

@interface CKStore ()

@property (retain, readwrite) CKDomain *domain;

@end

@implementation CKStore

@synthesize domain = _domain;

#pragma mark Shared CKCoreDataManager

+ (CKCoreDataManager *)storeCoreDataManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CloudKit" ofType:@"momd"];
        NSURL *momURL = [NSURL fileURLWithPath:path];
        CKStoreCoreDataManager = [[CKCoreDataManager alloc] initWithModelURL:momURL];
    });
    return CKStoreCoreDataManager;
}

- (NSManagedObjectContext *)context {
    return [[CKStore storeCoreDataManager] objectContext];
}

#pragma mark CKStore Initialization

- (id)initWithDomainName:(NSString *)domainName {
	if (self = [super init]) {
        // FIXME: The CKDomain should be fetched on demand--or replaced by only its name.
        
		// Fetch the domain, creating it if necessary
		BOOL created;
		self.domain = [[self context] fetchObjectForEntityForName:@"CKDomain" 
                                                        predicate:[NSPredicate predicateWithFormat:@"name == %@", domainName] 
                                                 createIfNotFound:YES
                                                       wasCreated:&created];
		if (created) { 
			self.domain.name = domainName; 
		}
	}
	return self;
}

+ (id)storeWithDomainName:(NSString *)domainName {
    @synchronized(self) {
        if (CKStoreCache == nil) {
            CKStoreCache = [[NSMutableDictionary alloc]init];
        }
        
        id store = [CKStoreCache objectForKey:domainName];
        if (store) { return store; }
    }
    
    CKStore *store = [[[CKStore alloc] initWithDomainName:domainName] autorelease];
    [CKStoreCache setObject:store forKey:domainName];
    return store;
}

- (void)dealloc {
    // TODO
    [super dealloc];
}

#pragma mark CKStore Fetch Items

- (NSArray *)fetchItems {
	return [self fetchItemsWithPredicateFormat:nil arguments:nil];
}

- (NSArray  *)fetchItemsWithLimit:(NSUInteger)limit {
	return [self fetchItemsWithPredicateFormat:nil arguments:nil limit:limit];
}

- (NSArray *)fetchItemsWithNames:(NSArray *)names {
	return (names ? [self fetchItemsWithPredicateFormat:@"(name IN %@)" arguments:[NSArray arrayWithObject:names]] : [self fetchItems]);	
}

- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments {
	return [self fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments limit:0];
}

// Generic Fetch

- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments limit:(NSUInteger)limit {	
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];

	/*NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	[predicateArguments addObjectsFromArray:arguments];
		
	NSMutableString *scopedPredicateFormat = [NSMutableString stringWithString:@"(domain == %@)"];
	if (predicateFormat) { [scopedPredicateFormat appendFormat:@" AND (%@)", predicateFormat]; }
	NSPredicate *predicate = [NSPredicate predicateWithFormat:scopedPredicateFormat argumentArray:predicateArguments];
	
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedBy:@"createdAt" limit:limit];*/
	return [self fetchItemsWithFormat:predicateFormat arguments:arguments range:NSMakeRange(0,limit) sortedByKeys:[NSArray arrayWithObject:@"createdAt"]];
}

- (NSArray *)fetchItemsWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys{
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];
	
	NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	if(arguments != nil){
		[predicateArguments addObjectsFromArray:arguments];
	}
	
	NSMutableString *scopedPredicateFormat = [NSMutableString stringWithString:@"(domain == %@)"];
	if (predicateFormat) { [scopedPredicateFormat appendFormat:@" AND (%@)", predicateFormat]; }
	NSPredicate *predicate = [NSPredicate predicateWithFormat:scopedPredicateFormat argumentArray:predicateArguments];
	
	return [[self context] fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedByKeys:keys range:range];
}

- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments {
	return [self fetchAttributesWithFormat:predicateFormat arguments:arguments range:NSMakeRange(0,0) sortedByKeys:[NSArray arrayWithObject:@"createdAt"]];
}

- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys{
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];
	
	NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	if(arguments != nil){
		[predicateArguments addObjectsFromArray:arguments];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArguments];
	return [[self context] fetchObjectsForEntityForName:@"CKAttribute" predicate:predicate sortedByKeys:keys range:range];
}

#pragma mark CKStore Count Items

- (NSUInteger)countItems {
	return [[self context] countObjectsForEntityForName:@"CKItem" 
                                              predicate:[NSPredicate predicateWithFormat:@"(domain == %@)", self.domain]];
}

#pragma mark CKStore Delete Items

- (void)deleteItems:(NSArray *)items {
	[[self context] deleteObjects:items];
}

- (void)deleteItemsWithNames:(NSArray *)names {
	[self deleteItems:[self fetchItemsWithNames:names]];
}

#pragma mark CKStore Insert Attributes

- (NSString *)insertAttributesWithValuesForNames:(NSDictionary *)attributes forItemNamed:(NSString *)itemName {
	BOOL created;
	
	// Generate an item name automatically, if not provided.
	
	NSString *name = itemName ? itemName : [NSString stringWithNewUUID];
	
	// Fetch the item
	
	CKItem *item = [[self context] fetchObjectForEntityForName:@"CKItem" 
                                                     predicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", name, self.domain]
                                              createIfNotFound:YES
                                                    wasCreated:&created];
	if (created) {
		item.name = name;
		item.domain = self.domain;
		[self.domain addItemsObject:item];
	}
	
	// Insert attributes
	[item updateAttributes:attributes];
	return name;
}

#pragma mark CKStore Fetch Attributes

- (NSArray *)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName {
	return [self fetchAttributesWithNames:names forItemNamed:itemName resultType:CKStoreAttributeResultType];
}

- (id)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName resultType:(CKStoreResultType)resultType {
	NSPredicate *predicate;
	
	if (names) {
		predicate = [NSPredicate predicateWithFormat:@"(name IN %@) AND (item.name == %@) AND (item.domain == %@)", names, itemName, self.domain];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"(item.name == %@) AND (item.domain == %@)", itemName, self.domain];
	}
		
	NSArray *attributes = [[self context] fetchObjectsForEntityForName:@"CKAttribute" 
                                                             predicate:predicate 
                                                          sortedByKeys:nil 
                                                                 limit:0];
	
	if (resultType == CKStoreAttributeResultType) {
		return attributes;
	} else {
		return [[NSValueTransformer valueTransformerForName:@"CKDictionaryFromAttributesTransformer"] transformedValue:attributes];
	}
}


@end


@implementation CKStore (CKStorePrivateAddition)
@dynamic domain;

- (CKAttribute*)fetchAttributeWithPredicate:(NSPredicate*)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL*)wasCreated{
	return [[self context] fetchObjectForEntityForName:@"CKAttribute"
                                             predicate:predicate
                                      createIfNotFound:createIfNotFound 
                                            wasCreated:wasCreated];
}

- (CKItem*)fetchItemWithPredicate:(NSPredicate*)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL*)wasCreated{
	return [[self context] fetchObjectForEntityForName:@"CKItem"
                                             predicate:predicate
                                      createIfNotFound:createIfNotFound 
                                            wasCreated:wasCreated];
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName{
	return [[self context] insertNewObjectForEntityForName:entityName];
}

@end