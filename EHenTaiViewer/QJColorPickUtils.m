//
//  QJColorPickUtils.m
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJColorPickUtils.h"

@implementation QJColorPickUtils

+ (NSString *)hexStringWithColor:(UIColor *)color hasAlpha:(BOOL)hasAlpha {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;
    if (hasAlpha) {
        rgb = (int)(a * 255.0f)<<24 | (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;
    }
    return [[NSString stringWithFormat:@"%06x", rgb] uppercaseString];
}

+ (UIColor *)changeColorAlpha:(UIColor *)color alpha:(CGFloat)alpha {
    const CGFloat *component = CGColorGetComponents(color.CGColor);
    return [UIColor colorWithRed:component[0] green:component[1] blue:component[2] alpha:alpha];
}

+ (UIColor *)getColorWithPoint:(CGPoint)point layer:(CALayer *)layer {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIColor colorWithRed:pixel[0] / 255.f green:pixel[1] / 255.f blue:pixel[2] / 255.f alpha:pixel[3] / 255.f];
}

@end
