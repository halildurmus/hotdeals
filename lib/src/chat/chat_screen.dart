import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../app_localizations.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import 'blocked_users.dart';
import 'message_arguments.dart';
import 'message_screen.dart';

enum _ChatPopup { blockedUsers }

typedef Json = Map<String, dynamic>;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static const String routeName = '/chats';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late MyUser? _user;

  @override
  void initState() {
    _user = Provider.of<UserControllerImpl>(context, listen: false).user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double _width = MediaQuery.of(context).size.width;

    Future<void> _onRefresh() async {
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget _buildSignIn() {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Icon(
                LineIcons.facebookMessenger,
                color: theme.primaryColor,
                size: 150.0,
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context)!.youNeedToSignIn,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.youNeedToSignInToSee,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildNoChats() {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Icon(
                LineIcons.facebookMessenger,
                color: theme.primaryColor,
                size: 150.0,
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context)!.noChats,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.noActiveConversations,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildCircularProgressIndicator() {
      return const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget _buildChats() {
      return StreamBuilder<QuerySnapshot<Json>>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('users', arrayContains: _user!.uid)
            .orderBy('latestMessage.createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot<Json>> _items = snapshot.data!.docs;

            // Removes empty message docs.
            _items.removeWhere((DocumentSnapshot<Json> e) =>
                (e.get('latestMessage') as Json).isEmpty);

            if (_items.isEmpty) {
              return _buildNoChats();
            }

            return Consumer<UserControllerImpl>(
              builder: (BuildContext context, UserControllerImpl mongoUser,
                  Widget? child) {
                final MyUser? user = mongoUser.user;

                return ListView.separated(
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    String _user2Id;
                    if (_user!.uid == _items[index].id.split('_')[0]) {
                      _user2Id = _items[index].id.split('_')[1];
                    } else {
                      _user2Id = _items[index].id.split('_')[0];
                    }

                    final Map<String, dynamic> _latestMessage =
                        _items[index].get('latestMessage') as Json;
                    final bool _lastMessageIsFile =
                        _latestMessage['type'] == 'file';
                    final bool _lastMessageIsImage =
                        _latestMessage['type'] == 'image';
                    final String _sentBy =
                        _latestMessage['author']['id'] as String;
                    bool _isRead;
                    if (_sentBy != _user!.uid) {
                      _isRead = (_latestMessage['status'] as String) == 'seen';
                    } else {
                      _isRead = true;
                    }

                    final bool _isUserBlocked =
                        user!.blockedUsers!.contains(_user2Id);

                    final DateTime _createdAt =
                        DateTime.fromMillisecondsSinceEpoch(
                      _latestMessage['createdAt'] as int,
                    );

                    return FutureBuilder<MyUser>(
                      future: GetIt.I
                          .get<SpringService>()
                          .getUserByUid(uid: _user2Id),
                      builder: (BuildContext context,
                          AsyncSnapshot<MyUser> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Center(
                              child: Text(AppLocalizations.of(context)!
                                  .anErrorOccurred),
                            );
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return buildCircularProgressIndicator();
                          case ConnectionState.done:
                            {
                              if (snapshot.hasData) {
                                final MyUser _user2 = snapshot.data!;

                                return InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(
                                    MessageScreen.routeName,
                                    arguments: MessageArguments(
                                      docId: _items[index].id,
                                      user2: _user2,
                                    ),
                                  ),
                                  highlightColor:
                                      theme.primaryColorLight.withOpacity(.1),
                                  splashColor:
                                      theme.primaryColorLight.withOpacity(.1),
                                  child: Container(
                                    color: _isRead
                                        ? Colors.transparent
                                        : theme.primaryColor.withOpacity(.2),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              radius: 24.0,
                                              backgroundImage:
                                                  NetworkImage(_user2.avatar!),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: _width / 1.8,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        _user2.nickname!,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                if (_isUserBlocked)
                                                  Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        LineIcons.ban,
                                                        size: 18.0,
                                                        color: theme.errorColor,
                                                      ),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Text(
                                                        "You can't chat with this user",
                                                        style: TextStyle(
                                                          color:
                                                              theme.errorColor,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (_lastMessageIsFile)
                                                  Row(
                                                    children: <Widget>[
                                                      const Icon(
                                                        Icons.description,
                                                        color: Color.fromRGBO(
                                                            117, 117, 117, 1),
                                                        size: 18.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      SizedBox(
                                                        width: _width / 1.8,
                                                        child: Text(
                                                          _latestMessage['name']
                                                              as String,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (_lastMessageIsImage)
                                                  Row(
                                                    children: <Widget>[
                                                      const Icon(
                                                        FontAwesomeIcons
                                                            .solidImage,
                                                        color: Color.fromRGBO(
                                                            117, 117, 117, 1),
                                                        size: 16.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .image,
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  SizedBox(
                                                    width: _width / 1.8,
                                                    child: Text(
                                                      _latestMessage['text']
                                                          as String,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              timeago.format(_createdAt,
                                                  locale:
                                                      '${Localizations.localeOf(context).languageCode}_short'),
                                              style: TextStyle(
                                                color: _isRead
                                                    ? Colors.grey
                                                    : theme.primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (!_isRead)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: CircleAvatar(
                                                  radius: 12.0,
                                                  backgroundColor:
                                                      theme.primaryColor,
                                                  child: const Text(
                                                    '1',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              print(snapshot.error);

                              return Center(
                                child: Text(AppLocalizations.of(context)!
                                    .anErrorOccurred),
                              );
                            }
                          default:
                            return buildCircularProgressIndicator();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 100.0, right: 16.0),
                      child: Divider(height: 0.0),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return Text(snapshot.error.toString());
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
        actions: <Widget>[
          PopupMenuButton<_ChatPopup>(
            icon: const Icon(
              FontAwesomeIcons.ellipsisV,
              size: 20.0,
            ),
            onSelected: (_ChatPopup result) {
              if (result == _ChatPopup.blockedUsers) {
                Navigator.of(context).pushNamed(BlockedUsers.routeName);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<_ChatPopup>>[
              PopupMenuItem<_ChatPopup>(
                value: _ChatPopup.blockedUsers,
                child: Text(AppLocalizations.of(context)!.blockedUsers),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _user == null ? _buildSignIn() : _buildChats(),
      ),
    );
  }
}
