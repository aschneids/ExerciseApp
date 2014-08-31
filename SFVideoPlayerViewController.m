//
//  SFVideoPlayerViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 8/30/14.
//
//

#import "SFVideoPlayerViewController.h"
#import "Video.h"

@interface SFVideoPlayerViewController () <UIWebViewDelegate>

@property (nonatomic) Video *video;

@end

@implementation SFVideoPlayerViewController

- (id)initWithVideo:(Video *)video
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.video = video;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(10, 15, 50, 40);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    NSString *videoURL = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", self.video.videoID];
    
    CGRect frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60);
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
    videoView.backgroundColor = [UIColor clearColor];
    videoView.opaque = NO;
    videoView.delegate = self;
    [self.view addSubview:videoView];
    
    
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:50%%; margin-top:-130px;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", videoURL];
    
    [videoView loadHTMLString:videoHTML baseURL:nil];
}

- (void)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
