//
//  SFVideoListViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//
//

#import "Video.h"
#import "SFVideoListCell.h"
#import "SFVideoListViewController.h"
#import "SFVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

@interface SFVideoListViewController () {

    NSMutableArray *_videoArr;
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation SFVideoListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _videoArr = [[NSMutableArray alloc] init];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [_activityIndicator startAnimating];
    
    [self downloadVideoData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadVideoData
{
    PFQuery *query = [PFQuery queryWithClassName:@"SFVideo"];
    [query whereKey:@"category" equalTo:self.tabItem.title];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d videos.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                Video *newVid = [[Video alloc] init];
                newVid.url = [object valueForKey:@"url"];
                newVid.title = [object valueForKey:@"title"];
                newVid.length = [object valueForKey:@"length"];
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

- (void)getThumbnailForUrl:(NSString *)url forImageView:(UIImageView *)imageView
{
    /*NSURL *videoURL = [NSURL URLWithString:url];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    UIImage *thumbnail = [player thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [player stop];
    return thumbnail;*/

    NSURL *videoURL = [NSURL URLWithString:url];
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            imageView.image = [UIImage imageWithCGImage:im];
        }
        else {
            NSLog(@"%@",[error localizedDescription]);
            imageView.image = [UIImage imageNamed:@"video_dummy"];
        }
    };
    
    CGSize maxSize = CGSizeMake(320, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
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
    [self getThumbnailForUrl:temp.url forImageView:cell.thumbnailImage];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SFVideoPlayerViewController *target = (SFVideoPlayerViewController*)[segue destinationViewController];
    Video *vid = [_videoArr objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    target.video = vid;
}

@end
