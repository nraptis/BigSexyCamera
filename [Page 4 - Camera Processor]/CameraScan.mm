//
//  CameraScan.m
//  OptimizeRX
//
//  Created by Nicholas Raptis on 8/28/15.
//  Copyright (c) 2015 Darkswarm LLC. All rights reserved.
//

//#include "OpenCV/OpenCV/opencv2/highgui/highgui.hpp"
//#include "OpenCV/OpenCV/opencv2/imgproc/imgproc.hpp"

#define  THRESHOLD 60.0
#define  THRESHOLDI 80


#define IMAGE_ALPHA_SHIFT(integer)((((unsigned int)integer)<<24)&0xFF000000)
#define IMAGE_ALPHA(color)(((color)>>24)&0xFF)
#define IMAGE_ALPHA_BITS (0xFF000000)
#define IMAGE_ALPHA_INVERSE (~IMAGE_ALPHA_BITS)

#define IMAGE_RED_SHIFT(integer)((((unsigned int)integer))&0x000000FF)
#define IMAGE_RED(color)(((color))&0xFF)
#define IMAGE_RED_BITS (0x000000FF)
#define IMAGE_RED_INVERSE (~IMAGE_RED_BITS)

#define IMAGE_GREEN_SHIFT(integer)((((unsigned int)integer)<<8)&0x0000FF00)
#define IMAGE_GREEN(color)(((color)>>8)&0xFF)
#define IMAGE_GREEN_BITS (0xFF000000)
#define IMAGE_GREEN_INVERSE (~IMAGE_GREEN_BITS)

#define IMAGE_BLUE_SHIFT(integer)((((unsigned int)integer)<<16)&0x00FF0000)
#define IMAGE_BLUE(color)(((color)>>16)&0xFF)
#define IMAGE_BLUE_BITS (0x00FF0000)
#define IMAGE_BLUE_INVERSE (~IMAGE_BLUE_BITS)

#define IMAGE_GREY(color)((IMAGE_RED(color) + IMAGE_GREEN(color) + IMAGE_BLUE(color)) / 3)

#define IMAGE_RGBA(__LOCAL_RED,__LOCAL_GREEN,__LOCAL_BLUE,__LOCAL_ALPHA) ((((unsigned int)__LOCAL_RED))&0x000000FF) | ((((unsigned int)__LOCAL_GREEN)<<8)&0x0000FF00) | ((((unsigned int)__LOCAL_BLUE)<<16)&0x00FF0000) | ((((unsigned int)__LOCAL_ALPHA)<<24)&0xFF000000)

#import "CameraScan.h"
#import "CameraScanContainer.h"
#import "RootViewController.h"
#import "UtilityMethods.h"

@implementation CameraScan

@synthesize session;
@synthesize device;

@synthesize container;
@synthesize imageViewCameraFeed;
@synthesize imageViewCameraFeedProcessed;

@synthesize cardFrameX;
@synthesize cardFrameY;
@synthesize cardFrameWidth;
@synthesize cardFrameHeight;

@synthesize edgeDetectedU;
@synthesize edgeDetectedR;
@synthesize edgeDetectedD;
@synthesize edgeDetectedL;

@synthesize edgeInnerDetectedU;
@synthesize edgeInnerDetectedR;
@synthesize edgeInnerDetectedD;
@synthesize edgeInnerDetectedL;

@synthesize stillImageOutput;
@synthesize stillImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    dataRaw = 0;
    data = 0;
    
    dataWidth = 0;
    dataHeight = 0;
    
    mImageDataSnapshot = 0;
    isSettingImage = NO;
    
    edgeDetectedU = NO;
    edgeDetectedR = NO;
    edgeDetectedD = NO;
    edgeDetectedL = NO;
    
    edgeInnerDetectedU = NO;
    edgeInnerDetectedR = NO;
    edgeInnerDetectedD = NO;
    edgeInnerDetectedL = NO;
    
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float aWidth = [RootViewController appWidth];
    float aHeight = [RootViewController appHeight];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, aWidth, aHeight);
    
    [self setupCaptureSession];
    [self startCaptureSession];
    
    
    [super viewDidLoad];
    
    [self.view setMultipleTouchEnabled:YES];
}

