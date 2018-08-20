//
//  PkhImageProcessing.m
//  ImageCutTest
//
//  Created by pkh on 11. 6. 14..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import "PkhImageProcessing.h"

//SmearCross Filter - 옆라인 랜덤 간격 범위
#define kSmearCross_minLineGap 1
#define kSmearCross_maxLineGap 10

//SmearCross Filter - 라인 랜덤 길이 범위
#define kSmearCross_minLineLength 20
#define kSmearCross_maxLineLength 50

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;


typedef enum{
	EDGEFILTER0 = -1, EDGEFILTER1 = -1, EDGEFILTER2 = -1,
	EDGEFILTER3 = -1, EDGEFILTER4 =  8, EDGEFILTER5 = -1, 
	EDGEFILTER6 = -1, EDGEFILTER7 = -1, EDGEFILTER8 = -1 
}EDGEFILTER;

@interface PkhImageProcessing (Interanl) 

-(void)reset;

@end

@implementation PkhImageProcessing

- (id)init
{
    self = [super init];
    if (self) 
	{
		srandom(time(NULL));
    }
    return self;
	
}

-(id)initWithImage:(UIImage*)anImage {
	
	if( (self = [super init] ) ) 
	{
		srandom(time(NULL));
		[self setImage:anImage];
	}
	
	return self;
}

-(void)dealloc {
	
	if( context ) {
		CGContextRelease(context);
	}
	if( pixels ) {
		free(pixels);
	}
	
	[super dealloc];
}
#pragma mark -
#pragma mark internal
-(void)reset 
{
	if( pixels ) {
		free(pixels);
		pixels = nil;
	}
	
	if( context ) {
		CGContextRelease(context);
		context = nil;
	}
}

-(id)setImage:(UIImage*)anImage {
	[self reset];
	if( anImage == nil ) {
		return nil;
	}
	
	CGSize size = anImage.size;
    width = size.width;
    height = size.height;
	
    // the pixels will be painted to this array
    pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, 
									kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), anImage.CGImage);
	
	
	CGColorSpaceRelease( colorSpace ); 
	
	return self;
}

-(UIImage*)getimage {
	if( context == nil ) {
		return nil;
	}
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	// make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	
    // we're done with image now too
    CGImageRelease(image);
	
    return resultUIImage;	
}


#pragma mark -
#pragma mark Image Processing

-(void)GreyScale
{
	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
}

-(void)SepiaScale
{
	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
		
			NSInteger outputRed = (rgbaPixel[RED] * .393) + (rgbaPixel[GREEN] *.769) + (rgbaPixel[BLUE] * .189);
			NSInteger outputGreen = (rgbaPixel[RED] * .349) + (rgbaPixel[GREEN] *.686) + (rgbaPixel[BLUE] * .168);
			NSInteger outputBlue = (rgbaPixel[RED] * .272) + (rgbaPixel[GREEN] *.534) + (rgbaPixel[BLUE] * .131);
			
			if(outputRed > 255) outputRed = 255;
			if(outputGreen > 255)outputGreen = 255;
			if(outputBlue > 255)outputBlue = 255;
			
			
			rgbaPixel[RED] = outputRed;
			rgbaPixel[GREEN] = outputGreen;
			rgbaPixel[BLUE] = outputBlue;
			
        }
    }

	
}

