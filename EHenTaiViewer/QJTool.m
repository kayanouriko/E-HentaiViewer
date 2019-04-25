//
//  QJTool.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/17.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJTool.h"

@implementation QJTool

+ (BOOL)isiPhoneXAfter {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInset = [UIApplication sharedApplication].windows[0].safeAreaInsets;
        if (UIEdgeInsetsEqualToEdgeInsets(edgeInset, UIEdgeInsetsZero) || UIEdgeInsetsEqualToEdgeInsets(edgeInset, UIEdgeInsetsMake(20, 0, 0, 0))) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

+ (UIColor *)colorWithHexString:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"]) {
        cString = [cString substringFromIndex:2];
    }
    else if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    // 直接返回透明颜色
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
