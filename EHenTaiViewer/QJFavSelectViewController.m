//
//  QJFavSelectViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJFavSelectViewController.h"
#import "QJFavSelectedCell.h"

@interface QJFavSelectViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navgationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomLine;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<UIColor *> *datas;
- (IBAction)cancelAction:(UIBarButtonItem *)sender;

@end

@implementation QJFavSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请选择收藏夹";
    
    [self setContent];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)setContent {
    self.navgationBar.delegate = self;
    self.navigationBarTopLine.constant = UIStatusBarHeight();
    self.tableViewBottomLine.constant = UITabBarSafeBottomMargin();
    //tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJFavSelectedCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJFavSelectedCell class])];
}

#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJFavSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJFavSelectedCell class])];
    [cell refreshUI:self.datas[indexPath.row] index:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectFavFolder:)]) {
        [self.delegate didSelectFavFolder:indexPath.row];
    }
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -getter
- (NSArray<UIColor *> *)datas {
    if (nil == _datas) {
        _datas = @[
                   [UIColor colorWithRed:0.376 green:0.376 blue:0.376 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.247 blue:0.247 alpha:1.00],
                   [UIColor colorWithRed:0.969 green:0.525 blue:0.184 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.965 blue:0.298 alpha:1.00],
                   [UIColor colorWithRed:0.298 green:1.000 blue:0.463 alpha:1.00],
                   [UIColor colorWithRed:0.722 green:1.000 blue:0.298 alpha:1.00],
                   [UIColor colorWithRed:0.298 green:1.000 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:0.345 green:0.298 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:0.663 green:0.298 blue:1.000 alpha:1.00],
                   [UIColor colorWithRed:1.000 green:0.298 blue:0.788 alpha:1.00]
                   ];
    }
    return _datas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
