//
//  ViewController.m
//  LPLocation
//
//  Created by Leap on 2017/4/2.
//  Copyright © 2017年 LPDev. All rights reserved.
//

#import "ViewController.h"
#import "LPLocationManager.h"
#import "Realm.h"
#import "LPLoc.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RLMResults *locArray;

@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 20, 100, 50)];
    [button setTitle:@"清除数据" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(actionClear) forControlEvents:UIControlEventTouchUpInside];
    
    //定位使用前先判断定位是否可用
    if(![CLLocationManager locationServicesEnabled]){
        NSLog(@"请开启定位:设置 > 隐私 > 位置 > 定位服务");
    }
    
    // Do any additional setup after loading the view, typically from a nib.
    //收到杀掉程序后需要唤醒要掉startMonitoringSignificantLocationChanges
//    [[LPLocationManager sharedManager]startMonitoringSignificantLocationChanges];
    //startUpdatingLocation是不能唤醒应用的
    [[LPLocationManager sharedManager]startUpdatingLocation];
    
    self.locArray = [[LPLoc allObjects] sortedResultsUsingProperty:@"date" ascending:NO];
    
    __weak __typeof(&*self)ws = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        
        ws.locArray = [[LPLoc allObjects] sortedResultsUsingProperty:@"date" ascending:NO];
        
        [ws.tableView reloadData];
    }];

}

- (void)actionClear
{
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    LPLoc *loc = [self.locArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [loc.date description];
    cell.detailTextLabel.text = loc.loc;
    cell.textLabel.textColor = loc.background?[UIColor redColor]:[UIColor blueColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end
