//
//  SFVideoListViewController.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface SFVideoListViewController : UIViewController <SKStoreProductViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITabBarItem *tabItem;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;

@end
