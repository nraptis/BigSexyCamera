//
//  CameraScan.h
//  OptimizeRX
//
//  Created by Nicholas Raptis on 8/28/15.
//  Copyright (c) 2015 Darkswarm LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>


@class CameraScanContainer;
@interface CameraScan : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate>
{
    
    AVCaptureSession                            *session;
    CameraScanContainer                         *container;
    AVCaptureDevice                             *device;
    
    UIImageView                                 *imageViewCameraFeed;
    UIImageView                                 *imageViewCameraFeedProcessed;
    
    BOOL                                        isSettingImage;
    
    int                                         videoWidth;
    int                                         videoHeight;
    
    unsigned int                                *mImageDataSnapshot;
    
    CGImageRef                                  imageRefSnapshot;
    CGColorSpaceRef                             rgbColorSpace;
    CGContextRef                                contextSnapshot;
    
    float                                       cardFrameX;
    float                                       cardFrameY;
    float                                       cardFrameWidth;
    float                                       cardFrameHeight;
    
    unsigned int                                *dataRaw;
    unsigned int                                **data;
    
    int                                         dataWidth;
    int                                         dataHeight;
    
    BOOL                                        edgeDetectedU;
    BOOL                                        edgeDetectedR;
    BOOL                                        edgeDetectedD;
    BOOL                                        edgeDetectedL;
    
    BOOL                                        edgeInnerDetectedU;
    BOOL                                        edgeInnerDetectedR;
    BOOL                                        edgeInnerDetectedD;
    BOOL                                        edgeInnerDetectedL;
    
    BOOL                                        isCapturingStillImage;
    
    AVCaptureStillImageOutput                   *stillImageOutput;
    UIImage                                     *stillImage;

}

@property (nonatomic, retain) AVCaptureSession *session;

@property (nonatomic, retain) CameraScanContainer *container;
@property (nonatomic, retain) AVCaptureDevice *device;

@property (nonatomic, strong) UIImageView *imageViewCameraFeed;
@property (nonatomic, strong) UIImageView *imageViewCameraFeedProcessed;



@property (nonatomic, assign) float cardFrameX;
@property (nonatomic, assign) float cardFrameY;
@property (nonatomic, assign) float cardFrameWidth;
@property (nonatomic, assign) float cardFrameHeight;


@property (nonatomic, assign) BOOL edgeDetectedU;
@property (nonatomic, assign) BOOL edgeDetectedR;
@property (nonatomic, assign) BOOL edgeDetectedD;
@property (nonatomic, assign) BOOL edgeDetectedL;

@property (nonatomic, assign) BOOL edgeInnerDetectedU;
@property (nonatomic, assign) BOOL edgeInnerDetectedR;
@property (nonatomic, assign) BOOL edgeInnerDetectedD;
@property (nonatomic, assign) BOOL edgeInnerDetectedL;


@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)click:(UIButton *)sender;

- (void)setCameraImage:(UIImage *)targetImage;
- (void)setCameraImageProcessed:(UIImage *)targetImage;

+ (BOOL)canUseCamera;

- (void)stopCaptureSession;
- (void)startCaptureSession;
- (void)setupCaptureSession;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer  fromConnection:(AVCaptureConnection *)connection;


- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)snapPicture;

- (void)processCardEdges;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (void)nuke;
- (void)dealloc;



@end
