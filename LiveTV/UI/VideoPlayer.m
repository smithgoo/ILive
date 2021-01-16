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
@property (strong) AVPlayerItem *playItem;

@property (strong) AVPlayer *player;


@property (strong) NSView *tmpView;

@property (strong) NSView *operationView;

@property (strong) NSButton *playBtn;

@property (strong) NSTextField *startLab;

@property (strong) NSTextField *totalLab;

@property (strong) NSButton *fullSecreenBtn;

@property (strong) CustomSlider *progressSlider;

@property (assign) NSInteger idx;

@end

@implementation VideoPlayer

- (instancetype)initWithFrame:(NSRect)frameRect withUrl:(NSString*)url v:(NSView*)v{
    self =[super initWithFrame:frameRect];
    
    if (self) {
        
        [self setUPUI:frameRect withUrl:url v:v];
        self.tmpView =v;
        [self initOperationUI:frameRect];
    }
    
    return self;
}


- (void)initOperationUI:(NSRect)frameRect {
    
    self.operationView =[NSView new];
    [self addSubview:self.operationView];
    self.operationView.wantsLayer = true;///设置背景颜色
    self.operationView.layer.backgroundColor =[[NSColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(self.mas_bottom).offset(-15);
        make.height.equalTo(@45);
    }];
    
    self.playBtn =[NSButton new];
    [self.operationView addSubview:self.playBtn];
    self.playBtn.wantsLayer = true;///设置背景颜色
    self.playBtn.layer.backgroundColor =[NSColor whiteColor].CGColor;
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(80);
        make.centerY.equalTo(self.operationView);
        make.height.width.equalTo(@40);
    }];
    self.playBtn.title =@"暂停";
    [self.playBtn setTarget:self];
    [self.playBtn setAction:@selector(playAction:)];
    
    
    self.fullSecreenBtn =[NSButton new];
    [self.operationView addSubview:self.fullSecreenBtn];
    self.fullSecreenBtn.title = @"全屏";
    self.fullSecreenBtn.wantsLayer = true;///设置背景颜色
    self.fullSecreenBtn.layer.backgroundColor =[NSColor whiteColor].CGColor;
    [self.fullSecreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-80);
        make.centerY.equalTo(self.operationView);
        make.height.width.equalTo(@40);
    }];
    
    
    self.startLab =[NSTextField new];
    [self.operationView addSubview:self.startLab];
    [self.startLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(20);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];
    self.startLab.backgroundColor =[NSColor clearColor];
    self.startLab.enabled =NO;
    
    self.startLab.maximumNumberOfLines = 1;//最多显示行数
            //设置断行模式
    [[self.startLab cell] setLineBreakMode:NSLineBreakByCharWrapping];
            //设置是否启用单行模式
    [[self.startLab cell]setUsesSingleLineMode:YES];
            //设置超出行数是否隐藏
    [[self.startLab cell] setTruncatesLastVisibleLine: YES ];
    
    
    
    self.totalLab =[NSTextField new];
    [self.operationView addSubview:self.totalLab];
    [self.totalLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullSecreenBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];
    self.totalLab.backgroundColor =[NSColor clearColor];
    self.totalLab.enabled =NO;
    
    self.totalLab.maximumNumberOfLines = 1;//最多显示行数
            //设置断行模式
    [[self.totalLab cell] setLineBreakMode:NSLineBreakByCharWrapping];
            //设置是否启用单行模式
    [[self.totalLab cell]setUsesSingleLineMode:YES];
            //设置超出行数是否隐藏
    [[self.totalLab cell] setTruncatesLastVisibleLine: YES ];

  
    self.progressSlider =[CustomSlider new];
    [self.operationView addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startLab.mas_right).offset(10);
        make.right.equalTo(self.totalLab.mas_left).offset(-10);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@30);
    }];
    
    self.progressSlider.minValue =0;
    self.progressSlider.maxValue =100;
  
    [self.progressSlider setTarget:self];
    [self.progressSlider setAction:@selector(sliderAction:)];
    
    self.operationView.hidden =YES;

}

- (void)rebuildSubviews{
    [self.operationView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(self.mas_bottom).offset(-15);
        make.height.equalTo(@45);
    }];
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(80);
        make.centerY.equalTo(self.operationView);
        make.height.width.equalTo(@40);
    }];

    [self.fullSecreenBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-80);
        make.centerY.equalTo(self.operationView);
        make.height.width.equalTo(@40);
    }];

    [self.startLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(20);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];
 
    [self.totalLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullSecreenBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];

    [self.progressSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startLab.mas_right).offset(10);
        make.right.equalTo(self.totalLab.mas_left).offset(-10);
        make.centerY.equalTo(self.operationView);
        make.height.equalTo(@30);
    }];
 

}


- (void)sliderAction:(id)sender {
    @weakify(self)
    if ((self.player.rate != 0) && (self.player.error == nil)) {
        [self.player pause]; //播放状态就暂停
    }
    NSSlider *slider = (NSSlider *)sender;

    float totalTime = CMTimeGetSeconds(self.playItem.duration)/100.0;
    
    float present = slider.floatValue;
    self.startLab.stringValue = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",totalTime*present]];

    [self.player seekToTime:CMTimeMakeWithSeconds(totalTime*present, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        @strongify(self)
        if (finished ==YES) {
            [self.player play];
        }
    }];

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



- (void)playAction:(NSButton*)sender {
    if ((self.player.rate != 0) && (self.player.error == nil)) {
        [self.player pause]; //播放状态就暂停
        self.playBtn.title =@"播放";
    } else {
        [self.player play];//否则就播放
        self.playBtn.title =@"暂停";
    }
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
    self.playlayer.frame = frameRect;
    // 添加到当前页
    [v.layer addSublayer:self.playlayer];
    
    
    // 获取当前播放时间,可以用value/timescale的方式
    CMTime interval = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
    [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        float currentTime = self.playItem.currentTime.value/self.playItem.currentTime.timescale;
        self.startLab.stringValue = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",currentTime]];
        // 获取视频总时间
        float totalTime = CMTimeGetSeconds(self.playItem.duration);
        self.totalLab.stringValue = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",totalTime]];
        if (isnan(totalTime)) {
            self.operationView.hidden =YES;
        } else {
            self.operationView.hidden = NO;
            self.progressSlider.floatValue = currentTime/totalTime*100;
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


@end
