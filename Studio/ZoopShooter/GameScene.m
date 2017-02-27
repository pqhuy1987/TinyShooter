//
//  GameScene.m
//  ZoopShooter
//
//  Created by Tom Hartnett on 5/29/15.
//  Copyright (c) 2015 Tom Hartnett. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()
@property BOOL canFire;
@property BOOL contentCreated;
@property BOOL moving;
@property CGPoint startingPoint;
@property (strong, nonatomic) SKNode *cannon;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

static const u_int32_t kMissileCategory = 0x1 << 0;
static const u_int32_t kEnemyCategory   = 0x1 << 1;
static const u_int32_t kCannonCategory  = 0x1 << 2;

@implementation GameScene

- (UITapGestureRecognizer *)tapRecognizer {
    
    if (!_tapRecognizer) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [[self view] addGestureRecognizer:_tapRecognizer];
    }
    return _tapRecognizer;
}

- (void)didMoveToView:(SKView *)view {
    
    if (!self.contentCreated) {
        
        [self createSceneContents];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [[self view] addGestureRecognizer:tapRecognizer];
        
        self.physicsWorld.contactDelegate = self;
        
        self.contentCreated = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (touches.count != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    self.startingPoint = location;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (touches.count != 1)
        return;
    
    if ([self.cannon hasActions])
        return;
    
    self.moving = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Get deltaX and deltaY.
    CGFloat dx = self.startingPoint.x - location.x;
    CGFloat dy = self.startingPoint.y - location.y;

    CGFloat d;
    if (fabs(dx) > fabs(dy)) {
        // dx is bigger.
        d = dx;
        // Check where touch is in relation to cannon and rotate cannon appropriately.
        if (location.y < self.cannon.position.y)
            d *= -1;
        
    } else {
        // dy is bigger.
        d = dy;
        // Check where touch is in relation to cannon and rotate cannon appropriately.
        if (location.x > self.cannon.position.x)
            d *= -1;
    }
    
    // Convert to radians.
    d = d * 0.0174532925;
    
    // Adjust cannon rotation.
    self.cannon.zRotation += d;
    
    // Save location for next touchesMoved event.
    self.startingPoint = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)didSimulatePhysics {
    
    // Remove missiles that have flown off-screen.
    [self enumerateChildNodesWithName:@"missile" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0 || node.position.y > self.frame.size.height || node.position.x < 0 || node.position.x > self.frame.size.width) {
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0 || node.position.y > self.frame.size.height || node.position.x < -50.0 || node.position.x > self.frame.size.width + 50.0) {
            [node removeFromParent];
        }
    }];
    
    NSUInteger count = 0;
    for (SKNode *node in [self children]) {
        if ([node.name isEqualToString:@"enemy"]) {
            count++;
        }
    }
    
    if (count == 0) {
        
        [self resetEnemies];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {

    if ([contact.bodyA.node.name isEqualToString:@"missile"]) {
        [contact.bodyA.node removeFromParent];
    }
    
    if ([contact.bodyB.node.name isEqualToString:@"missile"]) {
        [contact.bodyB.node removeFromParent];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
    // Total hack.
    if (self.moving) {
        self.moving = NO;
        return;
    }
    
    [self fireCannon];
}

- (void)createSceneContents {
    
    self.backgroundColor = [SKColor colorWithRed:78.0/255.0 green:10.0/255.0 blue:136.0/255.0 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsWorld.gravity = CGVectorMake(0,0); // disable gravity
    self.physicsWorld.contactDelegate = self;
    
    self.cannon = [self newCannon];
    self.cannon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.cannon.frame) / 2);
    [self addChild:self.cannon];
    
    [self resetEnemies];
    
    self.canFire = YES;
}

- (void)resetEnemies {
    
    [self addNewEnemy];
    [self addNewEnemy];
    [self addNewEnemy];
    [self addNewEnemy];
    [self addNewEnemy];
}

- (SKShapeNode *)newCannon {
    
    SKShapeNode *cannon = [SKShapeNode shapeNodeWithCircleOfRadius:50];
    cannon.name = @"cannon";
    
    // Setup appearance.
    cannon.fillColor = [UIColor grayColor];
    cannon.strokeColor = [UIColor grayColor];
    
    // Setup physics.
    cannon.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50];
    cannon.physicsBody.affectedByGravity = NO;
    cannon.physicsBody.angularDamping = 0.9;
    cannon.physicsBody.mass = 1000;
    // Set bit masks for collision detection.
    cannon.physicsBody.categoryBitMask = kCannonCategory;
    cannon.physicsBody.contactTestBitMask = 0x0;
    cannon.physicsBody.collisionBitMask = 0x0;
    
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(0, 40);
    [cannon addChild:light1];
    
    return cannon;
}

- (SKSpriteNode *)newLight {
    
    SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
    
    return light;
}

- (SKShapeNode *)newMissile {
    
    SKShapeNode *missile = [SKShapeNode shapeNodeWithCircleOfRadius:5.0];
    missile.fillColor = [SKColor redColor];
    missile.strokeColor = [SKColor redColor];
    
    missile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5.0];
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.affectedByGravity = NO;
    missile.physicsBody.restitution = 0.0;
    missile.physicsBody.linearDamping = 0.0;
    missile.physicsBody.angularDamping = 0.0;
    missile.physicsBody.mass = 1;
    missile.name = @"missile";
    // Set bit masks for collision detection.
    missile.physicsBody.categoryBitMask = kMissileCategory;
    missile.physicsBody.contactTestBitMask = kEnemyCategory;
    missile.physicsBody.collisionBitMask = kEnemyCategory;
    missile.physicsBody.usesPreciseCollisionDetection = YES;

    return missile;
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)addNewEnemy {

    SKNode *enemy = [self newEnemy];
    CGFloat h = self.frame.size.height;
    CGFloat y = skRand(h - 100, h - 500);
    enemy.position = CGPointMake(-40.0, y);
    [self addChild:enemy];
    
    CGFloat d = skRand(7.0, 12.0);
    SKAction *sequence = [SKAction sequence:@[
                                              [SKAction moveToX:self.size.width + 40 duration:d],
                                              [SKAction moveToX:-40 duration:d]]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [enemy runAction:repeat];
}

- (SKNode *)newEnemy {

    CGFloat r = skRand(0.0, 100.0);
    NSString *image;
    if (r < 25.0) {
        image = @"zoop1.png";
    } else if (r < 50.0) {
        image = @"zoop2.png";
    } else if (r < 75.0) {
        image = @"zoop3.png";
    } else {
        image = @"zoop4.png";
    }
    
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:image];
    enemy.size = CGSizeMake(40.0, 40.0);
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.affectedByGravity = NO;
    enemy.physicsBody.restitution = 0.0;
    enemy.physicsBody.linearDamping = 0.0;
    enemy.physicsBody.angularDamping = 0.0;
    enemy.physicsBody.mass = 10;
    enemy.name = @"enemy";
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40.0, 40.0)];
    
    // Set bitmasks for collision detection.
    enemy.physicsBody.categoryBitMask = kEnemyCategory;
    enemy.physicsBody.contactTestBitMask = kMissileCategory;
    enemy.physicsBody.collisionBitMask = kMissileCategory;
    
    return enemy;
}

