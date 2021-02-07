//
//  AppDelegate.m
//  LiveTV
//
//  Created by 王朋 on 2021/1/12.
//

#import "AppDelegate.h"
#import "FrontModel.h"
#import <WebKit/WKWebView.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <WebKit/WKUserScript.h>
#import <WebKit/WKUserContentController.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <Masonry/Masonry.h>
#import "VideoPlayer.h"
#import "TVSeriesView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "VideoOptionView.h"
@interface AppDelegate ()<NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate>

@property (strong) FrontModel *currentModel;
@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *contentView;

//主体View
@property (weak) IBOutlet NSWindow *showView;

@property (weak) IBOutlet NSView *tvView;

@property (strong) IBOutlet NSTableView *tvListView;

@property (strong) NSMutableArray *dataArr;
@property (weak) IBOutlet NSView *topMenuView;
@property (strong) NSMutableArray *btnArr;
@property (strong) NSArray *linkArr;
@property (strong) NSTextField *search;

@property (weak) IBOutlet NSView *bottomContentView;

@property (weak) IBOutlet NSView *playerContentView;

@property (weak) IBOutlet NSView *operaContentView;

@property (strong) VideoPlayer *player;

@property (strong) TVSeriesView *choiceView;

@property (strong) VideoOptionView *operationView;

@property (assign) NSInteger currentRow;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.linkArr =@[
        @"https://iptv-org.github.io/iptv/countries/cn.m3u",
        @"https://okzy.co/?m=vod-type-id-1.html",
        @"https://www.okzy.co/?m=vod-type-id-2.html",
        @"https://www.okzy.co/?m=vod-type-id-3.html"];
    [self setupUI];
    [self initWebData];
    
}

- (void)setupUI {
    self.window.delegate =self;
    self.btnArr =[NSMutableArray array];
    for (int index =0; index<4; index++) {
        NSButton *btn =[NSButton new];
        [self.topMenuView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topMenuView.mas_left).offset(100*index);
            make.top.equalTo(self.topMenuView.mas_top);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
        }];
        [btn setTitle:@[@"电视直播",@"电影",@"电视剧",@"综艺"][index]];
        [self.btnArr addObject:btn];
        [btn setTarget:self];
        [btn setAction:@selector(topmenuClick:)];
    }
    self.search =[NSTextField new];
    [self.topMenuView addSubview:self.search];
    [self.search mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topMenuView.mas_left).offset(400);
        make.top.equalTo(self.topMenuView.mas_top);
        make.bottom.equalTo(self.topMenuView.mas_bottom);
        make.width.equalTo(@300);
    }];
    self.search.placeholderString =@"🔍搜索影片";
    NSButton *btn =[NSButton new];
    [self.topMenuView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.search.mas_right);
        make.top.equalTo(self.topMenuView.mas_top);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    [btn setTitle:@"搜索"];
    [btn setTarget:self];
    [btn setAction:@selector(searchAction:)];
    
    self.bottomContentView.layer.backgroundColor =[NSColor blackColor].CGColor;
    self.tvListView.hidden = NO;
    self.operationView =[[VideoOptionView alloc] initWithFrame:self.operaContentView.bounds];
    [self.operaContentView addSubview:self.operationView];
    
    self.operationView.progressSlider.hidden =YES;
    
    @weakify(self)
    self.operationView.playAction = ^(NSButton * _Nonnull btn) {
        @strongify(self)
        [self playAction:btn];
    };
    self.operationView.sliderActionCallBack = ^(NSSlider * _Nonnull slider) {
        @strongify(self)
        [self sliderAction:slider];
    };
    
    self.operationView.refreshAction = ^{
        @strongify(self)
        if ((self.player.player.rate == 0) || (self.player.player.error != nil)) {
            [self.player.player seekToTime:CMTimeMakeWithSeconds(self.player.currentPlayerTime, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                @strongify(self)
                if (finished ==YES) {
                    [self.player.player play];
                    self.operationView.playBtn.title =@"暂停";
                }
            }];
        }
     
    };
 
     
}


- (void)playAction:(NSButton*)sender {
    if ((self.player.player.rate != 0) && (self.player.player.error == nil)) {
        [self.player.player pause]; //播放状态就暂停
        self.operationView.playBtn.title =@"播放";
    } else {
        [self.player.player play];//否则就播放
        self.operationView.playBtn.title =@"暂停";
    }
}

- (void)sliderAction:(id)sender {
    @weakify(self)
    if ((self.player.player.rate != 0) && (self.player.player.error == nil)) {
        [self.player.player pause]; //播放状态就暂停
    }
    NSSlider *slider = (NSSlider *)sender;

    float totalTime = CMTimeGetSeconds(self.player.playItem.duration)/100.0;

    float present = slider.floatValue;
    self.operationView.startLab.stringValue = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",totalTime*present]];

    [self.player.player seekToTime:CMTimeMakeWithSeconds(totalTime*present, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        @strongify(self)
        if (finished ==YES) {
            [self.player.player play];
        }
    }];
    

}

