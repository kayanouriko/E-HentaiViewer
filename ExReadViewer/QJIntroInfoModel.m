//
//  QJIntroInfoModel.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/28.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJIntroInfoModel.h"
#import "TFHpple.h"

#define isError(key) if (nil == key){self.needUser = YES;return;}

@implementation QJCategoryButtonInfo

@end

@interface QJIntroInfoModel ()

@property (strong, nonatomic) NSArray *engMonthArr;

@end

@implementation QJIntroInfoModel

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self getAllInfoFromData:data];
    }
    return self;
}

- (void)getAllInfoFromData:(NSData *)data {
    //获取一些基本的画廊参数,账号操作相关
    //我的解析太烂了,东一块西一块
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //base_url
    NSString *baseurlRegexString = @"var base_url.*?;";
    NSString *baseurlString = [[self matchString:html toRegexString:baseurlRegexString].firstObject copy];
    baseurlString = [baseurlString substringFromIndex:16];
    baseurlString = [baseurlString substringToIndex:baseurlString.length - 2];
    self.baseUrl = baseurlString;
    
    self.needUser = NO;
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    //基本信息
    NSMutableDictionary *introInfoDict = [NSMutableDictionary new];
    //图片
    /*
    TFHppleElement *imageUrlElement = [xpathParser searchWithXPathQuery:@"//div[@id='gd1']//img"].firstObject;
    if (nil == imageUrlElement) {
        self.needUser = YES;
        return;
    }
    introInfoDict[@"imageUrl"]= [imageUrlElement objectForKey:@"src"];
    //类别
    TFHppleElement *categoryElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdc']//img"].firstObject;
    isError(categoryElement);
    NSString *category = [categoryElement objectForKey:@"alt"];
    introInfoDict[@"category"] = [category uppercaseString];
     */
    TFHppleElement *categoryUrlElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdc']//a"].firstObject;
    isError(categoryUrlElement);
    introInfoDict[@"categoryUrl"] = [categoryUrlElement objectForKey:@"href"];
    /*
    //标题
    TFHppleElement *titleElement = [xpathParser searchWithXPathQuery:@"//h1[@id='gn']"].firstObject;
    isError(titleElement);
    introInfoDict[@"title"] = titleElement.text;
    //作者
    TFHppleElement *authorElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdn']//a"].firstObject;
    isError(authorElement);
    introInfoDict[@"author"] = authorElement.text;
     */
    //解析一个表格
    //排序:上传时间,Parent(???父类),是否可见(???),语言,文件大小,总页数,喜欢数
    NSArray *otherArr = [xpathParser searchWithXPathQuery:@"//div[@id='gdd']//tr"];
    NSArray *otherKeyArr = @[@"posted",@"parent",@"visible",@"language",@"size",@"length",@"favorited"];
    for (NSInteger i = 0; i < otherArr.count; i++) {
        TFHppleElement *otherElment = otherArr[i];
        TFHppleElement *secondElment = [otherElment searchWithXPathQuery:@"//td [@class='gdt2']"].firstObject;
        introInfoDict[otherKeyArr[i]] = secondElment.text;
    }
    introInfoDict[@"posted"] = [self changeTimeToLocalTime:introInfoDict[@"posted"]];
    //评分人数和评分数
    TFHppleElement *scoreElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdr']"].firstObject;
    isError(scoreElement);
    TFHppleElement *scorePersonElement = [scoreElement searchWithXPathQuery:@"//td[@id='grt3']//span"].firstObject;
    isError(scorePersonElement);
    introInfoDict[@"scorePerson"] = scorePersonElement.text;
    TFHppleElement *scoreAvgElement = [scoreElement searchWithXPathQuery:@"//td[@id='rating_label']"].firstObject;
    isError(scoreAvgElement);
    introInfoDict[@"scoreAvg"] = scoreAvgElement.text;
    //是否已收藏
    TFHppleElement *favoriteElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdf']//a"].firstObject;
    introInfoDict[@"favoriteStatus"] = favoriteElement.text;
    //简介收集完成
    self.introDict = introInfoDict;
    //收集tag
    NSMutableArray *tagArr = [NSMutableArray new];
    NSArray *tagListArr = [xpathParser searchWithXPathQuery:@"//div[@id='taglist']//tr"];
    for (TFHppleElement *eachElement in tagListArr) {
        TFHppleElement *leftElement = [eachElement searchWithXPathQuery:@"//td[@class='tc']"].firstObject;
        NSString *leftStr = [leftElement.text stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSArray *rightArr = [eachElement searchWithXPathQuery:@"//td[2]//div//a"];
        NSMutableArray *rightTagArr = [NSMutableArray new];
        for (TFHppleElement *rightTagElement in rightArr) {
            QJCategoryButtonInfo *model = [QJCategoryButtonInfo new];
            model.name = rightTagElement.text;
            model.url = [rightTagElement objectForKey:@"href"];
            [rightTagArr addObject:model];
        }
        CGFloat tagViewHeight = [self getTagViewHeightWithLaftStr:leftStr rightArr:rightTagArr];
        [tagArr addObject:@[leftStr,rightTagArr,@(tagViewHeight)]];
    }
    self.tagArr = tagArr;
    //评论区解析
    NSArray *comments = [xpathParser searchWithXPathQuery:@"//div[@id='cdiv']"];
    if (comments.count) {
        TFHppleElement *hppleElement = [comments firstObject];
        NSArray *oneComments = [hppleElement searchWithXPathQuery:@"//div[@class='c1']"];
        NSMutableArray *commentsArr = [NSMutableArray new];
        for (TFHppleElement *oneCommentElement in oneComments) {
            NSMutableDictionary *oneCommentDict = [NSMutableDictionary new];
            //发布日期
            TFHppleElement *repostTime = [oneCommentElement searchWithXPathQuery:@"//div[@class='c3']"].firstObject;
            oneCommentDict[@"repostTime"] = [self getDateWithLocalStyle:repostTime.text];
            //名字和跳转名字搜索的url
            TFHppleElement *reporter = [oneCommentElement searchWithXPathQuery:@"//div[@class='c3']//a"].firstObject;
            oneCommentDict[@"reporterUrl"] = [reporter objectForKey:@"href"];
            oneCommentDict[@"reporter"] = reporter.text;
            //评分
            TFHppleElement *score = [oneCommentElement searchWithXPathQuery:@"//div[@class='c7']"].firstObject;
            oneCommentDict[@"score"] = score.text != nil ? score.text : @"uploader";
            //评论内容
            TFHppleElement *contentElement = [oneCommentElement searchWithXPathQuery:@"//div[@class='c6']"].firstObject;
            NSMutableString *content = [NSMutableString new];
            if (contentElement.children.count) {
                for (TFHppleElement *subContent in contentElement.children) {
                    if ([subContent isTextNode]) {
                        if ([content isEqualToString:@""]) {
                            [content appendFormat:@"%@",subContent.content];
                        }
                        else {
                            [content appendFormat:@"\n%@",subContent.content];
                        }
                    }
                }
            }
            oneCommentDict[@"content"] = content;
            //TODO c8是修改日期,暂时没爬取
            [commentsArr addObject:oneCommentDict];
        }
        self.commentsArr = commentsArr;
    }
    //获取大图总页数
    TFHppleElement *requestCountElement = [xpathParser searchWithXPathQuery:@"//p[@class='gpc']"].firstObject;
    NSArray *requestCountArr = [requestCountElement.text componentsSeparatedByString:@" "];
    NSInteger currCount = [requestCountArr[3] integerValue];
    NSInteger totalCount = [requestCountArr[5] integerValue];
    self.requestCount = totalCount % currCount ? totalCount / currCount : totalCount / currCount - 1;
    //缩略图图片的获取
    /*
     //老的遍历方法,但是里站没有,所以废弃,改用下面的图片切割
     TFHppleElement *smallImageUrlElement = [xpathParser searchWithXPathQuery:@"//div[@id='gd5']//p[@class='g2']//a"][1];
     NSMutableString *allImageUrl = [NSMutableString stringWithFormat:@"%@",[smallImageUrlElement objectForKey:@"onclick"]];
     NSString *regexString = @"'.*'";
     allImageUrl = [[self matchString:allImageUrl toRegexString:regexString].firstObject mutableCopy];
     allImageUrl = [[allImageUrl stringByReplacingOccurrencesOfString:@"'" withString:@""] mutableCopy];
     [allImageUrl appendString:@"&type=wiki"];
     self.allImageUrl = allImageUrl;
     */
    self.allImageUrlArr = [NSMutableArray new];
    NSArray *smallImageUrlArr = [xpathParser searchWithXPathQuery:@"//div[@id='gdt']//div[@class='gdtm']//div"];
    for (TFHppleElement *smallImageUrlElement in smallImageUrlArr) {
        TFHppleElement *imageUrlElement = [smallImageUrlElement searchWithXPathQuery:@"//div"].firstObject;
        NSMutableString *smallImageUrlStr = [NSMutableString stringWithFormat:@"%@",[imageUrlElement objectForKey:@"style"]];
        NSString *regexString = @"http.*jpg";
        NSString *smallImageUrl = [[self matchString:smallImageUrlStr toRegexString:regexString].firstObject copy];
        
        NSString *widthRegexString = @"width.*?px";
        NSString *widthString = [[self matchString:smallImageUrlStr toRegexString:widthRegexString].firstObject copy];
        widthString = [widthString substringWithRange:NSMakeRange(6, widthString.length - 8)];
        
        NSString *heightRegexString = @"height.*?px";
        NSString *heightString = [[self matchString:smallImageUrlStr toRegexString:heightRegexString].firstObject copy];
        heightString = [heightString substringWithRange:NSMakeRange(7, heightString.length - 9)];
        
        NSString *xRegexString = @"-.*?px";
        NSString *xString = [[self matchString:smallImageUrlStr toRegexString:xRegexString].firstObject copy];
        xString = [xString componentsSeparatedByString:@" "][1];
        xString = [xString substringWithRange:NSMakeRange(1, xString.length - 3)];
        
        NSDictionary *dict = @{
                               @"url":smallImageUrl,
                               @"x":xString,
                               @"width":widthString,
                               @"height":heightString
                               };
        [self.allImageUrlArr addObject:dict];
    }
}

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

//获取tagView的高度
- (CGFloat)getTagViewHeightWithLaftStr:(NSString *)leftStr rightArr:(NSArray *)rightArr {
    CGFloat leftLabelWidth = [leftStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kNormalFontSize} context:nil].size.width + 20;
    CGFloat buttonViewWidth = kScreenWidth - (leftLabelWidth + 40) - 20;
    CGFloat buttonX = leftLabelWidth + 40;
    NSInteger heihtCount = 0;
    for (int i = 0; i < rightArr.count; i++) {
        QJCategoryButtonInfo *model = rightArr[i];
        CGFloat buttonWidth = [model.name boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kNormalFontSize} context:nil].size.width + 20;
        if (buttonWidth > kScreenWidth - (leftLabelWidth + 40) - 20) {
            buttonWidth = kScreenWidth - (leftLabelWidth + 40) - 30;
        }
        if (buttonWidth > buttonViewWidth) {
            //不能放下
            heihtCount++;
            buttonX = leftLabelWidth + 40;
            buttonViewWidth = kScreenWidth - (leftLabelWidth + 40) - 20;
        }
        //剩余宽度
        buttonViewWidth -= buttonWidth + 10;
        buttonX += buttonWidth + 10;
    }
    return (heihtCount + 1) * 35;
}

