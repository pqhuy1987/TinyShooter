//
//  ViewController.m
//  ZoopShooter
//
//  Created by Tom Hartnett on 5/29/15.
//  Copyright (c) 2015 Tom Hartnett. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "StartScreen.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    SKView *spriteView = (SKView *)self.view;
    spriteView.showsDrawCount = NO;
    spriteView.showsNodeCount = NO;
    spriteView.showsFPS = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    StartScreen* start = [[StartScreen alloc] initWithSize:CGSizeMake(768,1024)];
    SKView *spriteView = (SKView *)self.view;
    [spriteView presentScene: start];
}

@end
