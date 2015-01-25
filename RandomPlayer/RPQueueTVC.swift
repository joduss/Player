//
//  RPQueueTVC.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 13.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import UIKit
import MediaPlayer

class RPQueueTVC: UIViewController, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    //Constants
    let ROW_HEIGHT = 55.0
    
    
    
    enum ActionSheetTag : Int { case EmptyQueue, Randomize, RandomizeAdvanced }
    @IBOutlet weak var tableView: UITableView!
    
    var v : UIView?
    var barWidthConstraints : [AnyObject] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.navigationController.toolbarHidden = false;
        
        //[[NSBundle mainBundle] loadNibNamed:@"NewMiddleContent" owner:self options:nil];
        
        let viewArray = NSBundle.mainBundle().loadNibNamed("test", owner: self, options: nil)
        let viewB = viewArray[0] as UIView
        
        
        
        let navBarFrame = self.navigationController?.navigationBar.frame
        
        //self.navigationController?.navigationBar.addSubview(view)
        
        self.view.addSubview(viewB)
        
        //view.addSubview(view2)
        
        //view2.backgroundColor = UIColor.redColor()

        v = viewB

        var d = ["view": viewB]
        
        var y = self.navigationController?.navigationBar.frame.origin.y
        var h = self.navigationController?.navigationBar.frame.size.height
        
        viewB.autoresizingMask = UIViewAutoresizing.None
        viewB.setTranslatesAutoresizingMaskIntoConstraints(false)
        

        
        var c9 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: d)
        barWidthConstraints.extend( NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
            options: NSLayoutFormatOptions.AlignAllBaseline,
            metrics: ["dist" :  (h! + y!)],
            views: d))
        
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        
        self.view.addConstraints(c9)
        self.view.addConstraints(barWidthConstraints)
        
        var bottomBorder = CALayer();
        
        dprint("\(viewB.frame.size.width)")
        
        bottomBorder.frame = CGRectMake(0.0, 34.5, viewB.frame.size.width, 0.5);
        var color = UIColor.grayColor().colorWithAlphaComponent(0.7)
        bottomBorder.backgroundColor = color.CGColor
        viewB.layer.addSublayer(bottomBorder);
        
        
        
        //register for notif to update when song changed
        NSNotificationCenter.defaultCenter().addObserverForName(RPPlayerNotification.SongDidChange, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {notif in
                self.tableView.reloadData()
            if(RPPlayer.player.queue.count == 0){
                self.title = "Queue"
            }
            else {
                self.title = "\(RPPlayer.player.currentItemIndex + 1) / \(RPPlayer.player.queue.count)"
            }            }
        )

        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() // reload data in case the user add a song
        if(RPPlayer.player.queue.count == 0){
            self.title = "Queue"
        }
        else {
            self.title = "\(RPPlayer.player.currentItemIndex + 1) / \(RPPlayer.player.queue.count)"
        }
    }

    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if let vb = self.v{
            self.view.removeConstraints(barWidthConstraints)
            barWidthConstraints.removeAll(keepCapacity: true)

            let dic = ["view": vb]
            
            var y = self.navigationController?.navigationBar.frame.origin.y
            var h = self.navigationController?.navigationBar.frame.size.height

            
            barWidthConstraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
                options: NSLayoutFormatOptions.AlignAllBaseline,
                metrics: ["dist" :  (h! + y!)],
                views: dic))
            
            self.view.addConstraints(barWidthConstraints)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func randomize(sender: AnyObject) {
        RPPlayer.player.randomizeQueue()
        
        //reload and animate
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Middle)
    }
    
    
    @IBAction func randomizeAdvanced(sender: AnyObject) {
        RPPlayer.player.randomizeQueueAdvanced()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Middle)
    }
    
    /**Is song is playing, ask if want to keep the song playing and remove the rest of the queue. If song is paused, everything is removed*/
    @IBAction func emptyAueue(sender: UIButton) {

        //Is song is paused, we empty the whole queue
        //if
        if(RPPlayer.player.playbackState == MPMusicPlaybackState.Playing){
            let action = UIActionSheet(title: "Empty the queue", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Keep playing current song", "Stop and remove all")
            action.tag = ActionSheetTag.EmptyQueue.rawValue
            action.showFromRect(sender.frame, inView: self.view, animated: true)
        }
        else {
            RPPlayer.player.emptyQueue(true)
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
        }
        

        
    }
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - UIActionSheet delegate
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        
        if(actionSheet.tag == ActionSheetTag.EmptyQueue.rawValue){
            if(buttonIndex == 1) {
                RPPlayer.player.emptyQueue(false)
            }
            else if(buttonIndex == 2){
                RPPlayer.player.emptyQueue(true)
            }
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
        }
    }
    
    
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - Table view function

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return RPPlayer.player.getQueue().count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "queue cell"
        
        tableView.registerNib(UINib(nibName: "RPCellQueue", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as RPSimpleCell
        //cell.delegate = self

        // Configure the cell
        let mediaItem = RPPlayer.player.getQueueItem(indexPath.row)
        
        if let item = mediaItem {
            let artistName = item.artist()
            let albumName = item.albumTitle()
            let songTitle = item.songTitle()
            cell.mainLabel.text = songTitle
            cell.subLabel.text = artistName + " - " + albumName
            
            if(RPPlayer.player.currentItemIndex == indexPath.row){
                cell.contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
            }
            else {
                cell.contentView.backgroundColor = UIColor.whiteColor()
            }
            
            //load image async (smoother scroll)
            let imageView = cell.cellImageView
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                
                var artworkImage = item.artworkImage(ofSize:imageView.bounds.size)
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    imageView.image = artworkImage

                })
                
            })
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO
        RPPlayer.player.playSong(indexPath.row)
        self.tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            RPPlayer.player.removeItemAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(ROW_HEIGHT)
    }
    
    
    //########################################################################
    //########################################################################
    // #pragma mark - Notification from player
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
