//
//  UIImage+FFToast.m
//  FFToastDemo
//
//  Created by 李峰峰 on 2017/2/24.
//  Copyright © 2017年 李峰峰. All rights reserved.
//

#import "UIImage+FFToast.h"

@implementation UIImage (FFToast)

+ (UIImage*)imageWithName:(NSString*)name{
    NSBundle * pbundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleURL = [pbundle pathForResource:@"FFToast" ofType:@"bundle"];
    NSBundle *imagesBundle = [NSBundle bundleWithPath:bundleURL];
    UIImage * image = [UIImage imageNamed:name inBundle:imagesBundle compatibleWithTraitCollection:nil];
    return image;
}

@end
