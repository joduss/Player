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
@property (nonatomic, strong) RPCellViewBehind *rightView;
@property (nonatomic, weak) UIView *leftView;
@property (nonatomic, strong) UISwipeGestureRecognizer *reco;
@property NSTimeInterval lastMovement;
@property float touchSeparationOffset;

@end


@implementation RPSwipableTVCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}



-(void)layoutSubviews
{
    if(_rightView == nil)
    {
        _rightView = [[[NSBundle mainBundle] loadNibNamed:@"cellViewBehind" owner:self options:nil] lastObject];
        [_rightView setHidden:YES];
        _leftView = [self.contentView.subviews objectAtIndex:0];
        
        //add action
        [_rightView.buttonCenterLeft addTarget:self action:@selector(buttonCenterLeftPressed) forControlEvents:UIControlEventTouchUpInside];
        [_rightView.buttonCenterRight addTarget:self action:@selector(buttonCenterRightPressed) forControlEvents:UIControlEventTouchUpInside];
        [_rightView.buttonLeft addTarget:self action:@selector(buttonLeft) forControlEvents:UIControlEventTouchUpInside];
        [_rightView.buttonRight addTarget:self action:@selector(buttonRight) forControlEvents:UIControlEventTouchUpInside];
        
        //resize and add behindView to the cell
        [self.contentView insertSubview:_rightView belowSubview:_leftView];
        CGRect frame = self.contentView.frame;
        _rightView.frame = CGRectMake(frame.size.width - _rightViewOffSet, frame.origin.y, frame.size.width, frame.size.height);
        
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paning:)];
        pan.delegate = self;
        
        [self.contentView addGestureRecognizer:pan];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)prepareForReuse
{
    //Reset the cell by setting defaults position for view
    [_rightView setHidden:YES];
    UIView *contentView = self.contentView;
    CGRect newFVFrame = CGRectMake( 0,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    
    CGRect newBVFrame = CGRectMake(contentView.frame.size.width - _rightViewOffSet,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    _rightView.frame = newBVFrame;
    _leftView.frame = newFVFrame;
    
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
    else
    {
        if([_rightView pointInside:[gestureRecognizer locationInView:[self.contentView.window.subviews objectAtIndex:0]] withEvent:UIEventTypeTouches] ){
            DLog(@"hello");
            return false;
        }
    }
    return true;
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}



//############################################################################
/*! Handle pan gesture */
-(void)paning:(UIPanGestureRecognizer *)pan
{
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        //Correct to do like if the finger was on the separation
        //If finger is 50pixel left from separation, and swipe, then the position of
        // the separation will be position of finger + 50px. OffsetWill be +50.
        
        //Need to add leftViewOffSet  as the separation is in fact where the view begin
        // and thus it can be slighly behind the leftView. We add it, so we can deal like
        //if it was not the case.
        //If first button (80px) not visible. leftViewOffset will be 80px. So
        //The position of the separation appearing on screen will be: position of
        //rightView + 80.
        float positionSeparation = _rightView.frame.origin.x + _rightViewOffSet;
        float positionTouch = [pan locationInView:self.contentView].x;
        
        _touchSeparationOffset = positionSeparation - positionTouch;
        
        DLog(@"\nx: %f     toucheseparation offSet %f",positionTouch, _touchSeparationOffset);
        
        [_rightView setHidden:NO];
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
    DLog(@"heigh button: %f", _rightView.buttonCenterLeft.frame.size.height);
    DLog(@"contentView height: %f", self.contentView.frame.size.height);
    DLog(@"self heigh %f",self.frame.size.height);
    
    //Where the user touch
    float x = [pan locationInView:self.contentView].x;
    //give position of finger relative to separation. Negative = finger on left (wrt sep.)
    
    //Correct to do like if the finger was on the separation
    //If finger is 50pixel left from separation, and swipe, then the position of
    // the separation will be position of finger + 50px
    float touchPositionCorrected = x + _touchSeparationOffset ;
    
    //In case the user swipe on the wrong direction, the swipe decrease
//    if(touchPositionCorrected < _frontViewOffSet ){
//        touchPositionCorrected = _frontViewOffSet;
//    }
//    else if (touchPositionCorrected > self.contentView.frame.size.width){
//        touchPositionCorrected = self.contentView.frame.size.width;
//    }
    
    UIView *contentView = self.contentView;
    
    CGRect newFVFrame = CGRectMake( - contentView.frame.size.width + touchPositionCorrected, // ERREUR LA !!!!!!
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    
    CGRect newBVFrame = CGRectMake(touchPositionCorrected - _rightViewOffSet,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    
    _rightView.frame = newBVFrame;
    _leftView.frame = newFVFrame;
}

//############################################################################
/*!Pan Ended: animate the pan*/
-(void)panEnded:(UIPanGestureRecognizer *)pan
{
    CGRect frame = _rightView.frame;
    float xPosition = frame.origin.x;
    
    UIView *contentView = self.contentView;
    
    double direction = [pan velocityInView:self.contentView].x;
    
    
    
    if(direction > 0){
        //direction > 0 mean last movement was to right
        double velocity = [pan velocityInView:contentView].x;
        
        NSTimeInterval neededTime = (contentView.frame.size.width - xPosition) / velocity * 1.1; //1.1 because of curve slowing
        
        DLog(@"%f",_rightViewOffSet);
        
        if(neededTime < MAX_CELL_ANIMATION_DURATION){
            
            [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
                CGRect newFVFrame = CGRectMake( 0,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(contentView.frame.size.width - _rightViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _rightView.frame = newBVFrame;
                _leftView.frame = newFVFrame;
            }completion:nil];
        }
        else
        {
            [UIView animateWithDuration:MAX_CELL_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                CGRect newFVFrame = CGRectMake( 0,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(contentView.frame.size.width - _rightViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _rightView.frame = newBVFrame;
                _leftView.frame = newFVFrame;
            }completion:nil];
        }
    }
    else {
        //Swipe to the left
        double velocity = abs([pan velocityInView:contentView].x);
        
        
        NSTimeInterval neededTime = xPosition / velocity * 1.1; //1.1 because of curve slowing
        
        if(neededTime < MAX_CELL_ANIMATION_DURATION){
            
            [UIView animateWithDuration:neededTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
                CGRect newFVFrame = CGRectMake(- contentView.frame.size.width + _rightViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(0,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _rightView.frame = newBVFrame;
                _leftView.frame = newFVFrame;
            }completion:nil];
        }
        else
        {
            [UIView animateWithDuration:MAX_CELL_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                CGRect newFVFrame = CGRectMake( - contentView.frame.size.width + _rightViewOffSet,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                
                CGRect newBVFrame = CGRectMake(0,
                                               contentView.frame.origin.y,
                                               contentView.frame.size.width,
                                               contentView.frame.size.height);
                _rightView.frame = newBVFrame;
                _leftView.frame = newFVFrame;
            }completion:nil];
        }
    }
}



-(void)hideBehindCell
{
    UIView *contentView = self.contentView;
    
    [UIView animateWithDuration:MAX_CELL_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
        CGRect newFVFrame = CGRectMake( 0,
                                       contentView.frame.origin.y,
                                       contentView.frame.size.width,
                                       contentView.frame.size.height);
        
        CGRect newBVFrame = CGRectMake(contentView.frame.size.width - _rightViewOffSet,
                                       contentView.frame.origin.y,
                                       contentView.frame.size.width,
                                       contentView.frame.size.height);
        _rightView.frame = newBVFrame;
        _leftView.frame = newFVFrame;
    }completion:nil];
    
}


#pragma mark - Call the delegate

//These methods are used to set action on the buttons "behind" the cell

-(void)buttonLeftPressed
{
    if([_delegate respondsToSelector:@selector(buttonLeftPressed:)]){
        [self.delegate buttonLeftPressed:self];
    }
    else
    {
        WLog(@"WARNING: %@ does not respond to buttonLeftPressed", _delegate)
    }
}

-(void)buttonCenterLeftPressed
{
    
    if([_delegate respondsToSelector:@selector(buttonLeftPressed:)]){
        [self.delegate buttonCenterLeftPressed:self];
    }
    else
    {
        WLog(@"WARNING: %@ does not respond to buttonCenterLeftPressed", _delegate)
    }
}

-(void)buttonCenterRightPressed
{
    if([_delegate respondsToSelector:@selector(buttonLeftPressed:)]){
        [self.delegate buttonCenterRightPressed:self];
    }
    else
    {
        WLog(@"WARNING: %@ does not respond to buttonCenterRightPressed", _delegate)
    }
}

-(void)buttonRightPressed
{
    if([_delegate respondsToSelector:@selector(buttonLeftPressed:)]){
        [self.delegate buttonRightPressed:self];
    }
    else
    {
        WLog(@"WARNING: %@ does not respond to buttonRightPressed", _delegate)
    }
}

@end



