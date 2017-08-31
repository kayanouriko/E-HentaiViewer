//
//  QJHomeViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJHomeViewController.h"
#import "QJHenTaiParser.h"
#import "QJListCell.h"
#import "QJEnum.h"
#import "QJListTableView.h"
#import "QJTouchIDViewController.h"
#import "NSString+StringHeight.h"
#import "QJHeadFreshingView.h"
//详情页
#import "QJInfoViewController.h"

@interface QJHomeViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,QJHeadFreshingViewDelagate>
//搜索相关
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *otherStates;
@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSDictionary *searchKeyDict;
//列表
@property (nonatomic, strong) QJListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) float oldOffsetY;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) QJFreshStatus status;
//刷新提示文字
@property (nonatomic, strong) QJHeadFreshingView *refreshView;
@property (nonatomic, assign) BOOL canFreshMore;
@property (nonatomic, assign) BOOL isShowThumbImage;//是否呈现启动动画

@end

@implementation QJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initInfo];
    [self setContent];
    //第一次加载
    [self.refreshView beginReFreshing];
    //密码保护
    if ([NSObjForKey(@"ProtectMode") boolValue]) {
        [self showUnlockVC];
    }
}

- (void)showUnlockVC {
    QJTouchIDViewController *vc = [QJTouchIDViewController new];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
    if (self.isShowThumbImage) {
        [self showThumbImageAnimate];
    }
    */
}

- (void)showThumbImageAnimate {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    
    UIView *launchView = viewController.view;
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    launchView.frame = [UIApplication sharedApplication].keyWindow.frame;
    [mainWindow addSubview:launchView];
    
    [UIView animateWithDuration:0.6f delay:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        launchView.alpha = 0.0f;
        launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5f, 1.5f, 1.0f);
    } completion:^(BOOL finished) {
        [launchView removeFromSuperview];
        self.isShowThumbImage = NO;
        if ([NSObjForKey(@"ProtectMode") boolValue]) {
            [self showUnlockVC];
        }
    }];
}

#pragma mark -QJHeadFreshingViewDelagate
- (void)didBeginReFreshingWithFreshingView:(QJHeadFreshingView *)headFreshingView {
    if (self.datas.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    self.canFreshMore = YES;
    self.status = QJFreshStatusRefresh;
    self.pageIndex = 0;
    [self updateResource];
}

#pragma mark -更新数据
- (void)updateResource {
    NSString *url = [self makeUrl];
    [[QJHenTaiParser parser] updateListInfoWithUrl:url complete:^(QJHenTaiParserStatus status, NSArray *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.datas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else if (status == QJHenTaiParserStatusNetworkFail || status == QJHenTaiParserStatusParseFail) {
            self.pageIndex--;
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            self.canFreshMore = NO;
            self.pageIndex--;
        }
        
        self.status = QJFreshStatusNone;
        [self.refreshView endRefreshing];
    }];
}

//首页接收来自网页设置的影响,不再需要手动修改各个搜索选项
- (NSString *)makeUrl {
    NSString *url = @"";
    if (self.pageIndex) {
        url = [NSString stringWithFormat:@"?page=%ld", self.pageIndex];
    }
    /*
    NSMutableString *url = [NSMutableString stringWithFormat:@"?page=%ld&f_sname=on&f_stags=on&f_sdesc=on&f_apply=Apply+Filter", self.pageIndex];
    NSMutableArray *buttonStateArr = [NSMutableArray new];
    if (NSObjForKey(@"SearchBtnState")) {
        [buttonStateArr addObjectsFromArray:NSObjForKey(@"SearchBtnState")];
    }
    else {
        //该循环基本只有第一次运行会用到,故不写在懒加载中,影响性能
        NSMutableArray *arr = [NSMutableArray new];
        for (NSInteger i = 0; i < self.classifyArr.count; i++) {
            [arr addObject:@(1)];
        }
        buttonStateArr = arr;
        NSObjSetForKey(@"SearchBtnState", arr);
        NSObjSynchronize();
    }
    for (NSInteger i = 0; i < buttonStateArr.count; i++) {
        id value = buttonStateArr[i];
        [url appendFormat:@"%@%@",self.searchKeyDict[self.classifyArr[i]],value];
    }
    if ([self.otherStates[1] boolValue] && NSObjForKey(@"SearchSore")) {
        NSInteger index = [NSObjForKey(@"SearchSore") integerValue];
        [url appendFormat:@"&f_sr=on&f_srdd=%ld",index + 2];
    }
    if ([self.otherStates[0] boolValue]) {
        [url appendFormat:@"&f_search=language:chinese+%@",[self.searchBar.text urlEncode]];
    }
    else {
        [url appendFormat:@"&f_search=%@",[self.searchBar.text urlEncode]];
    }
     */
    return url;
}

- (void)refreshUI {
    if (self.status == QJFreshStatusNone) {
        [self.refreshView beginReFreshing];
    }
}

#pragma mark -初始化
- (void)initInfo {
    self.isShowThumbImage = YES;
    self.canFreshMore = YES;
}

#pragma mark -设置内容
- (void)setContent {
    //self.navigationItem.titleView = self.searchBar;
    self.title = [NSObjForKey(@"ExHentaiStatus") boolValue] ? @"ExHentai" : @"EHentai";
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
    vc.preferredContentSize = CGSizeMake(150, 150);
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

#pragma mark -getter
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UISearchBarHeight())];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.showsSearchResultsButton = YES;
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入搜索关键词";
        _searchBar.enablesReturnKeyAutomatically = NO;
    }
    return _searchBar;
}

- (QJListTableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //添加刷新模块
        [_tableView addSubview:self.refreshView];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSMutableArray *)otherStates {
    if (!_otherStates) {
        _otherStates = [NSMutableArray new];
    }
    return _otherStates;
}

- (NSInteger)pageIndex {
    if (!_pageIndex) {
        _pageIndex = 0;
    }
    return _pageIndex;
}

- (NSArray<NSString *> *)classifyArr {
    if (!_classifyArr) {
        _classifyArr = @[@"DOUJINSHI",
                         @"MANGA",
                         @"ARTIST CG",
                         @"GAME CG",
                         @"WESTERN",
                         @"NON-H",
                         @"IMAGE SET",
                         @"COSPLAY",
                         @"ASIAN PORN",
                         @"MISC"];
    }
    return _classifyArr;
}

- (NSDictionary *)searchKeyDict {
    if (nil == _searchKeyDict) {
        _searchKeyDict = @{
                           @"DOUJINSHI":@"&f_doujinshi=",
                           @"MANGA":@"&f_manga=",
                           @"ARTIST CG":@"&f_artistcg=",
                           @"GAME CG":@"&f_gamecg=",
                           @"WESTERN":@"&f_western=",
                           @"NON-H":@"&f_non-h=",
                           @"IMAGE SET":@"&f_imageset=",
                           @"COSPLAY":@"&f_cosplay=",
                           @"ASIAN PORN":@"&f_asianporn=",
                           @"MISC":@"&f_misc="
                           };
    }
    return _searchKeyDict;
}

- (QJHeadFreshingView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[QJHeadFreshingView alloc] initWithFrame:CGRectMake(0, -kRefreshingViewHeight, isPad ? UIScreenWidth() - 120 : UIScreenWidth(), kRefreshingViewHeight)];
        _refreshView.delegate = self;
    }
    return _refreshView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
