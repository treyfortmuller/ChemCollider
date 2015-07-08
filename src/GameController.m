//
//  GameController.m
//  BrickBreaker


#import "GameController.h"
#import <stdlib.h>

@implementation GameController

@synthesize scoreLabel, ball, paddle, livesLabel, menuButton, levelLabel, powerUp, tempLabel, slider, productImage, productImageN2O;

- (void)dealloc {
    [scoreLabel release];
    [ball release];
    [productImage release];
    [productImageN2O release];
    [paddle release];
    [musicPlayer release];
    [player1 release];
    [player2 release];
    [player3 release];
    [powerUp release];
    [tempLabel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeValues];
    
    collisionCounter = 0;
    
    powerUpFlag = NO;
    BOOL load = [[NSUserDefaults standardUserDefaults] boolForKey:@"keyLoadButton"];

    if(load) {
        [self loadGame];
        int count = 0;
        for (UIImageView *brick in brickArray) {
            count++;
            [self.view addSubview: brick];   
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"keyLoadButton"];
    } else {
        [self loadBricks];
    }
    levelLabel.hidden = NO;
    levelLabel.text = [NSString stringWithFormat:@"Level: %d", selectedLevel];
    [self loadAudio];
    [self initializeTimer];
}

- (void)initializeValues {
    selectedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"keyLevel"];
    //set volume
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"keySettingsVisited"]) {
        volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"keyVolume"];
        musicVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"keyMusicVolume"];
    } else {
        volume = 0.5;
        musicVolume = 0.2;
    }
    
    lives = 3;
    livesLabel.text = [NSString stringWithFormat:@"%d", lives];
    scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
    ballVelocity = 8;
    ballVelocityX = 1;
    //paddle dimensions
    halfWidth = paddle.image.size.width / 2;
    halfHeight = paddle.image.size.height / 2;
    ballRadius = ball.image.size.height / 2; //same for width and height
    //screen
    screenWidth = 320;
    screenHeight = 460;
    //random variables
    brickNumberHit = -1;
    
    [self loadBackground];
}

- (void)loadBackground {
    selectedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"keyLevel"];
    
    NSString *filename = @"gameback4.png";
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (screenRect.size.height == 568.0f) {
        filename = [filename stringByReplacingOccurrencesOfString:@".png" withString:@"-568h.png"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:filename]];
    }
    
    else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gameback4.png"]];
    }
}

- (void)loadAudio {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bounce" ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: filePath];
    player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    player1.volume = volume;
    
    filePath = [[NSBundle mainBundle] pathForResource:@"bubble" ofType:@"mp3"];
    fileURL = [[NSURL alloc] initFileURLWithPath: filePath];
    player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    player2.volume = volume;
    
    filePath = [[NSBundle mainBundle] pathForResource:@"clink" ofType:@"mp3"];
    fileURL = [[NSURL alloc] initFileURLWithPath: filePath];
    player3 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    player3.volume = volume;
    
    if(selectedLevel == 1){
        filePath = [[NSBundle mainBundle] pathForResource:@"music6" ofType:@"mp3"];
    }else if (selectedLevel == 2){
        filePath = [[NSBundle mainBundle] pathForResource:@"music6" ofType:@"mp3"];
    }else if (selectedLevel == 3){
        filePath = [[NSBundle mainBundle] pathForResource:@"music6" ofType:@"mp3"];
    }else if (selectedLevel == 4){
        filePath = [[NSBundle mainBundle] pathForResource:@"music6" ofType:@"mp3"];
    }else {
        filePath = [[NSBundle mainBundle] pathForResource:@"music6" ofType:@"mp3"];
    }
    
    fileURL = [[NSURL alloc] initFileURLWithPath: filePath];
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    musicPlayer.numberOfLoops = -1; //infinite replays
    musicPlayer.volume = musicVolume;
    
    [player1 prepareToPlay];
    [player2 prepareToPlay];
    [player3 prepareToPlay];
    [musicPlayer prepareToPlay];
    [musicPlayer play];
}

//DONE: save/load brick configuration
- (void)saveGame {
    [[NSUserDefaults standardUserDefaults] setInteger:lives forKey:@"keyLives"];
    [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"keyScore"];
    [[NSUserDefaults standardUserDefaults] setInteger:selectedLevel forKey:@"keyLevel"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject: brickArray] forKey:@"keyBrickArray"];
}

