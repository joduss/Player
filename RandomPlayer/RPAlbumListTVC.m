//
//  RPAlbumListTVC.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPAlbumListTVC.h"
#import "RPTools.h"

@interface RPAlbumListTVC ()
-(void)loadAlbumData;
@property (nonatomic, strong) MPMediaQuery *query;
@property (nonatomic, strong) NSArray *colletionSections;
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
    DLog("View did load AlbumList");
    [super viewDidLoad];
    [self loadAlbumData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadAlbumData];

}

-(void)loadAlbumData
{
    _query = [MPMediaQuery albumsQuery];
    [_query setGroupingType:MPMediaGroupingAlbum];
    
    
    if(_artist != nil){
        [_query setFilterPredicates:[NSSet setWithObjects:
                                    [NSPredicate predicateWithFormat:@"%K==%@",MPMediaItemPropertyArtist,_artist], nil]];
    }
    
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
    
    UIImageView *imgv = (UIImageView *)[self.view viewWithTag:100];
    UILabel *titleLabel  = (UILabel *)[self.view viewWithTag:101];
    UILabel *subtitleLabel  = (UILabel *)[self.view viewWithTag:102];
    
    MPMediaQuerySection *mqs = [_colletionSections objectAtIndex:indexPath.section];
    long albumIndex = mqs.range.location + indexPath.row;
    
    MPMediaItemCollection *album = [[_query collections] objectAtIndex:albumIndex];
    

    
    titleLabel.text = [[album representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    unsigned long count = [album count];
    if(count < 2)
        subtitleLabel.text = [NSString stringWithFormat:@"%d song", count];
    else
        subtitleLabel.text = [NSString stringWithFormat:@"%lu songs", count];
    
    MPMediaItemArtwork *artwork = [[album representativeItem] valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *im = [artwork imageWithSize:imgv.bounds.size];
    [imgv setImage:im];
    
    
    
    
    //[artistItem valueForProperty:MPMediaItemProperty]
    
    // Configure the cell...
    
    return cell;
}



@end
