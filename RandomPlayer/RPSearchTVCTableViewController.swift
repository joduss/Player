//
//  RPSearchTVCTableViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 04.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer



protocol RPSearchTVCDelegate {
    func songPicked(song : MPMediaItem)
    func albumPicked(album: MPMediaItemCollection)
    func artistPicked(artist: MPMediaItemCollection)
}


class RPSearchTVCTableViewController: UITableViewController, UISearchDisplayDelegate, UISearchBarDelegate, RPSwipableTVCellDelegate {
    
    
    var querySearchArtist : MPMediaQuery
    var querySearchAlbum : MPMediaQuery
    var querySearchSong : MPMediaQuery
    var delegate : RPSearchTVCDelegate?
    var searchTableView : UITableView?
    
//    override init(){
//        querySearchArtist = MPMediaQuery.artistsQuery()
//        querySearchAlbum = MPMediaQuery.albumsQuery()
//        querySearchSong = MPMediaQuery.songsQuery()
//        super.init()
//    }
    
    override init(style: UITableViewStyle) {
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder)  {
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
    
    func queryForSection(section : Int) -> MPMediaQuery! {
        switch(section){
        case 0:
            return querySearchArtist
        case 1:
            return querySearchAlbum
        case 2:
            return querySearchSong
        default:
            let exception = NSException(name: "Section out of range", reason: "No query for section > 3 or < 0", userInfo: nil)
            exception.raise()
            return nil
        }
    }
    
    /**Return the item (MPMediaItem or MPMediaItemCollection) corresponding in the section, and the selected row.*/
    func itemForPath(path : NSIndexPath) -> AnyObject! {
        if(path.section == 0){
            return querySearchArtist.collections![path.row]
        }
        else if(path.section == 1){
            return querySearchAlbum.collections![path.row]
        }
        else if(path.section == 2){
            return querySearchSong.items![path.row]
        }
        else {
            return nil //critical error
        }
    }
    
    
    
    //########################################################################
    //########################################################################
    // MARK: - Data filtering
    
    func filterContentFor(searchText : String) {
        
        dprint("hello, I search Artist with: \(searchText)")
        querySearchArtist = MPMediaQuery.artistsQuery()
        let filterPredicateArtist = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.Contains)
        
        querySearchArtist.filterPredicates = Set(arrayLiteral: filterPredicateArtist)
        //self.tableView.reloadData()
        
        
        querySearchAlbum = MPMediaQuery.albumsQuery()
        let filterPredicateAlbum = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.Contains)
        querySearchAlbum.filterPredicates = Set(arrayLiteral: filterPredicateAlbum)
        
        
        let filterPredicateSong = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyTitle, comparisonType: MPMediaPredicateComparison.Contains)
        querySearchSong.filterPredicates = Set(arrayLiteral: filterPredicateSong)
        
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        filterContentFor(searchString!)
        return true
    }
    
    
    //########################################################################
    //########################################################################
    // MARK: - Table view
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "Artists (\(querySearchArtist.collections!.count))"
        case 1:
            return "Album (\(querySearchAlbum.collections!.count))"
        case 2:
            return "Songs (\(querySearchSong.items!.count))"
        default:
            return "ERROR"
        }
    }
    

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var nbRows = 0
        var query = queryForSection(section)
        if(query == querySearchSong){
            if let items = query.items {
                return items.count
            }
            return 0
        }
        else {
            if let collections = query.collections {
                dprint("nb: \(collections.count)")
                return collections.count
            }
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 1){
            return 60
        }
        return 55
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : RPCell!
        
        if(indexPath.section == 0) {
            let identifier = "artist cell"
            tableView.registerNib(UINib(nibName: "RPCellArtist", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RPCell
            
            let artist = queryForSection(indexPath.section).collections![indexPath.row] 
            let item = artist.representativeItem
            
            if(item != nil) {
                cell.mainLabel.text = item!.valueForProperty(MPMediaItemPropertyArtist) as! String
            }
            
            cell.subLabel.text = RPTools.numberAlbumOfArtistFormattedString(artist) + ", " + RPTools.numberSongInCollection(artist)
            
        }
        else if(indexPath.section == 1){
            let identifier = "album cell"
            tableView.registerNib(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RPCell
            
            let album = queryForSection(indexPath.section).collections![indexPath.row] as! MPMediaItemCollection
            let item = album.representativeItem
            let albumTitle = item!.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
            cell.mainLabel.text = albumTitle
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                
                let artwork : MPMediaItemArtwork? = item!.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                let artworkImage = artwork?.imageWithSize(cell.cellImageView.bounds.size)
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    cell.cellImageView.image = artworkImage
                })
                
            })

            
            cell.subLabel.text = RPTools.numberSongInCollection(album)
            
        }
        else if(indexPath.section == 2){
            let identifier = "song cell"
            tableView.registerNib(UINib(nibName: "RPCellSong", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RPCell
            let item = queryForSection(indexPath.section).items![indexPath.row] as! MPMediaItem
            let title = item.valueForProperty(MPMediaItemPropertyTitle) as! String
            cell.mainLabel.text = title
            
            let duration = item.valueForProperty(MPMediaItemPropertyPlaybackDuration) as! NSTimeInterval
            cell.subLabel.text = formatTimeToMinutesSeconds(Int(duration))
            

        }
        else {
            NSException(name: "Error, no 4th section", reason: "too many sections", userInfo: nil).raise()
            return UITableViewCell()
        }
        
        //cell.rightViewOffSet = 80
        cell.delegate = self
        return cell
        
        
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            let artist = querySearchArtist.collections![indexPath.row] as! MPMediaItemCollection
            delegate?.artistPicked(artist)
        }
        else if(indexPath.section == 1){
            let album = querySearchAlbum.collections![indexPath.row] as! MPMediaItemCollection
            delegate?.albumPicked(album)
        }
        else {
            let song = querySearchSong.items![indexPath.row] as! MPMediaItem
            delegate?.songPicked(song)
        }
    }
    
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        let path = (searchTableView?.indexPathForCell(cell))!
        
        var songs : Array<MPMediaItem> = Array()
        
        if(path.section == 0 || path.section == 1){
            songs += itemForPath(path)  as! Array<MPMediaItem>
        }
        else if(path.section == 2) {
            songs.append(itemForPath(path) as! MPMediaItem)
        }
        
        RPPlayer.player.addSongs(songs)
        cell.hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        
        let path = (searchTableView?.indexPathForCell(cell))!

        
        
        var songs : Array<MPMediaItem> = Array()
            if(path.section == 0 || path.section == 1){
                //is or an artist or an album
                songs += (itemForPath(path) as! MPMediaItemCollection).items
            }
            else if(path.section == 2) {
                //is a song
                songs.append(itemForPath(path) as! MPMediaItem)
            }
            
            RPPlayer.player.addNextAndPlay(songs)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path : NSIndexPath = (searchTableView?.indexPathForCell(cell))!
        
        var songs : Array<MPMediaItem> = Array()
        
        if(path.section == 0 || path.section == 1){
            //is an album or an artist
            songs += (itemForPath(path) as! MPMediaItemCollection).items
        }
        else if(path.section == 2) {
            //is a song
            songs.append(itemForPath(path) as! MPMediaItem)
        }

        RPPlayer.player.addNext(songs)
        cell .hideBehindCell()
    }
    
    
}
