//
//  NSString+StringHeight.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/26.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "NSString+StringHeight.h"

@implementation NSString (StringHeight)

- (CGFloat)StringHeightWithFontSize:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    return [self boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
}

-  (CGFloat)StringWidthWithFontSize:(UIFont *)font {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
}

- (NSString *)urlEncode {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)self, NULL,
                                                                                 (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

- (NSString *)handleString {
    //感谢seven332
    NSString *prefixRegex = @"^(?:(?:\\([^\\)]*\\))|(?:\\[[^\\]]*\\])|(?:\\{[^\\}]*\\})|(?:~[^~]*~)|\\s+)*";
    NSString *suffixRegex = @"(?:\\s+ch.[\\s\\d-]+)?(?:(?:\\([^\\)]*\\))|(?:\\[[^\\]]*\\])|(?:\\{[^\\}]*\\})|(?:~[^~]*~)|\\s+)*$";
    NSString *newStr = self;
    newStr = [newStr stringByReplacingOccurrencesOfString:[self matchString:newStr toRegexString:prefixRegex].firstObject withString:@""];
    newStr = [newStr stringByReplacingOccurrencesOfString:[self matchString:newStr toRegexString:suffixRegex].firstObject withString:@""];
    //标题内还可能包含"|"
    if ([newStr containsString:@"|"]) {
        NSRange range = [newStr rangeOfString:@"|"];
        newStr = [newStr substringWithRange:NSMakeRange(0, range.location)];
    }
    return newStr;
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

- (NSString *)removeHtmlString {
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n" options:0 error:nil];
    NSString *string = [regularExpretion stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:@""];
    return string;
}

@end
