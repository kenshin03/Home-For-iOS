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
#import "PSHNotificationsViewController.h"
#import "PSHMessagingViewController.h"
#import "PSHFacebookXMPPService.h"

#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

static NSInteger const kPSHMenuViewControllerLaunchPhoneButton = 1112;
static NSInteger const kPSHMenuViewControllerLaunchMailButton = 1113;
static NSInteger const kPSHMenuViewControllerLaunchMapsButton = 1114;

static NSInteger const kPSHMenuViewControllerLaunchBrowserButton = 1115;
static NSInteger const kPSHMenuViewControllerLaunchMessengerButton = 1116;
static NSInteger const kPSHMenuViewControllerLaunchYoutubeButton = 1117;

static NSInteger const kPSHMenuViewControllerLaunchMusicButton = 1118;
static NSInteger const kPSHMenuViewControllerLaunchInstagramButton = 1119;
static NSInteger const kPSHMenuViewControllerLaunchTwitterButton = 1120;


@interface PSHMenuViewController ()<UIGestureRecognizerDelegate, PSHNotificationsViewControllerDelegate>

// own profile or menu button
@property (nonatomic, weak) IBOutlet UIView * menuButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * menuButtonImageView;

// messenger button
@property (nonatomic, weak) IBOutlet UIView * messengerButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * messengerButtonImageView;
@property (nonatomic, weak) IBOutlet UILabel * messengerButtonLabel;

// notification button
@property (nonatomic, weak) IBOutlet UIView * notificationsButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * notificationsButtonImageView;
@property (nonatomic, weak) IBOutlet UILabel * notificationsButtonLabel;

// launcher button
@property (nonatomic, weak) IBOutlet UIView * launcherButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * launcherButtonImageView;
@property (nonatomic, weak) IBOutlet UILabel * launcherButtonLabel;


// launcher menu
@property (nonatomic, weak) IBOutlet UIView * launcherMenuView;

@property (nonatomic) BOOL menuExpanded;

@property (nonatomic, strong) NSString * ownGraphID;

@property (nonatomic, strong) PSHMenuGestureRecognizer * menuGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer * menuTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer * menuLongGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;

// expanded positions of container frames (including top labels).
@property (nonatomic) CGRect expandedMenuButtonFrame;
@property (nonatomic) CGRect expandedMessengerButtonFrame;
@property (nonatomic) CGRect expandedNotificationsButtonFrame;
@property (nonatomic) CGRect expandedLauncherButtonFrame;

// collapsed positions
@property (nonatomic) CGRect collapsedButtonsFrame;


// sound
@property (nonatomic) SystemSoundID openMenuItemSoundID;


// notifications
@property (nonatomic, strong) UIView * notificationsView;


- (IBAction)launchAppButtonTapped:(id)sender;

- (IBAction)statusUpdateButtonTapped:(id)sender;
- (IBAction)photosButtonTapped:(id)sender;
- (IBAction)reloadButtonTapped:(id)sender;



@end

@implementation PSHMenuViewController

- (void)dealloc {
    
	AudioServicesDisposeSystemSoundID (_openMenuItemSoundID);
    
}

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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = screenBounds;
    
    // single tap
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self.tapGestureRecognizer addTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // swipe left or right on view
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [swipeGestureRecognizer addTarget:self action:@selector(viewSwiped:)];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    // custom gesture recognizer
    self.menuGestureRecognizer = [[PSHMenuGestureRecognizer alloc] init];
    [self.menuGestureRecognizer addTarget:self action:@selector(menuGestureRecognizerAction:)];
    self.menuGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.menuGestureRecognizer];
    
    
    [super viewDidLoad];
    [self initMenuButton];
    [self initMessengerButton];
    [self initAppLauncherButton];
    [self initNotificationsButton];
    [self initAppLauncher];
    [self initAudioServices];
    
    
    self.menuExpanded = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initAudioServices {
    
	NSString * openMenuSoundResPath = [[NSBundle mainBundle] pathForResource:@"menu_item_open" ofType:@"wav"];
    
	NSURL * openMenuItemSoundURLRef = [NSURL fileURLWithPath:openMenuSoundResPath isDirectory:NO];
	AudioServicesCreateSystemSoundID ((__bridge CFURLRef)openMenuItemSoundURLRef, &_openMenuItemSoundID);
}

