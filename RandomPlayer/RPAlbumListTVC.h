//
//  RPAlbumListTVC.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPMediaListTVC.h"

@interface RPAlbumListTVC : RPMediaListTVC
@property (nonatomic, strong) MPMediaItemCollection *artist;
@end
