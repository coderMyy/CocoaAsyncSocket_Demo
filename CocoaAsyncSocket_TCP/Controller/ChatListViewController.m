//
//  ChatListViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "ChatListCell.h"
#import "ChatModel.h"

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)UITableView *chatlistTableView;
//消息数据源
@property (nonatomic, strong) NSMutableArray *messagesArray;

@end

@implementation ChatListViewController

- (NSMutableArray *)messagesArray
{
    if (!_messagesArray) {
        _messagesArray = [NSMutableArray array];
    }
    return _messagesArray;
}

- (UITableView *)chatlistTableView
{
    if (!_chatlistTableView) {
        _chatlistTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _chatlistTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatlistTableView.delegate         = self;
        _chatlistTableView.dataSource     = self;
        _chatlistTableView.rowHeight       = 60;
        //聊天列表cell
        [_chatlistTableView registerNib:[UINib nibWithNibName:@"ChatListCell" bundle:nil] forCellReuseIdentifier:@"ChatListCell"];
    }
    return _chatlistTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self getMessages];
}



- (void)initUI
{
    [self.view addSubview:self.chatlistTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatListCell *listCell  = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    
    ChatModel *listModel = self.messagesArray[indexPath.row];
    
    listCell.chatModel = listModel;
    
    return listCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatViewController *chatVc = [[ChatViewController alloc]init];
    [self.navigationController pushViewController:chatVc animated:YES];
}

#pragma mark - 拉取数据库数据
- (void)getMessages
{
    //暂时先模拟假数据 , 后面加上数据库结构,再修改
    for (NSInteger index  = 0; index < 30; index ++) {
        
        ChatModel *chatModel   = [[ChatModel alloc]init];
        ChatContentModel *chatContent = [[ChatContentModel alloc]init];
        chatModel.content         = chatContent ;
        chatModel.nickName      = @"孟遥";
        chatModel.lastMessage  = @"UI部分持续更新中...涉及面较多,比较耗时";
        chatModel.noDisturb      = index%3==0 ? @2 : @1;
        chatModel.unreadCount = @(index);
        chatModel.lastTimeString = [NSDate timeStringWithTimeInterval:chatModel.senTime];
        [self.messagesArray addObject:chatModel];
    }
    
    [self configNav_Badges];
}

#pragma mark - 配置导航,tabbar角标
- (void)configNav_Badges
{
    NSUInteger totalUnread = 0;
    for (ChatModel *chatModel in self.messagesArray) {
        
        //如果不是免打扰(展示红点)的会话 , 计算总的未读数
        if (chatModel.noDisturb.integerValue !=2) {
            totalUnread += chatModel.unreadCount.integerValue ;
        }
    }
    self.title = totalUnread>0 ? [NSString stringWithFormat:@"聊天列表(%li)",totalUnread] : @"聊天列表";
}


@end
