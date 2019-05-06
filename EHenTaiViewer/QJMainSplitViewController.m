//
//  QJMainSplitViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/6.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJMainSplitViewController.h"

@interface QJMainSplitViewController ()

@end

@implementation QJMainSplitViewController

@dynamic maximumPrimaryColumnWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    self.maximumPrimaryColumnWidth = 80.f;
    self.splitViewController.maximumPrimaryColumnWidth = self.maximumPrimaryColumnWidth;
}

@end
