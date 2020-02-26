//
//  JRDataStateManager.h
//  gifDemo
//
//  Created by djr on 2020/2/26.
//  Copyright © 2020 djr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRDataStateManager : NSObject

+ (instancetype)shareInstance;

@property (readonly, nonatomic, nullable) NSArray <NSArray *>*dataSources;

+ (void)giveDataSource:(NSArray <NSArray *>*)dataSource;

+ (void)changeState:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
