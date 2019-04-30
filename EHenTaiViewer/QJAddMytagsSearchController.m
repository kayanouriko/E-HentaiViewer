//
//  QJAddMytagsSearchController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJAddMytagsSearchController.h"
#import "QJHenTaiParser.h"
#import "QJTagModel.h"
#import "QJSettingMytagsEditController.h"

@interface QJAddMytagsSearchController ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<QJTagModel *> *datas;

@end

@implementation QJAddMytagsSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.title = @"新增标签";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    // 配置搜索控制器
    UISearchController *searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchVC.dimsBackgroundDuringPresentation = NO;
    searchVC.obscuresBackgroundDuringPresentation = NO;
    searchVC.hidesNavigationBarDuringPresentation = NO;
    searchVC.searchResultsUpdater = self;
    self.navigationItem.searchController = searchVC;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;
}

#pragma mark - UISearchResultsUpdating Delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length) {
        // 这里请求数据
        [[QJHenTaiParser parser] getResultFromSearchKey:searchController.searchBar.text complete:^(QJHenTaiParserStatus status, NSDictionary *json) {
            if (status == QJHenTaiParserStatusSuccess && [json.allKeys containsObject:@"tags"]) {
                [self.datas removeAllObjects];
                NSDictionary *tagsDic = json[@"tags"];
                if ([tagsDic isKindOfClass:[NSDictionary class]]) {
                    for (NSString *key in tagsDic.allKeys) {
                        QJTagModel *model = [QJTagModel creatModelWithUserTag:key dict:tagsDic[key]];
                        [self.datas addObject:model];
                    }
                }
                [self.tableView reloadData];
            }
        }];
    }
    else {
        [self.datas removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.datas[indexPath.row].name;
    cell.detailTextLabel.text = self.datas[indexPath.row].group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJSettingMytagsEditController *vc = [QJSettingMytagsEditController new];
    vc.apikey = self.apikey;
    vc.apiuid = self.apiuid;
    vc.model = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (NSMutableArray<QJTagModel *> *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

@end
