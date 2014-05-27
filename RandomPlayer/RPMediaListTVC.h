//
//  RPMediaListTVC.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RPDictionaryIndexPath.h"

typedef enum {
    RPModeAlbumSelection,
    RPModeAlbumBrowse,
    RPModePlaylistBrowse,
    RPModePlaylistSelection,
    RPModeArtistSelection,
    RPModeArtistBrowse,
    RPModeSongSelection,
    RPModeSongBrowse
} RPListMode;

@interface RPMediaListTVC : UITableViewController
@property (nonatomic, strong) NSString *RPViewType;
//@property (nonatomic) BOOL selecting;
@property (nonatomic) RPListMode listMode;

@property (nonatomic, strong) RPDictionaryIndexPath *infoToShow;

@end

