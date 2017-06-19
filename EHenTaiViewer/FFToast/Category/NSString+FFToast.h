//
//  NSString+FFToast.h
//  FFToastDemo
//
//  Created by 李峰峰 on 2017/2/24.
//  Copyright © 2017年 李峰峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (FFToast)

+ (CGSize)sizeForString:(NSString*)content font:(UIFont*)font maxWidth:(CGFloat) maxWidth;

@end
