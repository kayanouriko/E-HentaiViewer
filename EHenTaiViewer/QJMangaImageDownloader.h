//
//  QJMangaImageDownloader.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QJMangaImageModel, QJMangaImageDownloader;

@protocol QJMangaImageDownloaderDelegate <NSObject>

@optional
- (void)imageDownloadFinishWithLoader:(QJMangaImageDownloader *)loader;

@end

@interface QJMangaImageDownloader : NSOperation

@property (nonatomic, strong) id<QJMangaImageDownloaderDelegate> delegate;
// 持有的对象
@property (nonatomic, strong) QJMangaImageModel *model;
// indexPath
@property (nonatomic, strong, readonly) NSIndexPath *indexPathInTableView;

// 初始化
- (instancetype)initWithModel:(QJMangaImageModel *)model atIndexPath:(NSIndexPath *)indexPath showKey:(NSString *)showkey gid:(NSString *)gid thdelegate:(id<QJMangaImageDownloaderDelegate>)delegate;

- (void)cancelTask;

@end
