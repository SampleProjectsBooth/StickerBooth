//
//  LFEditCollectionView.m
//  SafeAreaTest
//
//  Created by TsanFeng Lam on 2017/11/16.
//  Copyright © 2017年 TsanFeng Lam. All rights reserved.
//

#import "LFEditCollectionView.h"

@interface LFEditCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, copy) LFEditCollectionViewDequeueReusableCellBlock dequeueReusableCellBlock;
@property (nonatomic, copy) LFEditCollectionViewCellConfigureBlock cellConfigureBlock;
@property (nonatomic, copy) LFEditCollectionViewDidSelectItemAtIndexPathBlock didSelectItemAtIndexPathBlock;

@end

@implementation LFEditCollectionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}


- (void)customInit
{
    [self UI_init];
    
}

- (void)UI_init
{
    /* UI */
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 11.0, *)){
        [collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)callbackCellIdentifier:(LFEditCollectionViewDequeueReusableCellBlock)aCellIdentifier
                 configureCell:(LFEditCollectionViewCellConfigureBlock)aConfigureCell
      didSelectItemAtIndexPath:(LFEditCollectionViewDidSelectItemAtIndexPathBlock)aDidSelectItemAtIndexPath
{
    self.dequeueReusableCellBlock = aCellIdentifier;
    self.cellConfigureBlock = aConfigureCell;
    self.didSelectItemAtIndexPathBlock = aDidSelectItemAtIndexPath;
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSArray *subDataSources = self.dataSources[indexPath.section];
    id model = subDataSources[indexPath.row];
    
    NSString *LFEditCollectionViewCellIdentifier = @"LFEditCollectionViewCell";
    if (self.dequeueReusableCellBlock) {
        LFEditCollectionViewCellIdentifier = self.dequeueReusableCellBlock(indexPath);
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LFEditCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(indexPath, model, cell);
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *subDataSources = self.dataSources[section];
    return subDataSources.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSources.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *subDataSources = self.dataSources[indexPath.section];
    id model = subDataSources[indexPath.row];
    if (self.didSelectItemAtIndexPathBlock) {
        self.didSelectItemAtIndexPathBlock(indexPath, model);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging: withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.delegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollView setter/getter
- (void)setBounces:(BOOL)bounces
{
    self.collectionView.bounces = bounces;
}

- (BOOL)bounces
{
    return self.collectionView.bounces;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    self.collectionView.contentOffset = contentOffset;
}

- (CGPoint)contentOffset
{
    return self.collectionView.contentOffset;
}

- (void)setContentSize:(CGSize)contentSize
{
    self.collectionView.contentSize = contentSize;
}

- (CGSize)contentSize
{
    return self.collectionView.contentSize;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    self.collectionView.contentInset = contentInset;
}

- (UIEdgeInsets)contentInset
{
    return self.collectionView.contentInset;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [self.collectionView setContentOffset:contentOffset animated:animated];
}
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    [self.collectionView scrollRectToVisible:rect animated:animated];
}

#pragma mark - UICollectionView setter/getter
- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    self.collectionView.pagingEnabled = pagingEnabled;
}
- (BOOL)isPagingEnabled
{
    return self.collectionView.isPagingEnabled;
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
{
    self.collectionView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
}
- (BOOL)showsVerticalScrollIndicator
{
    return self.collectionView.showsVerticalScrollIndicator;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator
{
    self.collectionView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
}
- (BOOL)showsHorizontalScrollIndicator
{
    return self.collectionView.showsHorizontalScrollIndicator;
}

- (void)setPrefetchingEnabled:(BOOL)prefetchingEnabled
{
    self.collectionView.prefetchingEnabled = prefetchingEnabled;
}

- (BOOL)isPrefetchingEnabled
{
    return self.collectionView.isPrefetchingEnabled;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)invalidateLayout
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}
#pragma mark - UICollectionViewFlowLayout setter/getter
- (void)setCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
{
    self.collectionView.collectionViewLayout = collectionViewLayout;
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        _collectionViewLayout = collectionViewLayout;
    } else {
        _collectionViewLayout = nil;
    }
}
- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumLineSpacing = minimumLineSpacing;
}
- (CGFloat)minimumLineSpacing
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumLineSpacing;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumInteritemSpacing = minimumInteritemSpacing;
}
- (CGFloat)minimumInteritemSpacing
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumInteritemSpacing;
}

- (void)setItemSize:(CGSize)itemSize
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = itemSize;
}
- (CGSize)itemSize
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
}

- (void)setEstimatedItemSize:(CGSize)estimatedItemSize
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize = estimatedItemSize;
}
- (CGSize)estimatedItemSize
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).scrollDirection = scrollDirection;
}
- (UICollectionViewScrollDirection)scrollDirection
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).scrollDirection;
}

- (void)setHeaderReferenceSize:(CGSize)headerReferenceSize
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).headerReferenceSize = headerReferenceSize;
}
- (CGSize)headerReferenceSize
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).headerReferenceSize;
}

- (void)setFooterReferenceSize:(CGSize)footerReferenceSize
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).footerReferenceSize = footerReferenceSize;
}
- (CGSize)footerReferenceSize
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).footerReferenceSize;
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset = sectionInset;
}
- (UIEdgeInsets)sectionInset
{
    return ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset;
}

@end
