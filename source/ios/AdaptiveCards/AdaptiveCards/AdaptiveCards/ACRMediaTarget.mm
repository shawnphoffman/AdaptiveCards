//
//  ACRMediaTarget
//  ACRMediaTarget.mm
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACRMediaTarget.h"
#import "ACRAVPlayerViewHoldingUIView.h"
#import "ACOHostConfigPrivate.h"

// tags for easy accessing of subviews
const int playIconTag = 0x49434F4E;
const int posterTag = 0x504F5354;

@implementation ACRMediaTarget
{
    ACOMediaEvent *_mediaEvent;
    AVPlayerViewController *_mediaViewController;
    NSURL *_url;
    NSString *_mimeType;
    __weak ACRView *_view;
    __weak UIView *_containingview;
    BOOL isInline;
}
// dedicated initializer
- (instancetype)initWithMediaEvent:(ACOMediaEvent *)mediaEvent
                               url:(NSURL *)url
                          rootView:(ACRView *)rootView
                            config:(ACOHostConfig *)config
                    containingview:(UIView *)containingview
{
    self = [super init];
    if(self) {
        _mediaEvent = mediaEvent;
        _url = url;
        _view = rootView;
        _containingview = containingview;
        isInline = [config getHostConfig]->media.allowInlinePlayback;
    }
    return self;
}

- (instancetype)initWithMediaEvent:(ACOMediaEvent *)mediaEvent rootView:(ACRView *)rootView config:(ACOHostConfig *)config
{
    return [self initWithMediaEvent:mediaEvent url:nil rootView:rootView config:config containingview:nil];
}

- (instancetype)initWithMediaEvent:(ACOMediaEvent *)mediaEvent
                          rootView:(ACRView *)rootView
                            config:(ACOHostConfig *)config
                    containingview:(UIView *)containingview
{
    return [self initWithMediaEvent:mediaEvent url:nil rootView:rootView config:config containingview:containingview];
}
// delegate for ACRSelectActionDelegate
- (void)doSelectAction
{
    if(!isInline) {
        // if inline media play is disabled, call media delegate, and let host to handle it.
        if([_view.mediaDelegate respondsToSelector:@selector(didFetchMediaEvent: card:)]) {
            [_view.mediaDelegate didFetchMediaEvent:_mediaEvent card:[_view card]];
        } else {
            // https://github.com/Microsoft/AdaptiveCards/issues/1834
            NSLog(@"Warning: inline media play is disabled and host doesn't handle media event");
        }
    } else {
        BOOL validMediaTypeFound = NO;
        // loop and find media source that can be played
        for(ACOMediaSource *source in _mediaEvent.sources){
            if(source.isValid){
                if(source.isVideo){
                    NSURL *url = [[NSURL alloc] initWithString:source.url];
                    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
                    _mimeType = source.mimeType;
                    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
                        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:nil];
                        if(status == AVKeyValueStatusLoaded) {
                            dispatch_async(dispatch_get_main_queue(), ^{[self playVideoWhenTrackIsReady:asset];});
                        }
                    }];
                    validMediaTypeFound = YES;
                    break;
                } else{ // audio type
                    NSURL *url = [[NSURL alloc] initWithString:source.url];
                    AVPlayer *player = [AVPlayer playerWithURL:url];

                    self->_mediaViewController = [[AVPlayerViewController alloc] init];
                    self->_mediaViewController.player = player;

                    // pass AVPlayerViewController to host; it is not neccessary step for playback test, but it's better, the vc is inside parent vc tree
                    [_view.mediaDelegate didFetchMediaViewController:self->_mediaViewController card:nil];

                    self->_mediaViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    CGRect frame = self->_containingview.frame;
                    // TODO AVPlayerViewController has some constraints conflicts internally; need to fix, so the warning will be turned off, but
                    // system is correctly breaking the ties.
                    UIView *mediaView = self->_mediaViewController.view;
                    mediaView.frame = frame;
                    mediaView.translatesAutoresizingMaskIntoConstraints = NO;
                    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width].active = YES;
                    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.height].active = YES;

                    ACRAVPlayerViewHoldingUIView *poster = [self->_containingview viewWithTag:posterTag];
                    poster.hidePlayIcon = YES;
                    [poster setNeedsLayout];

                    UIView *playIconView = [poster viewWithTag:playIconTag];
                    if(playIconView){
                        [playIconView removeFromSuperview];
                    }
                    // poster and plyaIconView are removed from their superviews
                    [poster removeFromSuperview];

                    [self->_containingview addSubview:mediaView];
                    UIView *overlayview = self->_mediaViewController.contentOverlayView;

                    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self->_containingview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0].active = YES;
                    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self->_containingview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;

                    overlayview.backgroundColor = UIColor.blackColor;
                    // overlayview sit between AVPLayverViewController view's control view and content view, and here we add the poster.
                    [overlayview addSubview:poster];
                    [overlayview bringSubviewToFront:poster];

                    [NSLayoutConstraint activateConstraints:@[[poster.topAnchor constraintEqualToAnchor:overlayview.topAnchor], [poster.bottomAnchor constraintEqualToAnchor:overlayview.bottomAnchor], [poster.leadingAnchor constraintEqualToAnchor:overlayview.leadingAnchor], [poster.trailingAnchor constraintEqualToAnchor:overlayview.trailingAnchor]]];

                    [player play];
                    validMediaTypeFound = YES;
                    break;
                }
            }
        }
        if(!validMediaTypeFound) { // https://github.com/Microsoft/AdaptiveCards/issues/1834
            NSLog(@"Warning: supported media types not found");
        }
    }
}

- (void)playVideoWhenTrackIsReady:(AVURLAsset *)asset
{
    AVAssetTrack *track = [asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual][0];
    [track loadValuesAsynchronouslyForKeys:@[@"naturalSize"] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:@"naturalSize" error:nil];
        if(status == AVKeyValueStatusLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{[self playMedia:track asset:asset];});
        }
    }];
}

- (void)playMedia:(AVAssetTrack *)track asset:(AVURLAsset *)asset
{
    // video is ready to play, config AVPlayerViewController view dimension
    CGSize size = track.naturalSize;
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];

    self->_mediaViewController = [[AVPlayerViewController alloc] init];
    self->_mediaViewController.player = player;

    if([_view.mediaDelegate respondsToSelector:@selector(didFetchMediaViewController: card:)]){
        [_view.mediaDelegate didFetchMediaViewController:self->_mediaViewController card:nil];
    }

    self->_mediaViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // get frame that is constrained by actual media size and the superview
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(size, CGRectMake(0, 0, self->_containingview.frame.size.width, self->_containingview.frame.size.height));
    UIView *mediaView = self->_mediaViewController.view;
    mediaView.frame = frame;
    mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width].active = YES;
    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.height].active = YES;

    ACRAVPlayerViewHoldingUIView *poster = [self->_containingview viewWithTag:posterTag];
    poster.hidden = YES;

    [self->_containingview addSubview:mediaView];
    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self->_containingview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self->_containingview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;

    [player play];
}

@end
