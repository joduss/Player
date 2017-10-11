//
//  ArrayExtension.swift
//  ClassicPlayer
//
//  Created by Jonathan Duss on 11.10.17.
//  Copyright © 2017 Jonathan Duss. All rights reserved.
//

import Foundation


//Extension of Array type
//add a function that shuffle the array
extension Array {
    ///Shuffle the array
    func shuffleArray()->Array {
        var arr = self
        let c = arr.count
        for i in 0..<(c-1) {
            let j = Int(arc4random_uniform(UInt32(c)))
            if i != j {
                arr.swapAt(i, j)
            }
        }
        return arr
    }
}