-(void)EdgeScale:(NSInteger)level
{
	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
	
	NSInteger iColorValue;               // 변수의 선언 iColorValue : RGB평균치
	
	uint32_t *iArrayValue = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(iArrayValue, 0, width * height * sizeof(uint32_t));
     
	// 변수의 선언 cArrayColor : 색정보의 배열
	uint8_t *cArrayColor0, *cArrayColor1, *cArrayColor2, *cArrayColor3, *cArrayColor4, *cArrayColor5, *cArrayColor6, *cArrayColor7, *cArrayColor8; 
       
	// 화상에 대한 필터 처리
	for(NSInteger i = 1; i < width - 1; i++)
		for(NSInteger j = 1; j < height - 1; j++)
		{
			
			cArrayColor0 = (uint8_t *) &pixels[(j-1) * width + (i-1)];
			cArrayColor1 = (uint8_t *) &pixels[j * width + (i-1)];
			cArrayColor2 = (uint8_t *) &pixels[(j+1) * width + (i-1)];
			cArrayColor3 = (uint8_t *) &pixels[(j-1) * width + i];
			cArrayColor4 = (uint8_t *) &pixels[j * width + i];
			cArrayColor5 = (uint8_t *) &pixels[(j+1) * width + i];
			cArrayColor6 = (uint8_t *) &pixels[(j-1) * width + (i+1)];
			cArrayColor7 = (uint8_t *) &pixels[j * width + (i+1)];
			cArrayColor8 = (uint8_t *) &pixels[(j+1) * width + (i+1)];
			

			// 필터 처리
			iColorValue =   EDGEFILTER0*cArrayColor0[RED] + EDGEFILTER1*cArrayColor1[RED] + EDGEFILTER2*cArrayColor2[RED]  
			+ EDGEFILTER3*cArrayColor3[RED] + EDGEFILTER4*cArrayColor4[RED] + EDGEFILTER5*cArrayColor5[RED] 
			+ EDGEFILTER6*cArrayColor6[RED] + EDGEFILTER7*cArrayColor7[RED] + EDGEFILTER8*cArrayColor8[RED];
			iColorValue = level * iColorValue; // 출력 레벨의 설정
			// iColorValue가 0보다 작은 경우
			if(iColorValue < 0)
				iColorValue = -iColorValue; // 정의값에 변환
			// iColorValue가255보다 클 경우 
			if(iColorValue > 255)
				iColorValue = 255; // iColorValue를255으로 설정
			((uint8_t *) &iArrayValue[j * width + i])[RED] = iColorValue;

		}
	// 필터 처리 결과 출력
	for(NSInteger i = 1; i < width - 1; i++)
		for(NSInteger j = 1; j < height - 1; j++)
		{
			uint8_t *rgbaPixel = (uint8_t *) &pixels[j * width + i];
			
			rgbaPixel[RED] = ((uint8_t *) &iArrayValue[j * width + i])[RED];
			rgbaPixel[GREEN] = ((uint8_t *) &iArrayValue[j * width + i])[RED];
			rgbaPixel[BLUE] = ((uint8_t *) &iArrayValue[j * width + i])[RED];
			// iArrayValue 값에 의한 색 설정

		}
	
	free(iArrayValue);
	
	
}

-(void)NegativeScale
{
	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            rgbaPixel[RED] = 255 - rgbaPixel[RED];
            rgbaPixel[GREEN] = 255 - rgbaPixel[GREEN];
            rgbaPixel[BLUE] = 255 - rgbaPixel[BLUE];
        }
    }

}

-(void)NoiseMakeScale:(NSInteger)amount color:(BOOL)color
{
	NSInteger nosieCount = ((width * height) * amount) / 100;
	
//	NSLog(@"nosieCount = %d", nosieCount);

	for (NSInteger i=0; i < nosieCount; i++) {
		NSInteger posX = (NSInteger) ((CGFloat)random() / (CGFloat) RAND_MAX * width);
		NSInteger posY = (NSInteger) ((CGFloat)random() / (CGFloat) RAND_MAX * height);
		
		uint8_t *rgbaPixel = (uint8_t *) &pixels[posY * width + posX];
		
		if (color)
		{
			rgbaPixel[RED] = (NSInteger) ((CGFloat)random() / (CGFloat) RAND_MAX * 255.0);
			rgbaPixel[GREEN] = (NSInteger) ((CGFloat)random() / (CGFloat) RAND_MAX * 255.0);
			rgbaPixel[BLUE] = (NSInteger) ((CGFloat)random() / (CGFloat) RAND_MAX * 255.0);		
		}
		else 
		{
			rgbaPixel[RED] = 255;
			rgbaPixel[GREEN] = 255;
			rgbaPixel[BLUE] = 255;
		}
		
	}
	
}

