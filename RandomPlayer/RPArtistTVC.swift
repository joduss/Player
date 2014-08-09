//
//  RPArtistTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 15.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPArtistTVC: UITableViewController, RPSwipableTVCellDelegate, UISearchDisplayDelegate, UISearchBarDelegate, RPSearchTVCDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var query : MPMediaQuery
    var collectionSections : Array<AnyObject>
    let cellHeight = 55
    
    var querySearchArtist : MPMediaQuery?
    var querySearchAlbum : MPMediaQuery?
    var querySearchSong : MPMediaQuery?
    
    @IBOutlet var searchTVC: RPSearchTVCTableViewController!

    
    required init(coder aDecoder: NSCoder!)  {
        self.query = MPMediaQuery.artistsQuery()
        self.collectionSections = query.collectionSections
        super.init(coder: aDecoder)
    }
    
    override init() {
        self.query = MPMediaQuery.artistsQuery()
        self.collectionSections = query.collectionSections
        super.init()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.query = MPMediaQuery.artistsQuery()
        self.collectionSections = query.collectionSections
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        self.query = MPMediaQuery.artistsQuery()
        self.collectionSections = query.collectionSections
        super.init(style: style)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // #warning - verify compatibility with other swipableButton
        self.tableView.canCancelContentTouches = false
        searchTVC.delegate = self
        searchTVC.searchTableView = self.searchDisplayController.searchResultsTableView
        
        //tableView.registerClass(RPSwipableTVCell.self, forCellReuseIdentifier: "cell")

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //########################################################################
    //########################################################################
    
    // #pragma mark - other functions
    /**Return the artist at indexPath*/
    func artistAtIndexPath(indexPath : NSIndexPath) -> MPMediaItemCollection{
        let mediaQuerySection: AnyObject = self.collectionSections[indexPath.section]
        let artistIndex = mediaQuerySection.range.location + indexPath.row
        
        return self.query.collections[artistIndex] as MPMediaItemCollection
    }
    
    
    func artistAtIndexPath(indexPath : NSIndexPath, inQuery query:MPMediaQuery) -> MPMediaItemCollection{
        let mediaQuerySection: AnyObject = self.collectionSections[indexPath.section]
        let artistIndex = mediaQuerySection.range.location + indexPath.row
        
        return self.querySearchArtist?.collections[artistIndex] as MPMediaItemCollection
    }

    
    //########################################################################
    //########################################################################
    
    // #pragma mark - RPSwipableTVCell delegate methods

    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addSongs(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        let song = self.artistAtIndexPath(path).items as Array<MPMediaItem>
        RPPlayer.player.addNextAndPlay(song)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addNext(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 55
    }
    

    //########################################################################
    //########################################################################
    
    // #pragma mark - Table view data source
    

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        if(self.searchDisplayController.active){
            return self.collectionSections.count
        }
        else {
            return self.collectionSections.count
        }
    }

    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let mediaQuerySection: AnyObject = self.collectionSections[section]
        return mediaQuerySection.range.length
    }
    
    /**Return the title of the header for this section*/
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        let mediaQuerySection: AnyObject = self.collectionSections[section]
        return mediaQuerySection.title
    }
    

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        
        //self.tableView.registerClass(RPSwipableTVCell.self, forCellReuseIdentifier: "cellArtistTVC")
        
        //if(self.searchDisplayController.active == false) {

            let identifier = "artist cell"
            
            tableView.registerNib(UINib(nibName: "RPCellArtist", bundle: nil), forCellReuseIdentifier: identifier)
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPCell
            
            let titleLabel = cell.mainLabel
            let subtitleLabel = cell.subLabel
        
        var artist : MPMediaItemCollection = artistAtIndexPath(indexPath)
        
        if(self.searchDisplayController.active){
            if let q = querySearchArtist{
                artist = artistAtIndexPath(indexPath, inQuery: q)
            }
        }
        
        
            titleLabel.text = artist.representativeItem.valueForProperty(MPMediaItemPropertyArtist) as String
            
            var nbSongTitle = RPTools.numberSongInCollection(artist)
            var nbAlbumTitle = RPTools.numberAlbumOfArtistFormattedString(artist)
            
            subtitleLabel.text = "\(nbAlbumTitle), \(nbSongTitle)"
            
            
            cell.delegate = self
            cell.rightViewOffSet = 80;
            
            return cell

//        }
//        else {
//            
//        }
        

    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let artist = self.artistAtIndexPath(indexPath)
        self.performSegueWithIdentifier("segue artist to album", sender: artist)
    }


    
    //************************************************************************
    //************************************************************************
    //#pragma mark - RPSearchTVC delegate
    
    
    func songPicked(song : MPMediaItem){
        //self.performSegueWithIdentifier("segue artist to song", sender: song)
        //TODO
    }
    func albumPicked(album: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue artist to song", sender: album)
    }
    func artistPicked(artist: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue artist to album", sender: artist)
    }
    
    //************************************************************************
    //************************************************************************
    
    //#pragma mark - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "segue artist to album" || segue.identifier == "segue artiste to song"){
            let dest = segue.destinationViewController as RPAlbumTVC
            dest.filterAlbumForArtist(sender as MPMediaItemCollection)
        }
    }
    
//    -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//    {
//    if([segue.identifier isEqualToString:@"artistToAlbum"]){
//    RPAlbumListTVC *dest = (RPAlbumListTVC *)segue.destinationViewController;
//    NSIndexPath *path = sender;
//    MPMediaItemCollection *artist = [self artistAtIndexpath:path];
//    [dest setArtist:artist];
//    }
//    }

}
