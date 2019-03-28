//
//  PkhImageView.m
//  ImageCutTest
//
//  Created by pkh on 11. 6. 7..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import "PkhImageView.h"
#import "PkhCutView.h"
#import "pkhImageProcessing.h"
#import <QuartzCore/QuartzCore.h>

#define kFilter_None            0
#define kFilter_Grey            1
#define kFilter_Sepia           2
#define kFilter_Edge            3
#define kFilter_Negative        4
#define kFilter_Noise           5
#define kFilter_Aqua            6
#define kFilter_SmearCross      7
#define	kFilter_Quantize        8
#define kFilter_GaussianBlur    9
#define kFilter_WhiteMode       10

#define kEdgeLevel			2	//엣지 선 두께 숫자가 낮을 수록 가늘다(1 ~ 10)
#define kNoiseLevel			5	//노이즈 정도 (1 ~ 100) 
#define kNoiseColor			YES	// 노이즈 색 YES : 랜덤색, NO : 흰색
#define kQuantizeLevel      8   //level 이 높을 수록 양자화가 세밀해짐. 적당한 값은 8


#define kMiniimumPinchDelta 10	//축소 확대의 OffSet 최소 값

#define kScale				0.06 // 축소 확대 비율

#define kMaxScale			5.0	// 최대 확대 비율

#define kCurveMod_None		0	// 사진 회전 않함 
#define kCurveMod_Right		1	// 사진 회전 오른쪽 
#define kCurveMod_Down		2	// 사진 회전 아래
#define kCurveMod_Left		3	// 사진 회전 왼쪽 

@interface pkhUIScrollView : UIScrollView @end

@implementation pkhUIScrollView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.nextResponder touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.nextResponder touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.nextResponder touchesEnded:touches withEvent:event];
}
@end

@interface PkhImageView()
// getter, setter
-(BOOL)getcutMod;
-(void)setcutMod:(BOOL)value;
-(CGRect)getCutRect;
-(BOOL)getexpansionMod;
-(void)setexpansionMod:(BOOL)value;

// 초기화
-(void)init:(CGRect)aframe;


// 아이폰 화면에서 캡쳐할 사각형의 좌표를 이미지좌표로 변환한다 
-(CGRect)CutImageRectToImageRect:(CGRect)rect;
//필터를 적용한다.
-(UIImage *)makeFilterImage:(UIImage *)image SaveMode:(BOOL)saveMod;
//더블클릭시 이비지를 2배로 확대 축소 한다.
-(void)doubleTap;
//회전 모드를 계산한다.
-(void)changeCurveMod:(NSInteger)CurveMod;
//이미지를 현재 회전모드로 회전시킨다.
-(UIImage*)changeCurveImgae:(UIImage*)image;
@end

@implementation PkhImageView

@synthesize pkhcutView = m_pkhcutView;
@synthesize bgImageView = m_bgImageView;
@synthesize pkhImageProcessing = m_pkhImageProcessing;
@synthesize originalImage = m_originalImage, filterImage = m_filterImage, filterImage2 = m_filterImage2, tempImage = m_tempImage;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self init:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self init:self.frame];
		
	}
	return self;
	
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
	
	[m_pkhcutView release];
	[m_bgImageView release];
	[m_pkhImageProcessing release];
	[m_originalImage release];
	[m_filterImage release];
	[m_tempImage release];
	[m_ScrollView release];
    [super dealloc];
}



