//
//  VideoPageOpView.h
//  LiveTV
//
//  Created by 王朋 on 2021/2/28.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPageOpView : NSView

@property (nonatomic) void(^nextBtnClickCallback)(NSInteger page);

- (void)bdingTotalPage:(NSInteger)totalPage;

- (void)resetCurrentPage;

@end

NS_ASSUME_NONNULL_END
