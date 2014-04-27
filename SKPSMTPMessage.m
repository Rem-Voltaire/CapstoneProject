//
//  SKPSMTPMessage.m
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Revised by Matteo Manni on 22/12/2011 (bug fixes and ARC compatibility)
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

#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "NSStream+SKPSMTPExtensions.h"
#import "HSK_CFUtilities.h"

NSString *kSKPSMTPPartContentDispositionKey = @"kSKPSMTPPartContentDispositionKey";
NSString *kSKPSMTPPartContentTypeKey = @"kSKPSMTPPartContentTypeKey";
NSString *kSKPSMTPPartMessageKey = @"kSKPSMTPPartMessageKey";
NSString *kSKPSMTPPartContentTransferEncodingKey = @"kSKPSMTPPartContentTransferEncodingKey";

#define SHORT_LIVENESS_TIMEOUT 20.0
#define LONG_LIVENESS_TIMEOUT 60.0


@implementation SKPSMTPMessage

@synthesize login;
@synthesize pass;
@synthesize relayHost;
@synthesize relayPorts;
@synthesize subject;
@synthesize fromEmail;
@synthesize toEmail;
@synthesize parts;
@synthesize requiresAuth;
@synthesize inputString;
@synthesize wantsSecure;
@synthesize delegate;
@synthesize connectTimer;
@synthesize connectTimeout;
@synthesize shortWatchdogTimer; 
@synthesize longWatchdogTimer; 
@synthesize validateSSLChain;
@synthesize ccEmail;
@synthesize bccEmail;
@synthesize inputStream;
@synthesize outputStream;
@synthesize sendState;
@synthesize isSecure;
@synthesize serverAuthCRAMMD5;
@synthesize serverAuthPLAIN;
@synthesize serverAuthDIGESTMD5;
@synthesize serverAuthLOGIN;
@synthesize server8bitMessages;




