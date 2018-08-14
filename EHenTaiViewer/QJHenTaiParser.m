//
//  QJHenTaiParser.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//
//  TODO:移动数据网络状态下的请求可以使用allowsCellularAccess属性来控制,现在的逻辑每次请求直接根据布尔值判断,比较蠢,待处理

#import "QJHenTaiParser.h"
#import "TFHpple.h"
#import "QJNetworkTool.h"
#import "QJBigImageItem.h"
#import "QJListItem.h"
#import "QJGalleryItem.h"
#import "QJTorrentItem.h"
#import "QJToplistUploaderItem.h"
#import "QJSettingItem.h"

#define kConfigurationIdentifier @"EHenTaiViewer"

@interface QJHenTaiParser ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSArray<UIColor *> *colorArr;

@end

@implementation QJHenTaiParser

#pragma mark -创建一个单例
+ (instancetype)parser {
    static QJHenTaiParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [QJHenTaiParser new];
    });
    return parser;
}

#pragma mark -登陆表单提交
- (void)loginWithUserName:(NSString *)username password:(NSString *)password complete:(LoginHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSDictionary *jsonDictionary = @{
                                     @"UserName": username,
                                     @"PassWord": password,
                                     @"x":@12,//???
                                     @"y":@8//???
                                     };
    NSString *apiurl = @"https://forums.e-hentai.org/index.php?act=Login&CODE=01&CookieDate=1";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getFormStringWithDict:jsonDictionary] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        if ([self checkCookie]) {
            //登陆成功
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([self saveUserNameWithString:html]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Toast(@"登陆成功");
                    completion(QJHenTaiParserStatusSuccess);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Toast(@"登陆成功,没获取到账号名字");
                    completion(QJHenTaiParserStatusParseFail);
                });
            }
        } else {
            //登陆失败
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"登陆失败,请尝试网页登陆");
                completion(QJHenTaiParserStatusParseFail);
            });
        }
        
    }];
    [task resume];
}

#pragma mark -获取用户名
- (BOOL)saveUserNameWithString:(NSString *)html {
    NSString *regexStr = @"(?<=:\\h).*?(?=\\<)";
    NSString *userName = [[self matchString:html toRegexString:regexStr].firstObject copy];
    if (userName.length) {
        NSObjSetForKey(@"loginName", userName);
        NSObjSynchronize();
        return YES;
    }
    NSObjSetForKey(@"loginName", @"");
    NSObjSynchronize();
    return NO;
}

- (NSString *)getFormStringWithDict:(NSDictionary *)dict {
    NSMutableArray *queries = [NSMutableArray array];
    for (NSString *key in dict.allKeys) {
        [queries addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];
    }
    return [queries componentsJoinedByString:@"&"];
}

- (BOOL)checkCookie {
    NSURL *hentaiURL = [NSURL URLWithString:@"http://g.e-hentai.org"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hentaiURL]) {
        if ([cookie.name isEqualToString:@"ipb_pass_hash"]) {
            if ([[NSDate date] compare:cookie.expiresDate] != NSOrderedAscending) {
                return NO;
            }
            else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)deleteCokie {
    NSURL *hentaiURL = [NSURL URLWithString:@"http://g.e-hentai.org"];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookiesForURL:hentaiURL]) {
        [cookieJar deleteCookie:cookie];
    }
    NSObjSetForKey(@"loginName", @"未登录");
    NSObjSetForKey(@"xl_0", @"");
    NSObjSynchronize();
    [QJGlobalInfo setExHentaiStatus:NO];
    return YES;
}

#pragma mark -收藏
- (void)updateFavoriteStatus:(BOOL)isFavorite model:(QJListItem *)item index:(NSInteger)index content:(NSString *)content complete:(LoginHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSString *url = [NSString stringWithFormat:@"%@gallerypopups.php?gid=%@&t=%@&act=addfav",[NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL],item.gid ,item.token];
    NSDictionary *dict = [NSDictionary new];
    if (isFavorite) {
        //删除
        dict = @{
                 @"favcat":@"favdel",
                 @"favnote":@"",//留言
                 @"apply":@"Apply Changes",
                 @"update":@"1"
                 };
    } else {
        //添加
        dict = @{
                 @"favcat":@(index),
                 @"favnote":content,//留言
                 @"apply":@"Add to Favorites",
                 @"update":@"1"
                 };
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getFormStringWithDict:dict] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        if ([[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] containsString:@"Close Window"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(QJHenTaiParserStatusSuccess);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"操作或成功,但检测不到操作状态");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
    }];
    [task resume];
}

