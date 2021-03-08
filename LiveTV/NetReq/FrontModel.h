//
//  FrontModel.h
//  OKNetVideoPlayer
//
//  Created by 王朋 on 2020/5/23.
//  Copyright © 2020 smithgoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,showType) {
    showTypeLocal=0,//本地
    showTypeNet,//网络
    showTypeLIVE,//直播
};

@interface FrontModel : NSObject

//直播title
@property (nonatomic,strong) NSString *title;

//直播link
@property (nonatomic,strong) NSString *link;
//  资源来源
@property (nonatomic,assign) showType showComeResource;
//直播title
@property (nonatomic,strong) NSString *liveTitle;

//直播link
@property (nonatomic,strong) NSString *liveLink;

//片名
@property (nonatomic,strong) NSString *nickname;
//原名
@property (nonatomic,strong) NSString *fname;
//导演
@property (nonatomic,strong) NSString *director;
//演员
@property (nonatomic,strong) NSString *actor;
//类型是电影还是电视剧
@property (nonatomic,strong) NSString *ftype;
//地区
@property (nonatomic,strong) NSString *area;
//语言
@property (nonatomic,strong) NSString *lanuage;
//评分
@property (nonatomic,strong) NSString *fstart;
//时长
@property (nonatomic,strong) NSString *ftimeLong;
//更新时间
@property (nonatomic,strong) NSString *updataTime;
//总共的集数
@property (nonatomic,strong) NSString *totalCount;
@property (nonatomic,strong) NSString *todayCount;
@property (nonatomic,strong) NSString *totalScore;
@property (nonatomic,strong) NSString *scoreCount;
//简介
@property (nonatomic,strong) NSString *fcontent;
//封面
@property (nonatomic,strong) NSString *cover;
//播放地址
@property (nonatomic,strong) NSString *playurl;
//播放列表
@property (nonatomic,strong) NSArray *tplayurlArr;

@property (nonatomic,strong)  NSNumber *isView;
@property (nonatomic,strong)  NSNumber *iscollection;
@property (nonatomic,strong)  NSNumber *isDownload;
@property (nonatomic,strong) NSString *realCreateTime;
@property (nonatomic,assign) NSInteger did;

//原网络请求的 源url
@property (nonatomic,strong)  NSNumber *requestUrl;
//是否是本地播放 已经下载完的资源
@property (nonatomic,assign)  BOOL islocalPlayer;

//是否是电视和电影的标示 yes 就是电视剧
@property (nonatomic,strong)  NSNumber *isTVs;
//最后电视下载的状态
@property (nonatomic,strong) NSString *tvsDownloadFlag;

//当前的集数下载的tv 显示的集数 做标记
@property (nonatomic,assign) NSInteger  currentSeriesIdx;

//获取直播返回的链接地址
+ (void)Api_request_getLiveM3u8LIstAddress:(NSString*)url succ:(void(^)(NSArray*msg))callback;
//获取当前点击的是电影还是电视剧的 点击返回的列表首页
+ (void)Api_reqAction:(NSString*)reqUrl succ:(void(^)(NSString*msg))callback;
//根据页面数据爬取列表页面详情
+ (void)Api_request_final_get_PageUrl:(NSString*)msg Succ:(void (^)(NSArray *urlArr))succ;
//根据列表页面获取剧集信息播放列表
+ (void)Api_request_final_get_PageDetail:(NSString*)msg Succ:(void (^)(id result))succ;

////根据链接获取当前的最大页码 做翻页操作
+ (void)Api_request_getAllinfosPage:(NSString*)msg  Succ:(void (^)(id result))succ;

@end

NS_ASSUME_NONNULL_END