#pragma mark -
#pragma mark init
-(void)init:(CGRect)aframe 
{
	self.backgroundColor = [UIColor colorWithRed:26.0/256.0 green:26.0/256.0 blue:26.0/256.0 alpha:1.0];
	self.multipleTouchEnabled = YES;
	
	m_cutMod = YES;
	m_expansionMod = YES;
	
	m_filterMod = kFilter_None;
	m_curveMod = kCurveMod_None;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
	
	m_pkhImageProcessing = [[PkhImageProcessing alloc] init];
	
	m_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(aframe), CGRectGetHeight(aframe))];
	m_bgImageView.contentMode = UIViewContentModeScaleAspectFit;
	m_bgImageView.backgroundColor = [UIColor clearColor];
    m_bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	m_ScrollView = [[pkhUIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(aframe), CGRectGetHeight(aframe))];
	m_ScrollView.maximumZoomScale = 5.0;
	m_ScrollView.minimumZoomScale = 1.0;
	m_ScrollView.delegate = self;
    m_ScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[m_ScrollView addSubview:m_bgImageView];
	[self addSubview:m_ScrollView];
	
	
    m_pkhcutView = [[PkhCutView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(aframe), CGRectGetHeight(aframe))];
    m_pkhcutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:m_pkhcutView];
	
	self.cutMod = YES;
	
	
}

#pragma mark -
#pragma mark scrollView event
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
	return m_bgImageView;
}


#pragma mark -
#pragma mark touch event
-(void)doubleTap
{
	if (m_ScrollView.zoomScale == 1.0)
	{
		[m_ScrollView setZoomScale:2.0 animated:YES];
		
	}
	else 
	{
		[m_ScrollView setZoomScale:1.0 animated:YES];
		
	}
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	//	NSLog(@"touchesBegan2");
	UITouch *touch = [touches anyObject];
	
	NSInteger tapCount = [touch tapCount];
	
	if (tapCount == 2) [self doubleTap];
	
}
#pragma mark -
#pragma mark Geter Seter

-(CGRect)getCutRect
{
	return [self CutImageRectToImageRect:m_pkhcutView.cutRect];
}
-(BOOL)getcutMod
{
	return m_cutMod;
}

-(void)setcutMod:(BOOL)value
{
	m_cutMod = value;
	m_pkhcutView.hidden = !value;
}

-(BOOL)getexpansionMod
{
	return m_expansionMod;
}
-(void)setexpansionMod:(BOOL)value
{
	m_expansionMod = value;
	if (value)
		m_ScrollView.maximumZoomScale = 5.0;
	else 
	{
		m_ScrollView.zoomScale = 1.0;
		m_ScrollView.maximumZoomScale = 1.0;
	}
}
-(UIImage*)getImage
{
	self.tempImage = [self changeCurveImgae:self.tempImage]; // 실제 이미지 회전
	return [self makeFilterImage:m_tempImage SaveMode:YES]; // 실제 이미지에 필터 적용
}

-(void)setImage:(UIImage*)orgimg
{
    UIImage *img = [orgimg copy];
	m_filterMod = kFilter_None;
	m_curveMod = kCurveMod_None;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
	
	NSLog(@"Input Image Width = %f, Height = %f, orientation = %d", img.size.width, img.size.height, img.imageOrientation);
	
//	self.originalImage = img;
    self.originalImage = [PkhImageProcessing scaleAndRotate:img maxResolution:(img.size.width > img.size.height? img.size.width : img.size.height) orientation:img.imageOrientation];
	self.tempImage = self.originalImage;
	m_ScrollView.zoomScale = 1.0;
    if ( [[UIScreen mainScreen] respondsToSelector:@selector(scale)] )
    {
        if ( [[UIScreen mainScreen] scale] == 2.0) {
            // Retina
            CGSize size = m_bgImageView.frame.size;
            size.width *= 2;
            size.height *= 2;
            m_bgImageView.image = [PkhImageProcessing scaleAndRotate:img maxResolution:(size.width > size.height? size.width : size.height) orientation:img.imageOrientation];
//            if (img.size.width > size.width || img.size.height > size.height)
//                m_bgImageView.image = [PkhImageProcessing imageWithScaleImage:img scaledToSize:size];
//            else
//                m_bgImageView.image = img;
        } else {
            // Not Retina
            m_bgImageView.image = [PkhImageProcessing scaleAndRotate:img maxResolution:(m_bgImageView.frame.size.width > m_bgImageView.frame.size.height? m_bgImageView.frame.size.width : m_bgImageView.frame.size.height) orientation:img.imageOrientation];
//            if (img.size.width > m_bgImageView.frame.size.width || img.size.height > m_bgImageView.frame.size.height)
//                m_bgImageView.image = [PkhImageProcessing imageWithScaleImage:img scaledToSize:m_bgImageView.frame.size];
//            else
//                m_bgImageView.image = img;
        }
    }
	
	self.filterImage = m_bgImageView.image;
	self.filterImage2 = m_bgImageView.image;
    [img release];
}


