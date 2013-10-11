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
    NSString *html = [NSString stringWithFormat:@"\
    <html><head>\
    <style type=\"text/css\">\
    body {    background-color: transparent;\
    color: white; \
    }\
    </style>\
    </head><body style=\"margin:0\">\
    <iframe class=\"youtube-player\" width=\"320\" height=\"300\" src=\"%@\" frameborder=\"0\" allowfullscreen=\"true\"></iframe>\
    </body></html>", self.video.url];

    [self.webView loadHTMLString:html baseURL:nil];
    
    /*NSURL* url = [NSURL URLWithString:self.video.url];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];*/
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
