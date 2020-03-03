//
//  LFMEGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEGifView.h"
#import "LFMEWeakSelectorTarget.h"
#import <ImageIO/ImageIO.h>
#import "JRTestManager.h"

inline static NSTimeInterval LFMEGifView_CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    if (dictRef) CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        frameDuration = unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        frameDuration = delayTime.floatValue;
    }else{
        frameDuration = .1;
    }
    return frameDuration;
}

inline static CGAffineTransform LFMEGifView_CGAffineTransformExchangeOrientation(UIImageOrientation imageOrientation, CGSize size)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

inline static CGImageRef LFMEGifView_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size, UIViewContentMode contentMode, UIImageOrientation orientation)
{
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    if (size.width > 0 && size.height > 0) {
        float verticalRadio = size.height*1.0/height;
        float horizontalRadio = size.width*1.0/width;
        
        
        float radio = 1;
        if (contentMode == UIViewContentModeScaleAspectFill) {
            if(verticalRadio > horizontalRadio)
            {
                radio = verticalRadio;
            }
            else
            {
                radio = horizontalRadio;
            }
        } else {
            if(verticalRadio>1 && horizontalRadio>1)
            {
                radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
            }
            else
            {
                radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
            }

        }
        
        width = roundf(width*radio);
        height = roundf(height*radio);
    }
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
        {
            CGFloat tmpWidth = width;
            width = height;
            height = tmpWidth;
        }
            break;
        default:
            break;
    }
    
    CGAffineTransform transform = LFMEGifView_CGAffineTransformExchangeOrientation(orientation, CGSizeMake(width, height));
    // BGRA8888 (premultiplied) or BGRX8888
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) return NULL;
    CGContextConcatCTM(context, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(context, CGRectMake(0, 0, height, width), imageRef); // decode
            break;
        default:
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
            break;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return newImage;
}

inline static UIImageOrientation LFMEGifView_UIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

@interface LFMEGifView ()
{
    CADisplayLink *_displayLink;
    
    NSInteger _index;
    NSInteger _frameCount;
    CGFloat _timestamp;
    NSUInteger _loopTimes;
    
    CGImageSourceRef _gifSourceRef;
    
    NSTimeInterval _duration;
}

@property (readonly, nonatomic, nullable) NSArray<NSNumber *> * durations;

@property (readonly, nonatomic, nullable) NSMutableDictionary<NSNumber *, id> *imageRefs;

@property (nonatomic, assign) UIImageOrientation orientation;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation LFMEGifView

@synthesize image = _image;

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    NSString *address = [NSString stringWithFormat:@"%p", self];
    if (![[[JRTestManager shareInstance] cells] containsObject:address]) {
        [[JRTestManager shareInstance].cells addObject:address];
    }
    self.backgroundColor = [UIColor clearColor];
    _autoPlay = YES;
    _duration = 0.1f;
    _imageRefs = [NSMutableDictionary dictionary];
    _orientation = UIImageOrientationUp;
    _serialQueue = dispatch_queue_create("LFMEGifViewSerial", DISPATCH_QUEUE_SERIAL);
}

- (void)dealloc
{
    [self freeData];
    [self unsetupDisplayLink];
    NSString *address = [NSString stringWithFormat:@"%p", self];
    if ([[[JRTestManager shareInstance] cells] containsObject:address]) {
        [[JRTestManager shareInstance].cells removeObject:address];
    }
}

- (void)freeData
{
    if (_data) {
        [JRTestManager shareInstance].count = [JRTestManager shareInstance].count - 1;
    }
    [self unsetupDisplayLink];
    _orientation = 0;
    _image = nil;
    _data = nil;
    _frameCount = 0;
    _duration = 0.1f;
    _loopTimes = 0;
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = NULL;
    }
    _index = 0;
    _timestamp = 0;
    _durations = nil;
    
    for (id object in self.imageRefs) {
        CGImageRef imageRef = (__bridge CGImageRef)object;
        CGImageRelease(imageRef);
    }
    [self.imageRefs removeAllObjects];
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        [self freeData];
        _image = image;
        if (image) {
            _orientation = image.imageOrientation;
            if (_image.images.count > 1) {
                _frameCount = _image.images.count;
                _duration = _image.duration / _image.images.count;
                [self setupDisplayLink];
            } else {
                [self unsetupDisplayLink];
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                UIImageOrientation orientation = self.orientation;
                dispatch_async(self.serialQueue, ^{
                    CGImageRef decodeImageRef = LFMEGifView_CGImageScaleDecodedFromCopy(image.CGImage, size, mode, orientation);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.layer.contents = (__bridge id _Nullable)(decodeImageRef);
                        if (decodeImageRef) {
                            CGImageRelease(decodeImageRef);
                        }
                    });
                });
            }
        } else {
            [self unsetupDisplayLink];
        }
    }
}

