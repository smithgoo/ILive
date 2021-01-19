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
#import <Masonry/Masonry.h>
#import "CustomSlider.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface VideoPlayer ()



 
@property (strong) NSView *tmpView;
 
@property (assign) NSInteger idx;

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
 
- (void)setUPUI:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v {
    [self commonPlayFrame:frameRect withUrl:url v:v];
}

-(void)playUrl:(NSString *)url {
    [self commonPlayFrame:self.tmpView.bounds withUrl:url v:self.tmpView];
}


- (void)commonPlayFrame:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v {
    @weakify(self)
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
    self.playlayer.frame =CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
    // 添加到当前页
    [v.layer addSublayer:self.playlayer];
    
    // 获取当前播放时间,可以用value/timescale的方式
    CMTime interval = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
    [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        if (time.timescale !=1000000000) {
            return;
        }
        float currentTime = self.playItem.currentTime.value/self.playItem.currentTime.timescale;
        // 获取视频总时间
        float totalTime = CMTimeGetSeconds(self.playItem.duration);
        BOOL needHidden =NO;
        if (isnan(totalTime)) {
            needHidden =YES;
        } else {
            needHidden = NO;
        }
        
        if (self.playerActionCallBack) {
            self.playerActionCallBack([self getMMSSFromSS:[NSString stringWithFormat:@"%f",currentTime]],[self getMMSSFromSS:[NSString stringWithFormat:@"%f",totalTime]],needHidden,currentTime/totalTime*100);
        }



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


//传入 秒  得到 xx:xx:xx
-(NSString *)getMMSSFromSS:(NSString *)totalTime{

    NSInteger seconds = [totalTime integerValue];

    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];

    return format_time;

}

@end
