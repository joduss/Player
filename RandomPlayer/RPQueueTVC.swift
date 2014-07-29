//
//  RPQueueTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 13.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPQueueTVC: UITableViewController, UIActionSheetDelegate {
    
    enum ActionSheetTag : Int { case EmptyQueue, Randomize, RandomizeAdvanced }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController.toolbarHidden = false;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func randomize(sender: AnyObject) {
        // #warning Potentially incomplete method implementation.
    }
    
    
    @IBAction func randomizeAdvanced(sender: AnyObject) {
        // #warning Potentially incomplete method implementation.

    }
    
    /**Is song is playing, ask if want to keep the song playing and remove the rest of the queue. If song is paused, everything is removed*/
    @IBAction func emptyAueue(sender: UIBarButtonItem) {

        //Is song is paused, we empty the whole queue
        //if
        if(RPPlayer.player.playbackState == MPMusicPlaybackState.Playing){
            let action = UIActionSheet(title: "Empty the queue", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Keep playing current song", "Stop and remove all")
            action.tag = ActionSheetTag.EmptyQueue.toRaw()
            action.showFromBarButtonItem(sender, animated:true)
        }
        else {
            RPPlayer.player.emptyQueue(true)
            tableView.reloadData()
        }
        

        
    }
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - UIActionSheet delegate
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        
        if(actionSheet.tag == ActionSheetTag.EmptyQueue.toRaw()){
            if(buttonIndex == 1) {
                RPPlayer.player.emptyQueue(false)
            }
            else if(buttonIndex == 2){
                RPPlayer.player.emptyQueue(true)
            }
            tableView.reloadData()
        }
    }
    
    
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - Table view function

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return RPPlayer.player.getQueue().count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell
        let arraySongs = RPPlayer.player.getQueue()
        let mediaItem = arraySongs[indexPath.row]
        
        let artistName = mediaItem.valueForProperty(MPMediaItemPropertyArtist) as String
        let songTitle = mediaItem.valueForProperty(MPMediaItemPropertyTitle) as String
        
        cell.textLabel.text = songTitle + " - " + artistName
        
        return cell
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Notification from player
    

    

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

}
