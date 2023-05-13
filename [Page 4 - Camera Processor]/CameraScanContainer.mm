

#import "CameraScanContainer.h"
#import "CameraScan.h"

#import "InsuranceSearchPage.h"
#import "InsuranceCardScanner.h"
#import "RootViewController.h"

#import "UtilityMethods.h"

@implementation CameraScanContainer

@synthesize buttonOkay;
@synthesize buttonClose;
@synthesize buttonRetake;

@synthesize imageViewAnimateIn;
@synthesize imageViewPicture;

@synthesize labelInstructions1;
@synthesize labelInstructions2;

@synthesize imageViewArrow1;
@synthesize imageViewArrow2;
@synthesize imageViewArrow3;
@synthesize imageViewArrow4;



@synthesize viewScanLine1;
@synthesize viewScanLine2;


@synthesize cameraScan;

@synthesize viewFlash;

@synthesize imagePicture;

@synthesize viewInnerFrame;

@synthesize viewBackmask1;
@synthesize viewBackmask2;
@synthesize viewBackmask3;
@synthesize viewBackmask4;

@synthesize viewEdgeU;
@synthesize viewEdgeR;
@synthesize viewEdgeD;
@synthesize viewEdgeL;

@synthesize viewCornUL1;
@synthesize viewCornUL2;
@synthesize viewCornUR1;
@synthesize viewCornUR2;
@synthesize viewCornDL1;
@synthesize viewCornDL2;
@synthesize viewCornDR1;
@synthesize viewCornDR2;

