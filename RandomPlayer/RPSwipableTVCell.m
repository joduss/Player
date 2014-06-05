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
@property BOOL isSwiping;
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
        _isSwiping = NO;
        _lastMovement = 0;
        _frontViewOffSet = 80;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)layoutSubviews
{
    
    
    
    if(_behindView == nil)
    {
        _behindView = [[[NSBundle mainBundle] loadNibNamed:@"cellViewBehind" owner:self options:nil] lastObject];
        [_behindView setHidden:YES];
        
        [self addGestureRecognizer:[self swipeRecognizer]];
        
        [self.contentView addSubview:_behindView];
        CGRect frame = self.contentView.frame;
        _behindView.frame = CGRectMake(frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
        
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        
        [self addGestureRecognizer:pan];
    }
    
    [_behindView.buttonLeft setTitle:@"CONNARD" forState:UIControlStateNormal];
}

-(UIGestureRecognizer *)swipeRecognizer
{
    UISwipeGestureRecognizer * reco = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
    reco.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    reco.delegate = self;
    reco.cancelsTouchesInView = NO;
    
    
    
    
    return reco;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint rec = [pan velocityInView:self.contentView];
        DLog(@"Velocity: %f, %f", rec.x, rec.y);
        
        if(abs((rec.y) > 10 && abs(rec.x) < 100) || abs(rec.y) > 50){
            return false;
        }
    }
    return true;
}


