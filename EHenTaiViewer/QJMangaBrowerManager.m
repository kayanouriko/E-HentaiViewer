//
//  QJMangaBrowerManager.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/7.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaBrowerManager.h"
#import "QJMangaURLSession.h"

@interface QJMangaBrowerManager () {
    //用于存储解析获取的该画廊中单个图片对象
    NSMutableArray *_missions;
    //用于解析图片链接的队列
    NSOperationQueue *_imagesLinksQueue;
}


@end

@implementation QJMangaBrowerManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _missions = [NSMutableArray new];
        _imagesLinksQueue = [NSOperationQueue new];
    }
    return self;
}

+ (QJMangaBrowerManager *)shareManager {
    static QJMangaBrowerManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [QJMangaBrowerManager new];
    });
    return shareManager;
}

- (void)startMissionWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count complete:(missionComplete)complete {
    //创建解析每个图片链接的任务
    
}

- (void)endMission {
    
}

@end
