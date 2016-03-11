//
//  PlayViewController.h
//  KukuKube
//
//  Created by Shibin S on 13/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonGridView.h"
#import <iAd/iAd.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomIOSAlertView.h"


@protocol PlayDelegate <NSObject>

- (void)didEndGameWithScore:(int)score forLevel:(int)level;
- (void)didPauseGame;
- (void)didResumeGame;

@end

@interface PlayViewController : UIViewController<ButtonGridViewDataSource,ButtonGridViewDelegate,ADBannerViewDelegate,AVAudioPlayerDelegate,ADInterstitialAdDelegate,UIAlertViewDelegate,CustomIOSAlertViewDelegate>

- (void)pauseGame;

@property (assign, nonatomic) id<PlayDelegate> delegate;

@end
