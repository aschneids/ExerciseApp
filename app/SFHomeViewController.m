//
//  SFHomeViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//  Copyright (c) 2013 Lunde. All rights reserved.
//

#import "SFAppDelegate.h"
#import "SFHomeViewController.h"
#import <Parse/Parse.h>

@interface SFHomeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end

@implementation SFHomeViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *tmString = [[NSMutableAttributedString alloc] initWithString:self.introTextView.text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]}];
    NSRange tmRange = [self.introTextView.text rangeOfString:@"TM"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:9.0];
    [tmString addAttributes:@{NSFontAttributeName:font} range:tmRange];
    self.introTextView.attributedText = tmString;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasAgreed"] == NO) {
        [self performSegueWithIdentifier:@"Disclaimer" sender:self];
    }
    
    CGSize scrollableSize = CGSizeMake(self.introScrollView.frame.size.width, self.introScrollView.frame.size.height);
    CGSize scrollableSize2 = CGSizeMake(self.disclaimerScrollView.frame.size.width, self.disclaimerScrollView.frame.size.height);
    [self.introScrollView setContentSize:scrollableSize];
    [self.disclaimerScrollView setContentSize:scrollableSize2];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)swipeLeft:(id)sender {
    SFAppDelegate *appDelegate = (SFAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController.selectedIndex--;
}

@end
