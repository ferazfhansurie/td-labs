#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
   
    // Get the existing FlutterViewController
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    // Create a UINavigationController with the existing FlutterViewController as its root
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

  
   
    // Make the navigation bar transparent
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    navController.view.backgroundColor = [UIColor clearColor];
    navController.navigationBar.backgroundColor = [UIColor clearColor];

    // Set the window's root view controller to the UINavigationController
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];

    NSLog(@"Controller in didFinishLaunchingWithOptions: %@", controller);
    NSLog(@"Controller's Navigation Controller in didFinishLaunchingWithOptions: %@", controller.navigationController);

    FlutterMethodChannel* nativeChannel = [FlutterMethodChannel methodChannelWithName:@"com.tedainternational.tdlabs/scan" binaryMessenger:controller.binaryMessenger];

    [nativeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"getDeviceId" isEqualToString:call.method]) {
            [self getDeviceIdWithResult:result];
        } else if ([@"connectDevice" isEqualToString:call.method]) {
            [self connectDeviceWithController:controller call:call result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    return YES;
}

- (void)connectDeviceWithController:(FlutterViewController *)controller call:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = call.arguments;
    NSString *token = args[@"sdkToken"];
    controller.navigationController.navigationBarHidden = YES;
    NSLog(@"Controller in connectDeviceWithController: %@", controller);
    NSLog(@"Controller View: %@", controller.view);
    NSLog(@"Controller's Navigation Controller in connectDeviceWithController: %@", controller.navigationController);

    if (token == nil) {
        result([FlutterError errorWithCode:@"BAD_ARGS" message:@"Missing parameter: token" details:nil]);
        return;
    }

    [QLZConfigure startWithAppKey:@"qlzc8f447a9ff9f96e1" region:@"SG" env:NO];
    [[QLZConfigure sharedInstance] setOrientationType:Qiaolz_Portrait];

      [[QLZConfigure sharedInstance] startDetectWithToken:token viewController:controller complete:^(NSDictionary *resultDic) {
        NSInteger resultCode = [resultDic[@"resultCode"] integerValue];
        NSString *message = resultDic[@"errmsg"] ?: @"Unknown error";
        NSLog(@"Result Code: %ld", (long)resultCode);

        // Use the main thread to update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultCode == 0) {
                result(@"Detection successful");
           [self navigateToRootViewController:controller];
            } else {
                result([FlutterError errorWithCode:@"SDK_ERROR" message:message details:nil]);
                // Handle error UI if needed
                 [self navigateToRootViewController:controller];
            }
        });
            [self closeUI:controller];
    }];
}
- (void)navigateToRootViewController:(FlutterViewController *)controller {
    if (controller.navigationController) {
        [controller.navigationController popToRootViewControllerAnimated:YES];
    } else {
        // Handle the case where the controller is not embedded in a navigation controller
        // This might require a different approach depending on your app's architecture
    }
}
- (void)closeUI:(FlutterViewController *)controller {
    // Example: Dismiss the current view controller
 [controller.navigationController popViewControllerAnimated:YES];
}
- (void)getDeviceIdWithResult:(FlutterResult)result {
    NSString *deviceId = [QLZConfigure deviceIDForIntegration];
    result(deviceId);
}

@end
