//
//  ViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/25.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "ViewController.h"
#import "QJMainListCell.h"
#import "HentaiParser.h"
#import "QJIntroViewController.h"
#import "QJSettingViewController.h"
#import "QJTouchIDViewController.h"
#import "QJPasswordViewController.h"
#import "QJHotViewController.h"
#import "QJFavoritesViewController.h"
#import "QJTopButtonView.h"
#import "DiveExHentaiV2.h"
#import "AFNetworking.h"
#import "QJTagMainViewController.h"
#import "TagCollect+CoreDataClass.h"
#import "MMButtonMenu.h"

#define EHentai_URL @"https://e-hentai.org/"
#define ExHentai_URL @"https://exhentai.org//"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,QJTopButtonViewDelagate>
//导航栏
@property (strong, nonatomic) QJTopButtonView *topButtonView;
@property (strong, nonatomic) MMButtonMenu *buttonMenu;
//tablewview
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (assign, nonatomic) NSInteger pageIndex;
//搜索项
@property (weak, nonatomic) IBOutlet UIView *searchBarView;
@property (weak, nonatomic) IBOutlet UIView *searchBarBgView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopLine;//搜索框上约束线
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (assign, nonatomic) float oldOffsetY;//前一次偏移量
@property (weak, nonatomic) IBOutlet UIView *searchKeyView;
@property (weak, nonatomic) IBOutlet UIImageView *crossImageView;
@property (strong, nonatomic) NSMutableArray *btnStatusArr;
@property (strong, nonatomic) NSDictionary *colorDict;
@property (strong, nonatomic) NSDictionary *searchKeyDict;
@property (assign, nonatomic) BOOL needRefersh;//筛选条件之后是否需要刷新
@property (assign, nonatomic) BOOL needTouchID;//是否需要TouchID
@property (assign, nonatomic) BOOL isAddDatas;//下拉的时候是否需要添加旧数据
@property (assign, nonatomic) BOOL isExHentai;//是否是里站
//按钮动作
- (IBAction)btnAction:(UIButton *)sender;
- (IBAction)valueChange:(UISwitch *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatUI];
    //如果Cookie有问题,则进来不刷新数据
    if (self.isExHentai && ![DiveExHentaiV2 checkCookie]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"invalidcookie", nil)];
        [SVProgressHUD dismissWithDelay:1.f];
        return;
    }
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray *status = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"privacy"]];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (status.count && self.needTouchID && [status[1] boolValue]) {
        [self pushTouchIDVC];
        self.needTouchID = NO;
    }
    else if (status.count && self.needTouchID && [status[0] boolValue] && password) {
        [self pushPWDVC];
        self.needTouchID = NO;
    }
    else if (!status.count || !status || (status.count && ![status[0] boolValue] && ![status[1] boolValue])) {
        self.needTouchID = NO;
    }
}

