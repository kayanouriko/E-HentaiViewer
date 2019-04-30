//
//  QJSettingMytagsEditController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSettingMytagsEditController.h"
#import "QJTagModel.h"
//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

// 取色器相关
#import "QJColorPickBoard.h"
#import "QJColorPickSlider.h"
#import "QJColorPickShowView.h"

#import <SafariServices/SafariServices.h>

#import "QJHenTaiParser.h"

@interface QJSettingMytagsEditController ()<QJColorPickSliderDelegate, QJColorPickBoardDelegate>

@property (strong, nonatomic) UIBarButtonItem *doneItem;
@property (strong, nonatomic) UIBarButtonItem *freshItem;
@property (nonatomic, strong) UIActivityIndicatorView *actity;

@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegControl;
@property (weak, nonatomic) IBOutlet UITextField *weightTextF;
@property (weak, nonatomic) IBOutlet QJColorPickShowView *colorShowView;
@property (weak, nonatomic) IBOutlet QJColorPickSlider *colorSlider;
@property (weak, nonatomic) IBOutlet QJColorPickBoard *colorPickBoard;

@end

@implementation QJSettingMytagsEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.title = @"修改标签信息";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = self.doneItem;
    
    self.colorPickBoard.delegate = self;
    self.colorSlider.delegate = self;
    
    if (self.model) {
        // 设置显示数据
        self.tagNameLabel.text = [QJGlobalInfo isExHentaiTagCnMode] ? self.model.name_ch : self.model.name;
        self.groupLabel.text = self.model.group;
        if (self.model.isNone) {
            self.statusSegControl.selectedSegmentIndex = 0;
        }
        else {
            self.statusSegControl.selectedSegmentIndex = self.model.isWatched ? 1 : 2;
        }
        self.weightTextF.text = self.model.weight;
        self.colorShowView.showColor = UIColorHex(self.model.backgroundColor);
    }
}

#pragma mark - View Method
- (void)doneAction {
    [self.view endEditing:YES];
    self.view.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = self.freshItem;
    [self.actity startAnimating];
    Toast(@"正在提交操作,请稍等...");
    
    NSArray *vcs = self.navigationController.viewControllers;
    NSInteger index = vcs.count - 2;
    UIViewController *vc = vcs[index];
    if ([vc isKindOfClass:NSClassFromString(@"QJAddMytagsSearchController")]) {
        // 这是添加tag模式
        index--;
        [[QJHenTaiParser parser] addNewUserTagWithTagName:[NSString stringWithFormat:@"%@:%@", self.model.group, self.model.name] taghide:self.model.isHidden tagwatch:self.model.isWatched tagcolor:self.colorShowView.hexColor tagweight:self.weightTextF.text completion:^(QJHenTaiParserStatus status) {
            [self popToMyTagsListViewControllerWithIndex:index status:status];
        }];
    }
    else {
        // 这是修改标签模式
        [[QJHenTaiParser parser] setUserTagWithKey:self.apikey uid:self.apiuid color:self.colorShowView.hexColor taghide:self.model.isHidden tagid:self.model.usertag tagwatch:self.model.isWatched tagweight:self.weightTextF.text completion:^(QJHenTaiParserStatus status) {
            [self popToMyTagsListViewControllerWithIndex:index status:status];
        }];
    }
}

- (void)popToMyTagsListViewControllerWithIndex:(NSInteger)index status:(QJHenTaiParserStatus)status {
    self.view.userInteractionEnabled = YES;
    if (status == QJHenTaiParserStatusSuccess) {
        // 这里退出界面
        [self.navigationController popToViewController:self.navigationController.viewControllers[index] animated:YES];
        // 通知列表刷新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoticationNameChangeTagSuccess object:nil];
    }
    else {
        [self.actity stopAnimating];
        self.navigationItem.rightBarButtonItem = self.doneItem;
    }
}

- (IBAction)buttonAction:(UIButton *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"权重比" message:@"设定标签在相关页面显示的比例,设定在 -99 ~ 99 之间" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"了解更多" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://ehwiki.org/wiki/My_Tags"]];
        [self presentViewController:safariVC animated:YES completion:nil];
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)valueChangeAction:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0: {
            self.model.isNone = YES;
            self.model.isWatched = NO;
            self.model.isHidden = NO;
        }
            break;
        case 1: {
            self.model.isNone = NO;
            self.model.isWatched = YES;
            self.model.isHidden = NO;
        }
            break;
        case 2: {
            self.model.isNone = NO;
            self.model.isWatched = NO;
            self.model.isHidden = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - QJColorPickSliderDelegate, QJColorPickBoardDelegate
- (void)colorPickBoard:(QJColorPickBoard *)colorPickBoard didChangeColor:(UIColor *)color {
    self.colorSlider.showColor = color;
}

- (void)colorPickSlider:(QJColorPickSlider *)colorPickSlider didChangeColor:(UIColor *)color {
    self.colorShowView.showColor = color;
}

#pragma mark - Getter
- (UIBarButtonItem *)doneItem {
    if (!_doneItem) {
        _doneItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e62e", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
    return _doneItem;
}

- (UIBarButtonItem *)freshItem {
    if (!_freshItem) {
        _freshItem = [[UIBarButtonItem alloc] initWithCustomView:self.actity];
    }
    return _freshItem;
}

- (UIActivityIndicatorView *)actity {
    if (!_actity) {
        _actity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _actity.hidesWhenStopped = YES;
    }
    return _actity;
}

@end
