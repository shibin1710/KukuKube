//
//  SettingsTableViewCell.m
//  KukuKube
//
//  Created by Shibin S on 05/04/15.
//  Copyright (c) 2015 Shibin. All rights reserved.
//

#import "SettingsTableViewCell.h"

@implementation SettingsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchClicked:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchButtonClicked:)]) {
        [self.delegate switchButtonClicked:sender];
    }
}
@end
