import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotService {
  static const String baseUrl = 'http://192.168.4.1';
  static const Duration timeout = Duration(seconds: 5);

  // Test connection to robot
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/?State=U'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Send movement command
  static Future<bool> sendMovementCommand(String command) async {
    return await _sendCommand('/movement', {'command': command});
  }

  // Send gripper command
  static Future<bool> sendGripperCommand(String command) async {
    return await _sendCommand('/gripper', {'command': command});
  }

  // Send leg/mode command
  static Future<bool> sendLegCommand(String command) async {
    return await _sendCommand('/leg', {'command': command});
  }

  // Send emote command
  static Future<bool> sendEmoteCommand(String emote) async {
    return await _sendCommand('/emote', {'emote': emote});
  }

  // Stop all movements (emergency stop)
  static Future<bool> stopAll() async {
    return await _sendCommand('/stop', {});
  }

  // Private method to send HTTP requests
  static Future<bool> _sendCommand(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('Command sent successfully: $endpoint - $data');
        return true;
      } else {
        print('Command failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending command: $e');
      return false;
    }
  }

  // Get robot status
  static Future<Map<String, dynamic>?> getRobotStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/status'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting robot status: $e');
    }
    return null;
  }

  // Movement commands
  static Future<bool> moveForward() => _sendGetCommand('U');
  static Future<bool> moveBackward() => _sendGetCommand('B');
  static Future<bool> turnLeft() => _sendGetCommand('L');
  static Future<bool> turnRight() => _sendGetCommand('R');
  static Future<bool> stop() => _sendGetCommand('S');

  // Additional commands for robot control
  static Future<bool> maju() => _sendGetCommand('U');
  static Future<bool> mundur() => _sendGetCommand('B');
  static Future<bool> putarKiri() => _sendGetCommand('L');
  static Future<bool> putarKanan() => _sendGetCommand('R');

  // Step modes
  static Future<bool> setNormalStep() => _sendGetCommand('G');
  static Future<bool> setHighStep() => _sendGetCommand('H');
  static Future<bool> disableStairStep() => _sendGetCommand('N');
  static Future<bool> enableStairStep() => _sendGetCommand('T');
  static Future<bool> disableSlideStep() => _sendGetCommand('A');
  static Future<bool> enableSlideStep() => _sendGetCommand('X');

  // Gripper controls
  static Future<bool> gripperDown() => _sendGetCommand('Q');
  static Future<bool> gripperClose() => _sendGetCommand('W');
  static Future<bool> gripperOpen() => _sendGetCommand('I');
  static Future<bool> gripperUp() => _sendGetCommand('J');
  static Future<bool> gripperHalfDown() => _sendGetCommand('Z');

  // Private method to send HTTP GET requests
  static Future<bool> _sendGetCommand(String command) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/?State=$command'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('Command sent successfully: $command');
        return true;
      } else {
        print('Command failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending command: $e');
      return false;
    }
  }
}

// Command constants for easy reference
class RobotCommands {
  // Movement commands
  static const String forward = 'forward';
  static const String backward = 'backward';
  static const String left = 'left';
  static const String right = 'right';
  static const String stop = 'stop';

  // Gripper commands
  static const String gripperOpen = 'open';
  static const String gripperClose = 'close';
  static const String gripperUp = 'up';
  static const String gripperDown = 'down';
  static const String gripperHigh = 'high';

  // Leg/Mode commands
  static const String rightSlide = 'right_slide';
  static const String leftSlide = 'left_slide';
  static const String leftNormal = 'left_normal';
  static const String leftHigh = 'left_high';
  static const String rightStair = 'right_stair';
  static const String leftStair = 'left_stair';

  // Emote commands
  static const String happy = 'happy';
  static const String angry = 'angry';
  static const String surprised = 'surprised';
  static const String sad = 'sad';
  static const String cool = 'cool';
}