@synthesize timerUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    NSLog(@">>>> CameraScanContainer <<<<\n\n\n\n");
    
    didTakePic = NO;
    
    cardFrameX = 0.0f;
    cardFrameY = 0.0f;
    cardFrameWidth = [RootViewController appWidth];
    cardFrameHeight = [RootViewController appHeight];
    
    edgeCloserAlphaWobble = 0.0f;
    edgeCloserAlphaBase = 0.0f;

    for(int i=0;i<2;i++)
    {
        scanLineX[i] = 0.0f;
        scanLineDir[i] = 1;
        if((i % 2) == 1)scanLineDir[i] = -1;
        scanLineSpeed[i] = 3.0f;
        scanLineAlpha[i] = 0.0f;
    }
    
    
    
    for(int i=0;i<4;i++)
    {
        edgeOn[i] = false;
        edgeOnBack1[i] = false;
        edgeOnBack2[i] = false;
        edgeAlpha[i] = 0.0f;
        
        edgeInnerOn[i] = false;
        edgeInnerOnBack1[i] = false;
        edgeInnerOnBack2[i] = false;
        
    }
    
    edgeInnerOnTimer = 0;
    edgeOnTimer = 0;
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    
    float aWidth = [RootViewController appWidth];
    float aHeight = [RootViewController appHeight];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, aWidth, aHeight);
    
    
    
    
    
    //[self.view bringSubviewToFront:viewBackmask1];
    //[self.view bringSubviewToFront:viewBackmask2];
    //[self.view bringSubviewToFront:viewBackmask3];
    //[self.view bringSubviewToFront:viewBackmask4];
    
    [self.view bringSubviewToFront:viewInnerFrame];
    
    [self.view bringSubviewToFront:buttonRetake];
    [self.view bringSubviewToFront:buttonOkay];
    [self.view bringSubviewToFront:buttonClose];
    
    [self.view bringSubviewToFront:labelInstructions1];
    [self.view bringSubviewToFront:labelInstructions2];
    
    
    [self.view bringSubviewToFront:imageViewArrow1];
    [self.view bringSubviewToFront:imageViewArrow2];
    [self.view bringSubviewToFront:imageViewArrow3];
    [self.view bringSubviewToFront:imageViewArrow4];
    
    
    
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    float aWidth = [RootViewController appWidth];
    float aHeight = [RootViewController appHeight];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, aWidth, aHeight);
    
    self.cameraScan = [[CameraScan alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview:cameraScan.view];
    cameraScan.container = self;
    
    
    float aExpectedWidth = 726.0f;
    float aExpectedHeight = 470.0f;
    float aBorderSize = 36.0f;
    
    //FRect FRect::FitAspectFit(FRect pRect, float pObjectWidth, float pObjectHeight, float pBorder, float
    //&pScale)
    //{
        
        float aScale = 1.0f;
        
        aWidth = 0.0f;
        aHeight = 0.0f;
        
        float aImageWidth = aExpectedWidth;
        float aImageHeight = aExpectedHeight;
        
        float aProperWidth = self.view.frame.size.width - aBorderSize * 2.0f;
        float aProperHeight = self.view.frame.size.height - aBorderSize * 2.0f;
        
        aWidth = aProperWidth;
        aHeight = aProperHeight;
        
        if(aImageWidth > 0 && aImageHeight > 0 && aProperWidth > 0 && aProperHeight > 0)
        {
            if((aExpectedWidth / aExpectedHeight) > (aProperWidth / aProperHeight))
            {
                aScale = aProperWidth / aImageWidth;
                aWidth = aImageWidth * aScale;
                aHeight = aImageHeight * aScale;
            }
            else
            {
                aScale = aProperHeight / aImageHeight;
                aWidth = aImageWidth * aScale;
                aHeight = aImageHeight * aScale;
            }
        }
    
        float aX = (self.view.frame.size.width / 2.0f) - aWidth / 2.0f;
        float aY = (self.view.frame.size.height / 2.0f) - aHeight / 2.0f;
    
    if(aY > 80.0f)aY = 80.0f;
    
    
    float aRight = aX + aWidth;
    float aBottom = aY + aHeight;
    
    
    self.viewInnerFrame = [[UIView alloc] initWithFrame:CGRectMake(aX, aY, aWidth, aHeight)];
    viewInnerFrame.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f];
    [self.view addSubview:viewInnerFrame];
    
    self.viewBackmask1 = [[UIView alloc] initWithFrame:CGRectMake(aX, 0.0f, self.view.frame.size.width - ((self.view.frame.size.width - aWidth)), aY)];
    self.viewBackmask2 = [[UIView alloc] initWithFrame:CGRectMake(aRight, 0.0f, self.view.frame.size.width - aRight, self.view.frame.size.height)];
    self.viewBackmask3 = [[UIView alloc] initWithFrame:CGRectMake(aX, aBottom, self.view.frame.size.width - ((self.view.frame.size.width - aWidth)), self.view.frame.size.height - (aY + aHeight))];
    self.viewBackmask4 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aX, self.view.frame.size.height)];
    
    
    imageViewArrow1.alpha = 0.0f;
    imageViewArrow2.alpha = 0.0f;
    imageViewArrow3.alpha = 0.0f;
    imageViewArrow4.alpha = 0.0f;
    
    
    viewBackmask1.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
    viewBackmask2.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
    viewBackmask3.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
    viewBackmask4.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
    
    [self.view addSubview:viewBackmask1];
    [self.view addSubview:viewBackmask2];
    [self.view addSubview:viewBackmask3];
    [self.view addSubview:viewBackmask4];
    
    float aEdgeSize = 16.0f;
    
    self.viewEdgeU = [[UIView alloc] initWithFrame:CGRectMake(aX, aY - aEdgeSize, aWidth, aEdgeSize)];
    self.viewEdgeR = [[UIView alloc] initWithFrame:CGRectMake(aRight, aY, aEdgeSize, aHeight)];
    self.viewEdgeD = [[UIView alloc] initWithFrame:CGRectMake(aX, aBottom, aWidth, aEdgeSize)];
    self.viewEdgeL = [[UIView alloc] initWithFrame:CGRectMake(aX - aEdgeSize, aY, aEdgeSize, aHeight)];

    [self.view addSubview:viewEdgeU];
    [self.view addSubview:viewEdgeR];
    [self.view addSubview:viewEdgeD];
    [self.view addSubview:viewEdgeL];
    
    viewEdgeU.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    viewEdgeR.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    viewEdgeD.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    viewEdgeL.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];

    
    float aCornerSize = 16.0f;
    float aCornerLength = 26.0f;
    
    self.viewCornUL1 = [[UIView alloc] initWithFrame:CGRectMake(aX - aCornerSize, aY - aCornerSize, aCornerLength + aCornerSize, aCornerSize)];
    self.viewCornUL2 = [[UIView alloc] initWithFrame:CGRectMake(aX - aCornerSize, aY - aCornerSize, aCornerSize, aCornerLength + aCornerSize)];
    
    self.viewCornUR1 = [[UIView alloc] initWithFrame:CGRectMake((aX + aWidth), aY - aCornerSize, aCornerSize, aCornerLength + aCornerSize)];
    self.viewCornUR2 = [[UIView alloc] initWithFrame:CGRectMake((aX + aWidth) - (aCornerLength), aY - aCornerSize, aCornerLength + aCornerSize, aCornerSize)];
    
    self.viewCornDL1 = [[UIView alloc] initWithFrame:CGRectMake(aX - aCornerSize, (aY + aHeight) - aCornerLength, aCornerSize, aCornerLength + aCornerSize)];
    self.viewCornDL2 = [[UIView alloc] initWithFrame:CGRectMake(aX - aCornerSize, aY + aHeight, aCornerLength + aCornerSize, aCornerSize)];
    
    self.viewCornDR1 = [[UIView alloc] initWithFrame:CGRectMake((aX + aWidth), (aY + aHeight) - aCornerLength, aCornerSize, aCornerLength + aCornerSize)];
    self.viewCornDR2 = [[UIView alloc] initWithFrame:CGRectMake((aX + aWidth) - (aCornerLength), aY + aHeight, aCornerLength + aCornerSize, aCornerSize)];
    
    UIColor *aCornerColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    viewCornUL1.backgroundColor = aCornerColor;
    viewCornUL2.backgroundColor = aCornerColor;
    viewCornUR1.backgroundColor = aCornerColor;
    viewCornUR2.backgroundColor = aCornerColor;
    viewCornDL1.backgroundColor = aCornerColor;
    viewCornDL2.backgroundColor = aCornerColor;
    viewCornDR1.backgroundColor = aCornerColor;
    viewCornDR2.backgroundColor = aCornerColor;
    
    [self.view addSubview:viewCornUL1];
    [self.view addSubview:viewCornUL2];
    [self.view addSubview:viewCornUR1];
    [self.view addSubview:viewCornUR2];
    [self.view addSubview:viewCornDL1];
    [self.view addSubview:viewCornDL2];
    [self.view addSubview:viewCornDR1];
    [self.view addSubview:viewCornDR2];
    
    cardFrameX = aX;
    cardFrameY = aY;
    cardFrameWidth = aWidth;
    cardFrameHeight = aHeight;
    
    cameraScan.cardFrameX = cardFrameX;
    cameraScan.cardFrameY = cardFrameY;
    cameraScan.cardFrameWidth = cardFrameWidth;
    cameraScan.cardFrameHeight = cardFrameHeight;
    
    float aShift = 28.0f;
    transformScaleArrow1 = CGAffineTransformMakeTranslation(cardFrameX + aShift, cardFrameY + aShift);
    transformScaleArrow2 = CGAffineTransformMakeTranslation((cardFrameX + cardFrameWidth) - aShift, cardFrameY + aShift);
    transformScaleArrow3 = CGAffineTransformMakeTranslation((cardFrameX + cardFrameWidth) - aShift, (cardFrameY + cardFrameHeight) - aShift);
    transformScaleArrow4 = CGAffineTransformMakeTranslation(cardFrameX + aShift, (cardFrameY + cardFrameHeight) - aShift);
    
    
    float aArrowWidth = imageViewArrow1.frame.size.width;
    float aArrowHeight = imageViewArrow1.frame.size.height;
    
    imageViewArrow1.frame = CGRectMake(-aArrowWidth/2.0f, -aArrowHeight/2.0f, aArrowWidth, aArrowHeight);
    imageViewArrow2.frame = CGRectMake(-aArrowWidth/2.0f, -aArrowHeight/2.0f, aArrowWidth, aArrowHeight);
    imageViewArrow3.frame = CGRectMake(-aArrowWidth/2.0f, -aArrowHeight/2.0f, aArrowWidth, aArrowHeight);
    imageViewArrow4.frame = CGRectMake(-aArrowWidth/2.0f, -aArrowHeight/2.0f, aArrowWidth, aArrowHeight);
    
    
    
    
    labelInstructions1.frame = CGRectMake(cardFrameX + (cardFrameWidth / 2.0f) - labelInstructions1.frame.size.width / 2.0f, (cardFrameY + cardFrameHeight / 2.0f) - (labelInstructions1.frame.size.height / 2.0f), labelInstructions1.frame.size.width, labelInstructions1.frame.size.height);
    labelInstructions2.frame = CGRectMake(cardFrameX + (cardFrameWidth / 2.0f) - labelInstructions2.frame.size.width / 2.0f, cardFrameY + cardFrameHeight / 2.0f + 24.0f, labelInstructions2.frame.size.width, labelInstructions2.frame.size.height);
    
    float aButtonY = cardFrameY + cardFrameHeight + 40.0f;
    
    
    buttonClose.frame = CGRectMake(self.view.frame.size.width / 2.0f - buttonClose.frame.size.width / 2.0f, aButtonY, buttonClose.frame.size.width, buttonClose.frame.size.height);
    
    buttonOkay.frame = CGRectMake(self.view.frame.size.width / 2.0f - buttonOkay.frame.size.width / 2.0f, aButtonY, buttonOkay.frame.size.width, buttonOkay.frame.size.height);
    
    aButtonY += buttonClose.frame.size.height + 16.0f;
    
    
    buttonRetake.frame = CGRectMake(self.view.frame.size.width / 2.0f - buttonRetake.frame.size.width / 2.0f, aButtonY, buttonRetake.frame.size.width, buttonRetake.frame.size.height);
    
    
    buttonOkay.hidden = YES;
    buttonRetake.hidden = YES;
    buttonClose.hidden = NO;
    
    //buttonOkay.hidden = YES;
    //buttonClose.hidden = YES;
    
    scanLineX[0] = aX;
    scanLineX[1] = (aX + aWidth) - 2.0f;
    
    self.viewScanLine1 = [[UIView alloc] initWithFrame:CGRectMake(scanLineX[0], aY, 2.0f, aHeight)];
    self.viewScanLine2 = [[UIView alloc] initWithFrame:CGRectMake(scanLineX[1], aY, 2.0f, aHeight)];
    
    viewScanLine[0] = viewScanLine1;
    viewScanLine[1] = viewScanLine2;
    
    
    [self.view addSubview:viewScanLine1];
    [self.view addSubview:viewScanLine2];
    
    viewScanLine1.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    viewScanLine2.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
    
    
    
    self.timerUpdate = [NSTimer scheduledTimerWithTimeInterval:(1 / 30.0f) target:self selector:@selector(updateView) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timerUpdate forMode:NSRunLoopCommonModes];
}



