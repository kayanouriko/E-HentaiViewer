//
//  QJTagView.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJTagView.h"
#import "NSString+StringHeight.h"
#import "QJHenTaiParser.h"
#import "QJGalleryItem.h"
#import "QJSearchViewController.h"

@implementation QJTagView {
    CGFloat _leftLabelWidth;
    NSInteger _buttonCount;
    NSArray *_rightArr;
}

- (void)refreshUI:(NSArray *)array isCN:(BOOL)isCN {
    NSString *leftStr = array.firstObject;
    _leftLabelWidth = [leftStr StringWidthWithFontSize:AppFontContentStyle()] + 20;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _leftLabelWidth, 25)];
    leftLabel.text = leftStr;
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = AppFontContentStyle();
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = [UIColor purpleColor];
    leftLabel.layer.cornerRadius = 12.5f;
    leftLabel.clipsToBounds = YES;
    [self addSubview:leftLabel];
    
    _rightArr = array[1];
    _buttonCount = _rightArr.count;
    NSInteger i = 0;
    for (QJGalleryTagItem *model in _rightArr) {
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:isCN ? model.cname : model.name forState:UIControlStateNormal];
        addBtn.frame = CGRectMake(isCN ? model.buttonXCN : model.buttonX, isCN ? model.buttonYCN : model.buttonY, isCN ? model.buttonWidthCN : model.buttonWidth, 25);
        addBtn.titleLabel.font = AppFontContentStyle();
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBtn.backgroundColor = [UIColor colorWithRed:0.098 green:0.584 blue:0.533 alpha:1.00];
        addBtn.tag = i + 1000;
        i++;
        addBtn.layer.cornerRadius = 12.5f;
        addBtn.clipsToBounds = YES;
        [addBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
    }
}

- (void)click:(UIButton *)button {
    QJSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([QJSearchViewController class])];
    QJGalleryTagItem *model = _rightArr[button.tag - 1000];
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
