//
//  QJRankingUploadCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJRankingUploadCell.h"
#import "QJToplistUploaderItem.h"
#import "NSString+StringHeight.h"
#import "QJGalleryItem.h"
#import "QJSearchViewController.h"

@interface QJRankingUploadCell ()

@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploaderBtn;
@property (weak, nonatomic) IBOutlet UIView *underLine;

- (IBAction)jumpAction:(UIButton *)sender;

@end

@implementation QJRankingUploadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)refreshCellWithModel:(QJToplistUploaderItem *)model index:(NSInteger)index  isHidden:(BOOL)isHidden {
    [self.uploaderBtn setTitle:model.name forState:UIControlStateNormal];
    self.rankingLabel.text = [NSString stringWithFormat:@"#%ld", (long)index];
    self.underLine.hidden = isHidden;
}

- (IBAction)jumpAction:(UIButton *)sender {
    NSString *uploader = [self.uploaderBtn titleForState:UIControlStateNormal];
    NSString *searchKey = [NSString stringWithFormat:@"uploader:%@", uploader];
    NSString *url = [NSString stringWithFormat:@"uploader/%@/", [uploader urlEncode]];
    QJGalleryTagItem *model = [QJGalleryTagItem new];
    model.searchKey = searchKey;
    model.url = url;
    
    QJSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([QJSearchViewController class])];
    vc.model = model;
    [[self viewController].navigationController pushViewController:vc animated:YES];
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
