//
//  QJMangaBrowerManager.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/7.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^missionComplete)(NSArray *datas);

@interface QJMangaBrowerManager : NSObject

/*
 单例类
 */
+ (QJMangaBrowerManager *)shareManager;

/*
 开始一个画廊的任务
 */
- (void)startMissionWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count complete:(missionComplete)complete;
/*
 结束一个画廊的任务,进行一些清理工作
 */
- (void)endMission;

@end
