//
//  JRTitleCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRTitleCollectionViewCell.h"
#import "JRConfigTool.h"
#import "UIView+JRLayer.h"
#import "UIColor+JRColor.h"

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
    [self.label jr_addBorder:3 color:[UIColor whiteColor] borderWidth:1.f borderLine:CGRectGetHeight(self.label.frame)/2];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = nil;
}

- (UIFont *)textFont
{
    if (!_textFont) {
        if (self.label.font) {
            _textFont = self.label.font;
        } else {
            _textFont = [UIFont systemFontOfSize:16.f];
        }
    }
    return _textFont;
}

- (void)setCellData:(id)data
{
    [super setCellData:data];
    if (_textFont) {
        self.label.font = self.textFont;
    }
    if ([data isKindOfClass:[NSString class]]) {
        self.label.text = data;
    }
}

- (void)showAnimationOfProgress:(CGFloat)progress select:(BOOL)select
{
    if (select) {
        self.label.textColor = [UIColor colorTransformFrom:[JRConfigTool shareInstance].normalTitleColor to:[JRConfigTool shareInstance].selectTitleColor progress:progress];
    } else {
        self.label.textColor = [UIColor colorTransformFrom:[JRConfigTool shareInstance].selectTitleColor to:[JRConfigTool shareInstance].normalTitleColor progress:progress];
    }
}

#pragma mark - Private Methods
- (void)_createCustomView
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:lable];
    self.label = lable;
    self.label.font = _textFont;
    self.label.numberOfLines = 1.f;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
}



@end
