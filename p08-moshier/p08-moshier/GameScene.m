//
//  GameScene.m
//  p08-moshier
//
//  Created by Tom Moshier on 5/8/17.
//  Copyright © 2017 Tom Moshier. All rights reserved.
//

#import "GameScene.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer   = 0x1 << 0,
    CollisionCategoryRegularPlatform = 0x1 << 1,
    CollisionCategoryTriangle = 0x1 << 2,
};

@interface GameScene () <SKPhysicsContactDelegate> {
    SKSpriteNode *aCircle;

    SKShapeNode *circleShape;
    SKShapeNode *topBar;
    SKShapeNode *myTriangle;
    
    SKLabelNode* scoreLabel;
    SKLabelNode* gameOverLabel;
    SKLabelNode* finalScore;
    SKLabelNode* startNode;
    SKLabelNode* timeNode;
    SKLabelNode* levelNode;
    SKLabelNode* finalNum;
    
    SKNode* holder;
    
    CGFloat xAcceleration;
    
    bool gotPowerUp;
    bool gameOver;
    bool touchLeft;
    bool touchRight;
    bool timeFrozen;
    
    double speed;
    int time;
    int score;
    int level;
    
}

@end;

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    [self setUp];
}

-(void)setUp {
    self.backgroundColor = [SKColor blackColor];
    [self addBall];
    self.physicsWorld.gravity = CGVectorMake(0.0f, -9.8f);
    self.physicsWorld.contactDelegate = self;
    gameOver = false;
    gotPowerUp = false;
    xAcceleration = 0;
    level = 1;
    score = 0;
    time = 2000;
    [self spawnPowerUp];
    timeFrozen = false;
    
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    scoreLabel.fontSize = 40;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.position = CGPointMake(0, self.frame.size.height/2 -50);
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    
    timeNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    timeNode.fontSize = 40;
    timeNode.fontColor = [SKColor whiteColor];
    timeNode.position = CGPointMake(-self.frame.size.width/2 +50, self.frame.size.height/2 -50);
    timeNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    timeNode.text = [NSString stringWithFormat:@"%d", time];
    
    levelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    levelNode.fontSize = 40;
    levelNode.fontColor = [SKColor whiteColor];
    levelNode.position = CGPointMake(self.frame.size.width/2 -50, self.frame.size.height/2 -50);
    levelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    levelNode.text = [NSString stringWithFormat:@"%d", level];
    
    holder = [SKNode node];
    int y = -self.size.height/2;
    while(y <= self.size.height/2-200) {
        [self addRectangle:y];
        y+=100;
    }
    [self addRectangle:y];
    [self addChild:scoreLabel];
    [self addChild:levelNode];
    [self addChild:timeNode];
    
    CGSize size;
    size.height = 2;
    size.width = self.frame.size.width;
    CGRect rect;
    CGPoint origin;
    origin.x = -self.frame.size.width/2;
    origin.y = self.frame.size.height/2 -65;
    rect.origin = origin;
    rect.size = size;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    topBar = [SKShapeNode shapeNodeWithPath:path.CGPath];
    topBar.strokeColor = [SKColor whiteColor];
    topBar.fillColor = [SKColor whiteColor];
    [self addChild:topBar];
    [self addChild:holder];
}

- (void) addBall {
    //Add a ball with physics
    //Drawing the ball was found from here: http://stackoverflow.com/questions/24078687/draw-smooth-circle-in-ios-sprite-kit
    float radius = 15.0;
    aCircle = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(radius * 2, radius * 2)];
    SKPhysicsBody *circleBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    [circleBody setDynamic:NO];
    [circleBody setUsesPreciseCollisionDetection:YES];
    aCircle.physicsBody = circleBody;
    CGPathRef bodyPath = CGPathCreateWithEllipseInRect(CGRectMake(-[aCircle size].width / 2, -[aCircle size].height / 2, [aCircle size].width, [aCircle size].width), nil);
    
    
    circleShape = [SKShapeNode node];
    [circleShape setFillColor:[UIColor redColor]];
    [circleShape setLineWidth:0];
    [circleShape setPath:bodyPath];
    [aCircle addChild:circleShape];
    CGPathRelease(bodyPath);
    circleShape.fillColor = [SKColor whiteColor];
    aCircle.position = CGPointMake(0, self.frame.size.height/2 -66);
    [self addChild:aCircle];
    
    aCircle.physicsBody.usesPreciseCollisionDetection = YES;
    aCircle.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    aCircle.physicsBody.collisionBitMask = CollisionCategoryRegularPlatform;
    aCircle.physicsBody.contactTestBitMask = CollisionCategoryRegularPlatform;
}

