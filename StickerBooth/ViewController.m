//
//  ViewController.m
//  gifDemo
//
//  Created by djr on 2020/2/19.
//  Copyright © 2020 djr. All rights reserved.
//

#import "ViewController.h"
#import "JRStickerDisplayView.h"
#import "LFMEGifView.h"

@interface ViewController ()


@property (strong, nonatomic) NSMutableArray *dataSources;

@property (weak, nonatomic) JRStickerDisplayView *myView;

@property (weak, nonatomic) LFMEGifView *showView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    JRStickerDisplayView *view = [[JRStickerDisplayView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    self.myView = view;

    NSArray *array = @[@"https://n.sinaimg.cn/tech/transform/657/w357h300/20200224/184e-ipvnszf2965725.gif", @"https://f.sinaimg.cn/tech/transform/657/w357h300/20200224/936a-ipvnszf2966203.gif", @"https://n.sinaimg.cn/tech/transform/765/w483h282/20200224/6556-ipvnszf2965189.gif", @"https://n.sinaimg.cn/tech/transform/525/w287h238/20200224/5f18-ipvnszf2967457.gif", @"https://n.sinaimg.cn/tech/transform/138/w418h520/20200224/3c48-ipvnszf2966836.gif", @"https://n.sinaimg.cn/tech/transform/514/w300h214/20200225/531e-ipzreiv8013923.gif", @"https://n.sinaimg.cn/tech/transform/660/w317h343/20200225/638f-ipzreiv8013333.gif", @"https://n.sinaimg.cn/tech/transform/452/w220h232/20200225/7c40-ipzreiv8012841.gif", @"https://n.sinaimg.cn/tech/transform/781/w500h281/20200225/e49d-ipzreiv8007188.gif", @"https://n.sinaimg.cn/tech/transform/551/w350h201/20200225/b654-ipzreiv8006277.gif", @"https://f.sinaimg.cn/tech/transform/752/w272h480/20200225/80e7-ipzreiv7999251.gif", @"https://f.sinaimg.cn/tech/transform/550/w342h208/20200225/ff7e-ipzreiv7997482.gif", @"https://n.sinaimg.cn/tech/transform/770/w418h352/20200224/ca9a-ipvnszf2964158.gif", @"https://n.sinaimg.cn/tech/transform/640/w320h320/20200224/1af0-ipvnszf2963755.gif", @"https://n.sinaimg.cn/tech/transform/500/w300h200/20200224/c51e-ipvnszf2961442.gif", @"https://n.sinaimg.cn/tech/transform/525/w300h225/20200224/23c5-ipvnszf2959589.gif", @"https://n.sinaimg.cn/tech/transform/613/w400h213/20200224/9396-ipvnszf2958000.gif", @"https://n.sinaimg.cn/tech/transform/671/w400h271/20200224/6b90-ipvnszf2956557.gif", @"https://n.sinaimg.cn/tech/transform/536/w350h186/20200224/76ea-ipvnszf2955137.gif", @"https://f.sinaimg.cn/tech/transform/403/w256h147/20200224/4f9b-ipvnszf2952014.gif", @"https://n.sinaimg.cn/tech/transform/605/w302h303/20200224/ad19-ipvnszf2951363.gif", @"https://n.sinaimg.cn/tech/transform/522/w300h222/20200224/0ede-ipvnszf2948858.gif", @"https://n.sinaimg.cn/tech/transform/379/w250h129/20200224/a7af-ipvnszf2949992.gif", @"https://n.sinaimg.cn/tech/transform/448/w270h178/20200223/0371-ipvnszf0089260.gif", @"https://n.sinaimg.cn/tech/transform/687/w400h287/20200223/1258-ipvnszf0087347.gif", @"https://n.sinaimg.cn/tech/transform/454/w245h209/20200221/54b9-ipvnsze2391471.gif", @"https://n.sinaimg.cn/tech/transform/560/w240h320/20200221/6708-ipvnsze2371530.gif", @"https://n.sinaimg.cn/tech/transform/52/w426h426/20200221/08ba-ipvnsze2368269.gif", @"https://n.sinaimg.cn/tech/transform/160/w419h541/20200220/c6fb-ipvnszc8470106.gif", @"https://n.sinaimg.cn/tech/transform/167/w500h467/20200220/8b01-ipvnszc8466482.gif", @"https://n.sinaimg.cn/tech/transform/622/w222h400/20200220/8d0b-ipvnszc8453748.gif", @"https://n.sinaimg.cn/tech/transform/677/w400h277/20200219/4639-iprtayz5721379.gif", @"https://n.sinaimg.cn/tech/transform/549/w314h235/20200218/8c2e-iprtayz1341685.gif", @"https://f.sinaimg.cn/tech/transform/450/w300h150/20200217/0ecc-iprtayy7115006.gif", @"https://n.sinaimg.cn/tech/transform/134/w582h352/20200217/e193-iprtayy7110899.gif", @"https://n.sinaimg.cn/tech/transform/527/w300h227/20200217/e063-iprtayy7106450.gif", @"https://f.sinaimg.cn/tech/transform/300/w640h460/20200217/d069-iprtayy7097622.gif", @"https://n.sinaimg.cn/tech/transform/758/w469h289/20200214/05a8-ipmxpvz6398217.gif", @"https://n.sinaimg.cn/tech/transform/500/w320h180/20200214/b17f-ipmxpvz6390129.gif"];
    NSMutableArray *a1 = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *url in array) {
        NSURL *URL = [NSURL URLWithString:url];
        [a1 addObject:URL];
    }
    
    __weak typeof(self) weakSelf = self;
    NSArray *array1 = @[[NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/677/w400h277/20200219/4639-iprtayz5721379.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/40/w420h420/20200214/b778-ipmxpvz6387339.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/362/w244h118/20200214/d095-ipmxpvz6380936.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/552/w315h237/20200214/75d2-ipmxpvz6380604.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/538/w350h188/20200214/49ef-ipmxpvz6378358.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/18/w536h282/20200213/256b-ipmxpvz2333375.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/755/w280h475/20200213/ae28-ipmxpvz2324934.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/704/w351h353/20200213/34b7-ipmxpvz2320937.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/474/w308h166/20200213/3554-ipmxpvz2313851.gif"]];
    NSArray *objs = @[array1, a1, @[[NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/677/w400h277/20200219/4639-iprtayz5721379.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/468/w300h168/20200219/8dea-iprtayz5718598.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/160/w480h480/20200220/d36d-ipvnszc8464062.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/168/w393h575/20200218/baab-iprtayz1354632.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/168/w393h575/20200218/1b0e-iprtayz1353680.gif"], [NSURL URLWithString:@"https://n.sinaimg.cn/tech/transform/69/w382h487/20200218/157c-iprtayz1351773.gif"], [NSURL URLWithString:@"https://f.sinaimg.cn/tech/transform/0/w400h400/20200218/67c5-iprtayz1348076.gif"]]];
    [self.myView setTitles:@[@"1", @"2", @"3", @"4"] contents:objs];
    self.myView.didSelectBlock = ^(NSIndexPath * _Nonnull indexPath, NSData * _Nullable data) {
        NSLog(@"%@", [[objs objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
        if (data) {
            [weakSelf _createShowView];
            weakSelf.showView.frame = weakSelf.view.bounds;
            weakSelf.showView.backgroundColor = [UIColor blackColor];
            weakSelf.showView.data = data;
            [weakSelf.view bringSubviewToFront:weakSelf.showView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hiddenShowView)];
            [weakSelf.showView addGestureRecognizer:tap];
        }
    };
}

- (void)_hiddenShowView
{
    [self.showView removeFromSuperview];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat top, bottom, left, right = 0.f;
    top = self.view.safeAreaInsets.top;
    bottom = self.view.safeAreaInsets.bottom;
    left = self.view.safeAreaInsets.left;
    right = self.view.safeAreaInsets.right;
    self.myView.frame = CGRectMake(left, top, CGRectGetWidth(self.view.frame) - left - right, CGRectGetHeight(self.view.frame) - top - bottom);
}

- (void)_createShowView
{
    LFMEGifView *view = [[LFMEGifView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:view];
    self.showView = view;
}
@end
