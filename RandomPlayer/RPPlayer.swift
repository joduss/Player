//
//  RPQueueManager.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 05.06.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//



import Foundation
import MediaPlayer
import AVFoundation
import CoreMedia


class RPPlayer : NSObject {
    
    
    var queue : Array<MPMediaItem> = Array()
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    var currentItemIndex = 0
    var repeatMode : MPMusicRepeatMode = MPMusicRepeatMode.None
    
    
    var avMusicPlayer : AVPlayer = AVPlayer()
    
    
    
    // COMPUTED VARIABLE
    
    /**currently playing item.
    Returns nil if no item in the queue, or all have been read and repeat is OFF
    NOTE: as soon as there is one item added in the queue, it becomes the now playing item. */
    var nowPlayingItem : MPMediaItem? {
    get {
        if(queue.count > 0 && currentItemIndex >= 0 && currentItemIndex < queue.endIndex){
            return queue[currentItemIndex]
        }
        return nil
    }
    set {
        if let val = newValue {
            if(contains(queue, val)){
                currentItemIndex = find(queue, val)!
                playSong(val)
            }
        }
    }
    }
    
    //playback state
    var playbackState : MPMusicPlaybackState {
    get {
        if(queue.count == 0) {
            return MPMusicPlaybackState.Stopped
        }
        else if(avMusicPlayer.rate > 0 && avMusicPlayer.status != AVPlayerStatus.Failed) {
            return MPMusicPlaybackState.Playing
        }
        else if(avMusicPlayer.rate == 0 && avMusicPlayer.status != AVPlayerStatus.Failed){
            return MPMusicPlaybackState.Paused
        }
        else {
            //In case of error
            return MPMusicPlaybackState.Stopped
        }
    }
    }
    
    var currentPlaybackTime : NSTimeInterval {
    get {
        //return avMusicPlayer.currentTime()
        return CMTimeGetSeconds(avMusicPlayer.currentTime())
    }
    set {
        avMusicPlayer.seekToTime(CMTimeMakeWithSeconds(newValue, 1))
    }
    }
    
    
    
    //Singleton (should be only 1 instance possible). It is thread safe (see internet)
    class var player : RPPlayer{
    struct Static {
        static var instance: RPPlayer?
        static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = RPPlayer()
        }
        
        
        return Static.instance!
    }
    