- (void)addRectangle:(int)y{
    CGSize size;
    size.height = 20;
    size.width = self.frame.size.width;
    CGRect rect;
    CGRect rect2;
    int x = [self getRandomNumberBetween:self.size.width/8 to:self.size.width];
    CGPoint origin;
    CGPoint origin2;
    origin.x = x;
    origin.y = y;
    rect.origin = origin;
    origin2.x = x -850;
    origin2.y = y;
    rect2.origin = origin2;
    rect.size = size;
    rect2.size = size;
    SKSpriteNode *Rectangle1;
    SKSpriteNode *Rectangle2;
    
    if(level%10 == 1) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:rect2.size];
    }
    else if(level%10 == 0) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:rect2.size];
    }
    else if(level%10 == 2) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor orangeColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor orangeColor] size:rect2.size];
    }
    else if(level%10 == 3) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:rect2.size];
    }
    else if(level%10 == 4) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor magentaColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor magentaColor] size:rect2.size];
    }
    else if(level%10 == 5) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:rect2.size];
    }
    else if(level%10 == 6) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:rect2.size];
    }
    else if(level%10 == 7) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:rect2.size];
    }
    else if(level%10 == 8) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor cyanColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor cyanColor] size:rect2.size];
    }
    else if(level%10 == 9) {
        Rectangle1 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:rect.size];
        Rectangle2 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:rect2.size];
    }
    else{
        
    }
    SKPhysicsBody *rectBody = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
    [rectBody setDynamic:NO];
    [rectBody setUsesPreciseCollisionDetection:YES];
    Rectangle1.physicsBody = rectBody;
    Rectangle1.physicsBody.collisionBitMask = CollisionCategoryPlayer;
    Rectangle1.physicsBody.categoryBitMask = CollisionCategoryRegularPlatform;
    Rectangle1.physicsBody.contactTestBitMask = CollisionCategoryPlayer;
    Rectangle1.position = origin;
    Rectangle1.name = @"Rect";
    
    SKPhysicsBody *rectBody2 = [SKPhysicsBody bodyWithRectangleOfSize:rect2.size];
    [rectBody2 setDynamic:NO];
    [rectBody2 setUsesPreciseCollisionDetection:YES];
    Rectangle2.physicsBody = rectBody2;
    Rectangle2.physicsBody.collisionBitMask = CollisionCategoryPlayer;
    Rectangle2.physicsBody.categoryBitMask = CollisionCategoryRegularPlatform;
    Rectangle2.physicsBody.contactTestBitMask = CollisionCategoryPlayer;
    Rectangle2.position = origin2;
    Rectangle2.name = @"Rect";
    
    [holder addChild:Rectangle1];
    [holder addChild:Rectangle2];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if([firstBody.node.name  isEqual: @"TRI"]){
        [myTriangle removeFromParent];
        gotPowerUp = true;
        int powerUpReward = [self getRandomNumberBetween:0 to:10];
        NSLog(@"PowerUp: %d",powerUpReward);
        if(powerUpReward < 5) {
            time+=300;
            NSString *myMessage;
            myMessage = [NSString stringWithFormat:@"+300"];
            [self flashMessage:myMessage atPosition:CGPointMake(-self.frame.size.width/2 +200, self.frame.size.height/2 -50) duration:.5 size:40];
        }
        else if(powerUpReward >5 && powerUpReward <10) {
            int scorePlus;
            scorePlus = level*2000;
            score+=scorePlus;
            NSString *myMessage;
            myMessage = [NSString stringWithFormat:@"+%d",scorePlus];
            [self flashMessage:myMessage atPosition:CGPointMake(200, self.frame.size.height/2 -50) duration:.5 size:40];
        }
        else {
            timeFrozen = true;
            NSString *myMessage;
            myMessage = [NSString stringWithFormat:@"Time Frozen!"];
            [self flashMessage:myMessage atPosition:CGPointMake(0, self.frame.size.height/2 -150) duration:1.5 size:70];
        }
    }
}

