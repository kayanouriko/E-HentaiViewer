//
//  QJListTableView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/25.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJListTableView.h"
#import "QJListCell.h"

@implementation QJListTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.rowHeight = UITableViewAutomaticDimension;
        // 解决iOS11上拉请求刷新数据跨越式跳动的问题
        self.estimatedRowHeight = UIScreenHeight();
        self.tableFooterView = [UIView new];
        [self registerNib:[UINib nibWithNibName:NSStringFromClass([QJListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJListCell class])];
    }
    return self;
}

@end
