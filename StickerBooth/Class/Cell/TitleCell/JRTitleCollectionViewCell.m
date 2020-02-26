//
//  JRTitleCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRTitleCollectionViewCell.h"

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
    if ([data isKindOfClass:[NSString class]]) {
        self.label.text = data;
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

@end
