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
    func songPicked(_ song : MPMediaItem)
    func albumPicked(_ album: MPMediaItemCollection)
    func artistPicked(_ artist: MPMediaItemCollection)
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
        querySearchArtist = MPMediaQuery.artists()
        querySearchAlbum = MPMediaQuery.albums()
        querySearchSong = MPMediaQuery.songs()
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder)  {
        querySearchArtist = MPMediaQuery.artists()
        querySearchAlbum = MPMediaQuery.albums()
        querySearchSong = MPMediaQuery.songs()
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        querySearchArtist = MPMediaQuery.artists()
        querySearchAlbum = MPMediaQuery.albums()
        querySearchSong = MPMediaQuery.songs()
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
    
    func queryForSection(_ section : Int) -> MPMediaQuery! {
        switch(section){
        case 0:
            return querySearchArtist
        case 1:
            return querySearchAlbum
        case 2:
            return querySearchSong
        default:
            let exception = NSException(name: NSExceptionName(rawValue: "Section out of range"), reason: "No query for section > 3 or < 0", userInfo: nil)
            exception.raise()
            return nil
        }
    }
    
    /**Return the item (MPMediaItem or MPMediaItemCollection) corresponding in the section, and the selected row.*/
    func itemForPath(_ path : IndexPath) -> AnyObject! {
        if((path as NSIndexPath).section == 0){
            return querySearchArtist.collections![(path as NSIndexPath).row]
        }
        else if((path as NSIndexPath).section == 1){
            return querySearchAlbum.collections![(path as NSIndexPath).row]
        }
        else if((path as NSIndexPath).section == 2){
            return querySearchSong.items![(path as NSIndexPath).row]
        }
        else {
            return nil //critical error
        }
    }
    
    
    
    //########################################################################
    //########################################################################
    // MARK: - Data filtering
    
    func filterContentFor(_ searchText : String) {
        
        dprint("hello, I search Artist with: \(searchText)")
        querySearchArtist = MPMediaQuery.artists()
        let filterPredicateArtist = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.contains)
        
        querySearchArtist.filterPredicates = Set(arrayLiteral: filterPredicateArtist)
        //self.tableView.reloadData()
        
        
        querySearchAlbum = MPMediaQuery.albums()
        let filterPredicateAlbum = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.contains)
        querySearchAlbum.filterPredicates = Set(arrayLiteral: filterPredicateAlbum)
        
        
        let filterPredicateSong = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyTitle, comparisonType: MPMediaPredicateComparison.contains)
        querySearchSong.filterPredicates = Set(arrayLiteral: filterPredicateSong)
        
    }
    
    
    
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        filterContentFor(searchString!)
        return true
    }
    
    
    //########################################################################
    //########################################################################
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let query = queryForSection(section)
        if(query == querySearchSong){
            if let items = query?.items {
                return items.count
            }
            return 0
        }
        else {
            if let collections = query?.collections {
                dprint("nb: \(collections.count)")
                return collections.count
            }
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if((indexPath as NSIndexPath).section == 1){
            return 60
        }
        return 55
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : RPCell!
        
        if((indexPath as NSIndexPath).section == 0) {
            let identifier = "artist cell"
            tableView.register(UINib(nibName: "RPCellArtist", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPCell
            
            let artist = queryForSection((indexPath as NSIndexPath).section).collections![(indexPath as NSIndexPath).row] 
            let item = artist.representativeItem
            
            if(item != nil) {
                cell.mainLabel.text = item!.value(forProperty: MPMediaItemPropertyArtist) as? String
            }
            
            cell.subLabel.text = RPTools.numberAlbumOfArtistFormattedString(artist) + ", " + RPTools.numberSongInCollection(artist)
            
        }
        else if((indexPath as NSIndexPath).section == 1){
            let identifier = "album cell"
            tableView.register(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPCell
            
            let album = queryForSection((indexPath as NSIndexPath).section).collections![(indexPath as NSIndexPath).row]
            let item = album.representativeItem
            let albumTitle = item!.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
            cell.mainLabel.text = albumTitle
            
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {() -> Void in
                
                let artwork : MPMediaItemArtwork? = item!.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                let artworkImage = artwork?.image(at: cell.cellImageView.bounds.size)
                
                DispatchQueue.main.async(execute: {() -> Void in
                    cell.cellImageView.image = artworkImage
                })
                
            })

            
            cell.subLabel.text = RPTools.numberSongInCollection(album)
            
        }
        else if((indexPath as NSIndexPath).section == 2){
            let identifier = "song cell"
            tableView.register(UINib(nibName: "RPCellSong", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPCell
            let item = queryForSection((indexPath as NSIndexPath).section).items![(indexPath as NSIndexPath).row] as MPMediaItem
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as! String
            cell.mainLabel.text = title
            
            let duration = item.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! TimeInterval
            cell.subLabel.text = formatTimeToMinutesSeconds(Int(duration))
            

        }
        else {
            NSException(name: NSExceptionName(rawValue: "Error, no 4th section"), reason: "too many sections", userInfo: nil).raise()
            return UITableViewCell()
        }
        
        //cell.rightViewOffSet = 80
        cell.delegate = self
        return cell
        
        
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).section == 0){
            let artist = querySearchArtist.collections![(indexPath as NSIndexPath).row]
            delegate?.artistPicked(artist)
        }
        else if((indexPath as NSIndexPath).section == 1){
            let album = querySearchAlbum.collections![(indexPath as NSIndexPath).row]
            delegate?.albumPicked(album)
        }
        else {
            let song = querySearchSong.items![(indexPath as NSIndexPath).row]
            delegate?.songPicked(song)
        }
    }
    
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(_ cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(_ cell: RPSwipableTVCell!) {
        let path = (searchTableView?.indexPath(for: cell))!
        
        var songs : Array<MPMediaItem> = Array()
        
        if((path as NSIndexPath).section == 0 || (path as NSIndexPath).section == 1){
            songs += itemForPath(path)  as! Array<MPMediaItem>
        }
        else if((path as NSIndexPath).section == 2) {
            songs.append(itemForPath(path) as! MPMediaItem)
        }
        
        RPPlayer.player.addSongs(songs)
        cell.hideBehindCell()
    }
    
    func buttonCenterRightPressed(_ cell: RPSwipableTVCell!) {
        
        let path = (searchTableView?.indexPath(for: cell))!

        
        
        var songs : Array<MPMediaItem> = Array()
            if((path as NSIndexPath).section == 0 || (path as NSIndexPath).section == 1){
                //is or an artist or an album
                songs += (itemForPath(path) as! MPMediaItemCollection).items
            }
            else if((path as NSIndexPath).section == 2) {
                //is a song
                songs.append(itemForPath(path) as! MPMediaItem)
            }
            
            RPPlayer.player.addNextAndPlay(songs)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(_ cell: RPSwipableTVCell!) {
        let path : IndexPath = (searchTableView?.indexPath(for: cell))!
        
        var songs : Array<MPMediaItem> = Array()
        
        if((path as NSIndexPath).section == 0 || (path as NSIndexPath).section == 1){
            //is an album or an artist
            songs += (itemForPath(path) as! MPMediaItemCollection).items
        }
        else if((path as NSIndexPath).section == 2) {
            //is a song
            songs.append(itemForPath(path) as! MPMediaItem)
        }

        RPPlayer.player.addNext(songs)
        cell .hideBehindCell()
    }
    
    
}
