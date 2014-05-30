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
    MPMediaQuery *query = [MPMediaQuery artistsQuery];
    //[query setGroupingType:MPMediaGroupingArtist];
    
    NSArray *col = [query collections];
    
    //NSLog(@"NOMBRE = %lu", (unsigned long)[col count]);
    
    for(MPMediaItemCollection *artist in col)
    {
        MPMediaItem *representativeItem = [artist representativeItem];
        NSString *artistName = [representativeItem valueForProperty:MPMediaItemPropertyArtist];
        artistName = [RPTools clearStringForSort:artistName];
        
        NSString *section = @"";
        if([RPTools beginWithLetter:artistName] == false){
            section = @"*";
        }
        else
        {
            section = [artistName substringWithRange:NSMakeRange(0, 1)];
        }
        
        
        [self.infoToShow addObject:artist
                         inSection: section];
        //NSLog(@"ALBUM: %@", [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle]);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    //UIImageView *imgv = (UIImageView *)[self.view viewWithTag:10];
    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:10];
    //UILabel *subtitleLabel  = (UILabel *)[self.view viewWithTag:102];
    
    MPMediaItemCollection *artist = [self.infoToShow objectAt:indexPath];


    titleLabel.text = [[artist representativeItem] valueForProperty:MPMediaItemPropertyArtist];
    //[artistItem valueForProperty:MPMediaItemProperty]

    // Configure the cell...

    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
