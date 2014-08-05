//
//  RPSearchTVCTableViewController.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 04.08.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer


class RPSearchTVCTableViewController: UITableViewController, UISearchDisplayDelegate, UISearchBarDelegate {
    
    
    var querySearchArtist : MPMediaQuery
    var querySearchAlbum : MPMediaQuery
    var querySearchSong : MPMediaQuery
    
    override init(){
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init()
    }

    override init(style: UITableViewStyle) {
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init(style: style)
    }
    
    required init(coder aDecoder: NSCoder!)  {
        querySearchArtist = MPMediaQuery.artistsQuery()
        querySearchAlbum = MPMediaQuery.albumsQuery()
        querySearchSong = MPMediaQuery.songsQuery()
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
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

    // MARK: - Table view data source

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        switch(section){
        case 0:
            return "Artists"
        case 1:
            return "Album"
        case 2:
            return "Songs"
        default:
            return "ERROR"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.

        return 2
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var nbRows = 0
        var query = queryForSection(section)
        if(query == querySearchSong){
            return query.items.count
        }
        else {
            dprint("nb: \(query.collections.count)")
            return query.collections.count
        }
        
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if(indexPath.section == 1){
            return 60
        }
        return 55
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

        if(indexPath.section == 0) {
            let identifier = "artist cell"
            tableView.registerNib(UINib(nibName: "RPCellArtist", bundle: nil), forCellReuseIdentifier: identifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPCell
            
            let item = queryForSection(indexPath.section).collections[indexPath.row].representativeItem as MPMediaItem
            let songTitle = item.valueForProperty(MPMediaItemPropertyArtist) as String
            cell.mainLabel.text = songTitle
            
            cell.rightViewOffSet = 80
            return cell
        }
        else if(indexPath.section == 1){
            let identifier = "album cell"
            tableView.registerNib(UINib(nibName: "RPCellAlbum", bundle: nil), forCellReuseIdentifier: identifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPCell
            let item = queryForSection(indexPath.section).collections[indexPath.row].representativeItem as MPMediaItem
            let albumTitle = item.valueForProperty(MPMediaItemPropertyAlbumTitle) as String
            cell.mainLabel.text = albumTitle

            let artwork : MPMediaItemArtwork? = item.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            
            let artworkImage = artwork?.imageWithSize(CGSizeMake(60, 60))
            cell.cellImageView.image = artworkImage
            
            cell.rightViewOffSet = 80
            return cell
        }
        else {
            return nil
        }
        
        
        

    }
    

    func filterContentFor(searchText : String) {
        
        dprint("hello, I search Artist with: \(searchText)")
        querySearchArtist = MPMediaQuery.artistsQuery()
        let filterPredicate = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.Contains)
        
        querySearchArtist.filterPredicates = NSSet(object: filterPredicate)
        //self.tableView.reloadData()
        
        
        querySearchAlbum = MPMediaQuery.albumsQuery()
        let filterPredicateAlbum = MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.Contains)
        
        querySearchAlbum.filterPredicates = NSSet(object: filterPredicate)
        
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterContentFor(searchString)
        return true
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

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

}
