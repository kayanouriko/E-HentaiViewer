//
//  DiveExHentaiV2.h
//  e-Hentai
//
//  Created by DaidoujiChen on 2016/11/28.
//  Copyright © 2016年 ChilunChen. All rights reserved.
//  17-03-05 新增删除cookie/获取登录名

#import <Foundation/Foundation.h>

@interface DiveExHentaiV2 : NSObject<NSURLConnectionDataDelegate>

+ (void)replaceCookies;
+ (BOOL)checkCookie;
+ (BOOL)deleteCokie;
+ (void)diveBy:(NSString *)username andPassword:(NSString *)password completion:(void (^)(BOOL isSuccess))completion;

@end
