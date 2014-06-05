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

-(void)loadArtistData
{
    _query = [MPMediaQuery artistsQuery];
    
    _colletionSections= [_query collectionSections];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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

    //UIImageView *imgv = (UIImageView *)[self.view viewWithTag:10];
    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:10];
    //UILabel *subtitleLabel  = (UILabel *)[self.view viewWithTag:102];

    MPMediaItemCollection *artist = [self artistAtIndexpath:indexPath];


    titleLabel.text = [[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist];
    //[artistItem valueForProperty:MPMediaItemProperty]

    // Configure the cell...

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"artistToAlbum" sender:indexPath];
}





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


-(MPMediaItemCollection *)artistAtIndexpath:(NSIndexPath *)indexPath
{
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:indexPath.section];
    long artistIndex = mqs.range.location + indexPath.row;
    
    MPMediaItemCollection *artist = [[_query collections] objectAtIndex:artistIndex];
    return artist;
}









-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    
    //touch.gestureRecognizers;
}

@end
