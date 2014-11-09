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

struct RPPlayerNotification {
    static let SongDidChange = "RPPlayerNotificationSongDidChange"
    static let PlaybackStateDidChange = "RPPlayerNotificationPlaybackStateDidChange"
    static let QueueDidChange = "RPPlayerNotificationQueueDidChange"
    static let Error = "RPPlayerNotificationError"
    
}

class RPPlayer : NSObject {
    
    
    
    var queue : Array<MPMediaItem> = Array()
    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    var currentItemIndex = 0
    var repeatMode : MPMusicRepeatMode
    
    /**Is the current song ended and now is preparing to play the next one?*/
    private var isAutomaticallyTransitioningToNextSong = false
    
    var avMusicPlayer : AVPlayer = AVPlayer()
    
    private var isSeekingTo = false
    
    
    
    
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
                playSong(val, shouldStartPlaying: playbackState == MPMusicPlaybackState.Playing)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.SongDidChange, object: nil)
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
    
    /**Seek to the given time. not precise, but is very fast. Prefer to call this one, when seeking.*/
    func seekToTime(time: NSTimeInterval) {
        
        //TODO IMPROVE SEEKING
        
        if(isSeekingTo == false){
            isSeekingTo = true
            avMusicPlayer.seekToTime(CMTimeMakeWithSeconds(time, 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: {(finished : Bool) -> Void in
                let delayInSeconds = 0.5;
                let d = Int64(delayInSeconds * Double(NSEC_PER_SEC))
                let popTime = dispatch_time(DISPATCH_TIME_NOW, d);
                dispatch_after(popTime, dispatch_get_main_queue(), {() -> Void in
                    //code to be executed on the main queue after delay
                    self.isSeekingTo = false
                    });
                
                })
            
        }
        
        
    }
    
    /**Set the time exactly at this time. Prefer this one, when setting the time only once.*/
    var currentPlaybackTime : NSTimeInterval {
    get {
        return CMTimeGetSeconds(avMusicPlayer.currentTime())
    }
    set {
        avMusicPlayer.seekToTime(CMTimeMakeWithSeconds(newValue, 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        updateNowPlayingInfoCenter()
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
    
    override init() {
        repeatMode = MPMusicRepeatMode.All
        super.init()
        
        //Allow background
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        //Notification song is at end
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "automaticallyTransitionToNextSong", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        //if fail to play song: skip to next one
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "automaticallyTransitionToNextSong", name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        
        
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark -
    
    func playSong(song : MPMediaItem, shouldStartPlaying : Bool) {
        
        let asset = AVURLAsset(URL: song.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL, options: nil)
        // What
        let keyArray = ["tracks", "duration"]
        
        asset.loadValuesAsynchronouslyForKeys(keyArray, completionHandler: {() -> Void in
            
            let item = AVPlayerItem(asset: asset)
            let duration = item.duration
            
            self.avMusicPlayer = AVPlayer(playerItem: item)
            
            
            while((self.avMusicPlayer.status == AVPlayerStatus.ReadyToPlay) == false &&  (item.status == AVPlayerItemStatus.ReadyToPlay) == false){
                //dprint("\(self.avMusicPlayer.status == AVPlayerStatus.ReadyToPlay)")
                //dprint("\(item.status == AVPlayerItemStatus.ReadyToPlay)")
            }
            
            if(shouldStartPlaying || self.isAutomaticallyTransitioningToNextSong) {
                self.avMusicPlayer.play()
                self.isAutomaticallyTransitioningToNextSong = false //transition is over now
            }
            
            //update in main thread for notification
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.SongDidChange, object: nil)
                self.updateNowPlayingInfoCenter()
                })
            
            })
    }
    
    /**Remove the playing song from the player, so player.play() won't play anything, it won't play from the last position*/
    func resetPlayer() {
        if(queue.isEmpty == false){
            // if repeat mode is none, we reload the first song, but don't start to play it.
            playSong(queue[0], shouldStartPlaying: false)
        }
        else {
            avMusicPlayer = AVPlayer()
        }
    }
    
    /**Update information displayed on lock screen and control center*/
    func updateNowPlayingInfoCenter() {
        
        if let song = nowPlayingItem {
            
            var d : [String : AnyObject!] = Dictionary()
            d[MPMediaItemPropertyArtist] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtist)
            d[MPMediaItemPropertyAlbumTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyAlbumTitle)
            d[MPMediaItemPropertyTitle] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyTitle)
            d[MPMediaItemPropertyArtwork] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtwork) as MPMediaItemArtwork?
            d[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(avMusicPlayer.currentTime())
            d[MPMediaItemPropertyPlaybackDuration] = nowPlayingItem?.valueForProperty(MPMediaItemPropertyPlaybackDuration)
            
            
            d[MPNowPlayingInfoPropertyPlaybackRate] = avMusicPlayer.rate
            
            
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = d
        }
        else {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        }
    }
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - playback management
    
    /**Start playing the next song*/
    func automaticallyTransitionToNextSong() {
        isAutomaticallyTransitioningToNextSong = true
        skipToNextItem()
        //avMusicPlayer.play()
    }
    
    /**Skip the current song. The player keep is playbackState. Is playing, then in play the next one. If paused, it goes to the next song, but stay paused*/
    func skipToNextItem() {
        
        var nextSong : MPMediaItem?
        
        if(repeatMode == MPMusicRepeatMode.One){
            nextSong = queue[currentItemIndex]
        }
        else if((currentItemIndex+1) < queue.endIndex){
            currentItemIndex++
            nextSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex+1) >= queue.endIndex && repeatMode == MPMusicRepeatMode.All){
            currentItemIndex = 0
            nextSong = queue[currentItemIndex]
        }
        else {
            //All songs have been played and repeat mode is none.
            //error like queue is empty or other error
            nextSong = nil
            currentItemIndex = 0
        }
        
        
        if let song = nextSong {
            playSong(song, shouldStartPlaying: playbackState == MPMusicPlaybackState.Playing)
        }
        else {
            resetPlayer()
        }
        
    }
    
    
    /**Play previous item*/
    func skipToPreviousItem() {
        
        var previousSong : MPMediaItem?
        if(repeatMode == MPMusicRepeatMode.One){
            previousSong = queue[currentItemIndex]
        }
        else if((currentItemIndex-1) >= 0){
            currentItemIndex--
            previousSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex-1) < 0 && repeatMode == MPMusicRepeatMode.All){
            currentItemIndex = queue.endIndex - 1 //end index gives the first element empty in the array
            previousSong = queue[currentItemIndex]
        }
        else {
            //is first song (thus no previous song) or
            
            //error like queue is empty or other error
            currentItemIndex = 0
            previousSong = nil
        }
        
        
        if let song = previousSong {
            playSong(song, shouldStartPlaying: playbackState == MPMusicPlaybackState.Playing)
        }
        else {
            resetPlayer()
        }
        
        
    }
    
    
    func pause() {
        avMusicPlayer.pause()
        NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.PlaybackStateDidChange, object: nil)
        updateNowPlayingInfoCenter()
        
    }
    
    func play() {
        if(queue.count > 0 && avMusicPlayer.currentItem == nil){
            //if queue is not empty and currentItem is nil in player, we load one.
            playSong(nowPlayingItem!, shouldStartPlaying: true)
            NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.SongDidChange, object: nil)
        }
        avMusicPlayer.play()
        NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.PlaybackStateDidChange, object: nil)
        updateNowPlayingInfoCenter()
    }
    
    
    func playSong(atIndex : Int){
        if(atIndex >= 0 && atIndex < queue.count){
            playSong(queue[atIndex], shouldStartPlaying: true)
            currentItemIndex = atIndex
        }
    }
    
    //    func stop() {
    //        //TODO
    //    }
    
    /** shuffle the queue*/
    func randomizeQueue() {
        queue = queue.shuffleArray()
    }
    
    /** "Randomize" much better. Tries not to put songs of the same artist side by side*/
    func randomizeQueueAdvanced() {
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)
        
        var newQueue : Array<MPMediaItem> = Array()
        
        var artistSongPosition : Dictionary<String, Array<Int>> = Dictionary()
        var artistOfEachSong : Array<String> = Array()
        
        for(var i = 0; i < queue.endIndex; i++) {
            let item = queue[i]
            let artist = item.valueForProperty(MPMediaItemPropertyArtist) as String
            
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
            
        }
  
        
        printArray(artistOfEachSong)
        var artistOfEachSongShuffled = shuffleAndSeparateSimilarElement(artistOfEachSong)
        printArray(artistOfEachSongShuffled)

        for artist in artistOfEachSongShuffled {
            var positions = artistSongPosition[artist]!
            positions = positions.shuffleArray()

            newQueue.append(queue[positions[0]])
            positions.removeAtIndex(0)
            artistSongPosition[artist] = positions
            if(positions.isEmpty){
                artistSongPosition.removeValueForKey(artist)
            }
            
        }
        
        queue = newQueue
        
        
        
