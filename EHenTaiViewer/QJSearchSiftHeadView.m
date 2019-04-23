//
//  QJSearchSiftHeadView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJSearchSiftHeadView.h"

@interface QJSearchSiftHeadView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *label; // 说明文本
@property (strong, nonatomic) UIButton *lastButton; // 用于自动布局

@end

@implementation QJSearchSiftHeadView

- (instancetype)initWithKeys:(NSArray *)keys theDelegate:(id<QJSearchSiftHeadViewDelegate>)delegate {
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
    if (self) {
        [self setContent];
        self.keys = keys;
        self.delegate = delegate;
    }
    return self;
}

- (void)setContent {
    [self.contentView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
    }];
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label.mas_right).offset(10);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-20);
    }];
}

// Control Method
- (void)clickTagButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickTagActionWithHeadView:index:)]) {
        [self.delegate didClickTagActionWithHeadView:self index:button.tag - 1000];
    }
}

#pragma mark - Setter
- (void)setKeys:(NSArray *)keys {
    _keys = keys;
    
    self.hidden = !keys.count;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < keys.count; i++) {
        NSString *title = keys[i];
        NSString *pre = [[title componentsSeparatedByString:@"-"].firstObject substringToIndex:1];
        NSString *next = [title componentsSeparatedByString:@"-"].lastObject;
        UIButton *button = [self p_makeTagButtonWithTitle:[NSString stringWithFormat:@"%@:%@", pre, next] index:i];
        [self.scrollView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@20);
            make.centerY.equalTo(self.scrollView);
            if (self.lastButton) {
                make.left.equalTo(self.lastButton.mas_right).offset(10);
            }
            else {
                make.left.equalTo(self.scrollView);
            }
        }];
        self.lastButton = button;
    }
    [self.lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.scrollView);
    }];
    
    self.lastButton = nil;
}

- (UIButton *)p_makeTagButtonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [button setTitle:[NSString stringWithFormat:@" %@ × ", title] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = DEFAULT_COLOR;
    button.layer.cornerRadius = 3.f;
    button.tag = 1000 + index;
    [button addTarget:self action:@selector(clickTagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (nil == _scrollView) {
        _scrollView = [UIScrollView new];
    }
    return _scrollView;
}

- (UILabel *)label {
    if (nil == _label) {
        _label = [UILabel new];
        _label.text = @"高级筛选:";
        _label.font = [UIFont systemFontOfSize:12.f];
        _label.textColor = [UIColor lightGrayColor];
        }
    return _label;
}

@end
