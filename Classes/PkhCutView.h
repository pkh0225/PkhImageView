//
//  PkhCutImageView.h
//  GLImageProcessing
//
//  Created by pkh on 11. 6. 1..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PkhCutView : UIView {

	CGFloat x, y, width, height;
	
	CGPoint startTouch;
	BOOL oneTouch;
	BOOL twoTouch;
	BOOL endTouch;


	CGFloat initialDistance;
	CGFloat posDistance;
	
	UITouch *first; 
	UITouch *second;
	
	UIImageView *point1;
	UIImageView *point2;
	UIImageView *point3;
	UIImageView *point4;
	
	UIImageView *cutImageView;
	
	NSInteger checkPont;
}

@property(nonatomic, getter = getCutRect, readonly) CGRect cutRect;
@property(nonatomic, retain) UIImageView *cutImageView;

// 사각형 안에 있는 화면을 그대로 켭쳐한다.
-(UIImage*)onCutImage;

@end
