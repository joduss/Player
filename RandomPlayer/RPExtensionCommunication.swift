//
//  RPExtensionCommunication.swift
//  ClassicPlayer
//
//  Created by Jonathan Duss on 06.11.16.
//  Copyright © 2016 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPExtensionCommunication: NSObject {
    
    static let suiteName = "group.ClassicPlayer"
    static let songID = "SONG_ID"
    
    override init() {
        super.init()
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RPPlayerNotification.SongDidChange), object: nil, queue: OperationQueue.current, using: { notification in
            
            if let userDefaults = UserDefaults(suiteName: RPExtensionCommunication.suiteName), let song = notification.object as? MPMediaItem {
                dprint("overwrite: \(userDefaults.object(forKey: RPExtensionCommunication.songID))")
                userDefaults.setValue(song.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber, forKey: RPExtensionCommunication.songID)
            }
        })
    }

}
