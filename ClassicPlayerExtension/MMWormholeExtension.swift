//
//  MMWormholeExtension.swift
//  ClassicPlayer
//
//  Created by Jonathan Duss on 18.12.16.
//  Copyright © 2016 Jonathan Duss. All rights reserved.
//

import Foundation
import MMWormhole



extension MMWormhole {
    
    
    func passMessage(string: String, identifier: String) {
        self.passMessageObject(NSString(string: string), identifier: identifier)
    }
}
