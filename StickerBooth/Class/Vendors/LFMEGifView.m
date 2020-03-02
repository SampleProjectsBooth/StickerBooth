//
//  LFMEGifView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/24.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "LFMEGifView.h"
#import "LFMEWeakSelectorTarget.h"
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

inline static CGImageRef LFMEGifView_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size)
{
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    if (size.width > 0 && size.height > 0) {
        float verticalRadio = size.height*1.0/height;
        float horizontalRadio = size.width*1.0/width;
        
        float radio = 1;
        if(verticalRadio > horizontalRadio){
            radio = verticalRadio;
        }
        else{
            radio = horizontalRadio;
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
    // BGRA8888 (premultiplied) or BGRX8888
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) return NULL;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
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
    self.backgroundColor = [UIColor clearColor];
    _autoPlay = YES;
    _duration = 0.1f;
    _imageRefs = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    [self freeData];
    [self unsetupDisplayLink];
}

- (void)freeData
{
    [self unsetupDisplayLink];
    _image = nil;
    _data = nil;
    _frameCount = 0;
    _duration = 0.1f;
    _loopTimes = 0;
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = nil;
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
            if (_image.images.count > 1) {
                _frameCount = _image.images.count;
                _duration = _image.duration / _image.images.count;
                [self setupDisplayLink];
            } else {
                [self unsetupDisplayLink];
                CGImageRef imageRef = LFMEGifView_CGImageScaleDecodedFromCopy(_image.CGImage, self.frame.size);
                self.layer.contents = (__bridge id _Nullable)(imageRef);
                if (imageRef) {
                    CGImageRelease(imageRef);
                }
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
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, i, NULL);
                    if (!imageRef) {
                        continue;
                    }
                    
                    duration += [_durations[i] floatValue];
                    
                    [images addObject:[UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
                    
                    CGImageRelease(imageRef);
                }
                
                if (!duration) {
                    duration = (1.0f / 10.0f) * _frameCount;
                }
                
                _image = [UIImage animatedImageWithImages:images duration:duration];
            } else {
                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, 0, NULL);
                UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
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
            _gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
            _frameCount = CGImageSourceGetCount(_gifSourceRef);
            
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
                CGImageRef imageRef = LFMEGifView_CGImageScaleDecodedFromCopy(self.image.CGImage, self.frame.size);
                self.layer.contents = (__bridge id _Nullable)(imageRef);
                if (imageRef) {
                    CGImageRelease(imageRef);
                }
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
                imageRef = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
            } else if (_image) {
                imageRef = [[_image.images objectAtIndex:_index] CGImage];
            }
            if (imageRef) {
                CGImageRef decodeImageRef = LFMEGifView_CGImageScaleDecodedFromCopy(imageRef, self.frame.size);
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
            NSString *address = [NSString stringWithFormat:@"%p", self];
            if (![[[JRTestManager shareInstance] context] containsObject:address]) {
                [[[JRTestManager shareInstance] context] addObject:address];
                NSLog(@"play:%ld-%@ %ld", [[[JRTestManager shareInstance] context] indexOfObject:address], address, [[JRTestManager shareInstance] context].count);
            }
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
