//
//  FFBaseToastView.m
//  FFToastDemo
//
//  Created by 李峰峰 on 2017/2/23.
//  Copyright © 2017年 李峰峰. All rights reserved.
//

#import "FFBaseToastView.h"

#define VERTICAL_SPACE 8.f
#define HORIZONTAL_SPACE 8.f
#define BOTTOM_SPACE 80.f
#define BOTTOM_HORIZONTAL_MAX_SPACE 20.f


@interface FFBaseToastView()

//Toast图标ImageView
@property(strong,nonatomic)UIImageView *iconImageView;
//Toast标题Label
@property(strong,nonatomic)UILabel *titleLabel;
//Toast内容Label
@property(strong,nonatomic)UILabel *messageLabel;

@property (nonatomic, copy) NSString* titleString;
@property (nonatomic, copy) NSString* messageString;
@property (strong, nonatomic) UIImage* iconImage;

@property (assign, nonatomic) CGSize titleLabelSize;
@property (assign, nonatomic) CGSize messageLabelSize;
@property (assign, nonatomic) CGSize iconImageSize;
@property (assign, nonatomic) CGRect toastViewFrame;


@property handler handler;

@end


@implementation FFBaseToastView

static NSMutableArray* toastArray = nil;


- (instancetype)initToastWithTitle:(NSString *)title message:(NSString *)message iconImage:(UIImage*)iconImage{
    
    
    if (!toastArray) {
        toastArray = [NSMutableArray new];
    }
    
    self.titleString = title;
    self.messageString = message;
    
    if (iconImage == nil) {
        if (self.toastType == FFToastPositionDefault) {
            self.iconImage = nil;
        }
    }else{
        self.iconImage = iconImage;
    }
    self.iconImageSize = self.iconImage == nil ? CGSizeZero : CGSizeMake(35.f, 35.f);
    
    
    return [self init];
    
}




-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.iconImageView = [[UIImageView alloc]init];
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc]init];
        [self addSubview:self.titleLabel];
        
        self.messageLabel = [[UILabel alloc]init];
        [self addSubview:self.messageLabel];
        
    }
    
    return self;
}

/**
 设置Toast的frame、属性及内部控件的属性等
 */
-(void)layoutToastView{
    
    //设置子控件属性
    self.titleLabel.textColor = _titleTextColor;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = _titleFont;
    
    self.messageLabel.textColor = _messageTextColor;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = _messageFont;

    self.alpha = _toastAlpha;
    self.layer.cornerRadius = _toastCornerRadius;
    self.layer.masksToBounds = YES;
    
    //根据toastType设置背景色、icon
    switch (self.toastType) {
        case FFToastTypeDefault: {
            self.toastBackgroundColor = [UIColor darkGrayColor];
            break;
        }
        case FFToastTypeSuccess: {
            self.toastBackgroundColor = [UIColor colorWithRed:31.f/255.f green:177.f/255.f blue:138.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [UIImage imageWithName:@"fftoast_success"];
            }
            break;
        }
        case FFToastTypeError: {
            self.toastBackgroundColor = [UIColor colorWithRed:255.f/255.f green:91.f/255.f blue:65.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [UIImage imageWithName:@"fftoast_error"];
            }
            break;
        }
        case FFToastTypeWarning: {
            self.toastBackgroundColor = [UIColor colorWithRed:255.f/255.f green:134.f/255.f blue:0.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [UIImage imageWithName:@"fftoast_warning"];
            }
            break;
        }
        case FFToastTypeInfo: {
            self.toastBackgroundColor = [UIColor colorWithRed:75.f/255.f green:107.f/255.f blue:122.f/255.f alpha:1.f];
            if (!_iconImage) {
                self.iconImage = [UIImage imageWithName:@"fftoast_info"];
            }
            break;
        }
            
        default:
            break;
    }

    
    self.iconImageSize = self.iconImage == nil ? CGSizeZero : CGSizeMake(35.f, 35.f);
    
    

    //上滑消失
    if (_toastPosition != FFToastPositionBottom && _toastPosition != FFToastPositionBottomWithFillet) {
        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeGesture];
        
    }
    
     self.toastViewFrame = [self toastViewFrame];
    
    switch (self.toastPosition) {
        case FFToastPositionDefault: {
            self.frame = CGRectMake(_toastViewFrame.origin.x, -_toastViewFrame.size.height, _toastViewFrame.size.width, _toastViewFrame.size.height);
            break;
        }
        case FFToastPositionBelowStatusBar: {
            self.frame = CGRectMake(_toastViewFrame.origin.x, -(_toastViewFrame.size.height + STATUSBAR_HEIGHT), _toastViewFrame.size.width, _toastViewFrame.size.height);
            break;
        }
        case FFToastPositionBelowStatusBarWithFillet: {
            self.frame = CGRectMake(_toastViewFrame.origin.x, -(_toastViewFrame.size.height + STATUSBAR_HEIGHT), _toastViewFrame.size.width, _toastViewFrame.size.height);
            break;
        }
        case FFToastPositionBottom: {
            self.frame = _toastViewFrame;
            self.alpha = 0.f;
            break;
        }
        case FFToastPositionBottomWithFillet: {
            self.frame = _toastViewFrame;
            self.alpha = 0.f;
            break;
        }
        default:
            break;
    }
    
    
    
}




