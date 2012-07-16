//
//  CKMoviePlayerCellController.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKitDefines.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CKTableViewCellController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200


/** TODO
 */
@interface CKMoviePlayerCellController : CKTableViewCellController {
	MPMoviePlayerController *_playerController;
}

- (id)initWithContentURL:(NSURL *)url;

@end

#endif