- (void)searchAction:(NSButton*)sender {
    NSString *url =[NSString stringWithFormat:@"http://www.okzy.co/index.php?m=vod-search-pg-%ld-wd-%@.html",1,self.search.stringValue];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak __typeof__(self) weakSelf = self;
    [FrontModel Api_reqAction:url succ:^(NSString *msg) {
        [FrontModel Api_request_final_get_PageUrl:msg Succ:^(NSArray * _Nonnull urlArr) {
            [weakSelf nsoptainalAction:urlArr];
           
        }];
    }];
}

- (void)topmenuClick:(NSButton*)sender {
    @weakify(self)
    [self.btnArr enumerateObjectsUsingBlock:^(NSButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        if ([sender isEqual:obj]) {
            obj.contentTintColor = [NSColor redColor];
            if (idx ==0) {
                [self filterLIVEM3u8ListByLink:@"https://iptv-org.github.io/iptv/countries/cn.m3u"];
            } else {
                [self filterNormalM3u8ListByLink:self.linkArr[idx]];
            }
        } else {
            obj.contentTintColor = [NSColor blackColor];
        }
       
    }];
}


- (void)initWebData {
    self.tvListView.delegate =self;
    self.tvListView.dataSource =self;
    self.dataArr =[NSMutableArray array];
    [self filterLIVEM3u8ListByLink:@"https://iptv-org.github.io/iptv/countries/cn.m3u"];
}


- (void)videoPlayWithURL:(NSString*)url  {
    @weakify(self)
    if (!self.player) {
        self.player =[[VideoPlayer alloc] initWithFrame:self.playerContentView.bounds withUrl:url v:self.playerContentView];
        [self.bottomContentView addSubview:self.player];
        self.player.playerActionCallBack = ^(NSString * _Nonnull startString, NSString * _Nonnull totalString, BOOL needHidden, float pressValue) {
            @strongify(self)
            self.operationView.startLab.stringValue =startString;
            self.operationView.totalLab.stringValue =totalString;
            self.operationView.progressSlider.hidden =needHidden;
            self.operationView.progressSlider.floatValue = pressValue;
        };
        self.player.playerCompliteCallBack = ^{
            @strongify(self)
            if ([self.currentModel.tplayurlArr count]>0) {
                [self.currentModel.tplayurlArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([self.player.currentPlayUrl isEqualToString:obj]) {
                        *stop =YES;
                        if (idx!=([self.currentModel.tplayurlArr count]-1)) {
                            [self videoPlayWithURL:self.currentModel.tplayurlArr[idx+1]];
                            self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第%ld集",[self.currentModel title],idx+2];
                        }
                    }
                }];
            }
        };
       
        
    } else {
        if ([url isEqualToString:self.player.currentPlayUrl]) {
            return;
        }
        [self.player playUrl:url];
    }
}

- (void)filterNormalM3u8ListByLink:(NSString*)link  {
    @weakify(self)
    [FrontModel Api_reqAction:link succ:^(NSString * _Nonnull msg) {
        [FrontModel Api_request_final_get_PageUrl:msg Succ:^(NSArray * _Nonnull urlArr) {
            @strongify(self)
            [self nsoptainalAction:urlArr];
        }];
    }];
    
}

- (void)nsoptainalAction:(NSArray*)arr {
    @weakify(self)
    NSMutableArray *operationArr = [[NSMutableArray alloc]init];
    self.dataArr =[NSMutableArray array];
    for (int i=0; i<arr.count; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            @strongify(self)
            [self newgetVideoDetail:arr[i] endf:^(id result) {
                FrontModel *dmodel =result;
                [self.dataArr addObject:dmodel];
                if ([self.dataArr count]== [arr count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tvListView reloadData];
                        [self videoPlayWithURL:[self.dataArr[0] link]];
                        self.currentModel = self.dataArr[0];
                        if (self.choiceView) {
                            [self.choiceView removeFromSuperview];
                            self.choiceView =nil;
                            [self.tvListView deselectColumn:0];
                            [self.tvListView deselectRow:self.currentRow];
                        }
                        if ([[self.dataArr[0] tplayurlArr] count]>0) {
                            self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第1集",[self.dataArr[0] title]];
                        } else {
                            self.operationView.titleShowlabel.stringValue =[self.dataArr[0] title];
                        }
                    });
                }
            }];
        }];
        
        [operationArr addObject:operation];
        if (i>0) {
            NSBlockOperation *operation1 = operationArr[i-1];
            NSBlockOperation *operation2 = operationArr[i];
            [operation2 addDependency:operation1];
        }
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperations:operationArr waitUntilFinished:NO];  //YES会阻塞当前线程
#warning - 绝对不要在应用主线程中等待一个Operation,只能在第二或次要线程中等待。阻塞主线程将导致应用无法响应用户事件,应用也将表现为无响应。
}

