//
//  CKStyleView+Highlight.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKStyleView (Highlight)

- (void)layoutHighlightLayers;
- (void)regenerateHighlight;
- (BOOL)highlightEnabled;

@end