- (void)pushTouchIDVC {
    QJTouchIDViewController *vc = [QJTouchIDViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pushPWDVC {
    QJPasswordViewController *vc = [QJPasswordViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)creatUI {
    //初始化
    self.needRefersh = NO;
    self.needTouchID = YES;
    self.isAddDatas = NO;
    //中间按钮视图
    self.navigationItem.titleView = self.topButtonView;
    //判断状态
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ehentaiStatus"]) {
        self.isExHentai = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ehentaiStatus"] boolValue];
    }
    else {
        self.isExHentai = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@(self.isExHentai) forKey:@"ehentaiStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //悬浮Button
    [self.view addSubview:self.buttonMenu];
    //状态栏
    //[self.view addSubview:self.statueView];
    //tablewview
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex--;
        if (self.pageIndex < 0) {
            self.pageIndex = 0;
            self.isAddDatas = NO;
        }
        [self updateResource];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.isAddDatas = NO;
        self.pageIndex++;
        [self updateResource];
    }];
    //searchbar相关
    self.searchBarView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchBarView.layer.shadowOffset = CGSizeMake(4,4);
    self.searchBarView.layer.shadowOpacity = 0.2;
    self.searchBarView.layer.shadowRadius = 4;
    
    self.searchTextField.placeholder = NSLocalizedString(@"searchkey", nil);
    self.searchTextField.delegate = self;
    
    self.crossImageView.clipsToBounds = YES;
    self.crossImageView.transform = CGAffineTransformMakeRotation(M_PI * 45.f / 180);
    
    self.searchKeyView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchKeyView.layer.shadowOffset = CGSizeMake(4,4);
    self.searchKeyView.layer.shadowOpacity = 0.2;
    self.searchKeyView.layer.shadowRadius = 4;
    
    [self.view bringSubviewToFront:self.searchBarBgView];
    [self.view bringSubviewToFront:self.searchKeyView];
    [self.view bringSubviewToFront:self.searchBarView];
    //设置板块状态
    self.topButtonView.titleLabel.text = self.isExHentai ? @"ExHentai" : @"EHentai";
    //设置按钮状态
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"searchBtnStatus"]) {
        [self.btnStatusArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"searchBtnStatus"]];
        self.switchBtn.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"onlyChinese"] boolValue];
    }
    else {
        NSArray *array = @[@"DOUJINSHI", @"MANGA", @"ARTIST CG", @"GAME CG", @"WESTERN", @"NON-H", @"IMAGE SET", @"COSPLAY", @"ASIAN PORN", @"MISC"];
        NSMutableArray *btnStatus = [NSMutableArray new];
        for (NSString *str in array) {
            [btnStatus addObject:@[str, @"1"]];
        }
        [self.btnStatusArr addObjectsFromArray:btnStatus];
        [[NSUserDefaults standardUserDefaults] setObject:btnStatus forKey:@"searchBtnStatus"];
        
        self.switchBtn.on = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@(self.switchBtn.on) forKey:@"onlyChinese"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    for (NSInteger i = 0; i < 10; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:701 + i];
        NSMutableArray *btnStatus = [NSMutableArray arrayWithArray:self.btnStatusArr[i]];
        UIColor *selectColor = self.colorDict[btnStatus[0]];
        btn.layer.borderColor = selectColor.CGColor;
        btn.layer.borderWidth = 1.f;
        if ([btnStatus[1] boolValue]) {
            //选中
            btn.backgroundColor = selectColor;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else {
            //没选中
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:selectColor forState:UIControlStateNormal];
        }
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 44, 24);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 24, 24)];
    imageView.image = [UIImage imageNamed:@"ic_zyhc"];
    [btn addSubview:imageView];
    [btn addTarget:self action:@selector(tagSearch)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    /*
     留言测试
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发言" style:UIBarButtonItemStylePlain target:self action:@selector(sendSMS)];
    self.navigationItem.rightBarButtonItem = item;
     */
}

#pragma mark -本地保存的tag搜索
- (void)tagSearch {
    QJTagMainViewController *vc = [QJTagMainViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sendSMS {
    /*
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [session.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [session POST:@"https://exhentai.org/g/1021714/d2cdad1c4a/" parameters:@{@"commenttext":@"惊了这结局...",@"postcomment":@"Post Comment"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@",error);
    }];
    
    [session setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        if (request) {
            //this is the redirected url
            NSLog(@"%@",request.URL);
            return nil;
        }
        return request;
    }];
    */
}

- (void)refreshUI {
    if ([self.buttonMenu isExpanded]) {
        [self.buttonMenu toggleMenu];
    }
    if (![self.tableView.mj_header isRefreshing] && ![self.tableView.mj_footer isRefreshing]) {
        self.searchBarTopLine.constant = 10.f;
        self.pageIndex = 0;
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)updateResource {
    if (self.isExHentai && ![DiveExHentaiV2 checkCookie]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"invalidcookie", nil)];
        [SVProgressHUD dismissWithDelay:2.f];
        return;
    }
    NSString *url = [self getUrlWithAllCondition];
    [HentaiParser requestListAtFilterUrl:url forExHentai:self.isExHentai completion: ^(HentaiParserStatus status, NSArray *listArray) {
        NSArray *tempArr = [NSMutableArray new];
        if (status && [listArray count]) {
            if ([self.tableView.mj_header isRefreshing] && self.pageIndex != 0) {
                tempArr = [self.datas mutableCopy];
                [self.datas removeAllObjects];
            }
            else if ([self.tableView.mj_footer isRefreshing]) {
                
            }
            else {
                [self.datas removeAllObjects];
            }
            [self.datas addObjectsFromArray:listArray];
            
            NSInteger count = 0;
            if (self.isAddDatas) {
                count = listArray.count;
                [self.datas addObjectsFromArray:tempArr];
            }
            
            [self.tableView reloadData];
            
            if (tempArr.count && self.isAddDatas) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            self.isAddDatas = YES;
            
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Page %ld",self.pageIndex + 1]];
            [SVProgressHUD dismissWithDelay:0.75f];
        }
        else {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
                [self.datas removeAllObjects];
            }
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [self.tableView reloadData];
        }
    }];
}

