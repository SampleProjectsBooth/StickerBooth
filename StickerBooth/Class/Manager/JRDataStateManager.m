//
//  JRDataStateManager.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRDataStateManager.h"
#import <UIKit/UIKit.h>

@interface JRDataStateManager ()

@property (strong, nonatomic) NSMutableArray <NSMutableArray *>*states;

@end

@implementation JRDataStateManager

+ (instancetype)shareInstance
{
    static JRDataStateManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JRDataStateManager alloc] init];
    });
    return manager;
}


- (NSArray<NSArray *> *)dataSources
{
    return [self.states copy];
}

+ (void)changeState:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [[JRDataStateManager shareInstance].states objectAtIndex:indexPath.section];
    if ([[array objectAtIndex:indexPath.row] integerValue] == 0) {
        [array replaceObjectAtIndex:indexPath.row withObject:@1];
    } else {
        [array replaceObjectAtIndex:indexPath.row withObject:@0];
    }
}

+ (void)giveDataSource:(NSArray *)dataSource
{
    [JRDataStateManager shareInstance].states = [NSMutableArray arrayWithCapacity:dataSource.count];
    for (NSArray *array in dataSource) {
        NSMutableArray *s = [NSMutableArray arrayWithCapacity:array.count];
        for (id obj in array) {
            [s addObject:@0];
        }
        [[JRDataStateManager shareInstance].states addObject:s];
    }
}
@end
