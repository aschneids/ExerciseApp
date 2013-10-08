//
//  SFVideoPlayerViewController.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/8/13.
//
//

#import "Video.h"
#import <UIKit/UIKit.h>

@interface SFVideoPlayerViewController : UIViewController <UIToolbarDelegate>

@property (strong, nonatomic) Video *video;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)handleTapGesture:(id)sender;

@end