    init() {
        super.init()
        
        //Allow background
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - forward variable of MPMusicPlayerController
    
    func playSong(song : MPMediaItem) {
        
        let asset = AVURLAsset(URL: song.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL, options: nil)
        // What
        let keyArray = ["tracks", "duration"]
        
        
        //asset.l
        
        
        asset.loadValuesAsynchronouslyForKeys(keyArray, completionHandler: {() -> Void in
            
            let item = AVPlayerItem(asset: asset)
            let duration = item.duration
            
            dprint("duration \(duration)")
            
            
            
            
            self.avMusicPlayer = AVPlayer(playerItem: item)
            
            
            while((self.avMusicPlayer.status == AVPlayerStatus.ReadyToPlay) == false &&  (item.status == AVPlayerItemStatus.ReadyToPlay) == false){
                dprint("\(self.avMusicPlayer.status == AVPlayerStatus.ReadyToPlay)")
                dprint("\(item.status == AVPlayerItemStatus.ReadyToPlay)")
            }
            
            
            self.avMusicPlayer.play()
            
            
            })
    }
    
    /**Remove the playing song from the player, so player.play() won't play anything, it won't play from the last position*/
    func resetPlayer() {
        avMusicPlayer.replaceCurrentItemWithPlayerItem(nil)
    }
    
    
    /**Update information displayed on lock screen and control center*/
    func updateNowPlayingInfoCenter() {
        
        if let song = nowPlayingItem {
            
            var d : [String : AnyObject!] = Dictionary()
            d[MPMediaItemPropertyArtist] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtist)
            d[MPMediaItemPropertyAlbumTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyAlbumTitle)
            d[MPMediaItemPropertyTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyTitle)
            d[MPMediaItemPropertyArtwork] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtwork) as MPMediaItemArtwork?
            
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = d
        }
        else {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        }
    }
    
    //########################################################################
    //########################################################################
    // #pragma mark - playback management
    
    /**Play next item*/
    func skipToNextItem() {
        
        var nextSong : MPMediaItem?
        
        if(repeatMode == MPMusicRepeatMode.One){
            nextSong = queue[currentItemIndex]
        }
        else if((currentItemIndex+1) < queue.endIndex){
            currentItemIndex++
            nextSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex+1) < queue.endIndex && repeatMode == MPMusicRepeatMode.All){
            currentItemIndex = 0
            nextSong = queue[currentItemIndex]
        }
        else {
            //error like queue is empty or other error
            nextSong = nil
            currentItemIndex = 0
        }
        
        
        if let song = nextSong {
            playSong(song)
        }
        else {
            resetPlayer()
        }
        updateNowPlayingInfoCenter()
    }
    
    
    /**Play previous item*/
    func skipToPreviousItem() {
        
        var previousSong : MPMediaItem?
        if(repeatMode == MPMusicRepeatMode.One){
            previousSong = queue[currentItemIndex]
        }
        else if((currentItemIndex-1) > 0){
            currentItemIndex--
            previousSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex+1) < queue.endIndex && repeatMode == MPMusicRepeatMode.All){
            currentItemIndex = queue.endIndex - 1 //end index gives the first element empty in the array
            previousSong = queue[currentItemIndex]
        }
        else {
            //error like queue is empty or other error
            currentItemIndex = 0
            previousSong = nil
        }
        
        
        if let song = previousSong {
            playSong(song)
        }
        else {
            resetPlayer()
        }
        updateNowPlayingInfoCenter()
    }
    
    func pause() {
        avMusicPlayer.pause()
    }
    
    func play() {
        if(queue.count > 0 && avMusicPlayer.currentItem == nil){
            //if queue is not empty and currentItem is nil in player, we load one.
            playSong(nowPlayingItem!)
        }
        avMusicPlayer.play()
        updateNowPlayingInfoCenter()
    }
    
    func stop() {
        //TODO
    }
    
    /** shuffle the queue*/
    func randomizeQueue() {
        //TODO
        /**warning - no implemented*/
        queue = queue.sorted({(_,_) in return arc4random() % 2 == 0})
    }
    
    /** "Randomize" much better*/
    func randomizeQueueAdvanced() {
        //TODO
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)
        /**warning - no implemented*/
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Queue management
    
    func isPlayingFromExternalApp() -> Bool{
        return contains(queue, musicPlayer.nowPlayingItem)
    }
    
    /**Return the index of the nowPlayingItem. return nil if it is not in the queue (in case the queue was made in an external application)*/
    func indexPlayingItemInQueue() -> Int?{
        return find(queue, musicPlayer.nowPlayingItem)
    }
    
    func getQueue() -> Array<MPMediaItem> {
        return Array(queue)
    }
    
    
    
    /**Add the songs at the end of the queue*/
    func addSongs(songs: Array<MPMediaItem>){
        queue += songs
    }
    
    
    /**Add the songs in the queue just after the nowPlayingItem*/
    func addNext(songs: Array<MPMediaItem>) {
        var queueTemp: Array<MPMediaItem> = Array();
        
        let index = currentItemIndex
        
        if(queue.isEmpty == false && currentItemIndex < queue.endIndex){
            queueTemp += queue[0...index]
            queueTemp += songs
            queueTemp += queue[(index + 1)...(queue.endIndex - 1)] //-1 as it gives the index that ends the array (and that is nil), not index of last element
            
        }
        else {
            queueTemp += songs
        }
        queue = queueTemp
    }
    
    
    /** Add the songs on top of the queue and start playing from the first one added*/
    func addNextAndPlay(songs: Array<MPMediaItem>) {
        dprint("hahaha")
        if(queue.isEmpty == false) {
            addNext(songs)
            skipToNextItem()
        }
        else {
            addNext(songs)
        }
        play()
    }
    
    
    
    /**Empty the queue. Remove anything except the current song playing*/
    func emptyQueue(stopAndRemovePlayingItem : Bool) {
        if(stopAndRemovePlayingItem) {
            queue.removeAll(keepCapacity: false)
            resetPlayer()
            //stop, remove the song, so player.play() won't continue to play.
        }
        else if let current = nowPlayingItem {
            queue.removeAll(keepCapacity: false)
            queue += current
        }
        else {
            //should never be the case
            //lprint("ERROR in RPPlayer.EmptyQueue - CASE NOT HANDLED")
            debugAlertView("ERROR in RPPlayer.EmptyQueue - CASE NOT HANDLED")
        }
    }
    
    
    /**Debug function to print the content of the queue*/
    func printSongQueue(a : Array<MPMediaItem>) {
        #if DEBUG
            for item in a {
            dprint("\(item.valueForProperty(MPMediaItemPropertyTitle))  ")
            }
            dprint("\n\n")
        #endif
    }
    
    
    
}