-(void)AquaScale
{
	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
//			NSInteger outputRed = (rgbaPixel[RED] * .393) + (rgbaPixel[GREEN] *.769) + (rgbaPixel[BLUE] * .189);
//			NSInteger outputGreen = (rgbaPixel[RED] * .349) + (rgbaPixel[GREEN] *.686) + (rgbaPixel[BLUE] * .168);
//			NSInteger outputBlue = (rgbaPixel[RED] * .272) + (rgbaPixel[GREEN] *.534) + (rgbaPixel[BLUE] * .131);
			
			NSInteger outputRed = (rgbaPixel[RED] * .131) + (rgbaPixel[GREEN] *.272) + (rgbaPixel[BLUE] * .534);
			NSInteger outputGreen = (rgbaPixel[RED] * .168) + (rgbaPixel[GREEN] *.349) + (rgbaPixel[BLUE] * .686);
//			NSInteger outputBlue = (rgbaPixel[RED] * .189) + (rgbaPixel[GREEN] *.393) + (rgbaPixel[BLUE] * .769);
			NSInteger outputBlue = (rgbaPixel[RED] * .300) + (rgbaPixel[GREEN] * .500) + (rgbaPixel[BLUE] * .700);
			
			if(outputRed > 255) outputRed = 255;
			if(outputGreen > 255)outputGreen = 255;
			if(outputBlue > 255)outputBlue = 255;
			
			rgbaPixel[RED] = outputRed;
			rgbaPixel[GREEN] = outputGreen;
			rgbaPixel[BLUE] = outputBlue;
			
        }
    }
}

