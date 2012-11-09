//
//  MKMapView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "MKMapView+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import <MapKit/MKTypes.h>


@implementation MKMapView (CKIntrospectionAdditions)

- (void)annotationsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.contentProtocol = @protocol(MKAnnotation);
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)insertAnnotationsObjects:(NSArray *)annotations atIndexes:(NSIndexSet*)indexes{
	[self addAnnotations:annotations];
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeAnnotationsObjectsAtIndexes:(NSIndexSet*)indexes{
	NSArray* annotations = [self.subviews objectsAtIndexes:indexes];
	[self removeAnnotations:annotations];
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeAllAnnotationsObjects{
	[self removeAnnotations:self.annotations];
}

- (void)mapTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"MKMapType",
                                                   MKMapTypeStandard,
                                                   MKMapTypeSatellite,
                                                   MKMapTypeHybrid);
}

@end
