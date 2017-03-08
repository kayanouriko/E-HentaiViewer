//
//  QJTagMainViewController.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/8.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJTagMainViewController.h"
#import "QJDataManager.h"
#import "QJTagViewController.h"

@interface QJTagMainViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QJDataManager *manager;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) NSArray *keyArr;

@end

@implementation QJTagMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"tagSearch", nil);
    
    [self creatUI];
    
    [self readDBInfo];
}

- (void)creatUI {
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [localPath  stringByAppendingPathComponent:@"tagModel.db"];
    NSLog(@"%@",filePath);
    self.manager = [[QJDataManager alloc] initWithCoreData:@"TagCollect" modelName:@"QJCoreDataModel" sqlPath:filePath success:nil fail:nil];
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)readDBInfo {
    [self.manager readEntity:@[] ascending:NO filterStr:nil success:^(NSArray *results) {
        if (results.count) {
            results = (NSMutableArray *)[[results reverseObjectEnumerator] allObjects];
            for (NSManagedObject *obj in results) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                for (NSString *key in self.keyArr) {
                    dict[key] = [obj valueForKey:key];
                }
                [self.datas addObject:dict];
            }
            [self.tableView reloadData];
        }
    } fail:nil];
}

#pragma mark -tableView协议
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.datas[indexPath.row][@"tagName"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL isExHentai = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ehentaiStatus"] boolValue];
    NSString *url = self.datas[indexPath.row][@"tagUrl"];
    if (isExHentai) {
        url = [url stringByReplacingOccurrencesOfString:@"e-hentai" withString:@"exhentai"];
    }
    else {
        url = [url stringByReplacingOccurrencesOfString:@"exhentai" withString:@"e-hentai"];
    }
    QJTagViewController *vc = [QJTagViewController new];
    vc.mainUrl = url;
    vc.tagName = self.datas[indexPath.row][@"tagName"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
         NSDictionary *dict = self.datas[indexPath.row];
         __block NSManagedObject *obj = nil;
         [self.manager readEntity:@[] ascending:NO filterStr:[NSString stringWithFormat:@"tagName == '%@'",dict[@"tagName"]] success:^(NSArray *results) {
         if (results.count) {
         obj = (NSManagedObject *)results.firstObject;
         }
         } fail:nil];
         [self.manager deleteEntity:obj success:^{
         [self.datas removeObjectAtIndex:indexPath.row];
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
         } fail:nil];
    }];
    NSArray *arr = @[rowAction];
    return arr;
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        //分割线填满
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        //注册
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSArray *)keyArr {
    if (nil == _keyArr) {
        _keyArr = @[@"tagName",@"tagUrl"];
    }
    return _keyArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
