//
//  RPPlaylistTVCTableViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 11.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPPlaylistTVC: UIViewController, RPSearchTVCDelegate, RPSwipableTVCellDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var searchTVC: RPSearchTVCTableViewController!
    
    var songActionDelegate : SongActionSheetDelegate?

    
    var query = MPMediaQuery.playlists()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Playlists"
        
        //query.groupingType = MPMediaGrouping
        
        
        //dprint("\(query.collectionSections)")
        
        query.groupingType = MPMediaGrouping.playlist
        
//        dprint("nb: \(query.collections.count)")
//
//        var playlist = query.collections[11] as MPMediaPlaylist
////
////        dprint("name: \(playlist.name)")
////        
//        let id: AnyObject! = playlist.valueForProperty(MPMediaPlaylistPropertyPersistentID)
////        
////        
//        query = MPMediaQuery.songsQuery()
//        let p = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
//        query.filterPredicates = NSSet(object: p)
//        query.groupingType = MPMediaGrouping.Playlist
//
//        
//        dprint("nb: \(query.collections.count)")
//
//        let col = query.collections[0] as MPMediaItemCollection
//        
//        var a: AnyObject! = col.valueForKey("collections")
//        
//        dprint("\(a)")
//        
//        dprint("nb: \(query.collections.count)")

        //let picker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        
        //presentViewController(picker, animated: true, completion: nil)
        
        
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        songActionDelegate = nil
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return query.collections!.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "playlist cell"
        
        tableView.register(UINib(nibName: "RPCellPlaylist", bundle: nil), forCellReuseIdentifier: identifier)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPCell
        
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        if let playlist = query.collections?[(indexPath as NSIndexPath).row] as? MPMediaPlaylist {
            
            //dprint("\(playlist.valueForProperty(MPMediaItemP))")
            
            titleLabel?.text = playlist.name
            
            if(playlist.items.count > 0){
                subtitleLabel?.text = RPTools.numberSong(playlist.items)
            }
            else {
                subtitleLabel?.text = "No song"
            }
        }
        else {
            eprint("Inconsistency Error: no collection")
            subtitleLabel?.text = "Inconsistency Error: no collection"
        }
        
        
        
        cell.delegate = self
        //cell.rightViewOffSet = 80;
        
        return cell

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = query.collections![(indexPath as NSIndexPath).row] as! MPMediaPlaylist
        
        performSegue(withIdentifier: "segue playlist to song", sender: playlist)
    }


    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //########################################################################
    //########################################################################
    //#pragma mark - RPSearchTVC delegate
    
    func songPicked(_ song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action", delegate: songActionDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Play next", "Play now", "Add to Queue")
        actionSheet.show(in: self.view)    }
    
    func albumPicked(_ album: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue playlist to song", sender: album)
    }
    
    func artistPicked(_ artist: MPMediaItemCollection){
        self.performSegue(withIdentifier: "segue playlist to album", sender: artist)
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        dprint("segue: \(segue.identifier)")
        
        if(segue.identifier == "segue playlist to song") {
            let dest = segue.destination as! RPSongTVC

            if let playlist = sender as? MPMediaPlaylist
            {
                dest.setCollectionToDisplay(playlist)
                dest.title = playlist.name
            }
//            if((sender as AnyObject).isKind(of: MPMediaPlaylist)){
//                let playlist = sender as! MPMediaPlaylist
//                dest.setCollectionToDisplay(playlist)
//                dest.title = playlist.name
//            }
            else
            {
                //TODO fix
                let playlist = sender as! MPMediaPlaylist
                dest.setCollectionToDisplay(playlist)
                dest.title = playlist.name
            }
            
            
            
        }
        else if(segue.identifier == "segue playlist to album") {
            let dest = segue.destination as! RPAlbumTVC
            let artist = sender as! MPMediaItemCollection
            dest.filterAlbumForArtist(artist)
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
            let playlist = query.collections![(path as NSIndexPath).row] as! MPMediaPlaylist
            RPPlayer.player.addSongs(playlist.items )
        }
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell) {
            let playlist = query.collections![(path as NSIndexPath).row] as! MPMediaPlaylist
            RPPlayer.player.addNextAndPlay(playlist.items )
        }
        cell.hideBehindCell()
    }
    
    func buttonRightPressed(_ cell: RPSwipableTVCell!) {
        if let path = self.tableView.indexPath(for: cell) {
            let playlist = query.collections![(path as NSIndexPath).row] as! MPMediaPlaylist
            RPPlayer.player.addNext(playlist.items )
            
            //let item = playlist.items[0]
            //let artistName = item.valueForProperty(MPMediaItemPropertyArtist) as String

            
            cell .hideBehindCell()
        }
    }
    
    
    


}
