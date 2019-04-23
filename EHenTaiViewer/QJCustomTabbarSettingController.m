//
//  QJCustomTabbarSettingController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/7/23.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "QJCustomTabbarSettingController.h"

@interface QJCustomTabbarSettingController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray<NSString *> *datas;
@property(nonatomic, strong) NSDictionary *imageDatas;

@end

@implementation QJCustomTabbarSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI {
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Item Action
- (void)doneAction {
    [QJGlobalInfo setCustomTabbarItems:self.datas];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"长按右侧滑块移动来调整首页底部栏显示顺序";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.imageDatas[cell.textLabel.text]];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *exchangeStr = self.datas[sourceIndexPath.row];
    [self.datas removeObjectAtIndex:sourceIndexPath.row];
    [self.datas insertObject:exchangeStr atIndex:destinationIndexPath.row];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.editing = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), 0.5f)];
        headView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = headView;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray<NSString *> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray arrayWithArray:[QJGlobalInfo customTabbarItems]];
    }
    return _datas;
}

- (NSDictionary *)imageDatas {
    if (!_imageDatas) {
        _imageDatas = @{
                        @"当前热门": @"today",
                        @"画廊": @"games",
                        @"收藏": @"updates",
                        @"设置": @"apps",
                        };
    }
    return _imageDatas;
}

@end