- (void)playOpenMenuItemSound {
    AudioServicesPlaySystemSound(self.openMenuItemSoundID);
}


- (void) initMenuButton {
    
    if (self.view.frame.size.height == 480){
        // expanded
        self.expandedMenuButtonFrame = CGRectMake(120.0f, 458.0f-88.0f, 80.0f, 80.0f);
        self.expandedMessengerButtonFrame = CGRectMake(10.0f, 429.0f-88.0f, 72.0f, 110.0f);
        self.expandedLauncherButtonFrame = CGRectMake(124.0f, 306.0f-88.0f, 72.0f, 110.0f);
        self.expandedNotificationsButtonFrame = CGRectMake(240.0f, 429.0f-88.0f, 72.0f, 110.0f);
        
        // collapsed
        self.collapsedButtonsFrame = CGRectMake(124.0f, 430.0f-88.0f, 72.0f, 110.0f);
        
    }else{
        
        // expanded
        self.expandedMenuButtonFrame = CGRectMake(120.0f, 458.0f, 80.0f, 80.0f);
        self.expandedMessengerButtonFrame = CGRectMake(10.0f, 429.0f, 72.0f, 110.0f);
        self.expandedLauncherButtonFrame = CGRectMake(124.0f, 306.0f, 72.0f, 110.0f);
        self.expandedNotificationsButtonFrame = CGRectMake(240.0f, 429.0f, 72.0f, 110.0f);
        
        // collapsed
        self.collapsedButtonsFrame = CGRectMake(124.0f, 430.0f, 72.0f, 110.0f);
    }
    
    
    self.menuButtonView.tag = kPSHMenuViewControllerMenuButtonViewTag;
    self.menuButtonView.backgroundColor = [UIColor grayColor];
    self.menuButtonView.clipsToBounds = YES;
    self.menuButtonView.autoresizesSubviews = YES;
    [self.menuButtonView.layer setCornerRadius:40.0f];
    [self.menuButtonView.layer setMasksToBounds:YES];
    

    FetchProfileSuccess fetchProfileSuccess =^(NSString * graphID, NSString * avartarImageURL, NSError * error){
        self.ownGraphID = graphID;
        
        __block UIImageView * tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty_profile"]];
        tempImageView.contentMode = UIViewContentModeScaleToFill;
        tempImageView.frame = CGRectMake(12.0f, 12.0f, 65.0f, 65.0f);
        tempImageView.clipsToBounds = NO;
        [tempImageView.layer setCornerRadius:30.0f];
        [tempImageView.layer setMasksToBounds:YES];
        [self.menuButtonView insertSubview:tempImageView belowSubview:self.menuButtonImageView];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImageView * profileImageView = [[UIImageView alloc] initWithImage:profileImage];
                profileImageView.contentMode = UIViewContentModeScaleAspectFill;
                profileImageView.tag = kPSHMenuViewControllerMenuButtonProfileImageViewTag;
                profileImageView.frame = CGRectMake(-10.0f, -10.0f, 100.0f, 100.0f);
                [self.menuButtonView insertSubview:profileImageView belowSubview:self.menuButtonImageView];
                
                [tempImageView removeFromSuperview];
                
            });
        });
    };
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchOwnProfile:fetchProfileSuccess];
    
    self.menuTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    self.menuTapGestureRecognizer.delegate = self;
    [self.menuTapGestureRecognizer addTarget:self action:@selector(menuButtonTapped:)];
    [self.menuButtonView addGestureRecognizer:self.menuTapGestureRecognizer];
    
    // if simply tapped on menu button, don't fire off the other gesture recognizer
    [self.menuGestureRecognizer requireGestureRecognizerToFail:self.menuTapGestureRecognizer];
    
    
}

- (void) initMessengerButton {
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowMessenger)];
    [self.messengerButtonView addGestureRecognizer:tapRecognizer];
    
}

