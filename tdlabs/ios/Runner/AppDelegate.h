#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <GoogleMaps/GoogleMaps.h>
#import <QiaolzSDK/QiaolzSDK.h>

@interface AppDelegate : FlutterAppDelegate <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *peripheral;

@end
