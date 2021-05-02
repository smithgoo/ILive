//
//  FrontModel.m
//  OKNetVideoPlayer
//
//  Created by 王朋 on 2020/5/23.
//  Copyright © 2020 smithgoo. All rights reserved.
//

#import "FrontModel.h"
#import <AFNetworking.h>
#import <HTMLParser.h>
#import <HTMLNode.h>
@implementation FrontModel

//获取直播返回的链接地址
+ (void)Api_request_getLiveM3u8LIstAddress:(NSString*)url succ:(void(^)(NSArray*msg))callback {
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@",downloadProgress);//打印进度
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *filePath =[NSString stringWithFormat:@"%@",response.suggestedFilename];
        //        [WHCFileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",[WHCFileManager documentsDir],fileDir]];
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [downloadURL URLByAppendingPathComponent:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //此处已经在主线程了
        NSLog(@"filePath = %@",filePath);
        // 通过指定的路径读取文本内容
        NSString *str = [NSString stringWithContentsOfFile:filePath   encoding:NSUTF8StringEncoding error:&error];
        
        NSLog(@ "srt=%@" ,str);
        callback([str componentsSeparatedByString:@"#EXTINF:-1 tvg-id="]);
    }];
    
    [downloadTask resume];
}


//获取当前点击的是电影还是电视剧的 点击返回的列表首页
+ (void)Api_reqAction:(NSString*)reqUrl succ:(void(^)(NSString*msg))callback {
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:reqUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        callback(result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//根据页面数据爬取列表页面详情
+ (void)Api_request_final_get_PageUrl:(NSString*)msg Succ:(void (^)(NSArray *urlArr))succ {
    NSError *error = nil;
    NSString *html =[self isBegin_n:msg];
    NSMutableArray *urlArr =[NSMutableArray array];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray*spanArr =[bodyNode findChildTags:@"span"];
    for (HTMLNode *inputNode in spanArr) {
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"xing_vb4"]) {
            NSString* url =[NSString stringWithFormat:@"%@%@",@"http://www.1156zy.net",[[inputNode findChildTag:@"a"] getAttributeNamed:@"href"]];
            [urlArr addObject:url];
        }
    }
    succ(urlArr);
}

//根据列表页面获取剧集信息播放列表
+ (void)Api_request_final_get_PageDetail:(NSString*)msg Succ:(void (^)(id result))succ {
    NSError *error = nil;
    NSString *html =[self isBegin_n:msg];
    FrontModel *model =[FrontModel new];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray*imgArr =[bodyNode findChildTags:@"img"];
    NSArray*contentArr =[bodyNode findChildTags:@"div"];
    NSArray*m3u8Arr =[bodyNode findChildTags:@"input"];
    for (HTMLNode *inputNode in imgArr) {
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"lazy"]) {
            model.cover =[[inputNode getAttributeNamed:@"src"] length]>0?[inputNode getAttributeNamed:@"src"]:@"";
            model.nickname = [[inputNode getAttributeNamed:@"alt"] length]>0?[inputNode getAttributeNamed:@"alt"]:@"";
        }
    }
    NSMutableArray *xxArr =[NSMutableArray array];
    for (HTMLNode *inputNode in contentArr) {
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"vodinfobox"]) {
            [[inputNode findChildTags:@"li"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *arr =[[obj allContents] componentsSeparatedByString:@""];
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj containsString:@"导演"]) {
                        model.director = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"主演"]) {
                        model.actor = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"类型"]) {
                        model.ftype = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"语言"]) {
                        model.lanuage = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"上映"]) {
                        model.fstart = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"片长"]) {
                        model.ftimeLong = [obj length]>0?obj:@"-";
                    } else if ([obj containsString:@"更新"]) {
                        model.updataTime = [obj length]>0?obj:@"-";
                    }else if ([obj containsString:@"总播放量"]) {
                        model.totalCount = [obj length]>0?obj:@"-";
                    }else if ([obj containsString:@"今日播放量"]) {
                        model.todayCount = [obj length]>0?obj:@"-";
                    }else if ([obj containsString:@"总评分数"]) {
                        model.totalScore = [obj length]>0?obj:@"-";
                    }else if ([obj containsString:@"评分次数"]) {
                        model.scoreCount = [obj length]>0?obj:@"-";
                    }
                }];
            }];
        }
        if ([[inputNode getAttributeNamed:@"class"] isEqualToString:@"vodplayinfo"]) {
            [xxArr addObject:[inputNode rawContents]];
        }
    }
    if ([xxArr count]>0) {
        model.fcontent = [xxArr[0] length]>0?xxArr[0]:@"-";
    }
    NSMutableArray *m3u8_totalArr =[NSMutableArray array];
    for (HTMLNode *inputNode in m3u8Arr) {
        if ([[inputNode getAttributeNamed:@"type"] isEqualToString:@"checkbox"]) {
            NSString *m3u8Str =[inputNode getAttributeNamed:@"value"];
            if ([m3u8Str hasSuffix:@".m3u8"]) {
                [m3u8_totalArr addObject:m3u8Str];
            }
        }
    }
    model.tplayurlArr = m3u8_totalArr;
    if ([model.ftimeLong isEqualToString:@"片长：0"]) {
        if (model.tplayurlArr.count>=2) {
            model.ftimeLong = [NSString stringWithFormat:@"集数：%ld集",[model.tplayurlArr count]];
        }
    }
    model.area =@"-";
    model.playurl =@"-";
    model.fname = @"-";
    model.title =model.nickname;
    model.link =model.tplayurlArr.firstObject;
    succ(model);
}


//根据链接获取当前的最大页码 做翻页操作
+ (void)Api_request_getAllinfosPage:(NSString*)msg  Succ:(void (^)(id result))succ {
    NSError *error = nil;
    NSString *html =[self isBegin_n:msg];
    FrontModel *model =[FrontModel new];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray*contentArr =[bodyNode findChildTags:@"a"];
    NSMutableArray *muArr =[NSMutableArray array];
    for (HTMLNode *inputNode in contentArr) {
        if ([[inputNode getAttributeNamed:@"target"] isEqualToString:@"_self"]) {
            [muArr addObject:[inputNode getAttributeNamed:@"href"]];
        }
    }
    NSString *lastStr = muArr.lastObject;
    NSArray *pageArr =[lastStr componentsSeparatedByString:@"-"];
    NSString *tlastStr = pageArr.lastObject;
    NSString *pageStr = [tlastStr componentsSeparatedByString:@"."].firstObject;
    succ(pageStr);
}



+ (NSString*)isBegin_n:(NSString*)msg {
    NSString *xx =[msg substringToIndex:2];
    NSString *tempStr = @"<";
  
    if (![xx isEqual:tempStr]) {
       msg = [msg substringFromIndex:2];
    }

    return msg;
}




@end