- (void)updateMutlitFavoriteWithUrl:(NSString *)url status:(NSString *)ddact modifygids:(NSArray *)modifygids complete:(LoginHandler)completion {
    url = [NSString stringWithFormat:@"%@%@",[NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL], url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    NSMutableArray *queries = [NSMutableArray array];
    for (QJListItem *model in modifygids) {
        [queries addObject:[NSString stringWithFormat:@"modifygids[]=%@", model.gid]];
    }
    NSString *body = [queries componentsJoinedByString:@"&"];
    body = [NSString stringWithFormat:@"ddact=%@&apply=Apply&%@", ddact, body];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"操作成功");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"操作或成功,但检测不到操作状态");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
    }];
    [task resume];
}

#pragma mark -评论
//评论存在重定向,提交后直接拦截重定向
//所以不能用全局的Session,用局部的新定义Session
- (void)updateCommentWithContent:(NSString *)content url:(NSString *)url complete:(LoginHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSDictionary *dict = @{
                           @"commenttext":content,
                           @"postcomment":@"Post Comment"
                           };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getFormStringWithDict:dict] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse.statusCode == 301 || urlResponse.statusCode == 302) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"回复成功");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"操作或成功,但检测不到操作状态");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler {
    completionHandler(nil);
}

#pragma mark -列表爬取
- (void)updateListInfoWithUrl:(NSString *)url complete:(ListHandler)completion total:(TotalHandler)total {
    [self requestListInfo:url searchRule:@"//div [@class='it5']//a" complete:completion total:total];
}

#pragma mark -热门爬取
- (void)updateHotListInfoComplete:(ListHandler)completion {
    [self requestListInfo:nil searchRule:@"//div [@class='id3']//a" complete:completion total:nil];
}

#pragma mark -收藏爬取
- (void)updateLikeListInfoWithUrl:(NSString *)url complete:(ListHandler)completion {
    [self updateListInfoWithUrl:url complete:completion total:nil];
}

#pragma mark -上传人和tag爬取
- (void)updateOtherListInfoWithUrl:(NSString *)url complete:(ListHandler)completion {
    [self updateListInfoWithUrl:url complete:completion total:nil];
}

