//
//  ImageCutTestAppDelegate.h
//  ImageCutTest
//
//  Created by pkh on 11. 6. 2..
//  Copyright 2011 스페이스링크. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCutTestViewController;

@interface ImageCutTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ImageCutTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ImageCutTestViewController *viewController;

@end

