//
//  QJTorrentInfoController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/9.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTorrentInfoController.h"
#import "QJTorrentInfoCell.h"
#import "QJHenTaiParser.h"
#import "QJTorrentItem.h"

@interface QJTorrentInfoController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation QJTorrentInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self updateResource];
}

- (void)setContent {
    self.title = @"种子列表";
    
    [self.view addSubview:self.tableView];
}

- (void)updateResource {
    [[QJHenTaiParser parser] updateTorrentInfoWithGid:self.gid token:self.token complete:^(QJHenTaiParserStatus status, NSArray<QJTorrentItem *> *torrents) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.datas = torrents;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJTorrentInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJTorrentInfoCell class])];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJTorrentItem *item = self.datas[indexPath.row];
    NSString *magnet = item.magnet;
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:magnet];
    ToastSuccess(nil, @"磁力链接复制成功!");
}

#pragma mark -getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.frame = CGRectMake(isPad ? 60 : 0, 0,isPad ? UIScreenWidth() - 120 : UIScreenWidth(), UIScreenHeight());
        _tableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, -10, 0);
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 10;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJTorrentInfoCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJTorrentInfoCell class])];
    }
    return _tableView;
}

- (NSArray *)datas {
    if (!_datas) {
        _datas = [NSArray new];
    }
    return _datas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