- (void)didTap:(UITapGestureRecognizer *)recognizer
{
    
}

- (IBAction)click:(UIButton *)sender
{
    
    if(sender == buttonRetake)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.50f];

        viewBackmask1.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
        viewBackmask2.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
        viewBackmask3.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
        viewBackmask4.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f];
        viewInnerFrame.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f];
        
        
        [UIView commitAnimations];
        
        
        
        viewScanLine1.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
        viewScanLine2.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
        
        
        
        [viewFlash removeFromSuperview];
        self.viewFlash = nil;
        
        didTakePic = NO;
        
        buttonOkay.hidden = YES;
        buttonRetake.hidden = YES;
        buttonClose.hidden = NO;
        
        labelInstructions1.hidden = NO;
        labelInstructions2.hidden = NO;
        
        [cameraScan startCaptureSession];
        
        imageViewPicture.image = nil;
        [imageViewPicture removeFromSuperview];
        self.imageViewPicture = nil;
        
        for(int i=0;i<4;i++)
        {
            edgeOn[i] = false;
            edgeOnBack1[i] = false;
            edgeOnBack2[i] = false;
            edgeAlpha[i] = 0.0f;
        }
        edgeOnTimer = 0;
        edgeInnerOnTimer = 0;
        
        return;
    }
    
    
    if(sender == buttonOkay)
    {
        [viewFlash removeFromSuperview];
        self.viewFlash = nil;
        
        self.view.userInteractionEnabled = NO;
        
        [gRoot.insuranceSearchPage.cardScanner pictureTakePrepare:imagePicture];
        
        [gRoot dismissViewControllerAnimated:YES completion:^
         {
             [gRoot.insuranceSearchPage.cardScanner pictureTake:imagePicture];
         }];
    }
    

    

    
    
    if(didTakePic == YES)return;
    
    if(sender == buttonClose)
    {
        didTakePic = YES;
        
        [cameraScan stopCaptureSession];
        
        
        [gRoot.insuranceSearchPage.cardScanner pictureCancel];
        
        /*[gRoot dismissViewControllerAnimated:YES completion:^
         {
             
         }];
        */
    }
    
    
    
    
}


