//
//  UIView+JRLayer.m
//  StickerBooth
//
//  Created by djr on 2020/3/6.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "UIView+JRLayer.h"

NSInteger const _jr_layerTag = 678900;

NSString *const JR_kTag = @"tag";


@implementation UIView (JRLayer)

#pragma mark - 描单边
- (void)jr_addBorder:(JRBoardDirection)direction
{
    [self jr_addBorder:direction color:[UIColor whiteColor] borderWidth:0.5f];
}

- (void)jr_addBorder:(JRBoardDirection)direction color:(UIColor *)color borderWidth:(float)width
{
    float line = CGRectGetWidth(self.frame);
    switch (direction) {
        case JRBoardDirection_Left:
        case JRBoardDirection_Right:
        {
            line = CGRectGetHeight(self.frame);
        }
            break;
        default:
            break;
    }
    [self jr_addBorder:direction color:color borderWidth:width borderLine:line];
}

- (void)jr_addBorder:(JRBoardDirection)direction color:(nonnull UIColor *)color borderWidth:(float)width borderLine:(float)line;
{
    
    
    
    NSInteger tag = _jr_layerTag+30+direction;
    
    for (CALayer *layer in [self.layer sublayers]) {
        int layerTag = [[layer valueForKey:JR_kTag] intValue];
        if (layerTag == tag) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    
    
    CALayer *TopBorder = [CALayer layer];
    
    [TopBorder setValue:@(tag) forKey:JR_kTag];
    
    if (direction == JRBoardDirection_Top) { /** 上 */
        TopBorder.frame = CGRectMake((CGRectGetWidth(self.frame)-line)/2, 0.0f, line, width);
    } else if (direction == JRBoardDirection_Left) { /** 左 */
        TopBorder.frame = CGRectMake(0.0f, (CGRectGetHeight(self.frame)-line)/2, width, line);
    } else if (direction == JRBoardDirection_Bottom) { /** 下 */
        TopBorder.frame = CGRectMake((CGRectGetWidth(self.frame)-line)/2, self.frame.size.height-width, line, width);
    } else if (direction == JRBoardDirection_Right) { /** 右 */
        TopBorder.frame = CGRectMake(self.frame.size.width-width, (CGRectGetHeight(self.frame)-line)/2, width, line);
    }
    
    TopBorder.backgroundColor = color.CGColor;
    
    [self.layer addSublayer:TopBorder];

}

#pragma mark - 新增分割线
- (void)jr_addTopSeparatorLine:(UIColor *)color lineWidth:(float)width
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    [bezierPath closePath];
    CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
    lineLayer.frame = self.bounds;
    lineLayer.path = bezierPath.CGPath;
    lineLayer.strokeColor = color.CGColor;
    lineLayer.lineWidth = width;
    [self.layer addSublayer:lineLayer];
}


@end
