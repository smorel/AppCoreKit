//
//  CKCascadingTree.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKCascadingTree.h"
#import "JSONKit.h"

#import "CKProperty.h"
#import "NSValueTransformer+Additions.h"
#import "CKDebug.h"
#import <objc/runtime.h>
#import "CKConfiguration.h"
#import "CKResourceManager.h"
#import "CKVersion.h"

//CKCascadingTreeItemFormat


/**
 */
@interface NSDictionary (CKCascadingTree)
- (BOOL)isReservedKeyWord:(NSString*)key;
@end




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
				CKAssert([propertyValueComponents count] == 2,@"Invalid format for '%@' : invalid property value pair '%@'",format,propetyValuePair);
				
				NSString* propertyName = [propertyValueComponents objectAtIndex:0];
				propertyName = [propertyName stringByReplacingOccurrencesOfString:@"'" withString:@""];
				NSString* propertyValue = [propertyValueComponents objectAtIndex:1];
				propertyValue = [propertyValue stringByReplacingOccurrencesOfString:@"'" withString:@""];
				[components addObject:[propertyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				[components addObject:[propertyValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			}
		}
		else{
			CKDebugLog(@"Invalid format for '%@' : Cannot find end selector character ']'",format);
		}
	}
	else{//no selectors
		[components addObject:[format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	return components;
}

+ (NSString*)formatFromSplittedFormat:(NSArray*)splittedFormat{
	CKAssert([splittedFormat count] >= 1,@"no identifier for format");
	NSMutableString* str = [NSMutableString stringWithString:[splittedFormat objectAtIndex:0]];
	
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
	if (self = [super init]) {
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
		CKProperty* property = [CKProperty weakPropertyWithObject:object keyPath:subPropertyName];
        if([property descriptor]){
            id value = [property value];
            NSString* valueString = value ? [NSValueTransformer transformProperty:property toClass:[NSString class]] : @"null";
            [str appendFormat:@"%@%@='%@'",(i > 0) ? @";" : @"" ,subPropertyName,valueString];
            ++i;
        }
	}
	
	if([properties count] > 0){
		[str appendString:@"]"];
	}
	return str;
}

- (NSString*)description{
    NSMutableString* str = [NSMutableString string];
    [str appendFormat:@"CKCascadingTreeItemFormat <%p> : {\n",self];
    [str appendFormat:@"format : %@\n",self.format];
    [str appendFormat:@"objectClass : %@\n",self.objectClass];
    [str appendFormat:@"propertyName : %@\n",self.propertyName];
    [str appendFormat:@"properties : %@\n",self.properties];
    [str appendString:@"}"];
    return str;
}

@end

//Constants

NSString* const CKCascadingTreePrefix    = @"CKCascadingTree";
NSString* const CKCascadingTreeFormats   = @"CKCascadingTreeFormats";
NSString* const CKCascadingTreeParent    = @"CKCascadingTreeParent";
NSString* const CKCascadingTreeEmpty     = @"CKCascadingTreeEmpty";
NSString* const CKCascadingTreeNode      = @"CKCascadingTreeNode";
NSString* const CKCascadingTreeInherits  = @"@inherits";
NSString* const CKCascadingTreeImport    = @"@import";
NSString* const CKCascadingTreeIPad      = @"@ipad";
NSString* const CKCascadingTreeIPhone    = @"@iphone";
NSString* const CKCascadingTreeIPhone5   = @"@iphone5";
NSString* const CKCascadingTreeOSVersion = @"@ios";

@interface NSObject (CKCascadingTree)
+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords;
@end

@implementation NSObject (CKCascadingTree)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects: CKCascadingTreeFormats,CKCascadingTreeParent,CKCascadingTreeEmpty,CKCascadingTreeInherits,CKCascadingTreeImport,CKCascadingTreeNode,nil]];
}

@end

//NSMutableDictionary (CKCascadingTreePrivate)

@interface NSMutableDictionary (CKCascadingTreePrivate)

- (void)initAfterLoading;
- (void)postInitAfterLoadingForObjectWithKey:(NSString*)objectKey;
- (void)setFormat:(CKCascadingTreeItemFormat*)format;
- (void)setDictionary:(NSMutableDictionary*)style forKey:(NSString*)key;
- (NSMutableDictionary*)parentDictionary;
- (void)makeAllInheritsForObjectWithKey:(NSString*)objectKey;

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