- (void)newgetVideoDetail:(NSString*)url endf:(void(^)(id result))rsCallback{
    [FrontModel Api_reqAction:url succ:^(NSString *msg) {
        [FrontModel Api_request_final_get_PageDetail:msg Succ:^(id  _Nonnull result) {
            rsCallback(result);
        }];
    }];
}


- (void)filterLIVEM3u8ListByLink:(NSString*)link {
    @weakify(self)
    self.dataArr =[NSMutableArray array];
    [FrontModel Api_request_getLiveM3u8LIstAddress:link succ:^(NSArray * _Nonnull msg) {
        [msg enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            NSArray *tarr =[obj componentsSeparatedByString:@","];
            NSString *tt = tarr.lastObject;
            NSArray *ttarr  =[tt componentsSeparatedByString:@"\n"];
            if (ttarr.count>=2&&![ttarr[0] hasPrefix:@"#"]) {
                NSString *title = [tt componentsSeparatedByString:@"\n"].firstObject;
                NSString *tlink = [tt componentsSeparatedByString:@"\n"][1];
                NSLog(@"-------------------------------------------------\n%@\n%@-------------------------------------------------",title,tlink);
                FrontModel *model =[FrontModel new];
                model.title = title;
                model.link = tlink;
                [self.dataArr addObject:model];
            }
        }];
        
        for (NSInteger i = 0; i < self.dataArr.count; i++) {
            for (NSInteger j = i+1;j < self.dataArr.count; j++) {
                FrontModel *tempModel = self.dataArr[i];
                FrontModel *model = self.dataArr[j];
                if ([tempModel.title isEqualToString:model.title]) {
                    [self.dataArr removeObject:model];
                }
            }
        }
        [self.tvListView reloadData];
        if ([self.dataArr count]<=0) {
            return;
        }
        [self videoPlayWithURL:[self.dataArr[0] link]];
        self.currentModel = self.dataArr[0];
        if ([[self.dataArr[0] tplayurlArr] count]>0) {
            self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第1集",[self.dataArr[0] title]];
        } else {
            self.operationView.titleShowlabel.stringValue =[self.dataArr[0] title];
        }
    }];
}


- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    [self.playerContentView setNeedsLayout:YES];
    [self.operaContentView setNeedsLayout:YES];
    self.player.playlayer.frame = self.playerContentView.bounds;
    self.operationView.frame =self.operaContentView.bounds;

   
    return frameSize;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return self.dataArr.count;
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([self.dataArr count]>0) {
        if ([self.dataArr count]>row) {
            FrontModel *model = self.dataArr[row];
            return model.title;
        } else {
            return @"";
        }
        
    }
    return @"";
 
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    
    return YES;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
  
    NSInteger row = [self.tvListView selectedRow];
    if (row<0) {
        return;
    }
    FrontModel *model = self.dataArr[row];
    self.currentModel = model;
    if (self.choiceView) {
        [self.choiceView removeFromSuperview];
        self.choiceView =nil;
//        [self doneThis:model row:row];
        [self.tvListView deselectColumn:0];
        [self.tvListView deselectRow:row];
        return;
    }
  
    if ([self.dataArr count]>0) {
        if (self.choiceView) {
            [self.choiceView removeFromSuperview];
            self.choiceView =nil;
        }
        
        if ([model.tplayurlArr count]<=1) {
            [self videoPlayWithURL:model.link];
            if ([model.tplayurlArr count]>0) {
                self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第1集",model.title];
            } else {
                self.operationView.titleShowlabel.stringValue =model.title;
            }
        } else {
            [self doneThis:model row:row];
        }
     
    }

}

-(void)doneThis:(FrontModel*)model row:(NSInteger)row{
    @weakify(self)
    self.choiceView =[[TVSeriesView alloc] initWithFrame:self.contentView.bounds];
    [self.tvListView addSubview:self.choiceView];
    [self.choiceView bdingModel:model currentUrl:self.player.currentPlayUrl];
    
    if ([model.tplayurlArr count]>0) {
//        self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第1集",model.title];
    } else {
        self.operationView.titleShowlabel.stringValue =model.title;
        [self videoPlayWithURL:model.tplayurlArr[0]];
    }
    self.choiceView.choiceLinkCallback = ^(NSString * _Nonnull url, NSString * _Nonnull title, NSInteger idx) {
        @strongify(self)
        [self videoPlayWithURL:url];
        [self.choiceView removeFromSuperview];
        self.choiceView =nil;
        self.operationView.titleShowlabel.stringValue =[NSString stringWithFormat:@"%@-第%ld集",title,idx+1];
        [self.tvListView deselectColumn:0];
        [self.tvListView deselectRow:row];
    };
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
