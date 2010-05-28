//
//  CKMoviePlayerCellController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-27.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CloudKit/CKTableViewCellController.h>

@interface CKMoviePlayerCellController : CKTableViewCellController {
	MPMoviePlayerController *_playerController;
}

- (id)initWithContentURL:(NSURL *)url;

@end
