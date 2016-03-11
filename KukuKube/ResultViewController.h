//
//  ResultViewController.h
//  KukuKube
//
//  Created by Shibin S on 18/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <GameKit/GameKit.h>
#import <iAd/iAd.h>

@protocol ResultDelegate <NSObject>

- (void)didTapPlayAgain;
- (void)homeButtonTapped:(BOOL)showAdScreen;

@end

@interface ResultViewController : UIViewController<GKGameCenterControllerDelegate,ADInterstitialAdDelegate,UIAlertViewDelegate,ADBannerViewDelegate>

@property (assign, nonatomic) id<ResultDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (assign, nonatomic) BOOL isHighScore;
@property (assign, nonatomic) int currentScore;
@property (assign, nonatomic) int currentLevel;


@end
