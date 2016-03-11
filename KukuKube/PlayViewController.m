//
//  PlayViewController.m
//  KukuKube
//
//  Created by Shibin S on 13/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import "PlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomIOSAlertView.h"

#define TIME 60

typedef enum
{
    Easy = 1,
    Medium = 2,
    Hard = 3,
    Infinity = 4
} DifficultyLevel;

@interface PlayViewController ()
{
    int score;
    float timerCount;
    NSTimer *timer;
    BOOL isPaused;
    BOOL isGameInProgress;
    BOOL isAppPausedWhenResignActive;
    BOOL isAdShown;
    BOOL isAdFree;
}

@property (assign, nonatomic) int randomRowNumber;
@property (assign, nonatomic) int randomColumnNumber;
@property (assign, nonatomic) float redColorValue;
@property (assign, nonatomic) float greenColorValue;
@property (assign, nonatomic) float blueColorValue;
@property (assign, nonatomic) int clickCount;
@property (assign, nonatomic) DifficultyLevel difficultyLevel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIView *pauseMainView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet ADBannerView *banner;
@property (strong, nonatomic) ADInterstitialAd *interstitialAd;
@property (strong, nonatomic) UIView *placeHolderView;
@property (weak, nonatomic) IBOutlet UILabel *timeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreTextLabel;


@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isAdShown = NO;
    [timer invalidate];
    isAdFree = [[[NSUserDefaults standardUserDefaults]objectForKey:@"adFree"]boolValue];
    if (isAdFree) {
        [self removeAds];
    }
    self.interstitialAd = [[ADInterstitialAd alloc]init];
    self.interstitialAd.delegate = self;
    isPaused = NO;
    score = 0;
    isAppPausedWhenResignActive = NO;
    self.difficultyLevel = [[[NSUserDefaults standardUserDefaults]objectForKey:@"difficultyLevel"]intValue]
    ;
    self.clickCount = 0;
    timerCount = self.difficultyLevel == Infinity ? 6 : TIME;
    isGameInProgress = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseGameWhenAppResignsActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeGameAfterAppBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.banner.delegate = self;
    self.banner.hidden = YES;
    self.buttonView.layer.cornerRadius = 5.0;
    self.buttonView.clipsToBounds = YES;
    self.scoreView.layer.cornerRadius = 5;
//    self.scoreView.backgroundColor = [UIColor lightTextColor];
    self.pauseView.layer.cornerRadius = 5.0;
    self.pauseButton.layer.cornerRadius = 5.0;
    self.quitButton.layer.cornerRadius = 5.0;
    self.pauseMainView.layer.cornerRadius = 5;
    self.pauseMainView.hidden = YES;
    
    self.levelLabel.text = [self getLevelName:self.difficultyLevel];
    self.timerLabel.text = [NSString stringWithFormat:@"%i",self.difficultyLevel == Infinity ? 6 : TIME];
    self.highScoreLabel.text = [NSString stringWithFormat:@"%i",[self getHighScoreForLevel:self.difficultyLevel]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!isGameInProgress) {
        [self performSelector:@selector(createButtonGridView) withObject:nil afterDelay:0];
        
    }
    isGameInProgress = YES;
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.banner.delegate = nil;
    self.banner = nil;
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)createButtonGridView
{
    for (UIView *view in self.buttonView.subviews) {
        [view removeFromSuperview];
    }
    ButtonGridView *buttonGridView= [[ButtonGridView alloc]initWithFrame:CGRectMake(0, 0, self.buttonView.frame.size.width, self.buttonView.frame.size.height)];
    buttonGridView.paddingWidth = 3;
    buttonGridView.paddingHeight = 3;
    buttonGridView.buttonCornerRadius = 5;
    buttonGridView.isAnimating = YES;
    buttonGridView.animationDuration = 0.15;
    buttonGridView.dataSource = self;
    buttonGridView.delegate = self;
    self.randomRowNumber = [self createRandowRowNumber];
    self.randomColumnNumber = [self createRandomColumnNumber];
    self.redColorValue =[self createRandomValueForColor];
    self.greenColorValue =[self createRandomValueForColor];
    self.blueColorValue =[self createRandomValueForColor];
    buttonGridView.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:0.5];
    self.scoreLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.scoreTextLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.timerLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.timeTextLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.pauseButton.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.buttonView.backgroundColor = [UIColor whiteColor];
    [self.quitButton setTitleColor:[UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1] forState:UIControlStateNormal];
//    self.view.backgroundColor = [UIColor colorWithRed:self.redColorValue / 0.7 green:self.greenColorValue / 0.7 blue:self.blueColorValue / 0.7 alpha:1];
   [self.buttonView addSubview:buttonGridView];
}