#pragma mark -
#pragma image cut functoin
-(CGRect)CutImageRectToImageRect:(CGRect)rect
{
    
	CGSize bgImageSize = m_ScrollView.contentSize;
	CGPoint bgImagePoint = [m_ScrollView contentOffset];
	
	UIImage *realImage = m_tempImage;
	
	//	NSLog(@"1 Inputrect x = %f, y = %f, width = %f, height = %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	CGFloat imageWidth = realImage.size.width * bgImageSize.height / realImage.size.height;
	CGFloat imageHeight = realImage.size.height * bgImageSize.width / realImage.size.width;
	
	// 이미지가 확대 되었을때
	if ((bgImageSize.width != self.frame.size.width) && (bgImageSize.height != self.frame.size.height) )
	{ 
		
		// 이미지뷰 기준으로 스크린 좌료에서 구한다.
		CGRect screenRect;
		screenRect.origin.x = bgImagePoint.x;
		screenRect.origin.y = bgImagePoint.y;
		screenRect.size.width = self.frame.size.width;
		screenRect.size.height = self.frame.size.height;
		//스크린 좌표에서 CutImage 좌표를 구한다.
		rect.origin.x += screenRect.origin.x;
		rect.origin.y += screenRect.origin.y;
	}
	// 이미지가 이미지뷰보다 세로로 긴경우 좌우 여백을 다시 계산한다.
	if (imageWidth < bgImageSize.width)
	{
		imageHeight = bgImageSize.height;
		CGFloat imagePosX = (bgImageSize.width - imageWidth) / 2.0;
		rect.origin.x -= imagePosX;
		// y 좌료를 Quartz 좌표로 변환 
		//		rect.origin.y = bgImageView.frame.size.height - (rect.origin.y + rect.size.height);
		//		NSLog(@"imageWidth = %f", imageWidth);
		//		NSLog(@"rect.origin.x = %f", rect.origin.x);
	}
	// 이미지가 이미지뷰보다 가로로 긴경우 상하 여백을 다시 계산한다.
	else if (imageHeight < bgImageSize.height)
	{
		imageWidth = bgImageSize.width;
		CGFloat imagePssY = (bgImageSize.height - imageHeight) / 2.0;
		rect.origin.y -= imagePssY;
		// y 좌료를 Quartz 좌표로 변환 
		//		rect.origin.y = imageHeight - (rect.origin.y + rect.size.height);
		//		NSLog(@"imageHeight = %f", imageHeight);
		//		NSLog(@"rect.origin.y = %f", rect.origin.y);
	}
	// 이미지가 이미지뷰하고 비율이 같을때
	else
	{
		// y 좌료를 Quartz 좌표로 변환 
		//		rect.origin.y = bgImageView.frame.size.height - (rect.origin.y + rect.size.height);
	}
	
	//	NSLog(@"2 rect x = %f, y = %f, width = %f, height = %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	CGRect returnRect;
	// 이미지뷰 기준으로 구해온 좌표를 실제 이미지 사이즈 비율로 다시 계산다.
	returnRect.origin.x    = (realImage.size.width * rect.origin.x) / imageWidth;
	returnRect.origin.y    = (realImage.size.height * rect.origin.y) / imageHeight;
	returnRect.size.width  = (realImage.size.width * rect.size.width) / imageWidth;
	returnRect.size.height = (realImage.size.height * rect.size.height) / imageHeight;
	//	NSLog(@"3 rect x = %f, y = %f, width = %f, height = %f", returnRect.origin.x, returnRect.origin.y, returnRect.size.width, returnRect.size.height);
	
	// 사진의 여백은 빼야 한다.
	if (returnRect.origin.x < 0) 
	{
		returnRect.size.width += returnRect.origin.x;
		returnRect.origin.x = 0;
	}
	if (returnRect.origin.x > realImage.size.width) returnRect.origin.x = realImage.size.width;
	if (returnRect.origin.y < 0) 
	{
		returnRect.size.height += returnRect.origin.y;
		returnRect.origin.y = 0;
	}
	if (returnRect.origin.y > realImage.size.height) returnRect.origin.y = realImage.size.height;
	if ((returnRect.origin.x + returnRect.size.width) > (realImage.size.width)) returnRect.size.width = realImage.size.width - returnRect.origin.x;
	if ((returnRect.origin.y + returnRect.size.height) > (realImage.size.height)) returnRect.size.height = realImage.size.height - returnRect.origin.y;
	
	//	NSLog(@"returnRect x = %f, y = %f, width = %f, height = %f", returnRect.origin.x, returnRect.origin.y, returnRect.size.width, returnRect.size.height);
	
	return returnRect;
}
-(UIImage*)CutImage
{
	self.tempImage = [self changeCurveImgae:self.tempImage]; // 실제 이미지 회전
	
	CGRect rect = [self CutImageRectToImageRect:m_pkhcutView.cutRect];
	//	NSLog(@"cutRect  x = %f, y = %f, width = %f, height = %f,", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	UIImage *toImage = [PkhImageProcessing imageByCropping:m_tempImage toRect:rect];
	
	NSLog(@"cutRect  width = %f height = %f", rect.size.width, rect.size.height);
	NSLog(@"cutImage width = %f height = %f", toImage.size.width, toImage.size.height);
	
	m_ScrollView.zoomScale = 1.0;
	
	self.tempImage = toImage;
	
	// 필터가 적용 되어진 경우 자른 후 필터를 다시 적용한다.
	self.filterImage = [PkhImageProcessing imageWithScaleImage:toImage scaledToSize:m_bgImageView.frame.size];
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
	return toImage;
}

