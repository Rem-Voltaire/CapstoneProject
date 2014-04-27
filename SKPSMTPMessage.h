//
//  SKPSMTPMessage.h
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Rivisited by Matteo Manni on 22/12/2011 (bug fixes and ARC compatibility)
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

enum 
{
    kSKPSMTPIdle = 0,
    kSKPSMTPConnecting,
    kSKPSMTPWaitingEHLOReply,
    kSKPSMTPWaitingTLSReply,
    kSKPSMTPWaitingLOGINUsernameReply,
    kSKPSMTPWaitingLOGINPasswordReply,
    kSKPSMTPWaitingAuthSuccess,
    kSKPSMTPWaitingFromReply,
    kSKPSMTPWaitingToReply,
    kSKPSMTPWaitingForEnterMail,
    kSKPSMTPWaitingSendSuccess,
    kSKPSMTPWaitingQuitReply,
    kSKPSMTPMessageSent
};
typedef NSUInteger SKPSMTPState;
    
// Message part keys
extern NSString *kSKPSMTPPartContentDispositionKey;
extern NSString *kSKPSMTPPartContentTypeKey;
extern NSString *kSKPSMTPPartMessageKey;
extern NSString *kSKPSMTPPartContentTransferEncodingKey;

// Error message codes
#define kSKPSMPTErrorConnectionTimeout -5
#define kSKPSMTPErrorConnectionFailed -3
#define kSKPSMTPErrorConnectionInterrupted -4
#define kSKPSMTPErrorUnsupportedLogin -2
#define kSKPSMTPErrorTLSFail -1
#define kSKPSMTPErrorInvalidUserPass 535
#define kSKPSMTPErrorInvalidMessage 550
#define kSKPSMTPErrorNoRelay 530
// Added
#define kSKPSMTPErrorInvalidEmail 501
#define kSKPSMTPErrorConnectionCheckedTimedOut 555

@class SKPSMTPMessage;


@protocol SKPSMTPMessageDelegate
@required

-(void)messageSent:(SKPSMTPMessage *)message;
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error;

@end

@interface SKPSMTPMessage : NSObject <NSCopying,NSStreamDelegate>
{
    @public
    NSMutableArray *multipleRcptTo;

}

@property(nonatomic, strong) NSMutableString *inputString;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSTimer *shortWatchdogTimer;
@property (nonatomic, strong) NSTimer *longWatchdogTimer;
@property(nonatomic, strong) NSString *login;
@property(nonatomic, strong) NSString *pass;
@property(nonatomic, strong) NSString *relayHost;

@property(nonatomic, strong) NSArray *relayPorts;

@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *fromEmail;
@property(nonatomic, strong) NSString *toEmail;
@property(nonatomic, strong) NSString *ccEmail;
@property(nonatomic, strong) NSString *bccEmail;
@property(nonatomic, strong) NSArray *parts;
@property(nonatomic, strong) NSTimer *connectTimer;

@property  NSTimeInterval connectTimeout;

@property SKPSMTPState sendState;
@property (nonatomic, assign) BOOL requiresAuth;
@property (nonatomic, assign) BOOL wantsSecure;
@property (nonatomic, assign) BOOL validateSSLChain;
@property (nonatomic,assign)BOOL isSecure;

// Auth support flags
@property (nonatomic,assign) BOOL serverAuthCRAMMD5;
@property (nonatomic,assign) BOOL serverAuthPLAIN;
@property (nonatomic,assign) BOOL serverAuthLOGIN;
@property (nonatomic,assign) BOOL serverAuthDIGESTMD5;

// Content support flags
@property (nonatomic,assign) BOOL server8bitMessages;

@property(nonatomic, unsafe_unretained) id <SKPSMTPMessageDelegate> delegate;

// Methods
- (BOOL)send;
- (void)parseBuffer;
- (BOOL)sendParts;
- (void)cleanUpStreams;
- (void)startShortWatchdog;
- (void)stopWatchdog;
- (NSString *)formatAnAddress:(NSString *)address;
- (NSString *)formatAddresses:(NSString *)addresses;


@end
