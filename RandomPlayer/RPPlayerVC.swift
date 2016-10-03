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
    
    var timer : Timer?
    let musicPlayer : RPPlayer
    
    @IBOutlet weak var background: UIImageView!
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Initialization
    
    required init?(coder aDecoder: NSCoder) {
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
        sliderTime.addTarget(self, action:#selector(RPPlayerVC.sliderPlaybackTimeMoved(_:)), for: UIControlEvents.valueChanged)
        sliderTime.addTarget(self, action:#selector(RPPlayerVC.sliderPlaybackTimeMoved(_:)), for: UIControlEvents.touchDown)
        sliderTime.addTarget(self, action: #selector(RPPlayerVC.sliderPlaybackStoppedTimeMoving(_:)), for: UIControlEvents.touchUpInside)
        sliderTime.addTarget(self, action: #selector(RPPlayerVC.sliderPlaybackStoppedTimeMoving(_:)), for: UIControlEvents.touchUpOutside)
        
        
        //custom UI
        sliderTime.setThumbImage(UIImage(named: "slider_empty",in: nil, compatibleWith: UITraitCollection()), for: UIControlState())
        sliderTime.setThumbImage(UIImage(named: "thumb",in: nil, compatibleWith: UITraitCollection()), for: UIControlState.highlighted)
        
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
        
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        
        
        //Add gesture recognizer on the artwork
        imageViewArtwork.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(RPPlayerVC.imageViewArtworkGesture(_:))))

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
//        if let tarbar = self.tabBarController.tabBar {
//            tarbar.hidden = true
//        }

        self.view.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let tarbar = self.tabBarController.tabBar {
//            tarbar.hidden = true
//        }


        
        //if no queue: slider is disabled
        if(musicPlayer.nowPlayingItem == nil){
            sliderTime.isEnabled = false
        }
        else {
            sliderTime.isEnabled = true
        }
        updateInformation()
        subscribePlaybackNotifications()
        updatePlaybackSlider(nil)
        createTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    @IBAction func playStopButtonClicked(_ sender: AnyObject) {
        if(musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            //is playing, so we stop the player
            musicPlayer.pause()
        }
        else {
            musicPlayer.play()
        }
        //TODO HANDLE case of error => create new type: playing, paused, error
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        musicPlayer.skipToNextItem()
    }
    
    @IBAction func previousButtonClicked(_ sender: UIButton) {
        let currentPlayBackTimeThreshold = 5 as TimeInterval //time from which previous start the song again
        if(musicPlayer.currentPlaybackTime < currentPlayBackTimeThreshold) {
            musicPlayer.skipToPreviousItem()
        }
        else {
            musicPlayer.currentPlaybackTime = 0 //go to beginning of the song
        }
    }
    
    @IBAction func repeatPressed(_ sender: UIBarButtonItem) {
        let action = UIActionSheet(title: "Repeat", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Off", "All", "One")
        
        action.show(from: sender, animated: true)
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    //########################################################################
    //########################################################################
    // #pragma mark - slider management
    func sliderPlaybackTimeMoved(_ slider : UISlider) {
        timer?.invalidate()
        let sliderValueInt = Int(slider.value)
        let sliderValueIntLeft = Int(slider.maximumValue - slider.value)
        elprint("slider time moved at \(sliderValueInt) = \(formatTimeToMinutesSeconds(sliderValueInt)), and left \(formatTimeToMinutesSeconds(sliderValueIntLeft))")
        musicPlayer.seekToTime(TimeInterval(slider.value))
        labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueInt)
        labelLeftPlaybackTime.text = formatTimeToMinutesSeconds(sliderValueIntLeft)
        
    }
    
    func sliderPlaybackStoppedTimeMoving(_ slider : UISlider) {
        musicPlayer.currentPlaybackTime = TimeInterval(slider.value)
        createTimer()
    }
    
    func updatePlaybackSlider(_ timer : Timer?) {
        
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            
            
            sliderTime.value = Float(musicPlayer.currentPlaybackTime)
            dprint("time: \(musicPlayer.currentPlaybackTime)")
            labelCurrentPlaybackTime.text = formatTimeToMinutesSeconds(Int(musicPlayer.currentPlaybackTime))
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RPPlayerVC.updatePlaybackSlider(_:)), userInfo: nil, repeats: true)
        updateInformation()
    }
    
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - update information
    func updateInformation() {
        if(musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            //buttonPlay.setTitle("PAUSE", forState: UIControlState.Normal)
            buttonPlay.setImage(UIImage(named: "pause"), for: UIControlState())
        }
        else {
            //buttonPlay.setTitle("PLAY", forState: UIControlState.Normal)
            buttonPlay.setImage(UIImage(named: "play"), for: UIControlState())
        }
        
        let playingSong = musicPlayer.nowPlayingItem as MPMediaItem?
        
        if let song = playingSong {
            //set artwork
            imageViewArtwork.image = song.artworkImage(ofSize:imageViewArtwork.bounds.size)
            background.image = song.artworkImage(ofSize:background.bounds.size)
            
            //information about the song
            labelTitle.text = song.title
            labelArtistAlbum.text = song.artist! + " - " + song.albumTitle!
            
            //slider max value
            sliderTime.maximumValue = Float(song.duration())
            
            
            //rating
            viewRating.rating = Float(song.value(forProperty: MPMediaItemPropertyRating) as! Int)
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
        NotificationCenter.default.addObserver(self, selector: #selector(RPPlayerVC.updateInformation), name: NSNotification.Name(rawValue: RPPlayerNotification.PlaybackStateDidChange) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RPPlayerVC.updateInformation), name: NSNotification.Name(rawValue: RPPlayerNotification.SongDidChange), object: nil)
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
    
    func rateView(_ rateView: RateView, ratingDidChange rating: Float) {
        if let song = musicPlayer.nowPlayingItem {
            elprint("new rating: \(rating)")
            song.setValue(NSNumber(value: rating ), forKey: MPMediaItemPropertyRating)
            
            
        }
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - UIActionSheet Delegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if(buttonIndex == 1){
            lprint("Repeat OFF\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.none
        }
        else if(buttonIndex == 2){
            lprint("Repeat All\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.all
        }
        else if(buttonIndex == 3) {
            lprint("Repeat One\n\n")
            musicPlayer.repeatMode = MPMusicRepeatMode.one
        }
        else {
            lprint("Cancel changing repeat mode")
        }
    }

    
    
    //########################################################################
    //########################################################################
    // #pragma mark - For gestureRecognizer
    func imageViewArtworkGesture(_ gesture : UISwipeGestureRecognizer) {
        if(gesture.direction == UISwipeGestureRecognizerDirection.down){
            self.dismiss(animated: true, completion: nil)
        }
        else if(gesture.direction == UISwipeGestureRecognizerDirection.left) {
            RPPlayer.player.skipToPreviousItem()
        }
        else if(gesture.direction == UISwipeGestureRecognizerDirection.right){
            RPPlayer.player.skipToNextItem()
        }
    }
    
    
    
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
//        return true
//    }
    
    
}