- (void)refreshEdges
{
    
    BOOL aPrev[4];
    aPrev[0] = edgeOnBack2[0];
    aPrev[1] = edgeOnBack2[1];
    aPrev[2] = edgeOnBack2[2];
    aPrev[3] = edgeOnBack2[3];
    
    
    for(int i=0;i<4;i++)
    {
        if(edgeOnBack1[i] || edgeOn[i])edgeOnBack2[i] = true;
        else edgeOnBack2[i] = false;
        
        if(edgeOn[i])edgeOnBack1[i] = true;
        else edgeOnBack1[i] = false;
    }
    
    for(int i=0;i<4;i++)
    {
        if(edgeInnerOnBack1[i] || edgeInnerOn[i])edgeInnerOnBack2[i] = true;
        else edgeInnerOnBack2[i] = false;
        
        if(edgeInnerOn[i])edgeInnerOnBack1[i] = true;
        else edgeInnerOnBack1[i] = false;
    }
    
    edgeOn[0] = cameraScan.edgeDetectedU;
    edgeOn[1] = cameraScan.edgeDetectedR;
    edgeOn[2] = cameraScan.edgeDetectedD;
    edgeOn[3] = cameraScan.edgeDetectedL;
    
    edgeInnerOn[0] = cameraScan.edgeInnerDetectedU;
    edgeInnerOn[1] = cameraScan.edgeInnerDetectedR;
    edgeInnerOn[2] = cameraScan.edgeInnerDetectedD;
    edgeInnerOn[3] = cameraScan.edgeInnerDetectedL;
    
    
    for(int i=0;i<4;i++)
    {
        
        if(edgeOn[i])
        {
            edgeOnBack1[i] = true;
            edgeOnBack2[i] = true;
        }
        
        if(edgeInnerOn[i])
        {
            edgeInnerOnBack1[i] = true;
            edgeInnerOnBack2[i] = true;
        }
    }
    
    for(int i=0;i<4;i++)
    {
        if(edgeOnBack2[i] != aPrev[i])
        {
            if(edgeOnBack2[i] == YES)
            {
                [[RootViewController sharedInstance] playBeepEdge];
            }
            
        }
    }
    
    
    //aPrev[0] = ;
    //aPrev[1] = edgeOnBack2[1];
    //aPrev[2] = edgeOnBack2[2];
    //aPrev[3] = edgeOnBack2[3];
}

