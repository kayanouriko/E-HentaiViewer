//
//  QJSettingViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/22.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingViewController.h"
//cell
#import "QJSettingLoginCell.h"
#import "QJMainSettingListCell.h"
#import "UITableViewCell+QJAddition.h"
//控制器
#import "QJLoginViewController.h"
#import "QJSettingWatchSettingController.h"

#import "QJHenTaiParser.h"
#import <SafariServices/SafariServices.h>

@interface QJSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *datas;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation QJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessLogin) name:LOGIN_NOTI object:nil];
    // 如果是登陆状态,且没有获取头像和描述信息,则请求网络
    if ([[QJHenTaiParser parser] checkCookie] && ![[QJGlobalInfo getExHentaiUserImageUrl] containsString:@"http"]) {
        [[QJHenTaiParser parser] readUserInfoCompletion:^(QJHenTaiParserStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)setContent {
    // 开启大标题功能
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    self.title = @"设置";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (nil == self.tableView.tableFooterView) {
        UIView *settinngInfoView = [[NSBundle mainBundle] loadNibNamed:@"QJSettingInfo" owner:self options:nil].firstObject;
        settinngInfoView.frame = CGRectMake(0, 0, UIScreenWidth(), 65);
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = infoDictionary[@"CFBundleShortVersionString"];
        NSString *app_build = infoDictionary[@"CFBundleVersion"];
        self.versionLabel.text = [NSString stringWithFormat:@"Version %@(%@) ✨ Made by kayanouriko\n应用仅供学习交流使用\n内容来源于e-hentai.org和exhentai.org",app_Version, app_build];
        
        _tableView.tableFooterView = settinngInfoView;
    }
}

#pragma mark -tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return self.datas.count;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [UIView new];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footView = [UIView new];
    footView.backgroundColor = [UIColor clearColor];
    return footView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell addSectionCornerRadiusWithIndexPath:indexPath tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        QJMainSettingListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJMainSettingListCell class])];
        cell.funcNameLabel.text = self.datas[indexPath.row].firstObject;
        return cell;
    } else {
        QJSettingLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSettingLoginCell class])];
        [cell updateUserInfo];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section) {
        if (indexPath.row == 1) {
            Toast(@"网站系统改版,暂不可用");
            return;
            //检测是否登录
            if (![[QJHenTaiParser parser] checkCookie]) {
                Toast(@"请先前进行登录");
                return;
            }
        }
        QJSettingWatchSettingController *vc = [QJSettingWatchSettingController new];
        vc.type = indexPath.row;
        vc.title = self.datas[indexPath.row].firstObject;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        //登陆相关功能
        if ([[QJHenTaiParser parser] checkCookie]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定注销账号?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelBtn];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([[QJHenTaiParser parser] deleteCokie]) {
                    [self.tableView reloadData];
                }
            }];
            [alertVC addAction:okBtn];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertVC animated:YES completion:nil];
            });
        } else {
            QJLoginViewController *vc = [QJLoginViewController new];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

#pragma mark -QJLoginViewControllerDelagate
- (void)didSuccessLogin {
    [self.tableView reloadData];
    NSLogFunc();
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSettingLoginCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSettingLoginCell class])];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJMainSettingListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJMainSettingListCell class])];
    }
    return _tableView;
}

- (NSArray<NSArray<NSString *> *> *)datas {
    if (nil == _datas) {
        _datas = @[
                   @[@"EH",@"panda"],
                   @[@"高级设置",@"hight"],
                   @[@"反馈/意见",@"book"],
                   @[@"关于",@"about"]
                   ];
    }
    return _datas;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