-(UIImage*)CutImage:(CGRect)rect
{
	self.tempImage = [self changeCurveImgae:self.tempImage]; // 실제 이미지 회전
	
	UIImage *toImage = [PkhImageProcessing imageByCropping:m_tempImage toRect:rect];
	
	NSLog(@"cutRect  width = %f height = %f", rect.size.width, rect.size.height);
	NSLog(@"cutImage width = %f height = %f", toImage.size.width, toImage.size.height);
	
	m_ScrollView.zoomScale = 1.0;
	
	self.tempImage = toImage;
	
	// 필터가 적용 되어진 경우 자른 후 필터를 다시 적용한다.
	self.filterImage = [PkhImageProcessing imageWithScaleImage:toImage scaledToSize:m_bgImageView.frame.size];
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
	return toImage;
	
}

-(UIImage*)CaptureImage
{
	UIImage *captureImage = [m_pkhcutView onCutImage];
	m_ScrollView.zoomScale = 1.0;
	m_bgImageView.image = captureImage;	
	self.filterImage = m_bgImageView.image;
	return captureImage;	// 화면 갭쳐용
	
}



#pragma mark -
#pragma mark image curve
-(void)ImageLayerCurve:(CGFloat)value
{
	
	CGFloat radian = value * (2.0 * M_PI / 360); //레디안으로 변환
	
	[UIView beginAnimations:nil context:nil];
	
	[UIView setAnimationDuration:0.5];
	
	m_bgImageView.transform = CGAffineTransformMakeRotation( radian);
	
	[UIView commitAnimations];
	
}

