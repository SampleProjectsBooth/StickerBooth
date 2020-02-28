//
//  JRBaseCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"

@interface JRBaseCollectionViewCell ()

@property (strong, nonatomic) id data;

@end

@implementation JRBaseCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (void)setCellData:(nullable id)data
{
    _data = data;
}
@end
