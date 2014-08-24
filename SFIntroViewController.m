//
//  SFIntroViewController.m
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/9/13.
//
//

#import "SFIntroViewController.h"

@interface SFIntroViewController ()

@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end

@implementation SFIntroViewController

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
    
    NSMutableAttributedString *tmString = [[NSMutableAttributedString alloc] initWithString:self.introTextView.text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]}];
    NSRange tmRange = [self.introTextView.text rangeOfString:@"TM"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:9.0];
    [tmString addAttributes:@{NSFontAttributeName:font} range:tmRange];
    self.introTextView.attributedText = tmString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
