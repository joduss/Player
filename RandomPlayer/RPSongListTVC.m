////
////  RPSongListTVC.m
////  RandomPlayer
////
////  Created by Jonathan Duss on 09.06.14.
////  Copyright (c) 2014 Jonathan Duss. All rights reserved.
////
//
//#import "RPSongListTVC.h"
//#import "RPTools.h"
//#import "RandomPlayer-Swift.h"
//
//@interface RPSongListTVC ()
//@property (nonatomic,strong) MPMediaQuery *query;
//
//@end
//
//@implementation RPSongListTVC
//
//- (instancetype)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    [self loadSongData];
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self loadSongData];
//    [self.tableView reloadData];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//
//#pragma mark - songs data
//
///*!Return the songs (mediaitem) at the given indexpath*/
//-(MPMediaItem *)songAtIndexPath:(NSIndexPath *)path
//{
//    MPMediaQuerySection *mqs = [_query.itemSections objectAtIndex:path.section];
//    long index = mqs.range.location + path.row;
//    return [[_query items] objectAtIndex:index];
//}
//
//
///*!Load songs data: set the query*/
//-(void)loadSongData
//{
//    _query = [MPMediaQuery songsQuery];
//    [_query setGroupingType:MPMediaGroupingAlbum];
//    
//    //If an artist was given, then it shows only album for this artist
//    if(_album != nil){
//        self.title = [_album.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
//        [_query setFilterPredicates:[NSSet setWithObjects:
//                                     [MPMediaPropertyPredicate predicateWithValue:[[_album representativeItem] valueForProperty:MPMediaItemPropertyAlbumPersistentID]
//                                                                      forProperty:MPMediaItemPropertyAlbumPersistentID], nil]];
//    }
//}
//
//
//
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return _query.itemSections.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    MPMediaQuerySection *mqs = [_query.itemSections objectAtIndex:0];
//    return mqs.range.length;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    RPSwipableTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    [cell layoutSubviews];
//    cell.delegate = self;
//    cell.rightViewOffSet = 80;
//
//    
//    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:400];
//    UILabel *subtitleLabel = (UILabel *)[cell.contentView viewWithTag:401];
//    
//    MPMediaItem *song = [self songAtIndexPath:indexPath];
//    
//    titleLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
//    NSTimeInterval durationInSeconds = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue];
//    subtitleLabel.text = [RPTools minutesSecondsConversion:durationInSeconds];
//    
//    
//    return cell;
//}
//
//
////************************************************************************
////************************************************************************
//#pragma mark - RPSwipableTVCellDelegate handling
//
//-(void)buttonLeftPressed:(RPSwipableTVCell *)cell{}
//
//
///*!Correspond to add to queue*/
//-(void)buttonCenterLeftPressed:(RPSwipableTVCell *)cell
//{
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    
//    MPMediaItem *song = [self songAtIndexPath:path];
//    
//    
//    
//    [RPQueueManagerOC addSongs:[NSArray arrayWithObject:song]];
//    [cell hideBehindCell];
//    
//}
//
///*! Play next and play directly the first*/
//-(void)buttonCenterRightPressed:(RPSwipableTVCell *)cell
//{
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    
//    MPMediaItem* song = [self songAtIndexPath:path];
//    
//    [RPQueueManagerOC addNextAndPlay:[NSArray arrayWithObject:song]];
//    [cell hideBehindCell];
//}
//
///*! Play next */
//-(void)buttonRightPressed:(RPSwipableTVCell *)cell
//{
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    
//    MPMediaItem *song = [self songAtIndexPath:path];
//    
//    [RPQueueManagerOC addNextAndPlay:[NSArray arrayWithObject:song]];
//    [cell hideBehindCell];
//    
//}
//
//
//
//
//
//@end
