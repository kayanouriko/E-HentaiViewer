//
//  QJSearchSettingTagSearchViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/1.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSearchSettingTagSearchViewController.h"
#import "Tag+CoreDataClass.h"

@interface QJSearchSettingTagSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;

@end

@implementation QJSearchSettingTagSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
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
    NSString *key = searchController.searchBar.text;
    [self updateSearchResultsWithText:key];
}

- (void)updateSearchResultsWithText:(NSString *)text {
    [self.datas removeAllObjects];
    if (text.length) {
        // 先加入输入文本
        [self.datas addObject:@[text, @"选择该输入文本"]];
        
        NSString *searchText = [NSString stringWithFormat:@"*%@*", text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@ OR cname LIKE %@", searchText, searchText];
        NSArray *jpTags = [Tag MR_findAllWithPredicate:predicate];
        [self.datas addObjectsFromArray:jpTags];
    }
    [self.tableView reloadData];
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
    id model = self.datas[indexPath.row];
    if ([model isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)model;
        cell.textLabel.text = array.firstObject;
        cell.detailTextLabel.text = array.lastObject;
    } else {
        Tag *tag = (Tag *)model;
        cell.textLabel.text = tag.name;
        cell.detailTextLabel.text = tag.cname;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagSearchController:tagName:indexPath:)]) {
        
        NSString *tagName = @"";
        id model = self.datas[indexPath.row];
        if ([model isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)model;
            tagName = array.firstObject;
        } else {
            Tag *tag = (Tag *)model;
            tagName = tag.name;
        }
        
        [self.delegate tagSearchController:self tagName:tagName indexPath:self.indexPath];
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

@end
