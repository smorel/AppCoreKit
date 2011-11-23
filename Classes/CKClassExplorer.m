//
//  CKClassExplorer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassExplorer.h"
#import <objc/runtime.h>
#import "CKStoreDataSource.h"
#import "CKNSValueTransformer+Additions.h"

NSInteger compareStrings(NSString* obj1, NSString* obj2, void *context)
{
	return [obj1 caseInsensitiveCompare:obj2];
}


NSString* CKClassExplorerFilter = nil;
NSString* CKClassExplorerAdditionalFilter = @"ck";
CKClassExplorerType CKClassExplorerCurrentType = CKClassExplorerTypeClasses;

@interface CKClassExplorer()
@property(nonatomic,retain)CKDocumentArray* classesCollection;
@property(nonatomic,retain)NSString* className;
- (void)createClassesCollectionWithBaseClass:(Class)type;
- (void)createClassesCollectionWithProtocol:(Protocol*)protocol;
@end

@implementation CKClassExplorer
@synthesize classesCollection = _classesCollection;
@synthesize userInfo = _userInfo;
@synthesize className = _className;

- (void)dealloc{
	[_classesCollection release];
	[_userInfo release];
	[_className release];
	[super dealloc];
}

- (void)postInit{
	[super postInit];
	self.searchEnabled = YES;
	self.liveSearchDelay = 0.5;
    self.name = @"CKClassExplorer";
	
	self.searchScopeDefinition = [NSDictionary dictionaryWithObjectsAndKeys:
	    [CKCallback callbackWithBlock:^(id object){
		    CKClassExplorer* explorer = (CKClassExplorer*)object;
		    CKClassExplorerAdditionalFilter = @"ck";
		    CKClassExplorerCurrentType = CKClassExplorerTypeClasses;
		    [explorer didSearch:explorer.searchBar.text];
		    return (id)nil;
	    }],@"CloudKit",
	    [CKCallback callbackWithBlock:^(id object){
		    CKClassExplorer* explorer = (CKClassExplorer*)object;
		    CKClassExplorerAdditionalFilter= nil;
		    CKClassExplorerCurrentType = CKClassExplorerTypeClasses;
		    [explorer didSearch:explorer.searchBar.text];
		    return (id)nil;
	    }],@"All",
		[CKCallback callbackWithBlock:^(id object){
		    CKClassExplorer* explorer = (CKClassExplorer*)object;
		    CKClassExplorerAdditionalFilter= nil;
		    CKClassExplorerCurrentType = CKClassExplorerTypeInstances;
		    [explorer didSearch:explorer.searchBar.text];
		    return (id)nil;
	    }],@"Instances",
	    nil];
	self.defaultSearchScope = (CKClassExplorerCurrentType == CKClassExplorerTypeInstances) ? @"Instances" : ((CKClassExplorerAdditionalFilter) == nil ? @"All" : @"CloudKit");
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
	
	self.className = [type description];
	
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
			   && ![className hasPrefix:@"_"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
	NSMutableArray* mappings = [NSMutableArray array];
	CKItemViewControllerFactoryItem* classCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSString class]];
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
	
	CKItemViewControllerFactoryItem* objectCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSObject class]];
	[objectCellDescriptor setCreateBlock:^(id object){
		//for stylesheet identification
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		controller.name = @"CKClassExplorerCell";
		return (id)nil;
	}];
	[objectCellDescriptor setSetupBlock:^(id object){
		CKTableViewCellController* controller = (CKTableViewCellController*)object;
		CKClassPropertyDescriptor* nameDescriptor = [controller.value propertyDescriptorForKeyPath:@"modelName"];
		if(nameDescriptor != nil && [NSObject isKindOf:nameDescriptor.type parentType:[NSString class]]){
			controller.tableViewCell.textLabel.text = [controller.value valueForKeyPath:@"modelName"];
		}
		else{
			controller.tableViewCell.textLabel.text = @"Unknown";
		}
		return (id)nil;
	}];
	[objectCellDescriptor setFlags:CKItemViewFlagSelectable];
	
	self.controllerFactory = [CKItemViewControllerFactory factoryWithMappings:mappings];
	
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
			   && ![className hasPrefix:@"_"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
	NSMutableArray* mappings = [NSMutableArray array];
	CKItemViewControllerFactoryItem* classCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSString class]];
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
	self.controllerFactory = [CKItemViewControllerFactory factoryWithMappings:mappings];
	
	[self didSearch:CKClassExplorerFilter];
}

+ (CKStoreRequest*)localRequestForClassNamed:(NSString*)className range:(NSRange)range filter:(NSString*)filter domain:(NSString*)domain{
	//TODO : append all the inherited types in the request !
	NSString* predicate = nil;
	if(filter != nil && [filter length] > 0){
		predicate = [NSString stringWithFormat:@"(ANY attributes.name == '@class') AND (ANY attributes.value == '%@')  AND (name beginswith '%@')",className,filter];
	}
	else{
		predicate = [NSString stringWithFormat:@"(ANY attributes.name == '@class') AND (ANY attributes.value == '%@')",className];
	}
	CKStoreRequest* request = [CKStoreRequest requestWithPredicateFormat:predicate
															   arguments:nil 
																   range:range 
																sortKeys:[NSArray arrayWithObject:@"name"] 
																   store:[CKStore storeWithDomainName:domain]];
	return request;
}

- (void)didSearch:(NSString*)text{
	NSString* theFilter = [text retain];
	[CKClassExplorerFilter release];
	CKClassExplorerFilter = theFilter;
	
	CKDocumentArray* collection = _classesCollection;
	if(CKClassExplorerCurrentType == CKClassExplorerTypeClasses){
		if((text != nil && [text length] > 0)
		   ||(CKClassExplorerAdditionalFilter != nil && [CKClassExplorerAdditionalFilter length] > 0 )){
			NSArray* allObjects = [_classesCollection allObjects];
			NSArray* filteredObjects = [allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
				NSString* str = [(NSString*)evaluatedObject lowercaseString];
				BOOL found = YES;
				if(text != nil && [text length] > 0){
					NSString* filter = [text lowercaseString];
					NSRange range = [str rangeOfString:filter];
					found = found  && (range.location != NSNotFound);
				}
				if(CKClassExplorerAdditionalFilter != nil && [CKClassExplorerAdditionalFilter length] > 0){
					NSString* filter = [CKClassExplorerAdditionalFilter lowercaseString];
					found = found  && [str hasPrefix:filter];
				}
				return found;
			}]];
			collection = [[[CKDocumentArray alloc]init]autorelease];
			[collection addObjectsFromArray:filteredObjects];
		}
	}
	else{
		NSString* domain = nil;
		id appDelegate = [[UIApplication sharedApplication]delegate];
		if([appDelegate respondsToSelector:@selector(ckStoreDefaultDomain)]){
			domain = [appDelegate performSelector:@selector(ckStoreDefaultDomain)];
		}
		
		if(domain){
			CKStoreDataSource* source = [CKStoreDataSource synchronousDataSource];
			source.requestBlock = ^(NSRange range){
				return [[self class] localRequestForClassNamed:self.className range:range filter:text domain:domain];
			};
			source.transformBlock = ^(id value){
				return (id) [NSArray objectArrayFromDictionaryArray:value];
			};		
			collection = [[[CKDocumentArray alloc]initWithFeedSource:source]autorelease];
		}
	}
	self.objectController = [CKDocumentCollectionController controllerWithCollection:collection];
}

@end