-(void)ImageCurveLeft
{
	[self changeCurveMod:kCurveMod_Left];
	UIImage *toImage = [PkhImageProcessing ImageCurveLeft:self.filterImage];
	
	// 필터가 적용 되어진 경우 회전 후 필터를 다시 적용한다.
	self.filterImage = toImage;
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];	
	
}
-(void)ImageCurveRight
{
	[self changeCurveMod:kCurveMod_Right];
	UIImage *toImage = [PkhImageProcessing ImageCurveRight:self.filterImage];
	
	// 필터가 적용 되어진 경우 회전 후 필터를 다시 적용한다.
	self.filterImage = toImage;
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];	
	
	
}
-(void)ImageCurveUpDown
{
	[self changeCurveMod:kCurveMod_Down];
	UIImage *toImage = [PkhImageProcessing ImageCurveUpDown:self.filterImage];
	
	// 필터가 적용 되어진 경우 회전 후 필터를 다시 적용한다.
	self.filterImage = toImage;
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];	
	
}

-(void)changeCurveMod:(NSInteger)CurveMod
{
	m_curveMod += CurveMod;
	
	if (m_curveMod > 3) m_curveMod -= 4;
	
	m_curveMod = m_curveMod % 4;
	
    //	NSLog(@"CurveMod = %d", m_curveMod);
    
}

-(UIImage*)changeCurveImgae:(UIImage*)image
{
	UIImage *img;
	switch (m_curveMod) {
		case kCurveMod_None:
			img = image;
			break;
		case kCurveMod_Right:
			img = [PkhImageProcessing ImageCurveRight:image];
			break;
		case kCurveMod_Down:
			img = [PkhImageProcessing ImageCurveUpDown:image];
			break;
		case kCurveMod_Left:
			img = [PkhImageProcessing ImageCurveLeft:image];
			break;
	}
	m_curveMod = kCurveMod_None;
	return img;
}

#pragma mark -
#pragma mark image filter

-(UIImage *)makeFilterImage:(UIImage *)image SaveMode:(BOOL)saveMod
{
	UIImage *img;
	switch (m_filterMod) {
		case kFilter_None:
			img = image;
			break;
			
		case kFilter_Grey:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing GreyScale];
			img = m_pkhImageProcessing.image;
			break;
			
		case kFilter_Sepia:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing SepiaScale];
			img = m_pkhImageProcessing.image;
			break;
			
		case kFilter_Edge:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing EdgeScale:kEdgeLevel];
			img = m_pkhImageProcessing.image;
			break;
			
		case kFilter_Negative:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing NegativeScale];
			img = m_pkhImageProcessing.image;
			break;
			
		case kFilter_Noise: //이미지가 너무 작아 효과가 다르게 보여서 원본 이미지로 대체
			self.tempImage = [self changeCurveImgae:self.tempImage]; // 실제 이미지 회전
			[m_pkhImageProcessing setImage:self.tempImage];
			[m_pkhImageProcessing NoiseMakeScale:kNoiseLevel color:kNoiseColor];
			if (saveMod)
				img = m_pkhImageProcessing.image;
			else 
				img = [PkhImageProcessing imageWithScaleImage:m_pkhImageProcessing.image scaledToSize:m_bgImageView.frame.size];
			break;
			
		case kFilter_Aqua:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing AquaScale];
			img = m_pkhImageProcessing.image;
			break;
			
		case kFilter_SmearCross: //이미지가 너무 작아 효과가 다르게 보여서 원본 이미지로 대체
			self.tempImage = [self changeCurveImgae:self.tempImage]; // 실제 이미지 회전
			[m_pkhImageProcessing setImage:self.tempImage];
			[m_pkhImageProcessing SmearCrossScale];
			if (saveMod)
				img = m_pkhImageProcessing.image;
			else 
				img = [PkhImageProcessing imageWithScaleImage:m_pkhImageProcessing.image scaledToSize:m_bgImageView.frame.size];
			break;
			
		case kFilter_Quantize:
			[m_pkhImageProcessing setImage:image];
			[m_pkhImageProcessing Quantize:kQuantizeLevel];
			img = m_pkhImageProcessing.image;
			break;
            
        case kFilter_GaussianBlur:
			img = [m_pkhImageProcessing GaussianBlur:image];
			break;
            
        case kFilter_WhiteMode:
            img = [m_pkhImageProcessing WhiteMode:image];
            break;
	}
	
	self.filterImage2 = img;
	
	if ((m_BrightnessValue != 0.0) && (m_ContrastValue != 0.0) )
	{
		[m_pkhImageProcessing setImage:img];
		
		[m_pkhImageProcessing brighteness:m_BrightnessValue];
		
		[m_pkhImageProcessing setImage:m_pkhImageProcessing.image];
		
		[m_pkhImageProcessing contrast:m_ContrastValue];
		
		img = m_pkhImageProcessing.image;	
	}
	else if (m_BrightnessValue != 0.0)
	{
		[m_pkhImageProcessing setImage:img];
		
		[m_pkhImageProcessing brighteness:m_BrightnessValue];
		
		img = m_pkhImageProcessing.image;
		
	}
	else if (m_ContrastValue != 0.0)
	{
		[m_pkhImageProcessing setImage:img];
		
		[m_pkhImageProcessing contrast:m_ContrastValue];
		
		img = m_pkhImageProcessing.image;
	}
	
	return img;
}

