//
//  Video.h
//  Stretch&Flex
//
//  Created by Ashley Schneider on 10/7/13.
//
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *length;
@property (strong, nonatomic) NSString *thumbnailUrl;

@end
