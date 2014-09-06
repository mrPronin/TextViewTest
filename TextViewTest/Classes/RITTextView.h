//
//  RITTextView.h
//  TextViewTest
//
//  Created by Aleksandr Pronin on 06.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface RITTextView : UIView

@property (nonatomic, readwrite, copy) NSAttributedString *attributedString;

@end
