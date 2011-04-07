//
//  CKObjectCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCarouselView.h"
#import "CKObjectController.h"


@interface CKObjectCarouselViewController : UIViewController<CKCarouselViewDataSource,CKCarouselViewDelegate,CKObjectControllerDelegate> {
	CKCarouselView* _carouselView;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end
