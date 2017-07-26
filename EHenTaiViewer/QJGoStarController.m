//
//  QJGoStarController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGoStarController.h"
#import "XHStarRateView.h"
#import "QJHenTaiParser.h"

@interface QJGoStarController ()

@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
- (IBAction)canelAction:(UIBarButtonItem *)sender;
- (IBAction)sendInfoAction:(UIBarButtonItem *)sender;

@end

@implementation QJGoStarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.view.backgroundColor = [UIColor whiteColor];
    self.starView.rateStyle = HalfStar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)canelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendInfoAction:(UIBarButtonItem *)sender {
    NSInteger rating = self.starView.currentScore * 2;
    [self dismissViewControllerAnimated:YES completion:^{
        [[QJHenTaiParser parser] updateStarWithGid:self.gid token:self.token apikey:self.apikey apiuid:self.apiuid rating:rating complete:^(QJHenTaiParserStatus status) {
            
        }];
    }];
}
@end
