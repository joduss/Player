//
//  RPSwipableCell.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 02.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit

class RPCell: RPSwipableTVCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
