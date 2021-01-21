//
//  TVSeriesView.h
//  LiveTV
//
//  Created by 王朋 on 2021/1/15.
//

#import <Cocoa/Cocoa.h>
#import "FrontModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TVSeriesView : NSView
-(instancetype)initWithFrame:(CGRect)frame;
@property (copy) void(^choiceLinkCallback)(NSString*url,NSString* title,NSInteger idx);
@property (strong) FrontModel*model;
- (void)bdingModel:(FrontModel*)model;

@end

NS_ASSUME_NONNULL_END
