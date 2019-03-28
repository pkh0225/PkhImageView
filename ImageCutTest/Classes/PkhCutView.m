//
//  PkhCutImageView.m
//  GLImageProcessing
//
//  Created by pkh on 11. 6. 1..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import "PkhCutView.h"
#import "CGPointUtils.h"
#import <QuartzCore/QuartzCore.h>

#define kMiniimumPinchDelta 15 //축소 확대의 OffSet 최소 값

#define kImageWidth 9 // 축소 확대 좌표에 쓰일 이미지 Width
#define kImageHeight 9 // 축소 확대 좌표에 쓰일 이미지 height

#define kImageCutWidthMin 15 // 자를 이미지 최소 크기 width
#define kImageCutHeightMin 15 // 자를 이미지 최소 크기 height

#define kimageTouchOffSet 15 // 자를 이미지 축소 확대의 터치 이벤츠 offset값

@interface PkhCutView() {
    BOOL zoomIn;
    BOOL zoomOut;
}

// 뷰 기준의 사각형 좌료를 구한다.
-(CGRect)getCutRect;
// 자를 사각형을 그린다.
-(void)DrawRectangle:(CGContextRef)context;
// 사각형의 포인트가 선택되어 있는지 검사한다.
-(NSInteger)checkPoint:(CGFloat)pointX pointY:(CGFloat)pointY;
// 초기화
-(void)init:(CGRect)aframe;

@end



@implementation PkhCutView

@synthesize cutRect;
@synthesize cutImageView;

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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	[self DrawRectangle:context];
}

#pragma mark -
#pragma init 
-(void)init:(CGRect)aframe
{
	self.backgroundColor = [UIColor clearColor];
	self.multipleTouchEnabled = YES;
	
	point1 = nil;
	point2 = nil;
	point3 = nil;
	point4 = nil;
	
	width = (aframe.size.width / 2.0);
	height = (aframe.size.height / 2.0);
	x = (aframe.size.width - width) / 2.0;
	y = (aframe.size.height - height) / 2.0;
	
	initialDistance = 0;
	twoTouch = FALSE;
	oneTouch = FALSE;
	endTouch = TRUE;
	checkPont = 0;
	
	UIImage *image = [UIImage imageNamed:@"blue.png"]; // 캡쳐용 사각형 이미지 
	
	point1 = [[UIImageView  alloc] initWithImage:image]; 
	point1.frame = CGRectMake(x- (kImageWidth / 2.0),
							  y- (kImageHeight / 2.0),
							  kImageWidth,
							  kImageHeight);
	[self addSubview:point1];
	
	point2 = [[UIImageView  alloc] initWithImage:image]; 
	point2.frame = CGRectMake(x+width- (kImageWidth / 2.0),
							  y- (kImageHeight / 2.0),
							  kImageWidth,
							  kImageHeight);
	[self addSubview:point2];
	
	point3 = [[UIImageView  alloc] initWithImage:image]; 
	point3.frame = CGRectMake(x- (kImageWidth / 2.0),
							  y+height- (kImageHeight / 2.0),
							  kImageWidth,
							  kImageHeight);
	[self addSubview:point3];
	
	point4 = [[UIImageView  alloc] initWithImage:image]; 
	point4.frame = CGRectMake(x+width- (kImageWidth / 2.0),
							  y+height- (kImageHeight / 2.0),
							  kImageWidth,
							  kImageHeight);
	[self addSubview:point4];
	
	
	cutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
	cutImageView.contentMode = UIViewContentModeScaleAspectFit;
	
	cutImageView.hidden = YES; // 잘랐을때 미리보기 기능 끄자
	[self addSubview:cutImageView];
	
}

#pragma mark -
#pragma mark Touch Event

