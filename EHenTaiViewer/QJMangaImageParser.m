//
//  QJMangaImageParser.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/13.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJMangaImageParser.h"
#import "TFHpple.h"

@interface QJMangaImageParser()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSInteger count;

@end

@implementation QJMangaImageParser

- (instancetype)initWithGalleryUrl:(NSString *)url pageCount:(NSInteger)count theDelegate:(id<QJMangaImageParserDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.url = url;
        self.count = count;
    }
    return self;
}

// 开始任务
- (void)main {
    NSLog(@"开始解析页码为%ld的所有图片", self.count);
    // 随时监测队列的退出情况
    if (self.isCancelled) return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    @autoreleasepool {
        // 开始
        NSString *finalUrl = @"";
        if (self.count == 0) {
            finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m",self.url];
        }
        else {
            finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m&p=%ld",self.url,(long)self.count];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = YES;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        __weak typeof(NSURLSession) *weakSession = session;
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [weakSession invalidateAndCancel];
            NSMutableArray *urls = [NSMutableArray new];
            if (error) {
                // 报错的时候填充空字符串
                for (NSInteger i = 0; i < 40; i++) {
                    [urls addObject:@""];
                }
            }
            else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                // 这里有点疑问，需要斟酌，没有账号的时候gdtm，有账号的时候可以gdtl
                NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div[@class='gdtm']//a"];
                
                for (NSInteger i = 0; i < pageURL.count; i++) {
                    TFHppleElement *e = pageURL[i];
                    NSString *url = e.attributes[@"href"] == nil ? @"" : e.attributes[@"href"];
                    [urls addObject:url];
                    //https://e-hentai.org/s/4d74e00bc9/1070576-42
                }
            }
            // 这里任务结束,回调出去
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"图片链接解析完成");
                if (self.delegate && [self.delegate respondsToSelector:@selector(imageUrlDidParserWithArray:page:parser:)]) {
                    [self.delegate imageUrlDidParserWithArray:urls page:self.count parser:self];
                }
                dispatch_semaphore_signal(semaphore);
            });
        }];
        if (self.isCancelled) return;
        [task resume];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
