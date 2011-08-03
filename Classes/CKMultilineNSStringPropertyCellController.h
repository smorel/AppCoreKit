//
//  CKNSStringMultilinePropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-03.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKTextView.h"


@interface CKMultilineNSStringPropertyCellController : CKTableViewCellController<UITextViewDelegate> {
    CKTextView* _textView;
}

@property(nonatomic,retain,readonly)CKTextView* textView;

@end
