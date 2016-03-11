//
//  ViewController.m
//  KukuKube
//
//  Created by Shibin S on 11/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"
#import "ResultViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HomeTableViewCell.h"
#import "PlayTableViewCell.h"
#import "SettingsTableViewCell.h"
#import "CustomIOSAlertView.h"

typedef enum
{
    Easy = 1,
    Medium = 2,
    Hard = 3,
    Infinity = 4
} DifficultyLevel;

@interface ViewController ()
{
    BOOL isPlaying;
    BOOL isAdFree;
    SKProductsRequest *productsRequest;
}

@property (strong, nonatomic) PlayViewController *playViewController;
@property (strong, nonatomic) ResultViewController *resultViewController;
@property (strong, nonatomic) UIViewController *gameCenterViewController;
@property (strong, nonatomic) UILocalNotification *localNotification;
@property (weak, nonatomic) IBOutlet ADBannerView *banner;
@property (strong, nonatomic) NSArray *musicArray;
@property (assign, nonatomic) BOOL gameCenterEnabled;
@property (assign, nonatomic) NSString *leaderBoardIdentifier;
@property (strong, nonatomic) UIPopoverPresentationController *popPresenter;
@property (strong, nonatomic) ADInterstitialAd *interstitialAd;
@property (strong, nonatomic) UIView *placeHolderView;
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITableView *playTableView;
@property (weak, nonatomic) IBOutlet UILabel *chooseLevelLabel;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchaseButton;
@property (weak, nonatomic) IBOutlet UIView *upgradeView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *upgradeActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPlaying = NO;
    isAdFree = [[[NSUserDefaults standardUserDefaults]objectForKey:@"adFree"]boolValue];
    if (isAdFree) {
        [self hideAds];
    } else {
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
    self.upgradeButton.layer.cornerRadius = 8.0;
    self.restorePurchaseButton.layer.cornerRadius = 8.0;

    self.playView.hidden = YES;
    self.upgradeView.hidden = YES;
    self.settingsView.hidden = YES;
    self.gameCenterEnabled = NO;
    self.interstitialAd = [[ADInterstitialAd alloc]init];
    self.interstitialAd.delegate = self;
    self.musicArray = @[@"Music2"];
    
//    self.version.text = [NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"difficultyLevel"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:Easy] forKey:@"difficultyLevel"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreEasy"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"highScoreEasy"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreMedium"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"highScoreMedium"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreHard"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"highScoreHard"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreInfinity"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"highScoreInfinity"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"soundOn"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"showHelp"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"showHelp"];
    }
//    self.difficultyLevelLabel.text = [self getDifficultyNameForLevel:[self getDifficulty]];
//    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
//        self.soundButton.selected = YES;
//    } else {
//        self.soundButton.selected = NO;
//    }
//    switch ([self getDifficulty]) {
//        case 1:
//            self.leaderBoardIdentifier = @"Beginner";
//            break;
//        case 2:
//            self.leaderBoardIdentifier = @"Expert";
//            break;
//        case 3:
//            self.leaderBoardIdentifier = @"Legend";
//            break;
//        default:
//            break;
//    }
    [self authenticateLocalPlayer];

//    int randomNumber = arc4random() % (self.musicArray.count - 1);

    [self playMusic:[self.musicArray objectAtIndex:0] :@"mp3"];

    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.banner.hidden = YES;
    self.banner.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.banner.delegate = nil;
    self.banner = nil;
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)newGameButtonClicked:(id)sender {
//    self.modeName.text = [NSString stringWithFormat:@"%@ Mode",[self getDifficultyNameForLevel:[self getDifficulty]]];
//    if ([self getDifficulty] == Easy) {
//        self.negativeText.text = @"No penalty for wrong taps.";
//    } else {
//        self.negativeText.text = @"Penalty of 1 point for wrong taps.";
//    }
//    [self performSelector:@selector(loadPlayView) withObject:nil afterDelay:3];
}