- (void) initAppLauncherButton {
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowLauncher)];
    [self.launcherButtonView addGestureRecognizer:tapRecognizer];
    
}

- (void) initAppLauncher {
    self.launcherMenuView.hidden = YES;
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [swipeGestureRecognizer addTarget:self action:@selector(appLauncherSwipedDown:)];
    [self.launcherMenuView addGestureRecognizer:swipeGestureRecognizer];
    
}

- (void) initNotificationsButton {
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowNotifications)];
    [self.notificationsButtonView addGestureRecognizer:tapRecognizer];
}



- (void) menuGestureRecognizerAction:(PSHMenuGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        // began moving
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged){
        
        CGRect launcherButtonImageViewFrame = [self.view convertRect:self.launcherButtonImageView.frame fromView:self.launcherButtonImageView.superview];
        
        CGRect messengerButtonImageViewFrame = [self.view convertRect:self.messengerButtonImageView.frame fromView:self.messengerButtonImageView.superview];
        
        CGRect notificationsButtonImageViewFrame = [self.view convertRect:self.notificationsButtonImageView.frame fromView:self.notificationsButtonImageView.superview];
        
        
        
        CGRect menuButtonViewFrame = [self.view convertRect:self.menuButtonView.frame fromView:self.menuButtonView.superview];
        
        if (self.menuExpanded){
            
            BOOL actionsTriggered = YES;
            if (CGRectContainsRect(menuButtonViewFrame, launcherButtonImageViewFrame)){
                
                // intersects launcher
                [self playOpenMenuItemSound];
                [self animateShowLauncher];

            } else if (CGRectContainsRect(menuButtonViewFrame, messengerButtonImageViewFrame)){
                
                // intersects messenger
                [self playOpenMenuItemSound];
                [self animateShowMessenger];
                
            } else if (CGRectContainsRect(menuButtonViewFrame, notificationsButtonImageViewFrame)){
                
                // intersects notification
                [self playOpenMenuItemSound];
                [self animateShowNotifications];
                
            }else{
                actionsTriggered = NO;
            }
            
            if (actionsTriggered){
                [self animateHideMenuButtons];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
        }
        
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        DDLogVerbose(@"UIGestureRecognizerStateEnded");
        [self animateHideMenuButtons];
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed){
        DDLogVerbose(@"UIGestureRecognizerStateFailed");
        [self animateHideMenuButtons];
    }
}

- (void)menuButtonTapped:(UITapGestureRecognizer*)longRecognizer {
    if (self.menuExpanded){
        [self animateHideMenuButtons];
    }else{
        [self animateExpandMenuButtons];
    }

}

- (void) animateShowLauncher {
    
    
//    PSHFacebookXMPPService * xmppService = [PSHFacebookXMPPService sharedService];
//    NSLog(@"xmppService: %@", xmppService);
    
    [self.view bringSubviewToFront:self.launcherMenuView];
    
    CGRect origLauncherMenuRect = self.launcherMenuView.frame;
    origLauncherMenuRect.origin.y = 0.0f;
    
    if (self.launcherMenuView.frame.origin.y == 0.0f){
        // set it down to bring it up
        CGRect destLauncherMenuRect = self.launcherMenuView.frame;
        destLauncherMenuRect.origin.y = self.launcherMenuView.frame.size.height;
        self.launcherMenuView.frame = destLauncherMenuRect;
    }
    self.launcherMenuView.hidden = NO;
    self.launcherMenuView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.launcherMenuView.frame = origLauncherMenuRect;
        self.launcherMenuView.alpha = .9f;
    } completion:^(BOOL finished) {
        //
    }];
    
}


- (void) animateHideLauncher {
    
    CGRect destLauncherMenuRect = self.launcherMenuView.frame;
    destLauncherMenuRect.origin.y = self.launcherMenuView.frame.size.height;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.launcherMenuView.frame = destLauncherMenuRect;
        self.launcherMenuView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.launcherMenuView.hidden = YES;
    }];
}


