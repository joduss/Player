//
//  RPSwipableTVCell.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 12.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit





protocol RPSwipableTVCellDelegate {
    func buttonLeftPressed(_ cell : RPSwipableTVCell!)
    func buttonCenterLeftPressed(_ cell : RPSwipableTVCell!)
    func buttonRightPressed(_ cell : RPSwipableTVCell!)
    func buttonCenterRightPressed(_ cell : RPSwipableTVCell!)
}




class RPSwipableTVCell: UITableViewCell {
    
    let MAX_CELL_ANIMATION_DURATION = 0.5
    
    var behindView : RPCellViewBehind?
    
    var behindViewOffSet : CGFloat = 0.0
    
    var frontView : UIView?
    
    var lastMovement = TimeInterval(0)
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
        
        behindView =  Bundle.main.loadNibNamed("cellViewBehind", owner: self, options: nil)?.last as? RPCellViewBehind
        frontView = self.contentView.subviews[0] as? UIView
        behindView?.isHidden = true
        
        self.contentView.insertSubview(behindView!, belowSubview: frontView!)
        
        

        //add actions on buttons
        //TODO
        behindView?.buttonLeft?.addTarget(self, action: #selector(RPSwipableTVCell.buttonLeftPressed), for: UIControlEvents.touchUpInside)
        behindView?.buttonCenterLeft?.addTarget(self, action: #selector(RPSwipableTVCell.buttonCenterLeftPressed), for: UIControlEvents.touchUpInside)
        behindView?.buttonCenterRight?.addTarget(self, action: #selector(RPSwipableTVCell.buttonCenterRightPressed), for: UIControlEvents.touchUpInside)
        behindView?.buttonRight?.addTarget(self, action: #selector(RPSwipableTVCell.buttonRightPressed), for: UIControlEvents.touchUpInside)
    }
    
    
    override func prepareForReuse() {
        //super.prepareForReuse()
        frontView?.frame = self.contentView.frame
        behindView?.isHidden = true
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
                if(bv.isHidden){
                    bv.frame = self.contentView.frame
                    frontView?.frame = self.contentView.frame
                }
                else {
                    let newFrame = CGRect(
                        x: -frame.size.width + self.behindViewOffSet,
                        y: contentView.frame.origin.y,
                        width: contentView.frame.size.width,
                        height: contentView.frame.size.height)
                    bv.frame = self.contentView.frame
                    frontView?.frame = newFrame
                }
            }
            
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(RPSwipableTVCell.paning(_:)))
            pan.delegate = self
            
            self.addGestureRecognizer(pan)
        }
        else {
            NSException(name: NSExceptionName(rawValue: "Error RPSwipableTVCell"), reason: "Can't find enough views. Check that you have in the custom cell: a view over the content view. You have to add UI element in that view", userInfo: nil).raise()
        }
        
        super.layoutSubviews()
    }
    
    
    //############################################################################
    //############################################################################
    //MARK : Gesture stuff
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
//        if(gestureRecognizer.isMember(of: UIPanGestureRecognizer)){
        
            //Pan is swiping the cell.
            //only activate it if the velocity of the pan is above a threshold
            
            let velocity = pan.velocity(in: self.contentView)
            
