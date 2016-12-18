//
//  MMWormholeExtension.swift
//  ClassicPlayer
//
//  Created by Jonathan Duss on 18.12.16.
//  Copyright © 2016 Jonathan Duss. All rights reserved.
//

import Foundation
import MMWormhole


enum RPNotification : String {
    case SALUT = "salut"
}

extension MMWormhole {
    
    
    func passMessageObject(notification: RPNotification, identifier: String) {
        self.passMessageObject(notification.rawValue as NSCoding?, identifier: identifier)
    }
}
