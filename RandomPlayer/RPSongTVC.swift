//
//  RPSongTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPSongTVC: UITableViewController, RPSwipableTVCellDelegate {

    var query : MPMediaQuery
    var album : MPMediaItemCollection?
    
    
    init(coder aDecoder: NSCoder!) {
        query = MPMediaQuery.songsQuery()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - other functions
    func filterSongForAlbum(album : MPMediaItemCollection) {
        self.album = album
        self.title = album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
        let filterPredicate = MPMediaPropertyPredicate(
            value: album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumPersistentID),
            forProperty: MPMediaItemPropertyAlbumPersistentID)
        
        self.query.filterPredicates = NSSet(object: filterPredicate)
        self.tableView.reloadData()
    }
    
    /**Return the song at the given indexpath. It correspond to the displayed information at the IndexPath.*/
    func songAtIndexPath(indexPath : NSIndexPath) -> MPMediaItem{
        let mediaQuerySection = query.itemSections[indexPath.section] as MPMediaQuerySection
        let index = mediaQuerySection.range.location + indexPath.row
        return query.items[index] as MPMediaItem
    }

    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        RPQueueManager.addSongs([songAtIndexPath(path)])
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPQueueManager .addNextAndPlay([self.songAtIndexPath(path)])
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        RPQueueManager .addNext([self.songAtIndexPath(path)])
        cell .hideBehindCell()
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return self.query.itemSections.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.query.itemSections[section].range.length
        
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as RPSwipableTVCell
        cell.delegate = self
        cell.rightViewOffSet = 80
        
        let titleLabel = cell.contentView.viewWithTag(400) as UILabel
        let subtitleLabel = cell.contentView.viewWithTag(401) as UILabel
        
        let song = self.songAtIndexPath(indexPath)
        
        titleLabel.text = song.valueForProperty(MPMediaItemPropertyTitle) as String
        
        let durationInSeconds = song.valueForProperty(MPMediaItemPropertyPlaybackDuration) as Int
        subtitleLabel.text = formatTimeToMinutesSeconds(durationInSeconds)
        
        
    
        return cell
    }
    
}
