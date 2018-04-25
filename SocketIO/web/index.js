var app = require('express')();
var http = require('http').Server(app);
var io   = require('socket.io')(http);



app.get('/',function(req,res){
    res.sendfile(__dirname + '/index.html');
});
http.listen(3000,function () {
    console.log('listien 3000');
});

var socketArray = new Array();
//监听客户端链接,回掉函数会传递本次链接的socket
io.on('connection', function(socket){
    var islogin = false;
    console.log('**********新加入了一个用户*********',socket.id);
    //监听客户端发送的消息
    socket.on('login',function (userId) {
       if(islogin) return;
        socket.userId = userId;
        socketArray.push(socket);
       islogin = true;
       //当客户端已加入就给客户端发送广播
       io.sockets.emit("msg",{data:"hello world,all!"});
    });
    ////监听客户端发送的消息1本demo没用到
    socket.on('privateMessage',function (data) {
        console.log(data);
    })
    //监听客户端发送的消息2
    socket.on('chat message', function(data){
        var to   = data.toUser;
        var message = data.message;
        for(var i = 0;i<socketArray.length;i++){
            var receiveData = socketArray[i];
            if (receiveData.userId == to){
                console.log('***发送消息的客户端****socket Id =',receiveData.userId,'发送的小消息为=',message);
                //向客户端发送信息一个privateMessage类型的消息
                io.to([receiveData.id]).emit('privateMessage',''+receiveData.userId+'：'+message);
            }
        }
    });
    //监听客户端发送的消息3(用户推出)
    socket.on('disconnect',function () {
        console.log('***********用户退出登陆************,'+socket.id);
    })

    //给除了自己以外的客户端广播消息
   //socket.broadcast.emit("msg",{data:"hello world"});
   //给所有客户端广播消息
  //io.sockets.emit("msg",{data:"hello world,all!"})
  //分组
//   socket.on("group1",function(data){
//       socket.join('group1');
//   })
//对分组的用户发送消息
//socket.broadcast.to("group1").emit('event_name',data);

//客户端调用socket.emit('group1')//就可以加入分组
//踢出分组 socket.leave(data.room);

//获取客户端的socket
// io.sockets.clients().forEach(function(socket){

// })
//获取分组信息
//获取所有房间（分组）信息
// io.sockets.manager.rooms
// //来获取此socketid进入的房间信息
// io.sockets.manager.roomClients[socket.id]
// //获取particular room中的客户端，返回所有在此房间的socket实例
// io.sockets.clients('particular room')


});


