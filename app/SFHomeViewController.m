//
//  SFHomeViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//  Copyright (c) 2013 Lunde. All rights reserved.
//

#import "SFHomeViewController.h"
#import <Parse/Parse.h>

@implementation SFHomeViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
