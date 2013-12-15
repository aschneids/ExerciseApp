//
//  SFVideoListViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//
//

#import "XCDYouTubeVideoPlayerViewController.h"
#import "Video.h"
#import "SFAppDelegate.h"
#import "SFVideoListCell.h"
#import "SFVideoListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

@interface SFVideoListViewController () {

    NSMutableArray *_videoArr;
    UIActivityIndicatorView *_activityIndicator;
    BOOL firstLoad;
}
@end

@implementation SFVideoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstLoad = YES;
    self.titleLabel.text = self.tabBarItem.title;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(videoPlayerViewControllerDidReceiveMetadata:) name:XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

    _videoArr = [[NSMutableArray alloc] init];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [_activityIndicator startAnimating];
    
    [self downloadVideoData];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!firstLoad) [self checkForVideoUpdates];
    firstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkForVideoUpdates
{
    PFQuery *query = [PFQuery queryWithClassName:@"SFVideo"];
    [query whereKey:@"category" equalTo:self.tabItem.title];
    [query orderByAscending:@"sortID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects != nil) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d videos.", objects.count);
            BOOL reload = NO;
            NSMutableArray *newArr = [[NSMutableArray alloc] init];
            int i = 0;
            for (PFObject *object in objects) {
                if ([object valueForKey:@"videoID"] == nil || [object valueForKey:@"title"] == nil ||
                    [object valueForKey:@"length"] == nil || [object valueForKey:@"isAvailableInLite"] == nil) continue;
                Video *newVid = [[Video alloc] init];
                newVid.videoID = [object valueForKey:@"videoID"];
                newVid.title = [object valueForKey:@"title"];
                newVid.length = [object valueForKey:@"length"];
                newVid.isAvailableInLite = [[object valueForKey:@"isAvailableInLite"] boolValue];
                newVid.thumbnailUrl = [self generateYouTubeThumbnailUrlforID:[object valueForKey:@"videoID"]];
                if (i < [_videoArr count]) {
                    Video *oldVid = [_videoArr objectAtIndex:i];
                    if (![oldVid.videoID isEqualToString:newVid.videoID] || ![oldVid.title isEqualToString:newVid.title] ||
                        ![oldVid.length isEqualToString:newVid.length]) {
                        [newArr addObject:newVid];
                        reload = YES;
                    } else [newArr addObject:oldVid];
                } else {
                    [newArr addObject:newVid];
                    reload = YES;
                }
                
                i++;
            }
            
            if (reload || [_videoArr count] != [newArr count]) {
                _videoArr = newArr;
                [self.tableView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)downloadVideoData
{
    PFQuery *query = [PFQuery queryWithClassName:@"SFVideo"];
    [query whereKey:@"category" equalTo:self.tabItem.title];
    [query orderByAscending:@"sortID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects != nil) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d videos.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                if ([object valueForKey:@"videoID"] == nil || [object valueForKey:@"title"] == nil ||
                    [object valueForKey:@"length"] == nil || [object valueForKey:@"isAvailableInLite"] == nil) continue;
                Video *newVid = [[Video alloc] init];
                newVid.videoID = [object valueForKey:@"videoID"];
                newVid.title = [object valueForKey:@"title"];
                newVid.length = [object valueForKey:@"length"];
                newVid.isAvailableInLite = [[object valueForKey:@"isAvailableInLite"] boolValue];
                newVid.thumbnailUrl = [self generateYouTubeThumbnailUrlforID:[object valueForKey:@"videoID"]];
                [_videoArr addObject:newVid];
            }
            
            [self.tableView reloadData];
            [_activityIndicator stopAnimating];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSString *)generateYouTubeUrlforID:(NSString *)videoID
{
    return [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", videoID];
}

- (NSString *)generateYouTubeThumbnailUrlforID:(NSString *)videoID
{
    return [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", videoID];
}

- (void)getThumbnailForUrl:(NSString *)url forImageView:(UIImageView *)imageView
{
    NSURL *thumbnailUrl = [NSURL URLWithString:url];
    dispatch_queue_t fetchQ = dispatch_queue_create("ImageDownload", NULL);
    dispatch_async(fetchQ, ^{
        NSData *data = [NSData dataWithContentsOfURL:thumbnailUrl];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_videoArr count] > 0) return 1;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_videoArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoCell";
    SFVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SFVideoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  
    Video *temp = [_videoArr objectAtIndex:indexPath.row];
    cell.titleLabel.text = temp.title;
    cell.videoLengthLabel.text = temp.length;
    [self getThumbnailForUrl:temp.thumbnailUrl forImageView:cell.thumbnailImage];
    
    return cell;
}


#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *vid = [_videoArr objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    if ([SFAppDelegate isLiteVersion] && vid.isAvailableInLite == NO) {
        [self showAppWithIdentifier:@"669186589"];
    } else {
        XCDYouTubeVideoPlayerViewController *target = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:vid.videoID];
        [self presentMoviePlayerViewControllerAnimated:target];
    }
}

- (void)showAppWithIdentifier:(NSString *)identifier
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier:identifier};
    
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
                                       if (result)
                                           [self presentViewController:storeViewController animated:YES completion:nil];
                                   }];
}

#pragma mark SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications
- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
	NSString *reason = @"Unknown";
	switch (finishReason)
	{
		case MPMovieFinishReasonPlaybackEnded:
			reason = @"Playback Ended";
			break;
		case MPMovieFinishReasonPlaybackError:
			reason = @"Playback Error";
			break;
		case MPMovieFinishReasonUserExited:
			reason = @"User Exited";
			break;
	}
	NSLog(@"Finish Reason: %@%@", reason, error ? [@"\n" stringByAppendingString:[error localizedDescription]] : @"");
}

- (void) moviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	NSString *playbackState = @"Unknown";
	switch (moviePlayerController.playbackState)
	{
		case MPMoviePlaybackStateStopped:
			playbackState = @"Stopped";
			break;
		case MPMoviePlaybackStatePlaying:
			playbackState = @"Playing";
			break;
		case MPMoviePlaybackStatePaused:
			playbackState = @"Paused";
			break;
		case MPMoviePlaybackStateInterrupted:
			playbackState = @"Interrupted";
			break;
		case MPMoviePlaybackStateSeekingForward:
			playbackState = @"Seeking Forward";
			break;
		case MPMoviePlaybackStateSeekingBackward:
			playbackState = @"Seeking Backward";
			break;
	}
	NSLog(@"Playback State: %@", playbackState);
}

- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
    
	NSMutableString *loadState = [NSMutableString new];
	MPMovieLoadState state = moviePlayerController.loadState;
	if (state & MPMovieLoadStatePlayable)
		[loadState appendString:@" | Playable"];
	if (state & MPMovieLoadStatePlaythroughOK)
		[loadState appendString:@" | Playthrough OK"];
	if (state & MPMovieLoadStateStalled)
		[loadState appendString:@" | Stalled"];
    
	NSLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}

- (void) videoPlayerViewControllerDidReceiveMetadata:(NSNotification *)notification
{
	NSLog(@"Metadata: %@", notification.userInfo);
}


- (IBAction)swipeLeft:(id)sender {
    SFAppDelegate *appDelegate = (SFAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.tabBarController.selectedIndex == 0) return;
    appDelegate.tabBarController.selectedIndex--;
}

- (IBAction)swipeRight:(id)sender {
    SFAppDelegate *appDelegate = (SFAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.tabBarController.selectedIndex == 3) return;
    appDelegate.tabBarController.selectedIndex++;
}

@end