- (IBAction)click:(UIButton *)sender
{
    
}

- (void)setCameraImage:(UIImage *)targetImage
{
    if(imageViewCameraFeed == nil)
    {
        self.imageViewCameraFeed = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [RootViewController appWidth], [RootViewController appHeight])];
        [self.view addSubview:imageViewCameraFeed];
    }
    imageViewCameraFeed.image = targetImage;
}

- (void)setCameraImageProcessed:(UIImage *)targetImage
{
    if(imageViewCameraFeedProcessed == nil)
    {
        self.imageViewCameraFeedProcessed = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [RootViewController appWidth], [RootViewController appHeight])];
        [self.view addSubview:imageViewCameraFeedProcessed];
    }
    imageViewCameraFeedProcessed.image = targetImage;
}


+ (BOOL)canUseCamera
{
    NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *aDevice in captureDevices)
    {
        if(aDevice != nil)return YES;
    }
    return NO;
}

- (void)stopCaptureSession
{
    [session stopRunning];
}

- (void)startCaptureSession
{
    isCapturingStillImage = NO;
    if([CameraScan canUseCamera])[session startRunning];
    else [self stopCaptureSession];
}

- (void)snapPicture
{
    if(isCapturingStillImage == NO)
    {
    isCapturingStillImage = YES;
    
    AVCaptureConnection *videoConnection = nil;
    for(AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
        if(videoConnection)break;
        for(AVCaptureInputPort *port in [connection inputPorts])
        {
            if([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        
    }
        
    if((stillImageOutput != nil) && (videoConnection != nil))
    {
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             [self performSelectorOnMainThread:@selector(stopCaptureSession) withObject:nil waitUntilDone:YES];
             
             
             UIImage *aImage = [[UIImage alloc] initWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer]];
  
             float aScale = 8.0f;
             aImage = CropImageAspect(aImage, CGSizeMake(self.view.frame.size.width * aScale, self.view.frame.size.height * aScale), 0.0f);
             
             //NSLog(@"Aspect Image[%f x %f]", aImage.size.width, aImage.size.height);
             
             aImage = CropImage(aImage, 1.0f, cardFrameX * aScale, cardFrameY * aScale, cardFrameWidth * aScale, cardFrameHeight * aScale);
             
             ExportToPhotoLibrary(aImage);
             
             [container performSelectorOnMainThread:@selector(snapPictureComplete:) withObject:aImage waitUntilDone:YES];
         }];
    }
    }
    
    
    //[NSThread sleepForTimeInterval:0.1f];
    //[self stopCaptureSession];
    
    /*
     UIImage *aImage = imageViewCameraFeed.image;
     [NSThread sleepForTimeInterval:0.06f];
     
     //[self stopCaptureSession];
     
     float aScale = 2.0f;
     aImage = CropImage(aImage, 1.0f, cardFrameX * aScale, cardFrameY * aScale, cardFrameWidth * aScale, cardFrameHeight * aScale);
     */
    
    /*
     
     CGSize size = aImage.size;
     UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
     [[UIImage imageWithCGImage:[aImage CGImage] scale:1.0 orientation: UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
     aImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     
     float aScale = 2.0f;
     aImage = CropImageAspect(aImage, CGSizeMake(self.view.frame.size.width * aScale, self.view.frame.size.height * aScale), 0.0f);
     
     [self performSelectorOnMainThread:@selector(setCameraImage:) withObject:aImage waitUntilDone:YES];
     //CGAffineTransform aTransform = CGAffineTransformIdentity;
     */
    
    //UIImage *aImageCrop = CropImage(aImage, 0.5f, cardFrameX, cardFrameY, cardFrameWidth, cardFrameHeight);
    
    
    //return aImage;
}

