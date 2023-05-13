#import <UIKit/UIKit.h>
#import "CameraScan.h"

@interface CameraScanContainer : UIViewController
{
    
    BOOL                                        didTakePic;
    
    UIButton                                    *buttonOkay;
    UIButton                                    *buttonClose;
    UIButton                                    *buttonRetake;
    
    UIImageView                                 *imageViewAnimateIn;
    UIImageView                                 *imageViewPicture;
    
    UILabel                                     *labelInstructions1;
    UILabel                                     *labelInstructions2;
    
    CameraScan                                  *cameraScan;
    
    UIView                                      *viewFlash;
    
    UIImage                                     *imagePicture;
    
    float                                       cardFrameX;
    float                                       cardFrameY;
    float                                       cardFrameWidth;
    float                                       cardFrameHeight;
    
    UIView                                      *viewBackmask1;
    UIView                                      *viewBackmask2;
    UIView                                      *viewBackmask3;
    UIView                                      *viewBackmask4;
    
    UIView                                      *viewInnerFrame;
    
    UIView                                      *viewEdgeU;
    UIView                                      *viewEdgeR;
    UIView                                      *viewEdgeD;
    UIView                                      *viewEdgeL;
    
    UIView                                      *viewCornUL1;
    UIView                                      *viewCornUL2;
    UIView                                      *viewCornUR1;
    UIView                                      *viewCornUR2;
    UIView                                      *viewCornDL1;
    UIView                                      *viewCornDL2;
    UIView                                      *viewCornDR1;
    UIView                                      *viewCornDR2;
    
    
    UIImageView                                 *imageViewArrow1;
    UIImageView                                 *imageViewArrow2;
    UIImageView                                 *imageViewArrow3;
    UIImageView                                 *imageViewArrow4;
    
    CGAffineTransform                           transformScaleArrow1;
    CGAffineTransform                           transformScaleArrow2;
    CGAffineTransform                           transformScaleArrow3;
    CGAffineTransform                           transformScaleArrow4;
    
    
    UIView                                      *viewScanLine1;
    UIView                                      *viewScanLine2;
    UIView                                      *viewScanLine[2];
    
    float                                       scanLineX[2];
    int                                         scanLineDir[2];
    float                                       scanLineSpeed[2];
    float                                       scanLineAlpha[2];
    
    
    bool                                        edgeOn[4];
    bool                                        edgeOnBack1[4];
    bool                                        edgeOnBack2[4];
    
    bool                                        edgeInnerOn[4];
    bool                                        edgeInnerOnBack1[4];
    bool                                        edgeInnerOnBack2[4];
    
    float                                       edgeAlpha[4];
    
    int                                         edgeOnTimer;
    int                                         edgeInnerOnTimer;
    
    float                                       edgeCloserAlphaWobble;
    float                                       edgeCloserAlphaBase;
    
}

@property (nonatomic, strong) IBOutlet UIButton *buttonOkay;
@property (nonatomic, strong) IBOutlet UIButton *buttonClose;
@property (nonatomic, strong) IBOutlet UIButton *buttonRetake;

@property (nonatomic, strong) IBOutlet UIImageView *imageViewAnimateIn;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewPicture;

@property (nonatomic, strong) IBOutlet UILabel *labelInstructions1;
@property (nonatomic, strong) IBOutlet UILabel *labelInstructions2;

@property (nonatomic, strong) CameraScan *cameraScan;

@property (nonatomic, strong) UIView *viewFlash;

@property (nonatomic, strong) UIImage *imagePicture;

@property (nonatomic, strong) UIView *viewBackmask1;
@property (nonatomic, strong) UIView *viewBackmask2;
@property (nonatomic, strong) UIView *viewBackmask3;
@property (nonatomic, strong) UIView *viewBackmask4;

@property (nonatomic, strong) UIView *viewInnerFrame;

@property (nonatomic, strong) UIView *viewEdgeU;
@property (nonatomic, strong) UIView *viewEdgeR;
@property (nonatomic, strong) UIView *viewEdgeD;
@property (nonatomic, strong) UIView *viewEdgeL;

@property (nonatomic, strong) UIView *viewCornUL1;
@property (nonatomic, strong) UIView *viewCornUL2;
@property (nonatomic, strong) UIView *viewCornUR1;
@property (nonatomic, strong) UIView *viewCornUR2;
@property (nonatomic, strong) UIView *viewCornDL1;
@property (nonatomic, strong) UIView *viewCornDL2;
@property (nonatomic, strong) UIView *viewCornDR1;
@property (nonatomic, strong) UIView *viewCornDR2;

@property (nonatomic, strong) IBOutlet UIImageView *imageViewArrow1;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewArrow2;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewArrow3;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewArrow4;

@property (nonatomic, strong) UIView *viewScanLine1;
@property (nonatomic, strong) UIView *viewScanLine2;

@property (nonatomic, strong) NSTimer *timerUpdate;


- (IBAction)click:(UIButton *)sender;

- (void)refreshEdges;
- (void)flashAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)updateView;

- (void)snapPictureComplete:(UIImage *)pImage;

- (void)dealloc;
- (void)nuke;

@end