- (void)flashAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [gRoot.insuranceSearchPage.cardScanner pictureTake:imagePicture];
}

- (void)updateView
{
    // = 0.0f;
    //edgeCloserAlphaBase = 0.0f;

    if(didTakePic)
    {
        
    }
    
    edgeCloserAlphaWobble += 10.0f;
    if(edgeCloserAlphaWobble >= 360.0f)edgeCloserAlphaWobble -= 360.0f;
    
    
    if(edgeInnerOnTimer > 10)
    {
        
        edgeCloserAlphaBase += 0.1f;
        if(edgeCloserAlphaBase >= 1.0f)edgeCloserAlphaBase = 1.0f;
    }
    else
    {
        edgeCloserAlphaBase -= 0.1f;
        if(edgeCloserAlphaBase <= 0.0f)edgeCloserAlphaBase = 0.0f;
    }
    
    if(edgeCloserAlphaBase > 0.0f)
    {
        float aSin = sin(D_R * edgeCloserAlphaWobble);
        float aScale = 1.0f;//0.7f + ((aSin + 1.0f) * 0.3f);
        float aShiftMax = 6.0f;
        aShiftMax *= aSin;
        
        CGAffineTransform aTran1 = CGAffineTransformScale(transformScaleArrow1, aScale, aScale);
        aTran1 = CGAffineTransformTranslate(aTran1, -aShiftMax, -aShiftMax);
        
        CGAffineTransform aTran2 = CGAffineTransformScale(transformScaleArrow2, aScale, aScale);
        aTran2 = CGAffineTransformTranslate(aTran2, aShiftMax, -aShiftMax);
        
        CGAffineTransform aTran3 = CGAffineTransformScale(transformScaleArrow3, aScale, aScale);
        aTran3 = CGAffineTransformTranslate(aTran3, aShiftMax, aShiftMax);
        
        CGAffineTransform aTran4 = CGAffineTransformScale(transformScaleArrow4, aScale, aScale);
        aTran4 = CGAffineTransformTranslate(aTran4, -aShiftMax, aShiftMax);
        
        
        imageViewArrow1.transform = aTran1;
        imageViewArrow2.transform = aTran2;
        imageViewArrow3.transform = aTran3;
        imageViewArrow4.transform = aTran4;
        
        
    }
    else
    {
        //imageViewArrow1;
        //imageViewArrow2;
        //imageViewArrow3;
        //imageViewArrow4;
    }
    
    imageViewArrow1.alpha = edgeCloserAlphaBase;
    imageViewArrow2.alpha = edgeCloserAlphaBase;
    imageViewArrow3.alpha = edgeCloserAlphaBase;
    imageViewArrow4.alpha = edgeCloserAlphaBase;
    
    
    //float aCloserAlpha = aCloserAlpha = edgeCloserAlphaBase;
    
    //aCloserAlpha = edgeCloserAlphaBase * 0.5f + edgeCloserAlphaBase * ((sin(D_R * edgeCloserAlphaWobble) + 1.0f) * 0.25f);
    
    
    //labelInstructions1.alpha = (1.0f - edgeCloserAlphaBase);
    //labelInstructions2.alpha = (1.0f - edgeCloserAlphaBase);
    
    
    
    if(didTakePic || true)
    {
        
        for(int i=0;i<2;i++)
        {
            scanLineAlpha[i] += 0.04f;
            if(scanLineAlpha[i] > 0.6f)scanLineAlpha[i] = 0.6f;
            
            float aWidth = viewScanLine[i].frame.size.width;
            float aHeight = cardFrameHeight;
            
            if(scanLineDir[i] > 0)
            {
                scanLineX[i] += scanLineSpeed[i];
                float aRight = ((cardFrameX + cardFrameWidth) - aWidth);
                
                if(scanLineX[i] >= aRight)
                {
                    scanLineX[i] = aRight;
                    scanLineDir[i] = -1;
                }
            }
            else
            {
                scanLineX[i] -= scanLineSpeed[i];
                
                float aLeft = (cardFrameX);
                
                if(scanLineX[i] <= aLeft)
                {
                    scanLineX[i] = aLeft;
                    scanLineDir[i] = 1;
                }
            }
            
            viewScanLine[i].frame = CGRectMake(scanLineX[i], cardFrameY, aWidth, aHeight);
            viewScanLine[i].backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:scanLineAlpha[i]];
        }
    }
    
    int aOnCount = 0;
    int aOnInnerCount = 0;
    
    for(int i=0;i<4;i++)
    {
        if(edgeInnerOnBack2[i] == true)
        {
            aOnInnerCount++;
        }
        
        if(edgeOnBack2[i] == true)
        {
            aOnCount++;
            
            edgeAlpha[i] += 0.075f;
            if(edgeAlpha[i] > 1.0f)edgeAlpha[i] = 1.0f;
        }
        else
        {
            edgeAlpha[i] -= 0.055f;
            if(edgeAlpha[i] <= 0.0f)edgeAlpha[i] = 0.0f;
        }
    }
    
    viewEdgeU.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:edgeAlpha[0]];
    viewEdgeR.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:edgeAlpha[1]];
    viewEdgeD.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:edgeAlpha[2]];
    viewEdgeL.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:edgeAlpha[3]];
    
    
    if(didTakePic)return;
    
    if(aOnInnerCount >= 3)
    {
        edgeInnerOnTimer++;
        if(edgeInnerOnTimer >= 20)edgeInnerOnTimer=20;
    }
    else
    {
        edgeInnerOnTimer = 0;
    }
    
    if(aOnCount >= 4)
    {
        edgeOnTimer++;
        
        if(edgeOnTimer == 5)[gRoot playBeepCentered];
        
        if(edgeOnTimer >= 12)
        {
            didTakePic = YES;
            
            [cameraScan snapPicture];
        }
        
        
    }
    else
    {
        edgeOnTimer = 0;
    }
}

