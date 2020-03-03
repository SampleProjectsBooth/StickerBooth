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
#import "JRStickerContent.h"


CGFloat const JR_O_stickerSize = 80;
CGFloat const JR_O_stickerMargin = 10;

@interface JRCollectionViewCell () <LFEditCollectionViewDelegate>

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@end

@implementation JRCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _initSubView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
    [self.collectionView invalidateLayout];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.collectionView) {
        self.collectionView.dataSources = @[];
        [self.collectionView reloadData];
    }
}

- (void)dealloc
{
    [self.collectionView removeFromSuperview];
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    self.collectionView.dataSources = @[];
    if ([data isKindOfClass:[NSArray class]]) {
        self.collectionView.dataSources = @[data];
    }
    [self.collectionView reloadData];
}

- (void)clearData
{
    NSArray <UICollectionViewCell *>*array = [self.collectionView visibleCells];
    for (UICollectionViewCell *obj in array) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)obj;
        [imageCell clearData];
    }
}
#pragma mark - Private Methods
- (void)_initSubView
{
    __weak typeof(self) weakSelf = self;
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.minimumLineSpacing = 5.f;
//    flowLayout.sectionInset = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
    LFEditCollectionView *col = [[LFEditCollectionView alloc] initWithFrame:CGRectZero];
    col.minimumInteritemSpacing = 0.f;
    col.minimumLineSpacing = 0.f;
    col.itemSize = CGSizeMake(JR_O_stickerSize, JR_O_stickerSize);
    col.sectionInset = UIEdgeInsetsMake(JR_O_stickerMargin, JR_O_stickerMargin, JR_O_stickerMargin, JR_O_stickerMargin);
    col.delegate = self;
    col.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:col];
    self.collectionView = col;
    [self.collectionView registerClass:[JRImageCollectionViewCell class] forCellWithReuseIdentifier:[JRImageCollectionViewCell identifier]];
    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRImageCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, JRStickerContent * _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)cell;
        [imageCell setCellData:item];
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, JRStickerContent * _Nonnull item) {
        JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
        if (item.state == JRStickerContentState_Success) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectObj:index:)]) {
                [weakSelf.delegate didSelectObj:imageCell.imageData index:indexPath.row];
            }
        }
    }];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)cell;
    [imageCell clearData];
}
@end
