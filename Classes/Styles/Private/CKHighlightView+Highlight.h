//
//  CKStyleView+Highlight.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView.h"

@interface CKHighlightView (Highlight)

- (void)layoutHighlightLayers;
- (void)regenerateHighlight;
- (BOOL)highlightEnabled;

@end
