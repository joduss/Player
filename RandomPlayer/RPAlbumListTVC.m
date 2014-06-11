//
//  RPAlbumListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPAlbumListTVC.h"
#import "RPTools.h"
#import "RandomPlayer-Swift.h"
#import "RPSongListTVC.h"


@interface RPAlbumListTVC ()
-(void)loadAlbumData;
@property (nonatomic, strong) MPMediaQuery *query;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadAlbumData];
    [self.tableView reloadData];
    
}

-(void)loadAlbumData
{
    _query = [MPMediaQuery albumsQuery];
    [_query setGroupingType:MPMediaGroupingAlbum];
    
    //If an artist was given, then it shows only album for this artist
    if(_artist != nil){
        self.title = [_artist valueForProperty:MPMediaItemPropertyArtist];
        [_query setFilterPredicates:[NSSet setWithObjects:
                                     [MPMediaPropertyPredicate predicateWithValue:[[_artist representativeItem] valueForProperty:MPMediaItemPropertyArtistPersistentID]
                                                                      forProperty:MPMediaItemPropertyArtistPersistentID], nil]];
        
    }
}

/*!return the album at the given indexPath*/
-(MPMediaItemCollection *)albumAtIndexpath:(NSIndexPath *)indexPath
{
    MPMediaQuerySection *mqs = [_query.collectionSections objectAtIndex:indexPath.section];
    long albumIndex = mqs.range.location + indexPath.row;
    
    return [[_query collections] objectAtIndex:albumIndex];
}





//************************************************************************
//************************************************************************
#pragma mark - TableView Handling 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_query.collectionSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MPMediaQuerySection *mqs = [_query.collectionSections objectAtIndex:section];
    return mqs.range.length;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MPMediaQuerySection *mqs = [_query.collectionSections objectAtIndex:section];
    return mqs.title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RPSwipableTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.rightViewOffSet = 80;
    
    UIImageView *imgv = (UIImageView *)[self.view viewWithTag:100];
    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:101];
    UILabel *subtitleLabel  = (UILabel *)[self.view viewWithTag:102];
    

    MPMediaItemCollection *album = [self albumAtIndexpath:indexPath];
    
    
    titleLabel.text = [[album representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    unsigned long count = [album count];
    if(count < 2)
        subtitleLabel.text = [NSString stringWithFormat:@"%lu song", count];
    else
        subtitleLabel.text = [NSString stringWithFormat:@"%lu songs", count];
    
    MPMediaItemArtwork *artwork = [[album representativeItem] valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *im = [artwork imageWithSize:imgv.bounds.size];
    [imgv setImage:im];
    
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"albumToSong" sender:indexPath];
}

//************************************************************************
//************************************************************************

#pragma mark - SEGUE

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"albumToSong"]){
        RPSongListTVC *dest = (RPSongListTVC *)segue.destinationViewController;
        NSIndexPath *path = sender;
        MPMediaItemCollection *artist = [self albumAtIndexpath:path];
        [dest setAlbum:artist];
    }
}


//************************************************************************
//************************************************************************
#pragma mark - RPSwipableTVCellDelegate handling

-(void)buttonLeftPressed:(RPSwipableTVCell *)cell{}


/*!Correspond to add to queue*/
-(void)buttonCenterLeftPressed:(RPSwipableTVCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    MPMediaItemCollection *artist = [self albumAtIndexpath:path];
    
    [RPQueueManagerOC addSongs:artist.items];
    [cell hideBehindCell];
    
}

/*! Play next and play directly the first*/
-(void)buttonCenterRightPressed:(RPSwipableTVCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    MPMediaItemCollection *artist = [self albumAtIndexpath:path];
    
    [RPQueueManagerOC addNextAndPlay:artist.items];
    [cell hideBehindCell];
}

/*! Play next */
-(void)buttonRightPressed:(RPSwipableTVCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    MPMediaItemCollection *artist = [self albumAtIndexpath:path];
    
    [RPQueueManagerOC addNextAndPlay:artist.items];
    [cell hideBehindCell];
    
}


@end