- (void)requestListInfo:(NSString *)url searchRule:(NSString *)searchRule complete:(ListHandler)completion total:(TotalHandler)total {
    [[QJNetworkTool shareTool] showNetworkActivity];
    if ([url  isEqual: @""])
    {
        url = @"?";
    } else {
        url = [url stringByAppendingString:@"&"];
    }
    if (!([url containsString:@"favorites.php"] && ([url containsString:@"page"] || [url containsString:@"f_search"]))) {
        // 强制 list 结果,现在官网配置改为存在云端了,有些账号习惯用瀑布流的方式浏览网页,所以这里这样强制成list形式防止解析出错
        // 收藏界面除外,这个界面无需强制
        url = [url stringByAppendingString:@"inline_set=dm_l"];
    }
    NSString *finalUrl = @"";
    if (url) {
        if ([url hasPrefix:@"http"]) {
            finalUrl = url;
        } else {
            //首页列表
            NSMutableString *baseUrl = [NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL];
            [baseUrl appendString:url];
            finalUrl = baseUrl;
        }
    } else {
        finalUrl = HENTAI_URL;
    }
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail, nil);
            });
            return;
        }
        //这个解析是肯定有的
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        if ([finalUrl containsString:@"favorites"]) {
            //这时候解析收藏夹
            [self parserFavoritesInfoWithHpple:xpathParser];
        }
        NSString *html = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        if ([html containsString:@"IP address"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"IP被识别为爬虫状态,请更换IP或一两个小时后重试");
                completion(QJHenTaiParserStatusNetworkFail, nil);
            });
            return;
        }
        if ([html containsString:@"No hits found"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"没有更多数据");
                completion(QJHenTaiParserStatusParseNoMore, nil);
            });
            return;
        }
        if (total) {
            TFHppleElement *totalElement = [xpathParser searchWithXPathQuery:@"//table[@class='ptt']//td[last()-1]//a"].firstObject;
            total(totalElement.text && totalElement.text.length ? [totalElement.text integerValue] : 0);
        }
        // 获取当前页码
        TFHppleElement *currentElement = [xpathParser searchWithXPathQuery:@"//table[@class='ptt']//td[@class='ptds']//a"].firstObject;
        NSInteger currentPage = currentElement.text && currentElement.text.length ? [currentElement.text integerValue] : 0;
        //NSLog(@"%@",[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]);
        NSArray *photoURL = [xpathParser searchWithXPathQuery:searchRule];
        if (photoURL.count) {
            NSMutableArray *urlStringArray = [NSMutableArray array];
            NSMutableArray *subUrlSringArray = [NSMutableArray new];
            for (NSInteger i = 0; i < photoURL.count; i++) {
                TFHppleElement * eachTitleWithURL = photoURL[i];
                if (subUrlSringArray.count == 25) {
                    [urlStringArray addObject:[subUrlSringArray mutableCopy]];
                    [subUrlSringArray removeAllObjects];
                }
                [subUrlSringArray addObject:[eachTitleWithURL attributes][@"href"]];
                if (i == photoURL.count - 1) {
                    [urlStringArray addObject:[subUrlSringArray mutableCopy]];
                }
            }
            //计数超过25会请求不到,要把接口拆分来获取参数
            NSMutableArray *allList = [NSMutableArray new];
            for (NSInteger i = 0; i < photoURL.count; i++) {
                [allList addObject:@""];
            }
            NSInteger count = urlStringArray.count;
            __block NSInteger weakCount = count;
            for (NSInteger i = 0; i < urlStringArray.count; i++) {
                NSArray *subArr = urlStringArray[i];
                [self requestListInfoFromApi:subArr complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
                    if (status == QJHenTaiParserStatusSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (NSInteger j = 25 * i; j < subArr.count + 25 * i; j++) {
                                QJListItem *item = listArray[j - 25 * i];
                                item.page = currentPage;
                                allList[j] = item;
                            }
                            weakCount--;
                            if (weakCount == 0) {
                                completion(QJHenTaiParserStatusSuccess,allList);
                            }
                        });
                    }
                    else if (status == QJHenTaiParserStatusParseFail) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Toast(@"解析错误,等待升级版本");
                            completion(QJHenTaiParserStatusParseFail,nil);
                        });
                    }
                    else if (status == QJHenTaiParserStatusNetworkFail) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Toast(@"网络错误");
                            completion(QJHenTaiParserStatusNetworkFail,nil);
                        });
                    }
                }];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"解析错误,等待升级版本");
                completion(QJHenTaiParserStatusParseFail, nil);
            });
        }
    }];
    [task resume];
}

#pragma mark -收藏夹名字的爬取
- (void)parserFavoritesInfoWithHpple:(TFHpple *)xpathParser {
    NSMutableArray *favorites = [NSMutableArray new];
    TFHppleElement *facatsElement = [xpathParser searchWithXPathQuery:@"//div[@class='nosel']"].firstObject;
    NSArray *facats = facatsElement.children;
    NSInteger total = 0;
    for (TFHppleElement *facatElement in facats) {
        NSArray<TFHppleElement *> *divs = [facatElement searchWithXPathQuery:@"//div"];
        if (divs.count >= 3) {
            //收藏夹名字,收藏数
            NSMutableArray *subArr = [NSMutableArray new];
            [subArr addObject:divs.lastObject.text];
            NSString *count = divs[1].text;
            [subArr addObject:count];
            total += [count integerValue];
            [favorites addObject:subArr];
        }
    }
    //最后加入全部收藏夹的信息
    [favorites addObject:@[@"All Favorites", [NSString stringWithFormat:@"%ld",(long)total]]];
    NSObjSetForKey(@"favorites", favorites);
    NSObjSynchronize();
}

