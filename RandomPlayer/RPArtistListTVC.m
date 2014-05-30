//
//  RPArtistListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPArtistListTVC.h"
#import "RPTools.h"


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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    //UIImageView *imgv = (UIImageView *)[self.view viewWithTag:10];
    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:10];
    //UILabel *subtitleLabel  = (UILabel *)[self.view viewWithTag:102];
    
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:indexPath.section];
    long albumIndex = mqs.range.location + indexPath.row;
        
    MPMediaItemCollection *artist = [[_query collections] objectAtIndex:albumIndex];


    titleLabel.text = [[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist];
    //[artistItem valueForProperty:MPMediaItemProperty]

    // Configure the cell...

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
