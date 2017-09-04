//
//  QJSearchViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchViewController.h"
#import "Tag+CoreDataClass.h"
#import "QJSearchTagCell.h"
#import "QJOtherListController.h"
#import "QJSearchClassifyCell.h"
#import "QJSearchSoreCell.h"
#import "QJHenTaiParser.h"
#import "QJSearchGalleryCell.h"
#import "QJInfoViewController.h"
#import "QJSearchUploaderCell.h"
#import "QJSearchHeadView.h"
#import "NSString+StringHeight.h"

@interface QJSearchViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource ,QJSearchGalleryCellDelagate,QJSearchHeadViewDelagate>

@property (nonatomic, strong) UISearchController *searchVC;
@property (nonatomic, strong) UITableView *listTableView;//列表搜索
@property (nonatomic, strong) NSMutableArray<Tag *> *searchDatas;
@property (nonatomic, strong) NSMutableArray<QJListItem *> *topGallerys;//昨天最流行画廊
@property (nonatomic, strong) NSMutableArray<QJToplistUploaderItem *> *upladers;//昨天最流行上传主

//搜索设置相关
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSArray *headTitles;
@property (nonatomic, strong) NSMutableArray *otherInfos;

@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSDictionary *searchKeyDict;

@end

@implementation QJSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    [self updateResource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = self.searchVC.active;
}

- (void)setContent {
    self.navigationItem.titleView = self.searchVC.searchBar;
    [self.view addSubview:self.listTableView];
    [self.view addSubview:self.searchTableView];
}

- (void)updateResource {
    [[QJHenTaiParser parser] updateToplistInfoComplete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray, NSArray<QJToplistUploaderItem *> *uploaderArrary) {
        if (status == QJHenTaiParserStatusSuccess) {
            [self.topGallerys addObjectsFromArray:listArray];
            [self.upladers addObjectsFromArray:uploaderArrary];
            [self.listTableView reloadData];
        }
    }];
}

#pragma mark -UISearchBarDelegate
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar.searchResultsButtonSelected) {
        [self searchListHidden];
    }
    else {
        [self searchListShow];
    }
}

- (void)searchListShow {
    [UIView animateWithDuration:0.25f animations:^{
        self.searchTableView.frame = CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight());
    }];
    self.searchVC.searchBar.searchResultsButtonSelected = YES;
}

- (void)searchListHidden {
    [UIView animateWithDuration:0.25f animations:^{
        self.searchTableView.frame = CGRectMake(0, 0, UIScreenWidth(), 0);
    }];
    QJSearchClassifyCell *cell = (QJSearchClassifyCell *)[self.view viewWithTag:100];
    [cell saveButtonState];
    self.searchVC.searchBar.searchResultsButtonSelected = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self searchListHidden];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *url = [self makeUrl];
    QJOtherListController *vc = [QJOtherListController new];
    vc.titleName = self.searchVC.searchBar.text;
    vc.key = url;
    vc.type = QJOtherListControllerTypeTag;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)makeUrl {
    NSMutableString *url = [NSMutableString stringWithString:@"?f_sname=on&f_stags=on&f_sdesc=on&f_apply=Apply+Filter"];
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
    [url appendFormat:@"&f_search=%@",[self.searchVC.searchBar.text urlEncode]];
    return url;
}

#pragma mark -QJSearchGalleryCellDelagate
- (void)didClickOneTopGalleryWithItem:(QJListItem *)item {
    QJInfoViewController *vc = [QJInfoViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    vc.item = item;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.listTableView && !self.searchVC.active) {
        if (self.topGallerys.count) {
            //历史搜索,收藏,昨天流行画廊,上传者
            //暂时不做历史搜索和收藏
            return 2;
        }
        else {
            //TODO:历史搜索,收藏
            return 0;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.listTableView) {
        if (self.searchVC.active) {
            return self.searchDatas.count;
        } else {
            return 1;
            /*
            //画廊,上传者为1
            if (section == 2 || section == 3) {
                return 1;
            }
            else {
                return 2;
            }
             */
        }
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.listTableView) {
        if (self.searchVC.active) {
            return @"";
        }
        else {
            if (section) {
                return @"活跃上传者";
            }
            else {
                return @"昨日流行画廊";
            }
            /*
            if (section == 1) {
                return @"收藏";
            }
            else if (section == 2) {
                return @"昨日流行画廊";
            }
            else if (section == 3) {
                return @"活跃上传者";
            }
            else {
                return @"历史搜索";
            }
             */
        }
    } else {
        return @"分类排除";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.listTableView && self.searchVC.active) {
        return 0.1f;
    }
    else {
        return 35.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.listTableView) {
        if (self.searchVC.active) {
            QJSearchTagCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSearchTagCell class])];
            [cell refreshUI:self.searchDatas[indexPath.row] searchKey:self.searchVC.searchBar.text];
            return cell;
        }
        else {
            if (indexPath.section == 0) {
                QJSearchGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSearchGalleryCell class])];
                cell.delegate = self;
                [cell refrshUI:self.topGallerys];
                return cell;
            }
            else if (indexPath.section == 1) {
                QJSearchUploaderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSearchUploaderCell class])];
                [cell refrshUI:self.upladers];
                return cell;
            }
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
            return cell;
        }
    } else {
        QJSearchClassifyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSearchClassifyCell class])];
        cell.tag = 100;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchVC.active) {
        /*
        [self.searchVC.searchBar resignFirstResponder];
        self.searchVC.searchBar.text = @"";
        [self.searchVC dismissViewControllerAnimated:YES completion:nil];
         */
        //标签搜索
        Tag *tag = (Tag *)self.searchDatas[indexPath.row];
        QJOtherListController *vc = [QJOtherListController new];
        vc.key = tag.name;
        vc.type = QJOtherListControllerTypeTagIncomplete;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        
    }
}

