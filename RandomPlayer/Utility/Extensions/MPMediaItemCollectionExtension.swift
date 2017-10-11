//
//  MediamItemExtension.swift
//  ClassicPlayer
//
//  Created by Jonathan Duss on 11.10.17.
//  Copyright © 2017 Jonathan Duss. All rights reserved.
//

import Foundation
import MediaPlayer


//extension that adds an easy way to have the count of different albums
extension MPMediaItemCollection {
    var albumCount : Int {
        get {
            let query = MPMediaQuery.albums()
            let filterPredicate = MPMediaPropertyPredicate(
                value: representativeItem!.value(forProperty: MPMediaItemPropertyArtistPersistentID),
                forProperty: MPMediaItemPropertyArtistPersistentID)
            query.filterPredicates = Set(arrayLiteral: filterPredicate)
            
            return query.collections!.count
        }
    }
    
    
}
