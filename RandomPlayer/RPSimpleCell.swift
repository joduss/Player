//
//  RPSimpleCellTableViewCell.swift
//  RandomPlayer
//
//  Created by Jonathan on 13.11.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit

class RPSimpleCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
//    func setColor(color : UIColor){
//        let v = self.contentView.subviews[0] as UIView
//        v.backgroundColor = color
//    }

}
