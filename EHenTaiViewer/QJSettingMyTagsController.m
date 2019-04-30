//
//  QJSettingMyTagsController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSettingMyTagsController.h"
#import "QJSettingMyTagsCell.h"
#import "QJAddMytagsSearchController.h"
#import "QJHenTaiParser.h"
//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

#import "QJTagModel.h"

#import "QJSettingMytagsEditController.h"

@interface QJSettingMyTagsController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *leftItems;
@property (strong, nonatomic) UIBarButtonItem *addItem;
@property (strong, nonatomic) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (strong, nonatomic) UIBarButtonItem *doneItem;
// 用于转化数据的model
@property (strong, nonatomic) QJTagListModel *model;

@property (nonatomic, strong) NSMutableArray<NSString *> *selectDatas;

@end

@implementation QJSettingMyTagsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    
    [self readyUpdateDatas];
}

- (void)setContent {
    self.title = @"我的标签";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    // 监听修改/添加标签成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyUpdateDatas) name:kNoticationNameChangeTagSuccess object:nil];
}

- (void)readyUpdateDatas {
    [self showFreshingViewWithTip:nil];
    self.navigationItem.rightBarButtonItems = nil;
    [self updateDatas];
}

- (void)updateDatas {
    [[QJHenTaiParser parser] getMyTagsListInfoComplete:^(QJHenTaiParserStatus status, NSDictionary *json) {
        if (status == QJHenTaiParserStatusSuccess) {
            [self hiddenFreshingView];
            self.model = [QJTagListModel creatModelWithDict:json];
            self.navigationItem.rightBarButtonItems = @[self.deleteItem, self.addItem];
            self.title = self.model.tagset_name;
            [self.tableView reloadData];
        }
        else {
            [self showErrorViewWithTip:nil];
        }
    }];
}

#pragma mark - View Method
- (void)addAction {
    QJAddMytagsSearchController *vc = [QJAddMytagsSearchController new];
    vc.apikey = self.model.apikey;
    vc.apiuid = self.model.apiuid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteAction {
    [self.tableView setEditing:YES animated:YES];
    self.leftItems = [self.navigationItem.leftBarButtonItems copy];
    self.navigationItem.leftBarButtonItems = @[self.cancelItem];
    self.navigationItem.rightBarButtonItems = @[self.doneItem];
}

- (void)doneAction {
    if (self.selectDatas.count == 0) {
        Toast(@"至少先选中一项才能进行操作");
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除选中的标签?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self didDeleteTagsAction];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didDeleteTagsAction {
    // 请求数据
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItems = self.leftItems;
    [self showFreshingViewWithTip:nil];
    self.navigationItem.rightBarButtonItems = nil;
    
    [[QJHenTaiParser parser] deleteMutlitTagWithModifyusertags:self.selectDatas complete:^(QJHenTaiParserStatus status) {
        // 无论成功还是失败,都重新请求数据
        [self updateDatas];
    }];
}

- (void)cancelAction {
    // 处理一些东西
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItems = self.leftItems;
    self.navigationItem.rightBarButtonItems = @[self.deleteItem, self.addItem];
    // 清空选择的标签
    [self.selectDatas removeAllObjects];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJSettingMyTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSettingMyTagsCell class]) forIndexPath:indexPath];
    cell.model = self.model.tags[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        QJTagModel *model = self.model.tags[indexPath.row];
        if (![self.selectDatas containsObject:model.usertag]) {
            [self.selectDatas addObject:model.usertag];
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 跳转修改的界面
    QJSettingMytagsEditController *vc = [QJSettingMytagsEditController new];
    vc.apikey = self.model.apikey;
    vc.apiuid = self.model.apiuid;
    vc.model = self.model.tags[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        QJTagModel *model = self.model.tags[indexPath.row];
        if ([self.selectDatas containsObject:model.usertag]) {
            [self.selectDatas removeObject:model.usertag];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//多选相关
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSettingMyTagsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSettingMyTagsCell class])];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UIBarButtonItem *)deleteItem {
    if (!_deleteItem) {
        _deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e60f", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    }
    return _deleteItem;
}

- (UIBarButtonItem *)addItem {
    if (!_addItem) {
        _addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e621", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(addAction)];
    }
    return _addItem;
}

- (UIBarButtonItem *)doneItem {
    if (!_doneItem) {
        _doneItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e62e", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
    return _doneItem;
}

- (UIBarButtonItem *)cancelItem {
    if (nil == _cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e607", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    }
    return _cancelItem;
}

- (QJTagListModel *)model {
    if (!_model) {
        _model = [QJTagListModel new];
    }
    return _model;
}

- (NSMutableArray<NSString *> *)selectDatas {
    if (!_selectDatas) {
        _selectDatas = [NSMutableArray new];
    }
    return _selectDatas;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationNameChangeTagSuccess object:nil];
}

@end
