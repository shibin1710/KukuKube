//
//  ViewController.h
//  KukuKube
//
//  Created by Shibin S on 11/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayViewController.h"
#import "ResultViewController.h"
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>
#import "SettingsTableViewCell.h"
#import "CustomIOSAlertView.h"

@interface ViewController : UIViewController<PlayDelegate,ResultDelegate,ADBannerViewDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,GKGameCenterControllerDelegate,UIPopoverPresentationControllerDelegate,ADInterstitialAdDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,UITableViewDataSource,UITableViewDelegate,SettingsDelegate,CustomIOSAlertViewDelegate>

@property (strong, nonatomic) AVAudioPlayer *myPlayer;


@end

