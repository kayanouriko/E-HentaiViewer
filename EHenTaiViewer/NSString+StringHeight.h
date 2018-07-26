//
//  NSString+StringHeight.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/26.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringHeight)

//获取高度
- (CGFloat)StringHeightWithFontSize:(UIFont *)font maxWidth:(CGFloat)maxWidth;
//获取宽度
- (CGFloat)StringWidthWithFontSize:(UIFont *)font;
//编码
- (NSString *)urlEncode;
//截取字符串,去除[]()【】等内容
- (NSString *)handleString;
//去除html标签
- (NSString *)removeHtmlString;
// 文本md5
-(NSString *)MD5;

@end
