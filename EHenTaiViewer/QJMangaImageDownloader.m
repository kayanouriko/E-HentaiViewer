//
//  QJMangaImageDownloader.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJMangaImageDownloader.h"
#import "QJMangaImageModel.h"
#import "NSString+StringHeight.h"

@interface QJMangaImageDownloader()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong, readwrite) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong) NSString *showkey;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, assign) BOOL isCancel;

@end

@implementation QJMangaImageDownloader

- (instancetype)initWithModel:(QJMangaImageModel *)model atIndexPath:(NSIndexPath *)indexPath showKey:(NSString *)showkey gid:(NSString *)gid thdelegate:(id<QJMangaImageDownloaderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.model = model;
        self.indexPathInTableView = indexPath;
        self.showkey = showkey;
        self.gid = gid;
        self.delegate = delegate;
    }
    return self;
}

- (void)main {
    if (self.cancelled) return;
    // semaphore的创建需要排除在自动释放池外面，否则会在中断的时候被释放掉
    self.semaphore = dispatch_semaphore_create(0);
    @autoreleasepool {
        
        NSLog(@"开始单个图片的下载任务");
        
        // 执行任务之前，先把参数置为NO
        if (self.isCancel) {
            self.isCancel = NO;
        }
        
        if ([self.model hasImage]) {
            // 如果本地有缓存
            if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
                [self.delegate imageDownloadFinishWithLoader:self];
            }
            if (self.semaphore) {
                dispatch_semaphore_signal(self.semaphore);
            }
        } else if (self.model.imageUrl != nil && self.model.imageUrl.length) {
            // 大图图片链接已经获取到
            [self downloadBigImageUrl];
        } else {
            // 大图图片链接没有获取到
            [self getBigImageUrl];
        }
    }
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

// 获取大图链接
- (void)getBigImageUrl {
    // 如果url没有说明第一步虽然成功了，但是没有解析到url，直接返回fail。由外面控制是否重新请求
    if (self.model.url == nil || self.model.url.length == 0) {
        [self downloadFail];
        return;
    }
    
    //https://e-hentai.org/s/4d74e00bc9/1070576-42
    //4d74e00bc9 为imagekey 42 为page
    NSArray *arr = [self.model.url componentsSeparatedByString:@"/"];
    // 如果解析出来的不符合预期也退出
    if (arr.count <= 1) {
        [self downloadFail];
        return;
    }
    NSString *imageKey = arr[arr.count - 2];
    
    NSArray *pages = [arr.lastObject componentsSeparatedByString:@"-"];
    if (pages.count == 0) {
        [self downloadFail];
    }
    NSString *page = pages.lastObject;
    // 重置一下page，防止出错
    self.model.page = [page integerValue];
    // 开始创建流程
    NSDictionary *jsonDictionary = @{
                                     @"method": @"showpage",
                                     @"gid": self.gid,
                                     @"page": @(self.model.page),
                                     @"imgkey": imageKey,
                                     @"showkey": self.showkey
                                     };
    NSString *apiurl = [QJGlobalInfo isExHentaiStatus] ? EXHENTAI_APIURL : HENTAI_APIURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    NSURLSession *session = [self getSessionWithDelegate:NO];
    
    __weak typeof(NSURLSession) *weakSession = session;
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [weakSession invalidateAndCancel];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.model.failed = YES;
                NSLog(@"网络错误，大图url没获取到");
                if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
                    [self.delegate imageDownloadFinishWithLoader:self];
                }
                dispatch_semaphore_signal(self.semaphore);
                return;
            });
        }
        else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *html = json[@"i3"];
            
            NSString *regexStr = @"(?<=src=\")http.*?(?=\")";
            // 增加一层正则表达式的判断
            // TODO: 正则部分后面单独抽出来,目前请求块还是太混乱了
            NSString *url = nil;
            if ([self matchString:html toRegexString:regexStr] && [self matchString:html toRegexString:regexStr].count) {
                url = [[self matchString:html toRegexString:regexStr].firstObject copy];
            }
            if (url && url.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.model.imageUrl = url;
                    [self downloadBigImageUrl];
                });
            } else {
                // 虽然获取到了Json，但是图片url没有获取到
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.model.failed = YES;
                    NSLog(@"api请求错误，大图url没获取到");
                    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
                        [self.delegate imageDownloadFinishWithLoader:self];
                    }
                    dispatch_semaphore_signal(self.semaphore);
                    return;
                });
            }
        }
    }];
    // 执行任务之前先看任务是否已经退出
    if (self.cancelled) {
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    [task resume];
}

//根据正则表达式筛选
- (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    //match: 所有匹配到的字符,根据() 包含级
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

- (void)downloadFail {
    self.model.parser = NO;
    self.model.failed = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
        [self.delegate imageDownloadFinishWithLoader:self];
    }
    dispatch_semaphore_signal(self.semaphore);
}

// 下载大图
- (void)downloadBigImageUrl {
    if (self.cancelled) {
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    // 构建下载图片的方法，并且监听下载进度，并随时监测cancel状态
    NSLog(@"准备下载图片数据！");
    
    // 检查一下model是否有备份data
    NSURLSession *session = [self getSessionWithDelegate:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.model.imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.f];
    // 如果有缓存的时候使用缓存data继续下载，否则从头下载
    if (self.model.currentData) {
        self.task = [session downloadTaskWithResumeData:self.model.currentData];
    } else {
        self.task = [session downloadTaskWithRequest:request];
    }
    if (self.cancelled) {
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    // 开始下载
    [self.task resume];
}

- (NSURLSession *)getSessionWithDelegate:(BOOL)hasDelegate {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    return hasDelegate ? [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]] : [NSURLSession sessionWithConfiguration:configuration];
}

- (void)cancelTask {
    NSLog(@"请求还在继续，手动取消");
    self.isCancel = YES;
    // 如果退出了，则停止任务
    __weak typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.model.currentData = resumeData;
    }];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

#pragma mark - NSURLSessionDownloadDelegate
// 下载完成
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSLog(@"图片%ld下载完成", self.model.page);
    // 图片存储起来
    // 下载完成时调用
    // 保存到本地
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *imagePath = [cachePath stringByAppendingPathComponent:[_model.url MD5]];
    
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:imagePath] error:nil];
    // 更新本地地址
    dispatch_async(dispatch_get_main_queue(), ^{
        self.model.imagePath = imagePath;
    });
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
        [self.delegate imageDownloadFinishWithLoader:self];
    }
    [session invalidateAndCancel];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)creatFolderWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// 请求成功回调，下载失败也会回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [session invalidateAndCancel];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadingFail];
        });
    }
}

// 取消任务的时候会走这个
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    [session invalidateAndCancel];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadingFail];
        });
    }
}

// 取消任务和下载失败都会走didCompleteWithError方法
- (void)downloadingFail {
    NSLog(@"图片%ld下载失败", self.model.page);
    // 如果不是取消任务，则把数据参数清空
    if (!self.isCancel) {
        self.model.currentData = nil;
    }
    self.model.failed = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDownloadFinishWithLoader:)]) {
        [self.delegate imageDownloadFinishWithLoader:self];
    }
    dispatch_semaphore_signal(self.semaphore);
}

// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat rate = 100.f * totalBytesWritten / totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.model.rate = rate;
    });
}

@end
