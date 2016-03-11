//
//  ResultViewController.m
//  KukuKube
//
//  Created by Shibin S on 18/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import "ResultViewController.h"
#import <QuartzCore/QuartzCore.h>

#define RATE_APP_GAME_COUNT 25

@interface ResultViewController ()
{
    int gameCount;
    BOOL showReviewAlert;
    BOOL isAdFree;
}

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *startNewGameButton;
@property (weak, nonatomic) IBOutlet UILabel *yourLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAgainText;
@property (assign, nonatomic) NSString *leaderBoardIdentifier;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAdButton;
@property (weak, nonatomic) IBOutlet ADBannerView *banner;


@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isAdFree = [[[NSUserDefaults standardUserDefaults]objectForKey:@"adFree"]boolValue];
    if (isAdFree) {
        [self hideAds];
        [self.removeAdButton setTitle:@"scores" forState:UIControlStateNormal];
    } else {
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
        [self.removeAdButton setTitle:@"remove ads" forState:UIControlStateNormal];

    }
    gameCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"gameCount"]intValue];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"reviewAlert"] == nil) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"reviewAlert"];
    }
    showReviewAlert = [[[NSUserDefaults standardUserDefaults]objectForKey:@"reviewAlert"]boolValue];
    gameCount ++;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:gameCount] forKey:@"gameCount"];
    switch (self.currentLevel) {
        case 1:
            self.leaderBoardIdentifier = @"Beginner";
            break;
        case 2:
            self.leaderBoardIdentifier = @"Expert";
            break;
        case 3:
            self.leaderBoardIdentifier = @"Legend";
            break;
        case 4:
            self.leaderBoardIdentifier = @"Infinite";
            break;
        default:
            break;
    }
    self.homeButton.layer.cornerRadius = 10;
    self.shareButton.layer.cornerRadius = 10;

    self.removeAdButton.layer.cornerRadius = 10;

    self.startNewGameButton.layer.cornerRadius = 10;
    self.yourLabel.text = (self.isHighScore) ? @"new high" : @"your";
    [self.playAgainText setTitle:(self.isHighScore) ? @"play again" : @"retry" forState:UIControlStateNormal];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i",self.currentScore];
    [self reportScore];
    [self updateAchievements];
    if (gameCount == RATE_APP_GAME_COUNT && showReviewAlert) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"If you like this game, please rate and review Kuku Kube." delegate:self cancelButtonTitle:@"Don't ask me again"
                                                 otherButtonTitles:@"Write Review",@"Remind Me Later",nil];
        alertView.tag = 9865;
        [alertView show];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"gameCount"];

    }
    // Do any additional setup after loading the view.
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 9865) {
        if (buttonIndex == 1) {
             [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id944673793"]];
        } if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:@"reviewAlert"];
        }
       
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)playAgainButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapPlayAgain)]) {
        [self.delegate didTapPlayAgain];
    }
}
- (IBAction)goToHomeButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeButtonTapped:)]) {
        [self.delegate homeButtonTapped:NO];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didClickFBButton:(id)sender {
    NSString *levelName = @"Easy";
    switch (self.currentLevel) {
        case 1:
            levelName = @"Beginner";
            break;
        case 2:
            levelName = @"Expert";
            break;
        case 3:
            levelName = @"Legend";
            break;
        case 4:
            levelName = @"Infinite";
            break;
        default:
            break;
    }
    NSString *text = [NSString stringWithFormat:@"I scored %i points in %@ Mode in KukuKuke. I challenge you to beat my score. Download Kuku Kube from AppStore \n https://itunes.apple.com/us/app/expensemobile/id944673793?ls=1&mt=8",self.currentScore,levelName];
    [self shareInFB:text];
}

- (IBAction)didClickTwitterButton:(id)sender {
    NSString *levelName = @"Easy";
    switch (self.currentLevel) {
        case 1:
            levelName = @"Beginner";
            break;
        case 2:
            levelName = @"Expert";
            break;
        case 3:
            levelName = @"Legend";
            break;
        case 4:
            levelName = @"Infinite";
            break;
        default:
            break;
    }
    NSString *text = [NSString stringWithFormat:@"I scored %i points in %@ Mode in KukuKuke. I challenge you to beat my score. Download Kuku Kube from AppStore \n https://itunes.apple.com/us/app/expensemobile/id944673793?ls=1&mt=8",self.currentScore,levelName];
    [self shareInTwitter:text];
    
}
- (IBAction)didClickWhatzappButton:(id)sender {
    NSString *levelName = @"Easy";
    switch (self.currentLevel) {
        case 1:
            levelName = @"Beginner";
            break;
        case 2:
            levelName = @"Expert";
            break;
        case 3:
            levelName = @"Legend";
            break;
        case 4:
            levelName = @"Infinity";
            break;
        default:
            break;
    }
    NSString *text = [NSString stringWithFormat:@"I scored %i points in %@ Mode in KukuKuke. I challenge you to beat my score. Download Kuku Kube from AppStore \n https://itunes.apple.com/us/app/expensemobile/id944673793?ls=1&mt=8",self.currentScore,levelName];
    [self shareInWhatzApp:text];
}

- (void)shareInWhatzApp:(NSString *)text
{
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",text];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Kuku Kube" message:@"Sorry, Whatzapp is not installed on your device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)shareInFB:(NSString *)text
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:text];
        [self presentViewController:controller animated:YES completion:Nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Please configure Facebook on your device settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)shareInTwitter:(NSString *)text
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:text];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Please configure Twitter on your device settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