-(void)loadGame {
    lives = [[NSUserDefaults standardUserDefaults] integerForKey:@"keyLives"];
    livesLabel.text = [NSString stringWithFormat:@"%d", lives];
    score = [[NSUserDefaults standardUserDefaults] integerForKey:@"keyScore"];
    scoreLabel.text = [NSString stringWithFormat:@"%f", score];
    selectedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"keyLevel"];
   
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyBrickArray"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    brickArray = [[NSMutableArray alloc] initWithArray: array];
}

- (void)loadBricks {
    brickArray = [[NSMutableArray alloc] init];
    //Level 1
    CGFloat xInit = 40;
    CGFloat yInit = 60;
    CGFloat xOffset = 60;
    CGFloat yOffset = 30;
    int x = 0;
    int y = 0;
    if(selectedLevel==1){
        xOffset = 75;
        yOffset = 40;
        xInit = 48;
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
                brickImage.center = CGPointMake(xInit + xOffset*j, yInit + yOffset*i);
                [brickArray addObject:brickImage];
                [self.view addSubview:brickImage];    
            }
        }
    }    
    else if (selectedLevel==2){
      
        
        for (int i = 0; i < 4; i++) {
            if(y==2)
                y++;
            for (int j = 0; j < 4; j++) {
                if(x==2)
                    x++;
                
                UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
                brickImage.center = CGPointMake(xInit + xOffset*x, yInit + yOffset*y);
                x++;
                
                [brickArray addObject:brickImage];
                [self.view addSubview:brickImage];    
            }
            x = 0;
            y++;
        }
    }
    else if(selectedLevel==3){
       
        
        for (int i=0;i<5;i++){
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*i, yInit + yOffset*0);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];    
        }
        
        for (int i=0;i<5;i++){
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*i, yInit + yOffset*1);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];    
        }
        
        for (int i=2;i<5;i++){
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*0, yInit + yOffset*i);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];    
        }
        
        for (int i=2;i<5;i++){
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*4, yInit + yOffset*i);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];    
        }
        
    }
    else if(selectedLevel==4){
        
        x = 0;
        y = 0;
        for (int i = 0; i < 2; i++) {        
            for (int j = 0; j < 6; j++) {                      
                UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
                brickImage.center = CGPointMake(xInit + xOffset*x, yInit + yOffset*y);
                y++;
                
                [brickArray addObject:brickImage];
                [self.view addSubview:brickImage];    
            }
            y = 0;
            x = x+4;
        }
        UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*2, yInit + yOffset*2);   
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage];   
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*1.5, yInit + yOffset*3);   
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage]; 
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*2.5, yInit + yOffset*3);   
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage]; 
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*2, yInit + yOffset*4);   
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage]; 
    }
    else if (selectedLevel==5){
       
        int j=6;
        for (int i = 0; i < 4; i++) {     
            
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*i, yInit + yOffset*j);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];       
            
        }
        j=7;
        for (int i = 0; i < 4; i++) {     
            
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*i, yInit + yOffset*j);            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];       
            
        }
        j=3;
        for(int i=0;i<6;i++){
            UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
            brickImage.center = CGPointMake(xInit + xOffset*j, yInit + yOffset*i);     
            
            [brickArray addObject:brickImage];
            [self.view addSubview:brickImage];   
        }
        UIImageView *brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*0.5, yInit + yOffset*1);     
        
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage];   
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*0.5, yInit + yOffset*2);     
        
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage];  
        
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*1.5, yInit + yOffset*2);     
        
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage];   
        
        
        brickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO(30).png"]];
        brickImage.center = CGPointMake(xInit + xOffset*1.5, yInit + yOffset*1);     
        
        [brickArray addObject:brickImage];
        [self.view addSubview:brickImage]; 
    }
}

