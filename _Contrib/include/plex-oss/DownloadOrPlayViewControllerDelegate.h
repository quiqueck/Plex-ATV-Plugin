/*
 *  DownloadOrPlayViewControllerDelegate.h
 *  PlexPad
 *
 *  Created by Frank Bauer on 23.12.10.
 *  Copyright 2010 Ambertation. All rights reserved.
 *
 */

#import "CustomMessageViewControllerDelegate.h"
@class DownloadOrPlayViewController;

@protocol DownloadOrPlayViewControllerDelegate <CustomMessageViewControllerDelegate>
-(void)startDownload:(id)ctrl;
-(void)playbackAsUsual:(id)ctrl;
@end