-(NSInteger)checkPoint:(CGFloat)pointX pointY:(CGFloat)pointY
{
	NSInteger result = 0;
	if ((pointX >= x - kimageTouchOffSet) && 
		(pointX <= (x + kimageTouchOffSet)) &&
		(pointY >= y - kimageTouchOffSet) && 
		(pointY <= (y + kimageTouchOffSet)) )
		result = 1;
	else if ((pointX >= x + width - kimageTouchOffSet) && 
			 (pointX <= (x + width + kimageTouchOffSet)) &&
			 (pointY >= y - kimageTouchOffSet) && 
			 (pointY <= (y + kimageTouchOffSet)) )
		result = 2;
	else if ((pointX >= x - kimageTouchOffSet) && 
			 (pointX <= (x + kimageTouchOffSet)) &&
			 (pointY >= y + height - kimageTouchOffSet) && 
			 (pointY <= (y + height + kimageTouchOffSet)) )
		result = 3;
	else if ((pointX >= x + width - kimageTouchOffSet) && 
			 (pointX <= (x + width + kimageTouchOffSet)) &&
			 (pointY >= y + height - kimageTouchOffSet) && 
			 (pointY <= (y + height + kimageTouchOffSet)) )
		result = 4;
	
	return result;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *twoTouches =  [touches allObjects];
	NSInteger tapCount = [twoTouches count];
	//	NSInteger tapCount = [touches count];
	//	NSLog(@"Began %d", tapCount);
	
	
	switch (tapCount) 
	{
		case 1:
		{
			twoTouch = FALSE;
			if (endTouch)
			{
				oneTouch = TRUE;
				endTouch = FALSE;
				UITouch *touch = [touches anyObject];
				startTouch = [touch locationInView:self];
				
				checkPont = [self checkPoint:startTouch.x pointY:startTouch.y];
			}
			else 
			{
				oneTouch = FALSE;
			}
			
			break;
		}
		case 2:
		{
			checkPont = 0;
			twoTouch = YES;
			oneTouch = NO;
			first = [twoTouches objectAtIndex:0];
			second = [twoTouches objectAtIndex:1];
			initialDistance = distanceBetweenPoints( [first locationInView:self], [second locationInView:self] );
			break;
		}
		default:
			break;
	}
	
	//		NSLog(@"imageTouch = %d  ontTouch = %d  twoTouch = %d", imageTouch, oneTouch,twoTouch);
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *twoTouches =  [touches allObjects];
	NSInteger tapCount = [twoTouches count];
	//	NSLog(@"Moved %d", tapCount);
	switch (tapCount) {
		case 1:
		{	
			if (!twoTouch && oneTouch)
			{
				
				UITouch *touch = [touches anyObject];
				CGPoint point = [touch locationInView:self];
				
				
				switch (checkPont) 
				{
					case 1: // LeftTop 점 선택하여 크기 변경
					{
						CGFloat pointX = x + (point.x - startTouch.x);
						CGFloat pointY = y + (point.y - startTouch.y);
						
						CGFloat tmpwidth = width - (point.x - startTouch.x) ;
						CGFloat tmpheight = height - (point.y - startTouch.y);
						
						if ( (tmpwidth > kImageCutWidthMin) && (pointX >= 0) )
						{
							x = pointX; 
							width = tmpwidth;
						}
						if ( (tmpheight > kImageCutHeightMin) && (pointY >= 0) )
						{
							y = pointY;
							height = tmpheight;
						}
						
						break;
					}
					case 2: // RightTop 점 선택하여 크기 변경
					{
						CGFloat pointY = y + (point.y - startTouch.y);
						
						CGFloat tmpwidth = width + (point.x - startTouch.x) ;
						CGFloat tmpheight = height - (point.y - startTouch.y);
						
						if ((tmpwidth > kImageCutWidthMin) && (x + tmpwidth < self.frame.size.width))
						{
							width = tmpwidth;
						}
						if ( (tmpheight > kImageCutHeightMin) && (pointY >= 0) )
						{
							y = pointY;
							height = tmpheight;
						}
						
						break;
					}
					case 3: // LeftDown 점 선택하여 크기 변경
					{
						CGFloat pointX = x + (point.x - startTouch.x);
						
						
						CGFloat tmpwidth = width - (point.x - startTouch.x) ;
						CGFloat tmpheight = height + (point.y - startTouch.y);
						
						
						if ((tmpwidth > kImageCutWidthMin) && (pointX >= 0))
						{
							x = pointX; 
							width = tmpwidth;
						}
						if ( (tmpheight > kImageCutHeightMin) && (y + tmpheight < self.frame.size.height) )
						{
							height = tmpheight;
						}
						
						break;
					}
					case 4: // RightDown 점 선택하여 크기 변경
					{
						
						CGFloat tmpwidth = width + (point.x - startTouch.x) ;
						CGFloat tmpheight = height + (point.y - startTouch.y);
						
						if ( (tmpwidth > kImageCutWidthMin) && (x + tmpwidth < self.frame.size.width) )
						{
							width = tmpwidth;
						}
						if ( (tmpheight > kImageCutHeightMin) && (y + tmpheight < self.frame.size.height) )
						{
							height = tmpheight;
						}
						
						break;
					}
					default: // 점을 선택하지 않고 다른 부분 선택 하여 이동
					{
						CGFloat pointX = x + (point.x - startTouch.x);
						CGFloat pointY = y + (point.y - startTouch.y);
						
						if (pointX < 0) pointX = 0;
						if (pointY < 0) pointY = 0;
						if (pointX + width > self.frame.size.width) pointX = self.frame.size.width - width;
						if (pointY + height > self.frame.size.height) pointY = self.frame.size.height - height;
						
						x = pointX; 
						y = pointY;
						
						break;
					}
				}
				
				//				if (width < kImageCutWidthMin) width = kImageCutWidthMin;
				//				if (height < kImageCutHeightMin) height = kImageCutHeightMin;
				
				startTouch = point;
				[self setNeedsDisplay];
			}
			
			
			break;
		}
		case 2: // 축소 확대
		{
			twoTouch = YES;
			
			first = [twoTouches objectAtIndex:0];
			second = [twoTouches objectAtIndex:1];
			CGFloat currentDistance = distanceBetweenPoints( [first locationInView:self], [second locationInView:self] );
			
			if (initialDistance == 0)
            {
				initialDistance = currentDistance;
                orgRect = CGRectMake(x, y, width, height);
                zoomOut = NO;
                zoomIn = NO;
            }
			else if (currentDistance - initialDistance > kMiniimumPinchDelta)
			{
                // 확대
//                                NSLog(@"currentDistance - initialDistance = %f", currentDistance - initialDistance);
                zoomIn = YES;
                if (zoomOut) {
                    zoomOut = NO;
                    orgRect = CGRectMake(x, y, width, height);
                    initialDistance = currentDistance;
                }
                CGFloat d = currentDistance - initialDistance;
                CGFloat poswidth  = orgRect.size.width + d;
                CGFloat posheigth = orgRect.size.height + d;
                CGFloat posX = orgRect.origin.x - d / 2.0;
                CGFloat posY = orgRect.origin.y - d / 2.0;
				
				if (posX < 0) posX = 0;
				if (posY < 0) posY = 0;
				if (posX + poswidth > self.frame.size.width) poswidth = self.frame.size.width;
				if (posY + posheigth > self.frame.size.height) posheigth = self.frame.size.height;
				
				
				x = posX;
				y = posY;
				width = poswidth; 
				height = posheigth;
				
				
				if (posDistance > currentDistance)
				{
					initialDistance = currentDistance;
				}
				if (width < kImageCutWidthMin) width = kImageCutWidthMin;
				if (height < kImageCutHeightMin) height = kImageCutHeightMin;
				
				[self setNeedsDisplay];
			}
			else if (initialDistance - currentDistance   > kMiniimumPinchDelta)
			{
                // 축소
				//				NSLog(@"initialDistance - currentDistance = %f", initialDistance - currentDistance);
				
                zoomOut = YES;
                if (zoomIn) {
                    zoomIn = NO;
                    orgRect = CGRectMake(x, y, width, height);
                    initialDistance = currentDistance;
                }
                CGFloat d = initialDistance - currentDistance;
                CGFloat poswidth  = orgRect.size.width - d;
                CGFloat posheigth = orgRect.size.height - d;
                CGFloat posX = orgRect.origin.x + d / 2.0;
                CGFloat posY = orgRect.origin.y + d / 2.0;
                
				if (posX < 0) posX = 0;
				if (posY < 0) posY = 0;
				if (posX + poswidth > self.frame.size.width) poswidth = self.frame.size.width;
				if (posY + posheigth > self.frame.size.height) posheigth = self.frame.size.height;
				
				
				if (poswidth > kImageCutWidthMin) 
				{
					x = posX; 
					width = poswidth;
				}
				if (posheigth > kImageCutHeightMin) 
				{
					y = posY;
					height = posheigth;
				}
				
				if (posDistance < currentDistance)
				{
					initialDistance = currentDistance;
				}
				[self setNeedsDisplay];
			}
			posDistance = currentDistance;
			
			
			break;
		}
		default:
			break;
	}
	//	NSLog(@"imageTouch = %d  ontTouch = %d  twoTouch = %d", imageTouch, oneTouch,twoTouch);
	
	//	NSLog(@"x, = %f, y = %f, width = %f, height = %f", x, y, width, height);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"Ended");
	initialDistance = 0;
	twoTouch = NO;
	oneTouch = NO;
	endTouch = YES;
	checkPont = 0;
    zoomOut = NO;
    zoomIn = NO;
    orgRect = CGRectMake(x, y, width, height);
}

