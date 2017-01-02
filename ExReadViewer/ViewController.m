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

#define BASE_URL @"http://g.e-hentai.org/"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

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
@property (assign, nonatomic) BOOL needRefersh;
//按钮动作
- (IBAction)btnAction:(UIButton *)sender;
- (IBAction)valueChange:(UISwitch *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self.tableView.mj_header beginRefreshing];
    [self updateResource];
}

- (void)creatUI {
    //初始化
    self.needRefersh = NO;
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 0;
        [self updateResource];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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
}

- (void)updateResource {
    NSString *url = [self getUrlWithAllCondition];
    [HentaiParser requestListAtFilterUrl:url forExHentai:NO completion: ^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.datas removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            else if ([self.tableView.mj_footer isRefreshing]) {
                [self.tableView.mj_footer endRefreshing];
            }
            else {
                [self.datas removeAllObjects];
            }
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (NSString *)getUrlWithAllCondition {
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@?page=%ld", BASE_URL,self.pageIndex];
    for (NSArray *subArr in self.btnStatusArr) {
        [url appendFormat:@"%@%@",self.searchKeyDict[subArr[0]],subArr[1]];
    }
    [url appendFormat:@"&f_search=%@%@",self.switchBtn.on ? @"language:chinese+" : @"",[self.searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [url appendString:@"&f_apply=Apply+Filter"];
    return url;
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
                self.pageIndex = 0;
                [self.tableView.mj_header beginRefreshing];
                [self updateResource];
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
    self.pageIndex = 0;
    [self.tableView.mj_header beginRefreshing];
    [self updateResource];
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
    [self.tableView.mj_header beginRefreshing];
    self.pageIndex = 0;
    [self updateResource];
    return YES;
}

#pragma mark -uitableview滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float contentOffsetY = scrollView.contentOffset.y;
    if (self.oldOffsetY && contentOffsetY > -65.f) {
        float changeOffset = self.oldOffsetY - contentOffsetY;
        if (changeOffset > 0 && self.searchBarTopLine.constant <= 10.f) {
            self.searchBarTopLine.constant += changeOffset;
            if (self.searchBarTopLine.constant > 10.f) {
                self.searchBarTopLine.constant = 10.f;
            }
        }
        else if (changeOffset < 0 && self.searchBarTopLine.constant >= -70.f) {
            self.searchBarTopLine.constant += changeOffset;
            if (self.searchBarTopLine.constant < -65.f) {
                self.searchBarTopLine.constant = -65.f;
            }
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
    NSDictionary *dict = self.datas[indexPath.row];
    QJIntroViewController *vc = [QJIntroViewController new];
    vc.introUrl = dict[@"url"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 157.f;
        _tableView.tableFooterView = [UIView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
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
                       @"MISC":@"f_misc="
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
