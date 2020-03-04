//
//  JRTitleCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRTitleCollectionViewCell.h"
#import "JRConfigTool.h"
@interface JRTitleCollectionViewCell ()

@property (weak, nonatomic) UILabel *label;

@end

@implementation JRTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _createCustomView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = nil;
}

- (void)setCellData:(id)data
{
    [super setCellData:data];
    if ([data isKindOfClass:[NSString class]]) {
        self.label.text = data;
    }
}

- (void)showAnimationOfProgress:(CGFloat)progress select:(BOOL)select
{
    if (select) {
        self.label.textColor = [JRTitleCollectionViewCell colorTransformFrom:[JRConfigTool shareInstance].normalTitleColor to:[JRConfigTool shareInstance].selectTitleColor progress:progress];
    } else {
        self.label.textColor = [JRTitleCollectionViewCell colorTransformFrom:[JRConfigTool shareInstance].selectTitleColor to:[JRConfigTool shareInstance].normalTitleColor progress:progress];
    }
}

#pragma mark - Private Methods
- (void)_createCustomView
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:lable];
    self.label = lable;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
}

+ (UIColor *)colorTransformFrom:(UIColor*)fromColor to:(UIColor *)toColor progress:(CGFloat)progress {

    if (!fromColor || !toColor) {
        NSLog(@"Warning !!! color is nil");
        return [UIColor blackColor];
    }

    progress = progress >= 1 ? 1 : progress;

    progress = progress <= 0 ? 0 : progress;
    
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);
    
    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    
    CGFloat red = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat green = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat blue = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
