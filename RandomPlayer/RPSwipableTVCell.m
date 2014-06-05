//
//  RPSwipableTVCell.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 31.05.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPSwipableTVCell.h"
#import "RPCellViewBehind.h"

@interface RPSwipableTVCell()
@property (nonatomic, strong) RPCellViewBehind *behindView;
@property (nonatomic, strong) UISwipeGestureRecognizer *reco;
@property NSTimeInterval lastMovement;
@property float touchSeparationOffset;
@property float frontViewOffSet;
@end

@implementation RPSwipableTVCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _frontViewOffSet = 80;
    }
    return self;
}


-(void)layoutSubviews
{
    if(_behindView == nil)
    {
        _behindView = [[[NSBundle mainBundle] loadNibNamed:@"cellViewBehind" owner:self options:nil] lastObject];
        [_behindView setHidden:YES];
        
        [self.contentView addSubview:_behindView];
        CGRect frame = self.contentView.frame;
        _behindView.frame = CGRectMake(frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
        
   
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paning:)];
        pan.delegate = self;
        
        [self addGestureRecognizer:pan];
    }
    
    [_behindView.buttonLeft setTitle:@"CONNARD" forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)prepareForReuse
{
    [_behindView removeFromSuperview];
    _behindView = nil;
    [self layoutIfNeeded];
    [[self.contentView.subviews objectAtIndex:0] setFrame:self.contentView.frame];
}


#pragma mark - Gesture Recognizer stuff
//############################################################################
/*! Set if the pan gesture should begin or not. If it detects a swipe, it begins */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint rec = [pan velocityInView:self.contentView];
        //DLog(@"Velocity: %f, %f", rec.x, rec.y);

        if(abs(rec.y) / abs(rec.x) > 1/3){
            return false;
        }
    }
    return true;
}


//############################################################################
/*! Handle pan gesture */
-(void)paning:(UIPanGestureRecognizer *)pan
{
    
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        _touchSeparationOffset = [pan locationInView:[self.contentView.subviews objectAtIndex:0]].x - self.contentView.frame.size.width;
        [_behindView setHidden:NO];
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        [self panMoved:pan];
    }
    else if(pan.state == UIGestureRecognizerStateEnded){
        [self panEnded:pan];
    }
    
}


//############################################################################
/*!User pan the cell. Updating the position to animate*/
-(void)panMoved:(UIGestureRecognizer *)pan
{
    //Where the user touch
    float x = [pan locationInView:self.contentView].x;
    
    //Correct and do like if the finger was on the separation
    //soustraction: offset is negative if touch on left of the separation
    //and we want to compensate to the other direction
    float touchPositionCorrected = x - _touchSeparationOffset;
    
    //In case the user swipe on the wrong direction, the swipe decrease
    if(touchPositionCorrected < _frontViewOffSet ){
        touchPositionCorrected = _frontViewOffSet;
    }
    else if (touchPositionCorrected > self.contentView.frame.size.width){
        touchPositionCorrected = self.contentView.frame.size.width;
    }
    
    UIView *contentView = self.contentView;
    
    CGRect newFVFrame = CGRectMake( - contentView.frame.size.width + touchPositionCorrected,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    
    CGRect newBVFrame = CGRectMake(touchPositionCorrected,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    
    _behindView.frame = newBVFrame;
    UIView *frontView = [contentView.subviews objectAtIndex:0];
    frontView.frame = newFVFrame;
}

//############################################################################
/*!Pan Ended: animate the pan*/
-(void)panEnded:(UIPanGestureRecognizer *)pan
{
    CGRect frame = _behindView.frame;
    float xPosition = frame.origin.x;
    
    UIView *frontView = [self.contentView.subviews objectAtIndex:0];
    UIView *contentView = self.contentView;
    
    double direction = [pan velocityInView:self.contentView].x;
    
    
    NSTimeInterval const maxAnimationDuration = 0.5;
    
    //direction > 0 mean last movement was to right
    if(direction > 0){
        
        double velocity = [pan velocityInView:contentView].x;
        
        NSTimeInterval neededTime = (contentView.frame.size.width - xPosition) / velocity * 1.1; //1.1 because of curve slowing
        
        if(neededTime < maxAnimationDuration){
            
            [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
                CGRect newFVFrame = CGRectMake( _frontViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(contentView.frame.size.width,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _behindView.frame = newBVFrame;
                frontView.frame = newFVFrame;
            }completion:nil];
        }
        else
        {
            [UIView animateWithDuration:maxAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                CGRect newFVFrame = CGRectMake( _frontViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(contentView.frame.size.width,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _behindView.frame = newBVFrame;
                frontView.frame = newFVFrame;
            }completion:nil];
        }
    }
    else {
        
        double velocity = abs([pan velocityInView:contentView].x);

        
        NSTimeInterval neededTime = xPosition / velocity * 1.1; //1.1 because of curve slowing
        
        if(neededTime < maxAnimationDuration){
            
            [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
                CGRect newFVFrame = CGRectMake(- contentView.frame.size.width,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(_frontViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _behindView.frame = newBVFrame;
                frontView.frame = newFVFrame;
            }completion:nil];
        }
        else
        {
            [UIView animateWithDuration:maxAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                CGRect newFVFrame = CGRectMake( - contentView.frame.size.width,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(_frontViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _behindView.frame = newBVFrame;
                frontView.frame = newFVFrame;
            }completion:nil];
        }
    }
}



#pragma mark - Add Target for behind view

//These methods are used to set action on the buttons "behind" the cell

-(void)buttonLeftAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_behindView.buttonLeft addTarget:target action:action forControlEvents:event];
}

-(void)buttonRightAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_behindView.buttonRight addTarget:target action:action forControlEvents:event];
}

-(void)buttonCenterRightAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_behindView.buttonCenterRight addTarget:target action:action forControlEvents:event];
}

-(void)buttonCenterLeftAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_behindView.buttonCenterLeft addTarget:target action:action forControlEvents:event];
}

@end
