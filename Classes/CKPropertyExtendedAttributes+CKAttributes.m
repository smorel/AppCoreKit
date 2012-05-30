//
//  CKPropertyExtendedAttributes+CKAttributes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes+CKAttributes.h"

@implementation CKPropertyExtendedAttributes (CKObject)
@dynamic comparable,serializable,copiable,deepCopy,hashable,creatable,validationPredicate,contentType,contentProtocol,dateFormat,enumDescriptor;

- (void)setComparable:(BOOL)comparable{
    [self.attributes setObject:[NSNumber numberWithBool:comparable] forKey:@"CKPropertyExtendedAttributes_CKObject_comparable"];
}

- (BOOL)comparable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_comparable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setSerializable:(BOOL)serializable{
    [self.attributes setObject:[NSNumber numberWithBool:serializable] forKey:@"CKPropertyExtendedAttributes_CKObject_serializable"];
}

- (BOOL)serializable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_serializable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setCopiable:(BOOL)copiable{
    [self.attributes setObject:[NSNumber numberWithBool:copiable] forKey:@"CKPropertyExtendedAttributes_CKObject_copiable"];
}

- (BOOL)copiable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_copiable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setDeepCopy:(BOOL)deepCopy{
    [self.attributes setObject:[NSNumber numberWithBool:deepCopy] forKey:@"CKPropertyExtendedAttributes_CKObject_deepCopy"];
}

- (BOOL)deepCopy{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_deepCopy"];
    if(value) return [value boolValue];
    return NO;
}

- (void)setHashable:(BOOL)hashable{
    [self.attributes setObject:[NSNumber numberWithBool:hashable] forKey:@"CKPropertyExtendedAttributes_CKObject_hashable"];
}

- (BOOL)hashable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_hashable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setCreatable:(BOOL)creatable{
    [self.attributes setObject:[NSNumber numberWithBool:creatable] forKey:@"CKPropertyExtendedAttributes_CKObject_creatable"];
}

- (BOOL)creatable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_creatable"];
    if(value) return [value boolValue];
    
    //TODO : Return YES if CKCollection !
    return NO;
}

- (void)setValidationPredicate:(NSPredicate *)validationPredicate{
    [self.attributes setObject:validationPredicate forKey:@"CKPropertyExtendedAttributes_CKObject_validationPredicate"];
}

- (NSPredicate*)validationPredicate{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_validationPredicate"];
    return value;
}

-(void)setContentType:(Class)contentType{
    //TODO
}

- (Class)contentType{
    //TODO
    return nil;
}

-(void)setContentProtocol:(Protocol*)protocol{
    //TODO
}

- (Protocol*)contentProtocol{
    //TODO
    return nil;
}

- (void)setDateFormat:(NSString *)dateFormat{
    [self.attributes setObject:dateFormat forKey:@"CKPropertyExtendedAttributes_CKObject_dateFormat"];
}

- (NSString*)dateFormat{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_dateFormat"];
    return value;
}


- (void)setEnumDescriptor:(CKEnumDescriptor *)enumDescriptor{
    [self.attributes setObject:enumDescriptor forKey:@"CKPropertyExtendedAttributes_CKObject_enumDescriptor"];
}

- (CKEnumDescriptor*)enumDescriptor{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKObject_enumDescriptor"];
    return value;
}

@end

@implementation CKPropertyExtendedAttributes (CKPropertyGrid)
@dynamic editable,valuesAndLabels,cellControllerCreationBlock;

