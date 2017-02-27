//
//  StartScreen.m
//  ZoopShooter
//
//  Created by Tom Hartnett on 5/29/15.
//  Copyright (c) 2015 Tom Hartnett. All rights reserved.
//

#import "GameScene.h"
#import "StartScreen.h"

@interface StartScreen ()
@property BOOL contentCreated;
@end

@implementation StartScreen

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild: [self newTitleNode]];
}

- (SKLabelNode *)newTitleNode {
    
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    titleNode.text = @"Tiny Shoot";
    titleNode.fontSize = 40;
    titleNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    titleNode.name = @"title";
    return titleNode;
}

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {
    
    SKNode *titleNode = [self childNodeWithName:@"title"];
    if (titleNode != nil)
    {
        titleNode.name = nil;
        SKAction *moveUp = [SKAction moveByX: 0 y: 100.0 duration: 0.5];
        SKAction *zoom = [SKAction scaleTo: 2.0 duration: 0.25];
        SKAction *pause = [SKAction waitForDuration: 0.5];
        SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.25];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
        
        [titleNode runAction:moveSequence completion:^{
            
            SKScene *gameScene  = [[GameScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:gameScene transition:doors];
        }];
    }
}

@end
