//
//  JRPHAssetManager.m
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRPHAssetManager.h"

@interface JRPHAssetManager ()

@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation JRPHAssetManager

static JRPHAssetManager *_manager = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.jr.phasset", DISPATCH_QUEUE_CONCURRENT);
    } return self;
}


+ (void)jr_GetAllPhotos:(void(^)(NSArray <PHAsset *>*photos))completeBlock
{
    if (!_manager) {
        _manager = [[JRPHAssetManager alloc] init];
    }
    
    dispatch_async(_manager.queue, ^{
        NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:1];
        if (@available(iOS 8.0, *)){
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            
            PHFetchResult *fetchResult = nil;
            for (PHAssetCollection *collection in smartAlbums) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                break;
            }
            
            for (PHAsset *asset in fetchResult) {
                [stickers addObject:asset];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock([stickers copy]);
            }
        });
    });
}


@end

