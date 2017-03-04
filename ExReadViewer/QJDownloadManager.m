//
//  QJDownloadManager.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/13.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJDownloadManager.h"
#import "AFNetworking.h"

@implementation QJDownloadManager

+ (QJDownloadManager *)shareQueue {
    static QJDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [QJDownloadManager new];
        instance.maxConcurrentOperationCount = 1;
        [instance addObserver:instance forKeyPath:@"operations" options:0 context:nil];
    });
    return instance;
}

- (void)addOneBookDownQueueWithImageUrlArr:(NSArray *)images bookName:(NSString *)bookName {
    NSInteger i = 1;
    for (NSString *imageUrl in images) {
        [self addOperationWithBlock:^{
            NSString *imageName = [imageUrl componentsSeparatedByString:@"."].lastObject;
            NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            //创建路径
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            NSString *createPath = [NSString stringWithFormat:@"%@/%@",localPath,bookName];
            if (![[NSFileManager defaultManager]fileExistsAtPath:createPath]) {
                [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
            }else{
                NSLog(@"有这个文件了");
            }
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            session.responseSerializer = [AFHTTPResponseSerializer serializer];
            [session GET:imageUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSData *data = responseObject;
                NSString *imagePath = [NSString stringWithFormat:@"%@/%4ld.%@", createPath,(long)i,imageName];
                [data writeToFile:imagePath atomically:YES];
                NSLog(@"%@",imagePath);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }];
        i++;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [QJDownloadManager shareQueue] && [keyPath isEqualToString:@"operations"]) {
        NSLog(@"%ld",[QJDownloadManager shareQueue].operations.count);
        if (0 == [QJDownloadManager shareQueue].operations.count){
            [SVProgressHUD showSuccessWithStatus:@"全部图片下载完成"];
            [SVProgressHUD dismissWithDelay:1.f];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
