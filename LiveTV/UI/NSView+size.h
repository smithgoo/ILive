//
//  UIView+size.h
//  seafishing2
//
//  Created by zhaoyk10 on 13-4-23.
//  Copyright (c) 2013年 Szfusion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (size)

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end