- (void)setEditable:(BOOL)editable{
    [self.attributes setObject:[NSNumber numberWithBool:editable] forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_editable"];
}

- (BOOL)editable{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_editable"];
    if(value) return [value boolValue];
    return YES;
}

- (void)setValuesAndLabels:(NSDictionary*)valuesAndLabels{
    [self.attributes setObject:valuesAndLabels forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_valuesAndLabels"];
}

- (NSDictionary*)valuesAndLabels{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_valuesAndLabels"];
    return value;
}

- (void)setCellControllerCreationBlock:(CKCellControllerCreationBlock)cellControllerCreationBlock{
    [self.attributes setObject:[[cellControllerCreationBlock copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_cellControllerCreationBlock"];
}

- (CKCellControllerCreationBlock)cellControllerCreationBlock{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyGrid_cellControllerCreationBlock"];
    return value;
}

@end

@implementation CKPropertyExtendedAttributes (CKNSNumberPropertyCellController)
@dynamic minimumValue,maximumValue;

- (void)setMinimumValue:(NSNumber*)minimumValue{
    [self.attributes setObject:minimumValue forKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_minimumValue"];
}

- (NSNumber*)minimumValue{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_minimumValue"];
    return value;
}

- (void)setMaximumValue:(NSNumber*)maximumValue{
    [self.attributes setObject:maximumValue forKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_maximumValue"];
}

- (NSNumber*)maximumValue{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSNumberPropertyCellController_maximumValue"];
    return value;
}

@end

@implementation CKPropertyExtendedAttributes (CKNSStringPropertyCellController)
@dynamic minimumLength,maximumLength;

- (void)setMinimumLength:(NSInteger)minimumLength{
    [self.attributes setObject:[NSNumber numberWithInt:minimumLength] forKey:@"CKPropertyExtendedAttributes_CKNSStringPropertyCellController_minimumLength"];
}

- (NSInteger)minimumLength{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSStringPropertyCellController_minimumLength"];
    if(value) return [value intValue];
    return -1;
}

- (void)setMaximumLength:(NSInteger)maximumLength{
    [self.attributes setObject:[NSNumber numberWithInt:maximumLength] forKey:@"CKPropertyExtendedAttributes_CKNSStringPropertyCellController_maximumLength"];
}

- (NSInteger)maximumLength{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKNSStringPropertyCellController_maximumLength"];
    if(value) return [value intValue];
    return -1;
}

@end


@implementation CKPropertyExtendedAttributes (CKMultilineNSStringPropertyCellController)
@dynamic multiLineEnabled;

- (void)setMultiLineEnabled:(BOOL)multiLineEnabled{
    [self.attributes setObject:[NSNumber numberWithBool:multiLineEnabled] forKey:@"CKPropertyExtendedAttributes_CKMultilineNSStringPropertyCellController_multiLineEnabled"];
}

- (BOOL)multiLineEnabled{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKMultilineNSStringPropertyCellController_multiLineEnabled"];
    if(value) return [value boolValue];
    return NO;
}

@end


@implementation CKPropertyExtendedAttributes (CKOptionPropertyCellController)
@dynamic multiSelectionEnabled;
@dynamic sortingBlock;
@dynamic presentsOptionsAsPopover;

- (void)setMultiSelectionEnabled:(BOOL)multiSelectionEnabled{
    [self.attributes setObject:[NSNumber numberWithBool:multiSelectionEnabled] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_multiSelectionEnabled"];
}

- (BOOL)multiSelectionEnabled{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_multiSelectionEnabled"];
    if(value) return [value boolValue];
    return NO;
}

- (void)setPresentsOptionsAsPopover:(BOOL)presentsOptionsAsPopover{
    [self.attributes setObject:[NSNumber numberWithBool:presentsOptionsAsPopover] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_presentsOptionsAsPopover"];
}

- (BOOL)presentsOptionsAsPopover{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_presentsOptionsAsPopover"];
    if(value) return [value boolValue];
    return NO;
}

- (void)setSortingBlock:(CKOptionPropertyCellControllerSortingBlock)block{
    [self.attributes setObject:[[block copy] autorelease] forKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_sortingBlock"];
}

- (CKOptionPropertyCellControllerSortingBlock)sortingBlock{
    return [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKOptionPropertyCellController_sortingBlock"];
}

@end