//
//  QJAllCommentController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJAllCommentController.h"
#import "QJCommentCell.h"

@interface QJAllCommentController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign, getter=isNeedChangeRow) BOOL needChangeRow;

@end

@implementation QJAllCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.title = @"全部评论";
    self.needChangeRow = YES;
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //自动布局完成之前frame还没确定,scrollToRowAtIndexPath方法不生效,必须放在这个方法里面执行
    if (self.isNeedChangeRow && self.index > 0) {
        self.needChangeRow = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJCommentCell class])];
    [cell refreshUI:self.allComments[indexPath.row]];
    return cell;
}

#pragma mark -getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJCommentCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJCommentCell class])];
    }
    return _tableView;
}

@end
