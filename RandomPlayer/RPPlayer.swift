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
import MMWormhole


let NSUSERDEFAULT_RPPLAYER_QUEUE = "NSUSERDEFAULT_RPPLAYER_QUEUE"
let NSUSERDEFAULT_RPPLAYER_QUEUE_INDEX_PLAYING = "NSUSERDEFAULT_RPPLAYER_QUEUE_INDEX_PLAYING"


/*******************************************************************************************/
// Player implementation
/*******************************************************************************************/
/**
 This class is the backend player implementation
 It handles playing, stopping and queue.
* Note: The player is a singleton instance.
*/
class RPPlayer : NSObject {
    
    //Singleton (should be only 1 instance possible). It is thread safe (see internet)
    static let player = RPPlayer()
    
    let MaxTimeToGoPrevious : Double = 7

    
    let extensionCommunication = RPExtensionCommunication()
    
    let queue = RPQueue()
    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    var currentItemIndex = 0
    var repeatMode : MPMusicRepeatMode
    
    /**Is the current song ended and now is preparing to play the next one?*/
    fileprivate var isAutomaticallyTransitioningToNextSong = false
    
    var avMusicPlayer : AVPlayer = AVPlayer()
    
    fileprivate var isSeekingTo = false
    
    
    let wormhole = MMWormhole(applicationGroupIdentifier: RPExtensionCommunication.suiteName, optionalDirectory: "wormhole")
    
    
    
    
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
                if(queue.contains(song: val)){
                    currentItemIndex = queue.indexOf(song: val)!
                    playSong(val, shouldStartPlaying: playbackState == MPMusicPlaybackState.playing)
                }
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.SongDidChange), object: newValue)
        }
    }
    
    //playback state
    var playbackState : MPMusicPlaybackState {
        get {
            if(queue.count == 0) {
                return MPMusicPlaybackState.stopped
            }
            else if(avMusicPlayer.rate > 0 && avMusicPlayer.status != AVPlayerStatus.failed) {
                return MPMusicPlaybackState.playing
            }
            else if(avMusicPlayer.rate == 0 && avMusicPlayer.status != AVPlayerStatus.failed){
                return MPMusicPlaybackState.paused
            }
            else {
                //In case of error
                return MPMusicPlaybackState.stopped
            }
        }
    }
    
    /**Seek to the specified time. Not precise, but is very fast. Prefer to call this one, when seeking.*/
    func seekToTime(_ time: TimeInterval) {
        
        //TODO IMPROVE SEEKING
        
        if(isSeekingTo == false){
            isSeekingTo = true
            avMusicPlayer.seek(to: CMTimeMakeWithSeconds(time, 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: {(finished : Bool) -> Void in
                let delayInSeconds = 0.5;
                let d = Int64(delayInSeconds * Double(NSEC_PER_SEC))
                let popTime = DispatchTime.now() + Double(d) / Double(NSEC_PER_SEC);
                DispatchQueue.main.asyncAfter(deadline: popTime, execute: {() -> Void in
                    //code to be executed on the main queue after delay
                    self.isSeekingTo = false
                });
                
            })
            
        }
        
        
    }
    
    /**Set the time exactly at this time. Prefer this one, when setting the time only once.*/
    var currentPlaybackTime : TimeInterval {
        get {
            dprint("playback time \(avMusicPlayer.currentTime())")
            dprint("playback in sec \(CMTimeGetSeconds(avMusicPlayer.currentTime()))")
            if(avMusicPlayer.currentTime().isNumeric){
                return CMTimeGetSeconds(avMusicPlayer.currentTime())
            }
            return 0.0
        }
        set {
            avMusicPlayer.seek(to: CMTimeMakeWithSeconds(newValue, 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            updateNowPlayingInfoCenter()
        }
    }
    
    
    

    
    override init() {
        repeatMode = MPMusicRepeatMode.all
        super.init()
        
        do {
            //Allow background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        //Notification song is at end
        NotificationCenter.default.addObserver(self, selector: #selector(RPPlayer.automaticallyTransitionToNextSong), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        //if fail to play song: skip to next one
        NotificationCenter.default.addObserver(self, selector: #selector(RPPlayer.automaticallyTransitionToNextSong), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        
    
        self.wormhole.listenForMessage(withIdentifier: RPExtensionCommunication.RPExtensionCommunicationIdentifierRating, listener: {rating in
            //TODO verify track match (in case extreme)
            if let stringRating = rating as? String, let intRating = Int(stringRating) {
                self.ratePlayingSong(rating: intRating)
            }
        })

        
        //load the queue before the app was closed / memory released
        loadQueue()
    }
    
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark -
    
    
    
    /**Remove the playing song from the player, so player.play() won't play anything, it won't play from the last position*/
    func resetPlayer() {
        if(queue.isEmpty == false){
            // if repeat mode is none, we reload the first song, but don't start to play it.
            if let song = queue[0] {
                playSong(song, shouldStartPlaying: false)

            }
            else {
                //play next if first is not anymore on device
                playSong(1)
            }
        }
        else {
            avMusicPlayer = AVPlayer()
        }
    }
    
    /**Update information displayed on lock screen and control center*/
    func updateNowPlayingInfoCenter() {
        
        if let song = nowPlayingItem {
            
            var dicInfoForInfoCenter = [String : Any]()
            dicInfoForInfoCenter[MPMediaItemPropertyArtist] = song.artistFormatted()
            dicInfoForInfoCenter[MPMediaItemPropertyAlbumTitle] = song.albumTitleFormatted()
            dicInfoForInfoCenter[MPMediaItemPropertyTitle] = song.songTitle()
            dicInfoForInfoCenter[MPMediaItemPropertyArtwork] = song.artworkWithDefaultIfNone()
            dicInfoForInfoCenter[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(avMusicPlayer.currentTime())
            dicInfoForInfoCenter[MPMediaItemPropertyPlaybackDuration] = song.duration()
            dicInfoForInfoCenter[MPNowPlayingInfoPropertyPlaybackRate] = avMusicPlayer.rate
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = dicInfoForInfoCenter
            
            lprint("Is playing \"\(nowPlayingItem?.artistFormatted() as String!) - \(nowPlayingItem?.songTitle() as String!)\"" )
        }
        else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            lprint("Is not playing anything" )
        }
        
        
        
        
    }
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - playback management
    
    
    func ratePlayingSong(rating : Int) {
        nowPlayingItem?.setValue(NSNumber(value: rating ), forKey: MPMediaItemPropertyRating)
    }
    
    /**Start playing the next song*/
    func automaticallyTransitionToNextSong() {
        isAutomaticallyTransitioningToNextSong = true
        skipToNextItem()
        //avMusicPlayer.play()
    }
    
    /**Skip the current song. The player keep is playbackState. Is playing, then in play the next one. If paused, it goes to the next song, but stay paused*/
    func skipToNextItem() {
        
        var nextSong : MPMediaItem?
        
        if(repeatMode == MPMusicRepeatMode.one){
            nextSong = queue[currentItemIndex]
        }
        else if((currentItemIndex+1) < queue.endIndex){
            currentItemIndex += 1
            nextSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex+1) >= queue.endIndex && repeatMode == MPMusicRepeatMode.all){
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
            playSong(song, shouldStartPlaying: playbackState == MPMusicPlaybackState.playing)
        }
        else {
            queue.removeAtIndex(currentItemIndex)
            playSong(currentItemIndex)
        }

    }
    
    
    /**Play previous item*/
    func skipToPreviousItem() {
        
        var previousSong : MPMediaItem?
        
        if let seconds = avMusicPlayer.currentItem?.currentTime().seconds, seconds > MaxTimeToGoPrevious{
            avMusicPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            previousSong = queue[currentItemIndex]
        }
        else if(repeatMode == MPMusicRepeatMode.one){
            previousSong = queue[currentItemIndex]
        }
        else if((currentItemIndex-1) >= 0){
            currentItemIndex -= 1
            previousSong = queue[currentItemIndex]
        }
        else if ((currentItemIndex-1) < 0 && repeatMode == MPMusicRepeatMode.all){
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
            playSong(song, shouldStartPlaying: playbackState == MPMusicPlaybackState.playing)
        }
        else {
            queue.removeAtIndex(currentItemIndex)
            playSong(currentItemIndex)
        }
        
        
    }
    
    
    func pause() {
        avMusicPlayer.pause()
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.PlaybackStateDidChange), object: nil)
        updateNowPlayingInfoCenter()
        
    }
    
    func play() {
        if(queue.count > 0 && avMusicPlayer.currentItem == nil){
            //if queue is not empty and currentItem is nil in player, we load one.
            if let song = nowPlayingItem {
                playSong(song, shouldStartPlaying: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.SongDidChange), object: nowPlayingItem)
            } else {
                skipToNextItem()
                play()
            }
        }
        avMusicPlayer.play()
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.PlaybackStateDidChange), object: nil)
        updateNowPlayingInfoCenter()
    }
    
    /**
    Play the song that is at the specified index in the queue
    parameter : atIndex the index of the song in the queue
    */
    func playSong(_ atIndex : Int){
        if(atIndex >= 0 && atIndex < queue.count){
            if let song = queue[atIndex] {
                playSong(song, shouldStartPlaying: true)
                currentItemIndex = atIndex
            } else {
                playSong(atIndex + 1)
            }
        }
    }
    
    func playSong(_ song : MPMediaItem, shouldStartPlaying : Bool) {
        
        let asset = AVURLAsset(url: song.value(forProperty: MPMediaItemPropertyAssetURL) as! URL, options: nil)
        // What
        let keyArray = ["tracks", "duration"]
        
        asset.loadValuesAsynchronously(forKeys: keyArray, completionHandler: {() -> Void in
            
            let item = AVPlayerItem(asset: asset)
            //let duration = item.duration
            
            self.avMusicPlayer = AVPlayer(playerItem: item)
            
            
            while((self.avMusicPlayer.status == AVPlayerStatus.readyToPlay) == false &&  (item.status == AVPlayerItemStatus.readyToPlay) == false){
                //dprint("\(self.avMusicPlayer.status == AVPlayerStatus.ReadyToPlay)")
                //dprint("\(item.status == AVPlayerItemStatus.ReadyToPlay)")
            }
            
            if(shouldStartPlaying || self.isAutomaticallyTransitioningToNextSong) {
                self.avMusicPlayer.play()
                self.isAutomaticallyTransitioningToNextSong = false //transition is over now
            }
            
            //update in main thread for notification
            DispatchQueue.main.sync(execute: {() -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.SongDidChange), object: song)
                self.updateNowPlayingInfoCenter()
            })
            
        })
    }
    
    //    func stop() {
    //        //TODO
    //    }
    
    /** shuffle the queue*/
    func randomizeQueue() {
        let playingItem = queue[currentItemIndex]
        queue.removeAtIndex(currentItemIndex)
        queue.shuffleArray()
        queue.insert(playingItem!, atIndex: 0)
        currentItemIndex = 0
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
    }
    
    /** "Randomize" "much better". Tries not to put songs of the same artist side by side*/
    func randomizeQueueAdvanced() {
        //implement a way so that each song of one artist are far from each other (=> broadcast from DIS???)
        
        let playingItem = queue[currentItemIndex]
        queue.removeAtIndex(currentItemIndex)

        queue.randomizeQueueAdvanced()
        
        queue.insert(playingItem!, atIndex: 0)
        currentItemIndex = 0
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
    
//    func getQueue() -> Array<MPMediaItem> {
//        return queue.getArrayOfId()
//    }
    
    func getQueueItem(_ atIndex : Int) -> MPMediaItem?{
        if(queue.isEmpty){
            return nil
        }
        return queue[atIndex]
    }
    
    /**
    Gives the number of song currently in the queue
    returns number of songs in the queue
    */
    func count()->Int{
        return queue.getArrayOfId().count
    }
    
    func removeItemAtIndex(_ index : Int) {
        if(index >= 0 && queue.isEmpty == false && index < queue.endIndex){
            if(index < currentItemIndex){
                //if remove a song before the current, need to update the index
                currentItemIndex -= 1
            }
            queue.removeAtIndex(index)
            
            //if we remove the playing item, we stop it and start playing the one that
            //is next. Meaning now that this is the one at the currentIndex, replacing
            //the previous playing one that was removed
            if(index == currentItemIndex){
                playSong(index)
            }
        }
    }
    
    
    
    /**Add the songs at the end of the queue*/
    func addSongs(_ songs: Array<MPMediaItem>){
        
        //If it's first element of the queue, then add song to the player, but without starting playing
        if(queue.isEmpty){
            if songs.isEmpty == false {
                playSong(songs[0], shouldStartPlaying: false)
            }
        }
        
        queue += songs
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
    }
    
    
    /**Add the songs in the queue just after the nowPlayingItem*/
    func addNext(_ songs: Array<MPMediaItem>) {
        //If it's first element of the queue, then add song to the player, but without starting playing
        if(queue.isEmpty){
            if songs.isEmpty == false {
                playSong(songs[0], shouldStartPlaying: false)
            }
        }
        
        queue.insert(songs, atIndex: currentItemIndex)
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
    }
    
    
    /** Add the songs at next place of the queue and start playing the first one of the specified array*/
    func addNextAndPlay(_ songs: Array<MPMediaItem>) {
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
    }
    
    
    
    /**
    Empty the Queue
    - parameter stopAndRemovePlayingItem if true, the current playing song will be stopped an removed from the queue
    */
    func emptyQueue(_ stopAndRemovePlayingItem : Bool) {
        if(stopAndRemovePlayingItem) {
            queue.removeAll(keepingCapacity: false)
            resetPlayer()
            NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.PlaybackStateDidChange), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.SongDidChange), object: nil)
            //stop, remove the song, so player.play() won't continue to play.
        }
        else if let current = nowPlayingItem {
            queue.removeAll(keepingCapacity: false)
            queue.append(current)
        }
        else {
            //should never be the case
            //lprint("ERROR in RPPlayer.EmptyQueue - CASE NOT HANDLED")
            queue.removeAll(keepingCapacity: false)
        }
        currentItemIndex = 0
        updateNowPlayingInfoCenter()
        NotificationCenter.default.post(name: Notification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
    }
    
    
    /**Debug function to print the content of the queue*/
    func printSongQueue(_ a : Array<MPMediaItem>) {
        #if DEBUG
            for item in a {
                print("\(item.title)  ", terminator: "")
            }
        #endif
    }
    
    /**Debug function to print the content of an array*/
    func printArray(_ a :Array<String>){
        #if DEBUG
            for item in a {
                print("\"\(item) \"", terminator: "")
            }
            print("")
        #endif
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Queue Backup
    
    func saveQueue(){
        
        let arrayOfId = queue.getArrayOfId()
        
        let data = UserDefaults.standard
        if(queue.count > 0){
            data.set(arrayOfId, forKey: NSUSERDEFAULT_RPPLAYER_QUEUE)
            data.set(currentItemIndex, forKey: NSUSERDEFAULT_RPPLAYER_QUEUE_INDEX_PLAYING)
        }
        else
        {
            data.removeObject(forKey: NSUSERDEFAULT_RPPLAYER_QUEUE)
            data.removeObject(forKey: NSUSERDEFAULT_RPPLAYER_QUEUE_INDEX_PLAYING)
        }
    }
    
    //restore queue from previous session
    func loadQueue(){
        let data = UserDefaults.standard
        
        let storedQueue = data.array(forKey: NSUSERDEFAULT_RPPLAYER_QUEUE) as?  Array<NSNumber>
        
        if let queueToLoad = storedQueue {
            if(queueToLoad.count > 0){
                queue += queueToLoad
                currentItemIndex = data.integer(forKey: NSUSERDEFAULT_RPPLAYER_QUEUE_INDEX_PLAYING)
                if let song = queue[currentItemIndex]{
                    playSong(song, shouldStartPlaying: false)
                }
            }
        }
    }
}
