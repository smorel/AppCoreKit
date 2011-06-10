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


@interface CKClassExplorer()
@property(nonatomic,retain)CKDocumentArray* classesCollection;
- (void)createClassesCollectionWithBaseClass:(Class)type;
@end

@implementation CKClassExplorer
@synthesize classesCollection = _classesCollection;
@synthesize userInfo = _userInfo;

- (void)dealloc{
	[_classesCollection release];
	[_userInfo release];
	[super dealloc];
}

- (id)initWithBaseClass:(Class)type{
	[super init];
	[self createClassesCollectionWithBaseClass:type];
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
			   && ![className hasSuffix:@"_MAZeroingWeakRefSubclass"]){
				[ar addObject:className];
			}
		}
		free(classes);
	}
	
	[_classesCollection addObjectsFromArray: [ar sortedArrayUsingFunction:&compareStrings context:nil] ];
	
	self.objectController = [CKDocumentController controllerWithCollection:_classesCollection];
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
}

@end
