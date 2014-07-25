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
    
    
    var AVMusicPlayer : AVPlayer = AVPlayer()

    
    
    // COMPUTED VARIABLE
    
    //currently playing item
    var nowPlayingItem : MPMediaItem? {
    get {
        if(queue.count > 0){
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
        else if(AVMusicPlayer.rate > 0 && AVMusicPlayer.status != AVPlayerStatus.Failed) {
            return MPMusicPlaybackState.Playing
        }
        else if(AVMusicPlayer.rate == 0 && AVMusicPlayer.status != AVPlayerStatus.Failed){
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
        //return AVMusicPlayer.currentTime()
        return CMTimeGetSeconds(AVMusicPlayer.currentTime())
    }
    set {
        AVMusicPlayer.seekToTime(CMTimeMakeWithSeconds(newValue, 1))
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
            
            
            
            
            self.AVMusicPlayer = AVPlayer(playerItem: item)
            
            
            while((self.AVMusicPlayer.status == AVPlayerStatus.ReadyToPlay) == false &&  (item.status == AVPlayerItemStatus.ReadyToPlay) == false){
                dprint("\(self.AVMusicPlayer.status == AVPlayerStatus.ReadyToPlay)")
                dprint("\(item.status == AVPlayerItemStatus.ReadyToPlay)")
            }
            
            
            self.AVMusicPlayer.play()
            
            
            })

        
        updateNowPlayingInfoCenter()
    }
    
    
    /**Update information displayed on lock screen and control center*/
    func updateNowPlayingInfoCenter() {
        
        
        
        var d : [String : AnyObject!] = Dictionary()
        d[MPMediaItemPropertyArtist] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtist)
        d[MPMediaItemPropertyAlbumTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyAlbumTitle)
        d[MPMediaItemPropertyTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyTitle)
        d[MPMediaItemPropertyArtwork] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtwork) as MPMediaItemArtwork?
        
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = d
    }

    //########################################################################
    //########################################################################
    // #pragma mark - playback management
    
    func skipToNextItem() {
        // TODO
        /**warning - no implemented*/
        playSong(nextSong()!)
        
        //Take care if no new song
    }
    
    func skipToPreviousItem() {
        //TODO
        /**warning - no implemented*/
        playSong(previousSong()!)
        //take care if no previous song
    }
    
    func pause() {
        AVMusicPlayer.pause()
    }
    
    func play() {
        if(queue.count > 0 && AVMusicPlayer.currentItem == nil){
            //if queue is not empty and currentItem is nil in player, we load one.
            playSong(nowPlayingItem!)
        }
        AVMusicPlayer.play()
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
        
        if let index = indexPlayingItemInQueue() {
            queueTemp += queue[0...index]
            queueTemp += songs
            queueTemp += queue[(index + 1)...(queue.endIndex - 1)] //-1 as it gives the index that ends the array (and that is nil), not index of last element
        }
        else {
            queueTemp += songs
            queueTemp += queue
        }
        
        
        queue = queueTemp
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: queue))
        
        musicPlayer.shuffleMode = MPMusicShuffleMode.Off
        
    }
    
    func printSongQueue(a : Array<MPMediaItem>) {
        for item in a {
            dprint("\(item.valueForProperty(MPMediaItemPropertyTitle))  ")
        }
        dprint("\n\n")
    }
    
    func ok() {
        dprint("test")
    }
    
    var time : NSTimer?
    /** Add the songs on top of the queue and start playing the first one*/
    func addNextAndPlay(songs: Array<MPMediaItem>) {
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInformation", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: nil)

        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        if(songs.count > 0) {
            var queueTemp: Array<MPMediaItem> = Array();
            queueTemp += songs
            queueTemp += queue
            queue = queueTemp
            let a = Array(queue[0...0])
            musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: a))
            musicPlayer.shuffleMode = MPMusicShuffleMode.Off
            self.repeatMode = MPMusicRepeatMode.None
        }
        
        musicPlayer.play()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "ok", userInfo: nil, repeats: true)

    }
    
    
    func nextSong() -> MPMediaItem? {
        currentItemIndex++
        if(currentItemIndex < queue.endIndex){
            return queue[currentItemIndex]
        }
        return nil
    }
    
    func previousSong() -> MPMediaItem? {
        currentItemIndex--
        if(currentItemIndex > 0){
            return queue[currentItemIndex]
        }
        return nil
    }
    
    
    /**Empty the queue. Remove anything except the current song playing*/
    func emptyQueue() {
        queue.removeAll(keepCapacity: false)
        musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: queue))
    }
    
    

    

}
