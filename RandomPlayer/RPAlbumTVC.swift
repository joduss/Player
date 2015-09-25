//
//  RPAlbumTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 16.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPAlbumTVC: UIViewController, RPSwipableTVCellDelegate, RPSearchTVCDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var query : MPMediaQuery
    var artist : MPMediaItemCollection?
    
    var image : UIImage?
    
    @IBOutlet var searchTVC: RPSearchTVCTableViewController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var songActionDelegate : SongActionSheetDelegate?

    let ALBUM_CELL_IDENTIFIER = "album cell"
    
    
    required init?(coder aDecoder: NSCoder) {
        query = MPMediaQuery.albumsQuery()
        query.groupingType = MPMediaGrouping.Album
        super.init(coder: aDecoder)
    }
    
//    override init() {
//        query = MPMediaQuery.albumsQuery()
//        query.groupingType = MPMediaGrouping.Album
//        super.init()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        query = MPMediaQuery.albumsQuery()
        query.groupingType = MPMediaGrouping.Album
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Albums"
        
        // RPSearchTVC setup
        searchTVC.delegate = self
        searchTVC.searchTableView = self.searchDisplayController?.searchResultsTableView
        
        
        
        //hide searchBar
        let bounds = self.tableView.bounds;
        let b = CGRectMake(
            bounds.origin.x,
            bounds.origin.y + searchBar.bounds.size.height,
            bounds.size.width,
            bounds.size.height
        )
        self.tableView.bounds = b;
        
        //tableView setup
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.registerNib(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier:ALBUM_CELL_IDENTIFIER)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let currentArtist = artist {
            self.title = currentArtist.representativeItem.valueForProperty(MPMediaItemPropertyArtist) as? String
        }
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - other functions
    
    
    /**return the album at the given indexPath*/
    func albumAtIndexPath(indexPath : NSIndexPath) -> MPMediaItemCollection {
        let mediaQuerySection: AnyObject = self.query.collectionSections[indexPath.section]
        let albumIndex = mediaQuerySection.range.location + indexPath.row
        
        return self.query.collections[albumIndex] as! MPMediaItemCollection
    }
    
    /**Load album only for the specified artist*/
    func filterAlbumForArtist(artist : MPMediaItemCollection) {
        self.artist = artist
        self.title = artist.representativeItem.valueForProperty(MPMediaItemPropertyArtist) as? String
        let filterPredicate = MPMediaPropertyPredicate(
            value: artist.representativeItem.valueForProperty(MPMediaItemPropertyArtistPersistentID),
            forProperty: MPMediaItemPropertyArtistPersistentID)
        query.filterPredicates = NSSet(object: filterPredicate) as Set<NSObject>
        //self.tableView.reloadData()
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell) {
        
        RPPlayer.player.addSongs(albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell) {
        
        RPPlayer.player.addNextAndPlay(self.albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell){
        
        RPPlayer.player.addNext(self.albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.query.collectionSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.query.collectionSections[section].range.length
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(artist == nil) {
            return query.collectionSections[section].title!!
        }
        else {
            return ""
        }
    }
    
    //show alphabet on right part 1
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if(index == 0){
            tableView.scrollRectToVisible(searchBar.frame, animated: false)
            return NSNotFound
        }
        return (index - 1)
    }
    
    //show alphabet on right part 2
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]! {
        if(artist == nil) {
            var indexTitles : Array<String> = Array()
            indexTitles.append(UITableViewIndexSearch)
            for section in query.collectionSections {
                indexTitles.append(section.title!!)
            }
            return indexTitles
        }
        else {
            return [] //return empty array, because don't want indexTitles
        }
    }
    
    //Setup the  cells with the loaded content.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ALBUM_CELL_IDENTIFIER, forIndexPath: indexPath) as! RPCell
        
        cell.delegate = self
        //cell.rightViewOffSet = 80
        
        let imageView = cell.cellImageView
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        
        let album = self.albumAtIndexPath(indexPath)
        let representativeItem = album.representativeItem
        
        titleLabel.text = representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String
        let nbSongInAbum = album.count
        
        if(nbSongInAbum < 2) {
            subtitleLabel.text = "\(nbSongInAbum) song"
        }
        else {
            subtitleLabel.text = "\(nbSongInAbum) songs"
        }
        
        
        //load image async (more fluid)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            
            let artwork : MPMediaItemArtwork? = representativeItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            var artworkImage = artwork?.imageWithSize(imageView.bounds.size)
            
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                if(artworkImage == nil){
                    artworkImage = UIImage(named: "default_artwork")
                }
                imageView.image = artworkImage
            })
            
        })
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let chosenAlbum = albumAtIndexPath(indexPath)
        self.performSegueWithIdentifier("segue album to song", sender: chosenAlbum)
    }
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - RPSearchTVC delegate
    
    func songPicked(song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action", delegate: songActionDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Play next", "Play now", "Add to Queue")
        actionSheet.showInView(self.view)    }
    func albumPicked(album: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue album to song", sender: album)
    }
    func artistPicked(artist: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue album to album", sender: artist)
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "segue album to song") {
            let dest = segue.destinationViewController as! RPSongTVC
            let album = sender as! MPMediaItemCollection
            
            dprint("dest: \(dest)")
            dprint("album: \(album)")

            dest.filterSongForAlbum(album)
            dest.title = album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String
        }
        else if(segue.identifier == "segue album to album") {
            let dest = segue.destinationViewController as! RPAlbumTVC
            let artist = sender as! MPMediaItemCollection
            dest.filterAlbumForArtist(artist)
        }
    }
    
    
    
}