- (int)createRandowRowNumber
{
    return [self createRandomNumberBetweenLowerBound:0 upperBound:self.numberOfRows-1];
}

- (int)createRandomColumnNumber
{
    return [self createRandomNumberBetweenLowerBound:0 upperBound:self.numberOfColumns-1];
}

- (float)createRandomValueForColor
{
    if (self.difficultyLevel == Easy) {
        return [self createRandomNumberBetweenLowerBound:20 upperBound:130]/255.0;
    } else if (self.difficultyLevel == Medium || self.difficultyLevel == Infinity) {
        return [self createRandomNumberBetweenLowerBound:50 upperBound:150]/255.0;
    } else {
        return [self createRandomNumberBetweenLowerBound:50 upperBound:170]/255.0;

    }
}

- (int)createRandomNumberBetweenLowerBound:(int)lowerBound upperBound:(int)upperBound
{
    return lowerBound + arc4random() % (upperBound - lowerBound);
}

#pragma mark - ButtonGridView DataSource Methods

- (int)numberOfColumns
{
    return [self getRowAndColumnNumberForClickCount:self.clickCount];
}

- (int)numberOfRows
{
    return [self getRowAndColumnNumberForClickCount:self.clickCount];
}

- (UIColor *)colorForRow:(int)row Column:(int)column
{
    if (row == self.randomRowNumber && column == self.randomColumnNumber) {
        return [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:[self getAlphaValueForClickCount:self.clickCount]];
    }
    return [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
}

#pragma mark - ButtonGridView Delegate Methods

- (void)didSelectButtonWithRow:(int)rowNumber Column:(int)columnNumber
{
    if (rowNumber == self.randomRowNumber && columnNumber == self.randomColumnNumber) {
        
        [self playSound:@"beep6" :@"mp3"];
        self.clickCount ++;
        score ++;
        self.scoreLabel.text = [NSString stringWithFormat:@"%i",score];
        if (self.difficultyLevel == Infinity) {
            timerCount = [self getTimerForInfinityLevel:self.clickCount];
        }
        [self createButtonGridView];
        
    } else {
        if (self.difficultyLevel == Infinity) {
            [timer invalidate];
            timer = nil;
//            if (self.interstitialAd.loaded && !isAdFree) {
//                isAdShown = YES;
//                self.placeHolderView = [[UIView alloc]initWithFrame:self.view.bounds];
//                [self.view addSubview:self.placeHolderView];
//                [self.interstitialAd presentInView:self.placeHolderView];
//            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)]) {
                    [self.delegate didEndGameWithScore:score forLevel:self.difficultyLevel];
//                }
            }

        }
        if (self.difficultyLevel == Hard || self.difficultyLevel == Medium) {
            score --;
            self.scoreLabel.text = [NSString stringWithFormat:@"%i",score];
        }
        
        [self playSound:@"beep2" :@"wav"];
    }
}

- (int)getRowAndColumnNumberForClickCount:(int)clickCount
{
    if (self.difficultyLevel == Hard) {
        if ( clickCount <= 4) {
            return 5;
        } else if (clickCount <= 8){
            return 6;
        } else if (clickCount <= 12){
            return 7;
        } else if (clickCount <= 17){
            return 8;
        } else {
            return 9;
        }
    } else {
        if (clickCount <= 1) {
            return 3;
        } else if (clickCount <= 4) {
            return 4;
        } else if (clickCount <= 8) {
            return 5;
        } else if (clickCount <= 12) {
            return 6;
        } else if ( clickCount <= 20) {
            return 7;
        } else if (clickCount <= 35) {
            return 8;
        } else {
            return 9;
        }
    }
}

- (float)getAlphaValueForClickCount:(int)clickCount
{
    if (self.difficultyLevel == Easy) {
        return 0.8;
    } else {
        float difficultyLevelFactor = [self getDifficultyFactor];
        return difficultyLevelFactor + (difficultyLevelFactor * clickCount)/ (clickCount + 1);
    }
}

- (float)getDifficultyFactor
{
    switch (self.difficultyLevel) {
        case 2:
        case 4:
            return 0.44;
            break;
        case 3:
            return 0.47;
            break;
        default:
            return 0.5;
            break;
    }
}

