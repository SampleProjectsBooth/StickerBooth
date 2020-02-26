//
//  JRDataStateManager.m
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRDataStateManager.h"

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

- (void)changeState:(NSInteger)row stateType:(JRDataStateType)stateType
{
    if([[JRDataStateManager shareInstance].states count] >= self.section) {
        NSMutableArray *array = [[JRDataStateManager shareInstance].states objectAtIndex:self.section];
        if (array.count >= row) {
            [array replaceObjectAtIndex:row withObject:@(stateType)];
        }
    }
}

- (void)giveDataSources:(NSArray <NSArray *>*)dataSources
{
    [JRDataStateManager shareInstance].states = [NSMutableArray arrayWithCapacity:dataSources.count];
    for (NSArray *array in dataSources) {
        NSMutableArray *s = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSInteger i = 0; array.count > i; i++) {
            [s addObject:@(JRDataState_None)];
        }
        
        [[JRDataStateManager shareInstance].states addObject:s];
    }
}

- (JRDataStateType)stateTypeForIndex:(NSUInteger)index
{
    if([[JRDataStateManager shareInstance].states count] >= self.section) {
        NSMutableArray *array = [[JRDataStateManager shareInstance].states objectAtIndex:self.section];
        return [[array objectAtIndex:index] integerValue];
    } 
    return JRDataState_None;
}
@end
