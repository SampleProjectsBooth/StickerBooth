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
#import "JRConfigTool.h"

@interface JRCollectionViewCell () <LFEditCollectionViewDelegate>

@property (strong, nonatomic) LFEditCollectionView *collectionView;

@property (strong, nonatomic) NSIndexPath *longPressIndexPath;

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
    LFEditCollectionView *col = [[LFEditCollectionView alloc] initWithFrame:self.contentView.bounds];
    col.itemSize = [JRConfigTool shareInstance].itemCellSize;
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
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectData:image:index:)]) {
                [imageCell jr_getImageData:^(NSData * _Nonnull data, UIImage * _Nonnull image) {
                    [weakSelf.delegate didSelectData:data image:image index:indexPath.row];
                }];
            }
        }
    }];
    
    UILongPressGestureRecognizer *ge = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longpress:)];
    self.backgroundColor = [UIColor blackColor];
    [self addGestureRecognizer:ge];

}

static LFMEGifView *_jr_showView = nil;
static UIView *_jr_contenView = nil;

- (void)show:(JRImageCollectionViewCell *)cell
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect covertRect = [_jr_subCollectionView convertRect:cell.frame toView:keyWindow];
    
    if (!_jr_contenView) {
        UIView *contenView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 180.f, 180.f)];
        contenView.layer.cornerRadius = 10.f;
        contenView.backgroundColor = [UIColor grayColor];
        contenView.hidden = YES;
        [keyWindow addSubview:contenView];
        [keyWindow bringSubviewToFront:contenView];
        _jr_contenView = contenView;
        LFMEGifView *gifView = [[LFMEGifView alloc] initWithFrame:CGRectInset(contenView.bounds, 10.f, 10.f)];
        [contenView addSubview:gifView];
        _jr_showView = gifView;
    }
    CGRect f = _jr_contenView.frame;
    f.origin = CGPointMake(CGRectGetMidX(covertRect) - CGRectGetWidth(f)/2, CGRectGetMinY(covertRect) - 10.f - CGRectGetHeight(f));
    
    if (CGRectGetMinX(f) < 0) {
        f.origin.x = 0.f;
    }
    
    if (CGRectGetMaxX(f) > CGRectGetWidth(keyWindow.bounds)) {
        CGFloat margin = CGRectGetMaxX(f) - CGRectGetWidth(keyWindow.bounds);
        f.origin.x -= margin;
    }
    
    if (CGRectGetMinY(f) < 0) {
        f.origin.y = 10.f + CGRectGetMaxY(covertRect);
    }
    _jr_contenView.frame = f;
    [cell jr_getImageData:^(NSData * _Nonnull data, UIImage * _Nonnull image) {
        _jr_showView.data = data;
        _jr_contenView.hidden = NO;
    }];
}

static UICollectionView *_jr_subCollectionView = nil;

- (void)_longpress:(UILongPressGestureRecognizer *)longpress
{
    if (!_jr_subCollectionView) {
        for (UIView *subView in self.collectionView.subviews) {
            if ([subView isKindOfClass:[UICollectionView class]]) {
                _jr_subCollectionView = (UICollectionView *)subView;
                break;
            }
        }
    }
    CGPoint location = [longpress locationInView:self];
    location = [self convertPoint:location toView:_jr_subCollectionView];
    switch (longpress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.longPressIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
            cell.longpress = YES;
            [self show:cell];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势位置改变
            NSIndexPath *changeIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            if ((changeIndexPath && changeIndexPath.row != self.longPressIndexPath.row) || !self.longPressIndexPath) {
                NSIndexPath *oldIndexPath = self.longPressIndexPath;
                JRImageCollectionViewCell *oldCell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:oldIndexPath];
                oldCell.longpress = NO;
                self.longPressIndexPath = changeIndexPath;
                JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                cell.longpress = YES;
                [self show:cell];
            } else if (changeIndexPath == nil) {
                if (_jr_contenView) {
                    [_jr_contenView removeFromSuperview];
                    [_jr_showView removeFromSuperview];
                    _jr_showView = nil;
                    _jr_contenView = nil;
                    _jr_subCollectionView = nil;
                }
                if (self.longPressIndexPath) {
                    JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                    cell.longpress = NO;
                    self.longPressIndexPath = nil;
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        {
            if (_jr_contenView) {
                [_jr_contenView removeFromSuperview];
                [_jr_showView removeFromSuperview];
                _jr_showView = nil;
                _jr_contenView = nil;
                _jr_subCollectionView = nil;
            }
            if (self.longPressIndexPath) {
                JRImageCollectionViewCell *cell = (JRImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
                cell.longpress = NO;
                self.longPressIndexPath = nil;
            }
        }
            break;
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    JRImageCollectionViewCell *imageCell = (JRImageCollectionViewCell *)cell;
    [imageCell clearData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemCellSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemCellSize.width * count) / (count + 1);
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemCellSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemCellSize.width * count) / (count + 1);
    return margin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    int count = collectionView.frame.size.width / ([JRConfigTool shareInstance].itemCellSize.width + [JRConfigTool shareInstance].itemMargin);
    CGFloat margin = (collectionView.frame.size.width - [JRConfigTool shareInstance].itemCellSize.width * count) / (count + 1);
    return margin;
}

@end
