//
//  PSHMenuViewController.m
//  Home
//
//  Created by Kenny Tang on 4/22/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMenuViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHMenuGestureRecognizer.h"

#import <QuartzCore/QuartzCore.h>


static NSInteger const kPSHMenuViewControllerLaunchPhoneButton = 1112;
static NSInteger const kPSHMenuViewControllerLaunchMailButton = 1113;
static NSInteger const kPSHMenuViewControllerLaunchMapsButton = 1114;
static NSInteger const kPSHMenuViewControllerLaunchBrowserButton = 1115;
static NSInteger const kPSHMenuViewControllerLaunchFBButton = 1116;
static NSInteger const kPSHMenuViewControllerLaunchMessengerButton = 1117;
static NSInteger const kPSHMenuViewControllerLaunchInstagramButton = 1118;
static NSInteger const kPSHMenuViewControllerLaunchCameraButton = 1119;
static NSInteger const kPSHMenuViewControllerLaunchPhotosButton = 1120;


@interface PSHMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView * menuButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * menuButtonImageView;

@property (nonatomic, weak) IBOutlet UIView * messengerButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * messengerButtonImageView;

@property (nonatomic, weak) IBOutlet UIView * notificationsButtonView;

@property (nonatomic, weak) IBOutlet UIView * launcherButtonView;
@property (nonatomic, weak) IBOutlet UIView * launcherMenuView;

@property (nonatomic) BOOL menuExpanded;


@property (nonatomic, strong) PSHMenuGestureRecognizer * menuGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer * menuTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer * menuLongGestureRecognizer;


@property (nonatomic) CGRect defaultMenuButtonFrame;
@property (nonatomic) CGRect defaultMessengerButtonFrame;
@property (nonatomic) CGRect defaultNotificationsButtonFrame;
@property (nonatomic) CGRect defaultLauncherButtonFrame;

- (IBAction)launchAppButtonTapped:(id)sender;

@end

@implementation PSHMenuViewController

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
    [self initMenuButton];
    [self initMessengerButton];
    [self initAppLauncherButton];
    [self initNotificationsButton];
    self.menuExpanded = NO;
    
    self.menuGestureRecognizer = [[PSHMenuGestureRecognizer alloc] init];
    [self.menuGestureRecognizer addTarget:self action:@selector(menuGestureRecognizerAction:)];
    
    self.menuGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.menuGestureRecognizer];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initMenuButton {
    self.defaultMenuButtonFrame = self.menuButtonView.frame;
    self.menuButtonView.tag = kPSHMenuViewControllerMenuButtonViewTag;
    [self.menuButtonView.layer setCornerRadius:30.0f];
    [self.menuButtonView.layer setMasksToBounds:YES];
    [self.menuButtonView.layer setBorderWidth:2.0f];
    [self.menuButtonView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    self.menuButtonView.backgroundColor = [UIColor clearColor];
    
    FetchProfileSuccess fetchProfileSuccess =^(NSString * graphID, NSString * avartarImageURL, NSError * error){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.menuButtonImageView.image = profileImage;
            });
        });
    };
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchOwnProfile:fetchProfileSuccess];
    
    self.menuTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    self.menuTapGestureRecognizer.delegate = self;
    [self.menuTapGestureRecognizer addTarget:self action:@selector(menuButtonTapped:)];
    [self.menuButtonView addGestureRecognizer:self.menuTapGestureRecognizer];
    
    self.menuLongGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    self.menuLongGestureRecognizer.delegate = self;
    self.menuLongGestureRecognizer.minimumPressDuration = .5f;
    [self.menuLongGestureRecognizer addTarget:self action:@selector(menuButtonLongPressed:)];
    [self.menuButtonView addGestureRecognizer:self.menuLongGestureRecognizer];
    
    
    
}

