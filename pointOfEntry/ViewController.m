//
//  ViewController.m
//  pointOfEntry
//
//  Created by Cassandra Sandquist on 2014-05-06.
//  Copyright (c) 2014 Cassandra Sandquist. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton* gotToFacebookButton = [[UIButton alloc] init];
    gotToFacebookButton.frame = CGRectMake(44, 44, 300, 30);
    [gotToFacebookButton setTitle:@"Go To Facebook"
                         forState:UIControlStateNormal];
    [gotToFacebookButton setBackgroundColor:[UIColor blueColor]];
    [gotToFacebookButton addTarget:self
                            action:@selector(goToFacebookPressed)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gotToFacebookButton];
}
- (void)goToFacebookPressed
{
    FBLinkShareParams* params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];

    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        //present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall* call, NSDictionary* results, NSError* error) {
                                          if(error) {
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        //present feed dialog
        // Put together the dialog parameters
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                               @"Sharing Tutorial", @"name",
                                                               @"Build great social apps and get more installs.", @"caption",
                                                               @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                                               @"https://developers.facebook.com/docs/ios/share/", @"link",
                                                               @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                                               nil];
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL* resultURL, NSError* error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString*)query
{
    NSArray* pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    for (NSString* pair in pairs) {
        NSArray* kv = [pair componentsSeparatedByString:@"="];
        NSString* val =
            [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