- (void)loadPlayView
{
    isPlaying = YES;
    self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
    self.playViewController.delegate = self;
    [self.view addSubview:self.playViewController.view];
}

- (IBAction)difficultyLevelClicked:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    DifficultyLevel difficultyLevel = [self getDifficulty];
    UIAlertAction *easyAction = [UIAlertAction actionWithTitle:@"Beginner" style:difficultyLevel == Easy ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Beginner";
//        self.leaderBoardIdentifier = @"Beginner";
    }];
    UIAlertAction *mediumAction = [UIAlertAction actionWithTitle:@"Expert" style:difficultyLevel == Medium ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:2] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Expert";
//        self.leaderBoardIdentifier = @"Expert";

    }];
    UIAlertAction *hardAction = [UIAlertAction actionWithTitle:@"Legend" style:difficultyLevel == Hard ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:3] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Legend";
//        self.leaderBoardIdentifier = @"Legend";


    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:easyAction];
    [alertController addAction:mediumAction];
    [alertController addAction:hardAction];
    [alertController addAction:cancelAction];
    
    // This will turn the Action Sheet into a popover
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    // Set Modal In Popover to YES to make sure your popover isn't dismissed by taps outside the popover controller
    [alertController setModalInPopover:NO];
    
    // Get the PopoverPresentationController and set the source View and Rect so the Action Sheet knows where to pop up
//    self.popPresenter = [alertController popoverPresentationController];
//    self.popPresenter.delegate = self;
//    self.popPresenter.sourceView = self.view;
//    self.popPresenter.sourceRect = [self.view convertRect:self.gameModeButton.frame fromView:self.gameView];
//    return alertController;

    [self presentViewController:alertController animated:YES completion:nil];
}

- (DifficultyLevel)getDifficulty
{
    NSNumber *difficultyLevel = [[NSUserDefaults standardUserDefaults]objectForKey:@"difficultyLevel"];
    switch (difficultyLevel.intValue) {
        case 1:
            return Easy;
            break;
        case 2:
            return Medium;
            break;
        case 3:
            return Hard;
            break;
        case 4:
            return Infinity;
            break;
        default:
            return Easy;
            break;
    }
}

- (NSString *)getDifficultyNameForLevel:(DifficultyLevel)level
{
    switch (level) {
        case 1:
            return @"Beginner";
            break;
        case 2:
            return @"Expert";
            break;
        case 3:
            return @"Legend";
            break;
        case 4:
            return @"Infinity";
            break;
        default:
            return @"Beginner";
            break;
    }
}

- (void)didEndGameWithScore:(int)score forLevel:(int)level
{
    BOOL highScore = NO;
    if (level == 1 && score > [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreEasy"]intValue]) {
        highScore = YES;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:score] forKey:@"highScoreEasy"];
    }
    if (level == 2 && score > [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreMedium"]intValue]) {
        highScore = YES;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:score] forKey:@"highScoreMedium"];
    }
    if (level == 3 && score > [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreHard"]intValue]) {
        highScore = YES;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:score] forKey:@"highScoreHard"];
    }
    if (level == 4 && score > [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreInfinity"]intValue]) {
        highScore = YES;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:score] forKey:@"highScoreInfinity"];
    }
    self.resultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Result"];
//    self.resultViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    self.resultViewController.currentScore = score;
    self.resultViewController.isHighScore = highScore;
    self.resultViewController.currentLevel = [self getDifficulty];
    self.resultViewController.delegate = self;
    [self presentViewController:self.resultViewController animated:NO completion:^{
        [self.playViewController.view removeFromSuperview];
        self.playViewController = nil;
    }];
}

- (void)didTapPlayAgain
{
    [self.resultViewController dismissViewControllerAnimated:NO completion:nil];
    self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
    self.playViewController.delegate = self;
    [self.view addSubview:self.playViewController.view];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.banner.hidden = NO;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    self.banner.hidden = YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.banner.hidden = YES;
}

