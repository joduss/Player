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

    @IBOutlet var labelLeftPlaybackTime: UILabel
    @IBOutlet var sliderTime: UISlider
    @IBOutlet var labelTitle: UILabel
    @IBOutlet var labelArtistAlbum: UILabel
    @IBOutlet var viewRating: UIView
    @IBOutlet var imageViewArtwork: UIImageView
    @IBOutlet var buttonPlay: UIButton
    @IBOutlet var labelCurrentPlaybackTime: UILabel
    
    var timer : NSTimer?
    let musicPlayer : MPMusicPlayerController
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Initialization
    
    init(coder aDecoder: NSCoder!) {
        musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        
        //setup the slider action
        sliderTime.addTarget(self, action:"sliderPlaybackTimeMoved:", forControlEvents: UIControlEvents.ValueChanged)
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
        updatePlaybackSlider(nil)
        createTimer()
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
            musicPlayer.stop()
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
        
    }
    
    func createTimer(){
        timer?.invalidate() //to be sure there is only 1 slider
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "subscribePlaybackNotifications", userInfo: nil, repeats: true)
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - update information
    func updateInformation() {
        
    }
    
    //########################################################################
    //########################################################################
    // #pragma mark - notification subscription methods
    func subscribePlaybackNotifications() {
        
    }
    
    func unsubscribePlaybackNotifications() {
        
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
