//
//  UILabel+LinkUrl.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "UILabel+LinkUrl.h"

@implementation UILabel (LinkUrl)

- (void)setTextWithLinkAttribute:(NSString *)text {
    self.attributedText = [self subStr:text];
}

-(NSMutableAttributedString*)subStr:(NSString *)string
{
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
        
    }
    NSString *subStr=string;
    for (NSString *str in arr) {
        [rangeArr addObject:[self rangesOfString:str inString:subStr]];
    }
    UIFont *font = kNormalFontSize;
    NSMutableAttributedString *attributedText;
    attributedText=[[NSMutableAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName :font}];
    
    for(NSValue *value in rangeArr)
    {
        NSInteger index=[rangeArr indexOfObject:value];
        NSRange range=[value rangeValue];
        [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[arr objectAtIndex:index]] range:range];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
        
    }
    return attributedText;
    
    
}
//获取查找字符串在母串中的NSRange
- (NSValue *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    
    NSRange searchRange = NSMakeRange(0, [str length]);
    
    NSRange range;
    
    if ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return [NSValue valueWithRange:range];
}

@end
