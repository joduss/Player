//
//  RPQueue.swift
//  RandomPlayer
//
//  Created by Jonathan on 19.03.15.
//  Copyright (c) 2015 Jonathan Duss. All rights reserved.
//

import Foundation
import MediaPlayer




/*******************************************************************************************/
// Queue implementation with custom operation
/*******************************************************************************************/


infix operator +=

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
/**This class implements a queue*/
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
    subscript(index: Int) -> MPMediaItem? {
        get {
            
            //check that exist. If not, take the next, until queue is empty
            return mediaItem(songID: queue[index])
        }
        set(newValue) {
            if let newVal = newValue{
                queue[index] = newVal.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber
            }
        }
    }
    
    var isEmpty : Bool {
        get{
            return queue.isEmpty
        }
    }
    


    func append(_ song : MPMediaItem){
        queue.append(mediaItemId(of: song))
    }
    
    func append(_ songs : Array<NSNumber>){
        queue += songs
    }
    
    
    func contains(song: MPMediaItem) -> Bool {
        return queue.contains(mediaItemId(of: song))
    }
    
    func indexOf(song : MPMediaItem) -> Int? {
        return queue.index(of: mediaItemId(of: song))
    }
    
    func removeAtIndex(_ index : Int){
        queue.remove(at: index)
    }
    

    
    func insert(_ item : MPMediaItem , atIndex index : Int){
        queue.insert(mediaItemId(of: item), at: index)
    }
    
    func insert(_ itemsArray : Array<MPMediaItem> ,atIndex index : Int){
        var queueTemp : Array<NSNumber> = Array();
        let items = mediaItemsId(of: itemsArray)
        
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
    func removeAll(keepingCapacity : Bool){
        queue.removeAll(keepingCapacity: keepingCapacity)
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
    
    
    /** 
    Remove songs that have been deleted in sync
     */
    func cleanQueue() {
        
//        for s in queue {
//            if(mediaItem(songID: s) != nil) {
//                filteredQueue.append(s)
//            }
//        }
        
        queue = queue.filter({id in mediaItem(songID: id) != nil})
        
    }
    
    func shuffleArray(){
        queue = queue.shuffleArray()
    }
    
    // TODO: optimization to be less expensive
    /**Randomize song and try to separate song from a same artist to have a better distribution*/
    func randomizeQueueAdvanced() {
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)

        //first clean queue
        cleanQueue()
        
        var newQueue : Array<NSNumber> = Array()
        newQueue.reserveCapacity(queue.count)
        
        var artistSongPosition : Dictionary<String, Array<Int>> = Dictionary() //positions of all songs for a given artist that are in the queue
        var artistList : Array<String> = Array() //For each song at position i, it put at index i the artist of that song
        artistList.reserveCapacity(queue.count)
        
        for i in (queue.indices.suffix(from: 0)) {
            let item = queue[i]
            let artist = mediaItem(songID: item)!.artistFormatted()
            
            artistList.append(artist)
            
            if var position = artistSongPosition[artist] {
                position.append(i)
                artistSongPosition[artist] = position
                
            } else {
                //if artist neven has been seen, add an empty are for position for him
                artistSongPosition[artist] = Array()
                var position = artistSongPosition[artist]!
                position.append(i)
                artistSongPosition[artist] = position
            }
        }
        
        //shuffle and try to do so that no song of the same artist are following each other
        let artistOfEachSongShuffled = shuffleAndSeparateSimilarElement(of: artistList)
        //printArray(artistOfEachSongShuffled)
        
        //Shuffle the index of the array listing the songs position for all artists
        for tuple in artistSongPosition {
            let positions = tuple.1 as Array<Int>
            artistSongPosition[tuple.0] = positions.shuffleArray()
        }
        
        //recreate a new queue that has been randomized
        for artist in artistOfEachSongShuffled {
            if var positions = artistSongPosition[artist] {
                newQueue.append(queue[positions[0]])
                positions.remove(at: 0)
                artistSongPosition[artist] = positions
                if(positions.isEmpty){
                    artistSongPosition.removeValue(forKey: artist)
                }
            }
            
        }
        
        queue = newQueue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
            //.postNotificationName(RPPlayerNotification.QueueDidChange, object: nil)
    }
    
    
    
    /**
    The mediaItem corresponding to songID.
    - parameters:
        - songID: the id of the song to retrieve
    - returns: the song
    */
    func mediaItem(songID : NSNumber) -> MPMediaItem?{
        //TODO: support case when song not exist anymore: remove from queue and return next one
        //also notify RPPlayer
        
        
        //let predicate = MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: MPMediaPredicateComparison.EqualTo)
        let songQuery = MPMediaQuery.songs()
        //songQuery.addFilterPredicate(predicate)
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: MPMediaPredicateComparison.equalTo))

        if(songQuery.items!.count == 1){
            //return songQuery.items[0] as MPMediaItem
            return songQuery.items![0] 
        }
        return nil
    }
    
    /**
    Return the media item ID
     */
    func mediaItemId(of item: MPMediaItem) -> NSNumber{
        return item.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber
    }
    
    func mediaItemsId(of items : Array<MPMediaItem>) -> Array<NSNumber>{
        var arrayOfId = Array<NSNumber>()
        for item in items{
            arrayOfId.append(mediaItemId(of: item))
        }
        return arrayOfId
    }
    
}




