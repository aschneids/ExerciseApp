//
//  SFVideoListCell.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/7/13.
//
//

#import <UIKit/UIKit.h>

@interface SFVideoListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoLengthLabel;

@end