- (UIImage *)image
{
    if (_image == nil) {
        
        if (self.data) {
            if (_frameCount > 1) {
                NSMutableArray *images = [NSMutableArray array];
                NSTimeInterval duration = 0.0f;
                
                for (size_t i = 0; i < _frameCount; i++) {
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, i, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                    if (!imageRef) {
                        continue;
                    }
                    
                    duration += [_durations[i] floatValue];
                    
                    [images addObject:[UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:self.orientation]];
                    
                    CGImageRelease(imageRef);
                }
                
                if (!duration) {
                    duration = (1.0f / 10.0f) * _frameCount;
                }
                
                _image = [UIImage animatedImageWithImages:images duration:duration];
            } else {
                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 0, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:self.orientation];
                if (imageRef) {
                    CGImageRelease(imageRef);
                }
                if (image == nil) {
                    image = [UIImage imageWithData:self.data scale:[UIScreen mainScreen].scale];
                }
                _image = image;
            }
        }
    }
    return _image;
}

- (void)setData:(NSData *)data
{
    if (_data != data) {
        [self freeData];
        _data = data;
        if (data) {
            [JRTestManager shareInstance].count = [JRTestManager shareInstance].count + 1;
            _gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
            _frameCount = CGImageSourceGetCount(_gifSourceRef);
            
            //exifInfo 包含了很多信息,有兴趣的可以打印看看,我们只需要Orientation这个字段
            CFDictionaryRef exifInfo = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, 0,NULL);
            
            //判断Orientation这个字段,如果图片经过PS等处理,exif信息可能会丢失
            if(CFDictionaryContainsKey(exifInfo, kCGImagePropertyOrientation)){
                CFNumberRef orientation = CFDictionaryGetValue(exifInfo, kCGImagePropertyOrientation);
                NSInteger orientationValue = 0;
                CFNumberGetValue(orientation, kCFNumberIntType, &orientationValue);
                _orientation = LFMEGifView_UIImageOrientationFromEXIFValue(orientationValue);
            }
            CFRelease(exifInfo);
            
            
            if (_frameCount > 1) {
                NSInteger index = 0;
                NSMutableArray *durations = [NSMutableArray array];
                while (index < _frameCount) {
                    [durations addObject:@(LFMEGifView_CGImageSourceGetGifFrameDelay(_gifSourceRef, index))];
                    index ++;
                }
                _durations = [durations copy];
                [self setupDisplayLink];
            } else {
                [self unsetupDisplayLink];
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                UIImageOrientation orientation = self.orientation;
                dispatch_async(self.serialQueue, ^{
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(self->_gifSourceRef, 0, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                    CGImageRef decodeImageRef = LFMEGifView_CGImageScaleDecodedFromCopy(imageRef, size, mode, orientation);
                    if (imageRef) {
                        CGImageRelease(imageRef);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.layer.contents = (__bridge id _Nullable)(decodeImageRef);
                        if (decodeImageRef) {
                            CGImageRelease(decodeImageRef);
                        }
                    });
                });
            }
        } else {
            [self unsetupDisplayLink];
        }
    }
}

- (void)setAutoPlay:(BOOL)autoPlay
{
    _autoPlay = autoPlay;
    if (autoPlay) {
        [self playGif];
    } else {
        [self stopGif];
    }
}

#pragma mark - option
- (void)stopGif
{
    _displayLink.paused = YES;
}

- (void)playGif
{
    _displayLink.paused = NO;
}

#pragma mark - CADisplayLink

- (void)setupDisplayLink {
    if (_displayLink == nil && _frameCount > 1) {
        LFMEWeakSelectorTarget *target = [[LFMEWeakSelectorTarget alloc] initWithTarget:self targetSelector:@selector(displayGif)];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:target selector:target.handleSelector];
        
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        if (!_autoPlay) {
            [self stopGif];
        } else {
            [self playGif];
        }
    }
}

- (void)unsetupDisplayLink {
    if (_displayLink != nil) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - Gif
- (void)displayGif
{
    size_t sizeMin = MIN(_index+1, _frameCount-1);
    if (sizeMin == SIZE_MAX) {
        //若该Gif文件无法解释为图片，需要立即返回避免内存crash
        NSLog(@"Unable to interpret gif data");
        [self freeData];
        [self unsetupDisplayLink];
        return;
    }
    
    _timestamp += fmin(_displayLink.duration, 1);
    
    while (_timestamp >= [self frameDurationAtIndex:_index]) {
        _timestamp -= [self frameDurationAtIndex:_index];
        
        CGImageRef imageRef = (__bridge CGImageRef)([self.imageRefs objectForKey:@(_index)]);
        if (imageRef == NULL) {
            if (_gifSourceRef) {
                imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
            } else if (_image) {
                imageRef = [[_image.images objectAtIndex:_index] CGImage];
            }
            if (imageRef) {
                CGImageRef decodeImageRef = LFMEGifView_CGImageScaleDecodedFromCopy(imageRef, self.frame.size, self.contentMode, self.orientation);
                if (_gifSourceRef && imageRef) {
                    CGImageRelease(imageRef);
                }
                [self.imageRefs setObject:(__bridge id _Nullable)(decodeImageRef) forKey:@(_index)];
                imageRef = decodeImageRef;
            }
        }
        
        if (imageRef) {
            self.layer.contents = (__bridge id _Nullable)(imageRef);
        }
        
        
        _index += 1;
        if (_index == _frameCount) {
            _index = 0;
            if (_loopCount == ++_loopTimes) {
                [self stopGif];
                return;
            }
        }
    }
}

- (float)frameDurationAtIndex:(NSUInteger)index
{
    if (_durations) {
        return _durations[index%_durations.count].floatValue;
    } else {
        return _duration;
    }
}

@end
