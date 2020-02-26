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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.label removeFromSuperview];
}

- (void)setCellData:(id)data
{
    if ([data isKindOfClass:[NSString class]]) {
        [self _createCustomView];
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
    
}

@end
