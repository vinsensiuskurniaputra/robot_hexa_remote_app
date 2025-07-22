import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'robot_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const HexapodControlApp());
}

class HexapodControlApp extends StatelessWidget {
  const HexapodControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hexapod Robot Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.cyan,
          surface: Colors.grey.shade900,
          background: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          elevation: 4,
        ),
      ),
      home: const RobotControlScreen(),
    );
  }
}

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen>
    with SingleTickerProviderStateMixin {
  final String robotIP = '192.168.4.1';
  bool isConnected = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Column(
          children: [
            const Text(
              'Hexapod Robot Controller',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              robotIP,
              style: TextStyle(
                fontSize: 14,
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Emergency Stop Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red, size: 28),
              onPressed: () async {
                HapticFeedback.heavyImpact();
                _animationController.forward(from: 0.0);
                final success = await RobotService.stopAll();
                _showSnackBar(
                  success
                      ? 'Emergency Stop Activated!'
                      : 'Failed to stop robot',
                );
              },
              tooltip: 'Emergency Stop',
            ),
          ),
          IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _animationController.value * 0.2,
                  child: Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            onPressed: () async {
              _animationController.forward(from: 0.0);
              if (!isConnected) {
                // Test connection
                final connected = await RobotService.testConnection();
                setState(() {
                  isConnected = connected;
                });
                // _showSnackBar(
                //   connected ? 'Connected to robot' : 'Failed to connect',
                // );
              } else {
                // Disconnect
                setState(() {
                  isConnected = false;
                });
                _showSnackBar('Disconnected');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status Card
              Card(
                color: Colors.grey.shade900,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isConnected ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isConnected ? Icons.check_circle : Icons.error_outline,
                            color: isConnected ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? 'Connected to Robot' : 'Disconnected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IP: $robotIP',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Movement Controls
              _buildControlSection(
                title: 'Movement Controls',
                icon: Icons.rowing,
                color: Colors.blue,
                child: Column(
                  children: [
                    // Direction pad
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDirectionButton(
                            icon: Icons.arrow_upward,
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              final success = await RobotService.maju();
                              _showSnackBar(
                                success ? 'Moving Forward' : 'Failed to move forward',
                              );
                            },
                            color: Colors.blue,
                            tooltip: 'Forward',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDirectionButton(
                          icon: Icons.arrow_back,
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.putarKiri();
                            _showSnackBar(
                              success ? 'Turning Left' : 'Failed to turn left',
                            );
                          },
                          color: Colors.blue,
                          tooltip: 'Left',
                        ),
                        const SizedBox(width: 16),
                        _buildDirectionButton(
                          icon: Icons.stop,
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            final success = await RobotService.stop();
                            _showSnackBar(
                              success ? 'Stopped' : 'Failed to stop',
                            );
                          },
                          color: Colors.red,
                          tooltip: 'Stop',
                        ),
                        const SizedBox(width: 16),
                        _buildDirectionButton(
                          icon: Icons.arrow_forward,
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.putarKanan();
                            _showSnackBar(
                              success ? 'Turning Right' : 'Failed to turn right',
                            );
                          },
                          color: Colors.blue,
                          tooltip: 'Right',
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDirectionButton(
                            icon: Icons.arrow_downward,
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              final success = await RobotService.mundur();
                              _showSnackBar(
                                success ? 'Moving Backward' : 'Failed to move backward',
                              );
                            },
                            color: Colors.blue,
                            tooltip: 'Backward',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Gripper Controls
              _buildControlSection(
                title: 'Gripper Controls',
                icon: Icons.pan_tool,
                color: Colors.orange,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.arrow_upward,
                          label: 'Up',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.gripperUp();
                            _showSnackBar(
                              success ? 'Gripper Up' : 'Failed to move gripper up',
                            );
                          },
                          color: Colors.orange,
                        ),
                        _buildControlButton(
                          icon: Icons.arrow_downward,
                          label: 'Down',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.gripperDown();
                            _showSnackBar(
                              success ? 'Gripper Down' : 'Failed to move gripper down',
                            );
                          },
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.open_in_full,
                          label: 'Open',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.gripperOpen();
                            _showSnackBar(
                              success ? 'Gripper Open' : 'Failed to open gripper',
                            );
                          },
                          color: Colors.orange,
                        ),
                        _buildControlButton(
                          icon: Icons.close_fullscreen,
                          label: 'Close',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.gripperClose();
                            _showSnackBar(
                              success ? 'Gripper Close' : 'Failed to close gripper',
                            );
                          },
                          color: Colors.orange,
                        ),
                        _buildControlButton(
                          icon: Icons.height,
                          label: 'Half Down',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.gripperHalfDown();
                            _showSnackBar(
                              success ? 'Gripper Half Down' : 'Failed to half down gripper',
                            );
                          },
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Walking Mode Controls
              _buildControlSection(
                title: 'Walking Mode',
                icon: Icons.directions_walk,
                color: Colors.green,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.keyboard_double_arrow_down,
                          label: 'Normal',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.setNormalStep();
                            _showSnackBar(
                              success ? 'Normal Step Mode' : 'Failed to set normal step',
                            );
                          },
                          color: Colors.green,
                        ),
                        _buildControlButton(
                          icon: Icons.keyboard_double_arrow_up,
                          label: 'High',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.setHighStep();
                            _showSnackBar(
                              success ? 'High Step Mode' : 'Failed to set high step',
                            );
                          },
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.stairs,
                          label: 'Stair On',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.enableStairStep();
                            _showSnackBar(
                              success ? 'Stair Mode On' : 'Failed to enable stair mode',
                            );
                          },
                          color: Colors.green,
                        ),
                        _buildControlButton(
                          icon: Icons.stairs_outlined,
                          label: 'Stair Off',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.disableStairStep();
                            _showSnackBar(
                              success ? 'Stair Mode Off' : 'Failed to disable stair mode',
                            );
                          },
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.swap_horiz,
                          label: 'Slide On',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.enableSlideStep();
                            _showSnackBar(
                              success ? 'Slide Mode On' : 'Failed to enable slide mode',
                            );
                          },
                          color: Colors.green,
                        ),
                        _buildControlButton(
                          icon: Icons.swap_horiz_outlined,
                          label: 'Slide Off',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success = await RobotService.disableSlideStep();
                            _showSnackBar(
                              success ? 'Slide Mode Off' : 'Failed to disable slide mode',
                            );
                          },
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     duration: const Duration(seconds: 1),
    //     behavior: SnackBarBehavior.floating,
    //     margin: const EdgeInsets.all(8),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     backgroundColor: Colors.blue[700],
    //   ),
    // );
  }
  
  // Helper method to build control sections with consistent styling
  Widget _buildControlSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
  
  // Helper method to build direction control buttons
  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build control buttons
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
            elevation: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
