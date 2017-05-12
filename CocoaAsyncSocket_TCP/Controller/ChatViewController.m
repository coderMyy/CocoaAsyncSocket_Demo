//
//  ChatViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTextCell.h"
#import "ChatAudioCell.h"
#import "ChatImageCell.h"
#import "ChatVideoCell.h"
#import "ChatFileCell.h"
#import "ChatTipCell.h"
#import "ChatModel.h"

@interface ChatViewController ()

@property (nonatomic, strong) UITableView *chatTableView;

@property (nonatomic, strong) NSMutableArray *talkMessages;

@end

@implementation ChatViewController

- (NSMutableArray *)talkMessages
{
    if (!_talkMessages) {
        _talkMessages = [NSMutableArray array];
    }
    return _talkMessages;
}

- (UITableView *)chatTableView
{
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        //普通文本,表情消息类型
        [_chatTableView registerClass:[ChatTextCell class] forCellReuseIdentifier:@"ChatTextCell"];
        //语音消息类型
        [_chatTableView registerClass:[ChatAudioCell class] forCellReuseIdentifier:@"ChatAudioCell"];
        //图片消息类型
        [_chatTableView registerClass:[ChatImageCell class] forCellReuseIdentifier:@"ChatImageCell"];
        //视频消息类型
        [_chatTableView registerClass:[ChatVideoCell class] forCellReuseIdentifier:@"ChatVideoCell"];
        //文件消息类型
        [_chatTableView registerClass:[ChatFileCell class] forCellReuseIdentifier:@"ChatFileCell"];
         //提示消息类型
        [_chatTableView registerClass:[ChatTipCell class] forCellReuseIdentifier:@"ChatTipCell"];
    }
    return _chatTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.talkMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *chatModel = self.talkMessages[indexPath.row];
    
    //文本,表情消息
    if (hashEqual(chatModel.contenType, Content_Text)) {
        
    }else if (hashEqual(chatModel.contenType, Content_Audio)){
        
        
    }else if (hashEqual(chatModel.contenType, Content_Picture)){
        
        
    }else if (hashEqual(chatModel.contenType, Content_Video)){
        
        
    }else if (hashEqual(chatModel.contenType, Content_File)){
        
        
    }else if (hashEqual(chatModel.contenType, Content_Repeal)){
    }else{
        
    }
    return nil;
}





@end
