//
//  RPArtistListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPArtistListTVC.h"
#import "RPTools.h"
#import "RPAlbumListTVC.h"
#import "RandomPlayer-Swift.h"





@interface RPArtistListTVC ()
-(void)loadArtistData;
@property (nonatomic, strong) MPMediaQuery *query;
@property (nonatomic, strong) NSArray *colletionSections;
@end


@implementation RPArtistListTVC

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
    [self loadArtistData];
    self.tableView.canCancelContentTouches = NO;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

/*!Load the artists*/
-(void)loadArtistData
{
    _query = [MPMediaQuery artistsQuery];
    
    _colletionSections= [_query collectionSections];
    
    
}

/*!Return the artist at the given indexPath*/
-(MPMediaItemCollection *)artistAtIndexpath:(NSIndexPath *)indexPath
{
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:indexPath.section];
    long artistIndex = mqs.range.location + indexPath.row;
    
    MPMediaItemCollection *artist = [[_query collections] objectAtIndex:artistIndex];
    return artist;
}



//************************************************************************
//************************************************************************

#pragma mark - Tableview handling

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_colletionSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:section];
    return mqs.range.length;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:section];
    return mqs.title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RPSwipableTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:10];

    MPMediaItemCollection *artist = [self artistAtIndexpath:indexPath];


    titleLabel.text = [[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist];
    
    [cell setDelegate:self];
    //[artistItem valueForProperty:MPMediaItemProperty]

    // Configure the cell...

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"artistToAlbum" sender:indexPath];
}


//************************************************************************
//************************************************************************
 
#pragma mark - SEGUE

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"artistToAlbum"]){
        RPAlbumListTVC *dest = (RPAlbumListTVC *)segue.destinationViewController;
        NSIndexPath *path = sender;
        MPMediaItemCollection *artist = [self artistAtIndexpath:path];
        [dest setArtist:artist];
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
    
    MPMediaItemCollection *artist = [self artistAtIndexpath:path];
    
    [RPQueueManagerOC addSongs:artist.items];
    [cell hideBehindCell];

}

/*! Play next and play directly the first*/
-(void)buttonCenterRightPressed:(RPSwipableTVCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    MPMediaItemCollection *artist = [self artistAtIndexpath:path];
    
    [RPQueueManagerOC addNextAndPlay:artist.items];
    [cell hideBehindCell];
}

/*! Play next */
-(void)buttonRightPressed:(RPSwipableTVCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    MPMediaItemCollection *artist = [self artistAtIndexpath:path];
    
    [RPQueueManagerOC addNextAndPlay:artist.items];
    [cell hideBehindCell];
    
}




@end
