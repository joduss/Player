//
//  RateView.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 23.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit


protocol RateViewDelegate {
    func rateView(rateView : RateView, ratingDidChange rating : Float)
}

class RateView: UIView {
    
    var emptyStarImage : UIImage?
    var halfStarImage : UIImage?
    var fullStarImage : UIImage?
    var rating : Float = 0 {
    didSet {
        refresh()
    }
    }
    var maxRating : Int = 0
    var editable = false
    var imageViews : Array<UIImageView> = Array()
    let leftMargin : CGFloat = 0.0
    let midMargin : CGFloat = 5.0
    let minImageSize : CGSize  = CGSizeMake(5, 5)
    var delegate : RateViewDelegate?
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
override     
    init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**setup the rateview images and maximum rating*/
    func setupRateView(fullStarImage : UIImage, halfStarImage : UIImage, emptyStarImage : UIImage, maxRating : Int) {
        self.fullStarImage = fullStarImage
        self.halfStarImage = halfStarImage
        self.emptyStarImage = emptyStarImage
        self.maxRating = maxRating
        initImageViews()
        refresh()
    }
    
    /**setup the rateview images and maximum rating*/
    func setupRateView(fullStarImage : UIImage, emptyStarImage : UIImage, maxRating : Int) {
        self.fullStarImage = fullStarImage
        self.emptyStarImage = emptyStarImage
        self.maxRating = maxRating
        initImageViews()
        refresh()
    }
    
    /**Called to create the correct number of ImageView for each star (= maxRating)*/
    func initImageViews() {
        for(var i = 1; i <= maxRating; i++) {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - view update and layout
    
    /**Refresh the view*/
    func refresh() {
        for( var i: Float = 0; i < Float(self.imageViews.count); i++) {
            let imageView = imageViews[Int(i)]
            if(rating >= i + 1.0) {
                imageView.image = fullStarImage
            }
            else if (halfStarImage == nil && rating > i) {
                if(rating >= i + 0.5) {
                    imageView.image = fullStarImage
                }
                else {
                    imageView.image = emptyStarImage
                }
            }
            else if (halfStarImage != nil && rating > i) {
                imageView.image = halfStarImage
            }
            else {
                imageView.image = emptyStarImage
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let desiredImageWith = (self.frame.size.width - leftMargin*2 - midMargin*CGFloat(imageViews.count)) / CGFloat(imageViews.count)
        
        let imageWidth = max(minImageSize.width, desiredImageWith)
        let imageHeight = max(minImageSize.height, self.frame.size.height)
        
        for(var i = 0; i < imageViews.count; ++i) {
            let imageView = imageViews[i]
            let imageFrame = CGRectMake(leftMargin + CGFloat(i)*(midMargin + imageWidth), 0, imageWidth, imageHeight)
            imageView.frame = imageFrame
        }
        
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - touch events
    
    func handleTouchAtLocation(touchLocation : CGPoint) {
        if(editable) {
            var newRating: Float = 0
            for(var i = imageViews.count - 1; i >= 0; i--) {
                if(touchLocation.x > imageViews[i].frame.origin.x) {
                    newRating = Float(i) + 1.0
                    break
                }
            }
            rating = newRating
            refresh()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            handleTouchAtLocation(touchLocation)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            handleTouchAtLocation(touchLocation)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.rateView(self, ratingDidChange: rating)
    }

}