- (void)setupCaptureSession
{
    rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    videoWidth = (int)self.view.frame.size.width;  //cameraScreenContainer.view.frame.size.width;
    videoHeight = (int)self.view.frame.size.height;  //cameraScreenContainer.view.frame.size.height;
    
    if([RootViewController isTablet] == NO)
    {
        videoWidth *= 2.0f;
        videoHeight *= 2.0f;
    }
    
    mImageDataSnapshot = new unsigned int[videoWidth * videoHeight];//malloc(videoWidth * videoHeight * 4);
    contextSnapshot = CGBitmapContextCreate(mImageDataSnapshot, videoWidth, videoHeight, 8, videoWidth*4, rgbColorSpace, kCGImageAlphaNoneSkipLast);
    
    CGContextScaleCTM(contextSnapshot, 1.0f, -1.0f);
    CGContextTranslateCTM(contextSnapshot, 0.0f, -videoHeight);
    
    imageRefSnapshot = CGBitmapContextCreateImage(contextSnapshot);
    
    NSError *aError = nil;
    AVCaptureSession *aSession = [[AVCaptureSession alloc] init];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *aInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&aError];
    
    int flags = NSKeyValueObservingOptionNew;
    [device addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    
    //aSession.sessionPreset = AVCaptureSessionPresetMedium;
    aSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [session beginConfiguration];
    [device lockForConfiguration:nil];
    
    [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
    
    [aSession addInput:aInput];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [aSession addOutput:output];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [stillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    [aSession addOutput:stillImageOutput];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    output.videoSettings =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [aSession startRunning];
    [self setSession:aSession];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer  fromConnection:(AVCaptureConnection *)connection
{
    if(isSettingImage)
    {
        NSLog(@"Was Already Setting Image?");
        return;
    }
    
    isSettingImage = true;
    
    CGImageRef aImageRef = [self imageFromSampleBuffer:sampleBuffer];
    
    UIImage *aImage = [UIImage imageWithCGImage:aImageRef];
    
    CGSize size = aImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[aImage CGImage] scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(aImageRef);
    
    float aScale = 2.0f;
    aImage = CropImageAspect(aImage, CGSizeMake(self.view.frame.size.width * aScale, self.view.frame.size.height * aScale), 0.0f);
    
    [self performSelectorOnMainThread:@selector(setCameraImage:) withObject:aImage waitUntilDone:YES];
    
    float aWidth = aImage.size.width;
    float aHeight = aImage.size.height;
    int aImageWidth = (int)(aWidth + 0.1f);
    int aImageHeight = (int)(aHeight + 0.1f);
    
    int aArea = aImageWidth * aImageHeight;
    
    if(dataRaw == 0)
    {
        dataWidth = aImageWidth;
        dataHeight = aImageHeight;
        
        dataRaw = new unsigned int[aArea];
        data = new unsigned int*[aImageHeight];
        unsigned int *aPtr=dataRaw;
        
        for(int n=0;n<aImageHeight;n++)
        {
            data[n]=aPtr;
            aPtr+=aImageWidth;
        }
    }
    
    CGImageRef aCGImage=aImage.CGImage;
    CGColorSpaceRef aColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef aCGContext=CGBitmapContextCreate(dataRaw, dataWidth, dataHeight, 8, dataWidth*4, aColorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(aCGContext, CGRectMake(0, 0, dataWidth, dataHeight));
    CGContextDrawImage(aCGContext, CGRectMake(0, 0, dataWidth, dataHeight),aCGImage);
    CGContextRelease(aCGContext);
    CGColorSpaceRelease(aColorSpace);
    
    [self processCardEdges];
    
    isSettingImage = false;
}

- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    return newImage;
}


- (void)processCardEdges
{
    if((data == 0) || (dataWidth < 10) || (dataHeight < 10))return;
    
    for(int aPassIndex=0;aPassIndex<3;aPassIndex++)
    {
        int aFrameX1 = cardFrameX * 2;
        int aFrameY1 = cardFrameY * 2;
        
        int aFrameX2 = aFrameX1 + cardFrameWidth * 2;
        int aFrameY2 = aFrameY1 + cardFrameHeight * 2;
        
        if(aPassIndex == 1)
        {
            aFrameX1 += (int)(cardFrameWidth / 11);aFrameY1 += (int)(cardFrameHeight / 11);
            aFrameX2 -= (int)(cardFrameWidth / 11);aFrameY2 -= (int)(cardFrameHeight / 11);
        }
        
        if(aPassIndex == 2)
        {
            aFrameX1 += (int)(cardFrameWidth / 7);aFrameY1 += (int)(cardFrameHeight / 7);
            aFrameX2 -= (int)(cardFrameWidth / 7);aFrameY2 -= (int)(cardFrameHeight / 7);
        }
        
        int aX = 0, aY = 0, aDelta = 0, aStep = 6;
        int aCount[4];int aCountHit[4];
        
        int aDR = 0, aDG = 0, aDB = 0;
        
        int aSpan = 20;
        if((aPassIndex == 1) || (aPassIndex == 2))aSpan = 24;
        
        aCount[0] = 0;aCountHit[0] = 0;aCount[1] = 0;aCountHit[1] = 0;
        aCount[2] = 0;aCountHit[2] = 0;aCount[3] = 0;aCountHit[3] = 0;
        
        int aThresh = 62;
        if(aPassIndex == 1)aThresh = 56;
        if(aPassIndex == 2)aThresh = 52;
        
        aY = aFrameY1;
        for(aX=aFrameX1;aX<=aFrameX2;aX+=aStep)
        {
            aDR = IMAGE_RED(data[aY-aSpan][aX]) - IMAGE_RED(data[aY+aSpan][aX]);
            aDG = IMAGE_GREEN(data[aY-aSpan][aX]) - IMAGE_GREEN(data[aY+aSpan][aX]);
            aDB = IMAGE_BLUE(data[aY-aSpan][aX]) - IMAGE_BLUE(data[aY+aSpan][aX]);
            if(aDR < 0)aDR = -aDR;if(aDG < 0)aDG = -aDG;if(aDB < 0)aDB = -aDB;
            aDelta = (aDR + aDG + aDB);aCount[0]++;
            if(aDelta > aThresh)aCountHit[0]++;
        }
        
        aY = aFrameY2;
        for(aX=aFrameX1;aX<=aFrameX2;aX+=aStep)
        {
            aDR = IMAGE_RED(data[aY-aSpan][aX]) - IMAGE_RED(data[aY+aSpan][aX]);
            aDG = IMAGE_GREEN(data[aY-aSpan][aX]) - IMAGE_GREEN(data[aY+aSpan][aX]);
            aDB = IMAGE_BLUE(data[aY-aSpan][aX]) - IMAGE_BLUE(data[aY+aSpan][aX]);
            if(aDR < 0)aDR = -aDR;if(aDG < 0)aDG = -aDG;if(aDB < 0)aDB = -aDB;
            aDelta = (aDR + aDG + aDB);aCount[2]++;
            if(aDelta > aThresh)aCountHit[2]++;
        }
        
        aX = aFrameX1;
        for(aY=aFrameY1;aY<=aFrameY2;aY+=aStep)
        {
            aDR = IMAGE_RED(data[aY][aX-aSpan]) - IMAGE_RED(data[aY][aX+aSpan]);
            aDG = IMAGE_GREEN(data[aY][aX-aSpan]) - IMAGE_GREEN(data[aY][aX+aSpan]);
            aDB = IMAGE_BLUE(data[aY][aX-aSpan]) - IMAGE_BLUE(data[aY][aX+aSpan]);
            if(aDR < 0)aDR = -aDR;if(aDG < 0)aDG = -aDG;if(aDB < 0)aDB = -aDB;
            aDelta = (aDR + aDG + aDB);aCount[3]++;
            if(aDelta > aThresh)aCountHit[3]++;
        }
        
        aX = aFrameX2;
        for(aY=aFrameY1;aY<=aFrameY2;aY+=aStep)
        {
            aDR = IMAGE_RED(data[aY][aX-aSpan]) - IMAGE_RED(data[aY][aX+aSpan]);
            aDG = IMAGE_GREEN(data[aY][aX-aSpan]) - IMAGE_GREEN(data[aY][aX+aSpan]);
            aDB = IMAGE_BLUE(data[aY][aX-aSpan]) - IMAGE_BLUE(data[aY][aX+aSpan]);
            if(aDR < 0)aDR = -aDR;if(aDG < 0)aDG = -aDG;if(aDB < 0)aDB = -aDB;
            aDelta = (aDR + aDG + aDB);aCount[1]++;
            if(aDelta > aThresh)aCountHit[1]++;
        }
        
        float aPercent[4];
        aPercent[0] = ((float)aCountHit[0]) / ((float)aCount[0]);aPercent[1] = ((float)aCountHit[1]) / ((float)aCount[1]);
        aPercent[2] = ((float)aCountHit[2]) / ((float)aCount[2]);aPercent[3] = ((float)aCountHit[3]) / ((float)aCount[3]);
        
        if(aPassIndex == 0)
        {
            edgeDetectedU = (aPercent[0] > 0.60f);edgeDetectedR = (aPercent[1] > 0.60f);
            edgeDetectedD = (aPercent[2] > 0.60f);edgeDetectedL = (aPercent[3] > 0.60f);
        }
        
        if(aPassIndex == 1)
        {
            edgeInnerDetectedU = (aPercent[0] > 0.50f);edgeInnerDetectedR = (aPercent[1] > 0.50f);
            edgeInnerDetectedD = (aPercent[2] > 0.50f);edgeInnerDetectedL = (aPercent[3] > 0.50f);
        }
        
        if(aPassIndex == 2)
        {
            if(edgeInnerDetectedU == false)edgeInnerDetectedU = (aPercent[0] > 0.50f);
            if(edgeInnerDetectedR == false)edgeInnerDetectedR = (aPercent[1] > 0.50f);
            if(edgeInnerDetectedD == false)edgeInnerDetectedD = (aPercent[2] > 0.50f);
            if(edgeInnerDetectedL == false)edgeInnerDetectedL = (aPercent[3] > 0.50f);
        }
    }
    
    [container performSelectorOnMainThread:@selector(refreshEdges) withObject:nil waitUntilDone:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"adjustingFocus"])
    {
        //BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
    }
}


- (void)nuke
{
    [self stopCaptureSession];
    
    self.session = nil;
    self.stillImageOutput = nil;
    
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
    self.device = nil;
    
    self.container = nil;
    
    [NSThread sleepForTimeInterval:0.172f];
    
    self.session = nil;
    
    delete [] data;
    data = 0;
    
    delete [] dataRaw;
    dataRaw = 0;
    
    if(mImageDataSnapshot)
    {
        CGContextRelease(contextSnapshot);CGColorSpaceRelease(rgbColorSpace);
        delete[]mImageDataSnapshot;mImageDataSnapshot = 0;
    }
    
    imageViewCameraFeed.image = nil;
    [imageViewCameraFeed removeFromSuperview];
    self.imageViewCameraFeed = nil;
    
    imageViewCameraFeedProcessed.image = nil;
    [imageViewCameraFeedProcessed removeFromSuperview];
    self.imageViewCameraFeedProcessed = nil;
    
    [self.view removeFromSuperview];
}

- (void)dealloc
{
    [self nuke];
}




@end