- (id)findObjectInHierarchy:(NSString*)keyPath{
    NSString* normalizedKeyPath = [CKCascadingTreeItemFormat normalizeFormat:keyPath];
    
	NSMutableDictionary* dico = self;
	while(dico != nil){
		id foundObject = [dico valueForKeyPath:keyPath];
		if(foundObject && foundObject != self){
			return foundObject;
		}
		id foundNormalizedObject = [dico valueForKeyPath:normalizedKeyPath];
        if(foundNormalizedObject && foundNormalizedObject != self){
			return foundNormalizedObject;
		}
        
        dico = [dico parentDictionary];
	}
    
	return nil;
}

- (NSMutableDictionary*)applyHierarchically:(NSDictionary*)source toDictionary:(NSDictionary*)target{
	NSMutableDictionary* mutableTarget = target ? [target mutableCopy] : [[NSMutableDictionary alloc]init];
	
	[source enumerateKeysAndObjectsUsingBlock:^(id key, id sourceObject, BOOL *stop) {
        if(![key hasPrefix:CKCascadingTreePrefix] || [key isEqualToString:CKCascadingTreeNode]){
            if([sourceObject isKindOfClass:[NSMutableDictionary class]]){
                NSMutableDictionary* sourceDico = (NSMutableDictionary*)sourceObject;
                [sourceDico makeAllInheritsForObjectWithKey:key];
            }
            
			if([mutableTarget containsObjectForKey:key] == NO){
				if([sourceObject isKindOfClass:[NSDictionary class]]){
					[mutableTarget setObject:[NSMutableDictionary dictionaryWithDictionary:sourceObject] forKey:key];
				}
                else if([sourceObject isKindOfClass:[NSDictionary class]]){
                    CKAssert(NO,@"Should have been read as a mutable dico !");
                }
				else{
					[mutableTarget setObject:sourceObject forKey:key];
				}
			}
			else if([sourceObject isKindOfClass:[NSMutableDictionary class]]){
				NSMutableDictionary* result = [mutableTarget applyHierarchically:sourceObject toDictionary:[mutableTarget objectForKey:key]];
                [mutableTarget setObject:result forKey:key];
			}
		}
    }];
    
    return [mutableTarget autorelease];
}