- (int)getScoreForCount:(int)clickCount
{
    return clickCount;
//    score = score + clickCount;
//    return score;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)startTimer
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)timerTick
{
    timerCount --;
//    float greenColor = (timerCount/60);
//    float redColor = (TIME - timerCount)/TIME;
//    float blueColor = 0;
    self.timerLabel.text = [NSString stringWithFormat:@"%i",(int)timerCount];
//    self.timerLabel.textColor = [UIColor colorWithRed:redColor green:greenColor blue:blueColor alpha:1];
    if (timerCount <= 0) {
        [timer invalidate];
        timer = nil;
//        if (self.interstitialAd.loaded && !isAdFree) {
//            isAdShown = YES;
//            self.placeHolderView = [[UIView alloc]initWithFrame:self.view.bounds];
//            UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
//            [closeButton setTitle:@"X" forState:UIControlStateNormal];
//            [closeButton.titleLabel setFont:[UIFont systemFontOfSize:30]];
//            closeButton.backgroundColor = [UIColor redColor];
//            [closeButton addTarget:self action:@selector(adCloseClicked) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:self.placeHolderView];
//            [self.view addSubview:closeButton];
//            [self.interstitialAd presentInView:self.placeHolderView];
//        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)]) {
                [self.delegate didEndGameWithScore:score forLevel:self.difficultyLevel];
//            }
        }
        
    }
}

- (IBAction)quitButtonClicked:(id)sender {
    [timer invalidate];
    
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];

    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoViewForTag:0]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Yes",@"No", nil]];
    [alertView setDelegate:self];
    alertView.tag = 100;
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

    
//    UIAlertView *quitAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Do you want to quit the game?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
//    quitAlert.tag = 3500;
//    [quitAlert show];
    
}

- (IBAction)pauseButtonClicked:(id)sender {
    
    if (isPaused) {
        [self resumeGame];
    } else {
        [self pauseGame];
    }
}

- (IBAction)resumeButtonClicked:(id)sender {
    [self resumeGame];
}

- (NSString *)getLevelName:(int)level
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


- (void)playSound :(NSString *)fName :(NSString *) ext{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue]) {
        return;
    }
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}



- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [timer invalidate];
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

- (void)pauseGame
{
    self.buttonView.hidden = YES;
    self.pauseMainView.hidden = NO;
    isPaused = YES;
    self.pauseMainView.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    [self.pauseButton setTitle:@"resume" forState:UIControlStateNormal];
    [timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPauseGame)]) {
        [self.delegate didPauseGame];
    }
}

- (void)resumeGame
{
    isAppPausedWhenResignActive = NO;
    self.buttonView.hidden = NO;
    self.pauseMainView.hidden = YES;
    [self.pauseButton setTitle:@"pause" forState:UIControlStateNormal];
    isPaused = NO;
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResumeGame)]) {
        [self.delegate didResumeGame];
    }
}

- (void)resumeGameAfterAppBecomeActive
{
    if (isAppPausedWhenResignActive) {
        return;
    }
    [self resumeGame];
}

- (void)pauseGameWhenAppResignsActive
{
    if (isPaused) {
        isAppPausedWhenResignActive = YES;
    }
    [self pauseGame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    if (!isAdShown) {
        return;
    }
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)]) {
        [self.delegate didEndGameWithScore:score forLevel:self.difficultyLevel];
    }
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    if (!isAdShown) {
        return;
    }
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)]) {
        [self.delegate didEndGameWithScore:score forLevel:self.difficultyLevel];
    }
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    if (!isAdShown) {
        return;
    }
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)]) {
        [self.delegate didEndGameWithScore:score forLevel:self.difficultyLevel];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3500) {
        if (buttonIndex == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didResumeGame)]) {
                [self.delegate didResumeGame];
            }
            [self.view removeFromSuperview];
        } else if (buttonIndex == 1) {
            [self startTimer];
        }
    }
}

- (void)removeAds
{
    self.banner.alpha = 0;
}

- (int)getTimerForInfinityLevel:(int)clickCnt
{
    if (clickCnt < 15) {
        return 6;
    } else if (clickCnt < 30) {
        return 5;
    } else if (clickCnt < 50) {
        return 4;
    } else if (clickCnt < 70) {
        return 3;
    } else {
        return 2;
    }
}


- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    switch (alertView.tag) {
        case 100:
            if (buttonIndex == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didResumeGame)]) {
                    [self.delegate didResumeGame];
                }
                [self.view removeFromSuperview];
            } else if (buttonIndex == 1) {
                [self startTimer];
            }

        break;
            
        default:
            break;
    }
    
    
    [alertView close];
}

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    switch (tag) {
        case 0:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:20];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Do you really want to quit the game?";
            [demoView addSubview:label];
        }
            break;
            

            
        default:
            break;
    }
    
    return demoView;
}

@end
