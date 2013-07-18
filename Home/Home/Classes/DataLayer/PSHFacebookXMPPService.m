//
//  PSHFacebookXMPPService.m
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHFacebookXMPPService.h"
#import "PSHLogger.h"
#import "PSHFacebookDataService.h"
//#import "XMPP.h"
#import <Accounts/Accounts.h>

// the code in here references a lot of the work from
// https://github.com/KanybekMomukeyev/FacebookChat


@interface PSHFacebookXMPPService()

//@property (nonatomic, strong) XMPPStream * xmppStream;
//@property (nonatomic, strong) ACAccount * facebookAccount;

@end


@implementation PSHFacebookXMPPService

+ (PSHFacebookXMPPService*) sharedService {
    static PSHFacebookXMPPService * singleton = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
	return singleton;
}

- (id)init {
    self = [super init];
    if (self){
//        self.xmppStream = [[XMPPStream alloc] initWithFacebookAppId:kPSHFacebookAppID];
//        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//        
//        self.facebookAccount = [[PSHFacebookDataService sharedService] facebookAccount];
//        NSAssert(self.facebookAccount!=nil, @"Need authenticated Faceboook ACAcount object to proceed.");
//        if (self.facebookAccount){
//            NSError *error = nil;
//            [self.xmppStream connect:&error];
//        }
        
    }
    return self;
}


/*

#pragma mark XMPPStream Delegate
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    if (![self.xmppStream isSecure])
    {
        NSError *error = nil;
        BOOL result = [self.xmppStream secureConnection:&error];
        
        if (result == NO)
        {
            DDLogError(@"Error in xmpp STARTTLS: %@", error);
            NSLog(@"XMPP STARTTLS failed");
        }
    }
    else
    {
        // extract oauth access token - http://stackoverflow.com/questions/13930371/get-facebook-access-token-from-social-frameworkios6
        ACAccountCredential *fbCredential = [self.facebookAccount credential];
        NSString * accessToken = [fbCredential oauthToken];
        NSLog(@"Facebook Access Token: %@", accessToken);

        NSError *error = nil;
        BOOL result = [self.xmppStream authenticateWithFacebookAccessToken:accessToken error:&error];
        if (result == NO){
            DDLogError(@"Error in xmpp auth: %@", error);
            NSLog(@"XMPP authentication failed");
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    BOOL allowSelfSignedCertificates = YES;
    BOOL allowSSLHostNameMismatch = YES;
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		NSString *expectedCertName = [sender hostName];
		if (expectedCertName == nil)
		{
			expectedCertName = [[sender myJID] domain];
		}
        
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"XMPP STARTTLS...");
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP authenticated");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP authentication failed");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPP disconnected");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    [self processReceivedXMPPMessage:message];

}

#pragma mark - non XMPP logic

- (void) processReceivedXMPPMessage:(XMPPMessage *) xmppMessage {
    
    if([xmppMessage isChatMessageWithBody]) {
        // sample - -572733568@chat.facebook.com
        NSString * fromAddressString = [xmppMessage.fromStr substringWithRange:NSMakeRange(1, [xmppMessage.fromStr length]-1)];
        NSString * fromFacebookID = [NSString stringWithFormat:@"%@",[[fromAddressString componentsSeparatedByString:@"@"] objectAtIndex:0]];
        
        NSString * toAddressString = [xmppMessage.toStr substringWithRange:NSMakeRange(1, [xmppMessage.toStr length]-1)];
        NSString * toFacebookID = [NSString stringWithFormat:@"%@",[[toAddressString componentsSeparatedByString:@"@"] objectAtIndex:0]];
        
        NSString * message = [[xmppMessage elementForName:@"body"] stringValue];
        
        PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
        [dataService addChatMessage:fromFacebookID toID:toFacebookID message:message success:^{
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookMessageReceived" object:fromFacebookID];
            });
            
        }];
        
    }
    
    
}
*/



@end
