//
//  RPArtistTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 15.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPArtistTVC: UIViewController, RPSwipableTVCellDelegate, UISearchDisplayDelegate, UISearchBarDelegate, RPSearchTVCDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var query : MPMediaQuery
    var collectionSections : [MPMediaQuerySection]?
    let cellHeight = 55
    
    var querySearchArtist : MPMediaQuery?
    var querySearchAlbum : MPMediaQuery?
    var querySearchSong : MPMediaQuery?
    
    var v : UIView?
    var barWidthConstraints : [AnyObject] = []
    
    let CELL_IDENTIFIER = "artist cell"
    
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchTVC: RPSearchTVCTableViewController!
    
    var songActionDelegate : SongActionSheetDelegate?

    
    required init?(coder aDecoder: NSCoder)  {
        self.query = MPMediaQuery.artists()
        self.collectionSections = query.collectionSections
        super.init(coder: aDecoder)
    }
    
//    override init() {
//        self.query = MPMediaQuery.artistsQuery()
//        self.collectionSections = query.collectionSections
//        super.init()
//    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.query = MPMediaQuery.artists()
        self.collectionSections = query.collectionSections!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Artists"
        
        // #warning - verify compatibility with other swipableButton
        self.tableView.canCancelContentTouches = false
        


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
        
        
        //preload queue
        let vc = self.navigationController?.tabBarController?.childViewControllers
        dprint("nub: \(vc!.count)")
        if let viewControllers = vc{
            dprint("nub non opt: \(viewControllers.count)")
            for viewController in viewControllers
            {
                let navc = viewController as! UINavigationController
                
                if(navc.viewControllers[0].isKind(of: RPQueueTVC.classForCoder())){
                    //navc.viewControllers[0].view
                    dprint("hop")
                }
            }
        }
        
        //PANEL stuff
        //*********
