//
//  CKArrayProxyCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayProxyCollection.h"
#import "CKDebug.h"


@interface CKCollection()
@property (nonatomic,assign,readwrite) NSInteger count;
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end

@implementation CKArrayProxyCollection{
	CKProperty* _property;
}

@synthesize property = _property;

- (void)dealloc{
    [_property release];
    _property = nil;
    [super dealloc];
}

+ (CKArrayProxyCollection*)collectionWithArrayProperty:(CKProperty*)property{
	return [[[CKArrayProxyCollection alloc]initWithArrayProperty:property]autorelease];
}

- (id)initWithArrayProperty:(CKProperty*)theProperty{
	if (self = [super init]) {
      	CKClassPropertyDescriptor* desc = [theProperty descriptor];
        CKAssert([NSObject isClass:desc.type kindOfClass:[NSArray class]] || [[theProperty value]isKindOfClass:[NSArray class]],@"invalid property");
        self.property = theProperty;
    }
	return self;
}


- (NSArray*)allObjects{
	return [NSArray arrayWithArray:[_property value]];
}

- (NSInteger) count{
	return [[_property value] count];
}

- (id)objectAtIndex:(NSInteger)index{
	return [[_property value] objectAtIndex:index];
}

- (void)insertObjects:(NSArray *)theObjects atIndexes:(NSIndexSet *)indexes{
	if([theObjects count] <= 0)
		return;
	
    [_property insertObjects:theObjects atIndexes:indexes];
	self.count = [[_property value] count];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.addObjectsBlock){
        self.addObjectsBlock(theObjects,indexes); 
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
	NSArray* toRemove = [[_property value] objectsAtIndexes:indexSet];
	
	[_property removeObjectsAtIndexes:indexSet];
	self.count = [[_property value] count];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.removeObjectsBlock){
        self.removeObjectsBlock(toRemove,indexSet); 
    }
}

- (void)removeAllObjects{
    if(self.count == 0)
        return;
    
	[_property removeAllObjects];
	self.count = [[_property value] count];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.clearBlock){
        self.clearBlock(); 
    }
}

- (BOOL)containsObject:(id)object{
	return [[_property value] containsObject:object];
}

- (void)addObserver:(id)object{
    if([_property.keyPath isKindOfClass:[NSString class]]){
        [_property.object addObserver:object forKeyPath:_property.keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    else{
        CKDebugLog(@"could not observe non string keypath for array property : %@",_property);
    }
}

- (void)removeObserver:(id)object{
    if([_property.keyPath isKindOfClass:[NSString class]]){
        [_property.object removeObserver:object forKeyPath:_property.keyPath];
    }
    else{
        CKDebugLog(@"could not observe non string keypath for array property : %@",_property);
    }
}

- (NSArray*)objectsMatchingPredicate:(NSPredicate*)predicate{
	return [[_property value] filteredArrayUsingPredicate:predicate];
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	id object = [[[_property value] objectAtIndex:index]retain];
	[[_property value] removeObjectAtIndex:index];
	[[_property value] insertObject:other atIndex:index];
	self.count = [[_property value] count];	
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.replaceObjectBlock){
        self.replaceObjectBlock(other,object,index); 
    }
    [object release];
}

@end
