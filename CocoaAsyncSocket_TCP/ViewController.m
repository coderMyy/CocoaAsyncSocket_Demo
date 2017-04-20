//
//  ViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/4/14.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *messageTextField;

@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation ViewController

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:18.f weight:0.5];
        _sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _sendBtn;
}

- (UITextField *)messageTextField
{
    if (!_messageTextField) {
        _messageTextField = [[UITextField alloc]init];
        _messageTextField.placeholder = @"请输入消息内容";
        _messageTextField.textColor = [UIColor redColor];
        _messageTextField.font = [UIFont systemFontOfSize:14.f];
        _messageTextField.textAlignment = NSTextAlignmentLeft;
        _messageTextField.layer.borderColor = [UIColor redColor].CGColor;
        _messageTextField.layer.borderWidth = 1.f;
    }
    return _messageTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}


- (void)initUI
{
    [self.view addSubview:self.messageTextField];
    self.messageTextField.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)*0.5,200, 200, 20);
    
    [self.view addSubview:self.sendBtn];
    self.sendBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)*0.5, 250, 80,50);
}


@end
