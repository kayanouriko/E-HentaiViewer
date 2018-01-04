//
//  QJMangaBrowerManager.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/7.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaBrowerManager.h"
#import "QJMangaURLSession.h"
#import "QJMangaModel.h"
#import "TFHpple.h"

typedef void (^imageUrlComplete)(NSString *url, NSString *x, NSString *y);

@interface QJMangaBrowerManager () {
    //用于存储解析获取的该画廊中单个图片对象
    NSMutableArray<QJMangaModel *> *_missions;
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
    [_missions removeAllObjects];
    for (NSInteger i = 1; i <= count; i++) {
        QJMangaModel *model = [QJMangaModel new];
        model.page = i;
        [_missions addObject:model];
    }
    complete(_missions);
    
    //开始解析获取大图的链接
    NSInteger total = count % 40 == 0 ? count / 40 : count / 40 + 1;
    for (NSInteger i = 0; i < total; i++) {
        [self updateBigImageUrlWithUrl:url page:i showKey:showkey gid:gid];
    }
}


- (void)updateBigImageUrlWithUrl:(NSString *)url page:(NSInteger)page showKey:(NSString *)showkey gid:(NSString *)gid {
    //页码从0开始,40一页
    NSString *finalUrl = @"";
    if (page == 0) {
        finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m",url];
    }
    else {
        finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m&p=%ld",url,(long)page];
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
            });
            return;
        }
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div [@class='gdtm']//a"];
        dispatch_semaphore_t sema = dispatch_semaphore_create(10);
        for (NSInteger i = 0; i < pageURL.count; i++) {
            TFHppleElement *e = pageURL[i];
            QJMangaModel *model = _missions[i + page * 40];
            NSString *url = e.attributes[@"href"];
            if (!url) {
                model.state = QJMangaModelStateFail;
                dispatch_semaphore_signal(sema);
                continue;
            }
            //https://e-hentai.org/s/4d74e00bc9/1070576-42
            //4d74e00bc9 为imagekey
            NSArray *arr = [url componentsSeparatedByString:@"/"];
            NSString *imageKey = arr[arr.count - 2];
            
            [self updateBigImageUrlWithShowKey:showkey gid:gid imgkey:imageKey page:model.page complete:^(NSString *url,NSString *x ,NSString *y) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.url = url;
                    model.state = QJMangaModelStateWait;
                    dispatch_semaphore_signal(sema);
                });
            }];
        }
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];
    [task resume];
}

- (void)updateBigImageUrlWithShowKey:(NSString *)showkey gid:(NSString *)gid imgkey:(NSString *)imgkey page:(NSInteger)page complete:(imageUrlComplete)completion {
    NetworkShow();
    NSDictionary *jsonDictionary = @{
                                     @"method": @"showpage",
                                     @"gid": gid,
                                     @"page": @(page),
                                     @"imgkey": imgkey,
                                     @"showkey": showkey
                                     };
    NSString *apiurl = [NSObjForKey(@"ExHentaiStatus") boolValue] ? EXHENTAI_APIURL : HENTAI_APIURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NetworkHidden();
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(nil,nil,nil);
            });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *html = json[@"i3"];
        
        NSString *regexStr = @"(?<=src=\")http.*?(?=\")";
        NSString *url = [[self matchString:html toRegexString:regexStr].firstObject copy];
        NSString *x = json[@"x"];
        NSString *y = json[@"y"];
        if (url.length) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(url,x,y);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,nil,nil);
            });
        }
    }];
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

- (void)endMission {
    
}

@end
