//
//  CKCreditsFooterView.h
//  CloudKit
//
//  Created by Olivier Collet on 10-09-08.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CKCreditsFooterView : UIView {
}

- (id)initWithTitle:(NSString *)title;
+ (id)creditsViewWithTitle:(NSString *)title;

@end