- (void) initMessengerButton {
    [self.messengerButtonView.layer setCornerRadius:45.0f/2];
    [self.messengerButtonView.layer setMasksToBounds:YES];
    [self.messengerButtonView.layer setBorderWidth:.5f];
    [self.messengerButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.messengerButtonView.backgroundColor = [UIColor lightGrayColor];
    
}

- (void) initAppLauncherButton {
    [self.launcherButtonView.layer setCornerRadius:45.0f/2];
    [self.launcherButtonView.layer setMasksToBounds:YES];
    [self.launcherButtonView.layer setBorderWidth:.5f];
    [self.launcherButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.launcherButtonView.backgroundColor = [UIColor lightGrayColor];
    self.launcherMenuView.hidden = YES;
}

- (void) initNotificationsButton {
    [self.notificationsButtonView.layer setCornerRadius:45.0f/2];
    [self.notificationsButtonView.layer setMasksToBounds:YES];
    [self.notificationsButtonView.layer setBorderWidth:.5f];
    [self.notificationsButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.notificationsButtonView.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)menuButtonLongPressed:(UILongPressGestureRecognizer*)longRecognizer {
    if (longRecognizer.state == UIGestureRecognizerStateBegan){
        if (self.menuExpanded){
            [self animateHideMenuButtons];
        }else{
            [self animateExpandMenuButtons];
        }
    }else{
        [self animateHideMenuButtons];
        
    }
}

- (void) menuGestureRecognizerAction:(PSHMenuGestureRecognizer*)recognizer {
//    NSLog(@"menuGestureRecognizerAction state: %i", recognizer.state);
    CGRect launcherFrame = self.launcherButtonView.frame;
    CGRect messengerFrame = self.messengerButtonView.frame;
    CGRect notificationFrame = self.notificationsButtonView.frame;
    
//    CGRect initialButtonsFrame = CGRectMake(130.0f, 474.0f, 60.0f, 60.0f);
//    if ((CGRectContainsRect(initialButtonsFrame, launcherFrame)) ||
//        (CGRectContainsRect(initialButtonsFrame, messengerFrame)) ||
//        (CGRectContainsRect(initialButtonsFrame, notificationFrame))
//    ){
//        // ignore event if all buttons are at initial position
//        return;
//    }
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        launcherFrame = self.launcherButtonView.frame;
        messengerFrame = self.messengerButtonView.frame;
        notificationFrame = self.notificationsButtonView.frame;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint currentTouchPoint = [recognizer locationInView:self.view];
        if (CGRectContainsPoint(self.defaultLauncherButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.launcherButtonView.frame, self.defaultLauncherButtonFrame)){
                [self animateShowLauncher];
                [self resetMenuButton];
//                [self animateHideMenuButtons];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
            
        }else if (CGRectContainsPoint(self.defaultMessengerButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.messengerButtonView.frame, self.defaultMessengerButtonFrame)){
                [self animateShowMessenger];
                [self animateHideMenuButtons];
                [self resetMenuButton];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
            
        }else if (CGRectContainsPoint(self.defaultNotificationsButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.notificationsButtonView.frame, self.defaultNotificationsButtonFrame)){
                [self animateShowNotifications];
                [self animateHideMenuButtons];
                [self resetMenuButton];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
        }else{
            CGRect upperFrameRect = self.view.frame;
            upperFrameRect.size.height = upperFrameRect.size.height/1.5;
            if (CGRectContainsPoint(upperFrameRect, currentTouchPoint)){
                [self animateHideMenuButtonsFollowTouchPoint:currentTouchPoint];
                
            }
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        
        CGPoint currentTouchPoint = [recognizer locationInView:self.view];
        CGRect upperFrameRect = self.view.frame;
        upperFrameRect.size.height = upperFrameRect.size.height/1.5;
        if (CGRectContainsPoint(upperFrameRect, currentTouchPoint)){
            [self animateHideMenuButtonsFollowTouchPoint:currentTouchPoint];
        }
        if (!CGRectEqualToRect(self.launcherButtonView.frame, self.defaultLauncherButtonFrame)){
            [self resetMenuButton];
            [self animateHideMenuButtons];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed){
        [self resetMenuButton];
        [self animateHideMenuButtons];
        
    }
}

- (void)menuButtonTapped:(UITapGestureRecognizer*)longRecognizer {
    if (self.menuExpanded){
        [self resetMenuButton];
        [self animateHideMenuButtons];
    }else{
        [self animateExpandMenuButtons];
    }

}

- (void) animateShowLauncher {
    NSLog(@"animateShowLauncher");
    if (self.launcherMenuView.hidden){
        self.launcherButtonView.hidden = NO;
    }else{
        self.launcherButtonView.hidden = YES;
    }
}

- (void) animateShowMessenger {
    NSLog(@"animateShowMessenger");
    NSURL *url = [NSURL URLWithString:@"fb://messaging"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void) animateShowNotifications {
    NSLog(@"animateShowNotifications");
    NSURL *url = [NSURL URLWithString:@"fb://notifications"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void) resetMenuButton {
    [UIView animateWithDuration:0.2f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.menuButtonView.frame = CGRectMake(130.0f, 474.0f, self.menuButtonView.frame.size.width, self.menuButtonView.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

- (void) animateExpandMenuButtons {
    
    
    CGRect messengerButtonViewDestFrame = self.messengerButtonView.frame;
    messengerButtonViewDestFrame.origin.x = 30.0f;
    
    CGRect launcherButtonViewDestFrame = self.launcherButtonView.frame;
    launcherButtonViewDestFrame.origin.y = 360.0f;
    self.launcherButtonView.alpha = 0.0f;
    
    CGRect notificationsViewDestFrame = self.notificationsButtonView.frame;
    notificationsViewDestFrame.origin.x = 240.0f;
    self.notificationsButtonView.alpha = 0.0f;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = messengerButtonViewDestFrame;
        self.launcherButtonView.frame = launcherButtonViewDestFrame;
        self.notificationsButtonView.frame = notificationsViewDestFrame;
        
        self.defaultMessengerButtonFrame = messengerButtonViewDestFrame;
        self.defaultNotificationsButtonFrame = notificationsViewDestFrame;
        self.defaultLauncherButtonFrame = launcherButtonViewDestFrame;
        
        self.launcherButtonView.alpha = 1.0f;
        self.notificationsButtonView.alpha = 1.0f;
        self.messengerButtonView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        // nothing
        self.menuExpanded = YES;
    }];
}

- (void) animateHideMenuButtonsFollowTouchPoint:(CGPoint)currentTouchPoint {
    
    CGRect messengerButtonViewFrame = self.messengerButtonView.frame;
    CGRect notificationsButtonViewFrame = self.notificationsButtonView.frame;
    CGRect launcherButtonViewFrame = self.launcherButtonView.frame;
    
    messengerButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- messengerButtonViewFrame.size.width/1.1, currentTouchPoint.y- messengerButtonViewFrame.size.height/1.1);
    
    notificationsButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- notificationsButtonViewFrame.size.width/1.1, currentTouchPoint.y- notificationsButtonViewFrame.size.height/1.1);
    
    launcherButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- launcherButtonViewFrame.size.width/1.1, currentTouchPoint.y- launcherButtonViewFrame.size.height/1.1);
    
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.messengerButtonView.frame = messengerButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.notificationsButtonView.frame = notificationsButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.launcherButtonView.frame = launcherButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];
    
    
//    CGRect messengerButtonViewFrame = self.messengerButtonView.frame;
//    messengerButtonViewFrame.origin.x = currentTouchPoint.x-20.0f;
//    messengerButtonViewFrame.origin.y = currentTouchPoint.y+20.0f;
//
//    CGRect launcherButtonViewFrame = self.launcherButtonView.frame;
//    launcherButtonViewFrame.origin.x = currentTouchPoint.x-20.0f;;
//    launcherButtonViewFrame.origin.y = currentTouchPoint.y-20.0f;
//    
//    CGRect notificationsButtonViewFrame = self.notificationsButtonView.frame;
//    notificationsButtonViewFrame.origin.x = currentTouchPoint.x-20.0f;
//    notificationsButtonViewFrame.origin.y = currentTouchPoint.y-20.0f;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            self.notificationsButtonView.frame = notificationsButtonViewFrame;
//        } completion:^(BOOL finished) {
//        }];
//        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            self.launcherButtonView.frame = launcherButtonViewFrame;
//        } completion:^(BOOL finished) {
//        }];
//        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            self.messengerButtonView.frame = messengerButtonViewFrame;
//        } completion:^(BOOL finished) {
//            followMenuButtonAnimationLock = 0;
//        }];
//    });
}

- (void) animateHideMenuButtons {
    CGRect messengerButtonViewDestFrame = self.messengerButtonView.frame;
    messengerButtonViewDestFrame.origin.x = 145.0f;
    messengerButtonViewDestFrame.origin.y = 485.0f;
    
    CGRect launcherButtonViewDestFrame = self.launcherButtonView.frame;
    launcherButtonViewDestFrame.origin.x = 138.0f;
    launcherButtonViewDestFrame.origin.y = 474.0f;
    
    CGRect notificationsViewDestFrame = self.notificationsButtonView.frame;
    notificationsViewDestFrame.origin.x = 145.0f;
    notificationsViewDestFrame.origin.y = 485.0f;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = messengerButtonViewDestFrame;
        self.launcherButtonView.frame = launcherButtonViewDestFrame;
        self.notificationsButtonView.frame = notificationsViewDestFrame;
        
        self.launcherButtonView.alpha = 0.0f;
        self.notificationsButtonView.alpha = 0.0f;
        self.messengerButtonView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        // nothing
        self.menuExpanded = NO;

    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ((([gestureRecognizer isEqual:self.menuLongGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer])) ||
          (([gestureRecognizer isEqual:self.menuTapGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer]))){
        return YES;
    }else{
        return NO;
    }
}

- (IBAction)launchAppButtonTapped:(UIView*)sender {
    /*
    NSURL *url = [NSURL URLWithString:@"http://maps.apple.com/maps?daddr="];
    [[UIApplication sharedApplication] openURL:url];
     */
    
    void (*openApp)(CFStringRef, Boolean);
    void *hndl = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices");
    openApp = dlsym(hndl, "SBSLaunchApplicationWithIdentifier");
    
    switch (sender.tag) {
        case kPSHMenuViewControllerLaunchBrowserButton:
            openApp(CFSTR("com.apple.mobilesafari"), FALSE);
            break;
        case kPSHMenuViewControllerLaunchCameraButton:
            openApp(CFSTR("com.apple.camera"), FALSE);
            break;
        case kPSHMenuViewControllerLaunchPhotosButton:
            openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
            break;
            
        default:
            break;
    }
    
    
//    openApp(CFSTR("com.apple.Preferences"), FALSE);
//    openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
}


- (void) viewTapped:(UITapGestureRecognizer*) tapGestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(menuViewController:menuViewTapped:)]){
        [self.delegate menuViewController:self menuViewTapped:YES];
    }
}

@end