#pragma mark -toplist爬取
- (void)updateToplistInfoComplete:(ToplistHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    //只有表站有top统计,里站并没有
    NSString *finalUrl = @"https://e-hentai.org/toplist.php";
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail, nil, nil);
            });
            return;
        }
        //NSString *html = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        //遍历获取上传者
        NSArray *uploaderURL = [xpathParser searchWithXPathQuery:@"//div[@class='ido']/div[2]//div[@class='tdo']//table//a"];
        NSMutableArray *upladers = [NSMutableArray new];
        for (TFHppleElement *uploaderWithURL in uploaderURL) {
            QJToplistUploaderItem *item = [QJToplistUploaderItem new];
            item.name = uploaderWithURL.text;
            item.url = uploaderWithURL.attributes[@"href"];
            [upladers addObject:item];
        }
        //遍历获取画廊
        NSArray *photoURL = [xpathParser searchWithXPathQuery:@"//div[@class='dc']//div[@class='tdo']//table//a"];
        if (photoURL.count) {
            //TODO:toplist用25限制请求有时候貌似会有一条画廊请求不到,这是为什么?
            NSMutableArray *urlStringArray = [NSMutableArray array];
            NSMutableArray *subUrlSringArray = [NSMutableArray new];
            for (NSInteger i = 0; i < photoURL.count; i++) {
                TFHppleElement * eachTitleWithURL = photoURL[i];
                if (subUrlSringArray.count == 25) {
                    [urlStringArray addObject:[subUrlSringArray mutableCopy]];
                    [subUrlSringArray removeAllObjects];
                }
                [subUrlSringArray addObject:[eachTitleWithURL attributes][@"href"]];
                if (i == photoURL.count - 1) {
                    [urlStringArray addObject:[subUrlSringArray mutableCopy]];
                }
            }
            //计数超过25会请求不到,要把接口拆分来获取参数
            NSMutableArray *allList = [NSMutableArray new];
            for (NSInteger i = 0; i < photoURL.count; i++) {
                [allList addObject:@""];
            }
            NSInteger count = urlStringArray.count;
            __block NSInteger weakCount = count;
            for (NSInteger i = 0; i < urlStringArray.count; i++) {
                NSArray *subArr = urlStringArray[i];
                [self requestListInfoFromApi:subArr complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
                    if (status == QJHenTaiParserStatusSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (NSInteger j = 25 * i; j < subArr.count + 25 * i; j++) {
                                allList[j] = listArray[j - 25 * i];
                            }
                            weakCount--;
                            if (weakCount == 0) {
                                completion(QJHenTaiParserStatusSuccess,allList, upladers);
                            }
                        });
                    }
                    else if (status == QJHenTaiParserStatusParseFail) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Toast(@"解析错误,等待升级版本");
                            completion(QJHenTaiParserStatusParseFail,nil, nil);
                        });
                    }
                    else if (status == QJHenTaiParserStatusNetworkFail) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Toast(@"网络错误");
                            completion(QJHenTaiParserStatusNetworkFail,nil, nil);
                        });
                    }
                }];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"解析错误,等待升级版本");
                completion(QJHenTaiParserStatusParseFail, nil, nil);
            });
        }
    }];
    [task resume];
}

- (void)updateOneUrlInfoWithUrl:(NSString *)url complete:(ListHandler)completion {
    [self requestListInfoFromApi:@[url] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == QJHenTaiParserStatusSuccess) {
                completion(QJHenTaiParserStatusSuccess,listArray);
            }
            else if (status == QJHenTaiParserStatusParseFail) {
                completion(QJHenTaiParserStatusParseFail,nil);
            }
            else if (status == QJHenTaiParserStatusNetworkFail) {
                completion(QJHenTaiParserStatusNetworkFail,nil);
            }
        });
    }];
}

