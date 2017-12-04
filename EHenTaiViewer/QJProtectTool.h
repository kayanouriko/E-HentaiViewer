//
//  QJProtectTool.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/25.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

//感谢maltsugar,终于明白了系统密码调用的方法

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QJProtectToolStatus) {
    QJProtectToolStatusSuccess,//成功
    QJProtectToolStatusCannel,//用户点击了退出
};

typedef void(^CompletBlock)(QJProtectToolStatus status);

@interface QJProtectTool : NSObject

+ (QJProtectTool *)shareTool;

- (BOOL)isEnableTouchID;
- (void)showTouchID:(CompletBlock)completion;

@end