- (void)initializeTimer {
    float interval = 1.0 / 30.0;
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(animateBall:) userInfo:nil repeats:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [self initializeTimer];
        } else if (buttonIndex == 1) {
            [self goToMenu];
        } else if (buttonIndex == 2) {
            [self saveGame];
            [self goToMenu];
        }
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            //next level
            selectedLevel++;
            [[NSUserDefaults standardUserDefaults] setInteger:selectedLevel forKey:@"keyLevel"];
            [self stopSounds];
            [self viewDidLoad];
            [self resetPowerUp];
            [self resetBall];
        } else if (buttonIndex == 1) {
            [self goToMenu];
        }
    } else if (actionSheet.tag == 3) {
        if (buttonIndex == 0) {
            //retry level
            score = 0;
            [self stopSounds];
            [self viewDidLoad];
            [self resetPowerUp];
            [self resetBall];
            //lives = 3;
        } else if (buttonIndex == 1) {
            [self goToMenu];
        }
    } else if (actionSheet.tag == 4) {
        if (buttonIndex == 0) {
            //beat all levels
            [self goToMenu];
        }
    }
}

- (void) stopSounds {
    [musicPlayer release];
    [player1 release];
    [player2 release];
    [player3 release];
}

- (void) goToMenu {
    [self stopSounds];
    ViewController *viewMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
    [self presentViewController:viewMenu animated:YES completion:nil];
}

- (IBAction)didClickMenuButton:(id)sender {
    [self pauseAlertView];
}

- (void) pauseAlertView {
    [self pauseGame];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pause" message:@"" delegate:self cancelButtonTitle:@"Resume" otherButtonTitles: @"Menu", @"Save Game", nil];
    alert.tag = 1;
    [alert show];
    [alert autorelease];
}

- (void) switchLevelAlertView {
    [self pauseGame];
    NSString* messageString = [NSString stringWithFormat: @"Congratulations!\nYou formed %.02f moles of product.", score];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You beat the level!" message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles: @"Next Level", @"Menu", nil];
    alert.tag = 2;
    [alert show];
    [alert autorelease];
}

- (void) gameOverAlertView {
    [self pauseGame];
    NSString* messageString = [NSString stringWithFormat: @"Try agin...\nYou formed %.02f moles of product.", score];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You lost the level!" message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles: @"Retry Level", @"Menu", nil];
    alert.tag = 3;
    [alert show];
    [alert autorelease];
}

- (void) finishGameAlertView {
    [self pauseGame];
    NSString* messageString = [NSString stringWithFormat: @"You must be an AP chem student!\nYou formed %.02f moles of product.", score];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You beat the whole game!" message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles: @"Menu", nil];
    alert.tag = 4;
    [alert show];
    [alert autorelease];
    
}

-(void) pauseGame {
    //stop animating the ball
    [timer invalidate];
}

/*
- (void) animateProductFadeOut {
    NSLog(@"fade out the CO2");
    
    //productImage.alpha = 1.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:1.0 delay:.5 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        productImage.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        productImage.hidden = YES;
    }];
}
*/


- (void) animateProductFadeOut {
    NSLog(@"fade out the CO2");
    productImage.alpha = 0.8;
    [UIView animateWithDuration:0.75 delay:0.25 options:0 animations:^{
        productImage.alpha = 0.0;
    } completion:^(BOOL finished) {
        productImage.hidden = YES;
    }];
}

- (void) animateProductN2OFadeOut {
    NSLog(@"fade out the N20");
    productImageN2O.alpha = 0.8;
    [UIView animateWithDuration:0.75 delay:0.25 options:0 animations:^{
        productImageN2O.alpha = 0.0;
    } completion:^(BOOL finished) {
        productImageN2O.hidden = YES;
    }];
}

- (IBAction)sliderChanged:(id)sender {
    slider = (UISlider *)sender;
    
    NSLog(@"%f", slider.value);
    
    progressAsInt = (int)roundf(slider.value);
    int tempValue = progressAsInt*26;
    tempLabel.text = [NSString stringWithFormat:@"%dK", tempValue];
    
    ballVelocity = progressAsInt;
    //NSLog(@"%f", ballVelocity);
}