- (void) animateShowMessenger {
    DDLogVerbose(@"animateShowMessenger");
    
//    PSHFacebookXMPPService * xmppService = [PSHFacebookXMPPService sharedService];
//    NSLog(@"xmppService: %@", xmppService);
//    NSURL *url = [NSURL URLWithString:@"fb-messenger://compose"];
//    [[UIApplication sharedApplication] openURL:url];
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:messagesButtonTapped:)]){
        [self.delegate menuViewController:self messagesButtonTapped:YES];
    }
}


- (void) animateShowNotifications {
    DDLogVerbose(@"animateShowNotifications");
    
    [self animateHideLauncher];
    [self animateHideMenuButtons];

    self.menuTapGestureRecognizer.enabled = NO;
    self.menuGestureRecognizer.enabled = NO;
    self.tapGestureRecognizer.enabled = NO;
    
    PSHNotificationsViewController * notificationsVC = [[PSHNotificationsViewController alloc] init];
    notificationsVC.delegate = self;
    [self addChildViewController:notificationsVC];
    [notificationsVC didMoveToParentViewController:self];
    
    self.notificationsView = notificationsVC.view;
    [self.view addSubview:notificationsVC.view];
    notificationsVC.view.alpha = 0.5f;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        notificationsVC.view.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        //
    }];
    
    

}


#pragma mark - expand / collapse menu

- (void) animateExpandMenuButtons {
    
    self.launcherButtonView.hidden = NO;
    self.notificationsButtonView.hidden = NO;
    self.messengerButtonView.hidden = NO;
    self.launcherButtonLabel.hidden = NO;
    self.notificationsButtonLabel.hidden = NO;
    self.messengerButtonLabel.hidden = NO;
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = self.expandedMessengerButtonFrame;
        self.launcherButtonView.frame = self.expandedLauncherButtonFrame;
        self.notificationsButtonView.frame = self.expandedNotificationsButtonFrame;
        
        self.launcherButtonView.alpha = 1.0f;
        self.notificationsButtonView.alpha = 1.0f;
        self.messengerButtonView.alpha = 1.0f;
        self.launcherButtonLabel.alpha = 1.0f;
        self.notificationsButtonLabel.alpha = 1.0f;
        self.messengerButtonLabel.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        self.menuExpanded = YES;
    }];
    
    
}

- (void) animateHideMenuButtons {
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = self.collapsedButtonsFrame;
        self.launcherButtonView.frame = self.collapsedButtonsFrame;
        self.notificationsButtonView.frame = self.collapsedButtonsFrame;
        self.menuButtonView.frame = self.expandedMenuButtonFrame;
        
        self.launcherButtonView.alpha = 0.0f;
        self.notificationsButtonView.alpha = 0.0f;
        self.messengerButtonView.alpha = 0.0f;
        
        self.launcherButtonLabel.alpha = 0.0f;
        self.notificationsButtonLabel.alpha = 0.0f;
        self.messengerButtonLabel.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        self.menuExpanded = NO;
        
        self.launcherButtonView.hidden = YES;
        self.notificationsButtonView.hidden = YES;
        self.messengerButtonView.hidden = YES;
        self.launcherButtonLabel.hidden = YES;
        self.notificationsButtonLabel.hidden = YES;
        self.messengerButtonLabel.hidden = YES;
        
    }];
}



#pragma mark - Gesture Recognizer


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ((([gestureRecognizer isEqual:self.menuLongGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer])) ||
          (([gestureRecognizer isEqual:self.menuTapGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer]))){
        return YES;
    }else{
        return NO;
    }
}

- (void)appLauncherSwipedDown:(UISwipeGestureRecognizer*)swipeGestureRecognizer {
    if(!self.launcherMenuView.hidden){
        [self animateHideLauncher];
    }
}


