//
//  SFVideoListViewController.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/4/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface SFVideoListViewController : UITableViewController <SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITabBarItem *tabItem;

@end
