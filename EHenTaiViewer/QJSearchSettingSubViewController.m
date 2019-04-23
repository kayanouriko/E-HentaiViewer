//
//  QJSearchSettingSubViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/30.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSearchSettingSubViewController.h"
#import "QJSearchSettingTagSearchViewController.h"
#import "Tag+CoreDataClass.h"

@interface QJSearchSettingSubViewController ()<UITableViewDelegate, UITableViewDataSource, QJSearchSettingTagSearchViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;
@property (strong, nonatomic) NSArray *footDatas;

// 一般设定的存储数据
@property (strong, nonatomic) NSMutableArray *normalDatas;
@property (assign, nonatomic) NSInteger smallStarIndex;
// 高级筛选
@property (strong, nonatomic) NSMutableArray *siftDatas;
@property (strong, nonatomic) NSArray *siftInfo;

@end

@implementation QJSearchSettingSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    // 初始化数据
    [self initDatas];
}

- (void)setContent {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

- (void)initDatas {
    // 读取配置文件的信息
    self.smallStarIndex = [QJGlobalInfo getExHentaiSmallStar];
}

#pragma mark - View Method
- (NSArray *)saveAndGetSettingInfo {
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        // 如果是常规,存储就好了
        [QJGlobalInfo setExHentaiSearchSettingArr:self.normalDatas];
        [QJGlobalInfo setExHentaiSmallStar:self.smallStarIndex];
        return @[];
    } else {
        // 如果是高级,则回调数组到外面
        NSMutableArray *data = [NSMutableArray new];
        for (NSInteger i = 0; i < self.siftDatas.count; i++) {
            NSString *string = self.siftDatas[i];
            if (string.length) {
                string = [NSString stringWithFormat:@"%@-%@", self.siftInfo[i], string];
                [data addObject:string];
            }
        }
        return data;
    }
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        NSArray *subArr = self.datas[section];
        return subArr.count;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        return section ? @"其他设置" : @"该页面数据在本地持久化缓存,退出应用后设置保留";
    } else {
        return section ? nil : @"该页面数据不缓存,退出搜索后设置不保留";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"限制在某个 %@ 中搜索", self.footDatas[section]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        // 一般搜索
        NSArray *subArr = self.datas[indexPath.section];
        cell.textLabel.text = subArr[indexPath.row];
        
        // 设置勾选情况
        BOOL type = [self.normalDatas[indexPath.section * 10 + indexPath.row] boolValue];
        cell.accessoryType = type ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
        // 如果是评分,则显示评分
        if (indexPath.section && indexPath.row == subArr.count - 1 && type) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Star", self.smallStarIndex + 1];
        }
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // 高级筛选
        cell.textLabel.text = self.datas[indexPath.section];
        cell.detailTextLabel.text = self.siftDatas[indexPath.section];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == QJSearchSettingSubViewControllerTypeNormal) {
        NSArray *subArr = self.datas[indexPath.section];
        BOOL type = [self.normalDatas[indexPath.section * 10 + indexPath.row] boolValue];
        
        if (indexPath.section && indexPath.row == subArr.count - 1 && !type) {
            // 这里弹出候选框
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"设置最低评分" preferredStyle:UIAlertControllerStyleActionSheet];
            for (NSInteger i = 1; i < 5; i++) {
                UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%ld Star", i + 1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    self.smallStarIndex = i;
                    self.normalDatas[indexPath.section * 10 + indexPath.row] = @(!type);
                    [tableView reloadData];
                }];
                [alert addAction:action];
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            
            UIPopoverPresentationController *popover = alert.popoverPresentationController;
            if (popover) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                popover.sourceView = cell;
                popover.sourceRect = cell.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            // 其余情况修改状态即可
            self.normalDatas[indexPath.section * 10 + indexPath.row] = @(!type);
            [tableView reloadData];
        }
    } else {
        // 高级筛选跳转新页面
        QJSearchSettingTagSearchViewController *vc = [QJSearchSettingTagSearchViewController new];
        vc.title = [NSString stringWithFormat:@"设置%@限制词", self.datas[indexPath.section]];
        vc.indexPath = indexPath;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - QJSearchSettingTagSearchViewControllerDelegate
- (void)tagSearchController:(QJSearchSettingTagSearchViewController *)controller tagName:(NSString *)tagName indexPath:(NSIndexPath *)indexPath {
    self.siftDatas[indexPath.section] = tagName;
    [self.tableView reloadData];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)datas {
    if (nil == _datas) {
        _datas = self.type == QJSearchSettingSubViewControllerTypeNormal ? @[
                                                                             @[@"DOUJINSHI",
                                                                             @"MANGA",
                                                                             @"ARTIST CG",
                                                                             @"GAME CG",
                                                                             @"WESTERN",
                                                                             @"NON-H",
                                                                             @"IMAGE SET",
                                                                             @"COSPLAY",
                                                                             @"ASIAN PORN",
                                                                             @"MISC"],
                                                                             @[@"搜索画廊名字",
                                                                               @"搜索画廊标签",
                                                                               @"搜索画廊描述",
                                                                               @"搜索种子名称",
                                                                               @"仅显示含种子的画廊",
                                                                               @"搜索低愿力标签",
                                                                               @"搜索差评标签",
                                                                               @"显示被删除画廊",
                                                                               @"设置最低评分"]
                                                                             ] : @[@"上传者",
                                                                                   @"艺术家",
                                                                                   @"女性",
                                                                                   @"男性",
                                                                                   @"原作",
                                                                                   @"角色",
                                                                                   @"团队",
                                                                                   @"语言",] ;
    }
    return _datas;
}

- (NSArray *)footDatas {
    if (nil == _footDatas) {
        _footDatas = @[@"上传者",
                       @"绘画作者/Coser",
                       @"女性角色相关的恋物标签",
                       @"男性角色相关的恋物标签",
                       @"同人作品模仿的原始作品",
                       @"作品中出现的角色",
                       @"制作社团或公司",
                       @"作品语言"];
    }
    return _footDatas;
}

- (NSMutableArray *)normalDatas {
    if (nil == _normalDatas) {
        _normalDatas = [[NSMutableArray alloc] initWithArray:[QJGlobalInfo getExHentaiSearchSettingArr]];
    }
    return _normalDatas;
}

- (NSMutableArray *)siftDatas {
    if (nil == _siftDatas) {
        _siftDatas = [NSMutableArray new];
        for (NSInteger i = 0; i < self.siftInfo.count; i++) {
            NSString *key = self.siftInfo[i];
            NSString *value = @"";
            for (NSString *string in self.settings) {
                NSString *info = [string componentsSeparatedByString:@"-"].firstObject;
                if ([info isEqualToString:key]) {
                    value = [string componentsSeparatedByString:@"-"].lastObject;
                    break;
                }
            }
            [_siftDatas addObject:value];
        }
    }
    return _siftDatas;
}

- (NSArray *)siftInfo {
    if (nil == _siftInfo) {
        _siftInfo = @[@"uploader",
                      @"artist",
                      @"female",
                      @"male",
                      @"parody",
                      @"character",
                      @"group",
                      @"language",];
    }
    return _siftInfo;
}

@end
