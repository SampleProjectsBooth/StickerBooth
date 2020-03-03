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

+ (NSArray <PHAsset *>*)jr_GetAllPhotos;

+ (PHImageRequestID)jr_GetPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

@end

NS_ASSUME_NONNULL_END
