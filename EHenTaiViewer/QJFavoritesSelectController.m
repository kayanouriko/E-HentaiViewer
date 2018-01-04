//
//  QJFavoritesSelectController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJFavoritesSelectController.h"
#import "QJFavoritesSelectCell.h"
#import "QJHenTaiParser.h"

@interface QJFavoritesSelectController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *datas;
@property (nonatomic, strong) NSArray<UIColor *> *colors;

@end

@implementation QJFavoritesSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"收藏夹";
    [self setContent];
    
    [self readFavInfo];
}

- (void)setContent {
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)readFavInfo {
    NSArray *array = NSObjForKey(@"favorites");
    NSMutableArray *datas = [NSMutableArray arrayWithArray:array];
    if (!self.isLikeVCJump) {
        [datas removeLastObject];
    }
    self.datas = datas;
    [self.tableView reloadData];
}

#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJFavoritesSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJFavoritesSelectCell class])];
    cell.titleNameLabel.text = self.datas[indexPath.row].firstObject;
    cell.countLabel.text = self.datas[indexPath.row].lastObject;
    cell.colorView.backgroundColor = self.colors[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectFavFolderNameWithArr:index:)]) {
        [self.delegate didSelectFavFolderNameWithArr:self.datas[indexPath.row] index:self.isLikeVCJump && indexPath.row == self.datas.count - 1 ? -1 : indexPath.row];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 5 * 42;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJFavoritesSelectCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJFavoritesSelectCell class])];
    }
    return _tableView;
}

- (NSArray<UIColor *> *)colors {
    if (nil == _colors) {
        _colors = @[
                   [UIColor colorWithRed:0.376 green:0.376 blue:0.376 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.247 blue:0.247 alpha:1.00],
                   [UIColor colorWithRed:0.969 green:0.525 blue:0.184 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.965 blue:0.298 alpha:1.00],
                   [UIColor colorWithRed:0.298 green:1.000 blue:0.463 alpha:1.00],
                   [UIColor colorWithRed:0.722 green:1.000 blue:0.298 alpha:1.00],
                   [UIColor colorWithRed:0.298 green:1.000 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:0.345 green:0.298 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:0.663 green:0.298 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.298 blue:0.788 alpha:1.00],
                   [UIColor blackColor]
                   ];
    }
    return _colors;
}

@end
