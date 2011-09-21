//
//  CKDocumentCollectionViewCellController+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-27.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollectionViewCellController+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKLocalization.h"

NSString* CKStyleNoItemsMessage = @"noItemsMessage";
NSString* CKStyleOneItemMessage = @"oneItemMessage";
NSString* CKStyleManyItemsMessage = @"manyItemsMessage";
NSString* CKStyleIndicatorStyle = @"indicatorStyle";

@implementation NSMutableDictionary (CKDocumentCollectionViewCellControllerStyle)

- (NSString*)noItemsMessage{
	return [self stringForKey:CKStyleNoItemsMessage];
}

- (NSString*)oneItemMessage{
	return [self stringForKey:CKStyleOneItemMessage];
}

- (NSString*)manyItemsMessage{
	return [self stringForKey:CKStyleManyItemsMessage];
}

- (UIActivityIndicatorViewStyle)indicatorStyle{
	return (UIActivityIndicatorViewStyle)[self enumValueForKey:CKStyleIndicatorStyle 
												withEnumDescriptor:CKEnumDefinition(@"UIActivityIndicatorViewStyle",
                                                                                UIActivityIndicatorViewStyleWhiteLarge,
																				UIActivityIndicatorViewStyleWhite,
																				UIActivityIndicatorViewStyleGray																				
																				)];
}

@end
