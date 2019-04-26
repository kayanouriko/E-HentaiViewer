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


#import "HRBrightnessSlider.h"
#import "HRBrightnessCursor.h"
#import "HRHSVColorUtil.h"

@implementation HRBrightnessSlider {
    HRBrightnessCursor *_brightnessCursor;

    CAGradientLayer *_sliderLayer;
    NSNumber *_brightness;
    UIColor *_color;

    NSNumber *_brightnessLowerLimit;

    CGRect _controlFrame;
    CGRect _renderingFrame;
}

@synthesize brightness = _brightness;
@synthesize brightnessLowerLimit = _brightnessLowerLimit;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    _sliderLayer = [[CAGradientLayer alloc] initWithLayer:self.layer];
    _sliderLayer.startPoint = CGPointMake(0, .5);
    _sliderLayer.endPoint = CGPointMake(1, .5);
    _sliderLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    _sliderLayer.borderWidth = 1.f / [[UIScreen mainScreen] scale];

    [self.layer addSublayer:_sliderLayer];

    self.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer;
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];

    _brightnessCursor = [[HRBrightnessCursor alloc] init];
    [self addSubview:_brightnessCursor];

    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = (CGRect) {.origin = CGPointZero, .size = self.frame.size};
    _renderingFrame = UIEdgeInsetsInsetRect(frame, self.alignmentRectInsets);
    _controlFrame = CGRectInset(_renderingFrame, 8, 0);
    _brightnessCursor.center = CGPointMake(
            CGRectGetMinX(_controlFrame),
            CGRectGetMidY(_controlFrame));
    _sliderLayer.cornerRadius = _renderingFrame.size.height / 2;
    _sliderLayer.frame = _renderingFrame;
    [self updateCursor];
}

- (UIColor *)color {
    HRHSVColor hsvColor;
    HSVColorFromUIColor(_color, &hsvColor);
    hsvColor.v = _brightness.floatValue;
    return [[UIColor alloc] initWithHue:hsvColor.h
                             saturation:hsvColor.s
                             brightness:hsvColor.v
                                  alpha:1];
}

- (void)setColor:(UIColor *)color {
    _color = color;

    CGFloat brightness;
    [_color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    _brightness = @(brightness);

    [self updateCursor];

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue
                     forKey:kCATransactionDisableActions];

    HRHSVColor hsvColor;
    HSVColorFromUIColor(_color, &hsvColor);
    UIColor *darkColorFromHsv = [UIColor colorWithHue:hsvColor.h saturation:hsvColor.s brightness:self.brightnessLowerLimit.floatValue alpha:1.0f];
    UIColor *lightColorFromHsv = [UIColor colorWithHue:hsvColor.h saturation:hsvColor.s brightness:1.0f alpha:1.0f];

    _sliderLayer.colors = @[(id) lightColorFromHsv.CGColor, (id) darkColorFromHsv.CGColor];

    [CATransaction commit];
}

- (void)setBrightnessLowerLimit:(NSNumber *)brightnessLowerLimit {
    _brightnessLowerLimit = brightnessLowerLimit;
    [self updateCursor];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
        [self update:tapPoint];
        [self updateCursor];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        if (sender.numberOfTouches <= 0) {
            _brightnessCursor.editing = NO;
            return;
        }
        CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
        [self update:tapPoint];
        [self updateCursor];
        _brightnessCursor.editing = YES;
    }
}

- (void)update:(CGPoint)tapPoint {
    CGFloat selectedBrightness = 0;
    CGPoint tapPointInSlider = CGPointMake(tapPoint.x - _controlFrame.origin.x, tapPoint.y);
    tapPointInSlider.x = MIN(tapPointInSlider.x, _controlFrame.size.width);
    tapPointInSlider.x = MAX(tapPointInSlider.x, 0);

    selectedBrightness = 1.0 - tapPointInSlider.x / _controlFrame.size.width;
    selectedBrightness = selectedBrightness * (1.0 - self.brightnessLowerLimit.floatValue) + self.brightnessLowerLimit.floatValue;
    _brightness = @(selectedBrightness);

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateCursor {
    CGFloat brightnessCursorX = (1.0f - (self.brightness.floatValue - self.brightnessLowerLimit.floatValue) / (1.0f - self.brightnessLowerLimit.floatValue));
    if (brightnessCursorX < 0) {
        return;
    }
    CGPoint point = CGPointMake(brightnessCursorX * _controlFrame.size.width + _controlFrame.origin.x, _brightnessCursor.center.y);
    _brightnessCursor.center = point;
    _brightnessCursor.color = self.color;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

#pragma mark AutoLayout

- (UIEdgeInsets)alignmentRectInsets {
    return UIEdgeInsetsMake(10, 20, 10, 20);
}

- (CGRect)alignmentRectForFrame:(CGRect)frame {
    return UIEdgeInsetsInsetRect(frame, self.alignmentRectInsets);
}

- (CGRect)frameForAlignmentRect:(CGRect)alignmentRect {
    return UIEdgeInsetsInsetRect(alignmentRect, UIEdgeInsetsMake(-10, -20, -10, -20));
}

@end