- (id)init
{
  
    static NSArray *defaultPorts = nil;
    
    if (!defaultPorts)
    {
        defaultPorts = [[NSArray alloc] initWithObjects:[NSNumber numberWithShort:25], [NSNumber numberWithShort:465], [NSNumber numberWithShort:587], nil];
    }
    
    if (self = [super init])
    {
        // Setup the default ports
        self.relayPorts = defaultPorts;
        
        // setup a default timeout (8 seconds)
        connectTimeout = 16.0; 
        
        // by default, validate the SSL chain
        validateSSLChain = YES;
    }
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone
{
    SKPSMTPMessage *smtpMessageCopy = [[[self class] allocWithZone:zone] init];
    smtpMessageCopy.delegate = self.delegate;
    smtpMessageCopy.fromEmail = self.fromEmail;
    smtpMessageCopy.login = self.login;
    smtpMessageCopy.parts = [self.parts copy];
    smtpMessageCopy.pass = self.pass;
    smtpMessageCopy.relayHost = self.relayHost;
    smtpMessageCopy.requiresAuth = self.requiresAuth;
    smtpMessageCopy.subject = self.subject;
    smtpMessageCopy.toEmail = self.toEmail;
    smtpMessageCopy.wantsSecure = self.wantsSecure;
    smtpMessageCopy.validateSSLChain = self.validateSSLChain;
    smtpMessageCopy.ccEmail = self.ccEmail;
    smtpMessageCopy.bccEmail = self.bccEmail;
    
    return smtpMessageCopy;
}

- (void)startShortWatchdog
{
    NSLog(@"*** starting short watchdog ***");
    self.shortWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:SHORT_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)startLongWatchdog
{
    NSLog(@"*** starting long watchdog ***");
    self.longWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:LONG_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)stopWatchdog
{
    NSLog(@"*** stopping watchdog ***");
    NSLog(@"ShortWatchdog = %@ is Valid? %d",self.shortWatchdogTimer,[self.shortWatchdogTimer isValid]);
    NSLog(@"LongWatchdog = %@ is Valid? %d",self.longWatchdogTimer,[self.longWatchdogTimer isValid]);
    
   
        [self.shortWatchdogTimer invalidate];
        shortWatchdogTimer = nil;
    
  
        [self.longWatchdogTimer invalidate];
        longWatchdogTimer = nil;
}

- (BOOL)send
{
    NSAssert(sendState == kSKPSMTPIdle, @"Message has already been sent!");
    
    if (requiresAuth)
    {
        NSAssert(login, @"auth requires login");
        NSAssert(pass, @"auth requires pass");
    }
    
    NSAssert(relayHost, @"send requires relayHost");
    NSAssert(subject, @"send requires subject");
    NSAssert(fromEmail, @"send requires fromEmail");
    NSAssert(toEmail, @"send requires toEmail");
    NSAssert(parts, @"send requires parts");
    
    if (![relayPorts count])
    {
        [delegate messageFailed:self 
                          error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                    code:kSKPSMTPErrorConnectionFailed 
                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                          NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
        
        return NO;
    }
    
    // Grab the next relay port
    short relayPort = [[relayPorts objectAtIndex:0] shortValue];
    
    // Pop this off the head of the queue.
    self.relayPorts = ([relayPorts count] > 1) ? [relayPorts subarrayWithRange:NSMakeRange(1, [relayPorts count] - 1)] : [NSArray array];
    
    NSLog(@"C: Attempting to connect to server at: %@:%d", relayHost, relayPort);
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:connectTimeout
                                                         target:self
                                                       selector:@selector(connectionConnectedCheck:)
                                                       userInfo:nil 
                                                        repeats:NO]; 
    
    NSInputStream  *iStream;
    NSOutputStream *oStream;
    [NSStream getStreamsToHostNamed:relayHost port:relayPort inputStream:&iStream outputStream:&oStream];
    
    if ((iStream != nil) && (oStream != nil))
    {
        sendState = kSKPSMTPConnecting;
        isSecure = NO;

        inputStream = iStream;
        outputStream = oStream;
        
        iStream = nil;
        oStream = nil;
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        
        NSLog(@"$$$$$$$$$$$$$$ Scheduling for ROONLOOP %@ $$$$$$$$$$$$$$$$$$$$$$$$$\n",self);
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
        [inputStream open];
        [outputStream open];
        
        self.inputString = [NSMutableString string];
        
        
        
        return YES;
    }
    else
    {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        
        [delegate messageFailed:self 
                          error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                    code:kSKPSMTPErrorConnectionFailed 
                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                          NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
        
        return NO;
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode 
{
    switch(eventCode) 
    {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            memset(buf, 0, sizeof(uint8_t) * 1024);
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) 
            {
                NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                [inputString appendString:tmpStr];
                
                [self parseBuffer];
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            NSLog(@"HandleEvent: calling stopWatchDog");
            if(stream)
            {
                [self stopWatchdog];
                [stream close];
                NSLog(@"$$$$$$$$$$$$$$ Removing for ROONLOOP (handleEvent)  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
                stream = nil; // stream is ivar, so reinit it
            }
            if (sendState != kSKPSMTPMessageSent)
            {
                [self.delegate messageFailed:self 
                                  error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                            code:kSKPSMTPErrorConnectionInterrupted 
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"The connection to the server was interrupted.", @"server connection interrupted error description"),NSLocalizedDescriptionKey,
                                                                  NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];

            }
            
            break;
        }
    }
}
            

- (NSString *)formatAnAddress:(NSString *)address {
	NSString		*formattedAddress;
	NSCharacterSet	*whitespaceCharSet = [NSCharacterSet whitespaceCharacterSet];

	if (([address rangeOfString:@"<"].location == NSNotFound) && ([address rangeOfString:@">"].location == NSNotFound)) {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:<%@>\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];									
	}
	else {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:%@\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];																		
	}
	
	return(formattedAddress);
}

- (NSString *)formatAddresses:(NSString *)addresses {
    NSCharacterSet    *splitSet = [NSCharacterSet characterSetWithCharactersInString:@";,"];
    NSMutableString   *multipleRcpt = [NSMutableString string];
    
    if ((addresses != nil) && (![addresses isEqualToString:@""])) {
        if( [addresses rangeOfString:@";"].location != NSNotFound || [addresses rangeOfString:@","].location != NSNotFound ) {
            NSArray *addressParts = [addresses componentsSeparatedByCharactersInSet:splitSet];
            
            for( NSString *address in addressParts ) {
                [multipleRcpt appendString:[self formatAnAddress:address]];
            }
        }
        else {
            [multipleRcpt appendString:[self formatAnAddress:addresses]];
        }       
    }
    
    return(multipleRcpt);
}

            
- (void)parseBuffer
{
    // Pull out the next line
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
    NSString *tmpLine = nil;
    
    NSError *error = nil;
    BOOL encounteredError = NO;
    BOOL messageSent = NO;
    
    while (![scanner isAtEnd])
    {
        BOOL foundLine = [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                                 intoString:&tmpLine];
        if (foundLine)
        {

            [self stopWatchdog];
            NSLog(@"S: %@ .SendState=%d", tmpLine, sendState);
            switch (sendState)
            {
                case kSKPSMTPConnecting:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPConnecting  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPConnecting : 250  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        sendState = kSKPSMTPWaitingEHLOReply;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        NSLog(@"C: %@", ehlo);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingEHLOReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingEHLOReply  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    
                    // Test auth login options
                    if ([tmpLine hasPrefix:@"250-AUTH"])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitinhEHLOReply : 250-Auth  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        NSRange testRange;
                        testRange = [tmpLine rangeOfString:@"CRAM-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthCRAMMD5 = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"PLAIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthPLAIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"LOGIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthLOGIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"DIGEST-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthDIGESTMD5 = YES;
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250-8BITMIME"])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitinh EHLOReply : 250-8BITMIME  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        server8bitMessages = YES;
                    }
                    else if ([tmpLine hasPrefix:@"250-STARTTLS"] && !isSecure && wantsSecure)
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitinh EHLOReply : 250-STARTTLS  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        // if we're not already using TLS, start it up
                        sendState = kSKPSMTPWaitingTLSReply;
                        
                        NSString *startTLS = @"STARTTLS\r\n";
                        NSLog(@"C: %@", startTLS);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[startTLS UTF8String], [startTLS lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitinh EHLOReply : 250  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        if (self.requiresAuth)
                        {
                            // Start up auth
                            if (serverAuthPLAIN)
                            {
                                sendState = kSKPSMTPWaitingAuthSuccess;
                                NSString *loginString = [NSString stringWithFormat:@"\000%@\000%@", login, pass];
                                NSString *authString = [NSString stringWithFormat:@"AUTH PLAIN %@\r\n", [[loginString dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                                NSLog(@"C: %@", authString);
                                if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else if (serverAuthLOGIN)
                            {
                                sendState = kSKPSMTPWaitingLOGINUsernameReply;
                                NSString *authString = @"AUTH LOGIN\r\n";
                                NSLog(@"C: %@", authString);
                                if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else
                            {
                                error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                            code:kSKPSMTPErrorUnsupportedLogin
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unsupported login mechanism.", @"server unsupported login fail error description"),NSLocalizedDescriptionKey,
                                                                  NSLocalizedString(@"Your server's security setup is not supported, please contact your system administrator or use a supported email account like MobileMe.", @"server security fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                                         
                                encounteredError = YES;
                            }
                                
                        }
                        else
                        {
                            NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitinh EHLOReply : send form  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                            // Start up send from
                            sendState = kSKPSMTPWaitingFromReply;
                            
                            NSString *mailFrom = [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", fromEmail];
                            NSLog(@"C: %@", mailFrom);
                            if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom UTF8String], [mailFrom lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                            {
                                error =  [outputStream streamError];
                                encounteredError = YES;
                            }
                            else
                            {
                                [self startShortWatchdog];
                            }
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingTLSReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingTLSeEply  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingTLSeEply : 220  $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        // Attempt to use TLSv1
                        CFMutableDictionaryRef sslOptions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                        
                        CFDictionarySetValue(sslOptions, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelTLSv1);
                        
                        if (!self.validateSSLChain)
                        {
                            // Don't validate SSL certs. This is terrible, please complain loudly to your BOFH.
                            NSLog(@"WARNING: Will not validate SSL chain!!!");
                            
                            CFDictionarySetValue(sslOptions, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
                        }
                        
                        NSLog(@"Beginning TLSv1...");
                        
                        CFReadStreamSetProperty((__bridge_retained CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, sslOptions);
                        CFWriteStreamSetProperty((__bridge_retained CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, sslOptions);
                        
                        CFRelease(sslOptions);
                        
                        // restart the connection
                        sendState = kSKPSMTPWaitingEHLOReply;
                        isSecure = YES;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        NSLog(@"C: %@", ehlo);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                        
                        /*
                        else
                        {
                            error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                        code:kSKPSMTPErrorTLSFail
                                                    userInfo:[NSDictionary dictionaryWithObject:@"Unable to start TLS" 
                                                                                         forKey:NSLocalizedDescriptionKey]];
                            encounteredError = YES;
                        }
                        */
                    }
                }
                
                case kSKPSMTPWaitingLOGINUsernameReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingLoGINUsernamereply $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"334 VXNlcm5hbWU6"])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingLoGINUsernamereply : 334 VXNlcm5hbWU6 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        sendState = kSKPSMTPWaitingLOGINPasswordReply;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[login dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        NSLog(@"C: %@", authString);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingLOGINPasswordReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingLoGINUPassworgReply $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    
                    if ([tmpLine hasPrefix:@"334 UGFzc3dvcmQ6"])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingLoGINUPassworgReply : 334 UGFzc3dvcmQ6 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        sendState = kSKPSMTPWaitingAuthSuccess;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[pass dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        NSLog(@"C: %@", authString);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                
                case kSKPSMTPWaitingAuthSuccess:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingAuthSuccess $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"235 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingAuthSuccess : 235 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        sendState = kSKPSMTPWaitingFromReply;
                        
                        NSString *mailFrom = server8bitMessages ? [NSString stringWithFormat:@"MAIL FROM:<%@> BODY=8BITMIME\r\n", fromEmail] : [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", fromEmail];
                        NSLog(@"C: %@", mailFrom);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom cStringUsingEncoding:NSASCIIStringEncoding], [mailFrom lengthOfBytesUsingEncoding:NSASCIIStringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"535 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingAuthSuccess : 535 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidUserPass 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Invalid username or password.", @"server login fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Go to Email Preferences in the application and re-enter your username and password.", @"server login error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                
                case kSKPSMTPWaitingFromReply:
                {
					// toc 2009-02-18 begin changes per mdesaro issue 18 - http://code.google.com/p/skpsmtpmessage/issues/detail?id=18
					// toc 2009-02-18 begin changes to support cc & bcc
					
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingFromReply $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"250 "]) {
                        
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingFromReply : 250 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        //sendState = kSKPSMTPWaitingToReply;
                        
						//NSMutableString	*multipleRcptTo = [NSMutableString string];
						if (!multipleRcptTo) {
                            NSMutableString *multipleRcptToString = [NSMutableString string];
                            [multipleRcptToString appendString:[self formatAddresses:toEmail]];
                            [multipleRcptToString appendString:[self formatAddresses:ccEmail]];
                            [multipleRcptToString appendString:[self formatAddresses:bccEmail]];
                            
                            multipleRcptTo = [[multipleRcptToString componentsSeparatedByString:@"\r\n"] mutableCopy];
                            [multipleRcptTo removeLastObject];
                        }
                        if ([multipleRcptTo count] > 0) {
                            NSString *rcptTo = [NSString stringWithFormat:@"%@\r\n", [multipleRcptTo objectAtIndex:0]];
                            [multipleRcptTo removeObjectAtIndex:0];
                            
                            //DEBUGLOG(@"C: %@", rcptTo);
                            if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[rcptTo UTF8String], [rcptTo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                            {
                                error =  [outputStream streamError];
                                encounteredError = YES;
                            }
                            else
                            {
                                [self startShortWatchdog];
                            }
                        } 
                        if ([multipleRcptTo count] == 0) {
                            
                            sendState = kSKPSMTPWaitingToReply;
                            
                            
                            
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingToReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingToReply $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingToReply : 250 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        sendState = kSKPSMTPWaitingForEnterMail;
                        
                        NSString *dataString = @"DATA\r\n";
                        //NSLog(@"C: %@", dataString);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[dataString UTF8String], [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"530 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingToReply : 530 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorNoRelay 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Relay rejected.", @"server relay fail error description"),NSLocalizedDescriptionKey,
                                                        NSLocalizedString(@"Your server probably requires a username and password.", @"server relay fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingToReply : 550 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidMessage 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"To address rejected.", @"server to address fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Please re-enter the To: address.", @"server to address fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                case kSKPSMTPWaitingForEnterMail:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingForEnterMail $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"354 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingForEnterMail : 354 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        sendState = kSKPSMTPWaitingSendSuccess;
                        
                        if (![self sendParts])
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingSendSuccess:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingSendSuccess $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingSendSuccess : 250 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        sendState = kSKPSMTPWaitingQuitReply;
                        
                        NSString *quitString = @"QUIT\r\n";
                        NSLog(@"C: %@", quitString);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[quitString UTF8String], [quitString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingSendSuccess : IF $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingSendSuccess : else <Crashing Here> $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingSendSuccess : 550 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidMessage 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Failed to logout.", @"server logout fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                }
                case kSKPSMTPWaitingQuitReply:
                {
                    NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingQuitReply $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                    if ([tmpLine hasPrefix:@"221 "])
                    {
                        NSLog(@"$$$$$$$$$$$$$$ kSKPSMTPWaitingQuitReply : 221 $$$$$$$$$$$$$$$$$$$$$$$$$\n");
                        sendState = kSKPSMTPMessageSent;
                        
                        messageSent = YES;
                    }
                }
            }
            
        }
        else
        {
            break;
        }
    }
    NSLog(@"tmpLine  is %@", tmpLine);
    
    if([tmpLine hasPrefix:@"501 "])
    {
        NSLog(@"Bastard detected");
        [self cleanUpStreams];
        [delegate messageFailed:self error:error];
        return;
    }
    
    NSLog(@"inputString: %@ = scanLocation",inputString);
    inputString = [[inputString substringFromIndex:[scanner scanLocation]] mutableCopy];
    
    
    if (messageSent)
    {

        [self cleanUpStreams];
        [delegate messageSent:self];
    }
    else if (encounteredError)
    {
        [self cleanUpStreams];
        [delegate messageFailed:self error:error];
    }
}

- (BOOL)sendParts
{
    NSMutableString *message = [[NSMutableString alloc] init];
    static NSString *separatorString = @"--SKPSMTPMessage--Separator--Delimiter\r\n";
    
	CFUUIDRef	uuidRef   = CFUUIDCreate(kCFAllocatorDefault);
	NSString	*uuid     = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	CFRelease(uuidRef);
    
    NSDate *now = [[NSDate alloc] init];
	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	
	[message appendFormat:@"Date: %@\r\n", [dateFormatter stringFromDate:now]];
	[message appendFormat:@"Message-id: <%@@%@>\r\n", [(NSString *)uuid stringByReplacingOccurrencesOfString:@"-" withString:@""], self.relayHost];
    
    [message appendFormat:@"From:%@\r\n", fromEmail];
	
    
	if ((self.toEmail != nil) && (![self.toEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"To:%@\r\n", self.toEmail];		
	}

	if ((self.ccEmail != nil) && (![self.ccEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"Cc:%@\r\n", self.ccEmail];		
	}
    
    [message appendString:@"Content-Type: multipart/mixed; boundary=SKPSMTPMessage--Separator--Delimiter\r\n"];
    [message appendString:@"Mime-Version: 1.0 (SKPSMTPMessage 1.0)\r\n"];
    [message appendFormat:@"Subject:%@\r\n\r\n",subject];
    [message appendString:separatorString];
    
    NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //NSLog(@"C: %s", [messageData bytes], [messageData length]);
    if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[messageData bytes], [messageData length]) < 0)
    {
        return NO;
    }
    
    message = [[NSMutableString alloc] init];
    
    for (NSDictionary *part in parts)
    {
        if ([part objectForKey:kSKPSMTPPartContentDispositionKey])
        {
            [message appendFormat:@"Content-Disposition: %@\r\n", [part objectForKey:kSKPSMTPPartContentDispositionKey]];
        }
        [message appendFormat:@"Content-Type: %@\r\n", [part objectForKey:kSKPSMTPPartContentTypeKey]];
        [message appendFormat:@"Content-Transfer-Encoding: %@\r\n\r\n", [part objectForKey:kSKPSMTPPartContentTransferEncodingKey]];
        [message appendString:[part objectForKey:kSKPSMTPPartMessageKey]];
        [message appendString:@"\r\n"];
        [message appendString:separatorString];
    }
    
    [message appendString:@"\r\n.\r\n"];
    
    //NSLog(@"C: %@", message);
    if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[message UTF8String], [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
    {
        return NO;
    }
    [self startLongWatchdog];
    return YES;
}

- (void)connectionConnectedCheck:(NSTimer *)aTimer
{
     NSLog(@"$$$$$$$$$$$$$$ connectionConnectedCheck: timeout $$$$$$$$$$$$$$$$$$$$$$$$$\n");
    
    if (sendState == kSKPSMTPConnecting)
    {
        NSLog(@"$$$$$$$$$$$$$$ connectionConnectedCheck: kSMTPConnecting $$$$$$$$$$$$$$$$$$$$$$$$$\n");

            [inputStream close];
            NSLog(@"$$$$$$$$$$$$$$ inputStream REMOVE FROM LOOP (connectionConnectedCheck:) $$$$$$$$$$$$$$$$$$$$$$$$$\n");
            [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];

            inputStream = nil;
        
            [outputStream close];
            NSLog(@"$$$$$$$$$$$$$$ outputStream REMOVE FROM LOOP (connectionConnectedCheck:) $$$$$$$$$$$$$$$$$$$$$$$$$\n");
            [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
            outputStream = nil;
        
        // Try the next port - if we don't have another one to try, this will fail
        sendState = kSKPSMTPIdle;
        [self send];
    }
    else
    {
        NSLog(@"$$$$$$$$$$$$$$ connectionConnectedCheck: timer = nil $$$$$$$$$$$$$$$$$$$$$$$$$\n");
        [self cleanUpStreams];
        self.connectTimer = nil;
        
      /*  NSError *timeOutError =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                   code:kSKPSMTPErrorConnectionCheckedTimedOut 
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Failed to send email", @"operation timed out before completion"),NSLocalizedDescriptionKey,
                                         NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];*/
        
       // [delegate messageFailed:self error:timeOutError];
        
    }

}

- (void)connectionWatchdog:(NSTimer *)aTimer
{
    NSLog(@"$$$$$$$$$$$$$$ connectionWatchDog: timeout $$$$$$$$$$$$$$$$$$$$$$$$$\n");
    
    [self cleanUpStreams];
    
    // No hard error if we're wating on a reply
    if (sendState != kSKPSMTPWaitingQuitReply)
    {
        NSError *error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                             code:kSKPSMPTErrorConnectionTimeout 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Timeout sending message.", @"server timeout fail error description"),NSLocalizedDescriptionKey,
                                                   NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
        [delegate messageFailed:self error:error];
    }
    else
    {
        [delegate messageSent:self];
    }
}

- (void)cleanUpStreams
{
    if(inputStream)
    {
        [inputStream close];
        NSLog(@"$$$$$$$$$$$$$$ inputStream REMOVE FROM LOOP (cleanUp Streams:) $$$$$$$$$$$$$$$$$$$$$$$$$\n");
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        inputStream = nil;
    }
    if(outputStream)
    {
        [outputStream close];
        NSLog(@"$$$$$$$$$$$$$$ outputStream REMOVE FROM LOOP (cleanUp Streams:) $$$$$$$$$$$$$$$$$$$$$$$$$\n");
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
        outputStream = nil;
    }
}

- (void)dealloc
{
    [self.connectTimer invalidate];
    [self stopWatchdog];
    
}

@end
