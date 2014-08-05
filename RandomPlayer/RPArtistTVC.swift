//
//  RPArtistTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 15.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPArtistTVC: UITableViewController, RPSwipableTVCellDelegate, UISearchDisplayDelegate, UISearchBarDelegate {
    
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // #warning - verify compatibility with other swipableButton
        self.tableView.canCancelContentTouches = false
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
            
            let nbSong = artist.items.count
            let nbAlbum = artist.count
            
            var nbSongTitle = ""
            var nbAlbumTitle = ""
            
            if(nbSong <= 1) {
                nbSongTitle = "song"
                nbAlbumTitle = "album"
            }
            else if(nbSong > 1 && nbAlbum <= 1) {
                nbSongTitle = "songs"
                nbAlbumTitle = "album"
            }
            else {
                nbSongTitle = "songs"
                nbAlbumTitle = "albums"
            }
            
            subtitleLabel.text = "\(nbAlbum) \(nbAlbumTitle), \(nbSong) \(nbSongTitle)"
            
            
            cell.delegate = self
            cell.rightViewOffSet = 80;
            
            return cell

//        }
//        else {
//            
//        }
        

    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("artistToAlbum", sender: indexPath)
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
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //************************************************************************
    //************************************************************************
    
    //#pragma mark - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "artistToAlbum"){
            dprint("prep")
            let dest = segue.destinationViewController as RPAlbumTVC
            dprint("prep2")

            let artist = self.artistAtIndexPath(sender as NSIndexPath)
            dprint("prep3")

            dest.filterAlbumForArtist(artist)
            dprint("prep4")

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
