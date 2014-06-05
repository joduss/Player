//
//  RPSwipableTVCell.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 31.05.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPSwipableTVCell : UITableViewCell <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)buttonLeftAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;

-(void)buttonRightAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;

-(void)buttonCenterRightAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;

-(void)buttonCenterLeftAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;

/*!Clear the content of the cell (reset)*/
@end
