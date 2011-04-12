//
//  CKFeedCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-12.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectCarouselViewController.h"
#import <CloudKit/CKFeedSource.h>


@interface CKFeedCarouselViewController : CKObjectCarouselViewController {
	CKFeedSource* _feedSource;
}
@property (nonatomic, retain) CKFeedSource *feedSource;

- (id)initWithFeedSource:(CKFeedSource*)source mappings:(NSDictionary*)mappings styles:(NSDictionary*)styles;
- (void)setFeedSource:(CKFeedSource*)source mappings:(NSDictionary*)mappings styles:(NSDictionary*)styles;

@end