- (IBAction)soundButtonClicked:(id)sender {
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"soundOn"];
//        self.soundButton.selected = NO;
        [self.myPlayer pause];
    } else {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"soundOn"];
//        self.soundButton.selected = YES;
//        int randomNumber = arc4random() % (self.musicArray.count - 1);
        [self playMusic:[self.musicArray objectAtIndex:0] :@"mp3"];
    }

}

- (void)playMusic :(NSString *)fName :(NSString *) ext{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
        return;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fName ofType:ext];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    // create new audio player
    self.myPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    self.myPlayer.delegate = self;
    [self.myPlayer play];
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    int randomNumber = arc4random() % (self.musicArray.count - 1);

    [self playMusic:[self.musicArray objectAtIndex:0] :@"mp3"];
}

- (void)didPauseGame
{
    [self.myPlayer pause];
}

- (void)didResumeGame
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
        return;
    }
    [self.myPlayer play];
}


- (void)authenticateLocalPlayer
{
    // Instantiate a GKLocalPlayer object to use for authenticating a player.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            self.gameCenterViewController = viewController;
            // If it's needed display the login view controller.
            UIAlertView *gameCenterAlert = [[UIAlertView alloc]initWithTitle:@"KukuKube" message:@"Do you want to sign in to Game Center?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            gameCenterAlert.tag = 3000;
            [gameCenterAlert show];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // If the player is already authenticated then indicate that the Game Center features can be used.
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderBoardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && alertView.tag == 3000) {
        [self presentViewController:self.gameCenterViewController animated:YES completion:nil];

    }
    if (alertView.tag == 7700) {
        if (buttonIndex == 1) {
            [self restorePurchase];
            NSLog(@"Restore");
        } else if (buttonIndex == 2) {
            [self removeAds];
            NSLog(@"Buy");
        }
    }
    if (alertView.tag == 8000) {
        if (buttonIndex == 2) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.bensound.com"]];
        } else if (buttonIndex == 1) {
          [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id944673793"]];
        }
    }
}
- (IBAction)showLeaderboard:(id)sender {
    [self showLeaderboardAndAchievements:YES];
}


-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    
    // Init the following view controller object.
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    // Set self as its delegate.
    gcViewController.gameCenterDelegate = self;
    
    // Depending on the parameter, show either the leaderboard or the achievements.
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
//        gcViewController.leaderboardIdentifier = self.leaderBoardIdentifier;
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    // Finally present the view controller.
    [self presentViewController:gcViewController animated:YES completion:nil];
}

