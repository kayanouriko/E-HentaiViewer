/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */


#import "HRColorMapView.h"
#import "HRHSVColorUtil.h"
#import "UIImage+CoreGraphics.h"
#import "HRColorCursor.h"

@interface HRColorMapView () {
    UIColor *_color;
    CGFloat _brightness;
    NSNumber *_saturationUpperLimit;
    HRColorCursor *_colorCursor;
    NSOperationQueue *_initializeQueue;
    BOOL _didLayoutSubview;
}

@property (atomic, strong) CALayer *colorMapLayer; // brightness 1.0
@property (atomic, strong) CALayer *colorMapBackgroundLayer; // brightness 0 (= black)

@end

@implementation HRColorMapView {
    CALayer *_lineLayer;
}
@synthesize color = _color;
@synthesize saturationUpperLimit = _saturationUpperLimit;

#pragma mark - generate color map image

+ (UIImage *)colorMapImageWithSize:(CGSize)size
                          tileSize:(CGFloat)tileSize
              saturationUpperLimit:(CGFloat)saturationUpperLimit {

    int pixelCountX = (int) (size.width / tileSize);
    int pixelCountY = (int) (size.height / tileSize);
    CGSize colorMapSize = CGSizeMake(pixelCountX * tileSize, pixelCountY * tileSize);

    void(^renderToContext)(CGContextRef, CGRect) = ^(CGContextRef context, CGRect rect) {

        CGFloat margin = 0;

        HRHSVColor pixelHsv;
        pixelHsv.s = pixelHsv.v = 1;
        for (int i = 0; i < pixelCountX; ++i) {
            CGFloat pixelX = (CGFloat) i / pixelCountX;

            pixelHsv.h = pixelX;
            UIColor *color;
            color = [UIColor colorWithHue:pixelHsv.h
                               saturation:pixelHsv.s
                               brightness:pixelHsv.v
                                    alpha:1];
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context, CGRectMake(tileSize * i + rect.origin.x, rect.origin.y, tileSize - margin, CGRectGetHeight(rect)));
        }

        CGFloat top;
        for (int j = 0; j < pixelCountY; ++j) {
            top = tileSize * j + rect.origin.y;
            CGFloat pixelY = (CGFloat) j / (pixelCountY - 1);
            CGFloat alpha = (pixelY * saturationUpperLimit);
            CGContextSetRGBFillColor(context, 1, 1, 1, alpha);
            CGContextFillRect(context, CGRectMake(rect.origin.x, top, CGRectGetWidth(rect), tileSize - margin));
        }
    };

    return [UIImage hr_imageWithSize:colorMapSize renderer:renderToContext];
}

+ (UIImage *)backgroundImageWithSize:(CGSize)size
                            tileSize:(CGFloat)tileSize {

    int pixelCountX = (int) (size.width / tileSize);
    int pixelCountY = (int) (size.height / tileSize);
    CGSize colorMapSize = CGSizeMake(pixelCountX * tileSize, pixelCountY * tileSize);
    void(^renderBackgroundToContext)(CGContextRef, CGRect) = ^(CGContextRef context, CGRect rect) {
        CGFloat margin = 0;

        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, rect);

        CGFloat height;

        CGContextSetGrayFillColor(context, 0, 1.0);
        for (int j = 0; j < pixelCountY; ++j) {
            height = tileSize * j + rect.origin.y;
            for (int i = 0; i < pixelCountX; ++i) {
                CGContextFillRect(context, CGRectMake(tileSize * i + rect.origin.x, height, tileSize - margin, tileSize - margin));
            }
        }
    };

    return [UIImage hr_imageWithSize:colorMapSize
                            renderer:renderBackgroundToContext];
}

#pragma mark - init

+ (HRColorMapView *)colorMapWithFrame:(CGRect)frame {
    return [[HRColorMapView alloc] initWithFrame:frame saturationUpperLimit:0.95];
}

+ (HRColorMapView *)colorMapWithFrame:(CGRect)frame saturationUpperLimit:(CGFloat)saturationUpperLimit {
    return [[HRColorMapView alloc] initWithFrame:frame saturationUpperLimit:saturationUpperLimit];
}

