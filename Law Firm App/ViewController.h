//
//  ViewController.h
//  Information
//
//  Created by Owner on 4/1/14.
//  Copyright (c) 2014 Owner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


-(IBAction)twitterLink;

-(IBAction)websiteLink;

-(IBAction)facebookLink;

-(IBAction)callPhone;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@end

