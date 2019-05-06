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

@dynamic maximumPrimaryColumnWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.preferredPrimaryColumnWidthFraction = 1.f;
    self.maximumPrimaryColumnWidth = self.view.bounds.size.width;
}

@end
