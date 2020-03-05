//
//  JRTitleShowView.m
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRStickerDisplayView.h"
#import "JRCollectionViewCell.h"
#import "LFEditCollectionView.h"
#import "JRTitleCollectionViewCell.h"
#import "JRStickerContent.h"
#import "JRConfigTool.h"
#import "JRStickerHeader.h"

#define JRStickerDisplayView_bind_var(varType, varName, setterName) \
JRSticker_bind_var_getter(varType, varName, [JRConfigTool shareInstance]) \
JRSticker_bind_var_setter(varType, varName, setterName, [JRConfigTool shareInstance])

/** title高度 */
CGFloat const JR_V_ScrollView_heitht = 50.f;
/** 按钮宽度 */
CGFloat const JR_V_Button_width = 80.f;
/** 按钮在scrollView的间距 */
CGFloat const JR_O_margin = 1.5f;

@interface JRStickerDisplayView () <JRCollectionViewDelegate, LFEditCollectionViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (readonly , nonatomic, nonnull) NSArray <NSString *>*titles;

@property (readonly , nonatomic, nonnull) NSArray <NSArray <JRStickerContent *>*>*contents;

//@property (strong, nonatomic) LFEditCollectionView *collectionView;

@property (strong, nonatomic) LFEditCollectionView *topCollectionView;

@property (copy, nonatomic) NSString *selectTitle;

@property (assign, nonatomic) BOOL stopAnimation;

@property (strong, nonatomic, nullable) NSIndexPath *selectIndexPath;

@property (strong, nonatomic) NSMapTable *cells;

@property (weak, nonatomic) UICollectionView *collectionView;
@end

@implementation JRStickerDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cells = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:1];
        self.backgroundColor = [UIColor blackColor];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _customLayoutSubviews];
}

- (void)dealloc
{
    [self.cells removeAllObjects];
    [self.topCollectionView removeFromSuperview];
    [self.collectionView removeFromSuperview];
    self.topCollectionView = nil;
    self.collectionView = nil;
}
    
JRStickerDisplayView_bind_var(UIColor *, selectTitleColor, setSelectTitleColor);
JRStickerDisplayView_bind_var(UIColor *, normalTitleColor, setNormalTitleColor);
JRStickerDisplayView_bind_var(CGSize, itemCellSize, setItemCellSize);
JRStickerDisplayView_bind_var(CGFloat, itemMargin, setItemMargin);
JRStickerDisplayView_bind_var(UIImage *, normalImage, setNormalImage);
JRStickerDisplayView_bind_var(UIImage *, failureImage, setFailureImage);


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
        NSString *identifier = [JRTitleCollectionViewCell identifier];
        return identifier;
    } configureCell:^(NSIndexPath * _Nonnull indexPath, NSString *  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
        JRTitleCollectionViewCell *titleCell = (JRTitleCollectionViewCell *)cell;
        [titleCell setCellData:item];
        titleCell.backgroundColor =  [UIColor clearColor];
        [titleCell showAnimationOfProgress:1.f select:NO];
        if ([weakSelf.selectTitle isEqualToString:item]) {
            [titleCell showAnimationOfProgress:1.f select:YES];
        }
    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        [weakSelf _changeTitle:item];
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
    }];
    

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 10.0, *)) {
        collectionView.prefetchingEnabled = NO;
    }
    [self addSubview:collectionView];
    self.collectionView = collectionView;
//    LFEditCollectionView *collectionView = [[LFEditCollectionView alloc] initWithFrame:CGRectZero];
//    collectionView.collectionViewLayout = flowLayout;
//    collectionView.pagingEnabled = YES;
//    collectionView.showsVerticalScrollIndicator = NO;
//    collectionView.showsHorizontalScrollIndicator = NO;
//    collectionView.delegate = self;
//    collectionView.backgroundColor = [UIColor clearColor];
//    [self addSubview:collectionView];
//    self.collectionView = collectionView;
//    [self.collectionView setDataSources:@[_titles]];
    for (NSUInteger i = 0; i < _titles.count; i ++) {
        NSString *identifier = [NSString stringWithFormat:@"%@abc%lu", [JRTitleCollectionViewCell identifier], (unsigned long)i];
        [self.collectionView registerClass:[JRCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }

//    [self.collectionView callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
//        NSString *identifier = [NSString stringWithFormat:@"%@abc%ld", [JRTitleCollectionViewCell identifier], indexPath.row];
//        return identifier;
//    } configureCell:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item, UICollectionViewCell * _Nonnull cell) {
//        JRCollectionViewCell *imageCell = (JRCollectionViewCell *)cell;
//        imageCell.backgroundColor = [UIColor clearColor];
//        if (weakSelf.contents.count > indexPath.row) {
//            [imageCell setCellData:[weakSelf.contents objectAtIndex:indexPath.row]];
//        }
//        imageCell.delegate = weakSelf;
//    } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
//
//    }];
    
}

- (void)_changeTitle:(NSString *)string
{
    if ([self.selectTitle isEqualToString:string]) {
        return;
    }
    self.stopAnimation = YES;
    NSUInteger oldIndex = [self.titles indexOfObject:_selectTitle];
    NSUInteger selectIndex = [self.titles indexOfObject:string];
    self.selectTitle = string;
    [self.topCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:selectIndex inSection:0]]];
}

