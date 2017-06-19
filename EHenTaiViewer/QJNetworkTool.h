//
//  QJNetworkTool.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJNetworkTool : NSObject

+ (QJNetworkTool *)shareTool;
/*
 *  监听网络变化
 */
- (void)starNotifier;

- (BOOL)isEnableNetwork;//判断是否有网
- (BOOL)isEnableMobleNetwork;//判断是否为移动数据

@end
