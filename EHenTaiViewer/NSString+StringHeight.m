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
    NSArray *array = @[
                       @[@"[",@"]"],
                       @[@"(",@")"],
                       @[@"【",@"】"],
                       ];
    NSString *newStr = self;
    for (NSArray *subArr in array) {
        newStr = [self startWithStr:subArr.firstObject endStr:subArr.lastObject string:newStr];
    }
    return newStr;
}

- (NSString *)startWithStr:(NSString *)start endStr:(NSString *)end string:(NSString *) string {
    NSMutableString * muStr = [NSMutableString stringWithString:string];
    while (1) {
        NSRange range = [muStr rangeOfString:start];
        NSRange range1 = [muStr rangeOfString:end];
        if (range.location != NSNotFound) {
            NSInteger loc = range.location;
            NSInteger len = range1.location - range.location;
            [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
        }else{
            break;
        }
    }
    return muStr;
}

@end
