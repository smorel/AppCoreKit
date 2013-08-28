//
//  CKFoundation.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//


//Dependencies
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>
//libstdc++, libz, crypto, JSONKit



#import "CKConfiguration.h"
#import "CKDebug.h"
#import "CKWeakRef.h"
#import "CKCallback.h"
#import "CKVersion.h"

//Object Extension
#import "NSObject+Singleton.h"
#import "NSObject+Validation.h"

//Runtime
#import "CKRuntime.h"
#import "NSObject+Runtime.h"
#import "CKClassPropertyDescriptor.h"
#import "CKProperty.h"
#import "CKPropertyExtendedAttributes.h"

//Conversion
#import "NSValueTransformer+Additions.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"
#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "UIFont+ValueTransformer.h"

//Cascading Tree
#import "CKCascadingTree.h"

//Type Ahead
#import "CKTypeAhead.h"
#import "CKTypeAhead+Generator.h"

//Object Graph
#import "CKObjectGraph.h"

//Document
#import "CKObject.h"
#import "CKDocument.h"
#import "CKFeedSource.h"
#import "CKUserDefaults.h"
#import "CKCollection.h"
#import "CKArrayProxyCollection.h"
#import "CKArrayCollection.h"
#import "CKFilteredCollection.h"
#import "CKAggregateCollection.h"

//Localization
#import "CKLocalization.h"
#import "CKLocalizationManager.h"
#import "CKLocalizedString.h"

//Helpers
#import "CKUnit.h"
#import "UIImage+Transformations.h"
#import "NSArray+Additions.h"
#import "NSData+Base64.h"
#import "NSData+Compression.h"
#import "NSData+Matching.h"
#import "NSData+SHA1.h"
#import "NSDate+Calculations.h"
#import "NSDate+Conversions.h"
#import "NSObject+Invocation.h"
#import "NSObject+JSON.h"
#import "NSObject+Notifications.h"
#import "NSSet+Additions.h"
#import "NSString+Formating.h"
#import "NSString+Parsing.h"
#import "NSString+URIQuery.h"
#import "NSString+Validations.h"
#import "NSString+Additions.h"
#import "NSError+Additions.h"
#import "CoreGraphics+Additions.h"
#import "NSTimer+BlockBaseInterface.h"
#import "UIView+Name.h"
#import "UIView+AutoresizingMasks.h"


//ResourceManager
#import "CKResourceManager.h"
#import "CKResourceManager+UIUpdate.h"
