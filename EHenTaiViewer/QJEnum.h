//
//  QJEnum.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/22.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#ifndef QJEnum_h
#define QJEnum_h

typedef NS_ENUM(NSInteger, QJFreshStatus) {
    QJFreshStatusNone,//没有加载
    QJFreshStatusRefresh,//重新刷新
    QJFreshStatusMore,//加载更多
    QJFreshStatusFreshing,//正在加载中
    QJFreshStatusNotMore,//没有更多
};

#endif