//        let viewArray = NSBundle.mainBundle().loadNibNamed("panelSortSelect", owner: self, options: nil)
//        let viewB = viewArray[0] as UIView
//        
//        
//        
//        let navBarFrame = self.navigationController?.navigationBar.frame
//        
//        //self.navigationController?.navigationBar.addSubview(view)
//        
//        self.view.addSubview(viewB)
//        
//        //view.addSubview(view2)
//        
//        //view2.backgroundColor = UIColor.redColor()
//        
//        v = viewB
//        
//        var d = ["view": viewB]
//        
//        var y = self.navigationController?.navigationBar.frame.origin.y
//        var h = self.navigationController?.navigationBar.frame.size.height
//        
//        viewB.autoresizingMask = UIViewAutoresizing.None
//        viewB.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        
//        
//        var c9 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: d)
//        barWidthConstraints.extend( NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
//            options: NSLayoutFormatOptions.AlignAllBaseline,
//            metrics: ["dist" :  (h! + y!)],
//            views: d))
//        
//        self.view.addConstraints(c9)
//        self.view.addConstraints(barWidthConstraints)
//        
//        var bottomBorder = CALayer();
//        
//        dprint("\(viewB.frame.size.width)")
//        
//        bottomBorder.frame = CGRectMake(0.0, 34.5, viewB.frame.size.width, 0.5);
//        var color = UIColor.grayColor().colorWithAlphaComponent(0.7)
//        bottomBorder.backgroundColor = color.CGColor
//        viewB.layer.addSublayer(bottomBorder);
        
        
        
        //TableView nib for the cell
        self.tableView.register(UINib(nibName: "RPCellArtist", bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER)


    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        //        if let vb = self.v{
        //            self.view.removeConstraints(barWidthConstraints)
        //            barWidthConstraints.removeAll(keepCapacity: true)
        //
        //            let dic = ["view": vb]
        //
        //            var y = self.navigationController?.navigationBar.frame.origin.y
        //            var h = self.navigationController?.navigationBar.frame.size.height
        //
        //
        //            barWidthConstraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
        //                options: NSLayoutFormatOptions.AlignAllBaseline,
        //                metrics: ["dist" :  (h! + y!)],
        //                views: dic))
        //            
        //            self.view.addConstraints(barWidthConstraints)
        //        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //style
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = UIBarStyle.default

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Check that user authorized access to music
            checkMusicPermission()
    
    }
    
    func checkMusicPermission() {
        
        if #available(iOS 9.3, *) {
            if(MPMediaLibrary.authorizationStatus() == MPMediaLibraryAuthorizationStatus.denied){
                let alert = UIAlertController(title: "Music Access", message: "In order to access your music, we need you to grand access. Go in settings, Privacy, Media Library and allow the access for RandomPlayer. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                    self.checkMusicPermission()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //########################################################################
    //########################################################################
    
    // #pragma mark - other functions
    /**Return the artist at indexPath*/
    func artistAtIndexPath(_ indexPath : IndexPath) -> MPMediaItemCollection{
        if let mediaQuerySection = self.collectionSections?[(indexPath as NSIndexPath).section] {
            let artistIndex = mediaQuerySection.range.location + (indexPath as NSIndexPath).row
            
            return self.query.collections![artistIndex]
        }
        else {
            return MPMediaItemCollection()
        }
    }
    
    
    func artistAtIndexPath(_ indexPath : IndexPath, inQuery query:MPMediaQuery) -> MPMediaItemCollection{
        if let mediaQuerySection: AnyObject = self.collectionSections?[(indexPath as NSIndexPath).section] {
            let artistIndex = mediaQuerySection.range.location + (indexPath as NSIndexPath).row
            
            return (self.querySearchArtist?.collections![artistIndex])!
        }
        else {
            return MPMediaItemCollection()
        }
    }

    
    //########################################################################
    //########################################################################
    
    // #pragma mark - RPSwipableTVCell delegate methods

    
    func buttonLeftPressed(_ cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
            
            RPPlayer.player.addSongs(self.artistAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
            
            let song = self.artistAtIndexPath(path).items 
            RPPlayer.player.addNextAndPlay(song)
        }
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell){
            
            RPPlayer.player.addNext(self.artistAtIndexPath(path).items )
        }
        cell .hideBehindCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }


    //########################################################################
    //########################################################################
    
    // #pragma mark - Table view data source
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        guard let nbSections = collectionSections?.count else {
            return 0
        }
        
        if(self.searchDisplayController?.isActive ?? false){
            return nbSections
        }
        else {
            return nbSections
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let mediaQuerySection: AnyObject = self.collectionSections?[section] {
            return mediaQuerySection.range.length
        }
        else {
            return 0
        }
    }
    
    /**Return the title of the header for this section*/
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.collectionSections?[section].title
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if(index == 0){
            tableView.scrollRectToVisible(searchBar.frame, animated: false)
            return NSNotFound
        }
        return (index - 1)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        guard let collectionSections = collectionSections else {
            return nil
        }
        
        var indexTitles : Array<String> = Array()
        
        indexTitles.append(UITableViewIndexSearch)
        
        for section in collectionSections {
            indexTitles.append(section.title)
        }
        
        return indexTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //self.tableView.registerClass(RPSwipableTVCell.self, forCellReuseIdentifier: "cellArtistTVC")
        
        //if(self.searchDisplayController.active == false) {

        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as! RPCell
        
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        let artist : MPMediaItemCollection = artistAtIndexPath(indexPath)
   
        titleLabel?.text = artist.representativeItem!.value(forProperty: MPMediaItemPropertyArtist) as? String
        
        let nbSongTitle = RPTools.numberSongInCollection(artist)
        let nbAlbumTitle = RPTools.numberAlbumOfArtistFormattedString(artist)
        
        subtitleLabel?.text = "\(nbAlbumTitle), \(nbSongTitle)"
        
        
        cell.delegate = self
        //cell.rightViewOffSet = 80;
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = self.artistAtIndexPath(indexPath)
        self.performSegue(withIdentifier: "segue artist to album", sender: artist)
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
        actionSheet.show(in: self.view)
    }
    func albumPicked(_ album: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue artist to song", sender: album)
    }
    func artistPicked(_ artist: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue artist to album", sender: artist)
    }
    
    //************************************************************************
    //************************************************************************
    
    //#pragma mark - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if(segue.identifier == "segue artist to album"){
            let dest = segue.destination as! RPAlbumTVC
            dest.filterAlbumForArtist(sender as! MPMediaItemCollection)
        }
        else if(segue.identifier == "segue artist to song"){
            let dest = segue.destination as! RPSongTVC
            dest.filterSongForAlbum(sender as? MPMediaItemCollection)
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