- (void)requestListInfoFromApi:(NSArray *)urlArr complete:(ListHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSMutableArray *idArray = [NSMutableArray array];
    NSString *baseUrl = nil;
    for (NSString *eachURLString in urlArr) {
        NSArray *splitStrings = [eachURLString componentsSeparatedByString:@"/"];
        NSUInteger splitCount = [splitStrings count];
        [idArray addObject:@[splitStrings[splitCount - 3], splitStrings[splitCount - 2]]];
        if (nil == baseUrl) {
            baseUrl = eachURLString;
        }
    }
    NSDictionary *jsonDictionary = @{ @"method": @"gdata", @"gidlist":idArray };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *apiurl = [baseUrl containsString:@"exhentai"] ? EXHENTAI_APIURL : HENTAI_APIURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody =jsonData;
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            completion(QJHenTaiParserStatusNetworkFail, nil);
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *listArr = dict[@"gmetadata"];
        if (listArr) {
            NSMutableArray *newArr = [NSMutableArray new];
            for (NSInteger i = 0; i < listArr.count; i++) {
                NSDictionary *dict = listArr[i];
                QJListItem *item = [[QJListItem alloc] initWithDict:dict classifyArr:self.classifyArr colorArr:self.colorArr];
                item.url = urlArr[i];
                [newArr addObject:item];
            }
            completion(QJHenTaiParserStatusSuccess, newArr);
        }
        else {
            completion(QJHenTaiParserStatusParseFail, nil);
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

#pragma mark -画廊信息解析
- (void)updateGalleryInfoWithUrl:(NSString *)url complete:(GalleryHandler)completion {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 删除画廊显示??待验证
    NSString *finalUrl = [NSString stringWithFormat:@"%@?hc=1&inline_set=ts_l&nw=always",url];
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail, nil);
            });
            return;
        }
        if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] containsString:@"This gallery has been removed"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"画廊已删除");
                completion(QJHenTaiParserStatusParseFail,nil);
            });
            return;
        }
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        QJGalleryItem *item = [[QJGalleryItem alloc] initWithHpple:xpathParser];
        if (nil == item.testUrl && !item.testUrl.length) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"解析错误,等待升级版本");
                completion(QJHenTaiParserStatusParseFail,nil);
            });
            return;
        }
        
        [self getShowkeyWithUrl:item.testUrl complete:^(QJHenTaiParserStatus status, NSString *showkey) {
            [[QJNetworkTool shareTool] hiddenNetworkActivity];
            if (status == QJHenTaiParserStatusSuccess) {
                item.showkey = showkey;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(QJHenTaiParserStatusSuccess,item);
                });
            }
            else if (status == QJHenTaiParserStatusParseFail) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(QJHenTaiParserStatusParseFail,nil);
                });
            }
            else if (status == QJHenTaiParserStatusNetworkFail) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(QJHenTaiParserStatusNetworkFail,nil);
                });
            }
        }];
    }];
    [task resume];
}

- (void)getShowkeyWithUrl:(NSString *)url complete:(ShowkeyHandler)completion {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            completion(QJHenTaiParserStatusNetworkFail,nil);
            return;
        }
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *regexStr = @"(?<=showkey=\").*?(?=\";)";
        NSString *showkey = [[self matchString:html toRegexString:regexStr].firstObject copy];
        if (showkey.length) {
            completion(QJHenTaiParserStatusSuccess,showkey);
        }
        else {
            completion(QJHenTaiParserStatusParseFail,nil);
        }
    }];
    [task resume];
}

#pragma mark -大图链接爬取
- (void)updateBigImageUrlWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count complete:(BigImageListHandler)completion {
    //页码从0开始,40一页
    NSMutableArray *newArr = [NSMutableArray new];
    for (NSInteger i = 1; i <= count; i++) {
        QJBigImageItem *item = [QJBigImageItem new];
        item.page = i;
        [newArr addObject:item];
    }
    completion(newArr);
    NSInteger total = count % 40 == 0 ? count / 40 : count / 40 + 1;
    for (NSInteger i = 0; i < total; i++) {
        [self updateBigImageUrlWithUrl:url page:i showKey:showkey gid:gid array:newArr];
    }
}