//获取回复时间
- (NSString *)getDateWithLocalStyle:(NSString *)time {
    NSArray *array = [time componentsSeparatedByString:@" "];
    NSString *day = array[2];
    NSString *monthStr = array[3];
    NSInteger month = [self.engMonthArr indexOfObject:monthStr] + 1;
    NSString *year = [array[4] substringWithRange:NSMakeRange(0, 4)];
    NSString *hourAndMintime = array[5];
    
    NSString *utcTime = [NSString stringWithFormat:@"%4ld-%2ld-%2ld %@",(long)[year integerValue],(long)month,(long)[day integerValue],hourAndMintime];
    NSString *dateNowStr = [self changeTimeToLocalTime:utcTime];
    return dateNowStr;
}

//转换成当前时区的时间格式
- (NSString *)changeTimeToLocalTime:(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *utcDate = [dateFormatter dateFromString:time];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval timeValue = [zone secondsFromGMTForDate:utcDate];
    NSDate *dateNow = [utcDate dateByAddingTimeInterval:timeValue];
    NSString *dateNowStr = [dateFormatter stringFromDate:dateNow];
    return dateNowStr;
}

//获取缩略图
- (NSMutableArray *)getAllImageWithData:(NSData *)data {
    NSMutableArray *allImageArr = [NSMutableArray new];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    TFHppleElement *allImageElement = [xpathParser searchWithXPathQuery:@"//textarea"].firstObject;
    NSMutableString *allImageStr = [NSMutableString new];
    if (allImageElement.children.count) {
        for (TFHppleElement *subContent in allImageElement.children) {
            if ([subContent isTextNode]) {
                if ([allImageStr isEqualToString:@""]) {
                    [allImageStr appendFormat:@"%@",subContent.content];
                }
                else {
                    [allImageStr appendFormat:@"\n%@",subContent.content];
                }
            }
        }
    }
    [allImageArr addObjectsFromArray:[self matchString:allImageStr toRegexString:@"http.*jpg"]];
    [allImageArr removeObjectAtIndex:0];
    return allImageArr;
}

#pragma mark -懒加载
- (NSArray *)engMonthArr {
    if (nil == _engMonthArr) {
        _engMonthArr = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    }
    return _engMonthArr;
}

@end
