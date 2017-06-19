//
//  QJOtherListController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJOtherListController.h"
#import "QJListTableView.h"
#import "QJListCell.h"
#import "QJHenTaiParser.h"
#import "NSString+StringHeight.h"
#import "QJInfoViewController.h"
#import "QJHeadFreshingView.h"
#import "QJEnum.h"

@interface QJOtherListController ()<UITableViewDelegate,UITableViewDataSource,QJHeadFreshingViewDelagate>

@property (nonatomic, strong) QJListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) QJHeadFreshingView *freshingView;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL canFreshMore;

@end

@implementation QJOtherListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    [self.freshingView beginReFreshing];
}

- (void)setContent {
    self.pageIndex = 0;
    self.canFreshMore = YES;
    if (!self.titleName) {
        self.titleName = self.key;
    }
    self.title = self.titleName;
    self.view.backgroundColor = [UIColor whiteColor];
    /*
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickShare)];
    self.navigationItem.rightBarButtonItem = item;
    */
    [self.view addSubview:self.tableView];
}

- (void)clickShare {
    
}

#pragma mark -QJHeadFreshingViewDelagate
- (void)beginRefreshing {
    self.canFreshMore = YES;
    self.status = QJFreshStatusRefresh;
    self.pageIndex = 0;
    [self updateResource];
}

- (void)updateResource {
    NSString *url = @"";
    if (self.type == QJOtherListControllerTypeTag) {
        url = self.key;
    }
    else if (self.type == QJOtherListControllerTypePerson) {
        url = [NSString stringWithFormat:@"uploader/%@",[self.key urlEncode]];
    }
    else if (self.type == QJOtherListControllerTypeCatgoery) {
        url = [self.key urlEncode];
    }
    if (self.pageIndex) {
        if ([url containsString:@"Apply+Filter"]) {
            //特殊的
            url = [url stringByAppendingFormat:@"&page=%ld",(long)self.pageIndex];
        }
        else {
            url = [url stringByAppendingFormat:@"/%ld",(long)self.pageIndex];
        }
    }
    [[QJHenTaiParser parser] updateOtherListInfoWithUrl:url complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.datas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            self.canFreshMore = NO;
            self.pageIndex--;
        }
        self.status = QJFreshStatusNone;
        [self.freshingView endRefreshing];
    }];
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJInfoViewController *vc = [QJInfoViewController new];
    vc.item = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //预加载
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = 25 * 0.7 + self.pageIndex * 25;
    CGFloat totalItem = 25 * (self.pageIndex + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (self.datas.count && ratio >= newThreshold && self.status == QJFreshStatusNone && self.canFreshMore) {
        self.status = QJFreshStatusMore;
        self.pageIndex++;
        NSLog(@"Request page %ld from server.",self.pageIndex);
        [self updateResource];
    }
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView addSubview:self.freshingView];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (QJHeadFreshingView *)freshingView {
    if (!_freshingView) {
        _freshingView = [QJHeadFreshingView new];
        _freshingView.delegate = self;
    }
    return _freshingView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
