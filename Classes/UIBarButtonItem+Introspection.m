//
//  UIBarButtonItem+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIBarButtonItem+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UIBarButtonItem (CKIntrospectionAdditions)

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarButtonItemStyle", 
                                               UIBarButtonItemStylePlain,
                                               UIBarButtonItemStyleBordered,
                                               UIBarButtonItemStyleDone);
}

- (void)systemItemExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarButtonSystemItem",
                                                 UIBarButtonSystemItemDone,
                                                 UIBarButtonSystemItemCancel,
                                                 UIBarButtonSystemItemEdit,  
                                                 UIBarButtonSystemItemSave,  
                                                 UIBarButtonSystemItemAdd,
                                                 UIBarButtonSystemItemFlexibleSpace,
                                                 UIBarButtonSystemItemFixedSpace,
                                                 UIBarButtonSystemItemCompose,
                                                 UIBarButtonSystemItemReply,
                                                 UIBarButtonSystemItemAction,
                                                 UIBarButtonSystemItemOrganize,
                                                 UIBarButtonSystemItemBookmarks,
                                                 UIBarButtonSystemItemSearch,
                                                 UIBarButtonSystemItemRefresh,
                                                 UIBarButtonSystemItemStop,
                                                 UIBarButtonSystemItemCamera,
                                                 UIBarButtonSystemItemTrash,
                                                 UIBarButtonSystemItemPlay,
                                                 UIBarButtonSystemItemPause,
                                                 UIBarButtonSystemItemRewind,
                                                 UIBarButtonSystemItemFastForward,
                                                 UIBarButtonSystemItemUndo,
                                                 UIBarButtonSystemItemRedo,
                                                 UIBarButtonSystemItemPageCurl
                                                 );
}

@end
