//
//  QJSettingWatchSettingController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/16.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingWatchSettingController.h"
#import "QJHenTaiParser.h"
#import "QJSettingItem.h"
#import "QJSettingListCell.h"
#import "QJSettingModel.h"
#import <SafariServices/SafariServices.h>
#import "QJProtectTool.h"
#import "QJLanguageOutViewController.h"
#import "QJSettingHightOtherController.h"
#import "QJCustomTabbarSettingController.h"

static NSString *const kSaveSettingInfoNoti = @"SaveSettingInfoNoti";

@interface QJSettingWatchSettingController ()<UITableViewDelegate, UITableViewDataSource, QJSettingListCellDelagate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<QJSettingModel *> *datas;
@property (nonatomic, strong) NSDictionary<NSString *,QJSettingItem *> *settingDict;

@end

@implementation QJSettingWatchSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    //高级设置提供提示
    if (self.type == QJSettingWatchSettingControllerTypeHight) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(showAbount) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
        [self showFreshingViewWithTip:nil];
        [self updateResource];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettingInfo) name:kSaveSettingInfoNoti object:nil];
        return;
    }
    [self setContent];
}

- (void)setContent {
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)showAbount {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"该页面的修改只会影响账号在本客户端的浏览设置,并不会影响到账号在浏览器的浏览设置." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okBtn];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)updateResource {
    [[QJHenTaiParser parser] readSettingAllInfoCompletion:^(QJHenTaiParserStatus status, NSDictionary<NSString *,QJSettingItem *> *settingDict) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.settingDict = settingDict;
            [self setContent];
            if ([self isShowFreshingStatus]) {
                [self hiddenFreshingView];
            }
        }
    }];
}

- (void)saveSettingInfo {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *key in self.settingDict.allKeys) {
        QJSettingItem *model = self.settingDict[key];
        if ([key isEqualToString:@"排除语言"]) {
            for (QJSettingLanguageItem *subModel in model.subModels) {
                for (QJSettingLanguageCheckBoxItem *checkModel in subModel.models) {
                    if (checkModel.name.length && checkModel.checked) {
                        [params setValue:@"on" forKey:checkModel.name];
                    }
                    //这个属性网站不能修改,这里本地存储做强制修改
                    if ([checkModel.name isEqualToString:@"xl_0"]) {
                        NSObjSetForKey(@"xl_0", checkModel.isChecked ? @"on" : @"");
                        NSObjSynchronize();
                    }
                }
            }
        }
        else {
            for (QJSettingCheckboxItem *subModel in model.subModels) {
                if (subModel.name.length && subModel.isChecked) {
                    [params setValue:@"on" forKey:subModel.name];
                }
            }
        }
    }
    [[QJHenTaiParser parser] postMySettingInfoWithParams:params Completion:nil];
}

#pragma mark -QJSettingListCellDelagate
- (void)valueChangeWithSwitch:(UISwitch *)switchBtn model:(QJSettingModel *)model {
    if ([model.title isEqualToString:@"画廊站点"]) {
        if (![[QJHenTaiParser parser] checkCookie]) {
            Toast(@"请先前往设置页面进行登录");
            [QJGlobalInfo setExHentaiStatus:NO];
        }
        else {
            [QJGlobalInfo setExHentaiStatus:switchBtn.on];
        }
    }
    else if ([model.title isEqualToString:@"移动网络浏览"]) {
        [QJGlobalInfo setExHentaiWatchMode:switchBtn.on];
    }
    else if ([model.title isEqualToString:@"显示中文Tag"]) {
        [QJGlobalInfo setExHentaiTagCnMode:switchBtn.on];
    }
    else if ([model.title isEqualToString:@"显示日文标题"]) {
        [QJGlobalInfo setExHentaiTitleJnMode:switchBtn.on];
    }
    else if ([model.title isEqualToString:@"启动保护"]) {
        if (switchBtn.on) {
            if ([[QJProtectTool shareTool] isEnableTouchID]) {
                [[QJProtectTool shareTool] showTouchID:^(QJProtectToolStatus status) {
                    BOOL switchStatus = status != QJProtectToolStatusCannel;
                    [switchBtn setOn:switchStatus animated:YES];
                    model.value = [NSString stringWithFormat:@"%@",@(switchStatus)];
                    [QJGlobalInfo setExHentaiProtectMode:switchStatus];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }];
            }
            else {
                [switchBtn setOn:NO animated:YES];
                [QJGlobalInfo setExHentaiProtectMode:NO];
            }
        } else {
            [QJGlobalInfo setExHentaiProtectMode:NO];
        }
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJSettingListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSettingListCell class])];
    cell.model = self.datas[indexPath.row];
    if (self.type == QJSettingWatchSettingControllerTypeEH) {
        cell.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJSettingModel *model = self.datas[indexPath.row];
    if (self.type == QJSettingWatchSettingControllerTypeEH) {
        if ([model.type isEqualToString:@"操作"] && [model.title isEqualToString:@"自定义底部栏"]) {
            QJCustomTabbarSettingController *vc = [QJCustomTabbarSettingController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定清除缓存?其中包括已经缓存的画廊大图" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelBtn];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self clearFile];
            }];
            [alertVC addAction:okBtn];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }
    else if (self.type == QJSettingWatchSettingControllerTypeHight) {
        if ([model.title isEqualToString:@"排除语言"]) {
            QJLanguageOutViewController *vc = [QJLanguageOutViewController new];
            vc.title = model.title;
            vc.model = self.settingDict[model.title];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            QJSettingHightOtherController *vc = [QJSettingHightOtherController new];
            vc.title = model.title;
            vc.model = self.settingDict[model.title];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (self.type == QJSettingWatchSettingControllerTypeSuggest) {
        if ([model.type isEqualToString:@"邮件"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.value]];
        }
        else if ([model.type isEqualToString:@"网址"]) {
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:model.value]];
                [self presentViewController:safariVC animated:YES completion:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.value]];
            }
        }
    }
    else if (self.type == QJSettingWatchSettingControllerTypeAbout) {
        QJSettingWatchSettingController *vc = [QJSettingWatchSettingController new];
        vc.type = [model.value integerValue];
        vc.title = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.type == QJSettingWatchSettingControllerTypeAboutReference || self.type == QJSettingWatchSettingControllerTypeAboutFrame) {
        if (@available(iOS 9.0, *)) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:model.value]];
            [self presentViewController:safariVC animated:YES completion:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.value]];
        }
    }
}