- (void)updateBigImageUrlWithUrl:(NSString *)url page:(NSInteger)page showKey:(NSString *)showkey gid:(NSString *)gid array:(NSArray<QJBigImageItem *> *)array {
    //页码从0开始,40一页
    NSString *finalUrl = @"";
    if (page == 0) {
        finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m",url];
    }
    else {
        finalUrl = [NSString stringWithFormat:@"%@?inline_set=ts_m&p=%ld",url,(long)page];
    }
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
            });
            return;
        }
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *pageURL  = [xpathParser searchWithXPathQuery:@"//div [@class='gdtm']//a"];
        
        for (NSInteger i = 0; i < pageURL.count; i++) {
            TFHppleElement *e = pageURL[i];
            QJBigImageItem *item = array[i + page * 40];
            NSString *url = e.attributes[@"href"];
            if (!url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Toast(@"解析错误,等待升级版本");
                });
                break;
            }
            //https://e-hentai.org/s/4d74e00bc9/1070576-42
            //4d74e00bc9 为imagekey
            NSArray *arr = [url componentsSeparatedByString:@"/"];
            NSString *imageKey = arr[arr.count - 2];
            
            [self updateBigImageUrlWithShowKey:showkey gid:gid imgkey:imageKey page:item.page complete:^(QJHenTaiParserStatus status, NSString *url,NSString *x ,NSString *y) {
                if (status == QJHenTaiParserStatusSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        item.realImageUrl = url;
                        item.x = x;
                        item.y = y;
                    });
                }
            }];
        }
    }];
    [task resume];
}

#pragma mark -大图爬取
- (void)updateBigImageUrlWithShowKey:(NSString *)showkey gid:(NSString *)gid imgkey:(NSString *)imgkey page:(NSInteger)page complete:(BigImageHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSDictionary *jsonDictionary = @{
                                     @"method": @"showpage",
                                     @"gid": gid,
                                     @"page": @(page),
                                     @"imgkey": imgkey,
                                     @"showkey": showkey
                                     };
    NSString *apiurl = [QJGlobalInfo isExHentaiStatus] ? EXHENTAI_APIURL : HENTAI_APIURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail,nil,nil,nil);
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
                completion(QJHenTaiParserStatusSuccess,url,x,y);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(QJHenTaiParserStatusParseFail,nil,nil,nil);
            });
        }
    }];
    [task resume];
}

#pragma mark -评星
- (void)updateStarWithGid:(NSString *)gid token:(NSString *)token apikey:(NSString *)apikey apiuid:(NSString *)apiuid rating:(NSInteger)rating complete:(LoginHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSDictionary *jsonDictionary = @{
                                     @"method": @"rategallery",
                                     @"gid": gid,
                                     @"apikey": apikey,
                                     @"apiuid": apiuid,
                                     @"rating": @(rating),
                                     @"token": token
                                     };
    NSString *apiurl = [QJGlobalInfo isExHentaiStatus] ? EXHENTAI_APIURL : HENTAI_APIURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (json.allKeys.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"评星成功");
                completion(QJHenTaiParserStatusSuccess);
            });
        }
    }];
    [task resume];
}

#pragma mark -种子爬取
- (void)updateTorrentInfoWithGid:(NSString *)gid token:(NSString *)token complete:(TorrentListHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSString *url = [NSString stringWithFormat:@"gallerytorrents.php?gid=%@&t=%@",gid,token];
    NSMutableString *finalUrl = [NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL];
    [finalUrl appendString:url];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                completion(QJHenTaiParserStatusNetworkFail, nil);
            });
            return;
        }
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        //NSLog(@"%@",[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]);
        NSArray *torrents  = [xpathParser searchWithXPathQuery:@"//form [@method='post']//table"];
        if (nil == torrents) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(QJHenTaiParserStatusParseFail,nil);
            });
            return;
        }
        NSMutableArray *newTorrents = [NSMutableArray new];
        for (TFHppleElement *subElement in torrents) {
            QJTorrentItem *item = [QJTorrentItem new];
            item.posted = [[subElement searchWithXPathQuery:@"//td"].firstObject text];
            item.size = [[subElement searchWithXPathQuery:@"//td"][1] text];
            item.seeds = [[subElement searchWithXPathQuery:@"//td"][3] text];
            item.peers = [[subElement searchWithXPathQuery:@"//td"][4] text];
            item.downloads = [[subElement searchWithXPathQuery:@"//td"][5] text];
            item.uploader = [[subElement searchWithXPathQuery:@"//td"][6] text];
            item.name = [[subElement searchWithXPathQuery:@"//td//a"].firstObject text];
            NSString *url = [subElement searchWithXPathQuery:@"//td//a"].firstObject[@"href"];
            item.magnet = [NSString stringWithFormat:@"magnet:?xt=urn:btih:%@",[[url componentsSeparatedByString:@"/"].lastObject stringByDeletingPathExtension]];
            [newTorrents addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(QJHenTaiParserStatusSuccess,newTorrents);
        });
        
    }];
    [task resume];
}

