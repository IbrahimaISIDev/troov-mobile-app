import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _client;
  final _feedController = StreamController<Post>.broadcast();
  final _postLikesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _postCommentsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Post> get feedStream => _feedController.stream;
  Stream<Map<String, dynamic>> get postLikesStream =>
      _postLikesController.stream;
  Stream<Map<String, dynamic>> get postCommentsStream =>
      _postCommentsController.stream;

  void connect() {
    if (_client != null && _client!.isActive) return;

    // Use ws:// for unencrypted local connection, matching http port 8081
    // Note: Emulator uses 10.0.2.2, Physical device uses 192.168.1.36
    // We'll reuse the host from AuthService but change protocol and port/path
    // AuthService.baseUrl is 'http://192.168.1.36:8081/api'
    // WS URL should be 'ws://192.168.1.36:8081/ws-troov'

    final wsUrl = AuthService.baseUrl
        .replaceFirst('http', 'ws')
        .replaceFirst('/api', '/ws-troov');

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => print('WS Error: $error'),
        onStompError: (dynamic error) => print('Stomp Error: $error'),
        onDisconnect: (dynamic frame) => print('WS Disconnected'),
      ),
    );

    _client!.activate();
    print('WS Connecting to $wsUrl');
  }

  void _onConnect(StompFrame frame) {
    print('WS Connected');

    // Subscribe to global feed
    _client!.subscribe(
      destination: '/topic/feed',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            final post = Post.fromJson(data);
            _feedController.add(post);
          } catch (e) {
            print('WS Feed Error: $e');
          }
        }
      },
    );
  }

  // Subscribe to specific post likes
  // Clients call this when viewing a post
  void subscribeToPostLikes(String postId) {
    if (_client == null || !_client!.isActive) return;

    _client!.subscribe(
      destination: '/topic/post/$postId/likes',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _postLikesController.add(data);
        }
      },
    );
  }

  // Subscribe to post comments
  void subscribeToPostComments(String postId) {
    if (_client == null || !_client!.isActive) return;

    _client!.subscribe(
      destination: '/topic/post/$postId/comments',
      callback: (frame) {
        if (frame.body != null) {
          // We receive a CommentResponse, but stream passes raw map or object?
          // Let's pass a map wrapper: {postId: ..., comment: Comment}
          final commentData = jsonDecode(frame.body!);
          _postCommentsController.add(
              {'postId': postId, 'comment': Comment.fromJson(commentData)});
        }
      },
    );
  }

  final _postViewsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get postViewsStream =>
      _postViewsController.stream;

  // Subscribe to post view counts
  void subscribeToPostViews(String postId) {
    if (_client == null || !_client!.isActive) return;

    _client!.subscribe(
      destination: '/topic/post/$postId/views',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _postViewsController.add(data);
        }
      },
    );
  }

  final _postCommentCountController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get postCommentCountStream =>
      _postCommentCountController.stream;

  // Subscribe to post comment count
  void subscribeToPostCommentCount(String postId) {
    if (_client == null || !_client!.isActive) return;

    _client!.subscribe(
      destination: '/topic/post/$postId/comment-count',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          _postCommentCountController.add(data);
        }
      },
    );
  }

  final _postCommentLikesController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get postCommentLikesStream =>
      _postCommentLikesController.stream;

  // Subscribe to post comment likes
  void subscribeToPostCommentLikes(String postId) {
    if (_client == null || !_client!.isActive) return;

    _client!.subscribe(
      destination: '/topic/post/$postId/comment-likes',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          data['postId'] = postId;
          _postCommentLikesController.add(data);
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}
