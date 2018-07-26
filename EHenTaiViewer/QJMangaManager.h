//
//  QJMangaManager.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QJMangaImageModel;

@interface QJMangaManager : NSObject

/**
 存储排队下载大图的对象
 */
@property (nonatomic, strong) NSMutableDictionary *downloads;

/**
 下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

/**
 存储排队解析的队列
 */
@property (nonatomic, strong) NSMutableDictionary *parsers;

/**
 解析图片队列
 */
@property (nonatomic, strong) NSOperationQueue *parserQueue;

/**
 存储全部的图片对象
 */
@property (nonatomic, strong) NSArray<QJMangaImageModel *> *photos;

/**
 画廊url
 */
@property (nonatomic, strong) NSString *url;

/**
 图片总数
 */
@property (nonatomic, assign) NSInteger count;

// 一些需要的参数
@property (nonatomic, strong) NSString *showkey;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, assign, getter=isCancel) BOOL cancel;

/**
 初始化
 */
- (instancetype)initWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count imageUrls:(NSArray *)imageUrls smallImageUrls:(NSArray *)smallImageUrls;

/**
 开始一个图片下载任务
 */
- (void)startOperationForModel:(QJMangaImageModel *)model atIndexPath:(NSIndexPath *)indexPath;

/**
 开始解析缩略图链接
 */
- (void)startImageParserForModel:(QJMangaImageModel *)model;

/**
 暂停全部任务
 */
- (void)suspendAllOperations;

/**
 恢复全部任务
 */
- (void)resumeAllOperations;

/**
 取消全部任务
 */
- (void)cancelAllOperations;

@end
