//
//  VideoPageOpView.m
//  LiveTV
//
//  Created by 王朋 on 2021/2/28.
//

#import "VideoPageOpView.h"
#import <Masonry/Masonry.h>
@interface VideoPageOpView ()

@property (nonatomic) NSTextField *currentTef;
@property (nonatomic) NSTextField *totalTef;
@property (nonatomic) NSButton *leftBtn;
@property (nonatomic) NSButton *rightBtn;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic) NSInteger currentPage;

@end


@implementation VideoPageOpView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self =[super initWithFrame:frameRect];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.currentPage =0;
    float tmpH =5;
    self.leftBtn =[[NSButton alloc] initWithFrame:CGRectMake(20, tmpH, self.frame.size.height-tmpH*2, self.frame.size.height-tmpH*2)];
    [self addSubview:self.leftBtn];
    self.leftBtn.title =@"左";
    
    self.rightBtn =[[NSButton alloc] initWithFrame:CGRectMake(self.frame.size.width-20-self.frame.size.height, tmpH, self.frame.size.height-tmpH*2, self.frame.size.height-tmpH*2)];
    [self addSubview:self.rightBtn];
    self.rightBtn.title = @"右";
    
    [self.leftBtn setTarget:self];
    [self.leftBtn setAction:@selector(leftBtnAction:)];
    
    [self.rightBtn setTarget:self];
    [self.rightBtn setAction:@selector(rightBtnAction:)];
    
    self.currentTef =[NSTextField new];
    [self addSubview:self.currentTef];
    
    [self.currentTef mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightBtn.mas_left);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(@20);
        make.left.equalTo(self.leftBtn.mas_right);
    }];
    self.currentTef.backgroundColor =[NSColor clearColor];
    self.currentTef.enabled =NO;
    
    self.currentTef.maximumNumberOfLines = 1;//最多显示行数
            //设置断行模式
    [[self.currentTef cell] setLineBreakMode:NSLineBreakByCharWrapping];
            //设置是否启用单行模式
    [[self.currentTef cell]setUsesSingleLineMode:YES];
            //设置超出行数是否隐藏
    [[self.currentTef cell] setTruncatesLastVisibleLine: YES ];
    
}


- (void)leftBtnAction:(NSButton*)sender {
    self.currentPage --;
    if (self.currentPage<=1) {
        if (self.nextBtnClickCallback) {
            self.nextBtnClickCallback(1);
            self.currentPage =1;
        }
    } else {
        if (self.nextBtnClickCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.currentTef setStringValue:[NSString stringWithFormat:@"当前第%ld页,总%ld页",self.currentPage,self.totalPage]];
            });
        }
            self.nextBtnClickCallback(self.currentPage);
        }
    }
    

- (void)rightBtnAction:(NSButton*)sender {
    self.currentPage ++;
    if (self.currentPage>=self.totalPage) {
        if (self.nextBtnClickCallback) {
            self.nextBtnClickCallback(self.totalPage);
        }
    } else {
        if (self.nextBtnClickCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.currentTef setStringValue:[NSString stringWithFormat:@"当前第%ld页,总%ld页",self.currentPage,self.totalPage]];
            });
            self.nextBtnClickCallback(self.currentPage);
        }
    }

   
}


- (void)bdingTotalPage:(NSInteger)totalPage {
    self.totalPage =totalPage;
    self.currentTef.stringValue =[NSString stringWithFormat:@"当前第%ld页,总%ld页",self.currentPage,self.totalPage];
}

- (void)resetCurrentPage {
    self.currentPage =1;
}

@end
