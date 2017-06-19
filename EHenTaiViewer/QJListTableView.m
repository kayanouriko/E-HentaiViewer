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
        self.frame = CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight());
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        self.backgroundColor = [UIColor clearColor];
        self.rowHeight = UITableViewAutomaticDimension;
        self.estimatedRowHeight = 5 * 42;
        self.tableFooterView = [UIView new];
        [self registerNib:[UINib nibWithNibName:NSStringFromClass([QJListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJListCell class])];
    }
    return self;
}

@end
