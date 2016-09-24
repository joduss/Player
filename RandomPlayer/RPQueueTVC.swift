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
    
    
    
    enum ActionSheetTag : Int { case emptyQueue, randomize, randomizeAdvanced }
    @IBOutlet weak var tableView: UITableView!
    
    var v : UIView?
    var barWidthConstraints : [NSLayoutConstraint] = []


    override func loadView() {
        super.loadView()
        
        //register for notif to update when song changed or queue changed
        NotificationCenter.default.addObserver(self, selector:#selector(RPQueueTVC.updateInformation), name: NSNotification.Name(rawValue: RPPlayerNotification.SongDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(RPQueueTVC.updateInformation), name: NSNotification.Name(rawValue: RPPlayerNotification.QueueDidChange), object: nil)
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
        var viewArray = Bundle.main.loadNibNamed("RPQueuePanelWhite", owner: self, options: nil)
        if(self.navigationController?.navigationBar.barStyle == UIBarStyle.blackTranslucent) {
            viewArray = Bundle.main.loadNibNamed("RPQueuePanelBlack", owner: self, options: nil)
        }
        let viewB = viewArray?[0] as! UIView
        
        self.view.addSubview(viewB)
        
        v = viewB

        let panelView = ["view": viewB]
        
        let navBarYOrigin = self.navigationController?.navigationBar.frame.origin.y
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        viewB.autoresizingMask = [] //UIViewAutoresizing.none
        viewB.translatesAutoresizingMaskIntoConstraints = false
        


        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: panelView)
        barWidthConstraints.append( contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-dist-[view(35)]",
            options: NSLayoutFormatOptions.alignAllLastBaseline,
            metrics: ["dist" :  (navBarHeight! + navBarYOrigin!)],
            views: panelView))
        
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        
        self.view.addConstraints(constraints)
        self.view.addConstraints(barWidthConstraints)
        
        let bottomBorder = CALayer();
        

        bottomBorder.frame = CGRect(x: 0.0, y: 34.5, width: viewB.frame.size.width, height: 0.5);
        let color = UIColor.gray.withAlphaComponent(0.7)
        bottomBorder.backgroundColor = color.cgColor
        viewB.layer.addSublayer(bottomBorder);
        

        
        //update information
        updateInformation()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData() // reload data in case the user add a song
        updateInformation()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        v = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()

        if let vb = self.v {
            self.view.removeConstraints(barWidthConstraints)
            barWidthConstraints.removeAll(keepingCapacity: true)

            let dic = ["view": vb]
            
            let navBarYOrigin = self.navigationController?.navigationBar.frame.origin.y
            let navBarHeight = self.navigationController?.navigationBar.frame.size.height
            
            let c = NSLayoutConstraint.constraints(withVisualFormat: "V:|-dist-[view(35)]",
                options: NSLayoutFormatOptions.alignAllLastBaseline,
                metrics: ["dist" :  (navBarHeight! + navBarYOrigin!)],
                views: dic)
            
            barWidthConstraints.append(contentsOf: c)
            
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

    
    @IBAction func randomize(_ sender: AnyObject) {
        RPPlayer.player.randomizeQueue()
        
        //reload and animate
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.middle)
    }
    
    
    @IBAction func randomizeAdvanced(_ sender: AnyObject) {
        RPPlayer.player.randomizeQueueAdvanced()
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.middle)
    }
    
    /**Is song is playing, ask if want to keep the song playing and remove the rest of the queue. If song is paused, everything is removed*/
    @IBAction func emptyAueue(_ sender: UIButton) {

        //Is song is paused, we empty the whole queue
        //if
        if(RPPlayer.player.playbackState == MPMusicPlaybackState.playing){
            let action = UIActionSheet(title: "Empty the queue", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Keep playing current song", "Stop and remove all")
            action.tag = ActionSheetTag.emptyQueue.rawValue
            action.show(from: sender.frame, in: self.view, animated: true)
        }
        else {
            RPPlayer.player.emptyQueue(true)
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
        }
        

        
    }
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - UIActionSheet delegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if(actionSheet.tag == ActionSheetTag.emptyQueue.rawValue){
            
            if(buttonIndex == 1) {
                //remove all except the playing item and continue playing
                if(RPPlayer.player.queue.count > 1){
                    RPPlayer.player.emptyQueue(false)
                    self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
                }
            }
            else if(buttonIndex == 2){
                //remove all and stop playing
                RPPlayer.player.emptyQueue(true)
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
            }
        }
    }
    
    
    
    
    //###################################################################################
    //###################################################################################
    // #pragma mark - Table view function

    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return RPPlayer.player.count()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "queue cell"
        
        tableView.register(UINib(nibName: "RPCellQueue", bundle: nil), forCellReuseIdentifier: identifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RPSimpleCell
        //cell.delegate = self

        // Configure the cell
        let mediaItem = RPPlayer.player.getQueueItem((indexPath as NSIndexPath).row)
        
        if let item = mediaItem {
            //let artistName = item.artist()
            //let albumName = item.albumTitle()
            //let songTitle = item.songTitle()
            cell.mainLabel.text = item.songTitle()
            cell.subLabel.text = item.artistFormatted() + " - " + item.albumTitleFormatted()
            
            if(RPPlayer.player.currentItemIndex == (indexPath as NSIndexPath).row){
                cell.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
            }
            else {
                cell.contentView.backgroundColor = UIColor.white
            }
            
            //load image async (smoother scroll)
            let imageView = cell.cellImageView
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async(execute: {() -> Void in
                
                let artworkImage = item.artworkImage(ofSize:(imageView?.bounds.size)!)
                
                DispatchQueue.main.async(execute: {() -> Void in
                    imageView?.image = artworkImage

                })
                
            })
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RPPlayer.player.playSong((indexPath as NSIndexPath).row)
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            RPPlayer.player.removeItemAtIndex((indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
