//
//  RITCoreTextViewController.m
//  TextViewTest
//
//  Created by Aleksandr Pronin on 03.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITCoreTextViewController.h"

@interface RITCoreTextViewController ()

@end

@implementation RITCoreTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBarButton:(UIBarButtonItem *)sender {
    NSLog(@"frame: %@ bounds: %@", NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

@end
