//
//  CKMKMapView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMKMapView+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"

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
