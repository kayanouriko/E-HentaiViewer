//
//  QJBrowerSystemInfoShowView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/10.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJBrowerSystemInfoShowView.h"
#import "QJNetworkTool.h"
#import "Reachability.h"

@interface QJBrowerSystemInfoShowView ()

@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkLabel;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation QJBrowerSystemInfoShowView

- (void)awakeFromNib {
    [super awakeFromNib];
    // 这里调用
    [self updateInfo];
    // 这里启动计时器开始统计全部数据
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf updateInfo];
    }];
    
    [self reachabilityChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged)name:kReachabilityChangedNotification object:nil];
}

- (void)updateInfo {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    UIDeviceBatteryState status = [UIDevice currentDevice].batteryState;
    NSString *count = @"20";
    if (deviceLevel > 0.9) {
        count = @"100";
    }
    else if (deviceLevel > 0.8) {
        count = @"90";
    }
    else if (deviceLevel > 0.6) {
        count = @"80";
    }
    else if (deviceLevel > 0.5) {
        count = @"60";
    }
    else if (deviceLevel > 0.3) {
        count = @"50";
    }
    else if (deviceLevel > 0.2) {
        count = @"30";
    }
    NSInteger level = deviceLevel * 100;
    self.batteryLabel.text = [NSString stringWithFormat:@"%ld%%", level];
    
    NSString *imageName = [NSString stringWithFormat:status == UIDeviceBatteryStateCharging ? @"ic_battery_charging_%@" : @"ic_battery_%@", count];
    self.batteryImageView.image = [UIImage imageNamed:imageName];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    self.timeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)reachabilityChanged {
    if ([[QJNetworkTool shareTool] isEnableNetwork]) {
        self.networkLabel.text = [[QJNetworkTool shareTool] isEnableMobleNetwork] ? @"移动数据" : @"WIFI";
    } else {
        self.networkLabel.text = @"None";
    }
}

- (void)dealloc {
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
