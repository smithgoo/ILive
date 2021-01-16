//
//  TVSeriesView.m
//  LiveTV
//
//  Created by 王朋 on 2021/1/15.
//

#import "TVSeriesView.h"
#import "FrontModel.h"
@interface TVSeriesView()
@property (strong) NSMutableArray *totalArr;
@end

@implementation TVSeriesView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layer.backgroundColor =[NSColor whiteColor].CGColor;
    return self;
}

- (void)bdingModel:(FrontModel*)model {
    self.model =model;
    self.totalArr =[NSMutableArray array];
    for (NSView *x in self.subviews) {
        [x removeFromSuperview];
    }
    NSInteger idx = model.tplayurlArr.count;
    int pandding =10;
    float width = (self.frame.size.width-10*8)/7;
    float heigth = width;
    float xxx = 0;
    for (int index=0; index<idx; index++) {
        int x =index%7;
        int y = index/7;
        NSButton *btn = [NSButton new];
        [self addSubview:btn];
        btn.layer.borderColor =[NSColor orangeColor].CGColor;
        btn.layer.borderWidth =1;
        btn.tag = index+1;
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
}

- (void)choiceStart:(NSButton*)sender {
    [self.totalArr enumerateObjectsUsingBlock:^(NSButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([sender isEqual:obj]) {
            if (self.choiceLinkCallback) {
                self.choiceLinkCallback(self.model.tplayurlArr[idx]);
            }
        }
    }];
}




@end