//
//  NSString+JRSize.h
//  StickerBooth
//
//  Created by djr on 2020/3/6.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JRSize)

- (CGFloat)jr_textWidthForHeight:(CGFloat)height fontSize:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
