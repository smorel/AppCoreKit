//
//  CKClassExplorer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassExplorer.h"
#import <objc/runtime.h>
#import "NSValueTransformer+Additions.h"
#import "CKStandardContentViewController.h"

NSInteger compareStrings(NSString* obj1, NSString* obj2, void *context)
{
	return [obj1 caseInsensitiveCompare:obj2];
}


__strong NSString* CKClassExplorerFilter = nil;
NSString* CKClassExplorerAdditionalFilter = @"ck";
CKClassExplorerType CKClassExplorerCurrentType = CKClassExplorerTypeClasses;


@interface CKClassExplorer()
@property(nonatomic,retain)CKArrayCollection* classesCollection;
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
    //self.searchEnabled = YES;
    //self.liveSearchDelay = 0.5;
    self.name = @"CKClassExplorer";
	
	/*self.searchScopeDefinition = [NSDictionary dictionaryWithObjectsAndKeys:
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
	self.defaultSearchScope = (CKClassExplorerCurrentType == CKClassExplorerTypeInstances) ? @"Instances" : ((CKClassExplorerAdditionalFilter) == nil ? @"All" : @"CloudKit");*/
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    //self.searchBar.text = CKClassExplorerFilter;
}

- (id)initWithBaseClass:(Class)type{
    if (self = [super init]) {
        [self createClassesCollectionWithBaseClass:type];
    }
	return self;
}

- (id)initWithProtocol:(Protocol*)protocol{
	if (self = [super init]) {
      [self createClassesCollectionWithProtocol:protocol];  
    }
	return self;
}

- (void)createClassesCollectionWithBaseClass:(Class)type{
	self.classesCollection = [[[CKArrayCollection alloc]init]autorelease];
	
	self.className = [type description];
	
	NSMutableArray* ar = [NSMutableArray array];
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 )
	{
        Class * classes = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		for(int i = 0;i<numClasses; ++i){
			Class c = classes[i];
			NSString* className = NSStringFromClass(c);
			if([NSObject isClass:c kindOfClass:type]
			   && ![className hasPrefix:@"_"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    
    [factory registerFactoryForObjectOfClass:[NSString class]  factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        return [CKStandardContentViewController controllerWithTitle:object action:^(CKStandardContentViewController* controller){
            int i =3;
        }];
    }];
    
    
    [factory registerFactoryForObjectOfClass:[NSObject class]  factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        NSString* title = nil;
        CKClassPropertyDescriptor* nameDescriptor = [object propertyDescriptorForKeyPath:@"modelName"];
        if(nameDescriptor != nil && [NSObject isClass:nameDescriptor.type kindOfClass:[NSString class]]){
            title = [object valueForKeyPath:@"modelName"];
        }
        else{
            title = @"Unknown";
        }

        return [CKStandardContentViewController controllerWithTitle:title action:^(CKStandardContentViewController* controller){
            int i =3;
        }];
    }];
	
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:self.classesCollection  factory:factory];
    [self addSection:section animated:NO];
    
	[self didSearch:CKClassExplorerFilter];
}

- (void)createClassesCollectionWithProtocol:(Protocol*)protocol{
	self.classesCollection = [[[CKArrayCollection alloc]init]autorelease];
	
	NSMutableArray* ar = [NSMutableArray array];
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 )
	{
		Class * classes = malloc(sizeof(Class) * numClasses);
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
	
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    
    [factory registerFactoryForObjectOfClass:[NSString class]  factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        return [CKStandardContentViewController controllerWithTitle:object action:^(CKStandardContentViewController* controller){
            int i =3;
        }];
    }];
    
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:self.classesCollection  factory:factory];
    [self addSection:section animated:NO];
	
	[self didSearch:CKClassExplorerFilter];
}

- (void)didSearch:(NSString*)text{
	/*NSString* theFilter = [text retain];
	[CKClassExplorerFilter release];
	CKClassExplorerFilter = theFilter;
	
	CKArrayCollection* collection = _classesCollection;
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
			collection = [[[CKArrayCollection alloc]init]autorelease];
			[collection addObjectsFromArray:filteredObjects];
		}
	}
	else{
		NSString* domain = nil;
		id appDelegate = [[UIApplication sharedApplication]delegate];
		if([appDelegate respondsToSelector:@selector(ckStoreDefaultDomain)]){
			domain = [appDelegate performSelector:@selector(ckStoreDefaultDomain)];
		}
	}
	self.objectController = [CKCollectionController controllerWithCollection:collection];
     */
}

@end
