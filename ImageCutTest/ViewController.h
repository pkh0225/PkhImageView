//
//  ViewController.h
//  ImageCutTest
//
//  Created by pkh on 28/03/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PkhImageView;

@interface ImageCutTestViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
    IBOutlet UIButton *m_cutButton;
    
    IBOutlet PkhImageView *m_pkhImageView;
    
    float CurvePos;
    
    IBOutlet UISlider *slider1;
    IBOutlet UISlider *slider2;
    
}

-(IBAction)onTest:(id)sender;

-(IBAction)onCutButtonTouchUp:(id)sender;
-(IBAction)onSwitchChangeValue:(id)sender;
-(IBAction)onChoiceImageTouchUp:(id)sender;
-(IBAction)onLeftButtonTouchtUp:(id)sender;
-(IBAction)onRightButtonTouchUp:(id)sender;
-(IBAction)onDownButtonTouchUp:(id)sender;
-(IBAction)onOriginalButtonTouchUp:(id)sender;
-(IBAction)onSliderChangeValue:(id)sender;
-(IBAction)onfilterButtionTouchUp:(id)sender;
-(IBAction)onSaveButtonTouchUp:(id)sender;

-(IBAction)onDragExit:(id)sender;

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;
-(void) showAlertMessage:(NSString*)msg title:(NSString*)title;

@end