-(void)SmearCrossScale
{
	NSMutableArray *avoidOverLap = [[NSMutableArray alloc] init];
	//오른쪽 -> 왼쪽
	NSInteger lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
	//y축으로 랜덤 이동
	for (NSInteger y = 0; y < height; y = y + lineGap )
	{
		NSNumber *num = [NSNumber numberWithInt:y];
		[avoidOverLap addObject:num];
		lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
		//x축으로 랜덤 이동
		NSInteger start	= 1;
		NSInteger end		= 50;
		NSInteger lineGapX = (random() % (end - start + 1)) + start;
		for (NSInteger i = lineGapX ; i < width; i = i + lineGapX)
		{
			start = kSmearCross_maxLineLength + 10;
			end = start + kSmearCross_maxLineLength;
			lineGapX = (random() % (end - start + 1)) + start;
			if (i < width)
			{
				uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + i ];
				//x축으로 몇픽셀 그릴것인가
				NSInteger lineFix = (random() % (kSmearCross_maxLineLength - kSmearCross_minLineLength + 1)) + kSmearCross_minLineLength;
				for (NSInteger k = 0 ; k < lineFix; k ++)
				{
					if (k + i < width)
					{
						uint8_t *rgbaPixel2 = (uint8_t *) &pixels[y * width + k + i];	
						rgbaPixel2[RED] = rgbaPixel[RED];
						rgbaPixel2[GREEN] = rgbaPixel[GREEN];
						rgbaPixel2[BLUE] = rgbaPixel[BLUE];
					}
				}
			}
		}			
	}
	//왼쪽 -> 오른쪽
	lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
	//y축으로 랜덤 이동
	for (NSInteger y = 0; y < height; y = y + lineGap )
	{
		lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
		
		//x축으로 랜덤 이동
		NSInteger start	= 1;
		NSInteger end		= 50;
		NSInteger lineGapX = (random() % (end - start + 1)) + start;
		for (NSInteger i = width - lineGapX ; i >= 0; i = i - lineGapX)
		{
			start = kSmearCross_maxLineLength + 10;
			end = start + kSmearCross_maxLineLength;
			lineGapX = (random() % (end - start + 1)) + start;
			if (i >= 0)
			{
				uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + i ];
				//x축으로 몇픽셀 그릴것인가
				NSInteger lineFix = (random() % (kSmearCross_maxLineLength - kSmearCross_minLineLength + 1)) + kSmearCross_minLineLength;
				for (NSInteger k = lineFix ; k >= 0; k --)
				{
					if (i - k >= 0)
					{
						uint8_t *rgbaPixel2 = (uint8_t *) &pixels[y * width + (i - k)];	
						rgbaPixel2[RED] = rgbaPixel[RED];
						rgbaPixel2[GREEN] = rgbaPixel[GREEN];
						rgbaPixel2[BLUE] = rgbaPixel[BLUE];
					}
				}
			}
		}			
	}
	//위 -> 아래
	lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
	//x축으로 랜덤 이동
	for (NSInteger x = 0; x < width; x = x + lineGap )
	{
		lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
		
		//y축으로 랜덤 이동
		NSInteger start	= 1;
		NSInteger end		= 50;
		NSInteger lineGapX = (random() % (end - start + 1)) + start;
		for (NSInteger i = lineGapX ; i < height; i = i + lineGapX)
		{
			start = kSmearCross_maxLineLength + 10;
			end = start + kSmearCross_maxLineLength;
			lineGapX = (random() % (end - start + 1)) + start;
			if (i < height)
			{
				uint8_t *rgbaPixel = (uint8_t *) &pixels[i * width + x ];
				//x축으로 몇픽셀 그릴것인가
				NSInteger lineFix = (random() % (kSmearCross_maxLineLength - kSmearCross_minLineLength + 1)) + kSmearCross_minLineLength;
				for (NSInteger k = 0 ; k < lineFix; k ++)
				{
					if (k + i < height)
					{
						uint8_t *rgbaPixel2 = (uint8_t *) &pixels[(i + k) * width + x];	
						rgbaPixel2[RED] = rgbaPixel[RED];
						rgbaPixel2[GREEN] = rgbaPixel[GREEN];
						rgbaPixel2[BLUE] = rgbaPixel[BLUE];
					}
				}
			}
		}			
	}
	//아래 -> 위
	lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
	//x축으로 랜덤 이동
	for (NSInteger x = 0; x < width; x = x + lineGap )
	{
		lineGap = (random() % (kSmearCross_maxLineGap - kSmearCross_minLineGap + 1)) + kSmearCross_minLineGap;
		
		//y축으로 랜덤 이동
		NSInteger start	= 1;
		NSInteger end		= 50;
		NSInteger lineGapX = (random() % (end - start + 1)) + start;
		for (NSInteger i = height - lineGapX ; i >= 0; i = i - lineGapX)
		{
			start = kSmearCross_maxLineLength + 10;
			end = start + kSmearCross_maxLineLength;
			lineGapX = (random() % (end - start + 1)) + start;
			if (i >= 0)
			{
				uint8_t *rgbaPixel = (uint8_t *) &pixels[i * width + x ];
				//x축으로 몇픽셀 그릴것인가
				NSInteger lineFix = (random() % (kSmearCross_maxLineLength - kSmearCross_minLineLength + 1)) + kSmearCross_minLineLength;
				for (NSInteger k = lineFix ; k >= 0; k --)
				{
					if (i - k >= 0)
					{
						uint8_t *rgbaPixel2 = (uint8_t *) &pixels[(i - k) * width + x];	
						rgbaPixel2[RED] = rgbaPixel[RED];
						rgbaPixel2[GREEN] = rgbaPixel[GREEN];
						rgbaPixel2[BLUE] = rgbaPixel[BLUE];
					}
				}
			}
		}			
	}
//	NSLog(@"%@",avoidOverLap);
	[avoidOverLap release];
}

-(void)Quantize:(NSInteger)level
{
	for(NSInteger y = 0; y < height; y++) 
	{
		for(NSInteger x = 0; x < width; x++) 
		{
			uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
			uint32_t red = rgbaPixel[RED];
			NSInteger firstValue = ((CGFloat) red) / 256 * level;
			NSInteger lastValue = (firstValue * 256) /level;
			rgbaPixel[RED] = lastValue;
			
			uint32_t green = rgbaPixel[GREEN];
			firstValue = ((CGFloat) green) / 256 * level;
			lastValue = (firstValue * 256) / level;
			rgbaPixel[GREEN] = lastValue;
			
			uint32_t blue = rgbaPixel[BLUE];
			firstValue = ((CGFloat) blue) / 256 * (level * 2); //BLUE는 가시화 때문에 곱하기 2
			lastValue = (firstValue * 256) / ( level * 2 ); 
			rgbaPixel[BLUE] = lastValue;
		}
	}
}