-(void)pan:(UIPanGestureRecognizer *)pan
{
    
    if(pan.state == UIGestureRecognizerStateBegan){
        //DLog(@"pan begin");
        CGPoint rec = [pan velocityInView:self.contentView];
        _touchSeparationOffset = [pan locationInView:[self.contentView.subviews objectAtIndex:0]].x - self.contentView.frame.size.width;
        [_behindView setHidden:NO];
        
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        DLog(@"pan changed");
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
        
        DLog(@"touched corrected %f", touchPositionCorrected);
        
        
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
    else if(pan.state == UIGestureRecognizerStateEnded)
    {
        CGRect frame = _behindView.frame;
                float xPosition = frame.origin.x;
        
                UIView *frontView = [self.contentView.subviews objectAtIndex:0];
                UIView *contentView = self.contentView;
        
                double direction = [pan velocityInView:self.contentView].x;
        
        
                NSTimeInterval const maxAnimationDuration = 0.5;
        
                //direction > 0 mean last movement was to right
                if(direction > 0){
                    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
        
                    NSTimeInterval difTime = current - _lastMovement;
                    double velocity = direction / difTime;
        
                    NSTimeInterval neededTime = xPosition / velocity * 1.1; //1.1 because of curve slowing
        
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
                    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
        
                    NSTimeInterval difTime = current - _lastMovement;
                    double velocity = abs(direction / difTime);
        
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
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)swipeToLeft:(UISwipeGestureRecognizer *)reco
{
    
    //load, but with invisible !!!
    if([self.contentView.subviews containsObject:_behindView] == false){
        [self.contentView addSubview:_behindView];
        [_behindView setHidden:NO];
        CGRect frame = self.contentView.frame;
        [_behindView setFrame:CGRectMake(frame.size.width,
                                         frame.origin.y,
                                         frame.size.width,
                                         frame.size.height)]
        ;
    }
    [_behindView setUserInteractionEnabled:NO];
    _isSwiping = true;
    DLog(@"isSwipping to true");
    
}
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//        UITouch *touch = [touches anyObject];
//        _touchSeparationOffset = [touch locationInView:[self.contentView.subviews objectAtIndex:0]].x - self.contentView.frame.size.width;
//        DLog(@"began, offset %f", _touchSeparationOffset);
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    DLog(@"touches moved")
//
//    UITouch *touch = [touches anyObject];
//
//    if(_isSwiping){
//
//        //Where the user touch
//        float x = [touch locationInView:self.contentView].x;
//
//        //Correct and do like if the finger was on the separation
//        //soustraction: offset is negative if touch on left of the separation
//        //and we want to compensate to the other direction
//        float touchPositionCorrected = x - _touchSeparationOffset;
//
//        //In case the user swipe on the wrong direction, the swipe decrease
//        if(touchPositionCorrected < _frontViewOffSet ){
//            touchPositionCorrected = _frontViewOffSet;
//        }
//        else if (touchPositionCorrected > self.contentView.frame.size.width){
//            touchPositionCorrected = self.contentView.frame.size.width;
//        }
//
//        DLog(@"touched corrected %f", touchPositionCorrected);
//
//
//        UIView *contentView = self.contentView;
//
//        //Front view
//        UIView *frontView = [contentView.subviews objectAtIndex:0];
//
//
//        //CGRect behindViewFrame = _behindView.frame;
//
//
//
//        CGRect newFVFrame = CGRectMake( - contentView.frame.size.width + touchPositionCorrected,
//                                       contentView.frame.origin.y,
//                                       contentView.frame.size.width,
//                                       contentView.frame.size.height);
//
//        CGRect newBVFrame = CGRectMake(touchPositionCorrected,
//                                       contentView.frame.origin.y,
//                                       contentView.frame.size.width,
//                                       contentView.frame.size.height);
//
//        //_behindView.frame = BVFrame;
//        //_behindView.bounds = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height);
//
//
//        //animation
//        //[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
//        _behindView.frame = newBVFrame;
//        frontView.frame = newFVFrame;
//        _lastMovement = [NSDate timeIntervalSinceReferenceDate];
//        //} completion:nil];
//
//    }
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(_isSwiping){
//        CGRect frame = _behindView.frame;
//        float xPosition = frame.origin.x;
//
//        UIView *frontView = [self.contentView.subviews objectAtIndex:0];
//        UIView *contentView = self.contentView;
//
//        UITouch *touch = [touches anyObject];
//
//        double direction = [touch locationInView:self.contentView].x - [touch previousLocationInView:self.contentView].x;
//
//
//        NSTimeInterval const maxAnimationDuration = 0.5;
//
//        //direction > 0 mean last movement was to right
//        if(direction > maxAnimationDuration){
//            NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
//
//            NSTimeInterval difTime = current - _lastMovement;
//            double velocity = direction / difTime;
//
//            NSTimeInterval neededTime = xPosition / velocity * 1.1; //1.1 because of curve slowing
//
//            if(neededTime < maxAnimationDuration){
//
//                [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
//                    CGRect newFVFrame = CGRectMake( _frontViewOffSet,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//
//                    CGRect newBVFrame = CGRectMake(contentView.frame.size.width,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//                    _behindView.frame = newBVFrame;
//                    frontView.frame = newFVFrame;
//                }completion:nil];
//            }
//            else
//            {
//                [UIView animateWithDuration:maxAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
//                    CGRect newFVFrame = CGRectMake( 0,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//
//                    CGRect newBVFrame = CGRectMake(contentView.frame.size.width,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//                    _behindView.frame = newBVFrame;
//                    frontView.frame = newFVFrame;
//                }completion:nil];
//            }
//        }
//        else {
//            NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
//
//            NSTimeInterval difTime = current - _lastMovement;
//            double velocity = abs(direction / difTime);
//
//            NSTimeInterval neededTime = xPosition / velocity * 1.1; //1.1 because of curve slowing
//
//            if(neededTime < maxAnimationDuration){
//
//                [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
//                    CGRect newFVFrame = CGRectMake(- contentView.frame.size.width,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//
//                    CGRect newBVFrame = CGRectMake(0,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//                    _behindView.frame = newBVFrame;
//                    frontView.frame = newFVFrame;
//                }completion:nil];
//            }
//            else
//            {
//                [UIView animateWithDuration:maxAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
//                    CGRect newFVFrame = CGRectMake( - contentView.frame.size.width,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//
//                    CGRect newBVFrame = CGRectMake(0,
//                                                   contentView.frame.origin.y,
//                                                   contentView.frame.size.width,
//                                                   contentView.frame.size.height);
//                    _behindView.frame = newBVFrame;
//                    frontView.frame = newFVFrame;
//                }completion:nil];
//            }
//
//
//        }
//
//        _isSwiping = false;
//
//        //DLog(@"isSwiping to false");
//    }
//
//    [_behindView setUserInteractionEnabled:YES];
//
//    DLog(@"end %d", _behindView.buttonLeft.userInteractionEnabled);
//
//
//}



-(void)prepareForReuse
{
    [_behindView removeFromSuperview];
    _behindView = nil;
    [self layoutIfNeeded];
    [[self.contentView.subviews objectAtIndex:0] setFrame:self.contentView.frame];
}


#pragma mark - Add Target for behind view
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
