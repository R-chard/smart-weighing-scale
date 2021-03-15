import "package:flutter/material.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "font.dart";
import "data.dart";
import "package:loadcellapp/appPages/scaleList.dart";

class MessageHandler extends StatefulWidget {
  // handles information about notification
  @override createState() =>
      _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler>{

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List<Data> _messages;
  List<String> _messageTime;
  static int callbackCounter = 0;
  // prevents double triggering of firebase listeners

  @override
  void initState() {
    super.initState();
    _messages = List<Data>();
    _messageTime = List<String>();
    _getToken();

    firebaseMessaging.configure(
      // within app
        onMessage: (Map<String,dynamic> message) async{
          // called when app is running in the foreground
          if (callbackCounter%2==1) {
            print("onMessage: $message");
            _setMessage(message);
          }
          callbackCounter++;
        },
        onResume: (Map<String,dynamic> message) async{
          // called when app is running in the background
          if (callbackCounter%2==1) {
            print("onResume:$message");
            _setMessage(message);
          }
          callbackCounter++;
        },
        onLaunch: (Map<String,dynamic> message) async{
          // called when app is not running
          if (callbackCounter%2==1) {
            print("onLaunch:$message");
            _setMessage(message);
          }
        }
    );
  }

  _setMessage(Map<String, dynamic> message) {
    //message from cloud is a nested json in the format
    // {notification:{title:X,body:X}, data:{message:X},UserData{}}
    Data data = Data(message["data"]["name"],message["data"]["remarks"],message["data"]["pweight"],null);
    // todo:change null to productspecs
    DateTime _time = DateTime.fromMillisecondsSinceEpoch(message["data"]["google.sent_time"]);
    String _hourTime = _time.hour.toString() + ":" + _time.minute.toString();

    setState(() {
      // initializes Message object
      _messages.add(data);
      _messageTime.add(_hourTime);
    });
  }

    _getToken() {
      firebaseMessaging.getToken().then((token) {
        print(token);
      });
    }
    // run function to find token id

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.amber[300],
      appBar: AppBar(
        title: Text("Notifications",style:Font.style(20.0, Colors.white)),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        ),
      body: _buildNotifs(context)
    );
  }

  Widget _buildNotifs(BuildContext context) {
    if (_messages.isNotEmpty) {
      return ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                  leading: Icon(Icons.mail),
                  title: _generateText(_messages[index]),
                  trailing: Text(_messageTime[index],style: Font.style(14, Colors.black54),),
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SmartScaleList()));
                }
            ));
          }
      );
     }
    // display for when there is no notifications
    else return Column(
      children: <Widget>[
        Padding(padding:EdgeInsets.symmetric(vertical:20)),
        Container(
          child:Image.asset("lib/assets/images/empty_box.png"),
          constraints: BoxConstraints.tightFor(width:300, height:300),
        ),
        Padding(padding:EdgeInsets.symmetric(vertical:30)),
        Container(
          child: Text(
            "There are no new notifications currently. Check again later",
            style:Font.style(19,Colors.white), textAlign: TextAlign.center),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _generateText(Data data){
    return Text("The percentage of fuel left in ${data.label}'s tank has "
        "gone down to ${data.weight}.\nClick here to view his/her profile!",
        style: Font.style(19, Colors.black54)
    );
  }
}

