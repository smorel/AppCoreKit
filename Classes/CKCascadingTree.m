//
//  CKCascadingTree.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKCascadingTree.h"
#import "JSONKit.h"

#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"

//CKCascadingTreeItemFormat

@interface CKCascadingTreeItemFormat : NSObject{
}
@property(nonatomic,retain) NSString* format;
@property(nonatomic,assign) Class objectClass;
@property(nonatomic,retain) NSString* propertyName;
@property(nonatomic,retain) NSMutableArray* properties;

- (id)initFormatWithFormat:(NSString*)format;
- (NSString*)formatForObject:(id)object propertyName:(NSString*)propertyName className:(NSString*)className;
+ (NSString*)normalizeFormat:(NSString*)format;

@end


static NSMutableDictionary* CKCascadingTreeClassNamesCache = nil;

@implementation CKCascadingTreeItemFormat
@synthesize objectClass,properties,format,propertyName;

- (void)dealloc{
	[format release];
	[propertyName release];
	[properties release];
	[super dealloc];
}

+ (NSArray*)parseFormat:(NSString*)format{
	NSMutableArray* components = [NSMutableArray array];
	
	NSRange range1 = [format rangeOfString:@"["];
	if(range1.length > 0){//found "["
		NSString* identifier = [format substringWithRange:NSMakeRange(0,range1.location)];
		[components addObject:[identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		NSRange range2 = [format rangeOfString:@"]"];
		if(range2.length > 0){//found "]"
			NSString* allPropertyValuePairs = [format substringWithRange:NSMakeRange(range1.location +1,range2.location - range1.location - 1)];
			NSArray* propertyValuePairComponents = [allPropertyValuePairs componentsSeparatedByString:@";"];
			for(NSString* propetyValuePair in propertyValuePairComponents){
				NSArray* propertyValueComponents = [propetyValuePair componentsSeparatedByString:@"="];
				NSAssert([propertyValueComponents count] == 2,@"Invalid format for '%@' : invalid property value pair '%@'",format,propetyValuePair);
				
				NSString* propertyName = [propertyValueComponents objectAtIndex:0];
				propertyName = [propertyName stringByReplacingOccurrencesOfString:@"'" withString:@""];
				NSString* propertyValue = [propertyValueComponents objectAtIndex:1];
				propertyValue = [propertyValue stringByReplacingOccurrencesOfString:@"'" withString:@""];
				[components addObject:[propertyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				[components addObject:[propertyValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			}
		}
		else{
			NSLog(@"Invalid format for '%@' : Cannot find end selector character ']'",format);
		}
	}
	else{//no selectors
		[components addObject:[format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	return components;
}

+ (NSString*)formatFromSplittedFormat:(NSArray*)splittedFormat{
	NSAssert([splittedFormat count] >= 1,@"no identifier for format");
	NSMutableString* str = [NSMutableString stringWithCapacity:1024];
	[str appendString:[splittedFormat objectAtIndex:0]];
	
	if([splittedFormat count] > 1){
		[str appendString:@"["];
	}
	
	for(int i=1;i<[splittedFormat count];i += 2){
		NSString* propertyName = [splittedFormat objectAtIndex:i];
		NSString* propertyValue = [splittedFormat objectAtIndex:i+1];
		[str appendFormat:@"%@%@='%@'",(i >= 3) ? @";" : @"" ,propertyName,propertyValue];
	}
	
	if([splittedFormat count] > 1){
		[str appendString:@"]"];
	}
	
	return str;
}

+ (NSString*)normalizeFormat:(NSString*)format{
	NSArray* splittedFormat = [[self class] parseFormat:format];
	return [[self class] formatFromSplittedFormat:splittedFormat];
}

- (id)initFormatWithFormat:(NSString*)theformat{
	[super init];
	self.properties = [NSMutableArray array];
	
	NSArray* splittedFormat = [[self class] parseFormat:theformat];
	self.format = [[self class] formatFromSplittedFormat:splittedFormat];
	
	NSString* identifier = (NSString*)[splittedFormat objectAtIndex:0];
	Class type = NSClassFromString(identifier);
	if(type == nil){
		self.propertyName = identifier;
	}
	else{
		self.objectClass = type;
	}
	
	for(int i=1;i<[splittedFormat count];i += 2){
		NSString* name = [splittedFormat objectAtIndex:i];
		[self.properties addObject:name];
	}
	return self;
}

- (NSString*)formatForObject:(id)object propertyName:(NSString*)thePropertyName className:(NSString*)className{
	NSMutableString* str = [NSMutableString stringWithCapacity:1024];
	if(self.propertyName){
		[str appendString:thePropertyName];
	}
	else{
		//TODO : here verify if we really use inheritance for object ...
		if(CKCascadingTreeClassNamesCache == nil){
			CKCascadingTreeClassNamesCache = [[NSMutableDictionary alloc]init];
		}
		[str appendString:className];
	}
	
	//append subProperties
    if([properties count] > 0){
		[str appendString:@"["];
	}
	
	int i =0;
	for(NSString* subPropertyName in properties){
		CKObjectProperty* property = [CKObjectProperty propertyWithObject:object keyPath:subPropertyName];
		NSString* valueString = [NSValueTransformer transformProperty:property toClass:[NSString class]];
		[str appendFormat:@"%@%@='%@'",(i > 0) ? @";" : @"" ,subPropertyName,valueString];
		++i;
	}
	
	if([properties count] > 0){
		[str appendString:@"]"];
	}
	return str;
}

@end

//Constants

NSString* CKCascadingTreeFormats  = @"CKCascadingTreeFormats";
NSString* CKCascadingTreeParent   = @"CKCascadingTreeParent";
NSString* CKCascadingTreeEmpty    = @"CKCascadingTreeEmpty";
NSString* CKCascadingTreeInherits = @"@inherits";
NSString* CKCascadingTreeImport   = @"@import";

@interface NSObject (CKCascadingTree)
+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords;
@end

@implementation NSObject (CKCascadingTree)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects: CKCascadingTreeFormats,CKCascadingTreeParent,CKCascadingTreeEmpty,CKCascadingTreeInherits,CKCascadingTreeImport,nil]];
}

@end

//NSMutableDictionary (CKCascadingTreePrivate)

@interface NSMutableDictionary (CKCascadingTreePrivate)

- (void)initAfterLoading;
- (void)postInitAfterLoading;
- (void)setFormat:(CKCascadingTreeItemFormat*)format;
- (void)setDictionary:(NSMutableDictionary*)style forKey:(NSString*)key;
- (NSMutableDictionary*)parentDictionary;

@end


@implementation NSMutableDictionary (CKCascadingTreePrivate)

- (void)setFormat:(CKCascadingTreeItemFormat*)format{
    NSMutableDictionary* formats = [self objectForKey:CKCascadingTreeFormats];
	if(!formats){
		formats = [NSMutableDictionary dictionary];
		[self setObject:formats forKey:CKCascadingTreeFormats];
	}
	
	id formatKey = (format.objectClass != nil) ? (id)format.objectClass : (id)format.propertyName;
	NSMutableArray* formatsForClass = [formats objectForKey:formatKey];
	if(!formatsForClass){
		formatsForClass = [NSMutableArray array];
		[formats setObject:formatsForClass forKey:formatKey];
	}
	
	//order format the most specialized at the beginning
	NSInteger propertiesCount = [format.properties count];
	BOOL inserted = NO;
	for(int i=0;i<[formatsForClass count];++i){
		CKCascadingTreeItemFormat* other = [formatsForClass objectAtIndex:i];
		if(propertiesCount > [other.properties count]){
			[formatsForClass insertObject:format atIndex:i];
			inserted = YES;
			break;
		}
	}
	
	if(inserted == NO){
		[formatsForClass addObject:format];
	}
}

- (void)setDictionary:(NSMutableDictionary*)dico forKey:(NSString*)key{
    [self setObject:dico forKey:key];
    
	CKCascadingTreeItemFormat* format = [[[CKCascadingTreeItemFormat alloc]initFormatWithFormat:key]autorelease];
	[self setFormat:format];
}

- (NSMutableDictionary*)findDictionaryInHierarchy:(NSString*)key{
	NSMutableDictionary* dico = self;
	while(dico != nil){
		NSMutableDictionary* foundDico = [dico objectForKey:key];
		if(foundDico && foundDico != self){
			return foundDico;
		}
		dico = [dico parentDictionary];
	}
	return nil;
}

- (void)applyHierarchically:(NSDictionary*)source toDictionary:(NSDictionary*)target forKey:(NSString*)identifier{
	NSMutableDictionary* mutableTarget = [NSMutableDictionary dictionaryWithDictionary:target];
	[self setObject:mutableTarget forKey:identifier];
	
	for(id key in [source allKeys]){
		if([key isEqual:CKCascadingTreeParent] == NO
		   && [key isEqual:CKCascadingTreeEmpty] == NO
		   && [key isEqual:CKCascadingTreeFormats] == NO){
			id sourceObject = [source objectForKey:key];
			if([mutableTarget containsObjectForKey:key] == NO){
				if([sourceObject isKindOfClass:[NSDictionary class]]){
					[mutableTarget setObject:[NSMutableDictionary dictionaryWithDictionary:sourceObject] forKey:key];
				}
				else{
					[mutableTarget setObject:sourceObject forKey:key];
				}
			}
			else if([sourceObject isKindOfClass:[NSMutableDictionary class]]){
				[self applyHierarchically:sourceObject toDictionary:[mutableTarget objectForKey:key] forKey:key];
			}
		}
	}
}

- (void)makeAllInherits{
	NSArray* inheritsArray = [self objectForKey:CKCascadingTreeInherits];
	if(inheritsArray){
		for(NSString* key in inheritsArray){
			NSString* normalizedKey = [CKCascadingTreeItemFormat normalizeFormat:key];
			NSMutableDictionary* inheritedDico = [self findDictionaryInHierarchy:normalizedKey];
			if(inheritedDico != nil){
				//ensure inherits is threated on inheritedStyle
				[inheritedDico makeAllInherits];
				//Apply inheritedStyle to self
				for(NSString* obj in [inheritedDico allKeys]){
					if([obj isEqual:CKCascadingTreeParent] == NO
					   && [obj isEqual:CKCascadingTreeEmpty] == NO
					   && [obj isEqual:CKCascadingTreeFormats] == NO){
						id inheritedObject = [inheritedDico objectForKey:obj];
						if([self containsObjectForKey:obj] == NO){
							if([inheritedObject isKindOfClass:[NSDictionary class]]){
								[self setObject:[NSMutableDictionary dictionaryWithDictionary:inheritedObject] forKey:obj];
							}
							else{
								[self setObject:inheritedObject forKey:obj];
							}
						}
						else if([inheritedObject isKindOfClass:[NSDictionary class]]){
							[self applyHierarchically:inheritedObject toDictionary:[self objectForKey:obj] forKey:obj];
						}
					}
				}
			}
		}
		[self removeObjectForKey:CKCascadingTreeInherits];
	}
}

- (NSArray*)parseFormatGroups:(NSString*)formats{
	NSArray* components = [formats componentsSeparatedByString:@","];
	NSMutableArray* results = [NSMutableArray array];
	for(NSString* format in components){
		NSString* result = [CKCascadingTreeItemFormat normalizeFormat:format];
		[results addObject:result];
	}
	return results;
}

- (NSMutableDictionary*)parentDictionary{
	return [[self objectForKey:CKCascadingTreeParent]nonretainedObjectValue];
}

- (void)initAfterLoading{
    for(id key in [self allKeys]){
		id object = [[self objectForKey:key]retain];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKCascadingTreeFormats] == NO
		   && [key isEqual:CKCascadingTreeParent] == NO
		   && [key isEqual:CKCascadingTreeEmpty] == NO){
			NSArray* fromatGroups = [self parseFormatGroups:key];
			[self removeObjectForKey:key];
			
			for(NSString* format in fromatGroups){
				NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
				[self setObject:dico forKey:format];
				[dico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
				[dico initAfterLoading];
			}
		}
        else if([object isKindOfClass:[NSArray class]]){
            int index = 0;
            for(id subObject in object){
                if([subObject isKindOfClass:[NSDictionary class]]){
                    NSMutableDictionary* dico = subObject;
                    if(![subObject isKindOfClass:[NSMutableDictionary class]]){
                        [subObject retain];
                        [object removeObjectAtIndex:index];
                        dico = [NSMutableDictionary dictionaryWithDictionary:subObject];
                        [object insertObject:dico atIndex:index];
                        [dico initAfterLoading];
                        [subObject release];
                    }
                    [dico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                }
                ++index;
            }
        }
		[object release];
	}
}

- (void)postInitAfterLoading{
    [self makeAllInherits];
	for(id key in [self allKeys]){
		id object = [self objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKCascadingTreeFormats] == NO
		   && [key isEqual:CKCascadingTreeParent] == NO
		   && [key isEqual:CKCascadingTreeEmpty] == NO){
			
			CKCascadingTreeItemFormat* format = [[[CKCascadingTreeItemFormat alloc]initFormatWithFormat:key]autorelease];
			[self setFormat:format];
			
			[object postInitAfterLoading];
			[object setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
		}
        else if([object isKindOfClass:[NSArray class]]){
            for(id subObject in object){
                if([subObject isKindOfClass:[NSDictionary class]]){
                    [subObject postInitAfterLoading];
                }
            }
        }
	}
	
	//set the empty style
	NSMutableDictionary* emptyDico = [NSMutableDictionary dictionary];
	[emptyDico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
	[self setObject:emptyDico forKey:CKCascadingTreeEmpty];
}

@end

//NSDictionary (CKCascadingTree)
@implementation NSDictionary (CKCascadingTree)

- (BOOL)isReservedKeyWord:(NSString*)key{
    NSMutableSet* set = [NSMutableSet set];
    [NSObject updateReservedKeyWords:set];
    return [set containsObject:key];
}

@end

//NSMutableDictionary (CKCascadingTree)

@implementation NSMutableDictionary (CKCascadingTree)

//Search a style responding to the format in the current scope
- (NSMutableDictionary*)_dictionaryForObject:(id)object format:(CKCascadingTreeItemFormat*)format propertyName:(NSString*)propertyName className:(NSString*)className{
	NSString* objectFormatKey = [format formatForObject:object propertyName:propertyName className:className];
	return [self objectForKey:objectFormatKey];
}

//Search a style responding to the formats in the current scope
- (NSMutableDictionary*)_dictionaryForObject:(id)object formats:(NSArray*)formats propertyName:(NSString*)propertyName className:(NSString*)className{
	for(CKCascadingTreeItemFormat* format in formats){
		NSMutableDictionary* dico = [self _dictionaryForObject:object format:format propertyName:propertyName className:className];
		if(dico){
			return dico;
		}
	}
	return nil;
}

//Search a style in the current scope
- (NSMutableDictionary*)_dictionaryForObject:(id)object propertyName:(NSString*)propertyName{
	NSDictionary* allFormats = [self objectForKey:CKCascadingTreeFormats];
	if(allFormats){
		if(propertyName != nil){
			NSArray* propertyformats = [allFormats objectForKey:propertyName];
			if(propertyformats){
				NSMutableDictionary* dico = [self _dictionaryForObject:object formats:propertyformats propertyName:propertyName className:nil];
				if(dico){
					return dico;
				}
			}
		}
		
		Class type = [object class];
		while(type != nil){
			NSString* className = [CKCascadingTreeClassNamesCache objectForKey:type];
			if(className == nil){
				className = [type description];
				[CKCascadingTreeClassNamesCache setObject:className forKey:type];
			}
			
			NSArray* formats = [allFormats objectForKey:type];
			if(formats){
				NSMutableDictionary* dico = [self _dictionaryForObject:object formats:formats propertyName:propertyName  className:className];
				if(dico){
					return dico;
				}
			}
			type = class_getSuperclass(type);
		}
	}	
	return nil;
}

//Search a style in the current scope and its parents
- (NSMutableDictionary*)_dictionaryForObjectWithCascading:(id)object propertyName:(NSString*)propertyName{
	NSMutableDictionary* foundDico = [self _dictionaryForObject:object propertyName:propertyName];
	if(foundDico){
		return foundDico;
	}
	
	//Cascading
	NSMutableDictionary* parentDico = [self parentDictionary];
	if(parentDico){
		NSMutableDictionary* foundDico = [parentDico _dictionaryForObjectWithCascading:object propertyName:propertyName];
		if(foundDico){
			return foundDico;
		}
	}
	return nil;
}	

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName{
	NSMutableDictionary* foundDico = [self _dictionaryForObjectWithCascading:object propertyName:propertyName];
	if(foundDico){
		return foundDico;
	}
	
	id emptyDico = [self objectForKey:CKCascadingTreeEmpty];
	return (emptyDico != nil) ? emptyDico : self;
}


- (NSMutableDictionary*)dictionaryForClass:(Class)c{
    if(CKCascadingTreeClassNamesCache == nil){
        CKCascadingTreeClassNamesCache = [[NSMutableDictionary alloc]init];
    }
    
    Class type = c;
    while(type != nil){
        NSString* className = [CKCascadingTreeClassNamesCache objectForKey:type];
        if(className == nil){
            className = [type description];
            [CKCascadingTreeClassNamesCache setObject:className forKey:type];
        }
        
        id foundDico = [self objectForKey:className];
        if(foundDico){
            return foundDico;
        }
        
        type = class_getSuperclass(type);
    }
    
    NSMutableDictionary* parentDico = [self parentDictionary];
	if(parentDico){
		NSMutableDictionary* foundDico = [parentDico dictionaryForClass:c];
		if(foundDico){
			return foundDico;
		}
	}

    return nil;
}

- (NSMutableDictionary*)dictionaryForKey:(NSString*)key{
    id foundDico = [self objectForKey:key];
    if(foundDico){
        return foundDico;
    }
    
    NSMutableDictionary* parentDico = [self parentDictionary];
	if(parentDico){
		NSMutableDictionary* foundDico = [parentDico dictionaryForKey:key];
		if(foundDico){
			return foundDico;
		}
	}
    
    return nil;
}

- (BOOL)isEmpty{
    NSInteger count = [self count];
	if([self containsObjectForKey:CKCascadingTreeFormats]) --count;
	if([self containsObjectForKey:CKCascadingTreeParent]) --count;
	if([self containsObjectForKey:CKCascadingTreeEmpty]) --count;
	return count == 0;
}

- (BOOL)containsObjectForKey:(NSString*)key{
    id object = [self objectForKey:key];
	return (object != nil);
}

@end

//CKCascadingTree

@interface CKCascadingTree()
@property (nonatomic,retain) NSMutableDictionary* tree;
@property (nonatomic,retain) NSMutableSet* loadedFiles;
- (void)processImportsForDictionary:(NSMutableDictionary*)dictionary withMainExtension:(NSString*)mainExtension;
- (BOOL)importContentOfFile:(NSString*)path;
@end

@implementation CKCascadingTree
@synthesize tree = _tree;
@synthesize loadedFiles = _loadedFiles;

- (void)dealloc{
	[_tree release];
	[_loadedFiles release];
	[super dealloc];
}

- (id)init{
	[super init];
	self.loadedFiles = [NSMutableSet set];
	return self;
}

- (id)initWithContentOfFile:(NSString*)path{
    self = [self init];
    [self loadContentOfFile:path];
    return self;
}

+ (CKCascadingTree*)treeWithContentOfFile:(NSString*)path{
    return [[[CKCascadingTree alloc]initWithContentOfFile:path]autorelease];
}

- (BOOL)loadContentOfFile:(NSString*)path{
	if (_tree == nil){
		self.tree = [NSMutableDictionary dictionary];
	}
	if([self importContentOfFile:path]){
		[_tree initAfterLoading];
		[_tree postInitAfterLoading];return YES;
	}
    return NO;
}

- (BOOL)appendContentOfFile:(NSString*)path{
    return [self importContentOfFile:path];
}

- (BOOL)importContentOfFile:(NSString*)path{
	if([_loadedFiles containsObject:path])
		return NO;
	
    //TODO
    NSString* fileAndExtension = [path lastPathComponent];
    NSRange dotRange = [fileAndExtension rangeOfString:@"."];
    NSString* importFileExtension = (dotRange.location != NSNotFound) ? [fileAndExtension substringFromIndex:dotRange.location+1] : nil;
    
    //Parse file with validation
	NSData* fileData = [NSData dataWithContentsOfFile:path];
	NSError* error = nil;
    id result = [fileData mutableObjectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:&error];
	NSAssert(result != nil,@"invalid format in style file '%@'\nat line : '%@'\nwith error : '%@'",[path lastPathComponent],[[error userInfo]objectForKey:@"JKLineNumberKey"],
             [[error userInfo]objectForKey:@"NSLocalizedDescription"]);
	
    //Post process
    [_loadedFiles addObject:path];
	[self processImportsForDictionary:result withMainExtension:importFileExtension];
	[_tree addEntriesFromDictionary:result];
	
	return YES;
}

- (void)processImportsForDictionary:(NSMutableDictionary*)dictionary withMainExtension:(NSString*)mainExtension{
	NSArray* importArray = [dictionary objectForKey:CKCascadingTreeImport];
	for(NSString* import in importArray){
        //TODO
        NSString* fileAndExtension = [import lastPathComponent];
        NSRange dotRange = [fileAndExtension rangeOfString:@"."];
        NSString* importFileName = (dotRange.location != NSNotFound) ? [fileAndExtension substringWithRange:NSMakeRange(0,dotRange.location)] : fileAndExtension;
        NSString* importFileExtension = (dotRange.location != NSNotFound) ? [fileAndExtension substringFromIndex:dotRange.location+1] : nil;
        
        if(importFileExtension == nil){
            importFileExtension = mainExtension;
        }
        NSString* path = [[NSBundle mainBundle]pathForResource:importFileName ofType:importFileExtension];
        [self importContentOfFile:path];
	}
	[dictionary removeObjectForKey:CKCascadingTreeImport];
	
	for(id key in [dictionary allKeys]){
		id object = [dictionary objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKCascadingTreeFormats] == NO
		   && [key isEqual:CKCascadingTreeParent] == NO
		   && [key isEqual:CKCascadingTreeEmpty] == NO){
			NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
			[self processImportsForDictionary:dico withMainExtension:mainExtension];
		}
	}
}

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName{
	return [_tree dictionaryForObject:object propertyName:propertyName];
}

- (NSMutableDictionary*)dictionaryForKey:(id)key{
    return [_tree objectForKey:key];
}

- (NSArray*)arrayForKey:(id)key{
    return [_tree objectForKey:key];
}

- (NSMutableDictionary*)dictionaryForClass:(Class)c{
    return [_tree dictionaryForClass:c];
}

- (void)addDictionary:(NSMutableDictionary*)dictionary forKey:(id)key{
    id object = [_tree objectForKey:key];
    if(object){
        NSAssert(NO,@"tree already contains an object for key '%@'",key);
    }
    [_tree setObject:dictionary forKey:key];
}

- (void)removeDictionaryForKey:(id)key{
    [_tree removeObjectForKey:key];
}

- (NSString*)description{
	return [_tree description];
}


@end
