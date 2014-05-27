//
//  RPAlbumListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPAlbumListTVC.h"

@interface RPAlbumListTVC ()
-(void)loadAlbumData;
@end

@implementation RPAlbumListTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAlbumData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)loadAlbumData
{
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    [query setGroupingType:MPMediaGroupingAlbum];
    
    NSArray *col = [query collections];
    
    //NSLog(@"NOMBRE = %lu", (unsigned long)[col count]);
    
    for(MPMediaItemCollection *album in col)
    {
        MPMediaItem *representativeItem = [album representativeItem];
        
        [self.infoToShow addObject:[representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle]
                           withKey:@"title"
                         inSection:[[representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle] substringWithRange:NSMakeRange(0, 1)] ];
        //NSLog(@"ALBUM: %@", [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
