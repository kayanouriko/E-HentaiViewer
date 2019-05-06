//
//  QJContentSplitViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/6.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJContentSplitViewController.h"

@interface QJContentSplitViewController ()

@end

@implementation QJContentSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.preferredPrimaryColumnWidthFraction = 0.4f;
}

@end
