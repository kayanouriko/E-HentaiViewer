//
//  QJScoreView.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJScoreView.h"
#import "QJStarView.h"

@interface QJScoreView ()

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarLabel;
@property (weak, nonatomic) IBOutlet UILabel *coverLabel;

@property (weak, nonatomic) IBOutlet QJStarView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starInfoLabel;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJScoreView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.favoritesLabel.text = NSLocalizedString(@"favorites", nil);
    self.shareLabel.text = NSLocalizedString(@"share", nil);
    self.similarLabel.text = NSLocalizedString(@"similar_gallery", nil);
    self.coverLabel.text = NSLocalizedString(@"search_cover", nil);
    
    self.starView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popScoreWindows:)];
    [self.starView addGestureRecognizer:tap];
}

- (void)popScoreWindows:(UITapGestureRecognizer *)tap {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"grade", nil) message:@"\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    UILabel *starLabel = [UILabel new];
    starLabel.textAlignment = NSTextAlignmentCenter;
    starLabel.text = [self getGradeInfoWithScore:2.5];;
    [alertController.view addSubview:starLabel];
    
    QJStarView *starView = [[QJStarView alloc] init];
    starView.canChangeStar = YES;
    [alertController.view addSubview:starView];
    
    starView.translatesAutoresizingMaskIntoConstraints = NO;
    starLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [alertController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[starView(200)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(starView)]];
    [alertController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[starLabel]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(starLabel)]];
    //55
    [alertController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-55-[starLabel(21)]-10-[starView(30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(starLabel,starView)]];
    [alertController.view addConstraint:[NSLayoutConstraint constraintWithItem:starView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [starView refreshStarWithCount:2.5 width:40];
    starView.touchBlock = ^(CGFloat score){
        starLabel.text = [self getGradeInfoWithScore:score];
    };
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [[self viewController] presentViewController:alertController animated:YES completion:nil];
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

- (void)refreshUI:(NSDictionary *)dict {
    NSString *scoreAvg = dict[@"scoreAvg"];
    self.starInfoLabel.text = [NSString stringWithFormat:@"%@ / %@",dict[@"scorePerson"],scoreAvg];
    NSArray *array = [scoreAvg componentsSeparatedByString:@" "];
    [self.starView refreshStarWithCount:[array.lastObject floatValue] width:50.f];
}

- (IBAction)btnAction:(UIButton *)sender {
    ScoreViewType status = sender.tag - 1200;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickBtnWithStatus:)]) {
        [self.delegate didClickBtnWithStatus:status];
    }
}

- (NSString *)getGradeInfoWithScore:(CGFloat)score {
    NSString *scoreInfo = @"";
    if (score < 0.5) {
        //1
        scoreInfo = @"rank1";
    }
    else if (score >= 0.5 && score < 1) {
        //2
        scoreInfo = @"rank2";
    }
    else if (score >= 1 && score < 1.5) {
        //3
        scoreInfo = @"rank3";
    }
    else if (score >= 1.5 && score < 2) {
        //4
        scoreInfo = @"rank4";
    }
    else if (score >= 2 && score < 2.5) {
        //5
        scoreInfo = @"rank5";
    }
    else if (score >= 2.5 && score < 3) {
        //6
        scoreInfo = @"rank6";
    }
    else if (score >= 3 && score < 3.5) {
        //7
        scoreInfo = @"rank7";
    }
    else if (score >= 3.5 && score < 4) {
        //8
        scoreInfo = @"rank8";
    }
    else if (score >= 4 && score < 4.5) {
        //9
        scoreInfo = @"rank9";
    }
    else if (score >= 4.5 && score < 5) {
        //10
        scoreInfo = @"rank10";
    }
    else {
        scoreInfo = @"rank10";
    }
    return NSLocalizedString(scoreInfo, nil);
}

@end
