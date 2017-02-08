//
//  QJTopButtonView.m
//  ExReadViewer
//
//  Created by QinJ on 2017/2/2.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJTopButtonView.h"

@interface QJTopButtonView ()

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJTopButtonView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)btnAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", nil) message:NSLocalizedString(@"select_scene", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ehentaiAction = [UIAlertAction actionWithTitle:@"EHentai" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![self.titleLabel.text isEqualToString:@"EHentai"]) {
            [self updateResourceWithName:@"EHentai"];
        }
    }];
    [alertController addAction:ehentaiAction];
    UIAlertAction *exhentaiAction = [UIAlertAction actionWithTitle:@"ExHentai" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![self.titleLabel.text isEqualToString:@"ExHentai"]) {
            [self updateResourceWithName:@"ExHentai"];
        }
    }];
    [alertController addAction:exhentaiAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [[self viewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)updateResourceWithName:(NSString *)title {
    self.titleLabel.text = title;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickChannelWithName:)]) {
        [self.delegate didClickChannelWithName:title];
    }
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

@end
