//
//  SongActionSheetDelegate.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 11.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class SongActionSheetDelegate: NSObject, UIActionSheetDelegate {
    
    var song : MPMediaItem?
    
    override init() {
        super.init()
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        
        if let item = song{
            var itemArray : Array<MPMediaItem> = Array()
            itemArray.append(item)
            
            switch(buttonIndex){
            case 1:
                RPPlayer.player.addNext(itemArray)
            case 2:
                RPPlayer.player.addNextAndPlay(itemArray)
            case 3:
                RPPlayer.player.addSongs(itemArray)
            default:
                //Cancel
                return
            }
        }
    }
}
