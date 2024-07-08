import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_in_web/services/data_service.dart';
import 'package:talk_in_web/generated/l10n.dart';
class FindPeople extends StatefulWidget {
  const FindPeople({super.key});

  @override
  State<FindPeople> createState() => _FindPeopleState();
}

class _FindPeopleState extends State<FindPeople> {

  //List<Map<String,dynamic>> userList = [];

  // void loadUsers() async{
  //   final list = await DataService().getAllUsersExceptCurrentUser();
  //   setState(() {
  //     userList = list;
  //   });
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   loadUsers();
  // }

  @override
  Widget build(BuildContext context) {
    final dataServiceViewModel = Provider.of<DataService>(context);
    Future.delayed(Duration.zero,() async{
      dataServiceViewModel.getAllUsersExceptCurrentUser();
    });
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black26,
      ),
      body: ListView.builder(
          itemCount: dataServiceViewModel.userList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context,index){
            String name = dataServiceViewModel.userList[index]["name"].toString();
            String profilePic = dataServiceViewModel.userList[index]["profilePic"].toString();
            // bool isFriend = dataServiceViewModel.friendList.contains(dataServiceViewModel.userList[index]);
            // bool isRequested = dataServiceViewModel.sentRequestList.contains(dataServiceViewModel.userList[index]);
            bool isFriend = false;
            bool isRequested = false;
            bool profileVisibility = bool.parse(dataServiceViewModel.userList[index]["profileVisibility"].toString());
            dataServiceViewModel.friendList.forEach((element) {
              if(element["id"].toString().compareTo(dataServiceViewModel.userList[index]["id"].toString())==0){
                isFriend = true;
              }
            });
            dataServiceViewModel.sentRequestList.forEach((element) {
              if(element["id"].toString().compareTo(dataServiceViewModel.userList[index]["id"].toString())==0){
                isRequested = true;
              }
            });
            //print(dataServiceViewModel.friendList.length);
            //print(dataServiceViewModel.sentRequestList.length);
            //print("Find People $isFriend $isRequested");
            return ListTile(
              title: Text(name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
              leading: GestureDetector(
                onTap: (){
                  if(profileVisibility || isFriend){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        backgroundColor: Colors.black38,
                        title: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 100,
                          //maxRadius: 100,// Image radius
                          backgroundImage: profilePic=="null"?Image.asset("assets/images/profile.png").image:Image.network(profilePic).image,
                        ),
                      );
                    });
                  }else {
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        backgroundColor: Colors.black38,
                        title: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 100,
                          //maxRadius: 100,// Image radius
                          backgroundImage: Image.asset("assets/images/profile.png").image,
                        ),
                      );
                    });
                  }
                },
                child: profilePic=="null"?Image.asset("assets/images/profile.png",width: 30,height:30,):Image.network(profilePic,width: 30,height:30,),
              ),
              trailing: ElevatedButton(
                onPressed: isRequested? null: isFriend? () async{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black26,content: Text("Unfriend user",style: TextStyle(color: Colors.white),)));
                  await dataServiceViewModel.unFriendUser(context, dataServiceViewModel.userList[index]["id"].toString());
                } : () async{
                  await dataServiceViewModel.sendFriendRequest(context, dataServiceViewModel.userList[index]);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black26,content: Text("Sent",style: TextStyle(color: Colors.white),)));
                },
                child: isRequested ? Text(S.of(context).Requested,style: TextStyle(color: Colors.white),) : isFriend ? Text(S.of(context).UnFriend) : Text(S.of(context).SendFriendRequest),
              ),
            );
          }),
    );
  }
}
