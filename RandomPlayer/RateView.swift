//
//  RateView.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 23.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//



//protocol RateViewDelegate {
//    func rateView(rateView : RateView, ratingDidChange rating : Float)
//}
import UIKit

class RateView: UIView {
    
    let emptyStarImage : UIImage
    let halfStarImage : UIImage?
    let fullStarImage : UIImage
    var rating : Float = 0.0
    var maxRating : Int = 5
    var editable = false
    var imageViews : Array<UIImageView> = Array()
    var leftMargin : CGFloat = 0.0
    var midMargin : CGFloat = 5.0
    var minSize : CGSize  = CGSizeMake(5, 5)
    //var delegate : RateViewDelegate?
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Init
    
    init(coder aDecoder: NSCoder!, fullStarImage : UIImage, emptyStarImage : UIImage) {
        self.emptyStarImage = emptyStarImage
        self.fullStarImage = fullStarImage
        
        super.init(coder: aDecoder)
    }
    
    init(coder aDecoder: NSCoder!, fullStarImage : UIImage, halfStarImage : UIImage, emptyStarImage : UIImage) {
        self.emptyStarImage = emptyStarImage
        self.fullStarImage = fullStarImage
        self.halfStarImage = halfStarImage
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, fullStarImage : UIImage, emptyStarImage : UIImage) {
        self.emptyStarImage = emptyStarImage
        self.fullStarImage = fullStarImage
        super.init(frame: frame)
    }
    
    init(frame: CGRect, fullStarImage : UIImage, halfStarImage : UIImage, emptyStarImage : UIImage) {
        self.emptyStarImage = emptyStarImage
        self.fullStarImage = fullStarImage
        self.halfStarImage = halfStarImage
        super.init(frame: frame)
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark -
    
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
        self.frame.width
    }
    

}
