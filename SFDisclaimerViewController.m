//
//  SFDisclaimerViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/10/13.
//
//

#import "SFDisclaimerViewController.h"

@interface SFDisclaimerViewController ()

@end

@implementation SFDisclaimerViewController

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
	// Do any additional setup after loading the view.
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasAgreed"] == NO) {
        self.navItem.rightBarButtonItem = nil;
    } else {
        self.agreeButton.hidden = YES;
        CGRect frame = self.textView.frame;
        frame.size.height += self.agreeButton.frame.size.height;
        self.textView.frame = frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)agreeButtonTapped:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAgreed"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
