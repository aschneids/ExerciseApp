//
//  SFVideoListViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//
//

#import "Video.h"
#import "SFAppDelegate.h"
#import "SFVideoListCell.h"
#import "SFVideoListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import "SFVideoPlayerViewController.h"

@interface SFVideoListViewController () {

    NSMutableArray *_videoArr;
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation SFVideoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = self.tabBarItem.title;
    
    _videoArr = [[NSMutableArray alloc] init];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [_activityIndicator startAnimating];
    
    [self downloadVideoData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForVideoUpdates) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)requestFullVersionProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.Lunde.Stretch-Flex.fullVersion" ];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    SKProduct *fullVersion = [products count] == 1 ? [products firstObject] : nil;
    if (fullVersion)
    {
        NSLog(@"Product title: %@" , fullVersion.localizedTitle);
        NSLog(@"Product description: %@" , fullVersion.localizedDescription);
        NSLog(@"Product price: %@" , fullVersion.price);
        NSLog(@"Product id: %@" , fullVersion.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *vid = [_videoArr objectAtIndex:self.tableView.indexPathForSelectedRow.row];
//    if (vid.isAvailableInLite == NO) {
//        [self requestFullVersionProductData];
//    } else {
//        XCDYouTubeVideoPlayerViewController *target = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:vid.videoID];
//        [self presentMoviePlayerViewControllerAnimated:target];
//    }
    
    SFVideoPlayerViewController *videoPlayerViewController = [[SFVideoPlayerViewController alloc] initWithVideo:vid];
    videoPlayerViewController.view.backgroundColor = [UIColor blackColor];
    [self presentViewController:videoPlayerViewController animated:YES completion:nil];
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