- (void)animateBall:(NSTimer *) theTimer {
    ball.center = CGPointMake(ball.center.x + ballMovement.x, ball.center.y + ballMovement.y);
    
    //spin the molecule
    ball.transform = CGAffineTransformRotate(ball.transform, (.1));
    //CGFloat angle = [(NSNumber *)[ball valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    //NSLog(@"%f", angle);
    
    if(powerUpFlag){
        powerUp.center = CGPointMake(powerUp.center.x , powerUp.center.y + 1);
    }
    if(powerUpTimer>=5){
        powerUpTimer=0;
        reverse = NO;
        
        // restore normal ball velocity
        CGFloat sign = 1;
        if (ballMovement.y < 0) {
            sign = -1;
        }
        //NSLog(@"checking for a slider velocity change");
        ballMovement = CGPointMake(ballMovement.x, ballVelocity*sign);
        
    }
    powerUpTimer++;
    if(CGRectIntersectsRect(paddle.frame, powerUp.frame) && powerUpFlag){
        powerUp.alpha = 0;
        powerUpFlag = NO;
        //[powerUp release];
        //Extra life
        if (powerUpType==1){
            lives++;
            livesLabel.text = [NSString stringWithFormat:@"%d", lives];
        }
        //speed up ball
        else if(powerUpType==2){
            CGFloat sign = 1;
            if (ballMovement.y < 0) {
                sign = -1;
            }
            ballMovement = CGPointMake(ballMovement.x, 12*sign);
            
        }
        //Reverse paddle direction
        else if (powerUpType==3){
            reverse=YES;
        }
    }
    
    if (powerUp.center.y > screenHeight){
        if(powerUpFlag){
            powerUpFlag = NO;
            powerUp.alpha = 0;
        }
    }
    // if below paddle, don't even bother checking anything
    if (ball.center.y < paddle.center.y) {
        // check collision on all sides
        BOOL paddleCollision = ball.center.y >= paddle.center.y - halfHeight - ballRadius && 
            ball.center.x > paddle.center.x - halfWidth - ballRadius && 
            ball.center.x < paddle.center.x + halfWidth + ballRadius;
        
        if(paddleCollision) {
            [player1 play];
            ballMovement.y = -ballMovement.y;
            //DONE: change x based on how far away from the center of the paddle the ball landed
            ballMovement.x = (ball.center.x - paddle.center.x) / 4;
        }
    }
    // check border collisions
    if (ball.center.x < ballRadius || ball.center.x > screenWidth - ballRadius){
        [player1 play];
        wallHit = YES;
        ballMovement.x = -ballMovement.x;
    }
    if (ball.center.y < ballRadius + 45){
        [player1 play];
        wallHit = YES;
        ballMovement.y = -ballMovement.y;
    }
    // at bottom of screen
    if (ball.center.y > screenHeight + ballRadius) {
        lives--;
        
        if(lives >= 0){
            livesLabel.text = [NSString stringWithFormat:@"%d", lives];
        } else {
            // GAME OVER
            [self gameOverAlertView];
        }
        //DONE: reset position of ball to center of paddle
        [self resetBall];
        ballMovement = CGPointMake(0, 0);
        ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight - ballRadius - 1);
    }
    // brick collision
    int bricksGone = 0;
    int brickNumberInArray = 0;
    
    for (UIImageView *thisBrick in brickArray) {
        brickNumberInArray++;
        // only continue if brick is there, make it 0.05 to prevent math issues
        if (thisBrick.alpha == 1) {
            if (CGRectIntersectsRect(ball.frame, thisBrick.frame)) {
                
                wallHit = NO;
                
                //add buffer to rectangles
                CGFloat rectBuffer = 1;
                //divide brick into 4 rectangles signifying the four borders
                CGRect up = CGRectMake(thisBrick.frame.origin.x, thisBrick.frame.origin.y, thisBrick.frame.size.width-rectBuffer, thisBrick.frame.size.height/4);
                
                CGRect left = CGRectMake(thisBrick.frame.origin.x, thisBrick.frame.origin.y + thisBrick.frame.size.height/4+rectBuffer, thisBrick.frame.size.width/4, thisBrick.frame.size.height/2-rectBuffer*2);
                
                CGRect right = CGRectMake(thisBrick.frame.origin.x+(thisBrick.frame.size.width/4)*3, thisBrick.frame.origin.y + thisBrick.frame.size.height/4+rectBuffer, thisBrick.frame.size.width/4, thisBrick.frame.size.height/2-rectBuffer*2);
                
                //WHAT HAPPENS ON BRICK COLLISIONS
                
                //if the orientation is correct then bounce the thing and kill the brick
                if (CGRectIntersectsRect(ball.frame, left) && slider.value > 6.3){
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    NSLog(@"left side collision");
                    
                    if (ballMovement.x >= 0) {
                        ballMovement.x = -ballMovement.x;
                        
                        thisBrick.alpha -= (CGFloat)1;
                        
                        [player2 play];
                        
                        productImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO2(32).png"]];
                        productImage.center = CGPointMake(ball.center.x + ballMovement.x, ball.center.y + ballMovement.y);

                        [self.view addSubview:productImage];
                        [self animateProductFadeOut];
                        if (collisionCounter == 0){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O3(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 1){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O2(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 2){
                            UIImage *anotherMolecule = [UIImage imageNamed: @"N2O4(32).png"];
                            [ball setImage:anotherMolecule];
                            
                            score += 2;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                            productImageN2O = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"N2O(32).png"]];
                            productImageN2O.center = CGPointMake(ball.center.x + ballMovement.x - 35, ball.center.y + ballMovement.y);
                            [self.view addSubview:productImageN2O];
                            
                            [self animateProductN2OFadeOut];
                            
                            [self resetBall];
                            ballMovement = CGPointMake(0, 0);
                            ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight - ballRadius - 1);
                            
                            collisionCounter = -1;
                        }
                        
                        collisionCounter++;
                        
                        
                    }
                } if (CGRectIntersectsRect(ball.frame, right) && slider.value > 6.3) {
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    NSLog(@"right side collision with wrong angle");
                    
                    if (ballMovement.x <= 0) {
                        ballMovement.x = -ballMovement.x;
                        [player3 play];
                    }
                } if (CGRectIntersectsRect(ball.frame, up) && slider.value > 6.3){
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    NSLog(@"up side collision");
                    
                    if (ballMovement.y >= 0) {
                        ballMovement.y = -ballMovement.y;
                        //decrease opacity of brick to signify that it is closer to getting destroyed
                        thisBrick.alpha -= (CGFloat)1;
                        
                        [player2 play];
                        
                        productImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO2(32).png"]];
                        productImage.center = CGPointMake(ball.center.x + ballMovement.x, ball.center.y + ballMovement.y);
                        //[brickArray addObject:productImage];
                        [self.view addSubview:productImage];
                        [self animateProductFadeOut];
                        if (collisionCounter == 0){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O3(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 1){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O2(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 2){
                            UIImage *anotherMolecule = [UIImage imageNamed: @"N2O4(32).png"];
                            [ball setImage:anotherMolecule];
                            
                            score += 2;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                            productImageN2O = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"N2O(32).png"]];
                            productImageN2O.center = CGPointMake(ball.center.x + ballMovement.x - 35, ball.center.y + ballMovement.y);
                            [self.view addSubview:productImageN2O];
                            
                            [self animateProductN2OFadeOut];
                            
                            [self resetBall];
                            ballMovement = CGPointMake(0, 0);
                            ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight - ballRadius - 1);
                            
                            collisionCounter = -1;
                        }
                        
                        collisionCounter++;
                        
                    }
                } else if (slider.value > 6.3) {
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    NSLog(@"down side collision");
                    
                    if (ballMovement.y <= 0) {
                        ballMovement.y = -ballMovement.y;
                        //decrease opacity of brick to signify that it is closer to getting destroyed
                        thisBrick.alpha -= (CGFloat)1;
                    
                        [player2 play];
                        
                        productImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CO2(32).png"]];
                        productImage.center = CGPointMake(ball.center.x + ballMovement.x, ball.center.y + ballMovement.y);
                        [self.view addSubview:productImage];
                        [self animateProductFadeOut];
                        
                        if (collisionCounter == 0){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O3(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 1){
                            UIImage *intermediates = [UIImage imageNamed: @"N2O2(32).png"];
                            [ball setImage:intermediates];
                            score += 1;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                        }
                        if (collisionCounter == 2){
                            UIImage *anotherMolecule = [UIImage imageNamed: @"N2O4(32).png"];
                            [ball setImage:anotherMolecule];
                            
                            score += 2;
                            scoreLabel.text = [NSString stringWithFormat:@"%.02f moles", score];
                            
                            productImageN2O = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"N2O(32).png"]];
                            productImageN2O.center = CGPointMake(ball.center.x + ballMovement.x - 35, ball.center.y + ballMovement.y);
                            [self.view addSubview:productImageN2O];
                            
                            [self animateProductN2OFadeOut];
                            
                            [self resetBall];
                            ballMovement = CGPointMake(0, 0);
                            ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight - ballRadius - 1);
                            
                            collisionCounter = -1;
                        }
                        collisionCounter++;
                    }
                }
                
                //if the activtion energy is not sufficient just bounce it off
                
                if (CGRectIntersectsRect(ball.frame, left) && slider.value < 6.3) {
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    if (ballMovement.x >= 0) {
                        ballMovement.x = -ballMovement.x;
                        [player3 play];
                        NSLog(@"left not enough Ea");
                    }
                } if (CGRectIntersectsRect(ball.frame, right) && slider.value < 6.3) {
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    if (ballMovement.x <= 0) {
                        ballMovement.x = -ballMovement.x;
                        [player3 play];
                        NSLog(@"right not enough Ea");
                    }
                } if (CGRectIntersectsRect(ball.frame, up) && slider.value < 6.3){
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    if (ballMovement.y >= 0) {
                        ballMovement.y = -ballMovement.y;
                        [player3 play];
                        NSLog(@"up not enough Ea");
                    }
                } else if (slider.value < 6.3) {
                    NSLog(@"number of collisions: %d ", collisionCounter);

                    if (ballMovement.y <= 0) {
                        ballMovement.y = -ballMovement.y;
                        [player3 play];
                        NSLog(@"down not enough Ea");
                    }
                }
                /*
                else {
                    NSLog(@"NOTHING changed %f %f %f %f", ballMovement.x, ballMovement.y, ball.center.x, ball.center.y);
                }
                */
                //--------------------------------------------------------------------------------------------------------------
                
                //Power up
                float random = arc4random()%100;
                int yPowerPos = 60;
                
                if(random > 85 && !powerUpFlag){
                    powerUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"life1.png"]];
                    powerUpFlag = YES;
                    powerUpType=1;
                    
                    [self.view addSubview:powerUp];
                    random = arc4random()%250 + 20;
                    powerUp.center = CGPointMake(random, yPowerPos);
                    powerUp.alpha = 1;
                    
                    [self.view addSubview:powerUp];
                    random = arc4random()%250 + 20;
                    powerUp.center = CGPointMake(random, yPowerPos);
                    powerUp.alpha = 1;
                }
            }
            
        } else {
            thisBrick.alpha = 0;
            bricksGone++;
        }
    }
    
    if (bricksGone >= [brickArray count]) {
        //DONE: level complete, reset powerUps, reset slider position, reset tempLabel to match.
        [self resetPowerUp];
        [slider setValue:11.5];
        tempLabel.text = @"299K";
        if (selectedLevel >= 5) {
            [self finishGameAlertView];
        } else {
            [self switchLevelAlertView];
        }
    }
}

