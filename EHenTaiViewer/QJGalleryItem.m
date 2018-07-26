//
//  QJGalleryItem.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGalleryItem.h"
#import "NSString+StringHeight.h"
#import "Tag+CoreDataClass.h"
#import "TFHpple.h"

@implementation QJGalleryTagItem

@end

@interface QJGalleryItem ()

@property (strong, nonatomic) NSArray *engMonthArr;

@end

@implementation QJGalleryItem

- (instancetype)initWithHpple:(TFHpple *)xpathParser {
    self = [super init];
    if (self) {
        [self parserWithHpple:xpathParser];
    }
    return self;
}

- (void)parserWithHpple:(TFHpple *)xpathParser {
    //解析缩略图
    [self parserSmallImagesWithHpple:xpathParser];
    //解析基础信息
    [self parserBaseInfoWithHpple:xpathParser];
    //解析评论
    [self parserCommentsWithHpple:xpathParser];
    //解析tag
    [self parserTagWithHpple:xpathParser];
    //解析收藏状态
    [self parserStatusWithHpple:xpathParser];
    //解析api
    [self parserApiWithHpple:xpathParser];
}

- (void)parserApiWithHpple:(TFHpple *)xpathParser {
    TFHppleElement *apiElement = [xpathParser searchWithXPathQuery:@"//script[@type='text/javascript']"][1];
    NSString *jsHtml = apiElement.firstChild.content;
    NSString *regexStr = @"(?<=apiuid\\h=\\h).*?(?=;)";
    NSString *apiuid = [[self matchString:jsHtml toRegexString:regexStr].firstObject copy];
    self.apiuid = apiuid;
    
    NSString *regexStr1 = @"(?<=apikey\\h=\\h\").*?(?=\")";
    NSString *apikey = [[self matchString:jsHtml toRegexString:regexStr1].firstObject copy];
    self.apikey = apikey;
    
    //获取账号在该画廊的评分
    NSString *regexStr3 = @"(?<=average_rating\\h=\\h).*?(?=;)";
    NSString *avgSore = [[self matchString:jsHtml toRegexString:regexStr3].firstObject copy];
    
    NSString *regexStr2 = @"(?<=display_rating\\h=\\h).*?(?=;)";
    NSString *customSore = [[self matchString:jsHtml toRegexString:regexStr2].firstObject copy];
    if ([avgSore isEqualToString:customSore]) {
        self.customSore = 0;
    } else {
        self.customSore = [customSore floatValue];
    }
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

- (void)parserStatusWithHpple:(TFHpple *)xpathParser {
    TFHppleElement *favoriteElement = [xpathParser searchWithXPathQuery:@"//div[@id='gdf']//a"].firstObject;
    self.isFavorite = ![favoriteElement.text containsString:@"Add to Favorites"];
}

- (void)parserTagWithHpple:(TFHpple *)xpathParser {
    NSMutableArray *tagArr = [NSMutableArray new];
    NSArray *tagListArr = [xpathParser searchWithXPathQuery:@"//div[@id='taglist']//tr"];
    for (TFHppleElement *eachElement in tagListArr) {
        TFHppleElement *leftElement = [eachElement searchWithXPathQuery:@"//td[@class='tc']"].firstObject;
        NSString *leftStr = [leftElement.text stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSArray *rightArr = [eachElement searchWithXPathQuery:@"//td[2]//div//a"];
        NSMutableArray *rightTagArr = [NSMutableArray new];
        for (TFHppleElement *rightTagElement in rightArr) {
            QJGalleryTagItem *model = [QJGalleryTagItem new];
            
            NSString *tagString = rightTagElement.text;
            //如果标签有多个含义,则第一个为最原始的含义
            if ([tagString containsString:@"|"]) {
                tagString = [tagString componentsSeparatedByString:@" | "].firstObject;
            }
            model.name = tagString;
            Tag *tag = [Tag MR_findFirstByAttribute:@"name" withValue:tagString];
            if (tag) {
                model.cname = [tag.cname removeHtmlString];
            }
            else {
                model.cname = tagString;
            }
            model.url = [rightTagElement objectForKey:@"href"];
            //拼接用于在搜索界面显示的关键字
            model.searchKey = [NSString stringWithFormat:@"%@:\"%@\"", leftStr, model.name];
            [rightTagArr addObject:model];
        }
        CGFloat tagViewHeight = [self getTagViewHeightWithLaftStr:leftStr rightArr:rightTagArr isCN:NO];
        CGFloat tagViewHeightCN = [self getTagViewHeightWithLaftStr:leftStr rightArr:rightTagArr isCN:YES];
        [tagArr addObject:@[leftStr,rightTagArr,@(tagViewHeight),@(tagViewHeightCN)]];
    }
    self.tagArr = tagArr;
}

//获取tagView的高度,标签的各个位置
- (CGFloat)getTagViewHeightWithLaftStr:(NSString *)leftStr rightArr:(NSArray *)rightArr isCN:(BOOL)isCN {
    CGFloat leftLabelWidth = [leftStr StringWidthWithFontSize:AppFontContentStyle()] + 20;
    CGFloat buttonViewWidth = UIScreenWidth() - (leftLabelWidth + 40) - 20;
    CGFloat buttonX = leftLabelWidth + 40;
    NSInteger heihtCount = 0;
    for (int i = 0; i < rightArr.count; i++) {
        QJGalleryTagItem *model = rightArr[i];
        CGFloat buttonWidth = [isCN ? model.cname : model.name StringWidthWithFontSize:AppFontContentStyle()] + 20;
        if (buttonWidth > UIScreenWidth() - (leftLabelWidth + 40) - 20) {
            buttonWidth = UIScreenWidth() - (leftLabelWidth + 40) - 30;
        }
        if (buttonWidth > buttonViewWidth) {
            //不能放下
            heihtCount++;
            buttonX = leftLabelWidth + 40;
            buttonViewWidth = UIScreenWidth() - (leftLabelWidth + 40) - 20;
        }
        if (isCN) {
            model.buttonXCN = buttonX;
            model.buttonYCN = heihtCount * 35;
            model.buttonWidthCN = buttonWidth;
        } else {
            model.buttonX = buttonX;
            model.buttonY = heihtCount * 35;
            model.buttonWidth = buttonWidth;
        }
        //剩余宽度
        buttonViewWidth -= buttonWidth + 10;
        buttonX += buttonWidth + 10;
    }
    return (heihtCount + 1) * 35;
}

- (void)parserCommentsWithHpple:(TFHpple *)xpathParser {
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
            //名字
            TFHppleElement *reporter = [oneCommentElement searchWithXPathQuery:@"//div[@class='c3']//a"].firstObject;
            oneCommentDict[@"reporter"] = reporter.text;
            //评分
            TFHppleElement *score = [oneCommentElement searchWithXPathQuery:@"//div[@class='c5 nosel']//span"].firstObject;
            oneCommentDict[@"score"] = score.text != nil ? [NSString stringWithFormat:@"Score %@",score.text] : @"Uploader";
            //评论内容
            TFHppleElement *contentElement = [oneCommentElement searchWithXPathQuery:@"//div[@class='c6']"].firstObject;
            oneCommentDict[@"content"] = contentElement.raw;
            //TODO c8是修改日期,暂时没爬取
            [commentsArr addObject:oneCommentDict];
        }
        self.comments = commentsArr;
    }
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

- (void)parserBaseInfoWithHpple:(TFHpple *)xpathParser {
    NSMutableDictionary *introInfoDict = [NSMutableDictionary new];
    NSArray *otherArr = [xpathParser searchWithXPathQuery:@"//div[@id='gdd']//tr"];
    NSArray *otherKeyArr = @[@"posted",@"parent",@"visible",@"language",@"size",@"length",@"favorited"];
    for (NSInteger i = 0; i < otherArr.count; i++) {
        TFHppleElement *otherElment = otherArr[i];
        TFHppleElement *secondElment = [otherElment searchWithXPathQuery:@"//td [@class='gdt2']"].firstObject;
        //语言特殊处理一下
        NSString *value = secondElment.text;
        if (i == 3) {
            value  = [value substringToIndex:value.length - 2];
        }
        introInfoDict[otherKeyArr[i]] = value;
    }
    introInfoDict[@"posted"] = [self changeTimeToLocalTime:introInfoDict[@"posted"]];
    self.baseInfoDic = introInfoDict;
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

- (void)parserSmallImagesWithHpple:(TFHpple *)xpathParser {
    NSMutableArray *images = [NSMutableArray new];
    NSArray *smallElementArr = [xpathParser searchWithXPathQuery:@"//div[@id='gdt']//a//img"];
    for (TFHppleElement *subElement in smallElementArr) {
        [images addObject:[subElement objectForKey:@"src"]];
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:[subElement objectForKey:@"src"]] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies progress:nil transform:nil completion:nil];
    }
    self.smallImages = images;
    
    NSMutableArray *imageUrls = [NSMutableArray new];
    NSArray *smallUrlsElementArr = [xpathParser searchWithXPathQuery:@"//div[@id='gdt']//a"];
    for (TFHppleElement *imageUrlElement in smallUrlsElementArr) {
        [imageUrls addObject:[imageUrlElement objectForKey:@"href"]];
    }
    self.imageUrls = imageUrls;
    
    self.testUrl = imageUrls.firstObject;
}

#pragma mark -懒加载
- (NSArray *)engMonthArr {
    if (nil == _engMonthArr) {
        _engMonthArr = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    }
    return _engMonthArr;
}

@end
