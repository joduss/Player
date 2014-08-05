//
//  RPAlbumTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 16.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPAlbumTVC: UITableViewController, RPSwipableTVCellDelegate {
    
    var query : MPMediaQuery
    var artist : MPMediaItemCollection?
    
    var image : UIImage?
    
    
    required init(coder aDecoder: NSCoder!) {
        query = MPMediaQuery.albumsQuery()
        query.groupingType = MPMediaGrouping.Album
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Albums"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    
    //************************************************************************
    //************************************************************************
    // #pragma mark - other functions

    
    /**return the album at the given indexPath*/
    func albumAtIndexPath(indexPath : NSIndexPath) -> MPMediaItemCollection {
        let mediaQuerySection: AnyObject = self.query.collectionSections[indexPath.section]
        let albumIndex = mediaQuerySection.range.location + indexPath.row
        
        return self.query.collections[albumIndex] as MPMediaItemCollection
    }
    
    /**Load album only for the specified artist*/
    func filterAlbumForArtist(artist : MPMediaItemCollection) {
        self.artist = artist
        self.title = artist.representativeItem.valueForProperty(MPMediaItemPropertyArtist) as String
        let filterPredicate = MPMediaPropertyPredicate(
            value: artist.representativeItem.valueForProperty(MPMediaItemPropertyArtistPersistentID),
            forProperty: MPMediaItemPropertyArtistPersistentID)
        query.filterPredicates = NSSet(object: filterPredicate)
        self.tableView.reloadData()
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addSongs(albumAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addNextAndPlay(self.albumAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addNext(self.albumAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return self.query.collectionSections.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.query.collectionSections[section].range.length
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        let identifier = "album cell"
        
        tableView.registerNib(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPCell
        
        cell.delegate = self
        cell.rightViewOffSet = 80
        
        let imageView = cell.cellImageView
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        
        let album = self.albumAtIndexPath(indexPath)
        let representativeItem = album.representativeItem
        
        titleLabel.text = representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
        let nbSongInAbum = album.count
        
        if(nbSongInAbum < 2) {
            subtitleLabel.text = "\(nbSongInAbum) song"
        }
        else {
            subtitleLabel.text = "\(nbSongInAbum) songs"
        }
        

        //truc temporaire pour être fluide du temps que imageWithSize(56,56) ne fonctionne pas....
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
//            let artwork : MPMediaItemArtwork? = representativeItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
//            //NSLog("%@", artwork)
//            let artworkImage = artwork?.imageWithSize(CGSizeMake(150, 150))
//            
//            UIGraphicsBeginImageContext(CGSize(width: 56,height: 56))
//            var thumRect = CGRectZero
//            thumRect.origin = CGPoint(x: 0, y: 0)
//            
//            thumRect.size = CGSize(width: 56, height: 56)
//            
//            artworkImage?.drawInRect(thumRect)
//            
//            let im = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                imageView.image = im
//                })
//            
//            
//            })
                    let artwork : MPMediaItemArtwork? = representativeItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork

                    let artworkImage = artwork?.imageWithSize(CGSizeMake(60, 60))
        imageView.image = artworkImage

        

        return cell
    }
    
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("albumToSong", sender: indexPath)
    }



    //************************************************************************
    //************************************************************************
    // #pragma mark - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "albumToSong") {
            let dest = segue.destinationViewController as RPSongTVC
            let album = self.albumAtIndexPath(sender as NSIndexPath)
            dest.filterSongForAlbum(album)
        }
    }
    
}