- (void)resetBall {
    ballMovement = CGPointMake(0, 0);
    ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight - ballRadius - 1);
}

- (void) resetPowerUp{
    powerUp.alpha = 0;
    powerUpFlag = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    levelLabel.hidden = YES;
    
    // initialize movement if there is none
    if (ballMovement.y == 0) {
        ballMovement = CGPointMake(ballVelocityX, ballVelocity);
    }
    UITouch *touch = [[event allTouches] anyObject];
    touchOffset = paddle.center.x - [touch locationInView:touch.view].x;
    //touchOffset = (paddle.center.x - [touch locationInView:touch.view].x) * -1;
    if(reverse){
        touchOffset = [touch locationInView:touch.view].x;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // move ball with paddle if ball is staionary
    if (ballMovement.y == 0) {
        ball.center = CGPointMake(paddle.center.x, paddle.center.y-halfHeight-ballRadius-1);
    }
    UITouch *touch = [[event allTouches] anyObject];
    float distanceMoved = ([touch locationInView:touch.view].x + touchOffset) - paddle.center.x;
    float newX = (paddle.center.x + distanceMoved);
    
    if (reverse) {
        newX = paddle.center.x-([touch locationInView:touch.view].x-touchOffset);
        //newX = screenWidth-newX;
    }
    
    if (newX >= halfWidth && newX <= screenWidth-halfWidth)
        paddle.center = CGPointMake(newX, paddle.center.y);
    if (newX > screenWidth-halfWidth)
        paddle.center = CGPointMake(screenWidth-halfWidth, paddle.center.y);
    if (newX < halfWidth)
        paddle.center = CGPointMake(halfWidth, paddle.center.y);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self saveGame];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
