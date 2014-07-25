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
    
    
    init(coder aDecoder: NSCoder!) {
        query = MPMediaQuery.albumsQuery()
        query.groupingType = MPMediaGrouping.Album
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Albums"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as RPSwipableTVCell
        
        cell.delegate = self
        cell.rightViewOffSet = 80
        
        let imageView = self.view.viewWithTag(100) as UIImageView
        let titleLabel = self.view.viewWithTag(101) as UILabel
        let subtitleLabel = self.view.viewWithTag(102) as UILabel
        
        
        let album = self.albumAtIndexPath(indexPath)
        
        titleLabel.text = album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
        let nbSongInAbum = album.count
        
        if(nbSongInAbum < 2) {
            subtitleLabel.text = "\(nbSongInAbum) song"
        }
        else {
            subtitleLabel.text = "\(nbSongInAbum) songs"
        }
        
        let artwork = album.representativeItem.valueForProperty(MPMediaItemPropertyArtwork) as MPMediaItemArtwork
        let artworkImage = artwork.imageWithSize(imageView.bounds.size)
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
