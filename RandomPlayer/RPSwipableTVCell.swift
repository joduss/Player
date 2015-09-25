//
//  RPSwipableTVCell.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 12.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit





protocol RPSwipableTVCellDelegate {
    func buttonLeftPressed(cell : RPSwipableTVCell!)
    func buttonCenterLeftPressed(cell : RPSwipableTVCell!)
    func buttonRightPressed(cell : RPSwipableTVCell!)
    func buttonCenterRightPressed(cell : RPSwipableTVCell!)
}




class RPSwipableTVCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    let MAX_CELL_ANIMATION_DURATION = 0.5
    
    var behindView : RPCellViewBehind?
    
    var behindViewOffSet : CGFloat = 0.0
    
    var frontView : UIView?
    
    var lastMovement = NSTimeInterval(0)
    var touchOffSet = 0.0
    
    var delegate : RPSwipableTVCellDelegate?
    
    
    
//    override init() {
//        super.init()
//    }
//    
//    override     
//    init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        behindView =  NSBundle.mainBundle().loadNibNamed("cellViewBehind", owner: self, options: nil).last as? RPCellViewBehind
        frontView = self.contentView.subviews[0] as? UIView
        behindView?.hidden = true
        
        self.contentView.insertSubview(behindView!, belowSubview: frontView!)
        
        

        //add actions on buttons
        //TODO
        behindView?.buttonLeft?.addTarget(self, action: "buttonLeftPressed", forControlEvents: UIControlEvents.TouchUpInside)
        behindView?.buttonCenterLeft?.addTarget(self, action: "buttonCenterLeftPressed", forControlEvents: UIControlEvents.TouchUpInside)
        behindView?.buttonCenterRight?.addTarget(self, action: "buttonCenterRightPressed", forControlEvents: UIControlEvents.TouchUpInside)
        behindView?.buttonRight?.addTarget(self, action: "buttonRightPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    override func prepareForReuse() {
        //super.prepareForReuse()
        frontView?.frame = self.contentView.frame
        behindView?.hidden = true
    }
    
    
    
    override func layoutSubviews() {
 
        //do layout
        if(frontView != nil && behindView != nil){
        
            //find offset
            if let b = behindView?.buttonLeft {
                behindViewOffSet = b.frame.origin.x
            }
            else if let b = behindView?.buttonCenterLeft {
                behindViewOffSet = b.frame.origin.x
            } else if let b = behindView?.buttonCenterRight {
                behindViewOffSet = b.frame.origin.x
            } else if let b = behindView?.buttonRight {
                behindViewOffSet = b.frame.origin.x
            }
            
            if let bv = behindView {
                if(bv.hidden){
                    bv.frame = self.contentView.frame
                    frontView?.frame = self.contentView.frame
                }
                else {
                    let newFrame = CGRectMake(
                        -frame.size.width + self.behindViewOffSet,
                        contentView.frame.origin.y,
                        contentView.frame.size.width,
                        contentView.frame.size.height)
                    bv.frame = self.contentView.frame
                    frontView?.frame = newFrame
                }
            }
            
            
            let pan = UIPanGestureRecognizer(target: self, action: "paning:")
            pan.delegate = self
            
            self.addGestureRecognizer(pan)
        }
        else {
            NSException(name: "Error RPSwipableTVCell", reason: "Can't find enough views. Check that you have in the custom cell: a view over the content view. You have to add UI element in that view", userInfo: nil).raise()
        }
        
        super.layoutSubviews()
    }
    
    
    //############################################################################
    //############################################################################
    //MARK : Gesture stuff
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer.isMemberOfClass(UIPanGestureRecognizer)){
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            
            let velocity = pan.velocityInView(self.contentView)
            
            if(abs(velocity.y) / abs(velocity.x) > 1/4){
                return false
            }
        }
        else {
            if let view = behindView {
                let viewInside = (self.contentView.window!).subviews[0] 
                var eventToTest = UIEvent()
                
                if(view.pointInside(gestureRecognizer.locationInView(viewInside), withEvent: nil)){
                    return false
                }
            }

        }

        return true
    }
    
    
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer)-> Bool {
        return false
    }
    
    func paning(pan : UIPanGestureRecognizer) {
        
        if(pan.state == UIGestureRecognizerState.Began){
            behindView?.hidden = false
            if let fv = frontView {
                let frontViewPositionX = fv.frame.origin.x
                let touchPositionX = pan.locationInView(self.contentView).x
                
                touchOffSet = Double(frontViewPositionX) - Double(touchPositionX)
                behindView?.hidden = false
            }
        }
        else if (pan.state == UIGestureRecognizerState.Changed) {
            panMoved(pan)
        }
        else if(pan.state == UIGestureRecognizerState.Ended) {
            panEnded(pan)
        }
    }
    
    
    
    func panMoved(pan : UIGestureRecognizer) {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None

        
        let touchPositionX = pan.locationInView(self.contentView).x
        var touchPositionCorrectedX = touchPositionX + CGFloat(touchOffSet)
        
        if(touchPositionCorrectedX > 0){
            touchPositionCorrectedX = log2(touchPositionCorrectedX)
        }
        else if(touchPositionCorrectedX < (-1 * contentView.frame.size.width + behindViewOffSet)) {
            touchPositionCorrectedX = (-1 * contentView.frame.size.width + behindViewOffSet) - log2(abs(touchPositionCorrectedX + contentView.frame.size.width - behindViewOffSet))
        }
        
        
        let newFrame = CGRectMake(touchPositionCorrectedX,
            contentView.frame.origin.y,
            contentView.frame.width,
            contentView.frame.size.height)
        
        frontView?.frame = newFrame
        
    }
    
    
    func panEnded(pan : UIPanGestureRecognizer) {
        
        if let fv = frontView{
            let speedUpConstant = CGFloat(1.1)
            
            let frontViewXPosition = fv.frame.origin.x
            
            let velocity = pan.velocityInView(self.contentView).x
            
            if(velocity > 0) {
                //velocity < 0 -> last movement went to the right (cell become closed)
                
                var neededTime = NSTimeInterval((contentView.frame.size.width - frontViewXPosition) / velocity * speedUpConstant)
                
                if(neededTime > MAX_CELL_ANIMATION_DURATION){
                    neededTime = MAX_CELL_ANIMATION_DURATION
                }
//                
//                UIView.animateWithDuration(NSTimeInterval(neededTime), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
//                    fv.frame = self.contentView.frame
//                    }, completion: {(a : Bool) -> Void in
//                        self.behindView?.hidden = true
//                })
                
                
                UIView.animateWithDuration(neededTime, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {() -> Void in
                        fv.frame = self.contentView.frame
                    },
                    completion:{(c : Bool) -> Void in
                        if(c){
                            self.behindView?.hidden = true
                        }
                })
                
                

            }
            else {
                //velocity > 0 -> last movement went to the left
                
                var neededTime = (contentView.frame.size.width - frontViewXPosition) / velocity * speedUpConstant
                
                if(neededTime > CGFloat(MAX_CELL_ANIMATION_DURATION)){
                    neededTime = CGFloat(MAX_CELL_ANIMATION_DURATION)
                }
                /*
                UIView.animateWithDuration(NSTimeInterval(neededTime),
                    animations: {() -> Void in
                        let frame = self.contentView.frame
                        
                        let newFrame = CGRectMake(
                            -frame.size.width + CGFloat(self.behindViewOffSet),
                            frame.origin.y,
                            frame.size.width,
                            frame.size.height)
                        fv.frame = self.contentView.frame
                })
                */
                
                
                UIView.animateWithDuration(NSTimeInterval(neededTime), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                    let frame = self.contentView.frame
                    
                    let newFrame = CGRectMake(
                        -frame.size.width + self.behindViewOffSet,
                        frame.origin.y,
                        frame.size.width,
                        frame.size.height)
                    fv.frame = newFrame
                    }, completion: nil)
            }
        }
    }

    //############################################################################################
    //############################################################################################
    
    //UITableViewCell stuff
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // Configure the view for the selected state
    }
    
    
    func hideBehindCell(){
        
        if let fv = frontView{
            
            let neededTime = MAX_CELL_ANIMATION_DURATION
            
            UIView.animateWithDuration(neededTime, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {() -> Void in
                    fv.frame = self.contentView.frame
                },
                completion:{(c : Bool) -> Void in
                    if(c){
                        self.behindView?.hidden = true
                    }
            })
            
        }
        
    }
    
    //############################################################################################
    //############################################################################################
    //Handle buttons
    func buttonLeftPressed(){
        self.delegate?.buttonCenterLeftPressed(self)
    }
    
    func buttonCenterLeftPressed(){
        delegate?.buttonCenterLeftPressed(self)
    }
    
    func buttonRightPressed(){
        delegate?.buttonRightPressed(self)
    }
    
    func buttonCenterRightPressed(){
        delegate?.buttonCenterRightPressed(self)
    }
    
}