#pragma mark -获取缓存
- (float)filePath {
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    return [self folderSizeAtPath:cachPath];
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
    // 清除已缓存的画廊
    NSString *imageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:imageDir error:nil];
    
    
    [self performSelectorOnMainThread:@selector(clearCachSuccess) withObject:nil waitUntilDone:YES];
}

- (void)clearCachSuccess {
    for (QJSettingModel *model in self.datas) {
        if ([model.title isEqualToString:@"清除缓存"]) {
            model.subTitle = [NSString stringWithFormat:@"%.2f MB",[self filePath]];
            break;
        }
    }
    [self.tableView reloadData];
}

#pragma mark -getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        _tableView.tableFooterView = [UIView new];
        //注册
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSettingListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSettingListCell class])];
    }
    return _tableView;
}

- (NSArray<QJSettingModel *> *)datas {
    if (nil == _datas) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"QJSettingModel" ofType:@"plist"];
        NSDictionary *json = [NSDictionary dictionaryWithContentsOfFile:jsonPath];
        
        NSString *key = @"";
        if (self.type == QJSettingWatchSettingControllerTypeEH) {
            key = @"eh";
        }
        else if (self.type == QJSettingWatchSettingControllerTypeHight) {
            key = @"hight";
        }
        else if (self.type == QJSettingWatchSettingControllerTypeSuggest) {
            key = @"suggest";
        }
        else if (self.type == QJSettingWatchSettingControllerTypeAbout) {
            key = @"about";
        }
        else if (self.type == QJSettingWatchSettingControllerTypeAboutReference) {
            key = @"reference";
        }
        else if (self.type == QJSettingWatchSettingControllerTypeAboutFrame) {
            key = @"frame";
        }
        
        NSArray *array = json[key];
        NSMutableArray *datas = [NSMutableArray new];
        for (NSDictionary *dic in array) {
            QJSettingModel *model = [QJSettingModel creatModelWithDict:dic];
            if ([key isEqualToString:@"eh"]) {
                //这个类型要做特殊处理
                if ([model.title isEqualToString:@"画廊站点"]) {
                    model.value = [NSString stringWithFormat:@"%d", [QJGlobalInfo isExHentaiStatus]];
                }
                else if ([model.title isEqualToString:@"移动网络浏览"]) {
                    model.value = [NSString stringWithFormat:@"%d", [QJGlobalInfo isExHentaiWatchMode]];
                }
                else if ([model.title isEqualToString:@"显示中文Tag"]) {
                    model.value = [NSString stringWithFormat:@"%d", [QJGlobalInfo isExHentaiTagCnMode]];
                }
                else if ([model.title isEqualToString:@"显示日文标题"]) {
                    model.value = [NSString stringWithFormat:@"%d", [QJGlobalInfo isExHentaiTitleJnMode]];
                }
                else if ([model.title isEqualToString:@"启动保护"]) {
                    model.value = [NSString stringWithFormat:@"%d", [QJGlobalInfo isExHentaiProtectMode]];
                }
                else if ([model.title isEqualToString:@"清除缓存"]) {
                    model.subTitle = [NSString stringWithFormat:@"%.2f MB",[self filePath]];
                }
            }
            [datas addObject:model];
        }
        _datas = datas;
    }
    return _datas;
}

@end
