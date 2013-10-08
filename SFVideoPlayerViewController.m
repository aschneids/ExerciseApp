//
//  SFVideoPlayerViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/8/13.
//
//

#import "SFVideoPlayerViewController.h"

@interface SFVideoPlayerViewController ()

@end

@implementation SFVideoPlayerViewController

@synthesize video;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self playVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playVideo
{
    NSString *videoURL = @"http://www.youtube.com/embed/_01wJMrfLOM";
    NSURL* url = [NSURL URLWithString:videoURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleTapGesture:(id)sender {
    
    if (self.navBar.hidden == NO) {
        self.navBar.hidden = YES;
    } else if (self.navBar.hidden == YES) {
        self.navBar.hidden = NO;
    }
}

#pragma mark UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
