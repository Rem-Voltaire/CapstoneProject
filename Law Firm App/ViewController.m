//
//  ViewController.m
//  Information
//
//  Created by Owner on 4/1/14.
//  Copyright (c) 2014 Owner. All rights reserved.
//

#import "ViewController.h"
#define METERS_PER_MILE 1609.344

@interface ViewController ()

@end
//

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)twitterLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/#!/search/realtime/wardandbarnes"]];
}

-(IBAction)websiteLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.wardbarnes.com"]];
}

-(IBAction)facebookLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/pages/Ward-Barnes-PA/400878156626405"]];
}

//add actual phone number here
-(IBAction)callPhone{ //:(id)sender 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://8505721252"]];
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 30.4207778;
    zoomLocation.longitude= -87.2206944;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
}

@end



