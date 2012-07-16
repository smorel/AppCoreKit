//
//  CKNSStringMultilinePropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKTextView.h"


@interface CKMultilineNSStringPropertyCellController : CKPropertyGridCellController<UITextViewDelegate> {
    CKTextView* _textView;
}

@property(nonatomic,retain,readonly)CKTextView* textView;

@end
