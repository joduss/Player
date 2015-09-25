//
//  RPSongTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPSongTVC: UIViewController, RPSwipableTVCellDelegate, RPSearchTVCDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    var query : MPMediaQuery
    var collection : MPMediaItemCollection?
    var songActionDelegate : SongActionSheetDelegate?
    var panel: UIView?
    var panelYConstraints : [NSLayoutConstraint] = []
    
    
    let TAG_ACTIONSHEET_SORT = 9988
    let TAG_ACTIONSHEET_FILTER = 9977
    
    
    
    @IBOutlet var searchTVC: RPSearchTVCTableViewController!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - init
    
    required init?(coder aDecoder: NSCoder) {
        query = MPMediaQuery.songsQuery()
        super.init(coder: aDecoder)
    }
    
//    override init() {
//        query = MPMediaQuery.songsQuery()
//        super.init()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        query = MPMediaQuery.songsQuery()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - view loading / unloading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RPSearchTVC setup
        searchTVC.delegate = self
        searchTVC.searchTableView = self.searchDisplayController?.searchResultsTableView
        //self.title = "Albums"
        
        //hide searchBar
        let bounds = self.tableView.bounds;
        let b = CGRectMake(
            bounds.origin.x,
            bounds.origin.y + searchBar.bounds.size.height,
            bounds.size.width,
            bounds.size.height
        )
        self.tableView.bounds = b;
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        //LOAD THE PANEL
        var viewArray = NSBundle.mainBundle().loadNibNamed("PanelSortSelect", owner: self, options: nil)
        let panel = viewArray[0] as! UIView
        
        self.view.addSubview(panel)
        
        let navBarOriginY = self.navigationController?.navigationBar.frame.origin.y
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        panel.autoresizingMask = UIViewAutoresizing.None
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["panel" : panel]
        
        let constWidth = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[panel]-0-|",
            options: NSLayoutFormatOptions.AlignAllBaseline,
            metrics: nil,
            views: viewDict)
        panelYConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-dist-[panel(35)]",
            options: NSLayoutFormatOptions.AlignAllBaseline,
            metrics: ["dist" :  (navBarOriginY! + navBarHeight!)],
            views: viewDict)
        
        
        self.view.addConstraints(constWidth)
        self.view.addConstraints(panelYConstraints)
        
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0) //move so the the table start after the pannel
        self.panel = panel
        
        //add line border on the bottom of the pannel
        let bottomBorder = CALayer();
        bottomBorder.frame = CGRectMake(0.0, 34.5, panel.frame.size.width, 0.5);
        let color = UIColor.grayColor().colorWithAlphaComponent(0.7)
        bottomBorder.backgroundColor = color.CGColor
        panel.layer.addSublayer(bottomBorder);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.panel = nil
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if let panelToUpdate = panel{
            self.view.removeConstraints(panelYConstraints)
            panelYConstraints.removeAll(keepCapacity: true)
            
            let dic = ["panel": panelToUpdate]
            
            let navBarOriginY = self.navigationController?.navigationBar.frame.origin.y
            let navBarHeight = self.navigationController?.navigationBar.frame.size.height
            
            let c = NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[panel(35)]",
                options: NSLayoutFormatOptions.AlignAllBaseline,
                metrics: ["dist" :  (navBarHeight! + navBarOriginY!)],
                views: dic)
            
            panelYConstraints.appendContentsOf(c)
            
            self.view.addConstraints(panelYConstraints)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        songActionDelegate = nil
        // Dispose of any resources that can be recreated.
    }
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - other functions
    func filterSongForAlbum(album : MPMediaItemCollection?) {
        
        self.collection = album
        self.title = "salut" //String(album?.valueForProperty(MPMediaItemPropertyAlbumTitle) as NSString);
        //self.title = album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
        let filterPredicate = MPMediaPropertyPredicate(
            value: album!.representativeItem!.valueForProperty(MPMediaItemPropertyAlbumPersistentID),
            forProperty: MPMediaItemPropertyAlbumPersistentID)
        
        self.query.filterPredicates = Set(arrayLiteral: filterPredicate)
        
        //self.tableView.reloadData()
    }
    
    
    func setCollectionToDisplay(col : MPMediaItemCollection?) {
        collection = col
    }
    
    
    /**Return the song at the given indexpath. It correspond to the displayed information at the IndexPath.*/
    func songAtIndexPath(indexPath : NSIndexPath) -> MPMediaItem{
        //if collection speficied
        if let col = collection{
            return col.items[indexPath.row] 
        }
        
        //otherwise
        let mediaQuerySection = query.itemSections![indexPath.section] 
        let index = mediaQuerySection.range.location + indexPath.row
        return query.items![index]
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell){
            RPPlayer.player.addSongs([songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell){
            RPPlayer.player.addNextAndPlay([self.songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPathForCell(cell) {
            RPPlayer.player.addNext([self.songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if (collection != nil) {
            //if specify a collection
            return 1
        }
        //otherwise, if nothing specified
        return self.query.itemSections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let col = collection {
            //if a collection is speficied
            return col.count
        }
        //otherwise, if nothing specified, all songs
        return self.query.itemSections![section].range.length
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "song cell"
        
        tableView.registerNib(UINib(nibName: "RPCellSong", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RPCell
        cell.delegate = self
        //cell.rightViewOffSet = 80
        
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        let song = self.songAtIndexPath(indexPath)
        let durationInSeconds = song.valueForProperty(MPMediaItemPropertyPlaybackDuration) as! Int
        
        titleLabel.text = song.valueForProperty(MPMediaItemPropertyTitle) as? String
        subtitleLabel.text = formatTimeToMinutesSeconds(durationInSeconds)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        songPicked(query.items![indexPath.row] as! MPMediaItem)
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - RPSearchTVC delegate
    
    func songPicked(song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action",
            delegate: songActionDelegate,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: nil,
            otherButtonTitles: "Play next", "Play now", "Add to Queue")
        
        actionSheet.showInView(self.view)
    }
    func albumPicked(album: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue song to song", sender: album)
    }
    func artistPicked(artist: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue song to album", sender: artist)
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "segue song to album"){
            let dest = segue.destinationViewController as! RPAlbumTVC
            let artist = sender as? MPMediaItemCollection
            dest.filterAlbumForArtist(artist!)
        }
        else if(segue.identifier == "segue song to song"){
            let dest = segue.destinationViewController as! RPSongTVC
            dest.filterSongForAlbum(sender as? MPMediaItemCollection)
        }
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - Button from pannel and actionsheet
    
    @IBAction func sortButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Sort", delegate: self, cancelButtonTitle: "None", destructiveButtonTitle: nil, otherButtonTitles: "Alphabetically")
        actionSheet.tag = TAG_ACTIONSHEET_SORT
        actionSheet.showFromRect((sender as! UIButton).frame, inView: self.view, animated: true);
    }
    
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        
    }
    
    func sortAlpha(a: MPMediaItem, b:MPMediaItem) -> Bool {
        return (a.valueForProperty(MPMediaItemPropertyTitle) as! String) < (b.valueForProperty(MPMediaItemPropertyTitle) as! String)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        dprint("HELLO");
        
        if(actionSheet.tag == TAG_ACTIONSHEET_SORT){
            switch(buttonIndex){
            case 0:
                dprint("none")
                collection = nil
            case 1:
                dprint("alpha")
                var songsSorted = Array<MPMediaItem>()
                if(collection != nil){
                    songsSorted = (collection?.items)!
                }
                else{
                    songsSorted = query.items!
                }
                songsSorted.sortInPlace(sortAlpha)
                
                collection = MPMediaItemCollection(items: songsSorted)

            default:
                dprint("default")
            };
            self.tableView.reloadData()
            
        }
        //else if()
    }
    
    
    
}