-(void)flashMessage:(NSString *)message atPosition:(CGPoint)position duration:(NSTimeInterval)duration size:(int)mySize {
    //a method to make a sprite for a flash message at a certain position on the screen
    //to be used for instructions
    
    //make a label that is invisible
    SKLabelNode *flashLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    flashLabel.position = position;
    flashLabel.fontSize = mySize;
    flashLabel.fontColor = [SKColor whiteColor];
    flashLabel.text = message;
    [self addChild:flashLabel];
    //make an animation sequence to flash in and out the label
    SKAction *flashAction = [SKAction sequence:@[
                                                 [SKAction fadeInWithDuration:duration/3.0],
                                                 [SKAction waitForDuration:duration],
                                                 [SKAction fadeOutWithDuration:duration/3.0]
                                                 ]];
    // run the sequence then delete the label
    [flashLabel runAction:flashAction completion:^{[flashLabel removeFromParent];}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!gameOver) {
        if(aCircle.physicsBody.dynamic == NO) {
            aCircle.physicsBody.dynamic = YES;
        }
        UITouch *touch=[[event allTouches]anyObject];
        CGPoint point= [touch locationInView:self.view];
        if(point.x > self.frame.size.width/4) {
            touchRight = true;
        }
        else {
            touchLeft = true;
        }
    }
    else {
        for(SKNode *node in [self children]) {
            [node removeFromParent];
        }
        [self setUp];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchRight = false;
    touchLeft = false;
}

-(void)update:(CFTimeInterval)currentTime {
    if(!gameOver && aCircle.physicsBody.dynamic == YES) {
        aCircle.physicsBody.velocity = CGVectorMake(xAcceleration * 600.0f, aCircle.physicsBody.velocity.dy);
        if (aCircle.position.x < -self.frame.size.width/2) {
            aCircle.position = CGPointMake(self.frame.size.width/2, aCircle.position.y);
        }
        else if (aCircle.position.x > self.frame.size.width/2) {
            aCircle.position = CGPointMake(-self.frame.size.width/2, aCircle.position.y);
        }
        if(touchRight) {
            xAcceleration = (xAcceleration += 0.03);
        }
        if(touchLeft) {
            xAcceleration = (xAcceleration += -0.03);
        }
        if(!touchRight && !touchLeft) {
            if(xAcceleration > 0) {
                xAcceleration = (xAcceleration -= 0.01);
            }
            else if(xAcceleration < 0){
                xAcceleration = (xAcceleration += 0.01);
            }
        }
        if(xAcceleration > 1) {
            xAcceleration = 1;
        }
        if(xAcceleration < -1) {
            xAcceleration = -1;
        }
        if(aCircle.position.y < -self.frame.size.height/2) {
            [holder removeFromParent];
            
            holder = [SKNode node];
            [self addChild:holder];
            level++;
            int y = -self.size.height/2;
            while(y <= self.size.height/2-200) {
                [self addRectangle:y];
                y+=100;
            }
            if(!gotPowerUp) {
                [myTriangle removeFromParent];
            }
            gotPowerUp = false;
            time+=300;
            NSString *myMessage;
            myMessage = [NSString stringWithFormat:@"Level: %d",level];
            [self flashMessage:myMessage atPosition:CGPointMake(0, self.frame.size.height/2 -150) duration:1.5 size:70];
            myMessage = [NSString stringWithFormat:@"+300"];
            [self flashMessage:myMessage atPosition:CGPointMake(-self.frame.size.width/2 +200, self.frame.size.height/2 -50) duration:.5 size:40];
            levelNode.text = [NSString stringWithFormat:@"%d", level];
            aCircle.position = CGPointMake(aCircle.position.x, self.frame.size.height/2);
            [self spawnPowerUp];
            timeFrozen = false;
        }
        if(!timeFrozen) {
            score += 1*level;
            scoreLabel.text = [NSString stringWithFormat:@"%d", score];
            time--;
            timeNode.text = [NSString stringWithFormat:@"%d", time];
            if(time == 0) {
                gameOver = true;
                for(SKNode *node in [self children]) {
                    [node removeFromParent];
                }
                [self gameOver];
            }
        }
    }
}

-(void) spawnPowerUp {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(40,0)];
    [path addLineToPoint:CGPointMake(20, 40)];
    [path closePath];
    
    int x = [self getRandomNumberBetween:-self.size.width/2+100 to:self.size.width/2-100];
    int y = [self getRandomNumberBetween:-5 to:5];
    y = y*100 - 56;
    
    myTriangle = [SKShapeNode shapeNodeWithPath:path.CGPath];
    myTriangle.strokeColor = [SKColor yellowColor];
    myTriangle.fillColor = [SKColor yellowColor];
    myTriangle.position = CGPointMake(x, y);
    myTriangle.name = @"TRI";
    [self addChild:myTriangle];
    
    SKPhysicsBody *triBody = [SKPhysicsBody bodyWithPolygonFromPath:(path.CGPath)];
    [triBody setDynamic:NO];
    [triBody setUsesPreciseCollisionDetection:YES];
    myTriangle.physicsBody = triBody;
    myTriangle.physicsBody.collisionBitMask = CollisionCategoryPlayer;
    myTriangle.physicsBody.categoryBitMask = CollisionCategoryTriangle;
    myTriangle.physicsBody.contactTestBitMask = CollisionCategoryPlayer;
}

-(void)gameOver {
    gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOverLabel.fontSize = 70;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.position = CGPointMake(0.0f, 500.0f);;
    gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [gameOverLabel setText:@"Game Over"];
    [self addChild:gameOverLabel];
    
    finalScore = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    finalScore.fontSize = 70;
    finalScore.fontColor = [SKColor whiteColor];
    finalScore.position = CGPointMake(0.0f, 250.0f);
    finalScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [finalScore setText:[NSString stringWithFormat:@"Final Score:"]];
    [self addChild:finalScore];
    
    finalNum = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    finalNum.fontSize = 70;
    finalNum.fontColor = [SKColor whiteColor];
    finalNum.position = CGPointMake(0.0f, 0.0f);
    finalNum.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [finalNum setText:[NSString stringWithFormat:@"%d",score]];
    [self addChild:finalNum];
    
    startNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    startNode.fontSize = 55;
    startNode.fontColor = [SKColor whiteColor];
    startNode.position = CGPointMake(0.0f, -250.0f);
    startNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [startNode setText:@"Tap to Try Again"];
    [self addChild:startNode];
}

@end