- (void)fireCannon {
    
    // Only fire cannon if cannon is loaded.
    if (!self.canFire)
        return;
    
    // Need to correct angle by PI/2 for some unknown reason.
    CGFloat angle = self.cannon.zRotation + M_PI_2;
    // Get new missile.
    SKShapeNode *missile = [self newMissile];
    // Calculate missile position as point on circle at appropriate angle.
    CGFloat x = self.cannon.position.x + self.cannon.frame.size.width/2 * cos(angle);
    CGFloat y = self.cannon.position.y + self.cannon.frame.size.height/2 * sin(angle);
    missile.position = CGPointMake(x, y);
    // Add missile to scene.
    [self addChild:missile];
    // Fire missile (apply impulse to it).
    [missile.physicsBody applyImpulse:CGVectorMake(500 * cos(angle), 500 * sin(angle))];
    // Reload cannon.
    SKAction *cannonReloadSequence = [self getCannonReloadSequence];
    [self runAction:cannonReloadSequence];
}

- (SKAction *)getCannonReloadSequence {
    
    SKAction *cannonReloadSequence = [SKAction sequence:@[
                                                  [SKAction runBlock:^{
        SKShapeNode *cannon = (SKShapeNode *)self.cannon;
        [cannon setFillColor:[SKColor blackColor]];
        [cannon setStrokeColor:[SKColor blackColor]];
        self.canFire = NO;
    }],
                                                  [SKAction waitForDuration:0.25],
                                                  [SKAction runBlock:^{
        SKShapeNode *cannon = (SKShapeNode *)self.cannon;
        [cannon setFillColor:[SKColor grayColor]];
        [cannon setStrokeColor:[SKColor grayColor]];
        self.canFire = YES;
    }]]];
    
    return cannonReloadSequence;
}

@end
