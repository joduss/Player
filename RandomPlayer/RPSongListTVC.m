//
//  RPSongListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 09.06.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPSongListTVC.h"
#import "RPTools.h"

@interface RPSongListTVC ()
@property (nonatomic,strong) MPMediaQuery *query;

@end

@implementation RPSongListTVC

- (instancetype)initWithStyle:(UITableViewStyle)style
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
    [self loadSongData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadSongData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - songs data

/*!Return the songs (mediaitem) at the given indexpath*/
-(MPMediaItem *)songAtIndexPath:(NSIndexPath *)path
{
    MPMediaQuerySection *mqs = [_query.itemSections objectAtIndex:path.section];
    long index = mqs.range.location + path.row;
    return [[_query items] objectAtIndex:index];
}


/*!Load songs data: set the query*/
-(void)loadSongData
{
    _query = [MPMediaQuery songsQuery];
    [_query setGroupingType:MPMediaGroupingAlbum];
    
    //If an artist was given, then it shows only album for this artist
    if(_album != nil){
        self.title = [_album.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        [_query setFilterPredicates:[NSSet setWithObjects:
                                     [MPMediaPropertyPredicate predicateWithValue:[[_album representativeItem] valueForProperty:MPMediaItemPropertyAlbumPersistentID]
                                                                      forProperty:MPMediaItemPropertyAlbumPersistentID], nil]];
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _query.itemSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    MPMediaQuerySection *mqs = [_query.itemSections objectAtIndex:0];
    return mqs.range.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RPSwipableTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.rightViewOffSet = 80;

    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:400];
    UILabel *subtitleLabel = (UILabel *)[cell.contentView viewWithTag:401];
    
    MPMediaItem *song = [self songAtIndexPath:indexPath];
    
    titleLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
    NSTimeInterval durationInSeconds = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue];
    subtitleLabel.text = [RPTools minutesSecondsConversion:durationInSeconds];
    
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





@end
