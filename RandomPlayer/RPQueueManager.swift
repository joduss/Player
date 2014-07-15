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


class RPQueueManagerOC : NSObject{
    
    class func initQueue() -> Bool {
        return RPQueueManager.initQueue()
    }
    
    class func isQueueInitiated() -> Bool {
        return RPQueueManager.isQueueInitiated();
    }
    
    /**Add the songs at the end of the queue*/
    class func addSongs(songs: NSArray) -> Bool {
        return RPQueueManager.addSongs(songs)
    }
    
    /**Add the songs on top of the queue*/
    class func addNext(songs: NSArray) -> Bool {
        return RPQueueManager.addNext(songs)
    }
    
    
    /**Add the songs on top of the queue and start playing the first one*/
    class func addNextAndPlay(songs: NSArray) -> Bool {
        NSLog("%@", songs)
        return RPQueueManager.addNextAndPlay(songs)
    }
    
    /**return the queue in an array of MPMEdiaItem*/
    class func getQueue() -> NSArray? {
        return RPQueueManager.queue
    }
    
    
    
    //Test to get current queue from ipod
    /*class func test() {
    let musicPlayer = MPMusicPlayerController.iPodMusicPlayer()
    
    var dic : NSMutableSet = NSMutableSet()
    //musicPlayer.pause()
    
    for(var i = 0; i < 100; i++){
    var it = musicPlayer.nowPlayingItem
    dic.addObject(it)
    musicPlayer.skipToNextItem()
    println(i)
    }
    
    for(var i = 0; i < 100; i++){
    var it = musicPlayer.nowPlayingItem
    dic.addObject(it)
    musicPlayer.skipToPreviousItem()
    println(it.valueForProperty(MPMediaItemPropertyTitle))
    }
    
    
    }*/
    
}

struct RPQueueManager {
    
    static var queue : NSMutableArray = NSMutableArray()
    
    static func initQueue() -> Bool {
        //        if(queue){
        //            return false
        //        } else {
        //            queue = NSMutableArray()
        //            return true
        //        }
        return true
    }
    
    static func isQueueInitiated() -> Bool {
        return queue == nil
    }
    
    
    
    /**Add the songs at the end of the queue*/
    static func addSongs(songs: NSArray) -> Bool {
        //let musicPlayerApple = MPMusicPlayerController.iPodMusicPlayer()
        let musicPlayer = MPMusicPlayerController.iPodMusicPlayer()//MPMusicPlayerController.applicationMusicPlayer()
        
        initQueue()
        //queue.addObject(musicPlayerApple.nowPlayingItem)
        queue.addObjectsFromArray(songs)
        
        musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items:queue))
        return true
    }
    
    
    /**Add the songs on top of the queue*/
    static func addNext(songs: NSArray) -> Bool {
        var queueTemp: NSMutableArray = NSMutableArray();
        queueTemp.addObjectsFromArray(songs)
        queueTemp.addObjectsFromArray(queue)
        queue = queueTemp
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: queue))
        
        return true
    }
    
    
    /** Add the songs on top of the queue and start playing the first one*/
    static func addNextAndPlay(songs: NSArray) -> Bool {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        if(songs.count > 0) {
            var queueTemp: NSMutableArray = NSMutableArray();
            queueTemp.addObjectsFromArray(songs)
            queueTemp.addObjectsFromArray(queue)
            queue = queueTemp
            musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: queue))
        }

        musicPlayer.play()
        
        return true
    }
    
    
    
    /**Empty the queue. Remove anything except the current song playing*/
    static func emptyQueue() {
        
    }
}



