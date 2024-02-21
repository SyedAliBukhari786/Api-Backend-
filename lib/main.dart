import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  runApp(MyApp());
  test('Post toMap() method', () {
    final post = Post(id: 1, userId: 1, title: 'Test Title', body: 'Test Body');
    final map = post.toMap();
    expect(map, {'id': 1, 'userId': 1, 'title': 'Test Title', 'body': 'Test Body'});
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Demo',
      home: PostList(),
    );
  }
}

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({required this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }

  // Add a method to convert Post to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late List<Post> posts;
  late int currentPage;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    posts = [];
    _scrollController = ScrollController();
    fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMore();
    }
  }

  Future<void> fetchPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_page=$currentPage'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        if (currentPage == 1) {
          posts = jsonResponse.map((post) => Post.fromJson(post)).toList();
          // Save posts to local cache
          prefs.setStringList('posts', posts.map((post) => json.encode(post.toMap())).toList());
        } else {
          posts.addAll(jsonResponse.map((post) => Post.fromJson(post)));
          // Save updated posts to local cache
          prefs.setStringList('posts', posts.map((post) => json.encode(post.toMap())).toList());
        }
      });
    } else {
      // Attempt to load from local cache in case of failure
      List<String>? cachedPosts = prefs.getStringList('posts');
      if (cachedPosts != null) {
        setState(() {
          posts = cachedPosts.map((post) => Post.fromJson(json.decode(post))).toList();
        });
      } else {
        throw Exception('Failed to load posts');
      }
    }
  }

  Future<void> _refresh() async {
    currentPage = 1;
    await fetchPosts();
  }

  Future<void> _loadMore() async {
    currentPage++;
    await fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: posts.isNotEmpty
            ? ListView.builder(
          controller: _scrollController,
          itemCount: posts.length + 1,
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return _buildLoadMoreIndicator();
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    leading: Text("${index + 1}"),
                    title: Text(
                      '${posts[index].title}',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                       // backgroundColor: Colors.green,
                      ),
                    ),
                    subtitle: Text(posts[index].body),
                    onTap: () {
                      _showPostDetails(posts[index]);
                    },
                  ),
                ),
              );
            }
          },

        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showPostDetails(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(post.title),
          content: Text(post.body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}



