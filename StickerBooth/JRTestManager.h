//
//  JRTestManager.h
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRTestManager : NSObject

+ (instancetype)shareInstance;

@property (assign, nonatomic) NSInteger count;

@property (strong, nonatomic) NSMutableArray *cells;

@end

NS_ASSUME_NONNULL_END
