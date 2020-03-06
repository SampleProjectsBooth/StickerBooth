//
//  NSString+JRSize.m
//  StickerBooth
//
//  Created by djr on 2020/3/6.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "NSString+JRSize.h"

@implementation NSString (JRSize)

 ///获取文字高度
- (CGFloat)jr_textWidthForHeight:(CGFloat)height fontSize:(UIFont *)font{
    
    if (self.length == 0) {
        return 0.f;
    }
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    //返回计算出的行高
    return rect.size.width;
}

@end