- (void)makeAllPlatformSpecific{
    if(![self containsObjectForKey:CKCascadingTreeIPad]
       && ![self containsObjectForKey:CKCascadingTreeIPhone]
       && ![self containsObjectForKey:CKCascadingTreeIPhone5])
        return;
    
    BOOL isIphone = [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    if(isIphone){
        [self removeObjectForKey:CKCascadingTreeIPad];
        
        BOOL isIphone5 = [UIScreen mainScreen].scale == 2.f && [[UIScreen mainScreen] bounds].size.height == 568.0f;
        if(isIphone5 && [self containsObjectForKey:CKCascadingTreeIPhone5]){
            [self removeObjectForKey:CKCascadingTreeIPhone];
            NSDictionary* iphoneDico = [self objectForKey:CKCascadingTreeIPhone5];
            [self addEntriesFromDictionary:iphoneDico];
            [self removeObjectForKey:CKCascadingTreeIPhone5];
        }else{
            [self removeObjectForKey:CKCascadingTreeIPhone5];
            NSDictionary* iphoneDico = [self objectForKey:CKCascadingTreeIPhone];
            [self addEntriesFromDictionary:iphoneDico];
            [self removeObjectForKey:CKCascadingTreeIPhone];
        }
    }
    else{
        [self removeObjectForKey:CKCascadingTreeIPhone];
        [self removeObjectForKey:CKCascadingTreeIPhone5];
        NSDictionary* ipadDico = [self objectForKey:CKCascadingTreeIPad];
        [self addEntriesFromDictionary:ipadDico];
        [self removeObjectForKey:CKCascadingTreeIPad];
    }
}

- (void)makeAllOSVersionSpecific{
    CGFloat osVersion = [CKOSVersion() floatValue];
    
    NSArray* keys = [self allKeys];
    for(NSString* key in keys){

        NSString* trimmedKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([trimmedKey hasPrefix:CKCascadingTreeOSVersion]){
            NSArray* components = [trimmedKey componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([components count] != 3){
                NSLog(@"Invalid syntax for os version selector : %@",key);
                [self removeObjectForKey:key];
                continue;
            }
            
            NSString* operatorString = [[components objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* versionString = [[components objectAtIndex:2]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            CGFloat version = [versionString floatValue];
            
            bool keepIt = NO;
            if([operatorString isEqualToString:@"<"]){
                keepIt = (osVersion < version);
            }else if([operatorString isEqualToString:@"<="]){
                keepIt = (osVersion <= version);
            }else if([operatorString isEqualToString:@">"]){
                keepIt = (osVersion > version);
            }else if([operatorString isEqualToString:@">="]){
                keepIt = (osVersion >= version);
            }else if([operatorString isEqualToString:@"=="] || [operatorString isEqualToString:@"="]){
                keepIt = (osVersion == version);
            }else if([operatorString isEqualToString:@"!="]){
                keepIt = (osVersion != version);
            }
            
            if(keepIt){
                NSMutableDictionary* versionDico = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:key]];
                [versionDico makeAllPlatformSpecific];
                
                [self addEntriesFromDictionary:versionDico];
                [self removeObjectForKey:CKCascadingTreeIPad];
            }
            
            [self removeObjectForKey:key];
        }
    }
}

- (NSMutableDictionary*)deepCleanCopy:(NSMutableDictionary*)dico{
    NSMutableDictionary* res = [NSMutableDictionary dictionary];
    for(id key in dico){
        if([key hasPrefix:CKCascadingTreePrefix]){
        }
        else{
            id object = [dico objectForKey:key];
            if([object isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary* copiedDico = [self deepCleanCopy:object];
                [copiedDico setObject:[NSValue valueWithNonretainedObject:res] forKey:CKCascadingTreeParent];
                [res setObject:copiedDico forKey:key];
            }
            else if([object isKindOfClass:[NSArray class]]){
                NSMutableArray* ar = [NSMutableArray array];
                for(id subObject in object){
                    if([subObject isKindOfClass:[NSDictionary class]]){
                        NSMutableDictionary* copiedDico = [self deepCleanCopy:subObject];
                        [copiedDico setObject:[NSValue valueWithNonretainedObject:res] forKey:CKCascadingTreeParent];
                        [ar addObject:copiedDico];
                    }
                    else{
                        [ar addObject:subObject];
                    }
                }
                [res setObject:ar forKey:key];
            }
            else{
                [res setObject:object forKey:key];
            }
        }
    }
    return res;
}

+ (void)getRecursiveInheritanceDependenciesFromDictionary:(NSDictionary*)dico dependencies:(NSMutableArray*)dependencies forObjectWithKey:(NSString*)objectKey{
    if(!dico)
        return;
    
    [dico enumerateKeysAndObjectsUsingBlock:^(id key, id sourceObject, BOOL *stop) {
        if([sourceObject isKindOfClass:[NSDictionary class]]){
            
            NSArray* inheritsArray = [sourceObject objectForKey:CKCascadingTreeInherits];
            for(NSString* dependency in inheritsArray){
                
                
                NSInteger index = [dependencies indexOfObject:dependency];
                if(index != NSNotFound){
                    [dependencies removeObjectAtIndex:index];
                }
                [dependencies insertObject:dependency atIndex:0];
                
                NSMutableDictionary* dependencyDictionary = [(NSMutableDictionary*)dico findObjectInHierarchy:dependency];
                [NSMutableDictionary getRecursiveInheritanceDependenciesFromDictionary:dependencyDictionary dependencies:dependencies forObjectWithKey:dependency];
            }
            [NSMutableDictionary getRecursiveInheritanceDependenciesFromDictionary:sourceObject dependencies:dependencies forObjectWithKey:key];
            
        }else if([sourceObject isKindOfClass:[NSArray class]]){
            for(id object in sourceObject){
                if([object isKindOfClass:[NSDictionary class]]){
                    
                    NSArray* inheritsArray = [object objectForKey:CKCascadingTreeInherits];
                    for(NSString* dependency in inheritsArray){
                        
                        NSInteger index = [dependencies indexOfObject:dependency];
                        if(index != NSNotFound){
                            [dependencies removeObjectAtIndex:index];
                        }
                        [dependencies insertObject:dependency atIndex:0];
                        
                        
                        NSMutableDictionary* dependencyDictionary = [(NSMutableDictionary*)dico findObjectInHierarchy:dependency];
                        [NSMutableDictionary getRecursiveInheritanceDependenciesFromDictionary:dependencyDictionary dependencies:dependencies forObjectWithKey:dependency];
                        
                    }
                    [NSMutableDictionary getRecursiveInheritanceDependenciesFromDictionary:object dependencies:dependencies forObjectWithKey:[NSString stringWithFormat:@"%@ : %@",objectKey,key]];
                }
            }
        }
    }];
}

- (NSArray*)sortedKeysTakingCareOfInheritanceDependenciesForObjectWithKey:(NSString*)key{
    NSMutableArray* recursiveDependencies = [NSMutableArray array];
    [NSMutableDictionary getRecursiveInheritanceDependenciesFromDictionary:self dependencies:recursiveDependencies forObjectWithKey:key];
    
    NSArray* sortedKeys = nil;
    if(recursiveDependencies.count > 0){
        NSArray* allKeys = [self allKeys];
        //sort allkeys to put self in order first and then the rest
        sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger dependencyObj1Index = [recursiveDependencies indexOfObject:obj1];
            NSInteger dependencyObj2Index = [recursiveDependencies indexOfObject:obj2];
            NSInteger indexObj1 = [allKeys indexOfObject:obj1];
            NSInteger indexObj2 = [allKeys indexOfObject:obj2];
            
            if(dependencyObj1Index != NSNotFound && dependencyObj2Index != NSNotFound){
                return [[NSNumber numberWithInteger:dependencyObj1Index]compare:[NSNumber numberWithInteger:dependencyObj2Index]];
            }else if(dependencyObj1Index != NSNotFound && dependencyObj2Index == NSNotFound){
                return NSOrderedAscending;
            }else if(dependencyObj1Index == NSNotFound && dependencyObj2Index != NSNotFound){
                return NSOrderedDescending;
            }
            
            return [[NSNumber numberWithInteger:indexObj1]compare:[NSNumber numberWithInteger:indexObj2]];
        }];
    }else{
        sortedKeys = [self allKeys];
    }
    
    
    return sortedKeys;
}

- (void)makeAllInheritsForObjectWithKey:(NSString*)objectKey{
	NSArray* inheritsArray = [self objectForKey:CKCascadingTreeInherits];
	if(inheritsArray){
		for(NSString* key in inheritsArray){
			NSMutableDictionary* inheritedDico = [self findObjectInHierarchy:key];
            
            if(!inheritedDico){
                NSLog(@"CKCascadingTree Inheritance - Could Not find object with keypath : '%@'",key);
            }
            
            NSMutableDictionary* deepCopy = inheritedDico ? [self deepCleanCopy:inheritedDico] : nil;
            [deepCopy setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
            
			if(deepCopy != nil){
                
                NSArray* sortedKeys = [deepCopy sortedKeysTakingCareOfInheritanceDependenciesForObjectWithKey:objectKey];
                            
				//Apply inheritedStyle to self
				for(NSString* obj in sortedKeys){
					if(![obj hasPrefix:CKCascadingTreePrefix] || [obj isEqualToString:CKCascadingTreeNode]){
                        
						id inheritedObject = [deepCopy objectForKey:obj];
                        if([inheritedObject isKindOfClass:[NSMutableDictionary class]]){
                            [inheritedObject setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                         //   [inheritedObject postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"inherited %@ in %@",obj,objectKey]];
                        }else if([inheritedObject isKindOfClass:[NSArray class]]){
                            NSArray* selfArray = (NSArray*)[self objectForKey:obj];
                            NSArray* inheritedArray = (NSArray*)inheritedObject;
                            
                            BOOL requiersArrayMerge = false;
                            if(   (selfArray && [[selfArray objectAtIndex:0]isKindOfClass:[NSDictionary class]])
                               || (inheritedArray && [[inheritedArray objectAtIndex:0]isKindOfClass:[NSDictionary class]]) ){
                                requiersArrayMerge = YES;
                            }
                            
                            if(requiersArrayMerge){
                                NSMutableArray* result = [NSMutableArray array];
                                
                                //Merge And make inheritance in array objects !
                                for(int i =0; i< MAX(selfArray ? selfArray.count : 0,inheritedArray ? inheritedArray.count : 0); ++i){
                                    NSMutableDictionary* inheritedSubObject = inheritedArray ? (i < inheritedArray.count ? [inheritedArray objectAtIndex:i] : nil) : nil;
                                    NSMutableDictionary* subObject = selfArray ? (i < selfArray.count ? [selfArray objectAtIndex:i] : nil) : nil;
                                    
                                    NSMutableDictionary* deepCopy = inheritedSubObject ? [self deepCleanCopy:inheritedSubObject] : nil;
                                    [deepCopy setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                                    
                                    NSMutableDictionary* deepCopySelf = subObject ? [self deepCleanCopy:subObject] : nil;
                                    [deepCopySelf setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                                    
                                    if(deepCopySelf && deepCopy){
                                        
                                        [deepCopySelf postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"array object %d %@ in %@",i,obj,objectKey]];
                                        [deepCopy postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"inherited array object %d %@ in %@",i,obj,objectKey]];
                                        
                                        NSMutableDictionary* resultObject = [self applyHierarchically:deepCopy toDictionary:deepCopySelf];
                                        [resultObject setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                                        [result addObject:resultObject];
                                        
                                    }else if(deepCopySelf != nil){
                                        [deepCopySelf postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"array object %d %@ in %@",i,obj,objectKey]];
                                        
                                        [result addObject:deepCopySelf];
                                    }else{
                                        [deepCopy postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"inherited array object %d %@ in %@",i,obj,objectKey]];
                                        
                                        [result addObject:deepCopy];
                                    }
                                }
                                
                                inheritedObject = result;
                            }
                        }
                        
                        
                        //ensure inherits is threated on inheritedStyle
                        
                        id result = inheritedObject;
						if([inheritedObject isKindOfClass:[NSDictionary class]]){
                            [inheritedObject postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"inherited %@ in %@",key,objectKey]];
                            NSMutableDictionary* selfObject = [self objectForKey:obj];
                            [selfObject postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"self %@ in %@",key,objectKey]];
							result = [self applyHierarchically:inheritedObject toDictionary:selfObject];
                            [result setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                            [self setObject:result forKey:obj];
						}else if([inheritedObject isKindOfClass:[NSArray class]]){
                            [self setObject:result forKey:obj];
                        }else if(![self containsObjectForKey:obj]){
                            [self setObject:result forKey:obj];
                        }else{
                            //ignore as the key is overloaded here compared to the inherited object
                        }
					}
				}
			}
		}
		[self removeObjectForKey:CKCascadingTreeInherits];
	}
}

- (void)makeAllInjectionsForObjectWithKey:(NSString*)objectKey{
    for(NSString* key in [self allKeys]){
        if([key hasPrefix:@"@"]
           || [key isEqualToString:CKCascadingTreePrefix]
           || [key isEqualToString:CKCascadingTreeFormats]
           || [key isEqualToString:CKCascadingTreeParent]
           || [key isEqualToString:CKCascadingTreeEmpty]
           || [key isEqualToString:CKCascadingTreeNode]
           || [key isEqualToString:CKCascadingTreeInherits]
           || [key isEqualToString:CKCascadingTreeImport]
           || [key isEqualToString:CKCascadingTreeIPad]
           || [key isEqualToString:CKCascadingTreeIPhone]){
            continue;
        }
        
        id object = [self objectForKey:key];
        if([object isKindOfClass:[NSString class]]){
            NSString* injectionPath = (NSString*)object;
            
            id result = [self findObjectInHierarchy:injectionPath];
            if(result){
                if([result isKindOfClass:[NSDictionary class]]){
                    result = [self deepCleanCopy:result];
                    [result setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                    [self setObject:result forKey:key];
                    
                    [self postInitAfterLoadingForObjectWithKey:objectKey];
                }else{
                    [self setObject:result forKey:key];
                }
            }
        }
    }
}

- (NSArray*)parseFormatGroups:(NSString*)formats{
	NSArray* components = [formats componentsSeparatedByString:@","];
	NSMutableArray* results = [NSMutableArray arrayWithCapacity:components.count];
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
    [self makeAllPlatformSpecific];
    [self makeAllOSVersionSpecific];
    
    for(id key in [self allKeys]){
		id object = [[self objectForKey:key]retain];
        
        if([object isKindOfClass:[NSArray class]]){
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
                    }else{
                        [dico initAfterLoading];
                    }
                    [dico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                }
            }
        }
		else if([object isKindOfClass:[NSDictionary class]]
                && (![key hasPrefix:CKCascadingTreePrefix] || [key isEqualToString:CKCascadingTreeNode])){
			NSArray* fromatGroups = [self parseFormatGroups:key];
			[self removeObjectForKey:key];
			
			for(NSString* format in fromatGroups){
				NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
				[self setObject:dico forKey:format];
				[dico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
				[dico initAfterLoading];
			}
		}
		[object release];
	}
}

- (void)postInitAfterLoadingForObjectWithKey:(NSString*)objectKey{
    //Setup parent for hierarchical searchs
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if([object isKindOfClass:[NSArray class]]){
            for(id subObject in object){
                if([subObject isKindOfClass:[NSDictionary class]]){
                    [subObject setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                }
            }
        }
        else if([object isKindOfClass:[NSDictionary class]]
                && ![key hasPrefix:CKCascadingTreePrefix]){
			[object setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
		}
    }];
    
    [self makeAllInheritsForObjectWithKey:objectKey];
    [self makeAllInjectionsForObjectWithKey:objectKey];
    
    NSArray* sortedKeys = [self sortedKeysTakingCareOfInheritanceDependenciesForObjectWithKey:objectKey];
    
    //Init formats
	for(id key in sortedKeys){
		id object = [self objectForKey:key];
        if([object isKindOfClass:[NSArray class]]){
            int i =0;
            for(id subObject in object){
                if([subObject isKindOfClass:[NSDictionary class]]){
                    [subObject postInitAfterLoadingForObjectWithKey:[NSString stringWithFormat:@"array object %d %@ in %@",i,key,objectKey]];
                    
                    [subObject setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
                    [subObject setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"address <%p>",subObject],@"address",nil] forKey:CKCascadingTreeNode];
                }
                ++i;
            }
        }
		else if([object isKindOfClass:[NSDictionary class]]
                && ![key hasPrefix:CKCascadingTreePrefix]){
			CKCascadingTreeItemFormat* format = [[[CKCascadingTreeItemFormat alloc]initFormatWithFormat:key]autorelease];
			[self setFormat:format];
			
            [object postInitAfterLoadingForObjectWithKey:key];
            object = [self objectForKey:key];//in case it has been muted in postInitAfterLoadingForObjectWithKey
			[object setObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
            [object setObject:[NSDictionary dictionaryWithObjectsAndKeys:key,@"name",[NSString stringWithFormat:@"address <%p>",object],@"address",nil] forKey:CKCascadingTreeNode];
		}
	}
	
	//set the empty style
	NSMutableDictionary* emptyDico = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithNonretainedObject:self] forKey:CKCascadingTreeParent];
	[self setObject:emptyDico forKey:CKCascadingTreeEmpty];
}

