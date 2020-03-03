//
//  JRTitleShowView.h
//  gifDemo
//
//  Created by djr on 2020/2/24.
//  Copyright © 2020 djr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRConfigTool.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JRDidSelectItemBlock)(NSData * _Nullable data, UIImage * _Nullable image);

@interface JRStickerDisplayView : UIView

/** 点击返回data */
@property (copy , nonatomic) JRDidSelectItemBlock didSelectBlock;

/** 全局，只要有地方设置就可以了，不用设置回来 */
@property (strong , nonatomic) JRConfigTool *configTool;


/// 设置数据
/// @param titles 标题
/// @param contents 数据
- (void)setTitles:(nonnull NSArray <NSString *>*)titles contents:(nonnull NSArray <NSArray *>*)contents;

@end

NS_ASSUME_NONNULL_END
