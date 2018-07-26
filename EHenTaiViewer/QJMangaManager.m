//
//  QJMangaManager.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJMangaManager.h"
#import "QJMangaImageModel.h"
#import "QJMangaImageDownloader.h"
#import "QJMangaImageParser.h"

@interface QJMangaManager()<QJMangaImageParserDelegate, QJMangaImageDownloaderDelegate>

@property (nonatomic, strong) NSString *mangaName;

@end

@implementation QJMangaManager

// 初始化
- (instancetype)initWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count imageUrls:(NSArray *)imageUrls smallImageUrls:(NSArray *)smallImageUrls {
    self = [super init];
    if (self) {
        self.url = url;
        self.count = count;
        // 循环创建画廊的model数组
        NSMutableArray *array = [NSMutableArray new];
        for (NSInteger i = 1; i <= count; i++) {
            @autoreleasepool {
                NSString *url = i < imageUrls.count + 1 && imageUrls[i - 1] ? imageUrls[i - 1] : @"";
                NSString *smallUrl = i < smallImageUrls.count + 1 && smallImageUrls[i - 1] ? smallImageUrls[i - 1] : @"";
                QJMangaImageModel *model = [QJMangaImageModel new];
                model.url = url;
                model.smallImageUrl = smallUrl;
                model.page = i;
                [array addObject:model];
            }
        }
        self.photos = array;
        self.showkey = showkey;
        self.gid = gid;
        self.cancel = NO;
    }
    return self;
}



// 开启图片解析和下载任务
- (void)startOperationForModel:(QJMangaImageModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (!model.isParser) {
        // 没有析出大图url
        [self startImageParserForModel:model];
    }
    // 同时加入下载大图的队列
    if (!model.hasImage) {
        // 没有下载图片
        [self startImageDownloadingForModel:model atIndexPath:indexPath];
    }
    else {
        // 进入这里说明model本地有图片
        // 自动遍历处理下一个model
        [self startNextWithCurrentModel:model];
    }
}

// 解析大图url
- (void)startImageParserForModel:(QJMangaImageModel *)model {
    // 获取需要解析的页码
    NSInteger pageCount = [self getCurrentPageWithImagePage:model.page];
    if (![self.parsers.allKeys containsObject:@(pageCount)]) {
        // 创建解析器
        QJMangaImageParser *parser = [[QJMangaImageParser alloc] initWithGalleryUrl:self.url pageCount:pageCount theDelegate:self];
        // 加入标记和队列
        [self.parsers setObject:parser forKey:@(pageCount)];
        [self.parserQueue addOperation:parser];
    }
}

// 下载图片
- (void)startImageDownloadingForModel:(QJMangaImageModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![self.downloads.allKeys containsObject:indexPath]) {
        QJMangaImageDownloader *downloader = [[QJMangaImageDownloader alloc] initWithModel:model atIndexPath:indexPath showKey:self.showkey gid:self.gid thdelegate:self];
        // 先判断是否还没解析图片url，则添加依赖，解析完图片链接之后再下载大图
        NSInteger pageCount = [self getCurrentPageWithImagePage:model.page];
        QJMangaImageParser *parser = [self.parsers objectForKey:@(pageCount)];
        if (parser) {
            [downloader addDependency:parser];
            NSLog(@"图片%ld尚未解析图片链接，等在解析完成", (long)model.page);
        }
        // 引入队列
        [self.downloads setObject:downloader forKey:indexPath];
        [self.downloadQueue addOperation:downloader];
    }
}

#pragma mark - QJMangaImageParserDelegate
// 解析出图片的url，准备下载
- (void)imageUrlDidParserWithArray:(NSArray<NSString *> *)urls smallUrls:(NSArray<NSString *> *)smallUrls page:(NSInteger)page parser:(QJMangaImageParser *)parser {
    for (NSInteger i = 0; i < urls.count; i++) {
        NSString *url = urls[i];
        NSString *smallUrl = smallUrls[i];
        NSInteger index = page * 20 + i;
        if (index < self.photos.count) {
            @autoreleasepool {
                QJMangaImageModel *model = self.photos[index];
                model.url = url;
                model.smallImageUrl = smallUrl;
                // 如果解析不到数据，则将模型的状态设置为失败
                if (url.length == 0) {
                    model.failed = YES;
                }
                else {
                    model.parser = YES;
                }
            }
        }
    }
    // 这里代理为强引用，记得释放掉
    parser.delegate = nil;
    [self.parsers removeObjectForKey:@(page)];
}

// 图片任务下载完成
- (void)imageDownloadFinishWithLoader:(QJMangaImageDownloader *)loader {
    loader.delegate = nil;
    [self.downloads removeObjectForKey:loader.indexPathInTableView];
    // 如果队列里面没有任务了，则自动进行下一个model的下载，直到检测到最后一个model
    if (!self.isCancel && self.downloads.allKeys.count == 0) {
        QJMangaImageModel *model = loader.model;
        [self startNextWithCurrentModel:model];
    }
}

- (void)startNextWithCurrentModel:(QJMangaImageModel *)model {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"page == %ld", model.page + 1];
    NSArray<QJMangaImageModel *> *filteredArray = [self.photos filteredArrayUsingPredicate:predicate];
    if (filteredArray.count) {
        [self startOperationForModel:filteredArray.firstObject atIndexPath:[NSIndexPath indexPathForItem:filteredArray.firstObject.page - 1 inSection:0]];
    }
}

- (NSInteger)getCurrentPageWithImagePage:(NSInteger)imagePage {
    return imagePage % 20 == 0 ? imagePage / 20 - 1 : imagePage / 20;
}

#pragma mark - queue manager
- (void)suspendAllOperations {
    [self.downloadQueue setSuspended:YES];
    [self.parserQueue setSuspended:YES];
}

- (void)resumeAllOperations {
    [self.downloadQueue setSuspended:NO];
    [self.parserQueue setSuspended:NO];
}

- (void)cancelAllOperations {
    [self.downloadQueue cancelAllOperations];
    [self.parserQueue cancelAllOperations];
    self.cancel = YES;
}

#pragma mark - Getter
- (NSMutableDictionary *)downloads {
    if (nil == _downloads) {
        _downloads = [NSMutableDictionary new];
    }
    return _downloads;
}

- (NSOperationQueue *)downloadQueue {
    if (nil == _downloadQueue) {
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.name = @"DownloadQueue";
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)parsers {
    if (nil == _parsers) {
        _parsers = [NSMutableDictionary new];
    }
    return _parsers;
}

- (NSOperationQueue *)parserQueue {
    if (nil == _parserQueue) {
        _parserQueue = [NSOperationQueue new];
        _parserQueue.name = @"ParserQueue";
        _parserQueue.maxConcurrentOperationCount = 1;
    }
    return _parserQueue;
}

- (NSArray<QJMangaImageModel *> *)photos {
    if (nil == _photos) {
        _photos = [NSArray new];
    }
    return _photos;
}

@end
