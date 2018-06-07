//
//  ViewController.m
//  SocketIO
//
//  Created by ljl on 2018/4/25.
//  Copyright © 2018年 ljl. All rights reserved.
//

#import "ViewController.h"

#import <SocketIO/SocketIO-Swift.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *MessagetableView;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property(strong,nonatomic) NSMutableArray *messageArray;
@property(strong,nonatomic) SocketIOClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.MessagetableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.MessagetableView.delegate = self;
    self.MessagetableView.dataSource = self;
    
    [self connection];
    
}
- (NSMutableArray *)messageArray{
    if (!_messageArray) {
        _messageArray = @[].mutableCopy;
    }
    return _messageArray;
}
-(SocketIOClient *)client{
    
    if (!_client) {
        _client = [[SocketIOClient alloc] initWithSocketURL:[NSURL URLWithString:@"http://127.0.0.1:3000"] config:@{@"log": @YES, @"forcePolling": @YES}];
        
    }
    return _client;
}
-(void)connection{
    
    
    //正在链接
    [self.client on:@"connecting" callback:^(NSArray * data, SocketAckEmitter * ack) {
        
    }];
    //链接成功
    [self.client on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"*************\n\niOS客户端上线\n\n************");
        
        //向服务器发送一个login标识符的信息 信息内容为30342,那么服务器就知道30342的客户端用户上线了
        [self.client emit:@"login" with:@[@"30342"]];
    }];
    
    
    //监听服务器发送来的消息 msg标识符类的消息(用处当运行代码时服务器知道你上线了法送一个hello world给你)
    [self.client on:@"msg" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"我上线了服务器发给我的消息是%@",event[0]);
        
    }];
    //监听服务器发送来的消息 privateMessage
    [self.client on:@"privateMessage" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        
        if (event[0] && ![event[0] isEqualToString:@""]) {
            
            [self.messageArray insertObject:event[0] atIndex:0];
            [self.MessagetableView reloadData];
        }
    }];
    //客户端与服务器断开
    [self.client on:@"disconnect" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"*************\n\niOS客户端下线\n\n*************%@",event?event[0]:@"");
    }];
    //错误发送,并且无法被其他事件类型所处理
    [self.client on:@"error" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"*********错误****\n\n%@\n\n*************",event?event[0]:@"");
    }];
    
    //reconnect_failed:重连失败
    //reconnect:成功重连
    //reconnectin:正在重连
    //当第一次链接时:事件触发顺序为connecting->connect;当失败连击时:disconnect->reconnecting（可能进行多次）->connecting->reconnect->connect。
   
    
    
    //断开链接
    //  [self.client disconnect];

    //链接
    [self.client connect];
    
}



- (IBAction)sendMessage:(id)sender {
    NSLog(@"ddddd");
    if (self.inputText.text.length>0) {
        //发送消息 chat message是一个标识符,服务器正在监听 意思是发送chat message类型的消息给30621,消息为:self.inputView.text
        [self.client emit:@"chat message" with:@[@{@"toUser":@"30621",@"message":self.inputText.text}]];
        NSString *myUserstr = [NSString stringWithFormat:@"我:%@",self.inputText.text];
        [self.messageArray insertObject:myUserstr atIndex:0];
        
        // [self.messageTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.MessagetableView reloadData];
        self.inputText.text = @"";
    }
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.messageArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.messageArray[indexPath.row];
    return cell;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
