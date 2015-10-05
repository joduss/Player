//
//  RPMediaItem.swift
//  RandomPlayer
//
//  Created by Jonathan on 10.11.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

/**
Extension of MPMediaItem to provide easy access to some information such as
- title of the song
- title of the album
- name of the artist
- artwork image
- duration
...
*/
extension MPMediaItem {
    
    //not optimal //TODO do better
    
    private struct defaultValues {
        static let unknownSongTitle = "Unknown title"
        static let unknownAlbumTitle = "Unknown album title"
        static let unknownArtist = "Unknown artist"
    }
    
    
    func songTitle() -> String{
        if let title = self.valueForProperty(MPMediaItemPropertyTitle) as! String? {
            return title
        }
        else {
            return defaultValues.unknownSongTitle
        }
    }
    
    func albumTitleFormatted() -> String{
        if let albumTitle = self.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String? {
            return albumTitle
        }
        else {
            return defaultValues.unknownAlbumTitle
        }
    }
    
    func artistFormatted() -> String{
        if let artist = self.valueForProperty(MPMediaItemPropertyAlbumArtist) as! String? {
            return artist
        }
        else {
            return defaultValues.unknownArtist
        }
    }
    
    func artworkImage(ofSize size:CGSize) -> UIImage {
        let artwork : MPMediaItemArtwork? = self.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        
        var artworkImage = artwork?.imageWithSize(size)
        
        if(artworkImage == nil){
            artworkImage = UIImage(named: "default_artwork")
        }
        return artworkImage!
    }
    
    func artworkWithDefaultIfNone() -> MPMediaItemArtwork {
        var artwork : MPMediaItemArtwork? = self.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        
        if(artwork == nil){
            artwork = MPMediaItemArtwork(image: UIImage(named: "default_artwork")!)
        }
        return artwork!
    }
    
    func duration() -> NSTimeInterval {
        return self.valueForProperty(MPMediaItemPropertyPlaybackDuration) as! NSTimeInterval
    }
   
}
