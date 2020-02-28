//
//  JRTestManager.h
//  StickerBooth
//
//  Created by djr on 2020/2/28.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRTestManager : NSObject

+ (instancetype)shareInstance;

@property (strong, nonatomic) NSMutableArray *context;

@end

NS_ASSUME_NONNULL_END
