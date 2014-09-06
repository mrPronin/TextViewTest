//
//  RITCoreTextViewController.h
//  TextViewTest
//
//  Created by Aleksandr Pronin on 03.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RITCoreTextViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *textView;
- (IBAction)actionBarButton:(UIBarButtonItem *)sender;

@end
