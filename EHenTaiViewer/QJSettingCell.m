//
//  QJSettingCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingCell.h"
#import "QJProtectTool.h"
#import "QJTouchIDViewController.h"
#import "QJPasswordViewController.h"
#import "QJHenTaiParser.h"

@interface QJSettingCell ()

@property (nonatomic, assign) QJSettingCellMode mode;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

- (IBAction)valueChange:(UISwitch *)sender;

@end

@implementation QJSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mode = QJSettingCellModeNormal;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-  (void)refreshUI:(NSArray *)array {
    NSString *title = array.firstObject;
    QJSettingCellMode mode = [array[1] integerValue];
    self.titleLabel.text = title;
    NSString *subTitle = array.lastObject;
    self.subTitleLabel.text = subTitle;
    self.subTitleLabel.hidden = !subTitle.length;
    
    self.mode = mode;
    if ([title isEqualToString:@"是否允许移动数据浏览"]) {
        self.switchBtn.on = [NSObjForKey(@"WatchMode") boolValue];
    }
    if ([title isEqualToString:@"应用启动保护"]) {
        self.switchBtn.on = [NSObjForKey(@"ProtectMode") boolValue];
    }
    if ([title isEqualToString:@"ExHentai浏览"]) {
        self.switchBtn.on = [NSObjForKey(@"ExHentaiStatus") boolValue];
    }
}

- (IBAction)valueChange:(UISwitch *)sender {
    if ([self.titleLabel.text isEqualToString:@"是否允许移动数据浏览"]) {
        NSObjSetForKey(@"WatchMode", @(sender.on));
    }
    if ([self.titleLabel.text isEqualToString:@"应用启动保护"]) {
        if (sender.on) {
            if ([[QJProtectTool shareTool] isEnableTouchID]) {
                [[QJProtectTool shareTool] showTouchID:^(QJProtectToolStatus status) {
                    if (status == QJProtectToolStatusCannel) {
                        [sender setOn:NO animated:YES];
                    }
                }];
            }
            else {
                
            }
        }
        else {
            //删除对应信息
        }
        NSObjSetForKey(@"ProtectMode", @(sender.on));
        NSObjSynchronize();
    }
    if ([self.titleLabel.text isEqualToString:@"ExHentai浏览"]) {
        if (sender.on && ![[QJHenTaiParser parser] checkCookie]) {
            ToastError(nil, @"请先登陆账号");
            sender.on = NO;
            return;
        }
        NSObjSetForKey(@"ExHentaiStatus", @(sender.on));
    }
    NSObjSynchronize();
    
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (UITableView *)tableView {
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (UITableView *)tableView;
}

#pragma mark -setter
- (void)setMode:(QJSettingCellMode)mode {
    _mode = mode;
    if (_mode == QJSettingCellModeNormal) {
        self.switchBtn.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else if (_mode == QJSettingCellModeSwitch) {
        self.switchBtn.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

@end