- (NSString *)getUrlWithAllCondition {
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@?page=%ld", self.isExHentai ? ExHentai_URL : EHentai_URL,(long)self.pageIndex];
    for (NSArray *subArr in self.btnStatusArr) {
        [url appendFormat:@"%@%@",self.searchKeyDict[subArr[0]],subArr[1]];
    }
    [url appendFormat:@"&f_search=%@%@",self.switchBtn.on ? @"language:chinese+" : @"",[self.searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [url appendString:@"&f_apply=Apply+Filter"];
    return url;
}

#pragma mark -导航栏点击选择画廊
- (void)didClickChannelWithName:(NSString *)title {
    self.isExHentai = [title isEqualToString:@"ExHentai"];
    //保存在沙盒
    [[NSUserDefaults standardUserDefaults] setObject:@(self.isExHentai) forKey:@"ehentaiStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.isExHentai && ![DiveExHentaiV2 checkCookie]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"invalidcookie", nil)];
        [SVProgressHUD dismissWithDelay:2.f];
        return;
    }
    //刷新tableview
    self.searchBarTopLine.constant = 10.f;
    self.pageIndex = 0;
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark -按钮点击事件
- (IBAction)btnAction:(UIButton *)sender {
    //叉
    if (sender.tag == 700) {
        if (self.searchBarBgView.alpha) {
            [self.searchTextField resignFirstResponder];
            [UIView animateWithDuration:0.25f animations:^{
                self.crossImageView.transform = CGAffineTransformMakeRotation(M_PI * 45.f / 180);
                self.searchBarBgView.alpha = 0;
                self.searchKeyView.alpha = 0;
            }];
            if (self.needRefersh) {
                self.needRefersh = NO;
                [[NSUserDefaults standardUserDefaults] setObject:self.btnStatusArr forKey:@"searchBtnStatus"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.pageIndex = 0;
                [self.tableView.mj_header beginRefreshing];
            }
        }
        else {
            [UIView animateWithDuration:0.25f animations:^{
                self.crossImageView.transform = CGAffineTransformMakeRotation(0);
                self.searchBarBgView.alpha = 1;
                self.searchKeyView.alpha = 1;
            }];
        }
    }
    //类别
    else {
        self.needRefersh = YES;
        NSInteger i = sender.tag - 701;
        NSMutableArray *btnStatus = [NSMutableArray arrayWithArray:self.btnStatusArr[i]];
        UIColor *selectColor = self.colorDict[btnStatus[0]];
        if ([btnStatus[1] boolValue]) {
            //选中
            sender.backgroundColor = [UIColor whiteColor];
            [sender setTitleColor:selectColor forState:UIControlStateNormal];
            btnStatus[1] = @"0";
        }
        else {
            //没选中
            sender.backgroundColor = selectColor;
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnStatus[1] = @"1";
        }
        self.btnStatusArr[i] = btnStatus;
    }
}

- (IBAction)valueChange:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.switchBtn.on) forKey:@"onlyChinese"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.pageIndex = 0;
    [self.tableView.mj_header beginRefreshing];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.needRefersh = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        self.crossImageView.transform = CGAffineTransformMakeRotation(M_PI * 45.f / 180);
        self.searchBarBgView.alpha = 0;
        self.searchKeyView.alpha = 0;
    }];
    self.pageIndex = 0;
    [self.tableView.mj_header beginRefreshing];
    return YES;
}

