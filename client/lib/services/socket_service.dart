import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;
  bool _isConnected = false;

  void connect(String token) {
    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    _socket.on('connect', (_) {
      _isConnected = true;
      print('Socket connected');
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      print('Socket disconnected');
    });

    _socket.on('error', (error) {
      print('Socket error: $error');
    });

    // Listen for recruitment events
    _socket.on('interview_scheduled', (data) {
      print('Interview scheduled: $data');
    });

    _socket.on('application_updated', (data) {
      print('Application updated: $data');
    });

    _socket.on('notification', (data) {
      print('Notification: $data');
    });
  }

  void disconnect() {
    _socket.disconnect();
    // Socket instance is handled by disconnect() method, no need to nullify
    _isConnected = false;
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void off(String event) {
    _socket.off(event);
  }

  bool get isConnected => _isConnected;
}
