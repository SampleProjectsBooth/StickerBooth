//
//  RootViewController.m
//  StickerBooth
//
//  Created by djr on 2020/3/2.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "RootViewController.h"
#import "JRTestManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"aabbcc:%ld", [JRTestManager shareInstance].count);
}
@end