            if(abs(velocity.y) / abs(velocity.x) > 1/4){
                return false
            }
        }
        else {
            if let view = behindView {
                let viewInside = (self.contentView.window!).subviews[0] 
                //var eventToTest = UIEvent()
                
                if(view.point(inside: gestureRecognizer.location(in: viewInside), with: nil)){
                    return false
                }
            }

        }

        return true
    }
    
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)-> Bool {
        return false
    }
    
    func paning(_ pan : UIPanGestureRecognizer) {
        
        if(pan.state == UIGestureRecognizerState.began){
            behindView?.isHidden = false
            if let fv = frontView {
                let frontViewPositionX = fv.frame.origin.x
                let touchPositionX = pan.location(in: self.contentView).x
                
                touchOffSet = Double(frontViewPositionX) - Double(touchPositionX)
                behindView?.isHidden = false
            }
        }
        else if (pan.state == UIGestureRecognizerState.changed) {
            panMoved(pan)
        }
        else if(pan.state == UIGestureRecognizerState.ended) {
            panEnded(pan)
        }
    }
    
    
    /**The cell is being swiped currently*/
    func panMoved(_ pan : UIGestureRecognizer) {
        
        self.selectionStyle = UITableViewCellSelectionStyle.none

        
        let touchPositionX = pan.location(in: self.contentView).x
        var touchPositionCorrectedX = touchPositionX + CGFloat(touchOffSet)
        
        if(touchPositionCorrectedX > 0){
            touchPositionCorrectedX = log2(touchPositionCorrectedX)
        }
        else if(touchPositionCorrectedX < (-1 * contentView.frame.size.width + behindViewOffSet)) {
            touchPositionCorrectedX = (-1 * contentView.frame.size.width + behindViewOffSet) - log2(abs(touchPositionCorrectedX + contentView.frame.size.width - behindViewOffSet))
        }
        
        
        let newFrame = CGRect(x: touchPositionCorrectedX,
            y: contentView.frame.origin.y,
            width: contentView.frame.width,
            height: contentView.frame.size.height)
        
        frontView?.frame = newFrame
        
    }
    
    
    /**The cell swiping has ended*/
    func panEnded(_ pan : UIPanGestureRecognizer) {
        
        if let fv = frontView{
            let speedUpConstant = CGFloat(1.1)
            
            let frontViewXPosition = fv.frame.origin.x
            
            let velocity = pan.velocity(in: self.contentView).x
            
            if(velocity > 0) {
                //velocity < 0 -> last movement went to the right (cell become closed)
                
                var neededTime = TimeInterval((contentView.frame.size.width - frontViewXPosition) / velocity * speedUpConstant)
                
                if(neededTime > MAX_CELL_ANIMATION_DURATION){
                    neededTime = MAX_CELL_ANIMATION_DURATION
                }

                
                //animated the cell so it continue to be "swiped" and hide completely what is behind
                UIView.animate(withDuration: neededTime, delay: 0, options: UIViewAnimationOptions.curveEaseOut,
                    animations: {() -> Void in
                        fv.frame = self.contentView.frame
                    },
                    completion:{(c : Bool) -> Void in
                        if(c){
                            self.behindView?.isHidden = true
                        }
                })
                
                

            }
            else {
                //velocity > 0 -> last movement went to the left
                
                var neededTime = (contentView.frame.size.width - frontViewXPosition) / velocity * speedUpConstant
                
                if(neededTime > CGFloat(MAX_CELL_ANIMATION_DURATION)){
                    neededTime = CGFloat(MAX_CELL_ANIMATION_DURATION)
                }
                
                //animated the cell so it continue to be "swiped" and show completely what is behind
                UIView.animate(withDuration: TimeInterval(neededTime), delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                    let frame = self.contentView.frame
                    
                    let newFrame = CGRect(
                        x: -frame.size.width + self.behindViewOffSet,
                        y: frame.origin.y,
                        width: frame.size.width,
                        height: frame.size.height)
                    fv.frame = newFrame
                    }, completion: nil)
            }
        }
    }

    //############################################################################################
    //############################################################################################
    
    //UITableViewCell stuff
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    /**Show the view "behind the cell". (Show the buttons) */
    func hideBehindCell(){
        
        if let fv = frontView{
            let neededTime = MAX_CELL_ANIMATION_DURATION
            
            UIView.animate(withDuration: neededTime, delay: 0, options: UIViewAnimationOptions.curveEaseOut,
                animations: {() -> Void in
                    fv.frame = self.contentView.frame
                },
                completion:{(c : Bool) -> Void in
                    if(c){
                        self.behindView?.isHidden = true
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
