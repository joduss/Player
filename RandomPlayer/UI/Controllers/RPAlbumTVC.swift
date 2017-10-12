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
        query = MPMediaQuery.albums()
        query.groupingType = MPMediaGrouping.album
        super.init(coder: aDecoder)
    }
    
//    override init() {
//        query = MPMediaQuery.albumsQuery()
//        query.groupingType = MPMediaGrouping.Album
//        super.init()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        query = MPMediaQuery.albums()
        query.groupingType = MPMediaGrouping.album
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
        let b = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y + searchBar.bounds.size.height,
            width: bounds.size.width,
            height: bounds.size.height
        )
        self.tableView.bounds = b;
        
        //tableView setup
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier:ALBUM_CELL_IDENTIFIER)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentArtist = artist {
            self.title = currentArtist.representativeItem!.value(forProperty: MPMediaItemPropertyArtist) as? String
        }
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - other functions
    
    
    /**return the album at the given indexPath*/
    func albumAtIndexPath(_ indexPath : IndexPath) -> MPMediaItemCollection {
        let mediaQuerySection: AnyObject = self.query.collectionSections![(indexPath as NSIndexPath).section]
        let albumIndex = mediaQuerySection.range.location + (indexPath as NSIndexPath).row
        
        return self.query.collections![albumIndex]
    }
    
    /**Load album only for the specified artist*/
    func filterAlbumForArtist(_ artist : MPMediaItemCollection) {
        self.artist = artist
        self.title = artist.representativeItem!.value(forProperty: MPMediaItemPropertyArtist) as? String
        let filterPredicate = MPMediaPropertyPredicate(
            value: artist.representativeItem!.value(forProperty: MPMediaItemPropertyArtistPersistentID),
            forProperty: MPMediaItemPropertyArtistPersistentID)
        query.filterPredicates = Set(arrayLiteral: filterPredicate)
        //self.tableView.reloadData()
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(_ cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell) {
        
        RPPlayer.player.addSongs(albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell) {
        
        RPPlayer.player.addNextAndPlay(self.albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
        
        RPPlayer.player.addNext(self.albumAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.query.collectionSections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.query.collectionSections![section].range.length
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(artist == nil) {
            return query.collectionSections![section].title
        }
        else {
            return ""
        }
    }
    
    //show alphabet on right part 1
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if(index == 0){
            tableView.scrollRectToVisible(searchBar.frame, animated: false)
            return NSNotFound
        }
        return (index - 1)
    }
    
    //show alphabet on right part 2
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if(artist == nil) {
            var indexTitles : Array<String> = Array()
            indexTitles.append(UITableViewIndexSearch)
            for section in query.collectionSections! {
                indexTitles.append(section.title)
            }
            return indexTitles
        }
        else {
            return [] //return empty array, because don't want indexTitles
        }
    }
    
    //Setup the  cells with the loaded content.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ALBUM_CELL_IDENTIFIER, for: indexPath) as! RPCell
        
        cell.delegate = self
        //cell.rightViewOffSet = 80
        
        let imageView = cell.cellImageView
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        
        let album = self.albumAtIndexPath(indexPath)
        let representativeItem = album.representativeItem
        
        titleLabel?.text = representativeItem!.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
        let nbSongInAbum = album.count
        
        if(nbSongInAbum < 2) {
            subtitleLabel?.text = "\(nbSongInAbum) song"
        }
        else {
            subtitleLabel?.text = "\(nbSongInAbum) songs"
        }
        
        
        //load image async (more fluid)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {() -> Void in
            
            let artwork : MPMediaItemArtwork? = representativeItem!.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            var artworkImage = artwork?.image(at: (imageView?.bounds.size)!)
            
            DispatchQueue.main.async(execute: {() -> Void in
                if(artworkImage == nil){
                    artworkImage = UIImage(named: "default_artwork")
                }
                imageView?.image = artworkImage
            })
            
        })
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let chosenAlbum = albumAtIndexPath(indexPath)
        self.performSegue(withIdentifier: "segue album to song", sender: chosenAlbum)
    }
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - RPSearchTVC delegate
    
    func songPicked(_ song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action", delegate: songActionDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Play next", "Play now", "Add to Queue")
        actionSheet.show(in: self.view)    }
    func albumPicked(_ album: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue album to song", sender: album)
    }
    func artistPicked(_ artist: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue album to album", sender: artist)
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segue album to song") {
            let dest = segue.destination as! RPSongTVC
            let album = sender as! MPMediaItemCollection
            
            dprint("dest: \(dest)")
            dprint("album: \(album)")

            dest.filterSongForAlbum(album)
            dest.title = album.representativeItem!.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
        }
        else if(segue.identifier == "segue album to album") {
            let dest = segue.destination as! RPAlbumTVC
            let artist = sender as! MPMediaItemCollection
            dest.filterAlbumForArtist(artist)
        }
    }
    
    
    
}
