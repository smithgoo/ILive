//
//  VideoOptionView.m
//  LiveTV
//
//  Created by 王朋 on 2021/1/19.
//

#import "VideoOptionView.h"
#import <Masonry/Masonry.h>
#import "CustomSlider.h"
@interface VideoOptionView ()

@end

@implementation VideoOptionView

- (instancetype)initWithFrame:(NSRect)frameRect{
    self =[super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = true;///设置背景颜色
        self.layer.backgroundColor =[NSColor  whiteColor].CGColor;
        [self initOperationUI:frameRect];
    }
    
    return self;
}

- (void)initOperationUI:(NSRect)frameRect {
    
    self.refreshBtn =[NSButton new];
    [self addSubview:self.refreshBtn];
    self.refreshBtn.wantsLayer = true;///设置背景颜色
    self.refreshBtn.layer.backgroundColor =[NSColor whiteColor].CGColor;
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.equalTo(@40);
    }];
    self.refreshBtn.title =@"刷新";
    [self.refreshBtn setTarget:self];
    [self.refreshBtn setAction:@selector(refreshAction:)];
    
    
 
    self.playBtn =[NSButton new];
    [self addSubview:self.playBtn];
    self.playBtn.wantsLayer = true;///设置背景颜色
    self.playBtn.layer.backgroundColor =[NSColor whiteColor].CGColor;
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(80);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.equalTo(@40);
    }];
    self.playBtn.title =@"暂停";
    [self.playBtn setTarget:self];
    [self.playBtn setAction:@selector(playAction:)];
    
    
    self.fullSecreenBtn =[NSButton new];
    [self addSubview:self.fullSecreenBtn];
    self.fullSecreenBtn.title = @"全屏";
    self.fullSecreenBtn.wantsLayer = true;///设置背景颜色
    self.fullSecreenBtn.layer.backgroundColor =[NSColor whiteColor].CGColor;
    [self.fullSecreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-80);
        make.centerY.equalTo(self.mas_centerY);
        make.height.width.equalTo(@40);
    }];
    [self.fullSecreenBtn setTarget:self];
    [self.fullSecreenBtn setAction:@selector(fullScreenAction:)];
    
    
    self.startLab =[NSTextField new];
    [self addSubview:self.startLab];
    [self.startLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(20);
        make.centerY.equalTo(self.mas_centerY);
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
    [self addSubview:self.totalLab];
    [self.totalLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullSecreenBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.mas_centerY);
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
    [self addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startLab.mas_right).offset(10);
        make.right.equalTo(self.totalLab.mas_left).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(@30);
    }];
    
    self.progressSlider.minValue =0;
    self.progressSlider.maxValue =100;
  
    [self.progressSlider setTarget:self];
    [self.progressSlider setAction:@selector(sliderAction:)];
    
    
    self.titleShowlabel =[NSTextField new];
    [self addSubview:self.titleShowlabel];
    [self.titleShowlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(5);
        make.height.equalTo(@20);
        make.width.equalTo(@260);
    }];
    self.titleShowlabel.backgroundColor =[NSColor clearColor];
    self.titleShowlabel.enabled =NO;
    self.titleShowlabel.font =[NSFont systemFontOfSize:14];
    self.titleShowlabel.textColor =[NSColor blackColor];
 
    
    self.titleShowlabel.maximumNumberOfLines = 1;//最多显示行数
   
    

}



- (void)refreshAction:(NSButton*)sender {
    if (self.refreshAction) {
        self.refreshAction();
    }
}

- (void)playAction:(NSButton*)sender {
    if (self.playAction) {
        self.playAction(sender);
    }
 
}


- (void)sliderAction:(id)sender {
    NSSlider *slider = (NSSlider *)sender;
    if (self.sliderActionCallBack) {
        self.sliderActionCallBack(slider);
    }
 
}

- (void)fullScreenAction:(NSButton*)sender {
    if (self.fullScreenAction) {
        self.fullScreenAction();
    }
 
}


@end
