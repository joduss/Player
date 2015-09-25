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

func +=(queue : RPQueue, items : Array<NSNumber>){
        queue.append(items)
}



/*******************************************************************************************/
// Queue implementation
/*******************************************************************************************/
class RPQueue{

    
    var queue : Array<NSNumber> = Array()

    
    //########################################################################
    //########################################################################
    // #pragma mark - Standard array methods
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
    subscript(index: Int) -> MPMediaItem! {
        get {
            return mediaItem(queue[index])
        }
        set(newValue) {
            if let newVal = newValue{
                queue[index] = newVal.valueForProperty(MPMediaItemPropertyPersistentID) as! NSNumber
            }
        }
    }
    
    var isEmpty : Bool {
        get{
            return queue.isEmpty
        }
    }
    


    func append(song : MPMediaItem){
        queue.append(mediaItemId(song))
    }
    
    func append(songs : Array<NSNumber>){
        queue += songs
    }
    
    
    func containsSong(song: MPMediaItem) -> Bool {
        return queue.contains(mediaItemId(song))
    }
    
    func indexOf(song : MPMediaItem) -> Int? {
        return queue.indexOf(mediaItemId(song))
    }
    
    func removeAtIndex(index : Int){
        queue.removeAtIndex(index)
    }
    
    func shuffleArray(){
        queue = queue.shuffleArray()
    }
    
    func insert(item : MPMediaItem , atIndex index : Int){
        queue.insert(mediaItemId(item), atIndex: index)
    }
    
    func insert(itemsArray : Array<MPMediaItem> ,atIndex index : Int){
        var queueTemp : Array<NSNumber> = Array();
        let items = mediaItemsId(itemsArray)
        
        if(queue.isEmpty == false && index < (queue.endIndex-1)){
            queueTemp += queue[0...index]
            queueTemp += items
            queueTemp += queue[(index + 1)...(queue.endIndex - 1)] //-1 as it gives the index that ends the array (and that is nil), not index of last element
            
        }
        else {
            //case where the last song is playing, or queue is empty
            queueTemp = queue + items
        }
        queue = queueTemp
    }
    
    
    //# : to say keepCapacity keepCapacity
    func removeAll(keepCapacity keepCapacity : Bool){
        queue.removeAll(keepCapacity: keepCapacity)
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - more methods
    
    func getArrayOfId() -> Array<NSNumber>{
//        var arrayOfId = Array<NSNumber>()
//        
//        for item in queue {
//            let id = item.valueForProperty(MPMediaItemPropertyPersistentID) as NSNumber
//            arrayOfId.append(id)
//        }
//        return arrayOfId
        
        return queue
    }
    
    
    
    
    func randomizeQueueAdvanced() {
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)

        var newQueue : Array<NSNumber> = Array()
        newQueue.reserveCapacity(queue.count)
        
        var artistSongPosition : Dictionary<String, Array<Int>> = Dictionary()
        var artistOfEachSong : Array<String> = Array()
        artistOfEachSong.reserveCapacity(queue.count)
        
        for(var i = 0; i < queue.endIndex; i++) {
            let item = queue[i]
            let artist = mediaItem(item).artistFormatted()
            
            artistOfEachSong.append(artist)
            
            if(artistSongPosition.keys.contains(artist)){
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
    
    
    
    func mediaItem(songID : NSNumber) -> MPMediaItem!{
        //TODO: support case when song not exist anymore: remove from queue and return next one
        //also notify RPPlayer
        
        //let predicate = MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: MPMediaPredicateComparison.EqualTo)
        let songQuery = MPMediaQuery.songsQuery()
        //songQuery.addFilterPredicate(predicate)
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: MPMediaPredicateComparison.EqualTo))

        if(songQuery.items!.count == 1){
            //return songQuery.items[0] as MPMediaItem
            return songQuery.items![0] as! MPMediaItem
        }
        return nil
    }
    
    func mediaItemId(item : MPMediaItem) -> NSNumber{
        return item.valueForProperty(MPMediaItemPropertyPersistentID) as! NSNumber
    }
    
    func mediaItemsId(items : Array<MPMediaItem>) -> Array<NSNumber>{
        var arrayOfId = Array<NSNumber>()
        for item in items{
            arrayOfId.append(mediaItemId(item))
        }
        return arrayOfId
    }

    
    
    
}