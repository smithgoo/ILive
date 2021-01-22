//
//  TVSeriesView.m
//  LiveTV
//
//  Created by 王朋 on 2021/1/15.
//

#import "TVSeriesView.h"
#import "FrontModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface TVSeriesView()
@property (strong) NSMutableArray *totalArr;
@end

@implementation TVSeriesView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layer.backgroundColor =[NSColor whiteColor].CGColor;
    return self;
}

- (void)bdingModel:(FrontModel*)model currentUrl:(NSString*)link{
    self.model =model;
    self.totalArr =[NSMutableArray array];
    for (NSView *x in self.subviews) {
        [x removeFromSuperview];
    }
    NSScrollView *scrollerView =[NSScrollView new];
    [self addSubview:scrollerView];
    scrollerView.frame =self.bounds;
    
    NSInteger idx = model.tplayurlArr.count;
    int pandding =10;
    float width = (self.frame.size.width-10*8)/7;
    float heigth = width;
    float xxx = 0;
    for (int index=0; index<idx; index++) {
        int x =index%7;
        int y = index/7;
        NSButton *btn = [NSButton new];
        [scrollerView addSubview:btn];
        btn.layer.borderColor =[NSColor orangeColor].CGColor;
        btn.layer.borderWidth =1;
        btn.tag = index+1;
        btn.wantsLayer =YES;
        btn.title =[NSString stringWithFormat:@"%d",index+1];
        btn.frame = CGRectMake(x * (width + pandding) + pandding, y  * (heigth + pandding)+pandding, width, heigth);
        xxx = y  * (heigth + pandding)+pandding+heigth;
        [btn setTarget:self];
        [btn setAction:@selector(choiceStart:)];
        [self.totalArr addObject:btn];
        [self.totalArr enumerateObjectsUsingBlock:^(NSButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==0) {
                obj.layer.backgroundColor =[NSColor redColor].CGColor;
            } else {
                obj.layer.backgroundColor =[NSColor whiteColor].CGColor;
            }
        }];
    }
    
    [model.tplayurlArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:link]) {
            *stop =YES;
            __block NSInteger tdx =idx;
            [self.totalArr enumerateObjectsUsingBlock:^(NSButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (tdx==idx) {
                    obj.layer.backgroundColor =[NSColor redColor].CGColor;
                } else {
                    obj.layer.backgroundColor =[NSColor whiteColor].CGColor;
                }
            }];
        }
    }];
    
    
}

- (void)choiceStart:(NSButton*)sender {
    @weakify(self)
    [self.totalArr enumerateObjectsUsingBlock:^(NSButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        if ([sender isEqual:obj]) {
            if (self.choiceLinkCallback) {
                self.choiceLinkCallback(self.model.tplayurlArr[idx],self.model.nickname,idx);
            }
        }
    }];
}




@end
