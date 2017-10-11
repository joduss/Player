//
//  RPSongTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 17.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPSongTVC: UIViewController, RPSwipableTVCellDelegate, RPSearchTVCDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var query : MPMediaQuery
    var collection : MPMediaItemCollection?
    var collectionBeforeSort : MPMediaItemCollection?
    var songActionDelegate : SongActionSheetDelegate?
    
    var panel: UIView?
    var panelYConstraints : [NSLayoutConstraint] = []
    
    var panelSortLabel : UIButton!
    var panelFilterLabel : UIButton!

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
        query = MPMediaQuery.songs()
        super.init(coder: aDecoder)
    }
    
//    override init() {
//        query = MPMediaQuery.songsQuery()
//        super.init()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        query = MPMediaQuery.songs()
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
        let b = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y + searchBar.bounds.size.height,
            width: bounds.size.width,
            height: bounds.size.height
        )
        self.tableView.bounds = b;
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        //LOAD THE PANEL
        var viewArray = Bundle.main.loadNibNamed("PanelSortSelect", owner: self, options: nil)
        let panel = viewArray?[0] as! UIView
        
        self.view.addSubview(panel)
        
        let navBarOriginY = self.navigationController?.navigationBar.frame.origin.y
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        panel.autoresizingMask = [] // UIViewAutoresizing.none
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["panel" : panel]
        
        let constWidth = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[panel]-0-|",
            options: NSLayoutFormatOptions.alignAllLastBaseline,
            metrics: nil,
            views: viewDict)
        panelYConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-dist-[panel(35)]",
            options: NSLayoutFormatOptions.alignAllLastBaseline,
            metrics: ["dist" :  (navBarOriginY! + navBarHeight!)],
            views: viewDict)
        
        
        self.view.addConstraints(constWidth)
        self.view.addConstraints(panelYConstraints)
        
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0) //move so the the table start after the pannel
        self.panel = panel
        panelSortLabel = self.panel?.viewWithTag(7501) as! UIButton!
        panelFilterLabel = self.panel?.viewWithTag(7502) as! UIButton!
        panelSortLabel.setTitle("Sort: none", for: .normal)
        panelFilterLabel.alpha = 0

        //add line border on the bottom of the pannel
        let bottomBorder = CALayer();
        bottomBorder.frame = CGRect(x: 0.0, y: 34.5, width: panel.frame.size.width, height: 0.5);
        let color = UIColor.gray.withAlphaComponent(0.7)
        bottomBorder.backgroundColor = color.cgColor
        panel.layer.addSublayer(bottomBorder);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.panel = nil
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if let panelToUpdate = panel{
            self.view.removeConstraints(panelYConstraints)
            panelYConstraints.removeAll(keepingCapacity: true)
            
            let dic = ["panel": panelToUpdate]
            
            let navBarOriginY = self.navigationController?.navigationBar.frame.origin.y
            let navBarHeight = self.navigationController?.navigationBar.frame.size.height
            
            let c = NSLayoutConstraint.constraints(withVisualFormat: "V:|-dist-[panel(35)]",
                options: NSLayoutFormatOptions.alignAllLastBaseline,
                metrics: ["dist" :  (navBarHeight! + navBarOriginY!)],
                views: dic)
            
            panelYConstraints.append(contentsOf: c)
            
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
    func filterSongForAlbum(_ album : MPMediaItemCollection?) {
        
        self.collection = album
        collectionBeforeSort = album
        self.title = "salut" //String(album?.valueForProperty(MPMediaItemPropertyAlbumTitle) as NSString);
        //self.title = album.representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
        let filterPredicate = MPMediaPropertyPredicate(
            value: album!.representativeItem!.value(forProperty: MPMediaItemPropertyAlbumPersistentID),
            forProperty: MPMediaItemPropertyAlbumPersistentID)
        
        self.query.filterPredicates = Set(arrayLiteral: filterPredicate)
        
        //self.tableView.reloadData()
    }
    
    
    func setCollectionToDisplay(_ col : MPMediaItemCollection?) {
        collection = col
        collectionBeforeSort = col
    }
    
    
    /**Return the song at the given indexpath. It correspond to the displayed information at the IndexPath.*/
    func songAtIndexPath(_ indexPath : IndexPath) -> MPMediaItem{
        //if collection speficied
        if let col = collection {
            return col.items[(indexPath as NSIndexPath).row] 
        }
        
        //otherwise
        let mediaQuerySection = query.itemSections![(indexPath as NSIndexPath).section] 
        let index = mediaQuerySection.range.location + (indexPath as NSIndexPath).row
        return query.items![index]
    }
    
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(_ cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
            RPPlayer.player.addSongs([songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
            RPPlayer.player.addNextAndPlay([self.songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell) {
            RPPlayer.player.addNext([self.songAtIndexPath(path)])
        }
        cell .hideBehindCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    //************************************************************************
    //************************************************************************
    // #pragma mark - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if (collection != nil) {
            //if specify a collection
            return 1
        }
        //otherwise, if nothing specified
        return self.query.itemSections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let col = collection {
            //if a collection is speficied
            return col.count
        }
        //otherwise, if nothing specified, all songs
        return self.query.itemSections![section].range.length
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "song cell"
        
        tableView.register(UINib(nibName: "RPCellSong", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPCell
        cell.delegate = self
        //cell.rightViewOffSet = 80
        
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        let song = self.songAtIndexPath(indexPath)
        let durationInSeconds = song.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! Int
        
        titleLabel?.text = song.value(forProperty: MPMediaItemPropertyTitle) as? String
        subtitleLabel?.text = RPTools.formatTimeToMinutesSeconds(durationInSeconds)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songPicked(query.items![(indexPath as NSIndexPath).row] )
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - RPSearchTVC delegate
    
    func songPicked(_ song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action",
            delegate: songActionDelegate,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: nil,
            otherButtonTitles: "Play next", "Play now", "Add to Queue")
        
        actionSheet.show(in: self.view)
    }
    func albumPicked(_ album: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue song to song", sender: album)
    }
    func artistPicked(_ artist: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue song to album", sender: artist)
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if(segue.identifier == "segue song to album"){
            let dest = segue.destination as! RPAlbumTVC
            let artist = sender as? MPMediaItemCollection
            dest.filterAlbumForArtist(artist!)
        }
        else if(segue.identifier == "segue song to song"){
            let dest = segue.destination as! RPSongTVC
            dest.filterSongForAlbum(sender as? MPMediaItemCollection)
        }
    }
    
    
    //************************************************************************
    //************************************************************************
    //#pragma mark - Button from pannel and actionsheet
    
    @IBAction func sortButtonPressed(_ sender: AnyObject) {
        
        
        let actionSheet = UIAlertController(title: "Sort by", message: "How do you want to sort songs in the playlist?", preferredStyle: .actionSheet)
        //print("col: \(self.collection)")
        
        actionSheet.addAction(UIAlertAction(title: "Song title (A-Z)", style: .default, handler: { (action) in
            var songsSorted = Array<MPMediaItem>()
            //print("col: \(self.collection)")
            if let collection = self.collection {
                songsSorted = collection.items
            }
            else{
                songsSorted = self.query.items!
            }
            songsSorted.sort(by: self.sortAlpha)
            
            self.panelSortLabel.setTitle("Sort: Title (A-Z)", for: .normal)
            self.collection = MPMediaItemCollection(items: songsSorted)
            self.tableView.reloadData()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Song title (Z-A)", style: .default, handler: { (action) in
            var songsSorted = Array<MPMediaItem>()
            if let collection = self.collection{
                songsSorted = collection.items
            }
            else{
                songsSorted = self.query.items!
            }
            songsSorted.sort(by: self.sortAlphaDesc)
            
            self.collection = MPMediaItemCollection(items: songsSorted)
            self.panelSortLabel.setTitle("Sort: Title (Z-A)", for: .normal)
            self.tableView.reloadData()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "None", style: .default, handler: { (action) in
            self.collection = self.collectionBeforeSort
            self.panelSortLabel.setTitle("Sort: none", for: .normal)
            self.tableView.reloadData()
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        
//        let actionSheet = UIActionSheet(title: "Sort", delegate: self, cancelButtonTitle: "None", destructiveButtonTitle: nil, otherButtonTitles: "Song title (A-Z)")
//        actionSheet.tag = TAG_ACTIONSHEET_SORT
//        actionSheet.show(from: (sender as! UIButton).frame, in: self.view, animated: true);
    }
    
    
    @IBAction func filterButtonPressed(_ sender: AnyObject) {
        
    }
    
    func sortAlpha(_ a: MPMediaItem, b:MPMediaItem) -> Bool {
        return (a.value(forProperty: MPMediaItemPropertyTitle) as! String) < (b.value(forProperty: MPMediaItemPropertyTitle) as! String)
    }
    
    func sortAlphaDesc(_ a: MPMediaItem, b:MPMediaItem) -> Bool {
        return (a.value(forProperty: MPMediaItemPropertyTitle) as! String) > (b.value(forProperty: MPMediaItemPropertyTitle) as! String)
    }
    
    
//    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
//        dprint("HELLO");
//        
//        if(actionSheet.tag == TAG_ACTIONSHEET_SORT){
//            switch(buttonIndex){
//            case 0:
//                dprint("none")
//                collection = nil
//            case 1:
//                
//
//            default:
//                dprint("default")
//            };
//            self.tableView.reloadData()
//            
//        }
//        //else if()
//    }
    
    
    
}
