//
//  NSString+StringHeight.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/26.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "NSString+StringHeight.h"
#import <CommonCrypto/CommonCrypto.h>

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

-(NSString *)MD5 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSAttributedString *)convertStringsWithArray:(NSArray<NSString *> *)array {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    for (NSArray *subArr in array) {
        NSString *tag = subArr[0];
        NSString *titleColor = subArr[1];
        NSString *bgColor = subArr[2];
        UILabel *tagLabel = [UILabel new];
        CGFloat aaW = [tag StringWidthWithFontSize:[UIFont systemFontOfSize:10.f]] + 6;
        tagLabel.frame = CGRectMake(0, 0, aaW * 3, 16 * 3);
        tagLabel.text = tag;
        tagLabel.font = [UIFont boldSystemFontOfSize:10.f * 3];
        tagLabel.textColor = UIColorHex(titleColor);
        tagLabel.backgroundColor = UIColorHex(bgColor);
        tagLabel.clipsToBounds = YES;
        tagLabel.layer.cornerRadius = 3 * 3;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        //调用方法，转化成Image
        UIImage *image = [self p_imageWithUIView:tagLabel];
        //创建Image的富文本格式
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.bounds = CGRectMake(0, -2.5, aaW, 16); //这个-2.5是为了调整下标签跟文字的位置
        attach.image = image;
        //添加到富文本对象里
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attach];
        [string appendAttributedString:imageStr];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    // 设置行间距
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 4;
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    
    return string;
}

+ (UIImage *)p_imageWithUIView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

- (NSString *)digitalHTMLToUnicode {
    NSString *text = self;
    //匹配HTML格式转义字符正则
    NSString *prefix = @"[^&#]*\\;";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:prefix options:NSRegularExpressionCaseInsensitive error:nil];
    // 对text字符串进行匹配
    NSArray *matches = [regular matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    // 遍历匹配后的每一条记录
    NSString *result = text;
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *target = [text substringWithRange:range];
        //把HTML格式的表情转换为Unicode格式的
        NSString *emojiS = [target p_emojiHTMLToUnicode];
        //iOS 端直接支持unicode字符 (有一些高级表情会失败，返回nil)
        NSString *convertUnicode = [emojiS p_convertSimpleUnicodeStr];
        if (convertUnicode.length ==0) {
            convertUnicode = @" ";
        }
        //把表情替换回原来的位置，然后就能直接用UILabel显示表情了
        result = [result stringByReplacingOccurrencesOfString:[@"&#" stringByAppendingString:target] withString:convertUnicode];
    }
    return result;
}

- (NSString *)p_emojiHTMLToUnicode {
    NSString *result = [self stringByReplacingOccurrencesOfString:@"&#" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@";" withString:@""];
    NSString *hexString = [NSString stringWithFormat:@"U+%@",[[NSString alloc] initWithFormat:@"%1X",[result intValue]]];
    return hexString;
}

- (NSString *)p_convertSimpleUnicodeStr {
    NSString *strUrl = [self stringByReplacingOccurrencesOfString:@"U+" withString:@""];
    unsigned long  unicodeIntValue= strtoul([strUrl UTF8String],0,16);
    //   UTF32Char inputChar = unicodeIntValue ;// 变成utf32
    unsigned long inputChar = unicodeIntValue ;// 变成utf32
    //    inputChar = NSSwapHostIntToLittle(inputChar); // 转换成Little 如果需要
    inputChar = NSSwapHostLongToLittle(inputChar); // 转换成Little 如果需要
    NSString *sendStr = [[NSString alloc] initWithBytes:&inputChar length:4 encoding:NSUTF32LittleEndianStringEncoding];
    return sendStr;
}

@end
