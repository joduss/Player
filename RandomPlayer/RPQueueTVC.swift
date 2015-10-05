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
    var barWidthConstraints : [NSLayoutConstraint] = []


    override func loadView() {
        super.loadView()
        
        //register for notif to update when song changed or queue changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("updateInformation"), name: RPPlayerNotification.SongDidChange, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("updateInformation"), name: RPPlayerNotification.QueueDidChange, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.navigationController.toolbarHidden = false;
        
        //[[NSBundle mainBundle] loadNibNamed:@"NewMiddleContent" owner:self options:nil];
        
        
        //Add a panel just under the navitation bar
        var viewArray = NSBundle.mainBundle().loadNibNamed("RPQueuePanelWhite", owner: self, options: nil)
        if(self.navigationController?.navigationBar.barStyle == UIBarStyle.BlackTranslucent) {
            viewArray = NSBundle.mainBundle().loadNibNamed("RPQueuePanelBlack", owner: self, options: nil)
        }
        let viewB = viewArray[0] as! UIView
        
        self.view.addSubview(viewB)
        
        v = viewB

        let panelView = ["view": viewB]
        
        let navBarYOrigin = self.navigationController?.navigationBar.frame.origin.y
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        viewB.autoresizingMask = UIViewAutoresizing.None
        viewB.translatesAutoresizingMaskIntoConstraints = false
        


        
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: panelView)
        barWidthConstraints.appendContentsOf( NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
            options: NSLayoutFormatOptions.AlignAllBaseline,
            metrics: ["dist" :  (navBarHeight! + navBarYOrigin!)],
            views: panelView))
        
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        
        self.view.addConstraints(constraints)
        self.view.addConstraints(barWidthConstraints)
        
        let bottomBorder = CALayer();
        

        bottomBorder.frame = CGRectMake(0.0, 34.5, viewB.frame.size.width, 0.5);
        let color = UIColor.grayColor().colorWithAlphaComponent(0.7)
        bottomBorder.backgroundColor = color.CGColor
        viewB.layer.addSublayer(bottomBorder);
        

        
        //update information
        updateInformation()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() // reload data in case the user add a song
        updateInformation()
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        v = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()

        if let vb = self.v {
            self.view.removeConstraints(barWidthConstraints)
            barWidthConstraints.removeAll(keepCapacity: true)

            let dic = ["view": vb]
            
            let navBarYOrigin = self.navigationController?.navigationBar.frame.origin.y
            let navBarHeight = self.navigationController?.navigationBar.frame.size.height
            
            let c = NSLayoutConstraint.constraintsWithVisualFormat("V:|-dist-[view(35)]",
                options: NSLayoutFormatOptions.AlignAllBaseline,
                metrics: ["dist" :  (navBarHeight! + navBarYOrigin!)],
                views: dic)
            
            barWidthConstraints.appendContentsOf(c)
            
            self.view.addConstraints(barWidthConstraints)
        }
        

    }

    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //###################################################################################
    //###################################################################################
    // #pragma mark - Update informations
    
    func updateInformation() {
        self.tableView.reloadData()
        if(RPPlayer.player.queue.count == 0){
            self.title = "Queue"
        }
        else {
            self.title = "\(RPPlayer.player.currentItemIndex + 1) / \(RPPlayer.player.queue.count)"
        }
    }
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - Buttons
    
    
//    @IBAction func back(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }

    
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if(actionSheet.tag == ActionSheetTag.EmptyQueue.rawValue){
            
            if(buttonIndex == 1) {
                //remove all except the playing item and continue playing
                if(RPPlayer.player.queue.count > 1){
                    RPPlayer.player.emptyQueue(false)
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                }
            }
            else if(buttonIndex == 2){
                //remove all and stop playing
                RPPlayer.player.emptyQueue(true)
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            }
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
        return RPPlayer.player.count()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "queue cell"
        
        tableView.registerNib(UINib(nibName: "RPCellQueue", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RPSimpleCell
        //cell.delegate = self

        // Configure the cell
        let mediaItem = RPPlayer.player.getQueueItem(indexPath.row)
        
        if let item = mediaItem {
            //let artistName = item.artist()
            //let albumName = item.albumTitle()
            //let songTitle = item.songTitle()
            cell.mainLabel.text = item.songTitle()
            cell.subLabel.text = item.artistFormatted() + " - " + item.albumTitleFormatted()
            
            if(RPPlayer.player.currentItemIndex == indexPath.row){
                cell.contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
            }
            else {
                cell.contentView.backgroundColor = UIColor.whiteColor()
            }
            
            //load image async (smoother scroll)
            let imageView = cell.cellImageView
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {() -> Void in
                
                let artworkImage = item.artworkImage(ofSize:imageView.bounds.size)
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    imageView.image = artworkImage

                })
                
            })
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
