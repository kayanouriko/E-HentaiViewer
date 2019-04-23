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

@end