- (void)validation{
    /*    for(id key in [self allKeys]){
     id object = [self objectForKey:key];
     if([object isKindOfClass:[NSDictionary class]]
     && [key isEqual:CKCascadingTreeFormats] == NO
     && [key isEqual:CKCascadingTreeParent] == NO
     && [key isEqual:CKCascadingTreeEmpty] == NO
     && [key isEqual:CKCascadingTreeNode] == NO){
     id parent = [[object objectForKey:CKCascadingTreeParent]nonretainedObjectValue];
     CKAssert(parent == self,@"Invalid parent !");
     
     [object validation];
     }
     else if([object isKindOfClass:[NSArray class]]){
     for(id subObject in object){
     if([subObject isKindOfClass:[NSDictionary class]]){
     id parent = [[subObject objectForKey:CKCascadingTreeParent]nonretainedObjectValue];
     CKAssert(parent == self,@"Invalid parent !");
     
     [subObject validation];
     }
     }
     }
     }
     */
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
				[CKCascadingTreeClassNamesCache setObject:className forKey:[[type copy] autorelease]];
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
	if(parentDico && parentDico != self){
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
            [CKCascadingTreeClassNamesCache setObject:className forKey:[[type copy] autorelease]];
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
	if([self containsObjectForKey:CKCascadingTreeNode]) --count;
	return count == 0;
}

- (BOOL)containsObjectForKey:(NSString*)key{
    id object = [self objectForKey:key];
	return (object != nil);
}

- (NSString*)path{
    NSMutableString* fullPath = [NSMutableString string];
    NSMutableDictionary* currentDico = self;
    while(currentDico){
        NSMutableDictionary* node = [currentDico objectForKey:CKCascadingTreeNode];
        if(node){
            NSString* nodeName = [node objectForKey:@"name"];
            if([fullPath length] > 0){
                nodeName = [NSString stringWithFormat:@"%@/",nodeName];
            }
            [fullPath insertString:nodeName atIndex:0];
        }
        NSMutableDictionary* newdico = [[currentDico objectForKey:CKCascadingTreeParent]nonretainedObjectValue];
        currentDico = (newdico == currentDico) ? nil : newdico;
    }
    return fullPath;
}

@end

//CKCascadingTree

@interface CKCascadingTree()
@property (nonatomic,retain,readwrite) NSMutableDictionary* tree;
@property (nonatomic,retain) NSMutableSet* loadedFiles;
- (void)processImportsForDictionary:(NSMutableDictionary*)dictionary withMainExtension:(NSString*)mainExtension;
- (BOOL)importContentOfFile:(NSString*)path;
@end

@implementation CKCascadingTree{
	NSMutableDictionary* _tree;
	NSMutableSet* _loadedFiles;
}

@synthesize tree = _tree;
@synthesize loadedFiles = _loadedFiles;

- (void)dealloc{
	[_tree release];
	[_loadedFiles release];
	[super dealloc];
}

- (id)init{
	if (self = [super init]) {
        self.loadedFiles = [NSMutableSet set];
    }
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
		[_tree postInitAfterLoadingForObjectWithKey:@"ROOT"];
#ifdef DEBUG
        [_tree validation];
#endif
        return YES;
	}
    return NO;
}

