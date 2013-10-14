//
//  XCDYouTubeVideoPlayerViewController.m
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

#import "XCDYouTubeVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

NSString *const XCDYouTubeVideoErrorDomain = @"XCDYouTubeVideoErrorDomain";
NSString *const XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey = @"XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey";

NSString *const XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification = @"XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification";
NSString *const XCDMetadataKeyTitle = @"Title";
NSString *const XCDMetadataKeySmallThumbnailURL = @"SmallThumbnailURL";
NSString *const XCDMetadataKeyMediumThumbnailURL = @"MediumThumbnailURL";
NSString *const XCDMetadataKeyLargeThumbnailURL = @"LargeThumbnailURL";

static NSDictionary *DictionaryWithQueryString(NSString *string, NSStringEncoding encoding)
{
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	NSArray *fields = [string componentsSeparatedByString:@"&"];
	for (NSString *field in fields)
	{
		NSArray *pair = [field componentsSeparatedByString:@"="];
		if (pair.count == 2)
		{
			NSString *key = pair[0];
			NSString *value = [pair[1] stringByReplacingPercentEscapesUsingEncoding:encoding];
			value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			dictionary[key] = value;
		}
	}
	return dictionary;
}

static NSString *ApplicationLanguageIdentifier(void)
{
	static NSString *applicationLanguageIdentifier;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		applicationLanguageIdentifier = @"en";
		NSArray *preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
		if (preferredLocalizations.count > 0)
			applicationLanguageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:preferredLocalizations[0]] ?: applicationLanguageIdentifier;
	});
	return applicationLanguageIdentifier;
}

@interface XCDYouTubeVideoPlayerViewController ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *connectionData;
@property (nonatomic, strong) NSMutableArray *elFields;
@property (nonatomic, assign, getter = isEmbedded) BOOL embedded;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation XCDYouTubeVideoPlayerViewController

static void *XCDYouTubeVideoPlayerViewControllerKey = &XCDYouTubeVideoPlayerViewControllerKey;

- (id) init
{
	return [self initWithVideoIdentifier:nil];
}

- (id) initWithContentURL:(NSURL *)contentURL
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Use the `initWithVideoIdentifier:` method instead." userInfo:nil];
}