-(void)filterBrightness:(CGFloat)value
{
	if (m_BrightnessValue == value) return;
	
	m_BrightnessValue = value;
    
    //	m_bgImageView.image = [self makeFilterImage:self.filterImage];
	
    
	[m_pkhImageProcessing setImage:self.filterImage2];
	
	[m_pkhImageProcessing brighteness:m_BrightnessValue];
	
	UIImage *image = m_pkhImageProcessing.image;
    
    if (m_ContrastValue != 0.0)
	{
		[m_pkhImageProcessing setImage:image];
		
		[m_pkhImageProcessing contrast:m_ContrastValue];
		
		image = m_pkhImageProcessing.image;
	}
	
	m_bgImageView.image = image;
	
}

-(void)filterContrast:(CGFloat)value
{
	if (m_ContrastValue == value) return;
	
	m_ContrastValue = value;
    
	[m_pkhImageProcessing setImage:self.filterImage2];
	
	[m_pkhImageProcessing contrast:m_ContrastValue];
	
	UIImage *image = m_pkhImageProcessing.image;
	
	if (m_BrightnessValue != 0.0)
	{
		[m_pkhImageProcessing setImage:image];
		
		[m_pkhImageProcessing brighteness:m_BrightnessValue];
		
		image = m_pkhImageProcessing.image;
		
	}
    
	m_bgImageView.image = image;
	
}


-(void)filterGrey
{
	if (m_filterMod == kFilter_Grey && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Grey;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
	
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
}

-(void)filterSepia
{
	if (m_filterMod == kFilter_Sepia && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Sepia;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
	
}

-(void)filterAqua
{
	if (m_filterMod == kFilter_Aqua && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Aqua;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
}

-(void)filterEdge
{
	if (m_filterMod == kFilter_Edge && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Edge;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
}

-(void)filterNegative
{
	if (m_filterMod == kFilter_Negative && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Negative;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
	
}

-(void)filterNoise
{
	if (m_filterMod == kFilter_Noise && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Noise;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO]; 
	
}

-(void)filterSmearCross
{
	if (m_filterMod == kFilter_SmearCross && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_SmearCross;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
    
}

-(void)filterQuantize
{
	if (m_filterMod == kFilter_Quantize && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_Quantize;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
    
}

-(void)filterGaussianBlur
{
    if (m_filterMod == kFilter_GaussianBlur && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_GaussianBlur;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
}

-(void)filterWhiteMode
{
    if (m_filterMod == kFilter_WhiteMode && m_BrightnessValue == 0.0 && m_ContrastValue == 0.0) return;
	
	m_filterMod = kFilter_WhiteMode;
	m_BrightnessValue = 0.0;
	m_ContrastValue = 0.0;
    
	m_bgImageView.image = [self makeFilterImage:self.filterImage SaveMode:NO];
}

@end
