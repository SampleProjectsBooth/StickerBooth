//
//  JRTitleShowView.m
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRTitleShowView.h"
#import "JRCollectionViewCell.h"
#import "LFDownloadManager.h"
#import "LFEditCollectionView.h"
#import "JRTitleCollectionViewCell.h"
#import "JRDataStateManager.h"

/** title高度 */
CGFloat const JR_V_ScrollView_heitht = 50.f;
/** 按钮宽度 */
CGFloat const JR_V_Button_width = 80.f;
/** 按钮在scrollView的间距 */
CGFloat const JR_O_margin = 1.5f;

@interface JRTitleShowView () <JRCollectionViewDelegate, LFEditCollectionViewDelegate>

@property (readonly , nonatomic, nonnull) NSArray <NSString *>*titles;

@property (readonly , nonatomic, nonnull) NSArray <NSArray *>*objs;

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@property (strong, nonatomic) LFEditCollectionView *topCollectionView;

@end

@implementation JRTitleShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _customLayoutSubviews];
}

#pragma mark - Public Methods
- (void)setTitles:(NSArray *)titles objs:(NSArray<NSArray *> *)objs
{
    _titles = titles;
    _selectTitle = [titles firstObject];
    _objs = objs;
    [[JRDataStateManager shareInstance] giveDataSources:_objs];
    [self _initSubViews];
}

#pragma mark - Private Methods
- (void)_initSubViews
{
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewFlowLayout *tFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    tFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    tFlowLayout.itemSize = CGSizeMake(JR_V_ScrollView_heitht, JR_V_ScrollView_heitht);
    tFlowLayout.minimumLineSpacing = JR_O_margin;
    tFlowLayout.minimumInteritemSpacing = 0;
    tFlowLayout.sectionInset = UIEdgeInsetsMake(JR_O_margin, JR_O_margin, JR_O_margin, JR_O_margin);
    LFEditCollectionView *tCollectionView = [[LFEditCollectionView alloc] initWithFrame:CGRectZero];
    tCollectionView.showsVerticalScrollIndicator = NO;
    tCollectionView.showsHorizontalScrollIndicator = NO;
    tCollectionView.backgroundColor = [UIColor clearColor];
    tCollectionView.collectionViewLayout = tFlowLayout;
    [self addSubview:tCollectionView];
    self.topCollectionView = tCollectionView;
    [self.topCollectionView setDataSources:@[_titles]];

    [self.topCollectionView registerClass:[JRTitleCollectionViewCell class] forCellWithReuseIdentifier:[JRTitleCollectionViewCell identifier]];

    [self.topCollectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRTitleCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRTitleCollectionViewCell *titleCell = (JRTitleCollectionViewCell *)cell;
        [titleCell setCellData:item];
        titleCell.contentView.backgroundColor = [UIColor clearColor];
        if ([weakSelf.selectTitle isEqualToString:item]) {
            titleCell.contentView.backgroundColor = [UIColor orangeColor];
        }
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        [JRDataStateManager shareInstance].section = indexPath.row;
        [weakSelf _changeTitle:item];
        [weakSelf.topCollectionView reloadData];
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    LFEditCollectionView *collectionView = [[LFEditCollectionView alloc] initWithFrame:CGRectZero];
    collectionView.collectionViewLayout = flowLayout;
    collectionView.pagingEnabled = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView setDataSources:@[_titles]];
    [self.collectionView registerClass:[JRCollectionViewCell class] forCellWithReuseIdentifier:[JRCollectionViewCell identifier]];

    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRCollectionViewCell *viewCell = (JRCollectionViewCell *)cell;
        viewCell.backgroundColor = [UIColor clearColor];
        if (weakSelf.objs.count > indexPath.row) {
            [viewCell setCellData:[weakSelf.objs objectAtIndex:indexPath.row]];
        } else {
            [viewCell setCellData:nil];
        }
        viewCell.delegate = self;
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
    }];
    
}

- (void)_changeTitle:(NSString *)string
{
    if (![_selectTitle isEqualToString:string]) {
        _selectTitle = string;
    }
}

#pragma mark 调整视图
- (void)_customLayoutSubviews
{
    self.topCollectionView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), JR_V_ScrollView_heitht + JR_O_margin*2);
    
    self.collectionView.frame = CGRectMake(0.f, JR_V_ScrollView_heitht, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.topCollectionView.frame));
    self.collectionView.itemSize = self.collectionView.frame.size;
    [self.collectionView invalidateIntrinsicContentSize];
}

#pragma mark - JRCollectionViewDelegate
- (void)didSelectObj:(id)obj index:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self.titles indexOfObject:self.selectTitle]];
    if (self.didSelectBlock) {
        self.didSelectBlock(indexPath, obj);
    }
}

#pragma mark - LFEditCollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView.superview isEqual:self.collectionView]) {
        NSLog(@"2233");
        NSUInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        _selectTitle = self.titles[index];
        [self.topCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self.topCollectionView reloadItemsAtIndexPaths:@[]];
        
    }
}

@end