#pragma mark - GKGameCenterControllerDelegate method implementation

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rateAppClicked:(id)sender {
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id944673793"]];
    UIAlertView *creditAlert = [[UIAlertView alloc]initWithTitle:@"Credits" message:@"Kuku Kube Game is designed, engineered and developed by A-One Mobility Solutions. All music rights belong to www.bensound.com. If you like this game, please put a review in AppStore" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rate App",@"Visit Bensound",nil];
    creditAlert.tag = 8000;
    [creditAlert show];
    
}
- (IBAction)dismissTapped:(id)sender {
    [self loadPlayView];
}

//- (IBAction)changeModeClicked:(id)sender {
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    DifficultyLevel difficultyLevel = [self getDifficulty];
//    UIAlertAction *easyAction = [UIAlertAction actionWithTitle:@"Beginner" style:difficultyLevel == Easy ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Beginner";
//        self.modeName.text = @"Beginner Mode";
//        self.negativeText.text = @"No penalty for wrong taps.";
//        //        self.leaderBoardIdentifier = @"Beginner";
//    }];
//    UIAlertAction *mediumAction = [UIAlertAction actionWithTitle:@"Expert" style:difficultyLevel == Medium ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:2] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Expert";
//         self.modeName.text = @"Expert Mode";
//        self.negativeText.text = @"Penalty of 1 point for wrong taps.";
//        //        self.leaderBoardIdentifier = @"Expert";
//        
//    }];
//    UIAlertAction *hardAction = [UIAlertAction actionWithTitle:@"Legend" style:difficultyLevel == Hard ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:3] forKey:@"difficultyLevel"];
//        self.difficultyLevelLabel.text = @"Legend";
//        self.modeName.text = @"Legend Mode";
//        self.negativeText.text = @"Penalty of 1 point for wrong taps.";
//        //        self.leaderBoardIdentifier = @"Legend";
//        
//        
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//    }];
//    [alertController addAction:easyAction];
//    [alertController addAction:mediumAction];
//    [alertController addAction:hardAction];
//    [alertController addAction:cancelAction];
//    
//    // This will turn the Action Sheet into a popover
//    [alertController setModalPresentationStyle:UIModalPresentationPopover];
//    
//    // Set Modal In Popover to YES to make sure your popover isn't dismissed by taps outside the popover controller
//    [alertController setModalInPopover:NO];
//    
//    // Get the PopoverPresentationController and set the source View and Rect so the Action Sheet knows where to pop up
//    self.popPresenter = [alertController popoverPresentationController];
//    self.popPresenter.delegate = self;
//    self.popPresenter.sourceView = self.view;
//    self.popPresenter.sourceRect = [self.view convertRect:self.changeModeButton.frame fromView:self.view];
//    //    return alertController;
//    
//    [self presentViewController:alertController animated:YES completion:nil];
//}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    if (!isPlaying && !isAdFree) {
//        self.placeHolderView = [[UIView alloc]initWithFrame:self.view.bounds];
//        [self.view addSubview:self.placeHolderView];
//        [self.interstitialAd presentInView:self.placeHolderView];
    }
    
}

- (void)homeButtonTapped:(BOOL)showAdScreen
{
    [self.playTableView reloadData];
    isPlaying = NO;
    if (showAdScreen) {
        self.upgradeView.hidden = NO;
    }
}

- (IBAction)removeAdsClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Kuku Kube"
                          message:@"Do you want to restore purchase / buy ad free version?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Restore Purchase", @"Remove Ads", nil];
    alert.tag = 7700;
    [alert show];
    
}

- (void)removeAds
{
    if([SKPaymentQueue canMakePayments]){
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.shibin.KukuKube.removeAds"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        self.upgradeButton.userInteractionEnabled = YES;
        self.restorePurchaseButton.userInteractionEnabled = YES;
        [self.upgradeActivityIndicator stopAnimating];
        NSLog(@"User cannot make payments due to parental controls");
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to make payments." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        self.upgradeButton.userInteractionEnabled = YES;
        self.restorePurchaseButton.userInteractionEnabled = YES;
        [self.upgradeActivityIndicator stopAnimating];
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Your purchase has been restored. Enjoy the game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
            [self.homeTableView reloadData];
            [self.playTableView reloadData];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to restore purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Purchase was successful. Enjoy the game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                [errorAlert show];
                [self.homeTableView reloadData];
                [self.playTableView reloadData];
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                self.upgradeButton.userInteractionEnabled = YES;
                self.restorePurchaseButton.userInteractionEnabled = YES;
                [self.upgradeActivityIndicator stopAnimating];
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [errorAlert show];
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                break;
        }
    }
}

