//
//  PkhImageView.h
//  ImageCutTest
//
//  Created by pkh on 11. 6. 7..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PkhCutView;
@class PkhImageProcessing;
@class pkhUIScrollView;

@interface PkhImageView : UIView <UIScrollViewDelegate>
{
	
	PkhCutView *m_pkhcutView;
	PkhImageProcessing *m_pkhImageProcessing;
	
	UIImageView *m_bgImageView;
	pkhUIScrollView *m_ScrollView;
	
	BOOL m_cutMod;
	BOOL m_expansionMod;
	NSInteger m_curveMod;
	NSInteger m_filterMod;
	CGFloat m_BrightnessValue;
	CGFloat m_ContrastValue;
	
	UIImage *m_originalImage;
	UIImage *m_filterImage;
	UIImage *m_filterImage2;
	UIImage *m_tempImage;
	
}

@property(nonatomic, retain) PkhCutView *pkhcutView;
@property(nonatomic, retain) PkhImageProcessing *pkhImageProcessing;
@property(nonatomic, retain) UIImageView *bgImageView;
@property(nonatomic, getter=getcutMod, setter=setcutMod:) BOOL cutMod;
@property(nonatomic, getter=getexpansionMod, setter=setexpansionMod:) BOOL expansionMod;
@property(nonatomic, copy) UIImage *originalImage, *filterImage, *tempImage, *filterImage2;
@property(nonatomic, getter = getCutRect, readonly) CGRect cutRect;


-(UIImage*)getImage;
-(void)setImage:(UIImage*)orgimg;

// pkhCutView를 사용하여 이미지파일에서 선택된 영역을 자른다.
-(UIImage*)CutImage;
// pkhCutView를 상용하지 않고 임의의 Rect값으로 자를때
-(UIImage*)CutImage:(CGRect)rect;

// 화면에 보이는 그대로 선택된 영역을 캡쳐를 한다.
-(UIImage*)CaptureImage;

// 이미지뷰의 레이어 회전
-(void)ImageLayerCurve:(float)rad;


// 이미지파일 회전
-(void)ImageCurveLeft;
-(void)ImageCurveRight;
-(void)ImageCurveUpDown;


// 필터들
-(void)filterGrey;
-(void)filterSepia;
-(void)filterAqua;
-(void)filterEdge;
-(void)filterNegative;
-(void)filterNoise;
-(void)filterSmearCross;
-(void)filterQuantize;
-(void)filterGaussianBlur;
-(void)filterWhiteMode;


-(void)filterBrightness:(CGFloat)value;
-(void)filterContrast:(CGFloat)value;
@end