/**
 计算ToastView的frame
 
 @return ToastView的frame
 */
-(CGRect)toastViewFrame{
    
    CGFloat textMaxWidth = 0;
    if (self.iconImage == nil) {
        textMaxWidth = SCREEN_WIDTH - 2*HORIZONTAL_SPACE;
    }else{
        textMaxWidth = SCREEN_WIDTH - _iconImageSize.width - 3*HORIZONTAL_SPACE;
    }
    
    if (self.toastPosition == FFToastPositionBelowStatusBar || self.toastPosition == FFToastPositionBelowStatusBarWithFillet) {
        textMaxWidth -= 2*HORIZONTAL_SPACE;
    }else if(self.toastPosition == FFToastPositionBottom || self.toastPosition == FFToastPositionBottomWithFillet){
        textMaxWidth -= 2*BOTTOM_HORIZONTAL_MAX_SPACE;
    }
    
    self.titleLabelSize = [NSString sizeForString:_titleString font:_titleFont maxWidth:textMaxWidth];
    self.messageLabelSize = [NSString sizeForString:_messageString font:_messageFont maxWidth:textMaxWidth];
    
    
    CGFloat toastViewX = 0;
    CGFloat toastViewY = 0;
    CGFloat toastViewW = 0;
    CGFloat toastViewH = 0;
    if(self.iconImage == nil){
        //没有图标
        if (self.titleString == nil) {
            toastViewH = self.messageLabelSize.height + 2 * VERTICAL_SPACE;
        }else{
            toastViewH = self.titleLabelSize.height + self.messageLabelSize.height + 3 * VERTICAL_SPACE;
        }
        
    }else{
        //有图标
        CGFloat toastViewHTemp = 0;
        CGFloat toastViewHTemp2 = self.iconImageSize.height + 2 * VERTICAL_SPACE;
        if (self.titleString == nil) {
            toastViewHTemp = self.messageLabelSize.height + 2 * VERTICAL_SPACE;
        }else{
            toastViewHTemp = self.titleLabelSize.height + self.messageLabelSize.height + 3 * VERTICAL_SPACE;
        }
        toastViewH = toastViewHTemp > toastViewHTemp2 ? toastViewHTemp : toastViewHTemp2;
    }
    
    
    
    switch (self.toastPosition) {
        case FFToastPositionDefault: {
            toastViewW = SCREEN_WIDTH;
            toastViewH += STATUSBAR_HEIGHT;
            break;
        }
        case FFToastPositionBelowStatusBar: {
            toastViewY = STATUSBAR_HEIGHT;
            toastViewW = SCREEN_WIDTH;
            break;
        }
        case FFToastPositionBelowStatusBarWithFillet: {
            toastViewX = HORIZONTAL_SPACE;
            toastViewY = STATUSBAR_HEIGHT;
            toastViewW = SCREEN_WIDTH - 2*HORIZONTAL_SPACE;
            
            if (self.toastCornerRadius == 0) {
                self.toastCornerRadius = 5.f;
            }
            self.layer.cornerRadius = _toastCornerRadius;
            self.layer.masksToBounds = YES;
            
            break;
        }
        case FFToastPositionBottom: {
            
            toastViewW = _titleLabelSize.width > _messageLabelSize.width ? _titleLabelSize.width + 2* HORIZONTAL_SPACE : _messageLabelSize.width + 2* HORIZONTAL_SPACE;
            
            if (self.iconImage != nil) {
                toastViewW += _iconImageSize.width + HORIZONTAL_SPACE;
                
            }
            
            toastViewX = (SCREEN_WIDTH - toastViewW)/2;
            toastViewY = SCREEN_HEIGHT - toastViewH - BOTTOM_SPACE;
            
            
            break;
        }
        case FFToastPositionBottomWithFillet: {
            
            toastViewW = _titleLabelSize.width > _messageLabelSize.width ? _titleLabelSize.width + 2* HORIZONTAL_SPACE : _messageLabelSize.width + 2* HORIZONTAL_SPACE;
            
            
            
            if (self.iconImage != nil) {
                toastViewW += _iconImageSize.width + HORIZONTAL_SPACE;
                
                if ((_titleLabelSize.height + _messageLabelSize.height + 3*HORIZONTAL_SPACE) > _iconImageSize.height + 2*HORIZONTAL_SPACE) {
                    toastViewH = _titleLabelSize.height + _messageLabelSize.height + 3*HORIZONTAL_SPACE;
                }else{
                    toastViewH = _iconImageSize.height + 2*HORIZONTAL_SPACE;
                }
                
            }
            
            toastViewX = (SCREEN_WIDTH - toastViewW)/2;
            toastViewY = SCREEN_HEIGHT - toastViewH - BOTTOM_SPACE;
            
            if (self.toastCornerRadius == 0) {
                self.toastCornerRadius = 5.f;
            }
            self.layer.cornerRadius = _toastCornerRadius;
            self.layer.masksToBounds = YES;
            
            
            break;
        }
        default:
            break;
    }
    
    return CGRectMake(toastViewX, toastViewY, toastViewW, toastViewH);
}






