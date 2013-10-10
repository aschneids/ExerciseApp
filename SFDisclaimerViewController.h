//
//  SFDisclaimerViewController.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/10/13.
//
//

#import <UIKit/UIKit.h>

@interface SFDisclaimerViewController : UIViewController <UIToolbarDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)agreeButtonTapped:(id)sender;

@end
