//
//  ViewController.mm
//  MyApp
//
//  Created by Jinwoo Kim on 6/19/24.
//

#import "ViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface ViewController ()
@property (retain, readonly, nonatomic) UIBarButtonItem *firstBarButtonItem;
@property (retain, readonly, nonatomic) UIBarButtonItem *secondBarButtonItem;
@property (retain, readonly, nonatomic) UIView *orangeView;
@end

@implementation ViewController
@synthesize firstBarButtonItem = _firstBarButtonItem;
@synthesize secondBarButtonItem = _secondBarButtonItem;
@synthesize orangeView = _orangeView;

- (void)dealloc {
    [_firstBarButtonItem release];
    [_secondBarButtonItem release];
    [_orangeView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    UINavigationItem *navigationItem = self.navigationItem;
    
    navigationItem.rightBarButtonItems = @[
        self.secondBarButtonItem,
        self.firstBarButtonItem
    ];
    
    UIView *orangeView = self.orangeView;
    orangeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:orangeView];
    [NSLayoutConstraint activateConstraints:@[
        [orangeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [orangeView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [orangeView.widthAnchor constraintEqualToConstant:100.],
        [orangeView.heightAnchor constraintEqualToConstant:100.]
    ]];
}

- (UIBarButtonItem *)firstBarButtonItem {
    if (auto firstBarButtonItem = _firstBarButtonItem) return firstBarButtonItem;
    
    UIBarButtonItem *firstBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1" style:UIBarButtonItemStylePlain target:self action:@selector(firstBarButtonItemDidTrigger:)];
    
    _firstBarButtonItem = [firstBarButtonItem retain];
    return [firstBarButtonItem autorelease];
}

- (UIBarButtonItem *)secondBarButtonItem {
    if (auto secondBarButtonItem = _secondBarButtonItem) return secondBarButtonItem;
    
    __weak auto weakSelf = self;
    UIAction *runAnimationAction = [UIAction actionWithTitle:@"Run Animation" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        auto _self = weakSelf;
        if (_self == nil) return;
        
        ((void (*)(Class, SEL))objc_msgSend)(UIViewPropertyAnimator.class, sel_registerName("_startTrackingAnimations"));
        ((void (*)(Class, SEL, BOOL))objc_msgSend)(UIViewPropertyAnimator.class, sel_registerName("_setTrackedAnimationsStartPaused:"), YES);
        
        [_self animateOrangeView];
    }];
    
    runAnimationAction.attributes = UIMenuElementAttributesKeepsMenuPresented;
    
    __kindof UIMenuElement *sliderMenuElement = ((id (*)(id, SEL, id))objc_msgSend)(objc_lookUpClass("UICustomViewMenuElement"), sel_registerName("elementWithViewProvider:"), ^ UIView * {
        UISlider *slider = [UISlider new];
        slider.minimumValue = 0.f;
        slider.maximumValue = 1.f;
        
        [slider addTarget:weakSelf action:@selector(sliderValudDidChange:) forControlEvents:UIControlEventValueChanged];
        
        return [slider autorelease];
    });
    
    UIMenu *menu = [UIMenu menuWithChildren:@[
        runAnimationAction,
        sliderMenuElement
    ]];
    
    UIBarButtonItem *secondBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"2" menu:menu];
    
    _secondBarButtonItem = [secondBarButtonItem retain];
    return [secondBarButtonItem autorelease];
}

- (UIView *)orangeView {
    if (auto orangeView = _orangeView) return orangeView;
    
    UIView *orangeView = [UIView new];
    orangeView.backgroundColor = UIColor.systemOrangeColor;
    
    _orangeView = [orangeView retain];
    return [orangeView autorelease];
}

- (void)firstBarButtonItemDidTrigger:(UIBarButtonItem *)sender {
    [self animateOrangeView];
}

- (void)sliderValudDidChange:(UISlider *)sender {
    NSUUID * _Nullable _currentTrackedAnimationsUUID = ((id (*)(Class, SEL))objc_msgSend)(UIViewPropertyAnimator.class, sel_registerName("_currentTrackedAnimationsUUID"));
    
    if (_currentTrackedAnimationsUUID == nil) return;
    
    UIViewPropertyAnimator *animator = ((id (*)(Class, SEL, id))objc_msgSend)(UIViewPropertyAnimator.class, sel_registerName("_animatorForTrackedAnimationsUUID:"), _currentTrackedAnimationsUUID);
    
    animator.fractionComplete = sender.value;
}

- (void)animateOrangeView {
    UIView *orangeView = self.orangeView;
    
    // 내부적으로 자동으로 +[UIViewPropertyAnimator _saveTrackingAnimator:forUUID:andDescription:]를 호출해서 현재 Tracked Animator에 추가될 것
    [UIView animateWithDuration:3.0 animations:^{
        [self.view removeConstraints:self.view.constraints];
        [orangeView removeConstraints:orangeView.constraints];
        [NSLayoutConstraint activateConstraints:@[
            [orangeView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [orangeView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [orangeView.widthAnchor constraintEqualToConstant:200.],
            [orangeView.heightAnchor constraintEqualToConstant:200.]
        ]];
        [self.view layoutIfNeeded];
    } 
                     completion:^(BOOL finished) {
        [self.view removeConstraints:self.view.constraints];
        [orangeView removeConstraints:orangeView.constraints];
        [NSLayoutConstraint activateConstraints:@[
            [orangeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [orangeView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [orangeView.widthAnchor constraintEqualToConstant:100.],
            [orangeView.heightAnchor constraintEqualToConstant:100.]
        ]];
    }];
}

@end