- (IBAction)launchAppButtonTapped:(UIButton*)sender {
    
    NSURL * url = nil;
    switch (sender.tag) {
            
        case kPSHMenuViewControllerLaunchPhoneButton:
            url = [NSURL URLWithString:@"tel:1-408-111-1111"];
            break;
        case kPSHMenuViewControllerLaunchMailButton:
            url = [NSURL URLWithString:@"mailto:"];
            break;
        case kPSHMenuViewControllerLaunchMapsButton:
            url = [NSURL URLWithString:@"maps:"];
            break;
        case kPSHMenuViewControllerLaunchBrowserButton:
            url = [NSURL URLWithString:@"http://facebook.com"];
            break;
        case kPSHMenuViewControllerLaunchMessengerButton:
            url = [NSURL URLWithString:@"sms:"];
            break;
        case kPSHMenuViewControllerLaunchYoutubeButton:
            url = [NSURL URLWithString:@"http://youtube.com"];
            break;
        case kPSHMenuViewControllerLaunchMusicButton:
            url = [NSURL URLWithString:@"music:"];
            break;
        case kPSHMenuViewControllerLaunchInstagramButton:
            url = [NSURL URLWithString:@"instagram://app"];
            break;
        case kPSHMenuViewControllerLaunchTwitterButton:
            url = [NSURL URLWithString:@"twitter://"];
            break;
        default:
            break;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
    
    
//    void (*openApp)(CFStringRef, Boolean);
//    void *hndl = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices");
//    openApp = dlsym(hndl, "SBSLaunchApplicationWithIdentifier");
//    
//    switch (sender.tag) {
//        case kPSHMenuViewControllerLaunchBrowserButton:
//            openApp(CFSTR("com.apple.mobilesafari"), FALSE);
//            break;
//        case kPSHMenuViewControllerLaunchCameraButton:
//            openApp(CFSTR("com.apple.camera"), FALSE);
//            break;
//        case kPSHMenuViewControllerLaunchPhotosButton:
//            openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
//            break;
//            
//        default:
//            break;
//    }
    
    
//    openApp(CFSTR("com.apple.Preferences"), FALSE);
//    openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
}

- (void) viewSwiped:(UISwipeGestureRecognizer*) swipeGestureRecognizer {
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        if ([self.delegate respondsToSelector:@selector(menuViewController:viewSwipedToLeft:)]){
            [self.delegate menuViewController:self viewSwipedToLeft:YES];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(menuViewController:viewSwipedToRight:)]){
            [self.delegate menuViewController:self viewSwipedToRight:YES];
        }
    }
}

- (void) viewTapped:(UITapGestureRecognizer*) tapGestureRecognizer {
    if (self.launcherMenuView.hidden){
        if ([self.delegate respondsToSelector:@selector(menuViewController:menuViewTapped:)]){
            [self.delegate menuViewController:self menuViewTapped:YES];
        }
    }
}

- (IBAction)statusUpdateButtonTapped:(id)sender {
    
//    NSString * urlString = [NSString stringWithFormat:@"fb://publish/profile/%@?text=awesome!", self.ownGraphID];
//    
//    NSURL * url = [NSURL URLWithString:urlString];
//    if ([[UIApplication sharedApplication] canOpenURL:url]){
//        [[UIApplication sharedApplication] openURL:url];
//    }

    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString * initalTextString = @"Home is awesome.";
    [composeViewController setInitialText:initalTextString];
    [self presentViewController:composeViewController animated:YES completion:^{
        // 
    }];
    
}

- (IBAction)photosButtonTapped:(id)sender {
    NSURL * url = [NSURL URLWithString:@"fb6628568379snap://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (IBAction)checkinButtonTapped:(id)sender {
    NSURL * url = [NSURL URLWithString:@"fb://place/create"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (IBAction)reloadButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewController:reloadButtonTapped:)]){
        [self.delegate menuViewController:self reloadButtonTapped:YES];
    }
}

#pragma mark - PSHNotificationsViewControllerDelegate methods

- (void) notificationsViewController:(PSHNotificationsViewController*)vc shouldDismissView:(BOOL)dismiss{
    
    [self.notificationsView removeFromSuperview];
    self.menuTapGestureRecognizer.enabled = YES;
    self.menuGestureRecognizer.enabled = YES;
    self.tapGestureRecognizer.enabled = YES;
}


@end
