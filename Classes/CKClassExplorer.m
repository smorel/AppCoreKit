//
//  CKClassExplorer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassExplorer.h"
#import <objc/runtime.h>

NSInteger compareStrings(NSString* obj1, NSString* obj2, void *context)
{
	return [obj1 caseInsensitiveCompare:obj2];
}


NSString* CKClassExplorerFilter = nil;
NSString* CKClassExplorerAdditionalFilter = @"ck";

@interface CKClassExplorer()
@property(nonatomic,retain)CKDocumentArray* classesCollection;
@property(nonatomic,retain)NSString* additionalFilter;
- (void)createClassesCollectionWithBaseClass:(Class)type;
- (void)createClassesCollectionWithProtocol:(Protocol*)protocol;
@end

@implementation CKClassExplorer
@synthesize classesCollection = _classesCollection;
@synthesize userInfo = _userInfo;
@synthesize additionalFilter = _additionalFilter;

- (void)dealloc{
	[_classesCollection release];
	[_userInfo release];
	[_additionalFilter release];
	[super dealloc];
}

- (void)postInit{
	[super postInit];
	self.searchEnabled = YES;
	self.liveSearchDelay = 0.5;
	self.additionalFilter = CKClassExplorerAdditionalFilter;
	
	self.searchScopeDefinition = [NSDictionary dictionaryWithObjectsAndKeys:
	    [CKCallback callbackWithBlock:^(id object){
		    CKClassExplorer* explorer = (CKClassExplorer*)object;
		    explorer.additionalFilter = @"ck";
		    CKClassExplorerAdditionalFilter= @"ck";
		    [explorer didSearch:explorer.searchBar.text];
		    return (id)nil;
	    }],@"CloudKit",
	    [CKCallback callbackWithBlock:^(id object){
		    CKClassExplorer* explorer = (CKClassExplorer*)object;
		    explorer.additionalFilter = nil;
		    CKClassExplorerAdditionalFilter= nil;
		    [explorer didSearch:explorer.searchBar.text];
		    return (id)nil;
	    }],@"All",
	    nil];
	self.defaultSearchScope = (self.additionalFilter) == nil ? @"All" : @"CloudKit";
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.searchBar.text = CKClassExplorerFilter;
}

- (id)initWithBaseClass:(Class)type{
	[super init];
	[self createClassesCollectionWithBaseClass:type];
	return self;
}

- (id)initWithProtocol:(Protocol*)protocol{
	[super init];
	[self createClassesCollectionWithProtocol:protocol];
	return self;
}

- (void)createClassesCollectionWithBaseClass:(Class)type{
	self.classesCollection = [[[CKDocumentArray alloc]init]autorelease];
	
	NSMutableArray* ar = [NSMutableArray array];
	Class * classes = NULL;
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 )
	{
		classes = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		for(int i = 0;i<numClasses; ++i){
			Class c = classes[i];
			NSString* className = NSStringFromClass(c);
			if([NSObject isKindOf:c parentType:type]
			   && ![className hasSuffix:@"_MAZeroingWeakRefSubclass"]
			   && ![className hasPrefix:@"_"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
	NSMutableArray* mappings = [NSMutableArray array];
	CKObjectViewControllerFactoryItem* classCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSString class]];
	[classCellDescriptor setCreateBlock:^(id object){
		//for stylesheet identification
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		controller.name = @"CKClassExplorerCell";
		return (id)nil;
	}];
	[classCellDescriptor setSetupBlock:^(id object){
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		controller.tableViewCell.textLabel.text = (NSString*)controller.value;
		return (id)nil;
	}];
	[classCellDescriptor setFlags:CKItemViewFlagSelectable];
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	
	[self didSearch:CKClassExplorerFilter];
}

- (void)createClassesCollectionWithProtocol:(Protocol*)protocol{
	self.classesCollection = [[[CKDocumentArray alloc]init]autorelease];
	
	NSMutableArray* ar = [NSMutableArray array];
	Class * classes = NULL;
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 )
	{
		classes = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		for(int i = 0;i<numClasses; ++i){
			Class c = classes[i];
			NSString* className = NSStringFromClass(c);
			if(class_conformsToProtocol(c,protocol)
			   && ![className hasSuffix:@"_MAZeroingWeakRefSubclass"]
			   && ![className hasPrefix:@"_"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
	NSMutableArray* mappings = [NSMutableArray array];
	CKObjectViewControllerFactoryItem* classCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSString class]];
	[classCellDescriptor setCreateBlock:^(id object){
		//for stylesheet identification
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		controller.name = @"CKClassExplorerCell";
		return (id)nil;
	}];
	[classCellDescriptor setSetupBlock:^(id object){
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		controller.tableViewCell.textLabel.text = (NSString*)controller.value;
		return (id)nil;
	}];
	[classCellDescriptor setFlags:CKItemViewFlagSelectable];
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	
	[self didSearch:CKClassExplorerFilter];
}

- (void)didSearch:(NSString*)text{
	NSString* theFilter = [text retain];
	[CKClassExplorerFilter release];
	CKClassExplorerFilter = theFilter;
	
	CKDocumentArray* collection = _classesCollection;
	if((text != nil && [text length] > 0)
	   ||(_additionalFilter != nil && [_additionalFilter length] > 0 )){
		NSArray* allObjects = [_classesCollection allObjects];
		NSArray* filteredObjects = [allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
			NSString* str = [(NSString*)evaluatedObject lowercaseString];
			BOOL found = YES;
			if(text != nil && [text length] > 0){
				NSString* filter = [text lowercaseString];
				NSRange range = [str rangeOfString:filter];
				found = found  && (range.location != NSNotFound);
			}
			if(_additionalFilter != nil && [_additionalFilter length] > 0){
				NSString* filter = [_additionalFilter lowercaseString];
				found = found  && [str hasPrefix:filter];
			}
			return found;
		}]];
		collection = [[[CKDocumentArray alloc]init]autorelease];
		[collection addObjectsFromArray:filteredObjects];
	}
	self.objectController = [CKDocumentController controllerWithCollection:collection];
}

@end
