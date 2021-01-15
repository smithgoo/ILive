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

@interface AppDelegate ()<NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate>
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

@property (strong) VideoPlayer *player;

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
    [self.btnArr enumerateObjectsUsingBlock:^(NSButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    if (!self.player) {
        self.player =[[VideoPlayer alloc] initWithFrame:self.bottomContentView.bounds withUrl:url v:self.bottomContentView];
        [self.bottomContentView addSubview:self.player];
    } else {
        [self.player playUrl:url];
    }
}

- (void)filterNormalM3u8ListByLink:(NSString*)link  {
    [FrontModel Api_reqAction:link succ:^(NSString * _Nonnull msg) {
        [FrontModel Api_request_final_get_PageUrl:msg Succ:^(NSArray * _Nonnull urlArr) {
            [self nsoptainalAction:urlArr];
        }];
    }];
    
}

- (void)nsoptainalAction:(NSArray*)arr {
    NSMutableArray *operationArr = [[NSMutableArray alloc]init];
    self.dataArr =[NSMutableArray array];
    for (int i=0; i<arr.count; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self newgetVideoDetail:arr[i] endf:^(id result) {
                FrontModel *dmodel =result;
                [self.dataArr addObject:dmodel];
                if ([self.dataArr count]== [arr count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tvListView reloadData];
                        [self videoPlayWithURL:[self.dataArr[0] link]];
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
    self.dataArr =[NSMutableArray array];
    [FrontModel Api_request_getLiveM3u8LIstAddress:link succ:^(NSArray * _Nonnull msg) {
        [msg enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [self videoPlayWithURL:[self.dataArr[0] link]];
    }];
}


- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    if (1920 ==frameSize.width) {
        self.player.playlayer.frame = CGRectMake(0,0,frameSize.width-162,frameSize.height);
        self.contentView.hidden =YES;
    } else {
        self.player.playlayer.frame = self.bottomContentView.bounds;
        self.contentView.hidden = NO;
    }
    return frameSize;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return self.dataArr.count;
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([self.dataArr count]>0) {
        FrontModel *model = self.dataArr[row];
        return model.title;
    }
    return @"";
 
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    if ([self.dataArr count]>0) {
        NSInteger row = [self.tvListView selectedRow];
        FrontModel *model = self.dataArr[row];
        [self videoPlayWithURL:model.link];
    }

}


@end