//
//  FFBrightnessView.m
//  FFPlayerDemo
//
//  Created by 曹诚飞 on 2019/3/1.
//  Copyright © 2019 曹诚飞. All rights reserved.
//

#import "FFBrightnessView.h"
#import "FFPlayerMacro.h"

@interface FFBrightnessView ()
@property (nonatomic ,strong) UIImageView       *backImage;
@property (nonatomic ,strong) UILabel           *titleLabel;
@property (nonatomic ,strong) UIView            *elementBgView;
@property (nonatomic ,strong) NSMutableArray    *elementArray;
@property (nonatomic ,strong) NSTimer           *timer;
@end

@implementation FFBrightnessView

+ (instancetype)sharedBrightnessView {
    static FFBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFBrightnessView alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(kScreenWidth * 0.5, kScreenHeight * 0.5, 155, 155);
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.backgroundColor = UIColor.whiteColor;
        self.alpha = 0.0;
        
        [self addSubview:self.backImage];
        [self addSubview:self.titleLabel];
        [self addSubview:self.elementBgView];
        
        [self updateElementProgress:[UIScreen mainScreen].brightness];
        
        [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat value = [change[@"new"] floatValue];
    if (self.alpha == 0.0) {
        self.alpha = 1.0;
        
    }
    [self updateTimer];
    [self updateElementProgress:value];
}

- (void)updateElementProgress:(CGFloat)value {
    CGFloat stage = 1.0 / (self.elementArray.count - 1);
    NSInteger level = value / stage;
    NSLog(@" %lf - %ld",stage,level);

    NSInteger index = 0;
    for (UIImageView *imageView in self.elementArray) {
        index <= level ? [imageView setHidden:NO] : [imageView setHidden:YES];
        index ++;
    }
}

- (void)autoHideView {
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0;
        }];
    }
}

- (void)addTimer {
    if (self.timer) return ;
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(autoHideView) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer {
    if (!self.timer) return;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimer {
    [self removeTimer];
    [self addTimer];
}

#pragma mark - lazy-getter
-(UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
        _backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
        _backImage.image = [UIImage imageNamed:@"playgesture_BrightnessSun"];
    }
    return _backImage;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithRed:0.25 green:0.22 blue:0.21 alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"亮度";
    }
    return _titleLabel;
}

- (UIView *)elementBgView {
    if (!_elementBgView) {
        _elementBgView = [[UIView alloc] initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        _elementBgView.backgroundColor = [UIColor colorWithRed:0.25 green:0.22 blue:0.21 alpha:1];
    }
    return _elementBgView;
}

- (NSMutableArray *)elementArray {
    if (!_elementArray) {
        _elementArray = [NSMutableArray arrayWithCapacity:16];
        
        CGFloat elementW = (self.elementBgView.bounds.size.width - 17) / 16;
        CGFloat elementH = 5;
        CGFloat elementY = 1;
        for (int i = 0; i < 16; i++) {
            CGFloat elementX = i * (elementW + 1) + 1;
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.backgroundColor = UIColor.whiteColor;
            imageView.frame = CGRectMake(elementX, elementY, elementW, elementH);
            [self.elementBgView addSubview:imageView];
            [_elementArray addObject:imageView];
        }
    }
    return _elementArray;
}

@end
