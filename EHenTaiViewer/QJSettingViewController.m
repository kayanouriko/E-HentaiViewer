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
#import "QJSettingCell.h"
//控制器
#import "QJLoginViewController.h"
#import "QJAboutListViewController.h"

#import "QJHenTaiParser.h"

@interface QJSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *headArr;
@property (nonatomic, strong) NSArray<NSArray<NSArray *> *> *datas;

@end

@implementation QJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
}

- (void)setContent {
    self.title = @"设置";
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessLogin) name:LOGIN_NOTI object:nil];
}

#pragma mark -tableView
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headArr[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        QJSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSettingCell class])];
        if (indexPath.section == 2 && indexPath.row == 1) {
            [cell refreshUI:@[@"清除缓存",@(QJSettingCellModeNormal),[NSString stringWithFormat:@"%.2f MB",[self filePath]]]];
        }
        else {
            [cell refreshUI:self.datas[indexPath.section][indexPath.row]];
        }
        return cell;
    } else {
        QJSettingLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSettingLoginCell class])];
        if (NSObjForKey(@"loginName")) {
            cell.loginNameLabel.text = NSObjForKey(@"loginName");
        } else {
            NSObjSetForKey(@"loginName", @"未登录");
            NSObjSynchronize();
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //登陆相关功能
        if ([[QJHenTaiParser parser] checkCookie]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定注销账号?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelBtn];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([[QJHenTaiParser parser] deleteCokie]) {
                    NSObjSetForKey(@"ExHentaiStatus", @(NO));
                    [self.tableView reloadData];
                }
            }];
            [alertVC addAction:okBtn];
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            QJLoginViewController *vc = [QJLoginViewController new];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定注清除缓存?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelBtn];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self clearFile];
        }];
        [alertVC addAction:okBtn];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if (indexPath.section == 3) {
        if (indexPath.row) {
            //打开邮件
            [[UIApplication sharedApplication]openURL:[NSURL   URLWithString:@"mailto:qinjiang104@163.com"]];
        }
        else {
            //跳转github
            NSString *githubLink = @"https://github.com/kayanouriko/E-HentaiViewer";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:githubLink]];
        }
    }
    else if (indexPath.section == 4) {
        QJAboutListViewController *vc = [QJAboutListViewController new];
        vc.type = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -获取缓存
- (float)filePath {
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    return [ self folderSizeAtPath :cachPath];
}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (float)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil){
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/( 1024.0 * 1024.0 );
}

- (void)clearFile {
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    NSLog(@"cachpath = %@" ,cachPath);
    for (NSString * p in files) {
        NSError * error = nil ;
        NSString * path = [cachPath stringByAppendingPathComponent :p];
        if ([[ NSFileManager defaultManager ] fileExistsAtPath :path]) {
            [[ NSFileManager defaultManager ] removeItemAtPath :path error :&error];
        }
    }
    [self performSelectorOnMainThread:@selector(clearCachSuccess) withObject:nil waitUntilDone:YES];
}

- (void)clearCachSuccess {
    [self.tableView reloadData];
}

#pragma mark -QJLoginViewControllerDelagate
- (void)didSuccessLogin {
    [self.tableView reloadData];
    NSLogFunc();
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight()) style:UITableViewStyleGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 5 * 42;
        UIView *settinngInfoView = [[NSBundle mainBundle] loadNibNamed:@"QJSettingInfo" owner:nil options:nil].firstObject;
        settinngInfoView.frame = CGRectMake(0, 0, UIScreenWidth(), 65);
        _tableView.tableFooterView = settinngInfoView;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSettingLoginCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSettingLoginCell class])];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSettingCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSettingCell class])];
    }
    return _tableView;
}

- (NSArray *)headArr {
    if (!_headArr) {
        _headArr = @[@"",@"通用设置",@"辅助功能",@"建议&反馈",@"致谢"];
    }
    return _headArr;
}

- (NSArray<NSArray<NSArray *> *> *)datas {
    if (!_datas) {
        _datas = @[
                   @[
                       @[],
                       ],
                   @[
                       @[@"ExHentai浏览",@(QJSettingCellModeSwitch),@""],
                       @[@"应用启动保护",@(QJSettingCellModeSwitch),@""],
                       ],
                   @[
                       @[@"移动网络浏览",@(QJSettingCellModeSwitch),@""],
                       @[@"清除缓存",@(QJSettingCellModeNormal),@""],
                       ],
                   @[
                       @[@"Github",@(QJSettingCellModeNormal),@""],
                       @[@"Email",@(QJSettingCellModeNormal),@""],
                       ],
                   @[
                       @[@"参考项目",@(QJSettingCellModeNormal),@""],
                       @[@"开源框架",@(QJSettingCellModeNormal),@""],
                       ],
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
