//
//  RITTextViewLayer.h
//  TextViewTest
//
//  Created by Aleksandr Pronin on 06.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface RITTextViewLayer : CALayer

@property (nonatomic, readwrite, copy) NSAttributedString *attributedString;

@end