#pragma mark -UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchKey = searchController.searchBar.text;
    if (self.searchVC.active) {
        //先隐藏
        self.listTableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, 0, 0);
        self.tabBarController.tabBar.hidden = YES;
        
        [self.searchDatas removeAllObjects];
        if (searchKey.length) {
            //搜索
            NSString *regex = [NSString stringWithFormat:@".*%@.*",searchKey];
            NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"name MATCHES %@ OR cname MATCHES %@", regex, regex];
            NSArray *searchReslut = [Tag MR_findAllWithPredicate:peopleFilter];
            [self.searchDatas addObjectsFromArray:searchReslut];
        }
        [self.listTableView reloadData];
    }
    else {
        self.listTableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        self.tabBarController.tabBar.hidden = NO;
        [self.listTableView reloadData];
    }
}

#pragma mark -getter
- (UISearchController *)searchVC {
    if (nil == _searchVC) {
        _searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchVC.searchResultsUpdater = self;
        _searchVC.dimsBackgroundDuringPresentation = NO;
        _searchVC.hidesNavigationBarDuringPresentation = NO;
        //searchBar的一些设置
        _searchVC.searchBar.delegate = self;
        _searchVC.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchVC.searchBar.showsSearchResultsButton = YES;
        _searchVC.searchBar.delegate = self;
        _searchVC.searchBar.placeholder = @"请输入搜索关键词";
        _searchVC.searchBar.enablesReturnKeyAutomatically = NO;
    }
    return _searchVC;
}

- (UITableView *)listTableView {
    if (nil == _listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight()) style:UITableViewStyleGrouped];
        _listTableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        _listTableView.backgroundColor = [UIColor whiteColor];
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.rowHeight = UITableViewAutomaticDimension;
        _listTableView.estimatedRowHeight = 60;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.tableFooterView = [UIView new];
        _listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_listTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchTagCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchTagCell class])];
        [_listTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchGalleryCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchGalleryCell class])];
        [_listTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchUploaderCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchUploaderCell class])];
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _listTableView;
}

- (NSMutableArray<Tag *> *)searchDatas {
    if (nil == _searchDatas) {
        _searchDatas = [NSMutableArray new];
    }
    return _searchDatas;
}

- (UITableView *)searchTableView {
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), 0) style:UITableViewStyleGrouped];
        _searchTableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.rowHeight = UITableViewAutomaticDimension;
        _searchTableView.estimatedRowHeight = 5 * 42;
        _searchTableView.tableFooterView = [UIView new];
        [_searchTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchClassifyCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchClassifyCell class])];
        [_searchTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchSoreCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchSoreCell class])];
        [_searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _searchTableView;
}

- (NSArray *)headTitles {
    if (!_headTitles) {
        _headTitles = @[@"分类搜索项",@"其他搜索项"];
    }
    return _headTitles;
}

- (NSMutableArray *)otherInfos {
    if (!_otherInfos) {
        NSArray *array = @[@"只搜中文",@"设置最低评分"];
        _otherInfos = [NSMutableArray new];
        [_otherInfos addObjectsFromArray:array];
    }
    return _otherInfos;
}

- (NSMutableArray<QJListItem *> *)topGallerys {
    if (nil == _topGallerys) {
        _topGallerys = [NSMutableArray new];
    }
    return _topGallerys;
}

- (NSMutableArray<QJToplistUploaderItem *> *)upladers {
    if (nil == _upladers) {
        _upladers = [NSMutableArray new];
    }
    return _upladers;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
