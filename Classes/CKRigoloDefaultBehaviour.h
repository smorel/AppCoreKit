//
//  CKRigoloDefaultBehaviour.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKRigoloWebService.h"

/** 
 TODO
 */
@interface CKRigoloDefaultBehaviour : NSObject<CKRigoloWebServiceDelegate,UIAlertViewDelegate> {
    NSArray* _items;
}

@end