//        var artistFrequencyGroup : Dictionary<Int, Array<String>> = Dictionary()
//        
//        for artist in artistFreqKey {
//            let freq = artistFrequency[artist]
//            if(contains(artistFrequencyGroup.keys,freq!)){
//                var artistsInGroup = Array(artistFrequencyGroup[freq!]!)
//                artistsInGroup += artist
//            }
//            else {
//                let newArray: Array<String> = Array
//            }
//        }
        
        
        
        
        
        
        
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Queue management
    
    //    func isPlayingFromExternalApp() -> Bool{
    //        return contains(queue, avMusicPlayer.nowPlayingItem)
    //    }
    
    //    /**Return the index of the nowPlayingItem. return nil if it is not in the queue (in case the queue was made in an external application)*/
    //    func indexPlayingItemInQueue() -> Int?{
    //        return find(queue, avMusicPlayer.nowPlayingItem)
    //    }
    
    func getQueue() -> Array<MPMediaItem> {
        return Array(queue)
    }
    
    func getQueueItem(atIndex : Int) -> MPMediaItem?{
        if(queue.isEmpty){
            return nil
        }
        return queue[atIndex]
    }
    
    func removeItemAtIndex(index : Int) {
        if(index >= 0 && queue.isEmpty == false && index < queue.endIndex){
            queue.removeAtIndex(index)
        }
    }
    
    
    
    /**Add the songs at the end of the queue*/
    func addSongs(songs: Array<MPMediaItem>){
        queue += songs
    }
    
    
    /**Add the songs in the queue just after the nowPlayingItem*/
    func addNext(songs: Array<MPMediaItem>) {
        var queueTemp: Array<MPMediaItem> = Array();
        
        let index = currentItemIndex
        
        if(queue.isEmpty == false && currentItemIndex < (queue.endIndex-1)){
            queueTemp += queue[0...index]
            queueTemp += songs
            queueTemp += queue[(index + 1)...(queue.endIndex - 1)] //-1 as it gives the index that ends the array (and that is nil), not index of last element
            
        }
        else {
            //case where the last song is playing, or queue is empty
            queueTemp = queue + songs
        }
        queue = queueTemp
    }
    
    
    /** Add the songs on top of the queue and start playing from the first one added*/
    func addNextAndPlay(songs: Array<MPMediaItem>) {
        if(queue.isEmpty == false) {
            addNext(songs)
            skipToNextItem()
        }
        else {
            addNext(songs)
        }
        if(songs.isEmpty == false){
            playSong(songs[0], shouldStartPlaying: true)
        }
    }
    
    
    
    /**Empty the queue. Remove anything except the current song playing*/
    func emptyQueue(stopAndRemovePlayingItem : Bool) {
        if(stopAndRemovePlayingItem) {
            queue.removeAll(keepCapacity: false)
            resetPlayer()
            NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.PlaybackStateDidChange, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(RPPlayerNotification.SongDidChange, object: nil)
            //stop, remove the song, so player.play() won't continue to play.
        }
        else if let current = nowPlayingItem {
            queue.removeAll(keepCapacity: false)
            queue.append(current)
        }
        else {
            //should never be the case
            //lprint("ERROR in RPPlayer.EmptyQueue - CASE NOT HANDLED")
            queue.removeAll(keepCapacity: false)
        }
        updateNowPlayingInfoCenter()
    }
    
    
    /**Debug function to print the content of the queue*/
    func printSongQueue(a : Array<MPMediaItem>) {
        #if DEBUG
            for item in a {
                print("\(item.valueForProperty(MPMediaItemPropertyTitle))  ")
            }
        #endif
    }
    
    func printArray(a :Array<String>){
        #if DEBUG
            for item in a {
                print("\"\(item) \"")
            }
            println()
        #endif
    }
    
    
    
    
    
    
}
