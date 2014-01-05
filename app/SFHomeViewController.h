//
//  SFHomeViewController.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//  Copyright (c) 2013 Lunde. All rights reserved.
//

@interface SFHomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *introScrollView;
@property (weak, nonatomic) IBOutlet UITextView *disclaimerScrollView;

- (IBAction)swipeLeft:(id)sender;

@end
