//
//  RPQueueManager.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 05.06.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//



import Foundation
import coreGraphics
import MediaPlayer


class RPQueueManager : NSObject{
    
    func salut() {
        
    }
    
    class func playSongs(songs: Array<MPMediaItem>) -> Bool {
        return RPQueueManagerSW.playSongs(songs)
    }
    
}

struct RPQueueManagerSW {

    static var queue : MPMediaItemCollection? = nil
    
    
    static func addPlaySongs(songs: Array<MPMediaItem>) -> Bool {
        if(queue) {
            let musicPlayer = MPMusicPlayerController.iPodMusicPlayer();

            return true
        } else {
            return false
        }
    }
    
    static func playSongs(songs: Array<MPMediaItem>) -> Bool {
        println("hello");
        queue = MPMediaItemCollection(items: songs)
        let musicPlayer = MPMusicPlayerController.iPodMusicPlayer()
        musicPlayer.setQueueWithItemCollection(queue)
        musicPlayer.play()
                
        return true
    }
}



