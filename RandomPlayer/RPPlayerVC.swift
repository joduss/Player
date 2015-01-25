//
//  RPPlayerVCViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//



import UIKit
import MediaPlayer

struct s {
    var b = 10
}


class RPPlayerVC: UIViewController, RateViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var labelLeftPlaybackTime: UILabel!
    @IBOutlet var sliderTime: UISlider!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelArtistAlbum: UILabel!
    @IBOutlet var viewRating: RateView!
    @IBOutlet var imageViewArtwork: UIImageView!
    @IBOutlet var buttonPlay: UIButton!
    @IBOutlet var labelCurrentPlaybackTime: UILabel!
    
    var timer : NSTimer?
    let musicPlayer : RPPlayer
    
    @IBOutlet weak var background: UIImageView!
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Initialization
    
    required init(coder aDecoder: NSCoder) {
        musicPlayer = RPPlayer.player
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController.navigationBar.translucent = false
        //navigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        //navigationController.navigationBar.tintColor = UIColor.clearColor()
        //navigationController.navigationBar.backgroundColor = UIColor.clearColor()
        
        //navigationController.barT
        
        
        //setup the slider action
        sliderTime.addTarget(self, action:"sliderPlaybackTimeMoved:", forControlEvents: UIControlEvents.ValueChanged)
        sliderTime.addTarget(self, action:"sliderPlaybackTimeMoved:", forControlEvents: UIControlEvents.TouchDown)
        sliderTime.addTarget(self, action: "sliderPlaybackStoppedTimeMoving:", forControlEvents: UIControlEvents.TouchUpInside)
        sliderTime.addTarget(self, action: "sliderPlaybackStoppedTimeMoving:", forControlEvents: UIControlEvents.TouchUpOutside)
        
        
        //custom UI
        sliderTime.setThumbImage(UIImage(named: "slider_empty",inBundle: nil, compatibleWithTraitCollection: UITraitCollection()), forState: UIControlState.Normal)
        sliderTime.setThumbImage(UIImage(named: "thumb",inBundle: nil, compatibleWithTraitCollection: UITraitCollection()), forState: UIControlState.Highlighted)
        
        let emptyStarImage = UIImage(named: "emptyStar")
        let fullStarImage = UIImage(named: "fullStar")
        
        if(emptyStarImage != nil && fullStarImage != nil){
            viewRating.setupRateView(fullStarImage!, emptyStarImage : emptyStarImage!, maxRating : 5)
        }
        viewRating.editable = true
        viewRating.delegate = self
        
//        if let tarbar = self.tabBarController?.tabBar {
//            tarbar.hidden = true
//        }
        
//        let label = UILabel(frame: CGRectZero)
//        label.textColor = UIColor.whiteColor()
//        label.text = "Salut \n connard"
//        label.numberOfLines = 2
        
        
        
        //self.navigationItem.titleView = label
        //self.navigationItem.titleView.sizeToFit()
        
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.interactivePopGestureRecognizer.enabled = true
        self.navigationController?.interactivePopGestureRecognizer.delegate = self

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
//        if let tarbar = self.tabBarController.tabBar {
//            tarbar.hidden = true
//        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if let tarbar = self.tabBarController.tabBar {
//            tarbar.hidden = true
//        }


        
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
        //TODO HANDLE case of error => create new type: playing, paused, error
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
            musicPlayer.currentPlaybackTime = 0 //go to beginning of the song
        }
    }
    
    @IBAction func repeatPressed(sender: UIBarButtonItem) {
        let action = UIActionSheet(title: "Repeat", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Off", "All", "One")
        
        action.showFromBarButtonItem(sender, animated: true)
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    //########################################################################
    //########################################################################
    // #pragma mark - slider management
    func sliderPlaybackTimeMoved(slider : UISlider) {
        timer?.invalidate()
        let sliderValueInt = Int(slider.value)
        let sliderValueIntLeft = Int(slider.maximumValue - slider.value)
        elprint("slider time moved at \(sliderValueInt) = \(formatTimeToMinutesSeconds(sliderValueInt)), and left \(formatTimeToMinutesSeconds(sliderValueIntLeft))")
        musicPlayer.seekToTime(NSTimeInterval(slider.value))
        labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueInt)
        labelLeftPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueIntLeft)
        
    }
    
    func sliderPlaybackStoppedTimeMoving(slider : UISlider) {
        musicPlayer.currentPlaybackTime = NSTimeInterval(slider.value)
        createTimer()
    }
    
    func updatePlaybackSlider(timer : NSTimer?) {
        
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            
            
            sliderTime.value = Float(musicPlayer.currentPlaybackTime)
            labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(Int(musicPlayer.currentPlaybackTime))
            var playbackDuration = NSTimeInterval(0)
            playbackDuration = nowPlayingItem.playbackDuration
            labelLeftPlaybackTime.text = formatTimeToMinutesSeconds(Int(nowPlayingItem.playbackDuration - musicPlayer.currentPlaybackTime))
        }
        else {
            labelLeftPlaybackTime.text = "00:00"
            sliderTime.value = 0.0
            labelCurrentPlaybackTime.text = "00:00"
        }
        
        
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
            //buttonPlay.setTitle("PAUSE", forState: UIControlState.Normal)
            buttonPlay.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
        else {
            //buttonPlay.setTitle("PLAY", forState: UIControlState.Normal)
            buttonPlay.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        }
        
        let playingSong = musicPlayer.nowPlayingItem as MPMediaItem?
        
        if let song = playingSong {
            //set artwork
            imageViewArtwork.image = song.artworkImage(ofSize:imageViewArtwork.bounds.size)
            background.image = song.artworkImage(ofSize:background.bounds.size)
            
            //information about the song
            labelTitle.text = song.title
            labelArtistAlbum.text = song.artist() + " - " + song.albumTitle()
            
            //slider max value
            sliderTime.maximumValue = Float(song.duration())
            
            
            //rating
            viewRating.rating = Float(song.valueForProperty(MPMediaItemPropertyRating) as Int)
        }
        else
        {
            // TODO
            //hide while view with another to say "no song playing"
            // or make so that the playing is not visible if no song is playing
            imageViewArtwork.image = UIImage(named: "default_artwork")
            labelTitle.text = "NOTHING"
            labelArtistAlbum.text = "NOTHING"
            sliderTime.maximumValue = 300
            
        }
    }
    
    //########################################################################
    //########################################################################
    // #pragma mark - notification subscription methods
    func subscribePlaybackNotifications() {
//        musicPlayer.beginGeneratingPlaybackNotifications()
//        
//        //be notified when the playing song changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInformation", name: RPPlayerNotification.PlaybackStateDidChange , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInformation", name: RPPlayerNotification.SongDidChange, object: nil)
    }
    
    func unsubscribePlaybackNotifications() {
//        musicPlayer.endGeneratingPlaybackNotifications()
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    //########################################################################
    //########################################################################
    // #pragma mark - rateView delegate
    
    func rateView(rateView: RateView, ratingDidChange rating: Float) {
        if let song = musicPlayer.nowPlayingItem {
            elprint("new rating: \(rating)")
            song.setValue(rating, forKey: "rating")
        }
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - UIActionSheet Delegate
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        
        if(buttonIndex == 1){
            lprint("Repeat OFF\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.None
        }
        else if(buttonIndex == 2){
            lprint("Repeat All\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.All
        }
        else if(buttonIndex == 3) {
            lprint("Repeat One\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.One
        }
        else {
            lprint("Cancel changing repeat mode")
        }
    }

    
    
    
    
    
    
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
//        return true
//    }
    
    
}