#pragma mark -
#pragma mark Draw function
-(void)DrawRectangle:(CGContextRef)context
{
	// 선색
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.0);
	// 채우기 색
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.7);
	// 선 두께
	CGContextSetLineWidth(context, 4.0);
	// 경로에 사각형 추가
	CGContextAddRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	// 경로에 사각형 추가
	CGContextAddRect(context, CGRectMake(x, y, width, height));
	CGContextClosePath(context);
	CGContextEOFillPath(context);
	
	
	if (point1 != nil)
	{
		// 이미지 추가
		point1.frame = CGRectMake(x- (kImageWidth / 2.0),
								  y- (kImageHeight / 2.0),
								  kImageWidth,
								  kImageHeight);
		
		
		
		point2.frame = CGRectMake(x+width- (kImageWidth / 2.0),
								  y- (kImageHeight / 2.0),
								  kImageWidth,
								  kImageHeight);
		
		point3.frame = CGRectMake(x- (kImageWidth / 2.0),
								  y+height- (kImageHeight / 2.0),
								  kImageWidth,
								  kImageHeight);
		
		
		
		point4.frame = CGRectMake(x+width- (kImageWidth / 2.0),
								  y+height- (kImageHeight / 2.0),
								  kImageWidth,
								  kImageHeight);
	}
}



-(CGRect)getCutRect
{
	return CGRectMake(x, y , width, height);
}


#pragma mark -
#pragma mark imageCut function 

-(UIImage*)onCutImage
{
	
	self.hidden = YES;
	UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, cutImageView.opaque, 0.0);
	[self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *bgviewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//	NSLog(@"bgimage width = %f, height = %f", bgviewImage.size.width, bgviewImage.size.height);
	
	CGRect rect;
    rect = CGRectMake(x + self.frame.origin.x, y + self.frame.origin.y, width, height);
	
	CGImageRef tmp = CGImageCreateWithImageInRect( [bgviewImage CGImage], rect); 
	
	UIImage *cutImage =[UIImage imageWithCGImage:tmp];
	
	
	//	NSLog(@"rect x = %f, y = %f, width = %f, height = %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	NSLog(@"cutImage width = %f, height = %f", cutImage.size.width, cutImage.size.height);
	
	
	[cutImageView performSelectorOnMainThread:@selector(setImage:) withObject:cutImage waitUntilDone:YES];
	
	
	
	
	self.hidden = NO;
	
	return cutImageView.image;
	
}

@end


