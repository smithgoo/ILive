//
//  VideoPlayer.m
//  LiveTV
//
//  Created by 王朋 on 2021/1/15.
//

#import "VideoPlayer.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayer ()
@property (strong) AVPlayerItem *playItem;

@property (strong) AVPlayer *player;


@property (strong) NSView *tmpView;

@property (strong) NSView *operationView;

@end

@implementation VideoPlayer

- (instancetype)initWithFrame:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v{
    self =[super initWithFrame:frameRect];
    
    if (self) {
        [self setUPUI:frameRect withUrl:url v:v];
        self.tmpView =v;
    }
    
    return self;
}


- (void)initOperationUI:(NSRect)frameRect {
    
    
    
}

- (void)setUPUI:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v {
    [self commonPlayFrame:frameRect withUrl:url v:v];
}

-(void)playUrl:(NSString *)url {
    [self commonPlayFrame:self.tmpView.bounds withUrl:url v:self.tmpView];
}


- (void)commonPlayFrame:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v {
    if (self.player) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self.player pause];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player = nil;

    }
    
    NSURL * videoUrl = [NSURL URLWithString:url];
    // 设置播放项目
    self.playItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
    // 初始化player对象
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playItem];
    // 设置播放页面
    self.playlayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    self.playlayer.frame = frameRect;
    // 添加到当前页
    [v.layer addSublayer:self.playlayer];
    
    
    // 获取当前播放时间,可以用value/timescale的方式
    CMTime interval = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
    [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float currentTime = self.playItem.currentTime.value/self.playItem.currentTime.timescale;
        NSLog(@"%f",currentTime);
        
        // 获取视频总时间
        float totalTime = CMTimeGetSeconds(self.playItem.duration);
        NSLog(@"%f",totalTime);
    }];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.playItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                    // 播放方法在这里，比较稳妥
                    NSLog(@"准备播放");
                    [self.player play];
                    break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"准备失败");
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"未知");
                    break;
                    
                default:
                    break;
            }
        }
    }
   
}


@end