#pragma mark -uitableview滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float contentOffsetY = scrollView.contentOffset.y;
    if (self.oldOffsetY && contentOffsetY > -65) {
        float changeOffset = self.oldOffsetY - contentOffsetY;
        if ([self.buttonMenu isExpanded]) {
            [self.buttonMenu toggleMenu];
        }
        if (changeOffset > 0) {
            [UIView animateWithDuration:0.25f animations:^{
                self.searchBarTopLine.constant = 10.f;
                self.buttonMenu.alpha = 1;
                [self.view layoutIfNeeded];
            }];
        } else {
            [UIView animateWithDuration:0.25f animations:^{
                self.searchBarTopLine.constant = -60.f;
                self.buttonMenu.alpha = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
    self.oldOffsetY = contentOffsetY;
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJMainListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewHide" object:nil];
    NSDictionary *dict = self.datas[indexPath.row];
    QJIntroViewController *vc = [QJIntroViewController new];
    vc.introUrl = dict[@"url"];
    vc.infoDict = dict;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        //_tableView.frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight - 20);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 157.f;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
        [_tableView setContentOffset:CGPointMake(0, -65) animated:YES];
        //注册
        [_tableView registerNib:[UINib nibWithNibName:@"QJMainListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSDictionary *)colorDict {
    if (nil == _colorDict) {
        _colorDict = @{
                       @"DOUJINSHI":DOUJINSHI_COLOR,
                       @"MANGA":MANGA_COLOR,
                       @"ARTIST CG":ARTISTCG_COLOR,
                       @"GAME CG":GAMECG_COLOR,
                       @"WESTERN":WESTERN_COLOR,
                       @"NON-H":NONH_COLOR,
                       @"IMAGE SET":IMAGESET_COLOR,
                       @"COSPLAY":COSPLAY_COLOR,
                       @"ASIAN PORN":ASIANPORN_COLOR,
                       @"MISC":MISC_COLOR
                       };
    }
    return _colorDict;
}

- (NSDictionary *)searchKeyDict {
    if (nil == _searchKeyDict) {
        _searchKeyDict = @{
                       @"DOUJINSHI":@"&f_doujinshi=",
                       @"MANGA":@"&f_manga=",
                       @"ARTIST CG":@"&f_artistcg=",
                       @"GAME CG":@"&f_gamecg=",
                       @"WESTERN":@"&f_western=",
                       @"NON-H":@"&f_non-h=",
                       @"IMAGE SET":@"&f_imageset=",
                       @"COSPLAY":@"&f_cosplay=",
                       @"ASIAN PORN":@"&f_asianporn=",
                       @"MISC":@"&f_misc="
                       };
    }
    return _searchKeyDict;
}

- (NSMutableArray *)btnStatusArr {
    if (nil == _btnStatusArr) {
        _btnStatusArr = [NSMutableArray new];
    }
    return _btnStatusArr;
}

- (QJTopButtonView *)topButtonView {
    if (nil == _topButtonView) {
        _topButtonView = [[NSBundle mainBundle] loadNibNamed:@"QJTopButtonView" owner:nil options:nil].firstObject;
        _topButtonView.frame = CGRectMake(0, 0, 110, 44);
        _topButtonView.delegate = self;
    }
    return _topButtonView;
}

- (MMButtonMenu *)buttonMenu {
    if (nil == _buttonMenu) {
        MMButtonMenuItem *menuButtonItem1 = [[MMButtonMenuItem alloc] init];
        menuButtonItem1.backgroundColor = APP_COLOR;
        UIImage *actionImage = [[UIImage imageNamed:@"refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [menuButtonItem1 setImage:actionImage forState:UIControlStateNormal];
        [menuButtonItem1 addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        
        MMButtonMenuItem *menuButtonItem2 = [[MMButtonMenuItem alloc] init];
        menuButtonItem2.backgroundColor = APP_COLOR;
        UIImage *actionImage1 = [[UIImage imageNamed:@"jump"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [menuButtonItem2 setImage:actionImage1 forState:UIControlStateNormal];
        [menuButtonItem2 addTarget:self action:@selector(jumpPage) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonMenu = [[MMButtonMenu alloc] initWithFrame:self.view.frame menuItems:[NSArray arrayWithObjects:menuButtonItem2, menuButtonItem1,nil]];
        _buttonMenu.mainMenuItem.backgroundColor = APP_COLOR;
    }
    return _buttonMenu;
}

- (void)jumpPage {
    NSString *totalPages = self.datas.firstObject[@"totalPage"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", nil) message:[NSString stringWithFormat:@"%@ Pages",totalPages] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Page";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1300;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([self.buttonMenu isExpanded]) {
            [self.buttonMenu toggleMenu];
        }
        
        UITextField *pwdTextField = (UITextField *)[alertController.view viewWithTag:1300];
        self.pageIndex = [pwdTextField.text integerValue];
        self.isAddDatas = NO;
        [self.tableView.mj_header beginRefreshing];
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
