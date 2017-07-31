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

@interface QJSearchViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UISearchController *searchVC;
@property (nonatomic, strong) UITableView *listTableView;//列表搜索
@property (nonatomic, strong) NSMutableArray<Tag *> *searchDatas;

@end

@implementation QJSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.navigationItem.titleView = self.searchVC.searchBar;
    [self.view addSubview:self.listTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchVCHidden) name:SEARCHHIDDEN_NOTI object:nil];
}

- (void)searchVCHidden {
    self.searchVC.active = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchVC.active = NO;
}

#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return self.searchDatas.count;
    } else {
        return 10;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchVC.active) {
        if (self.searchDatas.count) {
            return @"相关标签";
        } else {
            return @"";
        }
    }
    else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchVC.active) {
        if (self.searchDatas.count) {
            return 35.f;
        }
        else {
            return 0.1f;
        }
    }
    else {
        return 0.1f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchVC.active) {
        QJSearchTagCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSearchTagCell class])];
        [cell refreshUI:self.searchDatas[indexPath.row] searchKey:self.searchVC.searchBar.text];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
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
        _listTableView.rowHeight = UITableViewAutomaticDimension;
        _listTableView.estimatedRowHeight = 60;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.tableFooterView = [UIView new];
        _listTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_listTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchTagCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSearchTagCell class])];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