- (id)init {
    return [self initWithFrame:CGRectZero saturationUpperLimit:0.95];
}

- (id)initWithFrame:(CGRect)frame saturationUpperLimit:(CGFloat)saturationUpperLimit {
    self = [super initWithFrame:frame];
    if (self) {
        self.saturationUpperLimit = @(saturationUpperLimit);
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)_init {
    self.alpha = 0;
    _didLayoutSubview = NO;
    self.brightness = 0.5;
    self.backgroundColor = [UIColor whiteColor];

    CGFloat lineWidth = 1.f / [[UIScreen mainScreen] scale];
    _lineLayer = [[CALayer alloc] init];
    _lineLayer.backgroundColor = [[UIColor colorWithWhite:0.7 alpha:1] CGColor];
    _lineLayer.frame = CGRectMake(0, -lineWidth, CGRectGetWidth(self.frame), lineWidth);
    [self.layer addSublayer:_lineLayer];

    // タイルの中心にくるようにずらす
    CGPoint cursorOrigin = CGPointMake(
            -([HRColorCursor cursorSize].width - _tileSize.floatValue) / 2.0f,
            -([HRColorCursor cursorSize].height - _tileSize.floatValue) / 2.0f);
    _colorCursor = [HRColorCursor colorCursorWithPoint:cursorOrigin];
    [self addSubview:_colorCursor];

    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer;
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];

    _initializeQueue = [[NSOperationQueue alloc] init];
    [_initializeQueue setSuspended:YES];
    [_initializeQueue addOperationWithBlock:^{
        [self createColorMapLayer];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.layer insertSublayer:self.colorMapBackgroundLayer atIndex:0];
            [self.layer insertSublayer:self.colorMapLayer atIndex:1];
            self.colorMapLayer.opacity = self.brightness;
            [self invalidateIntrinsicContentSize];

            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.alpha = 1;
                             }];
        });
    }];
}

#pragma mark - layout


- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateColorCursor];
    _didLayoutSubview = YES;
    [_initializeQueue setSuspended:!self.isAbleToCreateColorMap];
}

- (CGSize)intrinsicContentSize {
    CGFloat tileSize = self.tileSize.floatValue;
    int pixelCountX = (int) (CGRectGetWidth(self.frame) / tileSize);
    int pixelCountY = (int) (CGRectGetHeight(self.frame) / tileSize);
    CGSize colorMapSize = CGSizeMake(pixelCountX * tileSize, pixelCountY * tileSize);
    return colorMapSize;
}

#pragma mark color map

- (BOOL)isAbleToCreateColorMap {
    if (!_didLayoutSubview) {
        return NO;
    }
    if (CGRectIsNull(self.frame) || CGRectIsEmpty(self.frame) || CGRectEqualToRect(self.frame, CGRectZero)) {
        return NO;
    }
    if (!self.saturationUpperLimit) {
        return NO;
    }
    if (!self.tileSize) {
        return NO;
    }
    return YES;
}

- (void)setSaturationUpperLimit:(NSNumber *)saturationUpperLimit {
    _saturationUpperLimit = saturationUpperLimit;
    [_initializeQueue setSuspended:!self.isAbleToCreateColorMap];
}

- (void)setTileSize:(NSNumber *)tileSize {
    _tileSize = tileSize;
    [_initializeQueue setSuspended:!self.isAbleToCreateColorMap];
    CGRect cursorFrame = _colorCursor.frame;

    cursorFrame.origin = CGPointMake(
            -([HRColorCursor cursorSize].width - _tileSize.floatValue) / 2.0f,
            -([HRColorCursor cursorSize].height - _tileSize.floatValue) / 2.0f);
    _colorCursor.frame = cursorFrame;
}

