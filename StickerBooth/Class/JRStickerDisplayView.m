//
//  JRTitleShowView.m
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRStickerDisplayView.h"
#import "JRCollectionViewCell.h"
#import "LFDownloadManager.h"
#import "LFEditCollectionView.h"
#import "JRTitleCollectionViewCell.h"
#import "JRStickerContent.h"

/** title高度 */
CGFloat const JR_V_ScrollView_heitht = 50.f;
/** 按钮宽度 */
CGFloat const JR_V_Button_width = 80.f;
/** 按钮在scrollView的间距 */
CGFloat const JR_O_margin = 1.5f;

@interface JRStickerDisplayView () <JRCollectionViewDelegate, LFEditCollectionViewDelegate>

@property (readonly , nonatomic, nonnull) NSArray <NSString *>*titles;

@property (readonly , nonatomic, nonnull) NSArray <NSArray <JRStickerContent *>*>*contents;

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@property (strong, nonatomic) LFEditCollectionView *topCollectionView;

@property (copy, nonatomic) NSString *selectTitle;

@end

@implementation JRStickerDisplayView

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
- (void)setTitles:(NSArray *)titles contents:(NSArray<NSArray *> *)contents
{
    _titles = titles;
    _selectTitle = [titles firstObject];
    NSMutableArray *r_contents = [NSMutableArray arrayWithCapacity:contents.count];
    for (NSArray *subContents in contents) {
        NSMutableArray *s_contents = [NSMutableArray arrayWithCapacity:subContents.count];
        for (id content in subContents) {
            [s_contents addObject:[JRStickerContent stickerContentWithContent:content]];
        }
        [r_contents addObject:[s_contents copy]];
    }
    _contents = [r_contents copy];
    
    if (_titles.count) {
        [self _initSubViews];
    }
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
    } configureCell:^(NSIndexPath * _Nonnull indexPath, NSString *  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRTitleCollectionViewCell *titleCell = (JRTitleCollectionViewCell *)cell;
        [titleCell setCellData:item];
        titleCell.backgroundColor =  [UIColor clearColor];
        if ([weakSelf.selectTitle isEqualToString:item]) {
            titleCell.backgroundColor =  [UIColor orangeColor];
        }
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        [weakSelf _changeTitle:item];
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
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView setDataSources:@[_titles]];
    [self.collectionView registerClass:[JRCollectionViewCell class] forCellWithReuseIdentifier:[JRCollectionViewCell identifier]];

    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [JRCollectionViewCell identifier];
    } configureCell:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRCollectionViewCell *imageCell = (JRCollectionViewCell *)cell;
        imageCell.backgroundColor = [UIColor clearColor];
        if (weakSelf.contents.count > indexPath.row) {
            [imageCell setCellData:[weakSelf.contents objectAtIndex:indexPath.row]];
        }
        imageCell.delegate = self;
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        
    }];
    
}

- (void)_changeTitle:(NSString *)string
{
    if ([self.selectTitle isEqualToString:string]) {
        return;
    }
    NSUInteger oldIndex = [self.titles indexOfObject:_selectTitle];
    NSUInteger selectIndex = [self.titles indexOfObject:string];
    self.selectTitle = string;
    [self.topCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:selectIndex inSection:0]]];
}

#pragma mark 调整视图
- (void)_customLayoutSubviews
{
    self.topCollectionView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), JR_V_ScrollView_heitht + JR_O_margin*2);
    
    self.collectionView.frame = CGRectMake(0.f, JR_V_ScrollView_heitht, CGRectGetWidth(self.frame)+10.f, CGRectGetHeight(self.frame) - CGRectGetHeight(self.topCollectionView.frame));
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
        NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (self.titles.count > index) {
            NSString *string = [self.titles objectAtIndex:index];
            [self _changeTitle:string];
        }
    }
}

@end
