//
//  RPPlaylistTVCTableViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 11.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPPlaylistTVC: UITableViewController, RPSearchTVCDelegate, RPSwipableTVCellDelegate {

    @IBOutlet var searchTVC: RPSearchTVCTableViewController!
    
    var songActionDelegate : SongActionSheetDelegate?

    
    var query = MPMediaQuery.playlistsQuery()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Playlists"
        
        //query.groupingType = MPMediaGrouping
        
        
        //dprint("\(query.collectionSections)")
        
        query.groupingType = MPMediaGrouping.Playlist
        
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

        let picker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        
        //presentViewController(picker, animated: true, completion: nil)
        
        
        // RPSearchTVC setup
        searchTVC.delegate = self
        searchTVC.searchTableView = self.searchDisplayController.searchResultsTableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        songActionDelegate = nil
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return query.collections.count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let identifier = "playlist cell"
        
        tableView.registerNib(UINib(nibName: "RPCellPlaylist", bundle: nil), forCellReuseIdentifier: identifier)
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPCell
        
        let titleLabel = cell.mainLabel
        let subtitleLabel = cell.subLabel
        
        var playlist = query.collections[indexPath.row] as MPMediaPlaylist
        
        //dprint("\(playlist.valueForProperty(MPMediaItemP))")
        
        
        
        
        
        titleLabel.text = playlist.name
        
        //var nbSongTitle = RPTools.numberSongInCollection(MPMediaItemCollection(items: playlist.items))
        
        //subtitleLabel.text = "\(nbSongTitle)"
        
        
        cell.delegate = self
        //cell.rightViewOffSet = 80;
        
        return cell

    }
    
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 55
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
    
    func songPicked(song : MPMediaItem){
        if(songActionDelegate == nil){
            songActionDelegate = SongActionSheetDelegate()
        }
        songActionDelegate?.song = song
        let actionSheet = UIActionSheet(title: "Choose an action", delegate: songActionDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Play next", "Play now", "Add to Queue")
        actionSheet.showInView(self.view)    }
    func albumPicked(album: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue playlist to song", sender: album)
    }
    func artistPicked(artist: MPMediaItemCollection){
        self.performSegueWithIdentifier("segue playlist to album", sender: artist)
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "segue playlist to song") {
            let dest = segue.destinationViewController as RPSongTVC
            dest.filterSongForAlbum(sender as MPMediaItemCollection)
        }
        else if(segue.identifier == "segue playlist to album") {
            let dest = segue.destinationViewController as RPAlbumTVC
            let artist = sender as MPMediaItemCollection
            dest.filterAlbumForArtist(artist)
        }
    }
    
    //########################################################################
    //########################################################################
    
    // #pragma mark - RPSwipableTVCell delegate methods
    
    
    func buttonLeftPressed(cell: RPSwipableTVCell!) {
        //no left button
    }
    
    
    func buttonCenterLeftPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        //RPPlayer.player.addSongs(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    func buttonCenterRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
//        let song = self.artistAtIndexPath(path).items as Array<MPMediaItem>
//        RPPlayer.player.addNextAndPlay(song)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
//        RPPlayer.player.addNext(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    
    


}
