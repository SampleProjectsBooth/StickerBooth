//
//  JRDataStateManager.h
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JRDataStateType) {
    JRDataState_None = 0,
    JRDataState_Success,
    JRDataState_Fail,
};

@interface JRDataStateManager : NSObject

@property (readonly, nonatomic, nullable) NSArray <NSArray *>*dataSources;

@property (assign, nonatomic) NSUInteger section;

+ (instancetype)shareInstance;

- (void)giveDataSources:(NSArray <NSArray *>*)dataSources;

- (void)changeState:(NSInteger)row stateType:(JRDataStateType)stateType;

/** 如果index大于下标，会崩溃 */
- (JRDataStateType)stateTypeForIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
