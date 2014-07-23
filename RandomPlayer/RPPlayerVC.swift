//
//  RPPlayerVCViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//



import UIKit
import MediaPlayer

class RPPlayerVC: UIViewController {
    
    @IBOutlet var labelLeftPlaybackTime: UILabel!
    @IBOutlet var sliderTime: UISlider!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelArtistAlbum: UILabel!
    @IBOutlet var viewRating: UIView!
    @IBOutlet var imageViewArtwork: UIImageView!
    @IBOutlet var buttonPlay: UIButton!
    @IBOutlet var labelCurrentPlaybackTime: UILabel!
    
    var timer : NSTimer?
    let musicPlayer : MPMusicPlayerController
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Initialization
    
    init(coder aDecoder: NSCoder!) {
        musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        
        //setup the slider action
        sliderTime.addTarget(self, action:"sliderPlaybackTimeMoved:", forControlEvents: UIControlEvents.ValueChanged)
        sliderTime.addTarget(self, action:"sliderPlaybackTimeMoved:", forControlEvents: UIControlEvents.TouchDown)
        sliderTime.addTarget(self, action: "sliderPlaybackStoppedTimeMoving:", forControlEvents: UIControlEvents.TouchUpInside)
        sliderTime.addTarget(self, action: "sliderPlaybackStoppedTimeMoving:", forControlEvents: UIControlEvents.TouchUpOutside)
        
        
        //custom UI
        sliderTime.setThumbImage(UIImage(named: "slider_empty",inBundle: nil, compatibleWithTraitCollection: UITraitCollection()), forState: UIControlState.Normal)
        sliderTime.setThumbImage(UIImage(named: "thumb",inBundle: nil, compatibleWithTraitCollection: UITraitCollection()), forState: UIControlState.Highlighted)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //if no queue: slider is disabled
        if(musicPlayer.nowPlayingItem == nil){
            sliderTime.enabled = false
        }
        else {
            sliderTime.enabled = true
        }
        updateInformation()
        subscribePlaybackNotifications()
        updatePlaybackSlider(nil)
        createTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribePlaybackNotifications()
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - buttons function
    
    @IBAction func playStopButtonClicked(sender: AnyObject) {
        if(musicPlayer.playbackState == MPMusicPlaybackState.Playing) {
            //is playing, so we stop the player
            musicPlayer.pause()
        }
        else {
            musicPlayer.play()
        }
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        musicPlayer.skipToNextItem()
    }
    
    @IBAction func previousButtonClicked(sender: UIButton) {
        let currentPlayBackTimeThreshold = 5 as NSTimeInterval //time from which previous start the song again
        if(musicPlayer.currentPlaybackTime < currentPlayBackTimeThreshold) {
            musicPlayer.skipToPreviousItem()
        }
        else {
            musicPlayer.skipToBeginning()
        }
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - slider management
    func sliderPlaybackTimeMoved(slider : UISlider) {
        timer?.invalidate()
        let sliderValueInt = Int(slider.value)
        let sliderValueIntLeft = Int(slider.maximumValue - slider.value)
        elprint("slider time moved at \(sliderValueInt) = \(formatTimeToMinutesSeconds(sliderValueInt)), and left \(formatTimeToMinutesSeconds(sliderValueIntLeft))")
        musicPlayer.currentPlaybackTime = NSTimeInterval(slider.value)
        labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueInt)
        labelLeftPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueIntLeft)
        
    }
    
    func sliderPlaybackStoppedTimeMoving(slider : UISlider) {
        elprint("slider time stop moving at \(slider.value)")
        createTimer()
    }
    
    func updatePlaybackSlider(timer : NSTimer?) {
        sliderTime.value = Float(musicPlayer.currentPlaybackTime)
        labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(Int(musicPlayer.currentPlaybackTime))
        labelLeftPlaybackTime.text = formatTimeToMinutesSeconds(Int(musicPlayer.nowPlayingItem.playbackDuration - musicPlayer.currentPlaybackTime))
        
        // LOL
//        UIView.animateKeyframesWithDuration(1, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
//            self.imageViewArtwork.transform = CGAffineTransformRotate(self.imageViewArtwork.transform, CGFloat(M_PI / 30))
//            }, completion: nil)
        
    }
    
    func createTimer(){
        timer?.invalidate() //to be sure there is only 1 slider
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatePlaybackSlider:", userInfo: nil, repeats: true)
        updateInformation()
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - update information
    func updateInformation() {
        if(musicPlayer.playbackState == MPMusicPlaybackState.Playing) {
            buttonPlay.setTitle("PAUSE", forState: UIControlState.Normal)
        }
        else {
            buttonPlay.setTitle("PLAY", forState: UIControlState.Normal)
        }
        
        let playingSong = musicPlayer.nowPlayingItem as MPMediaItem?
        
        if let song = playingSong {
            //set artwork
            let artworkItem = song.valueForProperty(MPMediaItemPropertyArtwork) as MPMediaItemArtwork
            imageViewArtwork.image = artworkItem.imageWithSize(imageViewArtwork.bounds.size)
            
            //information about the song
            labelTitle.text = song.valueForProperty(MPMediaItemPropertyTitle) as String
            labelArtistAlbum.text = (song.valueForProperty(MPMediaItemPropertyArtist) as String)
                + " - "
                + (song.valueForProperty(MPMediaItemPropertyAlbumTitle) as String)
            
            //slider max value
            sliderTime.maximumValue = Float(song.valueForProperty(MPMediaItemPropertyPlaybackDuration) as NSNumber)
        }
        else
        {
            // TODO
        }
    }
    
    //########################################################################
    //########################################################################
    // #pragma mark - notification subscription methods
    func subscribePlaybackNotifications() {
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        //be notified when the playing song changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInformation", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInformation", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: nil)
    }
    
    func unsubscribePlaybackNotifications() {
        musicPlayer.endGeneratingPlaybackNotifications()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
