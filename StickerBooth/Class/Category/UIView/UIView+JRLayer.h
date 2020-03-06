//
//  UIView+JRLayer.h
//  StickerBooth
//
//  Created by djr on 2020/3/6.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JRBoardDirection)
{
    JRBoardDirection_Top = 0,
    JRBoardDirection_Left = 1,
    JRBoardDirection_Bottom = 2,
    JRBoardDirection_Right = 3,
};

@interface UIView (JRLayer)

- (void)jr_addBorder:(JRBoardDirection)direction;

- (void)jr_addBorder:(JRBoardDirection)direction color:(nonnull UIColor *)color borderWidth:(float)width;

/// 视图描边
/// @param direction 方向
/// @param color 颜色
/// @param width 宽度
/// @param line 长度 （居中显示）
- (void)jr_addBorder:(JRBoardDirection)direction color:(nonnull UIColor *)color borderWidth:(float)width borderLine:(float)line;


- (void)jr_addTopSeparatorLine:(nonnull UIColor *)color lineWidth:(float)width;

@end

NS_ASSUME_NONNULL_END