-(UIImage*)GaussianBlur:(UIImage*)image
{
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [image drawInRect:CGRectMake(x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [image drawInRect:CGRectMake(-x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContext(image.size);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}

-(UIImage*)WhiteMode:(UIImage*)image;
{
    [self setImage:image];
    [self brighteness:0.2];
    [self contrast:0.25];
    UIImage *bcImage = [self getimage];
    UIImage *gImage = [self GaussianBlur:bcImage];
//    UIImage *gImage = [self GaussianBlur:image];
    UIGraphicsBeginImageContext(image.size);
	[image drawAtPoint:CGPointMake(0,0)];
    [gImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModeScreen alpha:0.6];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
    
}

-(void)brighteness:(CGFloat)brightValue
{

	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
			if (brightValue < 0.0)
			{
				rgbaPixel[RED] *= (1.0 + brightValue);
				rgbaPixel[GREEN] *= (1.0 + brightValue);
				rgbaPixel[BLUE] *= (1.0 + brightValue);
				rgbaPixel[ALPHA] *= brightValue;
			}
			else
			{
				rgbaPixel[RED] += (255 - rgbaPixel[RED]) * (brightValue);
				rgbaPixel[GREEN] += (255 - rgbaPixel[GREEN]) * (brightValue);
				rgbaPixel[BLUE] += (255 - rgbaPixel[BLUE]) * (brightValue);
//				rgbaPixel[ALPHA] += (255 - rgbaPixel[ALPHA]) * (brightValue -1.0);;
			}
			
			if (rgbaPixel[RED] > 255.0 ) rgbaPixel[RED] = 255.0;
			if (rgbaPixel[RED] < 0.0 ) rgbaPixel[RED] = 0.0;
			if (rgbaPixel[GREEN] > 255.0 ) rgbaPixel[GREEN] = 255.0;
			if (rgbaPixel[GREEN] < 0.0 ) rgbaPixel[GREEN] = 0.0;
			if (rgbaPixel[BLUE] > 255.0 ) rgbaPixel[BLUE] = 255.0;
			if (rgbaPixel[BLUE] < 0.0 ) rgbaPixel[BLUE] = 0.0;
//			if (rgbaPixel[ALPHA] > 255.0 ) rgbaPixel[ALPHA] = 255.0;
//			if (rgbaPixel[ALPHA] < 0.0 ) rgbaPixel[ALPHA] = 0.0;
        }
    }
	
	
}




-(void)contrast:(CGFloat)contrastValue
{

	for(NSInteger y = 0; y < height; y++) 
	{
        for(NSInteger x = 0; x < width; x++) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
			if (contrastValue < 0.0)
			{
				rgbaPixel[RED]   = (rgbaPixel[RED] + ((rgbaPixel[RED]   - 128) * contrastValue));
				rgbaPixel[GREEN] = (rgbaPixel[GREEN] + ((rgbaPixel[GREEN] - 128) * contrastValue));
				rgbaPixel[BLUE]  = (rgbaPixel[BLUE] + ((rgbaPixel[BLUE]  - 128) * contrastValue));
			}
			else
			{
				if (rgbaPixel[RED] > 128)  
				{
					CGFloat value = rgbaPixel[RED] + ((rgbaPixel[RED] - 128) * contrastValue);
					if (value > 255) value = 255.0;
					rgbaPixel[RED]   = value;
				}
				else {
					CGFloat value = rgbaPixel[RED] - ((128 - rgbaPixel[RED]) * contrastValue);
					if (value < 0) value = 0.0;
					rgbaPixel[RED]   = value;
				}


				if (rgbaPixel[GREEN] > 128)  
				{
					CGFloat value = rgbaPixel[GREEN] + ((rgbaPixel[GREEN] - 128) * contrastValue);
					if (value > 255) value = 255.0;
					rgbaPixel[GREEN] = value;
				}
				else {
					CGFloat value = rgbaPixel[GREEN] - ((128 - rgbaPixel[GREEN]) * contrastValue);
					if (value < 0) value = 0.0;
					rgbaPixel[GREEN]   = value;
				}

				
				if (rgbaPixel[BLUE] > 128)
				{
					CGFloat value = rgbaPixel[BLUE] + ((rgbaPixel[BLUE] - 128) * contrastValue);
					if (value > 255) value = 255.0;
					rgbaPixel[BLUE]  = value;
				}
				else {
					CGFloat value = rgbaPixel[BLUE] - ((128 - rgbaPixel[BLUE]) * contrastValue);
					if (value < 0) value = 0.0;
					rgbaPixel[BLUE]   = value;
				}

				
			}
			
        }
    }
	
}

#pragma mark -
#pragma mark image Cut

+(UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	
	CGImageRelease(imageRef);
	
	return cropped;
}

#pragma mark -
#pragma mark image curve


+(UIImage*)ImageCurveLeft:(UIImage*)inImage
{
	
	CGSize size =  CGSizeMake(inImage.size.height, inImage.size.width);
	
	UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(currentContext, 0.0, inImage.size.height);
	
	CGContextScaleCTM(currentContext, 1.0, -1.0);
	
	CGContextRotateCTM(currentContext, 90*(M_PI/180.0));
	
	CGContextDrawImage(currentContext, CGRectMake(inImage.size.height - inImage.size.width, -inImage.size.height, inImage.size.width, inImage.size.height), inImage.CGImage);
	
	UIImage *toImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	

	return  toImage;
	
}
+(UIImage*)ImageCurveRight:(UIImage*)inImage
{
	
	CGSize size =  CGSizeMake(inImage.size.height, inImage.size.width);
	
	UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(currentContext, 0.0, inImage.size.height);
	
	CGContextScaleCTM(currentContext, 1.0, -1.0);
	
	CGContextRotateCTM(currentContext, -90*(M_PI/180.0));
	
	CGContextDrawImage(currentContext, CGRectMake(-inImage.size.height ,0, inImage.size.width, inImage.size.height), inImage.CGImage);
	
	UIImage *toImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return toImage;
	
}
+(UIImage*)ImageCurveUpDown:(UIImage*)inImage
{
	
	CGSize size =  CGSizeMake(inImage.size.width, inImage.size.height);
	
	UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(currentContext, 0.0, inImage.size.height);
	
	CGContextScaleCTM(currentContext, 1.0, -1.0);
	
	CGContextRotateCTM(currentContext, -180*(M_PI/180.0));
	
	CGContextDrawImage(currentContext, CGRectMake(-inImage.size.width, -inImage.size.height, inImage.size.width, inImage.size.height), inImage.CGImage);
	
	UIImage *toImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();

	return toImage;
	
}


#pragma mark -
#pragma mark image resize
+(UIImage *)imageWithImage:(UIImage*)inImage scaledToSize:(CGSize)newSize 

{
	
    UIGraphicsBeginImageContext(newSize);
	
    [inImage drawInRect:CGRectMake(0, 0, newSize.width,  newSize.height)];
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    return newImage;
	
}

+(UIImage*)imageWithScaleImage:(UIImage*)inImage scaledToSize:(CGSize)newSize
{
	CGFloat imageWidth = inImage.size.width * newSize.height / inImage.size.height;
	CGFloat imageHeight = inImage.size.height * newSize.width / inImage.size.width;
	
	
	if (imageWidth < newSize.width) imageHeight = newSize.height;
	else if (imageHeight < newSize.height) imageWidth = newSize.width;
	
	return [self imageWithImage:inImage scaledToSize:CGSizeMake(imageWidth, imageHeight)];
	
}

+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution orientation:(UIImageOrientation)orientation;
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > maxResolution || height > maxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    switch (orientation) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageCopy;
}



@end
