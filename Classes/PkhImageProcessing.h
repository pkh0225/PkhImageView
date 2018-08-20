//
//  PkhImageProcessing.h
//  ImageCutTest
//
//  Created by pkh on 11. 6. 14..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PkhImageProcessing : NSObject {
	uint32_t* pixels;
	CGContextRef context;
	
	NSInteger width;
	NSInteger height;
}

@property(nonatomic, retain, readonly, getter = getimage) UIImage *image;

//초기화시 이미지를 넣을 수 있다 
-(id)initWithImage:(UIImage*)anImage;
//필터를 적용하기 위해서는 setImage를 해야 한다.
-(id)setImage:(UIImage*)anImage;
//필터 적용 된 이미지 가져오기 
-(UIImage*)getimage;

// 이미지 필터
// setImage로 이미지 넣고 getimage로 가져와야 한다.
-(void)GreyScale;
-(void)SepiaScale;
-(void)EdgeScale:(NSInteger)level; //level 이 낮을수록 선이 가늘어 진다.(1 ~ 10)
-(void)NegativeScale;
-(void)NoiseMakeScale:(NSInteger)amount color:(BOOL)color; //amount : 노이즈 정도(1 ~ 100) color : 노이즈를 랜덤색으로 할지 흰색으로 할지 여부.
-(void)AquaScale;
-(void)SmearCrossScale;
-(void)Quantize:(NSInteger)level; //level 이 높을 수록 양자화가 세밀해짐. 적당한 값은 8
-(UIImage*)GaussianBlur:(UIImage*)image;
-(UIImage*)WhiteMode:(UIImage*)image;


// brightValue 값은 -1.0 부터 1.0까지
-(void)brighteness:(CGFloat)brightValue;
// contrastValue 값은 -1.0 부터 1.0까지
-(void)contrast:(CGFloat)contrastValue;

// 이미지파일 회전
+(UIImage*)ImageCurveLeft:(UIImage*)image;
+(UIImage*)ImageCurveRight:(UIImage*)image;
+(UIImage*)ImageCurveUpDown:(UIImage*)image;

//이미지 자르기
+(UIImage*)imageByCropping:(UIImage*)imageToCrop toRect:(CGRect)rect;

//이미지를 newSize로 조정한다.
+(UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
//이미지를 newSize로 조정하는데 원본 이미지 비율을 유지면서 조정한다.
+(UIImage*)imageWithScaleImage:(UIImage*)image scaledToSize:(CGSize)newSize;
//orientation 값으로 회전하여 원본 비율을 유지하며 사이즈 조정
+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution orientation:(UIImageOrientation)orientation;
@end