- (id) initWithVideoIdentifier:(NSString *)videoIdentifier
{
	if (!(self = [super init]))
		return nil;
    
	self.preferredVideoQualities = nil;
    
	if (videoIdentifier)
		self.videoIdentifier = videoIdentifier;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(moviePlayerWillEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:self.moviePlayer];
	[defaultCenter addObserver:self selector:@selector(moviePlayerWillExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:self.moviePlayer];
	[defaultCenter addObserver:self selector:@selector(videoPlayerViewControllerDidReceiveMetadata:) name:XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

    
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setVideoIdentifier:(NSString *)videoIdentifier
{
	if (![NSThread isMainThread])
	{
		[self performSelectorOnMainThread:_cmd withObject:videoIdentifier waitUntilDone:NO];
		return;
	}
    
	if ([videoIdentifier isEqual:self.videoIdentifier])
		return;
    
	_videoIdentifier = [videoIdentifier copy];
    
	self.elFields = [[NSMutableArray alloc] initWithArray:@[ @"embedded", @"detailpage", @"vevo", @"" ]];
    
	[self startVideoInfoRequest];
}

- (void) setPreferredVideoQualities:(NSArray *)preferredVideoQualities
{
	if (preferredVideoQualities)
	{
		_preferredVideoQualities = [preferredVideoQualities copy];
	}
	else
	{
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
			_preferredVideoQualities = @[ @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
		else
			_preferredVideoQualities = @[ @(XCDYouTubeVideoQualityHD1080), @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
	}
}

- (void) presentInView:(UIView *)view
{
	self.embedded = YES;
    
	self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
	self.moviePlayer.view.frame = CGRectMake(0.f, 0.f, view.bounds.size.width, view.bounds.size.height);
	self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if (![view.subviews containsObject:self.moviePlayer.view])
		[view addSubview:self.moviePlayer.view];
	objc_setAssociatedObject(view, XCDYouTubeVideoPlayerViewControllerKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) startVideoInfoRequest
{
	NSString *elField = [self.elFields objectAtIndex:0];
	[self.elFields removeObjectAtIndex:0];
	if (elField.length > 0)
		elField = [@"&el=" stringByAppendingString:elField];
    
	NSURL *videoInfoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@%@&ps=default&eurl=&gl=US&hl=%@", self.videoIdentifier ?: @"", elField, ApplicationLanguageIdentifier()]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:videoInfoURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240];
	[request setValue:ApplicationLanguageIdentifier() forHTTPHeaderField:@"Accept-Language"];
	[self.connection cancel];
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) finishWithError:(NSError *)error
{
	NSDictionary *userInfo = @{ MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: @(MPMovieFinishReasonPlaybackError),
	                            XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey: error };
	[[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer userInfo:userInfo];
    
	if (self.isEmbedded)
		[self.moviePlayer.view removeFromSuperview];
	else
		[self.presentingViewController dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - UIViewController

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	if (![self isBeingPresented])
		return;
    
	self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
	[self.moviePlayer play];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	if (![self isBeingDismissed])
		return;
    
	[self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate / NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSUInteger capacity = response.expectedContentLength == NSURLResponseUnknownLength ? 0 : (NSUInteger)response.expectedContentLength;
	self.connectionData = [[NSMutableData alloc] initWithCapacity:capacity];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.connectionData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *error = nil;
	NSURL *videoURL = [self videoURLWithData:self.connectionData error:&error];
	if (videoURL)
		self.moviePlayer.contentURL = videoURL;
	else if (self.elFields.count > 0)
		[self startVideoInfoRequest];
	else
		[self finishWithError:error];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self finishWithError:error];
}

#pragma mark - Notifications

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
	NSString *reason = @"Unknown";
	switch (finishReason)
	{
		case MPMovieFinishReasonPlaybackEnded:
			reason = @"Playback Ended";
			break;
		case MPMovieFinishReasonPlaybackError:
			reason = @"Playback Error";
			break;
		case MPMovieFinishReasonUserExited:
			reason = @"User Exited";
			break;
	}
	NSLog(@"Finish Reason: %@%@", reason, error ? [@"\n" stringByAppendingString:[error description]] : @"");
}

- (void) moviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	NSString *playbackState = @"Unknown";
	switch (moviePlayerController.playbackState)
	{
		case MPMoviePlaybackStateStopped:
			playbackState = @"Stopped";
			break;
		case MPMoviePlaybackStatePlaying:
			playbackState = @"Playing";
			break;
		case MPMoviePlaybackStatePaused:
			playbackState = @"Paused";
			break;
		case MPMoviePlaybackStateInterrupted:
			playbackState = @"Interrupted";
			break;
		case MPMoviePlaybackStateSeekingForward:
			playbackState = @"Seeking Forward";
			break;
		case MPMoviePlaybackStateSeekingBackward:
			playbackState = @"Seeking Backward";
			break;
	}
	NSLog(@"Playback State: %@", playbackState);
}

- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
    
	NSMutableString *loadState = [NSMutableString new];
	MPMovieLoadState state = moviePlayerController.loadState;
	if (state & MPMovieLoadStatePlayable)
		[loadState appendString:@" | Playable"];
	if (state & MPMovieLoadStatePlaythroughOK)
		[loadState appendString:@" | Playthrough OK"];
	if (state & MPMovieLoadStateStalled)
		[loadState appendString:@" | Stalled"];
    
	NSLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}

- (void) videoPlayerViewControllerDidReceiveMetadata:(NSNotification *)notification
{
	NSLog(@"Metadata: %@", notification.userInfo);
}

- (void) moviePlayerWillEnterFullscreen:(NSNotification *)notification
{
	UIApplication *application = [UIApplication sharedApplication];
	self.statusBarHidden = application.statusBarHidden;
	self.statusBarStyle = application.statusBarStyle;
}

- (void) moviePlayerWillExitFullscreen:(NSNotification *)notification
{
	UIApplication *application = [UIApplication sharedApplication];
	[application setStatusBarHidden:self.statusBarHidden withAnimation:UIStatusBarAnimationFade];
	[application setStatusBarStyle:self.statusBarStyle animated:YES];
}

#pragma mark - URL Parsing

- (NSURL *) videoURLWithData:(NSData *)data error:(NSError * __autoreleasing *)error
{
	NSString *videoQuery = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSStringEncoding queryEncoding = NSUTF8StringEncoding;
	NSDictionary *video = DictionaryWithQueryString(videoQuery, queryEncoding);
	NSArray *streamQueries = [video[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","];
    
	NSMutableDictionary *streamURLs = [NSMutableDictionary new];
	for (NSString *streamQuery in streamQueries)
	{
		NSDictionary *stream = DictionaryWithQueryString(streamQuery, queryEncoding);
		NSString *type = stream[@"type"];
		NSString *urlString = stream[@"url"];
		NSString *signature = stream[@"sig"];
		if (urlString && signature && [AVURLAsset isPlayableExtendedMIMEType:type])
		{
			NSURL *streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&signature=%@", urlString, signature]];
			streamURLs[@([stream[@"itag"] integerValue])] = streamURL;
		}
	}
    
	for (NSNumber *videoQuality in self.preferredVideoQualities)
	{
		NSURL *streamURL = streamURLs[videoQuality];
		if (streamURL)
		{
			NSString *title = video[@"title"];
			NSString *thumbnailSmall = video[@"thumbnail_url"];
			NSString *thumbnailMedium = video[@"iurlsd"];
			NSString *thumbnailLarge = video[@"iurlmaxres"];
			NSMutableDictionary *userInfo = [NSMutableDictionary new];
			if (title)
				userInfo[XCDMetadataKeyTitle] = title;
			if (thumbnailSmall)
				userInfo[XCDMetadataKeySmallThumbnailURL] = [NSURL URLWithString:thumbnailSmall];
			if (thumbnailMedium)
				userInfo[XCDMetadataKeyMediumThumbnailURL] = [NSURL URLWithString:thumbnailMedium];
			if (thumbnailLarge)
				userInfo[XCDMetadataKeyLargeThumbnailURL] = [NSURL URLWithString:thumbnailLarge];
            
			[[NSNotificationCenter defaultCenter] postNotificationName:XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification object:self userInfo:userInfo];
			return streamURL;
		}
	}
    
	if (error)
	{
		NSMutableDictionary *userInfo = [@{ NSURLErrorKey: self.connection.originalRequest.URL } mutableCopy];
		NSString *reason = video[@"reason"];
		if (reason)
		{
			reason = [reason stringByReplacingOccurrencesOfString:@"<br\\s*/?>" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, reason.length)];
			NSRange range;
			while ((range = [reason rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
				reason = [reason stringByReplacingCharactersInRange:range withString:@""];
            
			userInfo[NSLocalizedDescriptionKey] = reason;
		}
        
		NSInteger code = [video[@"errorcode"] integerValue];
		*error = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:code userInfo:userInfo];
	}
    
	return nil;
}

@end