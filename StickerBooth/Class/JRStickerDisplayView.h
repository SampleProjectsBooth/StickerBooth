//
//  JRTitleShowView.h
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JRDidSelectItemBlock)(NSData * _Nullable data);

@interface JRStickerDisplayView : UIView

/** 点击返回data */
@property (copy , nonatomic) JRDidSelectItemBlock didSelectBlock;

@property (nonatomic) UIColor *selectTitleColor;

@property (nonatomic) UIColor *normalTitleColor;

@property (nonatomic) CGSize itemCellSize;

@property (nonatomic) CGFloat itemMargin;

/** 占位图，为nil不显示 */
@property (nonatomic, nullable) UIImage *normalImage;

/** 加载失败图，为nil不显示 */
@property (nonatomic, nullable) UIImage *failureImage;

@property (nonatomic, readonly, nonnull) NSIndexPath *selectIndexPath;

/// 设置数据
/// @param titles 标题
/// @param contents 数据
- (void)setTitles:(nonnull NSArray <NSString *>*)titles contents:(nonnull NSArray <NSArray *>*)contents;

@end

NS_ASSUME_NONNULL_END
