//
//  XCDYouTubeVideoPlayerViewController.h
//  XCDYouTubeVideoPlayerViewController
//
//  Created by Cédric Luthi on 02.05.13.
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Cédric Luthi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, XCDYouTubeVideoQuality) {
	XCDYouTubeVideoQualitySmall240  = 36,
	XCDYouTubeVideoQualityMedium360 = 18,
	XCDYouTubeVideoQualityHD720     = 22,
	XCDYouTubeVideoQualityHD1080    = 37,
};

MP_EXTERN NSString *const XCDYouTubeVideoErrorDomain;
MP_EXTERN NSString *const XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey; // NSError key for the `MPMoviePlayerPlaybackDidFinishNotification` userInfo dictionary

enum {
	XCDYouTubeErrorInvalidVideoIdentifier = 2,   // The given `videoIdentifier` string is invalid (including `nil`)
	XCDYouTubeErrorRemovedVideo           = 100, // The video has been removed as a violation of YouTube's policy
	XCDYouTubeErrorRestrictedPlayback     = 150  // The video is not playable because of legal reasons or the this is a private video
};

MP_EXTERN NSString *const XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification;
// Metadata notification userInfo keys, they are all optional
MP_EXTERN NSString *const XCDMetadataKeyTitle;
MP_EXTERN NSString *const XCDMetadataKeySmallThumbnailURL;
MP_EXTERN NSString *const XCDMetadataKeyMediumThumbnailURL;
MP_EXTERN NSString *const XCDMetadataKeyLargeThumbnailURL;

@interface XCDYouTubeVideoPlayerViewController : MPMoviePlayerViewController

- (id) initWithVideoIdentifier:(NSString *)videoIdentifier;

@property (nonatomic, copy) NSString *videoIdentifier;

// On iPhone, defaults to @[ @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ]
// On iPad, defaults to @[ @(XCDYouTubeVideoQualityHD1080), @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ]
// If you really know what you are doing, you can use the `itag` values as described on http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
// Setting this property to nil restores its default values
@property (nonatomic, copy) NSArray *preferredVideoQualities;

// Ownership of the XCDYouTubeVideoPlayerViewController instance is transferred to the view.
- (void) presentInView:(UIView *)view;

@end