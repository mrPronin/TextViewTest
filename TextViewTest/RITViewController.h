//
//  RITViewController.h
//  TextViewTest
//
//  Created by Pronin Alexander on 26.08.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RITViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)setTextButton:(UIButton *)sender;

@end