-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat tempStatusBarHeight = 0;
    if (self.toastPosition == FFToastPositionDefault) {
        tempStatusBarHeight = STATUSBAR_HEIGHT;
    }
    
    CGFloat iconImageViewX = HORIZONTAL_SPACE;
    CGFloat iconImageViewY = (_toastViewFrame.size.height - self.iconImageSize.width - tempStatusBarHeight)/2 + tempStatusBarHeight;
    CGFloat iconImageViewW = self.iconImageSize.width;
    CGFloat iconImageViewH = self.iconImageSize.height;
    self.iconImageView.frame = CGRectMake(iconImageViewX, iconImageViewY, iconImageViewW, iconImageViewH);
    
    CGFloat titleLabelX = CGSizeEqualToSize(self.iconImageSize, CGSizeZero) ? HORIZONTAL_SPACE : iconImageViewX + iconImageViewW + HORIZONTAL_SPACE;
    CGFloat titleLabelY = VERTICAL_SPACE + tempStatusBarHeight;
    CGFloat titleLabelW = self.titleLabelSize.width;
    CGFloat titleLabelH = self.titleLabelSize.height;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    CGFloat messageLabelX = titleLabelX;
    CGFloat messageLabelY = 0;
    if (self.titleString == nil) {
        messageLabelY = (self.toastViewFrame.size.height - self.messageLabelSize.height - tempStatusBarHeight)/2 + tempStatusBarHeight;
    }else{
        messageLabelY = titleLabelY + titleLabelH + VERTICAL_SPACE;
    }
    CGFloat messageLabelW = self.messageLabelSize.width;
    CGFloat messageLabelH = self.messageLabelSize.height;
    self.messageLabel.frame = CGRectMake(messageLabelX, messageLabelY, messageLabelW, messageLabelH);
    
    [self loadViewData];
    
}

/**
 加载各View数据
 */
-(void)loadViewData{
    self.iconImageView.image = self.iconImage;
    self.titleLabel.text = self.titleString;
    self.messageLabel.text = self.messageString;
    if (_toastBackgroundColor != nil) {
        self.backgroundColor = _toastBackgroundColor;
    }
    
}

/**
 显示一个Toast
 */
- (void)show{
    
    [self layoutToastView];
    
    //显示之前先把之前的移除
    if ([toastArray count] != 0) {
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
    }
    
    @synchronized (toastArray) {
        
        UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
        [windowView addSubview:self];
        
        [UIView animateWithDuration:0.5f
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.frame = _toastViewFrame;
                             self.alpha = _toastAlpha;
                         } completion:^(BOOL finished) {
                             
                         }];
        
        [toastArray addObject:self];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:_duration];
        
    }
    
    
}

/**
 显示一个Toast并添加点击回调
 
 @param handler 回调
 */
- (void)show:(handler)handler{
    [self show];
    if (handler) {
        _handler = handler;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionWithHandler)];
        [self addGestureRecognizer:tapGesture];
    }
}


- (void)tapActionWithHandler {
    if (_handler) {
        _handler();
    }
    [self dismiss];
}

/**
 隐藏一个Toast
 */
-(void)dismiss{
    
    if (toastArray && [toastArray count] > 0) {
        @synchronized (toastArray) {
            
            FFBaseToastView* toast = toastArray[0];
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:toast];
            [toastArray removeObject:toast];
            
            if (self.dismissToastAnimated == YES && _toastPosition != FFToastPositionBottom && _toastPosition != FFToastPositionBottomWithFillet) {
                
                CGFloat tempStatusBarHeight = 0;
                if (self.toastPosition == FFToastPositionDefault) {
                    tempStatusBarHeight = STATUSBAR_HEIGHT;
                }
                
                [UIView animateWithDuration:0.2f
                                 animations:^{
                                     toast.alpha = 0.f;
                                     self.frame = CGRectMake(_toastViewFrame.origin.x, -(_toastViewFrame.size.height + tempStatusBarHeight), _toastViewFrame.size.width, _toastViewFrame.size.height);
                                 } completion:^(BOOL finished) {
                                     [toast removeFromSuperview];
                                 }];
                
                
            }else{
                [UIView animateWithDuration:0.2f
                                 animations:^{
                                     toast.alpha = 0.f;
                                 } completion:^(BOOL finished) {
                                     [toast removeFromSuperview];
                                 }];
                
            }
            
        }
    }
    
    
}





@end
