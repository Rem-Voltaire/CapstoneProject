//
//  ConsultationViewController.m
//  Law Firm App
//
//  Created by Owner on 4/10/14.
//
//

#import "ConsultationViewController.h"

@interface ConsultationViewController () <UITextViewDelegate>
-(BOOL)checkEmail;
@end

@implementation ConsultationViewController{
    UIAlertView *emailAlert;
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
    [super viewDidLoad];
    [_scroller setScrollEnabled:YES];
    [_scroller setContentSize:CGSizeMake(320, 700)];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return NO;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(BOOL)validateEmail:(NSString *)emailStr {
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(BOOL)checkEmail {
    if(![self validateEmail:[_email text]] || [_email.text length] <= 0)
    {
        emailAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
        [emailAlert show];
        return NO;
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [_email becomeFirstResponder];
    return;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter Comments here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter Comments here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (IBAction)sendConsultationButton:(id)sender {
    
    if(![self checkEmail])
    {
        return;
    }
    
    NSLog(@"Start Sending");
    
    SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
    
    emailMessage.fromEmail = _email.text; //sender email address
    
    emailMessage.toEmail = _email.text;  //receiver email address
    
    emailMessage.relayHost = @"smtp.gmail.com";
    
    emailMessage.bccEmail =@"silverfreezez@hotmail.com";
    
    //emailMessage.bccEmail =@"your bcc address";
    
    emailMessage.requiresAuth = YES;
    
    emailMessage.login = @"wbrelayhost@gmail.com";//sender email address
    
    emailMessage.pass = @"wardandbarnesftw"; //sender email password
    
    emailMessage.subject =@"Auto Accident Consultation";
    
    emailMessage.wantsSecure = YES;
    
    emailMessage.delegate = self; // you must include <SKPSMTPMessageDelegate> to your class
    
    //NSString *messageBody = _MessageTextView.text;
    
    NSString *messageBody = [NSString stringWithFormat:@"Name: %@ %@\nEmail: %@\nContact No: %@\nComment: %@",_firstName.text, _lastName.text,_email.text,_phoneNumber.text,_comments.text];
    
    // Now creating plain text email message
    
    NSDictionary *plainMsg = [NSDictionary
                              
                              dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                              
                              messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
    
    //in addition : Logic for attaching file with email message.
    
    /*
     
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filename" ofType:@"JPG"];
     
     NSData *fileData = [NSData dataWithContentsOfFile:filePath];
     
     NSDictionary *fileMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-
     
     unix-mode=0644;\r\n\tname=\"filename.JPG\"",kSKPSMTPPartContentTypeKey,@"attachment;\r\n\tfilename=\"filename.JPG\"",kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
     
     emailMessage.parts = [NSArray arrayWithObjects:plainMsg,fileMsg,nil]; //including plain msg and attached file msg
     
     */
    
    [emailMessage send];
    
    // sending email- will take little time to send so its better to use indicator with message showing sending...
    
    
    
}


//Now, handling delegate methods :

// On success



-(void)messageSent:(SKPSMTPMessage *)message{
    
    NSLog(@"delegate - message sent");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
    
}



// On Failure

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    
    // open an alert with just an OK button
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
    
}

@end
