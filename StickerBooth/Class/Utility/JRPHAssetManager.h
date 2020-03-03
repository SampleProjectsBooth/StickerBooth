//
//  JRPHAssetManager.h
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRPHAssetManager : NSObject

+ (void)jr_GetAllPhotos:(void(^)(NSArray <PHAsset *>*photos))completeBlock;

@end

NS_ASSUME_NONNULL_END