- (void)doRemoveAds
{
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
    
    [self hideAds];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adFree"];
    isAdFree = YES;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)hideAds
{
    self.banner.alpha = 0;
//    self.removeAdsButton.hidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.homeTableView)
        return 3;
    else if (tableView == self.playTableView)
        return 4;
    else
        return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.homeTableView)
        return tableView.frame.size.height/3;
    else if (tableView == self.playTableView)
        return tableView.frame.size.height/4;
    else
        return tableView.frame.size.height/6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chooseLevelLabel.font = [UIFont fontWithName:@"Georgia" size:self.playTableView.frame.size.height/25];
    self.settingsLabel.font = [UIFont fontWithName:@"Georgia" size:self.settingsTableView.frame.size.height/25];
    if (tableView == self.homeTableView) {
        HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[HomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
        }
        cell.menuLabel.font = [UIFont fontWithName:@"Georgia" size:tableView.frame.size.height/25];
        switch (indexPath.row) {
            case 0:
                if (isAdFree) {
                    cell.menuLabel.text = @"leaderboard";
                } else {
                    cell.menuLabel.text = @"upgrade";
                }
                
                cell.menuLabel.textColor = [UIColor colorWithRed:0.0/255/0 green:100.0/255.0 blue:0.0/255.0 alpha:1.0];
                break;
            case 1:
                cell.menuLabel.text = @"play";
                cell.menuLabel.textColor = [UIColor redColor];
                break;
            case 2:
                cell.menuLabel.text = @"settings";
                cell.menuLabel.textColor = [UIColor purpleColor];
                break;
            default:
                break;
        }
        return cell;
    } else if (tableView == self.playTableView) {
        PlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[PlayTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlayCell"];
        }
        cell.levelName.font = [UIFont fontWithName:@"Georgia" size:tableView.frame.size.height/25];
        cell.levelName.backgroundColor = [UIColor clearColor];
        cell.scoreLabel.font = [UIFont fontWithName:@"Georgia" size:tableView.frame.size.height/25];
        cell.scoreLabel.backgroundColor = [UIColor clearColor];
        
        switch (indexPath.row) {
            case 0:
                cell.levelName.text = @"beginner";
                cell.levelName.textColor = [UIColor colorWithRed:0.0/255/0 green:100.0/255.0 blue:0.0/255.0 alpha:1.0];
                cell.scoreLabel.textColor = [UIColor colorWithRed:0.0/255/0 green:100.0/255.0 blue:0.0/255.0 alpha:1.0];
                cell.scoreLabel.text = [NSString stringWithFormat:@"%i points",[self getHighScoreForLevel:indexPath.row + 1]];
                break;
            case 1:
                cell.levelName.text = @"expert";
                cell.levelName.textColor = [UIColor redColor];
                cell.scoreLabel.textColor = [UIColor redColor];
                cell.scoreLabel.text = [NSString stringWithFormat:@"%i points",[self getHighScoreForLevel:indexPath.row + 1]];
                break;
            case 2:
                cell.levelName.text = @"legend";
                cell.levelName.textColor = [UIColor purpleColor];
                cell.scoreLabel.textColor = [UIColor purpleColor];
                cell.scoreLabel.text = [NSString stringWithFormat:@"%i points",[self getHighScoreForLevel:indexPath.row + 1]];
                break;
            case 3:
                cell.levelName.text = @"infinite";
                cell.levelName.textColor = [UIColor magentaColor];
                cell.scoreLabel.textColor = [UIColor magentaColor];
                if (isAdFree) {
                    cell.scoreLabel.text = [NSString stringWithFormat:@"%i points",[self getHighScoreForLevel:indexPath.row + 1]];
                } else {
                    cell.scoreLabel.text = @"locked";
                }
                
                break;
            default:
                break;
        }
    
        return cell;
    } else {
        
        
        SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SettingsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
        }
        cell.settingName.font = [UIFont fontWithName:@"Georgia" size:self.settingsTableView.frame.size.height/25];
        cell.themeName.font = [UIFont fontWithName:@"Georgia" size:self.settingsTableView.frame.size.height/25];
        cell.soundSwitch.hidden = YES;
        cell.themeName.hidden = YES;
        switch (indexPath.row) {
            case 0:
                cell.delegate = self;
                cell.settingName.text = @"music";
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
                    cell.soundSwitch.on = YES;
                } else {
                    cell.soundSwitch.on = NO;
                }
                cell.soundSwitch.tag = 300;

                cell.soundSwitch.hidden = NO;
                cell.soundSwitch.onTintColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
                cell.settingName.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
                break;
            case 1:
                cell.settingName.text = @"leaderboard";
                cell.settingName.textColor = [UIColor magentaColor];
                break;
            case 2:
                cell.settingName.text = @"rate game";
                cell.settingName.textColor = [UIColor blueColor];
                break;
            case 3:
                cell.delegate = self;
                cell.settingName.text = @"show help";
                cell.themeName.hidden = YES;
                cell.soundSwitch.hidden = NO;
                cell.soundSwitch.tag = 301;
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"showHelp"]boolValue]) {
                    cell.soundSwitch.on = YES;
                } else {
                    cell.soundSwitch.on = NO;
                }
                cell.soundSwitch.onTintColor = [UIColor purpleColor];

                cell.settingName.textColor = [UIColor purpleColor];
                cell.themeName.textColor = [UIColor purpleColor];

                break;
            case 4:
                cell.settingName.text = @"about";
                cell.settingName.textColor = [UIColor orangeColor];
                break;
            default:
                break;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.homeTableView) {
        switch (indexPath.row) {
            case 0:
                if (isAdFree) {
                    [self showLeaderboardAndAchievements:YES];
                } else {
                    self.upgradeView.hidden = NO;

                }
                self.playView.hidden = YES;
                self.settingsView.hidden = YES;

                break;
            case 1:
                self.playView.hidden = NO;
                self.upgradeView.hidden = YES;
                self.settingsView.hidden = YES;
                break;
            case 2:
                self.playView.hidden = YES;
                self.upgradeView.hidden = YES;
                self.settingsView.hidden = NO;
                
                break;
            default:
                break;
        }

    } else if (tableView == self.playTableView) {

        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        BOOL showHelp = [[[NSUserDefaults standardUserDefaults]objectForKey:@"showHelp"]boolValue];

        switch (indexPath.row) {
            case 0:
                if (showHelp) {
                    // Here we need to pass a full frame
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoViewForTag:20]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Play", nil]];
                    [alertView setDelegate:self];
                    alertView.tag = 20;
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                        [alertView close];
                    }];
                    
                    [alertView setUseMotionEffects:true];
                    
                    // And launch the dialog
                    [alertView show];
                } else{
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"difficultyLevel"];
                    self.playView.hidden = YES;
                    [self loadPlayView];
                    
                }
                
