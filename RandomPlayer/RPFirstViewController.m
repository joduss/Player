////
////  RPFirstViewController.m
////  RandomPlayer
////
////  Created by Jonathan Duss on 23.01.14.
////  Copyright (c) 2014 Jonathan Duss. All rights reserved.
////
//
//#import "RPFirstViewController.h"
//
//@interface RPFirstViewController ()
//
//@end
//
//@implementation RPFirstViewController
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
//   didPickMediaItems: (MPMediaItemCollection *) collection {
//    
//    [self dismissModalViewControllerAnimated: YES];
//   // [self updatePlayerQueueWithMediaCollection: collection];
//}
//
//- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
//    
//    [self dismissModalViewControllerAnimated: YES];
//}
//
//
//- (IBAction)createNewRPList:(id)sender {
//    MPMediaPickerController *picker =
//    [[MPMediaPickerController alloc]
//     initWithMediaTypes: MPMediaTypeAnyAudio];                   // 1
//    
//    [picker setDelegate: self];                                         // 2
//    [picker setAllowsPickingMultipleItems: YES];                        // 3
//    picker.prompt =
//    NSLocalizedString (@"Add songs to play",
//                       "Prompt in media item picker");
//    
//    [self presentModalViewController: picker animated: YES];    // 4
//}
//
//@end
