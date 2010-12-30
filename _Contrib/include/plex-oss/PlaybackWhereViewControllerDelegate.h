/*
 *  PlaybackWhereViewControllerDelegate.h
 *  PlexPad
 *
 *  Created by Frank Bauer on 23.12.10.
 *  Copyright 2010 Ambertation. All rights reserved.
 *
 */

#import "CustomMessageViewControllerDelegate.h"

@protocol PlaybackWhereViewControllerDelegate <CustomMessageViewControllerDelegate>
-(void)startPlaybackInPlex;
-(void)startPlaybackOnDevice;
@end