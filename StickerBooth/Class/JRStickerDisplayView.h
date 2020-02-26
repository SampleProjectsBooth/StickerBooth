//
//  JRTitleShowView.h
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JRDidSelectItemBlock)(NSIndexPath *indexPath, NSData * _Nullable data);

@interface JRStickerDisplayView : UIView

/** 点击返回data */
@property (copy , nonatomic) JRDidSelectItemBlock didSelectBlock;

/** 设置数据后，默认titles第一个*/
@property (readonly, nonatomic, nullable) NSString *selectTitle;

/// 设置数据
/// @param titles 标题
/// @param content 数据
- (void)setTitles:(nonnull NSArray <NSString *>*)titles contents:(nonnull NSArray <NSArray *>*)contents;

@end

NS_ASSUME_NONNULL_END