//                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"difficultyLevel"];
                break;
            case 1:
                if (showHelp) {
                    // Here we need to pass a full frame
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoViewForTag:21]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Play", nil]];
                    [alertView setDelegate:self];
                    alertView.tag = 21;
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                        [alertView close];
                    }];
                    
                    [alertView setUseMotionEffects:true];
                    
                    // And launch the dialog
                    [alertView show];
                } else {
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:2] forKey:@"difficultyLevel"];
                    self.playView.hidden = YES;
                    [self loadPlayView];
                    
                }
  
//                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:2] forKey:@"difficultyLevel"];
                break;
            case 2:
                if (showHelp) {
                    // Here we need to pass a full frame
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoViewForTag:22]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Play", nil]];
                    [alertView setDelegate:self];
                    alertView.tag = 22;
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                        [alertView close];
                    }];
                    
                    [alertView setUseMotionEffects:true];
                    
                    // And launch the dialog
                    [alertView show];
                } else {
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:3] forKey:@"difficultyLevel"];
                    self.playView.hidden = YES;
                    [self loadPlayView];
                    
                }
                
//                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:3] forKey:@"difficultyLevel"];
                break;
            case 3:
                if (!isAdFree) {

                    // Here we need to pass a full frame
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoViewForTag:0]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Upgrade", @"Cancel", nil]];
                    [alertView setDelegate:self];
                    alertView.tag = 0;
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                        [alertView close];
                    }];
                    
                    [alertView setUseMotionEffects:true];
                    
                    // And launch the dialog
                    [alertView show];
                    return;
                } else {
                    
                    if (showHelp) {
                        // Add some custom content to the alert view
                        [alertView setContainerView:[self createDemoViewForTag:20]];
                        
                        // Modify the parameters
                        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Play", nil]];
                        [alertView setDelegate:self];
                        alertView.tag = 23;
                        
                        // You may use a Block, rather than a delegate.
                        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                            [alertView close];
                        }];
                        
                        [alertView setUseMotionEffects:true];
                        
                        // And launch the dialog
                        [alertView show];
                    } else {
                        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:4] forKey:@"difficultyLevel"];
                        self.playView.hidden = YES;
                        [self loadPlayView];
                        
                    }
                  
                }
