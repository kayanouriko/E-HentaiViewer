//
//  NSString+FFToast.m
//  FFToastDemo
//
//  Created by 李峰峰 on 2017/2/24.
//  Copyright © 2017年 李峰峰. All rights reserved.
//

#import "NSString+FFToast.h"

@implementation NSString (FFToast)

+ (CGSize)sizeForString:(NSString*)content font:(UIFont*)font maxWidth:(CGFloat) maxWidth{
    if (!content || content.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    
    CGSize contentSize = [content boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                     NSFontAttributeName : font}
                                           context:nil].size;
    
    return contentSize;
}

@end
