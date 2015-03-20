//
//  RPQueue.swift
//  RandomPlayer
//
//  Created by Jonathan on 19.03.15.
//  Copyright (c) 2015 Jonathan Duss. All rights reserved.
//

import Foundation
import MediaPlayer


infix operator += {

}

func +=(queue : RPQueue, item : MPMediaItem){
    queue.append(item)
}

func +=(queue : RPQueue, items : Array<MPMediaItem>){
    for item  in items {
        queue.append(item)
    }
}


class RPQueue : NSObject{

    
    var queue : Array<MPMediaItem> = Array()

    var count : Int{
        get {
            return queue.count
        }
    }
        
    var endIndex : Int{
        get {
        return queue.endIndex
        }
    }
    
    //Support queue[323] = ...
    subscript(index: Int) -> MPMediaItem {
        get {
            return queue[index]
        }
        set(newValue) {
            queue[index] = newValue
        }
    }
    
    var isEmpty : Bool {
        get{
            return queue.isEmpty
        }
    }
    


    func append(item : MPMediaItem){
        queue.append(item)
    }
    
    
    func containsSong(song: MPMediaItem) -> Bool {
        return contains(queue, song)
    }
    
    func indexOf(song : MPMediaItem) -> Int? {
        return find(queue, song)
    }
    
    func removeAtIndex(index : Int){
        queue.removeAtIndex(index)
    }
    
    func shuffleArray(){
        queue.shuffleArray()
    }
    
    func insert(item : MPMediaItem , atIndex index : Int){
        queue.insert(item, atIndex: index)
    }
    
    func insert(item : Array<MPMediaItem> ,atIndex index : Int){
        var queueTemp : Array<MPMediaItem> = Array();
        
        if(queue.isEmpty == false && index < (queue.endIndex-1)){
            queueTemp += queue[0...index]
            queueTemp += item
            queueTemp += queue[(index + 1)...(queue.endIndex - 1)] //-1 as it gives the index that ends the array (and that is nil), not index of last element
            
        }
        else {
            //case where the last song is playing, or queue is empty
            queueTemp = queue + item
        }
        queue = queueTemp
    }
    
    
    func removeAll(#keepCapacity : Bool){
        queue.removeAll(keepCapacity: keepCapacity)
    }
    
    func getArrayOfId() -> Array<NSNumber>{
        var arrayOfId = Array<NSNumber>()
        
        for item in queue {
            let id = item.valueForProperty(MPMediaItemPropertyPersistentID) as NSNumber
            arrayOfId.append(id)
        }
        return arrayOfId
    }
    
    
    
    
    func randomizeQueueAdvanced() {
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)

        var newQueue : Array<MPMediaItem> = Array()
        newQueue.reserveCapacity(queue.count)
        
        var artistSongPosition : Dictionary<String, Array<Int>> = Dictionary()
        var artistOfEachSong : Array<String> = Array()
        artistOfEachSong.reserveCapacity(queue.count)
        
        for(var i = 0; i < queue.endIndex; i++) {
            let item = queue[i]
            let artist = item.artist()
            
            artistOfEachSong.append(artist)
            
            if(contains(artistSongPosition.keys, artist)){
                var position = artistSongPosition[artist]!
                position.append(i)
                artistSongPosition[artist] = position
                
            } else {
                artistSongPosition[artist] = Array()
                var position = artistSongPosition[artist]!
                position.append(i)
                artistSongPosition[artist] = position
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.QueueDidChange, object: nil)
        }
        
        
        //printArray(artistOfEachSong)
        var artistOfEachSongShuffled = shuffleAndSeparateSimilarElement(artistOfEachSong)
        //printArray(artistOfEachSongShuffled)
        
        for tuple in artistSongPosition {
            let positions = tuple.1 as Array<Int>
            artistSongPosition[tuple.0] = positions.shuffleArray()
        }
        
        for artist in artistOfEachSongShuffled {
            var positions = artistSongPosition[artist]!
            
            newQueue.append(queue[positions[0]])
            positions.removeAtIndex(0)
            artistSongPosition[artist] = positions
            if(positions.isEmpty){
                artistSongPosition.removeValueForKey(artist)
            }
            
        }
        
        queue = newQueue
    }

    
    
    
}