//                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:4] forKey:@"difficultyLevel"];
                break;
            default:
                break;
        }
//        self.playView.hidden = YES;
//        [self loadPlayView];
    } else {
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];

//        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Paid feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                [self showLeaderboardAndAchievements:YES];
                break;
            case 2:
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id944673793"]];
                break;
            case 3:
//                if (!isAdFree) {
//                    // Here we need to pass a full frame
//                    
//                    // Add some custom content to the alert view
//                    [alertView setContainerView:[self createDemoViewForTag:2]];
//                    
//                    // Modify the parameters
//                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Upgrade",@"Cancel", nil]];
//                    [alertView setDelegate:self];
//                    alertView.tag = 2;
//                    
//                    // You may use a Block, rather than a delegate.
//                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
//                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
//                        [alertView close];
//                    }];
//                    
//                    [alertView setUseMotionEffects:true];
//                    
//                    // And launch the dialog
//                    [alertView show];
//                }
                
                break;
            case 4:
                
                // Here we need to pass a full frame
                
                // Add some custom content to the alert view
                [alertView setContainerView:[self createDemoViewForTag:1]];
                
                // Modify the parameters
                [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
                [alertView setDelegate:self];
                alertView.tag = 1;
                
                // You may use a Block, rather than a delegate.
                [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                    NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                    [alertView close];
                }];
                
                [alertView setUseMotionEffects:true];
                
                // And launch the dialog
                [alertView show];

                
                break;
            default:
                break;
        }
    }
}