- (void)createColorMapLayer {
    if (self.colorMapLayer) {
        return;
    }

    UIImage *colorMapImage;
    colorMapImage = [HRColorMapView colorMapImageWithSize:self.frame.size
                                                 tileSize:self.tileSize.floatValue
                                     saturationUpperLimit:self.saturationUpperLimit.floatValue];

    UIImage *backgroundImage;
    backgroundImage = [HRColorMapView backgroundImageWithSize:self.frame.size
                                                     tileSize:self.tileSize.floatValue];

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue
                     forKey:kCATransactionDisableActions];

    self.colorMapLayer = [[CALayer alloc] initWithLayer:self.layer];
    self.colorMapLayer.frame = (CGRect) {.origin = CGPointZero, .size = colorMapImage.size};
    self.colorMapLayer.contents = (id) colorMapImage.CGImage;
    self.colorMapBackgroundLayer = [[CALayer alloc] initWithLayer:self.layer];
    self.colorMapBackgroundLayer.frame = (CGRect) {.origin = CGPointZero, .size = backgroundImage.size};
    self.colorMapBackgroundLayer.contents = (id) backgroundImage.CGImage;

    [CATransaction commit];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self updateColorCursor];
}

- (CGFloat)brightness {
    return _brightness;
}

- (void)setBrightness:(CGFloat)brightness {
    _brightness = brightness;
    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.colorMapLayer.opacity = _brightness;
    [CATransaction commit];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
        [self update:tapPoint];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            if ([_colorCursor respondsToSelector:@selector(setEditing:)]) {
                [_colorCursor setEditing:NO];
            }
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
        [self update:tapPoint];
        if ([_colorCursor respondsToSelector:@selector(setEditing:)]) {
            [_colorCursor setEditing:YES];
        }
    }
}

- (void)update:(CGPoint)tapPoint {
    if (!CGRectContainsPoint((CGRect) {.origin = CGPointZero, .size = self.frame.size}, tapPoint)) {
        return;
    }
    int pixelCountX = (int) (self.frame.size.width / _tileSize.floatValue);
    int pixelCountY = (int) (self.frame.size.height / _tileSize.floatValue);

    CGFloat pixelX = (int) ((tapPoint.x) / _tileSize.floatValue) / (CGFloat) pixelCountX; // X(色相)
    CGFloat pixelY = (int) ((tapPoint.y) / _tileSize.floatValue) / (CGFloat) (pixelCountY - 1); // Y(彩度)

    HRHSVColor selectedHSVColor;
    selectedHSVColor.h = pixelX;
    selectedHSVColor.s = 1.0f - (pixelY * self.saturationUpperLimit.floatValue);
    selectedHSVColor.v = self.brightness;

    UIColor *selectedColor;
    selectedColor = [UIColor colorWithHue:selectedHSVColor.h
                               saturation:selectedHSVColor.s
                               brightness:selectedHSVColor.v
                                    alpha:1.0];
    _color = selectedColor;
    [self updateColorCursor];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateColorCursor {
    // カラーマップのカーソルの移動＆色の更新
    CGPoint colorCursorPosition = CGPointZero;
    HRHSVColor hsvColor;
    HSVColorFromUIColor(self.color, &hsvColor);

    int pixelCountX = (int) (self.frame.size.width / _tileSize.floatValue);
    int pixelCountY = (int) (self.frame.size.height / _tileSize.floatValue);
    CGPoint newPosition;
    CGFloat hue = hsvColor.h;
    if (hue == 1) {
        hue = 0;
    }

    newPosition.x = hue * (CGFloat) pixelCountX * _tileSize.floatValue + _tileSize.floatValue / 2.0f;
    newPosition.y = (1.0f - hsvColor.s) * (1.0f / self.saturationUpperLimit.floatValue) * (CGFloat) (pixelCountY - 1) * _tileSize.floatValue + _tileSize.floatValue / 2.0f;
    colorCursorPosition.x = (int) (newPosition.x / _tileSize.floatValue) * _tileSize.floatValue;
    colorCursorPosition.y = (int) (newPosition.y / _tileSize.floatValue) * _tileSize.floatValue;
    _colorCursor.color = self.color;
    _colorCursor.transform = CGAffineTransformMakeTranslation(colorCursorPosition.x, colorCursorPosition.y);
}

@end