-(void)reportScore{
    // Create a GKScore object to assign the score and report it as a NSArray object.
    
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderBoardIdentifier];
    score.value = self.currentScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    // Init the following view controller object.
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    // Set self as its delegate.
    gcViewController.gameCenterDelegate = self;
    
    // Depending on the parameter, show either the leaderboard or the achievements.
//    if (shouldShowLeaderboard) {
//        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
////        gcViewController.leaderboardIdentifier = self.leaderBoardIdentifier;
//    }
//    else{
//        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
//    }
    
    // Finally present the view controller.
    [self presentViewController:gcViewController animated:YES completion:nil];
}


-(void)updateAchievements{
    // Each achievement identifier will be assigned to this string.
    NSString *achievementIdentifier;
    // The calculated progress percentage will be assigned to the next variable.
    float progressPercentage = 0.0;
    
    // This flag will indicate if any progress regarding the level should be reported to achievements.
//    BOOL progressInLevelAchievement = NO;
    
    // Declare a couple of GKAchievement objects to use in this method.
//    GKAchievement *levelAchievement = nil;
    GKAchievement *scoreAchievement = nil;
    
    // When the currentAdditionCounter equals to 0, then a new level has been started so the progress
    // should be reported.
//    if (_currentAdditionCounter == 0) {
//        if (_level <= 3) {
//            progressPercentage = _level * 100 / 3;
//            achievementIdentifier = @"Achievement_Level3";
//            progressInLevelAchievement = YES;
//        }
//        else if (_level < 6){
//            progressPercentage = _level * 100 / 5;
//            achievementIdentifier = @"Achievement_Level5Complete";
//            progressInLevelAchievement = YES;
//        }
//    }
//    
//    // When the next flag is YES then initiate the levelAchievement object to report the level-related progress.
//    if (progressInLevelAchievement) {
//        levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
//        levelAchievement.percentComplete = progressPercentage;
//    }
    NSMutableArray *achievements = [[NSMutableArray alloc]init];
    switch (self.currentLevel) {
        case 1:
            if (self.currentScore >= 70) {
                achievementIdentifier = @"004";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 65) {
                achievementIdentifier = @"003";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 50) {
                achievementIdentifier = @"002";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 40) {
                achievementIdentifier = @"001";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }

            break;
            
        case 2:
            if (self.currentScore >= 60) {
                achievementIdentifier = @"009";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 50) {
                achievementIdentifier = @"008";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 40) {
                achievementIdentifier = @"007";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 30) {
                achievementIdentifier = @"006";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 20) {
                achievementIdentifier = @"005";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            break;
        case 3:
            if (self.currentScore >= 40) {
                achievementIdentifier = @"013";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 30) {
                achievementIdentifier = @"012";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 20) {
                achievementIdentifier = @"011";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            if (self.currentScore >= 15) {
                achievementIdentifier = @"010";
                progressPercentage = 100;
                scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                scoreAchievement.percentComplete = progressPercentage;
                [achievements addObject:scoreAchievement];
            }
            break;
        default:
            break;
    }
    
    // Initialize the scoreAchievement object and assign the progress.
//    scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
//    scoreAchievement.percentComplete = progressPercentage;
    
    // Depending on the progressInLevelAchievement flag value create a NSArray containing either both
    // or just the scores achievement.
//    NSArray *achievements =  @[scoreAchievement];
    
    // Report the achievements.
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


-(void)resetAchievements{
    // Just call the next method to reset the achievements.
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


#pragma mark - GKGameCenterControllerDelegate method implementation

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showLeaderboard:(id)sender {
    [self showLeaderboardAndAchievements:YES];

}

- (IBAction)shareButton:(id)sender {
    
    NSString *levelName = @"Easy";
    switch (self.currentLevel) {
        case 1:
            levelName = @"Beginner";
            break;
        case 2:
            levelName = @"Expert";
            break;
        case 3:
            levelName = @"Legend";
            break;
        case 4:
            levelName = @"Infinite";
            break;
        default:
            break;
    }
    NSString *text = [NSString stringWithFormat:@"I scored %i points in %@ Mode in KukuKuke. I challenge you to beat my score. Download Kuku Kube from AppStore \n https://itunes.apple.com/us/app/expensemobile/id944673793?ls=1&mt=8",self.currentScore,levelName];
    UIImage *kukuImage = [UIImage imageNamed:@"iconimage.png"];
    UIActivityViewController *shareController = [[UIActivityViewController alloc]initWithActivityItems:@[text,kukuImage] applicationActivities:nil];
    [self presentViewController:shareController animated:YES completion:nil];
}
- (IBAction)removeAdsClicked:(id)sender {
    
    if (isAdFree) {
        
        [self showLeaderboardAndAchievements:YES];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(homeButtonTapped:)]) {
            [self.delegate homeButtonTapped:YES];
        }
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }
    
}

- (void)hideAds
{
    self.banner.alpha = 0;
    //    self.removeAdsButton.hidden = YES;
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

@end