- (int)getHighScoreForLevel:(int)level
{
    switch (level) {
        case 1:
            return [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreEasy"]intValue];
            break;
        case 2:
            return [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreMedium"]intValue];
            break;
        case 3:
            return [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreHard"]intValue];
            break;
        case 4:
            return [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreInfinity"]intValue];
            break;
        default:
            return [[[NSUserDefaults standardUserDefaults]objectForKey:@"highScoreEasy"]intValue];
            break;
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    self.playView.hidden = YES;
    self.upgradeView.hidden = YES;
    self.settingsView.hidden = YES;
    if (productsRequest) {
        [productsRequest cancel];
    }
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
    
}
- (IBAction)upgradeButtonClicked:(id)sender {
    self.upgradeActivityIndicator.color = [UIColor redColor];
    self.upgradeButton.userInteractionEnabled = NO;
    self.restorePurchaseButton.userInteractionEnabled = NO;
    [self.upgradeActivityIndicator startAnimating];
    [self removeAds];
}
- (IBAction)restoreButtonClicked:(id)sender {
    self.upgradeActivityIndicator.color = [UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:0.0/255.0 alpha:1.0];
    [self.upgradeActivityIndicator startAnimating];
    self.upgradeButton.userInteractionEnabled = NO;
    self.restorePurchaseButton.userInteractionEnabled = NO;
    [self restorePurchase];

}

- (void)switchButtonClicked:(UISwitch *)aSwitch
{
    if (aSwitch.tag == 300) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:aSwitch.on] forKey:@"soundOn"];
        if (!aSwitch.on) {
            [self.myPlayer pause];
        } else {
            [self playMusic:[self.musicArray objectAtIndex:0] :@"mp3"];
        }
    }  if (aSwitch.tag == 301) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:aSwitch.on] forKey:@"showHelp"];
    }

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    switch (alertView.tag) {
        case 0:
        {
            if (isAdFree) {
                self.playView.hidden = YES;
                self.upgradeView.hidden = YES;
                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:4] forKey:@"difficultyLevel"];
                [self loadPlayView];
                

            } else {
                if (buttonIndex == 0) {
                    self.upgradeView.hidden = NO;
                    self.playView.hidden = YES;
                    self.settingsView.hidden = YES;
                }
            }

        }
        case 2:
        {
            if (buttonIndex == 0) {
                self.upgradeView.hidden = NO;
                self.playView.hidden = YES;
                self.settingsView.hidden = YES;
            }
        }
        break;
            
        case 20:
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"difficultyLevel"];
            self.playView.hidden = YES;
            [self loadPlayView];
            
            break;
        case 21:
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:2] forKey:@"difficultyLevel"];
            self.playView.hidden = YES;
            [self loadPlayView];
            
            break;
        case 22:
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:3] forKey:@"difficultyLevel"];
            self.playView.hidden = YES;
            [self loadPlayView];
            
            break;
        case 23:
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:4] forKey:@"difficultyLevel"];
            self.playView.hidden = YES;
            [self loadPlayView];
            
            break;
 
        default:
            break;
    }
   
   
    [alertView close];
}

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    switch (tag) {
        case 0:
        {
            if (isAdFree) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
                label.numberOfLines = 0;
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont fontWithName:@"Georgia" size:17];
                label.textColor = [UIColor brownColor];
                label.text = @"Tap on the tile with different shade. For correct tile you will get 1 point. The game will be over if you tap on the wrong tile. Tap on correct tile in specified time. You can play as long as you tap on the correct tile.";
                [demoView addSubview:label];
            } else {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
                label.numberOfLines = 0;
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont fontWithName:@"Georgia" size:20];
                label.textColor = [UIColor brownColor];
                label.text = @"Upgrade game to unlock this level for just 0.99$. It will remove all ads.";
                [demoView addSubview:label];
            }
            
        }
        break;
        
        case 1:
        {
            
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:20];
            label.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
            label.text = @"Kuku Kube Shade Spotter game is developed by A-One Mobile Solutions. All music rights belong to www.bensound.com.";
            [demoView addSubview:label];
        }
        break;
            
        case 2:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:20];
            label.textColor = [UIColor purpleColor];
            label.text = @"Upgrade game to unlock new color themes for just 0.99$. It will remove all ads and unlock new level.";
            [demoView addSubview:label];
        }
        break;
        
        case 20:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:17];
            label.textColor = [UIColor purpleColor];
            label.text = @"Tap on the tile with different shade. For correct tile, you will get 1 point. There is no penalty for tapping wrong tiles. You will get 60 seconds to play. The transparency of the tile will be same throughout the game";
            [demoView addSubview:label];
        }
            break;
            
        case 21:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:17];
            label.textColor = [UIColor purpleColor];
            label.text = @"Tap on the tile with different shade. For correct tile, you will get 1 point. One point will be deducted for tapping wrong tiles. You will get 60 seconds to play. The transparency of the tile reduce as game progress.";
            [demoView addSubview:label];
        }
            break;
            
        case 22:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 200)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:17];
            label.textColor = [UIColor purpleColor];
            label.text = @"Tap on the tile with different shade. For correct tile, you will get 1 point. One point will be deducted for tapping wrong tiles. You will get 60 seconds to play. The transparency of the tile reduce as game progress.";
            [demoView addSubview:label];
        }
            break;
            
        default:
            break;
    }
    
    return demoView;
}

@end