- (void)snapPictureComplete:(UIImage *)pImage
{
    NSLog(@"snapPictureComplete!!!");
    
    buttonOkay.hidden = NO;
    buttonRetake.hidden = NO;
    buttonClose.hidden = YES;
    labelInstructions1.hidden = YES;
    labelInstructions2.hidden = YES;
    
    if(imageViewPicture == nil)
    {
        self.imageViewPicture = [[UIImageView alloc] initWithFrame:CGRectMake(cardFrameX, cardFrameY, cardFrameWidth, cardFrameHeight)];
        [self.view addSubview:imageViewPicture];
    }
    else
    {
        [self.view bringSubviewToFront:imageViewPicture];
    }
    
    [self.view bringSubviewToFront:viewScanLine1];
    [self.view bringSubviewToFront:viewScanLine2];
    
    
    
    [viewFlash removeFromSuperview];
    self.viewFlash = nil;
    
    
    self.viewFlash = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:viewFlash];
    viewFlash.userInteractionEnabled = NO;
    
    viewFlash.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.45f];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.40f];
    //[UIView setAnimationDidStopSelector:@selector(flashAnimationDidStop:finished:context:)];
    //[UIView setAnimationDelegate:self];
    
    viewFlash.backgroundColor = [UIColor colorWithRed:0.75f green:1.0f blue:1.0f alpha:0.0f];
    
    [UIView commitAnimations];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.80f];
    
    viewBackmask1.backgroundColor = [UIColor colorWithRed:0.1f green:0.08f blue:0.02f alpha:0.85f];
    viewBackmask2.backgroundColor = [UIColor colorWithRed:0.1f green:0.08f blue:0.02f alpha:0.85f];
    viewBackmask3.backgroundColor = [UIColor colorWithRed:0.1f green:0.08f blue:0.02f alpha:0.85f];
    viewBackmask4.backgroundColor = [UIColor colorWithRed:0.1f green:0.08f blue:0.02f alpha:0.85f];
    viewInnerFrame.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    [UIView commitAnimations];
    
    
    self.imagePicture = pImage;
    imageViewPicture.image = pImage;
}

