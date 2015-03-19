//
//  NSDateFormatter+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSDateFormatter+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation NSDateFormatter (CKIntrospectionAdditions)

- (void)dateStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"NSDateFormatterStyle",
                                                 NSDateFormatterNoStyle,
                                                 NSDateFormatterShortStyle,
                                                 NSDateFormatterMediumStyle,
                                                 NSDateFormatterLongStyle,
                                                 NSDateFormatterFullStyle);
}

- (void)timeStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"NSDateFormatterStyle",
                                                 NSDateFormatterNoStyle,
                                                 NSDateFormatterShortStyle,
                                                 NSDateFormatterMediumStyle,
                                                 NSDateFormatterLongStyle,
                                                 NSDateFormatterFullStyle);
}


+ (NSArray*)additionalClassPropertyDescriptors{
    NSMutableArray* properties = [NSMutableArray array];
    
    [properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"dateStyle"
                                                                          readOnly:NO]];
    
    [properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"timeStyle"
                                                                          readOnly:NO]];
        
    return properties;
}

@end
