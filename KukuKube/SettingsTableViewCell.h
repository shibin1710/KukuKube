//
//  SettingsTableViewCell.h
//  KukuKube
//
//  Created by Shibin S on 05/04/15.
//  Copyright (c) 2015 Shibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsDelegate <NSObject>

- (void)switchButtonClicked:(UISwitch *)aSwitch;

@end

@interface SettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *settingName;
@property (weak, nonatomic) IBOutlet UILabel *themeName;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (assign, nonatomic) id<SettingsDelegate> delegate;
@end
