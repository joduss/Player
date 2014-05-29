//
//  RPPlayerViewController.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 26.05.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPPlayerViewController.h"

@interface RPPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAlbum;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelArtistAlbum;
@property (weak, nonatomic) IBOutlet UISlider *sliderTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderVolume;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;

@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) MPMusicPlayerController *musicPlayer;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation RPPlayerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //UIImage *empty = [UIImage new];
    [_sliderTime setThumbImage:[UIImage alloc] forState:UIControlStateNormal];
    
    
    // instantiate a music player
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //update the button state and information and subscribe to NotifCenter
    [self beginPlaybackNotifications];
    [self updateInformation];
    [_timer invalidate]; //to be sure that there is no more than 1 unique timer working
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeSlider:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self endPlaybackNotifications];
    [_timer invalidate]; //no need to update the timer
    _timer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _timer = nil;
    // Dispose of any resources that can be recreated.
}



#pragma mark - controls

- (IBAction)playPressed:(id)sender {
    
    if([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
    {
        //PAUSES THE PLAYER
        [_musicPlayer pause];
    }
    else
    {
        //START playing
        [_musicPlayer play];
    }
}

- (IBAction)previousPressed:(id)sender {
    int currentTime = [_musicPlayer currentPlaybackTime];
    //If the song time is < 5 secondes, we skip to the previous,
    //otherwise, just play the current song from the beginning
    if(currentTime < 5)
    {
        [_musicPlayer skipToPreviousItem];
    }
    else
    {
        [_musicPlayer setCurrentPlaybackTime:0];
    }

}

- (IBAction)nextPressed:(id)sender {
    [_musicPlayer skipToNextItem];
}


#pragma mark - information shown
/*!
 * update the time slider each second
 */
-(void)updateTimeSlider:(NSTimer *)timer
{
    int currentTime = [_musicPlayer currentPlaybackTime];
    NSNumber *duration = [_musicPlayer.nowPlayingItem valueForKey:MPMediaItemPropertyPlaybackDuration];
    [_sliderTime setMaximumValue:duration.intValue];
    [_sliderTime setMinimumValue:0];
    [_sliderTime setValue:currentTime animated:YES];
    //TODO verify that it is still playing
}

/*!
 * Update the information on screen when the song change
 * but also check the state of the player to update
 * pause/play button in case of a stop
 */
-(void)updateInformation
{
    if([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying)
    {
        [_buttonPlayPause setTitle:@"PAUSE" forState:UIControlStateNormal]; //show button to pause (a bit mind fuck)
    }
    else
    {
        //NEW STATE = PAUSE
        [_buttonPlayPause setTitle:@"PLAY" forState:UIControlStateNormal]; //show button to play (a bit mind fuck)
    }
    
    //In any cases, we update the information
    MPMediaItem *song = _musicPlayer.nowPlayingItem;
    
    NSString *artist = [song valueForKey:MPMediaItemPropertyArtist];
    NSString *album = [song valueForKey:MPMediaItemPropertyAlbumTitle];
    [_labelArtistAlbum setText: [NSString stringWithFormat:@"%@ - %@", artist, album]];
    [_labelTitle setText:[song valueForKey:MPMediaItemPropertyTitle]];
}



/*!
 * Subscribe to the notification center to be notified when song changed
 */
-(void)beginPlaybackNotifications
{
    [_musicPlayer beginGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateInformation)
     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateInformation)
     name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:nil];
}

/*!
 * UNSubscribe to the notification center
 */
-(void)endPlaybackNotifications
{
    [_musicPlayer endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
