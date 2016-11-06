//
//  RateView.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 23.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit


protocol RateViewDelegate {
    func rateView(_ rateView : RateView, ratingDidChange rating : Float)
}

public class RateView: UIView {
    
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
    let minImageSize : CGSize  = CGSize(width: 5, height: 5)
    var delegate : RateViewDelegate?
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
override     
    init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**setup the rateview images and maximum rating*/
    func setupRateView(_ fullStarImage : UIImage, halfStarImage : UIImage, emptyStarImage : UIImage, maxRating : Int) {
        self.fullStarImage = fullStarImage
        self.halfStarImage = halfStarImage
        self.emptyStarImage = emptyStarImage
        self.maxRating = maxRating
        initImageViews()
        refresh()
    }
    
    /**setup the rateview images and maximum rating*/
    func setupRateView(_ fullStarImage : UIImage, emptyStarImage : UIImage, maxRating : Int) {
        self.fullStarImage = fullStarImage
        self.emptyStarImage = emptyStarImage
        self.maxRating = maxRating
        initImageViews()
        refresh()
    }
    
    /**Called to create the correct number of ImageView for each star (= maxRating)*/
    func initImageViews() {
        for _ in (1 ... maxRating) {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - view update and layout
    
    /**Refresh the view*/
    func refresh() {
        for i in (0 ..< self.imageViews.count) {
            let idx = Float(i)
            let imageView = imageViews[Int(idx)]
            if(rating >= idx + 1.0) {
                imageView.image = fullStarImage
            }
            else if (halfStarImage == nil && rating > idx) {
                if(rating >= idx + 0.5) {
                    imageView.image = fullStarImage
                }
                else {
                    imageView.image = emptyStarImage
                }
            }
            else if (halfStarImage != nil && rating > idx) {
                imageView.image = halfStarImage
            }
            else {
                imageView.image = emptyStarImage
            }
        }
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        let desiredImageWith = (self.frame.size.width - leftMargin*2 - midMargin*CGFloat(imageViews.count)) / CGFloat(imageViews.count)
        
        let imageWidth = max(minImageSize.width, desiredImageWith)
        let imageHeight = max(minImageSize.height, self.frame.size.height)
        
        for i in (0 ..< imageViews.count) {
            let imageView = imageViews[i]
            let imageFrame = CGRect(x: leftMargin + CGFloat(i)*(midMargin + imageWidth), y: 0, width: imageWidth, height: imageHeight)
            imageView.frame = imageFrame
        }
        
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - touch events
    
    func handleTouchAtLocation(_ touchLocation : CGPoint) {
        if(editable) {
            var newRating: Float = 0
            for i in (0 ..< imageViews.count).reversed()  {//(var i = imageViews.count - 1; i >= 0; i -= 1) {
                if(touchLocation.x > imageViews[i].frame.origin.x) {
                    newRating = Float(i) + 1.0
                    break
                }
            }
            rating = newRating
            refresh()
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            handleTouchAtLocation(touchLocation)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            handleTouchAtLocation(touchLocation)
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.rateView(self, ratingDidChange: rating)
    }

}
