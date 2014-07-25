//
//  RPArtistTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 15.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPArtistTVC: UITableViewController, RPSwipableTVCellDelegate {
    
    
    
    var query : MPMediaQuery
    var collectionSections : Array<AnyObject>
    
    init(coder aDecoder: NSCoder!)  {
        self.query = MPMediaQuery.artistsQuery()
        self.collectionSections = query.collectionSections
        super.init(coder: aDecoder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // #warning - verify compatibility with other swipableButton
        self.tableView.canCancelContentTouches = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // Turn on remote control event delivery
        
        // Set itself as the first responder
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent!) {
        dprint("cool")
        if (event.type == UIEventType.RemoteControl) {
            
            switch (event.subtype) {
            case UIEventSubtype.RemoteControlNextTrack:
                dprint("HAHAHA")
            default:
                dprint("HOHOHO")
            }
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
    func artistAtIndexPath(indexPath : NSIndexPath) -> MPMediaItemCollection{
        let mediaQuerySection: AnyObject = self.collectionSections[indexPath.section]
        let artistIndex = mediaQuerySection.range.location + indexPath.row
        
        return self.query.collections[artistIndex] as MPMediaItemCollection
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
        
        
        RPPlayer.player.addNextAndPlay(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    
    func buttonRightPressed(cell: RPSwipableTVCell!) {
        let path = self.tableView.indexPathForCell(cell)
        
        RPPlayer.player.addNext(self.artistAtIndexPath(path).items as Array<MPMediaItem>)
        cell .hideBehindCell()
    }
    

    //########################################################################
    //########################################################################
    
    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return self.collectionSections.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as RPSwipableTVCell
        
        let titleLabel = self.view.viewWithTag(10) as UILabel
        
        let artist = self.artistAtIndexPath(indexPath)
        
        titleLabel.text = artist.representativeItem.valueForProperty(MPMediaItemPropertyArtist) as String
        
        cell.delegate = self
        cell.rightViewOffSet = 80;
        

        return cell
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