#pragma mark -网站设置读取
- (void)readSettingAllInfoCompletion:(SettingHandler)completion {
    //https://e-hentai.org/uconfig.php
    [[QJNetworkTool shareTool] showNetworkActivity];
    NSMutableString *finalUrl = [NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL];
    [finalUrl appendString:@"uconfig.php"];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:finalUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(QJHenTaiParserStatusNetworkFail,nil);
                return;
            });
        }
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *settings = [xpathParser searchWithXPathQuery:@"//div[@class='optmain']"];
        NSMutableDictionary *allSettingDic = [NSMutableDictionary new];
        for (TFHppleElement *subElement in settings) {
            TFHppleElement *nameElement = [subElement searchWithXPathQuery:@"//p"].firstObject;
            if ([nameElement.text containsString:@"What categories would you like to view as default on the front page"] || [nameElement.text containsString:@"If you wish to hide galleries in certain languages from the gallery list and searches"] || [nameElement.text containsString:@"If you want to exclude certain namespaces from a default tag search"]) {
                //排除语言,主页分类显示,排除标签组
                QJSettingItem *model = [QJSettingItem creatModelWithHpple:subElement];
                [allSettingDic setValue:model forKey:model.name];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(QJHenTaiParserStatusSuccess,allSettingDic);
        });
    }];
    [task resume];
}

- (void)postMySettingInfoWithParams:(NSDictionary *)params Completion:(LoginHandler)completion {
    [[QJNetworkTool shareTool] showNetworkActivity];
    //这里的操作只要上传自己想要的就好了,只是排除语言需要每次都上传,不然会遗漏,其他采用默认的就好了
    NSMutableString *finalUrl = [NSMutableString stringWithString:[QJGlobalInfo isExHentaiStatus] ? EXHENTAI_URL : HENTAI_URL];
    [finalUrl appendString:@"uconfig.php"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setValue:@"Apply" forKey:@"apply"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalUrl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getFormStringWithDict:dict] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[QJNetworkTool shareTool] hiddenNetworkActivity];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"网络错误");
                if (completion) completion(QJHenTaiParserStatusNetworkFail);
            });
            return;
        }
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([html containsString:@"If you wish to hide galleries in certain languages from the gallery list and searches"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置成功之后不需要提示
                //ToastSuccess(nil, @"设置成功!");
                if (completion) completion(QJHenTaiParserStatusSuccess);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                Toast(@"设置或成功,未解析到操作状态");
                if (completion) completion(QJHenTaiParserStatusParseFail);
            });
        }
    }];
    [task resume];
}

#pragma mark -懒加载
- (NSURLSession *)session {
    if (nil == _session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = YES;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (NSArray<NSString *> *)classifyArr {
    if (nil == _classifyArr) {
        _classifyArr = @[@"DOUJINSHI",
                         @"MANGA",
                         @"ARTIST CG",
                         @"GAME CG",
                         @"WESTERN",
                         @"NON-H",
                         @"IMAGE SET",
                         @"COSPLAY",
                         @"ASIAN PORN",
                         @"MISC"];
    }
    return _classifyArr;
}

- (NSArray<UIColor *> *)colorArr {
    if (nil == _colorArr) {
        _colorArr = @[
                      DOUJINSHI_COLOR,
                      MANGA_COLOR,
                      ARTISTCG_COLOR,
                      GAMECG_COLOR,
                      WESTERN_COLOR,
                      NONH_COLOR,
                      IMAGESET_COLOR,
                      COSPLAY_COLOR,
                      ASIANPORN_COLOR,
                      MISC_COLOR
                      ];
    }
    return _colorArr;
}

@end
