//
//  Loction.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "Loction.h"

@interface Loction ()
@property (strong, nonatomic)MKMapView *mapView;
@property (strong, nonatomic)CLLocationManager *_locationManager;
@property (strong, nonatomic)UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic)UISegmentedControl *segmentedControl;
@end

@implementation Loction

#define     TABBarHeight (self.tabBarController.tabBar.frame.size.height)
#define     SCREENRECT ([[UIScreen mainScreen] bounds])

- (void)setMapConfig
{
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, SCREENRECT.size.height-TABBarHeight-self.navigationController.navigationBar.frame.size.height)];
    [self.mapView setBackgroundColor:[UIColor whiteColor]];
    self.mapView.delegate = self;
    //请求定位服务
    self._locationManager=[[CLLocationManager alloc]init];
    self._locationManager.delegate = self;
    if([[[UIDevice currentDevice]systemVersion] doubleValue]>=8.0)
    {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self._locationManager requestWhenInUseAuthorization];
        [self._locationManager requestAlwaysAuthorization];
    }
    [self._locationManager startUpdatingLocation];

    _mapView.userTrackingMode=MKUserTrackingModeFollow;
    _mapView.mapType=MKMapTypeStandard;


    [self.view addSubview:self.mapView];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ]
                                                      initWithFrame:CGRectMake(85.0f,10.0f,30.0f,30.0f)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    [_activityIndicatorView setCenter:CGPointMake(90.0f, self.navigationController.navigationBar.center.y-[[UIApplication sharedApplication] statusBarFrame].size.height)];
    [self.navigationController.navigationBar addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    
    NSArray *arr = [[NSArray alloc]initWithObjects:NSLocalizedString(@"平面",nil),NSLocalizedString(@"卫星",nil),nil];

    _segmentedControl = [[UISegmentedControl alloc]initWithItems:arr];
    
    _segmentedControl.frame = CGRectMake(self.view.frame.size.width-110.0f, self.navigationController.navigationBar.frame.origin.y+5.0f, 100.0f, 30.0f);
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setTintColor:[UIColor redColor]];
    [_segmentedControl addTarget:self action:@selector(_segment_select:) forControlEvents:UIControlEventValueChanged];
    [_mapView addSubview:_segmentedControl];
}
- (void)_segment_select:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            _mapView.mapType=MKMapTypeStandard;

        }
            break;
        case 1:
        {
            _mapView.mapType=MKMapTypeHybrid;
        }
            break;
        default:
            break;
    }

}
- (void)viewDidAppear:(BOOL)animated
{
    self._locationManager.distanceFilter = kCLDistanceFilterNone;
    self._locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self._locationManager startUpdatingLocation];
//    NSLog(@"%@", [self deviceLocation]);
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self._locationManager.location.coordinate.latitude;
    region.center.longitude = self._locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.05f;
    region.span.longitudeDelta = 0.05f;
    [self.mapView setRegion:region animated:YES];
}
- (void)viewDidLoad {
    self.title=NSLocalizedString(@"地图定位",nil);
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"地图",nil)];
    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

    [self setMapConfig];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//MapView委托方法，当定位自身时调用
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    CLLocationCoordinate2D loc = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 100, 100);
    
//    [self.mapView setRegion:region animated:YES];
    [_activityIndicatorView stopAnimating];

}
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self._locationManager.location.coordinate.latitude, self._locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self._locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self._locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self._locationManager.location.altitude];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (
        ([self._locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) ||
        (![self._locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorized)
        ) {
        
    }else {
        
        [self._locationManager startUpdatingLocation];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