- (void)_customLayoutSubviews
{
    self.stopAnimation = YES;
    NSInteger currentIndex = [self.titles indexOfObject:self.selectTitle];

    CGRect topViewR = self.topCollectionView.frame;

    if (CGRectEqualToRect(topViewR, CGRectZero)) {
        topViewR = CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), JR_V_ScrollView_heitht + JR_O_margin*2);
    }
    topViewR.size.width = CGRectGetWidth(self.frame);
    self.topCollectionView.frame = topViewR;
    self.topCollectionView.itemSize = CGSizeMake((CGRectGetWidth(self.topCollectionView.frame)-JR_O_margin * 5)/4, JR_V_ScrollView_heitht);
    [self.topCollectionView.collectionViewLayout invalidateLayout];
    
    CGRect collectionViewR = self.collectionView.frame;
    if (CGRectEqualToRect(collectionViewR, CGRectZero)) {
        collectionViewR = CGRectMake(0.f, JR_V_ScrollView_heitht, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.topCollectionView.frame));
    }
    collectionViewR.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.topCollectionView.frame));
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = collectionViewR.size;
    self.collectionView.frame = collectionViewR;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.contentSize = CGSizeMake(self.titles.count * (self.collectionView.frame.size.width), 0.f);
    [self.collectionView.collectionViewLayout invalidateLayout];
    if (self.titles.count) {
        [self.collectionView setContentOffset:CGPointMake((self.collectionView.frame.size.width) * currentIndex, 0) animated:NO];
    }
}

- (void)_changeTitleAnimotionProgress:(CGFloat)progress
{
    NSUInteger _selectedIndex = [self.titles indexOfObject:self.selectTitle];
    //获取下一个index
    NSInteger targetIndex = progress < 0 ? _selectedIndex - 1 : _selectedIndex + 1;
    if (targetIndex < 0 || targetIndex >= [self.titles count]) return;

    //获取cell
    JRTitleCollectionViewCell *currentCell = (JRTitleCollectionViewCell *)[self.topCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    JRTitleCollectionViewCell *targetCell = (JRTitleCollectionViewCell *)[self.topCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
    
    [currentCell showAnimationOfProgress:progress select:NO];
    
    [targetCell showAnimationOfProgress:progress select:YES];


}

#pragma mark - JRCollectionViewDelegate
- (void)didSelectData:(NSData *)data image:(UIImage *)image index:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self.titles indexOfObject:self.selectTitle]];
    _selectIndexPath = indexPath;
    if (self.didSelectBlock) {
        self.didSelectBlock(data, image);
    }
    _selectIndexPath = nil;
}

#pragma mark - LFEditCollectionViewScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        if (self.stopAnimation) {
            return;
        }
        CGFloat value = scrollView.contentOffset.x/scrollView.bounds.size.width - [self.titles indexOfObject:self.selectTitle];
        [self _changeTitleAnimotionProgress:value];
        self.selectTitle = [self.titles objectAtIndex:scrollView.contentOffset.x/scrollView.bounds.size.width];
    }
}

//更新执行动画状态
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

////更新执行动画状态
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = [NSString stringWithFormat:@"%@abc%lu", [JRTitleCollectionViewCell identifier], (unsigned long)indexPath.row];
    JRCollectionViewCell *imageCell = [self.cells objectForKey:identifier];
    if (!imageCell) {
        imageCell = (JRCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        imageCell.delegate = self;
        imageCell.backgroundColor = [UIColor clearColor];
        [self.cells setObject:imageCell forKey:identifier];
        if (self.contents.count > indexPath.row) {
            [imageCell setCellData:[self.contents objectAtIndex:indexPath.row]];
        } else {
            [imageCell setCellData:nil];
        }
    }
    return imageCell;
}

@end
