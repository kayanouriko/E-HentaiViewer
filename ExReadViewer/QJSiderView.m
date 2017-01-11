//
//  QJSiderView.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/7.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJSiderView.h"

@interface QJSiderView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *siderViewRightLine;

@property (strong, nonatomic) NSArray *datas;

@end

@implementation QJSiderView

+ (QJSiderView *)shareView {
    static QJSiderView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSBundle mainBundle] loadNibNamed:@"QJSiderView" owner:nil options:nil].firstObject;
        instance.frame = [UIScreen mainScreen].bounds;
        instance.alpha = 0;
        UIWindow *mainWindows = [UIApplication sharedApplication].keyWindow;
        [mainWindows addSubview:instance];
    });
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //添加手势
    self.bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.bgView addGestureRecognizer:tap];
    self.titleNameLabel.text = NSLocalizedString(@"ExReader", nil);
    self.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeGest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeGest.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeGest];
    //tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)show {
    self.alpha = 1;
    [UIView animateWithDuration:0.25f animations:^{
        self.siderViewRightLine.constant = 0;
        self.bgView.alpha = 0.5;
        [self layoutIfNeeded];
    }];
}

- (void)close {
    [UIView animateWithDuration:0.25f animations:^{
        self.siderViewRightLine.constant = -200;
        self.bgView.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.alpha = 0;
    }];
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *dict = self.datas[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    cell.textLabel.tintColor = [UIColor darkGrayColor];
    UIImage *image = [UIImage imageNamed:dict[@"icon"]];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.image = image;
    cell.imageView.tintColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.datas[indexPath.row];
    [self close];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickSiderWithDict:)]) {
        [self.delegate didClickSiderWithDict:dict];
    }
}

#pragma mark -懒加载
- (NSArray *)datas {
    if (nil == _datas) {
        _datas = @[
                   @{
                       @"name":NSLocalizedString(@"hot", nil),
                       @"icon":@"hot",
                       },
                   @{
                       @"name":NSLocalizedString(@"download", nil),
                       @"icon":@"download",
                       },
                   @{
                       @"name":NSLocalizedString(@"favorites", nil),
                       @"icon":@"like",
                       },
                   @{
                       @"name":NSLocalizedString(@"setting", nil),
                       @"icon":@"setting",
                       },
                   ];
    }
    return _datas;
}

@end
