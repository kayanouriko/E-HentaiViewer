//
//  QJListItem.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJListItem.h"

@implementation QJListItem

- (instancetype)initWithDict:(NSDictionary *)dict classifyArr:(NSArray<NSString *> *)classifyArr colorArr:(NSArray<UIColor *> *)colorArr {
    self = [super init];
    if (self) {
        self.title = isnull(@"title", dict);
        self.title_jpn = isnull(@"title_jpn", dict);
        self.rating = [isnull(@"rating", dict) floatValue];
        self.category = [self getCategoryNameAndColor:isnull(@"category", dict) classifyArr:classifyArr colorArr:colorArr];
        self.thumb = isnull(@"thumb", dict);
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:self.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies progress:nil transform:nil completion:nil];
        self.uploader = isnull(@"uploader", dict);
        self.expunged = [isnull(@"expunged", dict) boolValue];
        self.tags = dict[@"tags"];
        self.torrentcount = [isnull(@"torrentcount", dict) integerValue];
        self.filecount = [isnull(@"filecount", dict) integerValue];
        self.posted = [self transTime:isnull(@"posted", dict)];
        CGFloat filesize = [isnull(@"filesize", dict) floatValue];
        self.filesize = [self transformedValue:filesize];
        self.language = [self getLanguageWithTitle:self.title];
        self.gid = isnull(@"gid", dict);
        self.token = isnull(@"token", dict);
        self.page = 0;
    }
    return self;
}

//精简分类和颜色背景
- (NSString *)getCategoryNameAndColor:(NSString *)category classifyArr:(NSArray<NSString *> *)classifyArr colorArr:(NSArray<UIColor *> *)colorArr{
    NSString *upperCategory = [category uppercaseString];
    for (NSString *realCategory in classifyArr) {
        if ([upperCategory containsString:realCategory]) {
            upperCategory = realCategory;
            break;
        }
    }
    self.categoryColor = colorArr[[classifyArr indexOfObject:upperCategory]];
    return upperCategory;
}

//筛选出语言
- (NSString *)getLanguageWithTitle:(NSString *)title {
    NSString *language = @"";
    NSArray *languageArr = @[
                             @[@"[(\\[]eng(?:lish)?[)\\]]",@"EN"],
                             @[@"[(（\\[]ch(?:inese)?[)）\\]]|[汉漢]化|中[国國][语語]|中文",@"ZH"],
                             @[@"[(\\[]spanish[)\\]]|[(\\[]Español[)\\]]",@"ES"],
                             @[@"[(\\[]korean?[)\\]]",@"KO"],
                             @[@"[(\\[]rus(?:sian)?[)\\]]",@"RU"],
                             @[@"[(\\[]fr(?:ench)?[)\\]]",@"FR"],
                             @[@"[(\\[]portuguese",@"PT"],
                             @[@"[(\\[]thai(?: ภาษาไทย)?[)\\]]|แปลไทย",@"TH"],
                             @[@"[(\\[]german[)\\]]",@"DE"],
                             @[@"[(\\[]italiano?[)\\]]",@"IT"],
                             @[@"[(\\[]vietnamese(?: Tiếng Việt)?[)\\]]",@"VN"],
                             @[@"[(\\[]polish[)\\]]",@"PL"],
                             @[@"[(\\[]hun(?:garian)?[)\\]]",@"HU"],
                             @[@"[(\\[]dutch[)\\]]",@"NL"],
                             ];
    for (NSArray *subArr in languageArr) {
        NSRange range = [title rangeOfString:subArr.firstObject options:NSCaseInsensitiveSearch|NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            language = subArr[1];
            break;
        }
    }
    return language;
}

//转换文件大小
- (NSString *)transformedValue:(CGFloat)value {
    double convertedValue = value;
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

//转换时间
- (NSString *)transTime:(NSString *)timeStr {
    NSTimeInterval createTime = [timeStr integerValue];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]];
    
    // 获取当前时时间戳 1466386762.345715 十位整数 6位小数
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 时间差
    NSTimeInterval time = currentTime - createTime;
    
    if (time < 61) {
        return @"刚刚";
    }
    //秒转分钟
    NSInteger minute = time / 60;
    if (minute < 61) {
        return [NSString stringWithFormat:@"%ld分钟前",minute];
    }
    //秒转小时
    NSInteger hours = time/3600;
    if (hours < 25) {
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 32) {
        dateFormatter.dateFormat = @"HH:mm";
        return [NSString stringWithFormat:@"%ld天前 %@",days ,[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]]];
    }
    //秒转月
    NSInteger months = time/3600/24/30;
    if (months < 13) {
        dateFormatter.dateFormat = @"MM-dd HH:mm";
        return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]];
    }
    //年
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]];
}

@end
