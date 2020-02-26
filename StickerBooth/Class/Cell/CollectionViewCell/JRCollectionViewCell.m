//
//  JRCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/19.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRCollectionViewCell.h"
#import "JRImageCollectionViewCell.h"
#import "LFEditCollectionView.h"
#import "JRDataStateManager.h"

@interface JRCollectionViewCell ()

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@end

@implementation JRCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
    CGFloat width = (CGRectGetWidth(self.contentView.bounds) - 5.f*6)/3;
    self.collectionView.itemSize = CGSizeMake(width, width);
    [self.collectionView invalidateIntrinsicContentSize];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.collectionView) {
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
    }
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    if ([data isKindOfClass:[NSArray class]]) {
        [self _initSubView];
        self.collectionView.dataSources = @[data];
    }
}

#pragma mark - Private Methods
- (void)_initSubView
{
    __weak typeof(self) weakSelf = self;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 5.f;
    flowLayout.sectionInset = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
    LFEditCollectionView *col = [[LFEditCollectionView alloc] initWithFrame:CGRectZero];
    col.collectionViewLayout = flowLayout;
    col.pagingEnabled = YES;
    col.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:col];
    self.collectionView = col;
    [self.collectionView registerClass:[JRImageCollectionViewCell class] forCellWithReuseIdentifier:[JRImageCollectionViewCell identifier]];
    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRImageCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)cell;
        [imageCell setCellData:item indexPath:indexPath];
        imageCell.contentView.backgroundColor = [UIColor lightGrayColor];
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        if ([[JRDataStateManager shareInstance] stateTypeForIndex:indexPath.row] == JRDataState_Success) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectObj:index:)]) {
                [weakSelf.delegate didSelectObj:imageCell.imageView.data index:indexPath.row];
            }
        }
    }];
    
}

@end
