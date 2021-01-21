//
//  VideoPlayer.h
//  LiveTV
//
//  Created by 王朋 on 2021/1/15.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoOptionView.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : NSView
@property (strong) AVPlayerLayer *playlayer;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerItem *playItem;
@property (strong) NSString *currentPlayUrl;

//实时监听
@property (copy) void(^playerActionCallBack)(NSString*startString,NSString*totalString,BOOL needHidden,float pressValue);

//播放完成的监听
@property (copy) void(^playerCompliteCallBack)(void);

- (instancetype)initWithFrame:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v;

- (void)playUrl:(NSString*)url;

- (void)rebuildSubviews;

@end

NS_ASSUME_NONNULL_END
