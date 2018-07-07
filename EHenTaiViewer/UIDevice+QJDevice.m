//
//  UIDevice+QJDevice.m
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/6/26.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "UIDevice+QJDevice.h"

@implementation UIDevice (QJDevice)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

@end
