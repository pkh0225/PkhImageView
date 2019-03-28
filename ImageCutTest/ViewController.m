//
//  ViewController.m
//  ImageCutTest
//
//  Created by pkh on 28/03/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

#import "ViewController.h"
#import "PkhImageView.h"
#import "CGPointUtils.h"


@implementation ImageCutTestViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [m_pkhImageView setImage:[UIImage imageNamed:@"Image"]];
    
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}



#pragma mark -
#pragma mark button event
-(IBAction)onSaveButtonTouchUp:(id)sender
{
    UIImageWriteToSavedPhotosAlbum([m_pkhImageView getImage] , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

-(IBAction)onDownButtonTouchUp:(id)sender
{
    [m_pkhImageView ImageCurveUpDown];
}

-(IBAction)onCutButtonTouchUp:(id)sender
{
    [m_pkhImageView CutImage]; // 실제 파일 자르기
    //    UIImage *image = [m_pkhImageView.pkhcutView onCutImage]; // 화면 캡쳐
    
}

-(IBAction)onChoiceImageTouchUp:(id)sender
{
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    
    myImagePickerController.delegate = self;
    
    myImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:myImagePickerController];
        [popoverController presentPopoverFromRect:CGRectMake(50, 50, 600, 900) inView:[self view] permittedArrowDirections:UIProgressViewStyleDefault animated:YES];
        
    }
    else
    {
        [self presentModalViewController:myImagePickerController animated:YES];
    }
    
    
}

-(IBAction)onLeftButtonTouchtUp:(id)sender
{
    
    [m_pkhImageView ImageCurveLeft];
    
}
-(IBAction)onRightButtonTouchUp:(id)sender
{
    
    [m_pkhImageView ImageCurveRight];
    
}

-(IBAction)onOriginalButtonTouchUp:(id)sender
{
    [slider1 setValue:0.0 animated:YES];
    [slider2 setValue:0.0 animated:YES];
    [m_pkhImageView setImage:m_pkhImageView.originalImage];
    
    
}

-(IBAction)onfilterButtionTouchUp:(id)sender
{
    [slider1 setValue:0.0 animated:YES];
    [slider2 setValue:0.0 animated:YES];
    switch (((UIButton*)sender).tag) {
        case 0:
            [m_pkhImageView filterGrey];
            break;
        case 1:
            [m_pkhImageView filterSepia];
            break;
        case 2:
            [m_pkhImageView filterEdge];
            break;
        case 3:
            [m_pkhImageView filterNegative];
            break;
        case 4:
            [m_pkhImageView filterNoise];
            break;
        case 5:
            [m_pkhImageView filterAqua];
            break;
        case 6:
            [m_pkhImageView filterSmearCross];
            break;
        case 7:
            [m_pkhImageView filterQuantize];
            break;
        case 8:
            [m_pkhImageView filterGaussianBlur];
            break;
        case 9:
            [m_pkhImageView filterWhiteMode];
            break;
            
    }
    
    
    
}

-(IBAction)onTest:(id)sender
{
    //    NSLog(@"bgImage width = %f, height = %f", m_pkhImageView.bgImageView.frame.size.width, m_pkhImageView.bgImageView.frame.size.height);
    
    //    CGFloat ang = angleBetweenPoints(CGPointMake(160, 230), CGPointMake(60, 200));
    CGFloat ang = angleBetweenLines(CGPointMake(160, 230), CGPointMake(160, 100), CGPointMake(160, 230), CGPointMake(180, 330));
    NSLog(@"ang = %f", ang);
    
}

#pragma mark -
#pragma mark switch event
-(IBAction)onSwitchChangeValue:(id)sender
{
    UISwitch *switchbutton = sender;
    m_pkhImageView.cutMod = switchbutton.on;
    m_cutButton.enabled = switchbutton.on;
    
}


#pragma mark -
#pragma mark slider event
-(IBAction)onSliderChangeValue:(id)sender
{
    
    switch ( ((UISlider*)sender).tag )
    {
        case 0:
            [m_pkhImageView filterBrightness:((UISlider*)sender).value];
            break;
        case 1:
            [m_pkhImageView filterContrast:((UISlider*)sender).value];
            break;
    }
    
    
}

-(IBAction)onDragExit:(id)sender
{
    switch ( ((UISlider*)sender).tag )
    {
        case 0:
            [m_pkhImageView filterBrightness:((UISlider*)sender).value];
            break;
        case 1:
            [m_pkhImageView filterContrast:((UISlider*)sender).value];
            break;
    }
}


#pragma mark -
#pragma ImagePickerView Save Event


- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    
    NSString *msg = [NSString stringWithFormat:@"저 장 완 료/n , image width = %f, height = %f",
                     image.size.width, image.size.height];
    [self showAlertMessage:msg title:@"알 림"];
}

#pragma mark -
#pragma mark AlertMessage
-(void) showAlertMessage:(NSString*)msg title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"확 인"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark -
#pragma mark ImagePickerView event
-  (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    [slider1 setValue:0.0 animated:YES];
    [slider2 setValue:0.0 animated:YES];
    [m_pkhImageView setImage: image];
    
    [imagePickerController dismissModalViewControllerAnimated:YES];
    
    
}



@end
