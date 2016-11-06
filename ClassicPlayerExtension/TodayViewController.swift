//
//  TodayViewController.swift
//  ClassicPlayerExtension
//
//  Created by Jonathan Duss on 02.11.16.
//  Copyright © 2016 Jonathan Duss. All rights reserved.
//

import UIKit
import NotificationCenter
import MediaPlayer

class TodayViewController: UIViewController, NCWidgetProviding, RateViewDelegate {
        
    @IBOutlet weak var rateView: RateView!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBAction func zeroStar(_ sender: UITapGestureRecognizer) {
        dprint("0 star")
        rateView.rating = 0
    }
    let userDefaults = UserDefaults(suiteName: RPExtensionCommunication.suiteName)
    
    private var currentSongId = NSNumber(value: 0)
    
    override func viewDidLoad() {
        let emptyStarImage = UIImage(named: "emptyStarBlack")
        let fullStarImage = UIImage(named: "fullStarBlack")
        
        if(emptyStarImage != nil && fullStarImage != nil){
            rateView.setupRateView(fullStarImage!, emptyStarImage : emptyStarImage!, maxRating : 5)
        }
        rateView.editable = true
        rateView.delegate = self
        super.viewDidLoad()
        self.rateView.rating = 2
        
        
        
        //Notification song is at end
        
        if #available(iOSApplicationExtension 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: {_ in
                if let songID = self.userDefaults?.object(forKey: RPExtensionCommunication.songID) as? NSNumber, songID != self.currentSongId{
                    self.songChanged()
                }
            })
        } else {
            // Fallback on earlier versions
        }
        
        songChanged()
    }
    

    //Song changed: update view
    func songChanged(){
        //FIRST LOAD
        guard let userDefaults = userDefaults, userDefaults.object(forKey: RPExtensionCommunication.songID) != nil else {
            return
        }
        dprint("reading: \(userDefaults.object(forKey: RPExtensionCommunication.songID))")
        
        let songID = userDefaults.object(forKey: RPExtensionCommunication.songID) as! NSNumber
        
        if let song = self.mediaItem(songID: songID ) {
            self.artistLabel.text = song.artist
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func rateView(_ rateView : RateView, ratingDidChange rating : Float){
        
    }
    
    
    
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

}