- (BOOL)appendContentOfFile:(NSString*)path{
    return [self importContentOfFile:path];
}

- (void)reloadAfterFileUpdate{
    [CKResourceManager removeObserver:self];
    
    NSSet *toLoadFiles = _loadedFiles.copy;
    [_loadedFiles removeAllObjects];
    [_tree removeAllObjects];
    for (NSString * path in toLoadFiles) {
        [self loadContentOfFile:path];
    }
    [toLoadFiles release];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:CKCascadingTreeFilesDidUpdateNotification object:self];
}

- (BOOL)importContentOfFile:(NSString*)path{
    if(path == nil || [path isKindOfClass:[NSNull class]] || [_loadedFiles containsObject:path])
		return NO;
    
    __unsafe_unretained CKCascadingTree* bself = self;
    [CKResourceManager addObserverForPath:path object:self usingBlock:^(id observer, NSString *newpath) {
        [bself.loadedFiles removeObject:path];
        [bself.loadedFiles addObject:newpath];
        
        [bself reloadAfterFileUpdate];
    }];
	
    NSString* fileAndExtension = [path lastPathComponent];
    NSRange dotRange = [fileAndExtension rangeOfString:@"."];
    NSString* importFileExtension = (dotRange.location != NSNotFound) ? [fileAndExtension substringFromIndex:dotRange.location+1] : nil;
    
    //Parse file with validation
	NSData* fileData = [NSData dataWithContentsOfFile:path];
	NSError* error = nil;
    id result = [fileData mutableObjectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:&error];
    
    if (error){
        CKDebugLog(@"**** Parsing error : invalid format in style file '%@' at line : '%@' with error : '%@'",[path lastPathComponent],[[error userInfo]objectForKey:@"JKLineNumberKey"],
              [[error userInfo]objectForKey:@"NSLocalizedDescription"]);
    }
	
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
        NSString* path = [CKResourceManager pathForResource:importFileName ofType:importFileExtension];
        //CKDebugLog(@"processImportsForDictionary %@ with path %@",importFileName,path);
        [self importContentOfFile:path];
	}
	[dictionary removeObjectForKey:CKCascadingTreeImport];
	
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKCascadingTreeFormats] == NO
		   && [key isEqual:CKCascadingTreeParent] == NO
		   && [key isEqual:CKCascadingTreeEmpty] == NO){
			NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
			[self processImportsForDictionary:dico withMainExtension:mainExtension];
		}
    }];
}

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName{
	return [_tree dictionaryForObject:object propertyName:propertyName];
}

- (NSMutableDictionary*)dictionaryForKey:(id)key{
    return [_tree objectForKey:key];
}

- (NSMutableDictionary*)dictionaryForClass:(Class)c{
    return [_tree dictionaryForClass:c];
}

- (void)addDictionary:(NSMutableDictionary*)dictionary forKey:(id)key{
    id object = [_tree objectForKey:key];
    if(object){
        CKAssert(NO,@"tree already contains an object for key '%@'",key);
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
