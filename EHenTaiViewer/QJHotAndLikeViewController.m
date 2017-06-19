//
//  QJHotAndLikeViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/17.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJHotAndLikeViewController.h"
#import "QJListCell.h"
#import "QJHenTaiParser.h"
#import "QJListTableView.h"
#import "QJInfoViewController.h"
#import "QJHeadFreshingView.h"
#import "QJEnum.h"

#import "QJLoginViewController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate,UITableViewDataSource,QJHeadFreshingViewDelagate>

@property (nonatomic, strong) UISegmentedControl *segControl;
@property (nonatomic, strong) QJListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *hotDatas;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) QJHeadFreshingView *refreshingView;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self.refreshingView beginReFreshing];
}

#pragma mark -QJHeadFreshingViewDelagate
- (void)beginRefreshing {
    [self scrollToTop];
    self.status = QJFreshStatusRefresh;
    self.segControl.userInteractionEnabled = NO;
    self.canFreshMore = YES;
    if (self.segControl.selectedSegmentIndex == 0) {
        [self updateHotResource];
    }
    else if (self.segControl.selectedSegmentIndex == 1) {
        self.pageIndex = 0;
        [self updateLikeResource];
    }
}

- (void)updateHotResource {
    [[QJHenTaiParser parser] updateHotListInfoComplete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.hotDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.hotDatas addObjectsFromArray:listArray];
            self.datas = self.hotDatas;
            if (self.segControl.selectedSegmentIndex == 0) {
                [self changeSonmethingWhenDataGet];
            }
        }
        [self changeSomethingAnyTime];
    }];
}

- (void)updateLikeResource {
    [[QJHenTaiParser parser] updateLikeListInfoWithUrl:[self getLikeUrl] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.likeDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.likeDatas addObjectsFromArray:listArray];
            self.datas = self.likeDatas;
            if (self.segControl.selectedSegmentIndex == 1) {
                [self changeSonmethingWhenDataGet];
            }
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            self.canFreshMore = NO;
            self.pageIndex--;
        }
        [self changeSomethingAnyTime];
    }];
}

- (void)changeSonmethingWhenDataGet {
    [self.tableView reloadData];
}

- (void)changeSomethingAnyTime {
    self.segControl.userInteractionEnabled = YES;
    self.status = QJFreshStatusNone;
    [self.refreshingView endRefreshing];
}

- (NSString *)getLikeUrl {
    if (self.pageIndex == 0) {
        return @"favorites.php";
    }
    return [NSString stringWithFormat:@"favorites.php?page=%ld",self.pageIndex];
}

- (void)setContent {
    self.canFreshMore = YES;
    self.pageIndex = 0;
    self.navigationItem.titleView = self.segControl;
    [self.view addSubview:self.tableView];
}

#pragma mark -tableview
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
    vc.hidesBottomBarWhenPushed = YES;
    vc.item = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.segControl.selectedSegmentIndex == 0) {
        return;
    }
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
        [self updateLikeResource];
    }
}

#pragma mark -seg点击事件
- (void)segControlValueChange:(UISegmentedControl *)segControl {
    if (segControl.selectedSegmentIndex) {
        self.datas = @[];
        [self.tableView reloadData];
        if (![[QJHenTaiParser parser] checkCookie]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"未登录" message:@"是否前往登陆?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelBtn];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                QJLoginViewController *vc = [QJLoginViewController new];
                [self presentViewController:vc animated:YES completion:nil];
            }];
            [alertVC addAction:okBtn];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        }
        if (self.likeDatas.count) {
            self.datas = self.likeDatas;
            [self.tableView reloadData];
            [self scrollToTop];
        }
        else {
            self.datas = @[];
            [self.tableView reloadData];
            [self.refreshingView beginReFreshing];
        }
    } else {
        if (self.hotDatas.count) {
            self.datas = self.hotDatas;
            [self.tableView reloadData];
            [self scrollToTop];
        } else {
            self.datas = @[];
            [self.tableView reloadData];
            [self.refreshingView beginReFreshing];
        }
    }
}

- (void)scrollToTop {
    if (self.datas.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

#pragma mark -懒加载
- (UISegmentedControl *)segControl {
    if (!_segControl) {
        _segControl = [[UISegmentedControl alloc] initWithItems:@[@"热门",@"收藏"]];
        _segControl.frame = CGRectMake(0, 0, 180, 30);
        _segControl.selectedSegmentIndex = 0;
        [_segControl addTarget:self action:@selector(segControlValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
}

- (QJListTableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView addSubview:self.refreshingView];
    }
    return _tableView;
}

- (NSMutableArray *)hotDatas {
    if (!_hotDatas) {
        _hotDatas = [NSMutableArray new];
    }
    return _hotDatas;
}

- (NSMutableArray *)likeDatas {
    if (!_likeDatas) {
        _likeDatas = [NSMutableArray new];
    }
    return _likeDatas;
}

- (NSArray *)datas {
    if (!_datas) {
        _datas = [NSArray new];
    }
    return _datas;
}

- (NSInteger)pageIndex {
    if (!_pageIndex) {
        _pageIndex = 0;
    }
    return _pageIndex;
}

- (QJHeadFreshingView *)refreshingView {
    if (!_refreshingView) {
        _refreshingView = [QJHeadFreshingView new];
        _refreshingView.delegate = self;
    }
    return _refreshingView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