- (void)dealloc
{
    NSLog(@"Dealloc[%@]", [self class]);
    [self nuke];
}

- (void)nuke
{
    self.buttonOkay = nil;
    self.buttonClose = nil;
    self.buttonRetake = nil;
    
    imageViewAnimateIn.image = nil;
    [imageViewAnimateIn removeFromSuperview];
    self.imageViewAnimateIn = nil;
    
    imageViewPicture.image = nil;
    [imageViewPicture removeFromSuperview];
    self.imageViewPicture = nil;
    
    [cameraScan nuke];
    self.cameraScan = nil;
    
    [viewFlash removeFromSuperview];
    self.viewFlash = nil;
    
    self.imagePicture = nil;
    
    [viewBackmask1 removeFromSuperview];
    [viewBackmask2 removeFromSuperview];
    [viewBackmask3 removeFromSuperview];
    [viewBackmask4 removeFromSuperview];
    
    self.viewBackmask1 = nil;
    self.viewBackmask2 = nil;
    self.viewBackmask3 = nil;
    self.viewBackmask4 = nil;
    
    [viewEdgeU removeFromSuperview];
    [viewEdgeR removeFromSuperview];
    [viewEdgeD removeFromSuperview];
    [viewEdgeL removeFromSuperview];
    
    [viewCornUL1 removeFromSuperview];
    [viewCornUL2 removeFromSuperview];
    [viewCornUR1 removeFromSuperview];
    [viewCornUR2 removeFromSuperview];
    [viewCornDL1 removeFromSuperview];
    [viewCornDL2 removeFromSuperview];
    [viewCornDR1 removeFromSuperview];
    [viewCornDR2 removeFromSuperview];
    
    self.viewEdgeU = nil;
    self.viewEdgeR = nil;
    self.viewEdgeD = nil;
    self.viewEdgeL = nil;
    
    self.viewCornUL1 = nil;
    self.viewCornUL2 = nil;
    self.viewCornUR1 = nil;
    self.viewCornUR2 = nil;
    self.viewCornDL1 = nil;
    self.viewCornDL2 = nil;
    self.viewCornDR1 = nil;
    self.viewCornDR2 = nil;
    
    [imageViewArrow1 removeFromSuperview];
    [imageViewArrow2 removeFromSuperview];
    [imageViewArrow3 removeFromSuperview];
    [imageViewArrow4 removeFromSuperview];
    
    self.imageViewArrow1 = nil;
    self.imageViewArrow2 = nil;
    self.imageViewArrow3 = nil;
    self.imageViewArrow4 = nil;
    
    
    [viewInnerFrame removeFromSuperview];
    self.viewInnerFrame = nil;
    
    
    [viewScanLine1 removeFromSuperview];
    [viewScanLine2 removeFromSuperview];
    
    self.viewScanLine1 = nil;
    self.viewScanLine2 = nil;
    
    self.labelInstructions1 = nil;
    self.labelInstructions2 = nil;
    
    [timerUpdate invalidate];
    self.timerUpdate = nil;
    
    [self.view removeFromSuperview];
}

@end
