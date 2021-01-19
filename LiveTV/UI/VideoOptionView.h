//
//  VideoOptionView.h
//  LiveTV
//
//  Created by 王朋 on 2021/1/19.
//

#import <Cocoa/Cocoa.h>
#import "CustomSlider.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoOptionView : NSView

@property (strong) NSButton *playBtn;

@property (strong) NSTextField *startLab;

@property (strong) NSTextField *totalLab;

@property (strong) NSButton *fullSecreenBtn;

@property (strong) CustomSlider *progressSlider;

@property (copy) void(^playAction)(NSButton *btn);
@property (copy) void(^sliderActionCallBack)(NSSlider *slider);
@end

NS_ASSUME_NONNULL_END
