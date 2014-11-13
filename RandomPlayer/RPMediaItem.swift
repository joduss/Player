//
//  RPMediaItem.swift
//  RandomPlayer
//
//  Created by Jonathan on 10.11.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

extension MPMediaItem {
    
    func songTitle() -> String{
        var title = self.valueForProperty(MPMediaItemPropertyTitle) as String?
        if(title == nil){
            title = "Unknown title"
        }
        return title!
    }
    
    func albumTitle() -> String{
        var albumTitle = self.valueForProperty(MPMediaItemPropertyAlbumTitle) as String?
        if(albumTitle == nil){
            albumTitle = "Unknown album title"
        }
        return albumTitle!
    }
    
    func artist() -> String{
        var artist = self.valueForProperty(MPMediaItemPropertyAlbumArtist) as String?
        if(artist == nil){
            artist = "Unknown artist"
        }
        return artist!
    }
    
    func artworkImage(ofSize size:CGSize) -> UIImage {
        let artwork : MPMediaItemArtwork? = self.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        
        var artworkImage = artwork?.imageWithSize(size)
        
        if(artworkImage == nil){
            artworkImage = UIImage(named: "default_artwork")
        }
        return artworkImage!
    }
    
    func artwork() -> MPMediaItemArtwork {
        var artwork : MPMediaItemArtwork? = self.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        
        if(artwork == nil){
            artwork = MPMediaItemArtwork(image: UIImage(named: "default_artwork"))
        }
        return artwork!
    }
    
    func duration() -> NSTimeInterval {
        return self.valueForProperty(MPMediaItemPropertyPlaybackDuration) as NSTimeInterval
    }
   
}
