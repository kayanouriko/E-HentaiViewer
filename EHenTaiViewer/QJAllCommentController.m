//
//  QJAllCommentController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJAllCommentController.h"
#import "QJCommentCell.h"
#import <SafariServices/SafariServices.h>
#import "QJPasteManager.h"
#import "QJNewSearchViewController.h"

@interface QJAllCommentController ()<UITableViewDelegate, UITableViewDataSource, QJCommentCellDelegate>

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
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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
    cell.delegate = self;
    [cell refreshUI:self.allComments[indexPath.row]];
    return cell;
}

#pragma mark - QJCommentCellDelegate
- (void)commentCell:(QJCommentCell *)cell didClickUserImageWithUserName:(NSString *)userName {
    QJNewSearchViewController *vc = [QJNewSearchViewController new];
    vc.title = [NSString stringWithFormat:@"uploader:\"%@\"", userName];
    vc.type = QJNewSearchViewControllerTypeTag;
    vc.searchKey = @"";
    [vc.settings addObject:[NSString stringWithFormat:@"uploader-%@", userName]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)commentCell:(QJCommentCell *)cell didClickContentUrlWithURL:(NSURL *)URL {
    if (![[QJPasteManager sharedInstance] checkInfoWithUrl:URL.absoluteString]) {
        // 这里直接跳转内置浏览器
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:safariVC animated:YES completion:nil];
    }
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
