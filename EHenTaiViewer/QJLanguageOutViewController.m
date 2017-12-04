//
//  QJLanguageOutViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLanguageOutViewController.h"
#import "QJLanguageOutCell.h"
#import "QJLanguageOutHeadView.h"
#import "QJSettingItem.h"
#import "QJHenTaiParser.h"

static NSString *const kSaveSettingInfoNoti = @"SaveSettingInfoNoti";

@interface QJLanguageOutViewController ()<UITableViewDelegate, UITableViewDataSource, QJLanguageOutCellDelagate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QJLanguageOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveInfo)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)saveInfo {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSaveSettingInfoNoti object:nil];
}

#pragma mark -QJLanguageOutCellDelagate
- (void)didClickBtn {
    [self.tableView reloadData];
}

#pragma mark -tableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QJLanguageOutHeadView *headView = [[NSBundle mainBundle] loadNibNamed:@"QJLanguageOutHeadView" owner:nil options:nil][0];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.subModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJLanguageOutCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJLanguageOutCell class])];
    QJSettingLanguageItem *model = self.model.subModels[indexPath.row];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark -getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        //注册
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJLanguageOutCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJLanguageOutCell class])];
    }
    return _tableView;
}

@end
