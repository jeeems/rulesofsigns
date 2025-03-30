// ignore_for_file: unnecessary_import, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6C63FF), // Same as header color
      statusBarIconBrightness:
          Brightness.light, // White icons for dark background
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rules of Signs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFFF6584),
          surface: Colors.white,
          background: const Color(0xFFF9F9F9),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool showSplash = true;
  int score = 0;
  double? result;
  bool isComputed = false;
  bool showBreakdown = false;
  List<Map<String, dynamic>> computationSteps = [];
  Set<String> shownFacts = {};

  final Map<int, AnimationController> _termAnimationControllers = {};
  final ScrollController _scrollController = ScrollController();
  late AnimationController _breakdownController;
  late AnimationController _headerAnimationController;
  late AnimationController _termsAnimationController;
  late AnimationController _buttonsAnimationController;

  late AnimationController _splashAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _starAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _termsScaleAnimation;
  late Animation<Offset> _buttonsSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _buttonsFadeAnimation;

  String _getTermOrdinal(int index) {
    switch (index + 1) {
      case 1:
        return 'First';
      case 2:
        return 'Second';
      case 3:
        return 'Third';
      case 4:
        return 'Fourth';
      case 5:
        return 'Fifth';
      default:
        return 'Enter';
    }
  }

  String formatNumber(double? number) {
    if (number == null) return '0';
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  static const List<Map<String, dynamic>> signs = [
    {'value': '+', 'color': Color(0xFF4ECA8C), 'name': 'Positive'},
    {'value': '-', 'color': Color(0xFFFF6584), 'name': 'Negative'},
  ];

  static const List<Map<String, dynamic>> operators = [
    {'value': '+', 'color': Color(0xFF4ECA8C), 'name': 'Add'},
    {'value': '-', 'color': Color(0xFFFF6584), 'name': 'Subtract'},
    {'value': '×', 'color': Color(0xFF6C63FF), 'name': 'Multiply'},
    {'value': '÷', 'color': Color(0xFFFFAB40), 'name': 'Divide'},
  ];

  List<Map<String, dynamic>> terms = [
    {'sign': '+', 'value': ''},
    {'operator': '+', 'sign': '+', 'value': ''},
  ];

  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashAnimation();

    // Initialize controllers for all terms
    for (var term in terms) {
      _controllers.add(TextEditingController(text: term['value']));
    }
  }

  void _setupAnimations() {
    // Splash animations
    _splashAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _splashAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    _starAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Header animations
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Slightly faster
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    // Terms animations
    _termsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _termsScaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _termsAnimationController,
      curve: Curves.elasticOut,
    ));

    // Buttons animations
    _buttonsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 3), // Move further down
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.elasticOut,
    ));

    _buttonsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOut,
    ));

    // Breakdown animations
    _breakdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _startSplashAnimation() {
    _splashAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          showSplash = false;
        });

        // Start sequential animations
        _headerAnimationController.forward().then((_) {
          // After header animation completes, start terms animation
          _termsAnimationController.forward();
          // After terms animation completes, start buttons animation
          _buttonsAnimationController.forward();
        });
      });
    });
  }

  void addTerm() {
    if (terms.length < 5 && !isComputed) {
      final newTermIndex = terms.length;

      // Create animation controller for the new term
      final animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _termAnimationControllers[newTermIndex] = animationController;

      setState(() {
        terms.add({'operator': '+', 'sign': '+', 'value': ''});
        _controllers.add(TextEditingController());
      });

      // Start the animation
      animationController.forward();

      // Scroll to the new term after animation frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void deleteTerm(int index) {
    if (terms.length > 2 && !isComputed) {
      // Dispose the animation controller
      _termAnimationControllers[index]?.dispose();
      _termAnimationControllers.remove(index);

      setState(() {
        terms.removeAt(index);
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void updateTerm(int index, String field, String value) {
    if (!isComputed) {
      setState(() {
        terms[index][field] = value;
        if (field == 'value') {
          _controllers[index].text = value;
        }
      });
    }
  }

  void computeResult() {
    double currentResult = 0;
    List<Map<String, dynamic>> steps = [];

    for (int i = 0; i < terms.length; i++) {
      final term = terms[i];
      final value = double.tryParse(term['value'] ?? '0') ?? 0;
      final signedValue = term['sign'] == '-' ? -value : value;
      final signText = term['sign'] == '-' ? '-' : '';
      // final signText = term['sign'] == '-' ? '-' : '+';

      String formatValue(String value, bool isNegative) {
        return isNegative ? "(-$value)" : value;
      }

      if (i == 0) {
        currentResult = signedValue;
        // Remove parentheses from first step
        final formattedInitialValue =
            formatValue(term['value'], term['sign'] == '-');
        steps.add({
          // 'step': 'Start with ${signText}${term['value']}',
          'step': 'Start with $formattedInitialValue',
          'explanation': 'We begin with our first number',
          'result': currentResult,
          'operation': 'initial',
          'values': [signedValue],
        });
      } else {
        // final formattedValue = '(${signText}${term['value']}';
        final formattedValue = formatValue(term['value'], term['sign'] == '-');
        final operator = term['operator'];
        final previousResult = currentResult;
        String explanation = '';

        switch (operator) {
          case '+':
            currentResult += signedValue;
            // More detailed explanations for addition
            if ((previousResult >= 0 && signedValue >= 0) ||
                (previousResult < 0 && signedValue < 0)) {
              explanation =
                  'When adding numbers with the same sign, we add their absolute values and keep the sign';
            } else {
              explanation =
                  'When adding numbers with different signs, we find the difference between their absolute values and use the sign of the larger number';
            }
            break;
          case '-':
            currentResult -= signedValue;
            // More detailed explanations for subtraction
            if (signedValue >= 0) {
              explanation =
                  'Subtracting a positive number is the same as adding its negative';
            } else {
              explanation =
                  'Subtracting a negative number is the same as adding its positive value';
            }
            break;
          case '×':
            currentResult *= signedValue;
            // More detailed explanations for multiplication
            if ((previousResult >= 0 && signedValue >= 0) ||
                (previousResult < 0 && signedValue < 0)) {
              explanation =
                  'When multiplying numbers with the same sign (both positive or both negative), the result is positive';
            } else {
              explanation =
                  'When multiplying numbers with different signs (one positive, one negative), the result is negative';
            }
            break;
          case '÷':
            if (value != 0) {
              currentResult /= signedValue;
              // More detailed explanations for division
              if ((previousResult >= 0 && signedValue >= 0) ||
                  (previousResult < 0 && signedValue < 0)) {
                explanation =
                    'When dividing numbers with the same sign (both positive or both negative), the result is positive';
              } else {
                explanation =
                    'When dividing numbers with different signs (one positive, one negative), the result is negative';
              }
            } else {
              explanation =
                  'Division by zero is undefined. The result remains unchanged.';
            }
            break;
        }

        steps.add({
          'step': '${term['operator']} $formattedValue',
          'explanation': explanation,
          'result': currentResult,
          'operation': operator,
          'values': [previousResult, signedValue],
        });
      }
    }

    setState(() {
      result = currentResult;
      computationSteps = steps;
      isComputed = true;
      score += 10;
      showBreakdown = true;
    });

    // Start breakdown animation and scroll to it
    _breakdownController.forward(from: 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Find all widgets before the breakdown section
      double offset = 0;
      for (int i = 0; i < terms.length; i++) {
        offset += 100; // Approximate height of each term
      }
      if (!isComputed && terms.length < 5) {
        offset += 70; // Height of add term button
      }
      if (result != null) {
        offset += 100; // Height of result section
      }

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void resetComputation() {
    setState(() {
      // Dispose existing controllers
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers.clear();

      // Reset terms
      terms = [
        {'sign': '+', 'value': ''},
        {'operator': '+', 'sign': '+', 'value': ''},
      ];

      // Create new controllers
      for (var term in terms) {
        _controllers.add(TextEditingController());
      }

      result = null;
      computationSteps = [];
      showBreakdown = false;
      isComputed = false;

      shownFacts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return _buildSplashScreen();
    }

    final screenSize = MediaQuery.of(context).size;
    bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _headerSlideAnimation,
              child: _buildHeader(isSmallScreen),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController, // Add this
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  child: Column(
                    children: [
                      ...terms.asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final isInitialTerm = index < 2;
                          final hasCustomAnimation =
                              _termAnimationControllers.containsKey(index);

                          Widget termWidget = AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: _buildTerm(entry.key, isSmallScreen),
                          );

                          // Apply initial animation only to first two terms
                          if (isInitialTerm) {
                            return ScaleTransition(
                              scale: _termsScaleAnimation,
                              child: termWidget,
                            );
                          }

                          // Apply custom animation to newly added terms
                          if (hasCustomAnimation) {
                            return ScaleTransition(
                              scale:
                                  Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _termAnimationControllers[index]!,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: termWidget,
                            );
                          }

                          return termWidget;
                        },
                      ),
                      if (!isComputed && terms.length < 5)
                        SlideTransition(
                          position: _buttonsSlideAnimation,
                          child: FadeTransition(
                            opacity: _buttonsFadeAnimation,
                            child: _buildAddTermButton(),
                          ),
                        ),
                      if (result != null) _buildResult(),
                      if (showBreakdown)
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _breakdownController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: _breakdownController,
                            child: _buildBreakdown(isSmallScreen),
                          ),
                        ),
                      SlideTransition(
                        position: _buttonsSlideAnimation,
                        child: FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: _buildComputeButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: Center(
        child: AnimatedBuilder(
          animation: _splashAnimationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calculate,
                        size: 100,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Text(
                    'Rules of Signs',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Opacity(
                  opacity: _starAnimation.value,
                  child: const Text(
                    'Learn math interactively',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16.0 : 20.0,
        vertical: isSmallScreen ? 14.0 : 20.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF6C63FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Let's Play with Numbers!",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                    const SizedBox(width: 6),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the rules of signs',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerm(int index, bool isSmallScreen) {
    final term = terms[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (index > 0) _buildOperatorDropdown(index),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSignDropdown(index),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '${_getTermOrdinal(index)} Term',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isComputed,
                      controller: _controllers[index],
                      onChanged: (value) => updateTerm(index, 'value', value),
                    ),
                  ),
                  if (terms.length > 2 && !isComputed)
                    Material(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => deleteTerm(index),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade700,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignDropdown(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEFF),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButton<String>(
        value: terms[index]['sign'],
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
        underline: const SizedBox(),
        elevation: 8,
        isDense: false,
        borderRadius: BorderRadius.circular(12),
        items: signs.map((sign) {
          return DropdownMenuItem<String>(
            value: sign['value'],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: sign['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sign['value'],
                style: TextStyle(
                  color: sign['color'],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: isComputed
            ? null
            : (value) {
                if (value != null) {
                  updateTerm(index, 'sign', value);
                }
              },
      ),
    );
  }

  Widget _buildOperatorDropdown(int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Operation: ",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Theme(
                data: Theme.of(context).copyWith(
                  // This ensures the dropdown menu appears directly below the button
                  popupMenuTheme: PopupMenuThemeData(
                    position: PopupMenuPosition.under,
                  ),
                ),
                child: DropdownButton<String>(
                  value: terms[index]['operator'],
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF6C63FF)),
                  isExpanded: true,
                  elevation: 8,
                  dropdownColor: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  menuMaxHeight: 300,
                  // These properties ensure the dropdown is positioned correctly
                  itemHeight: null,
                  isDense: false,
                  // Make dropdown full width
                  alignment: Alignment.bottomLeft,
                  items: operators.map((operator) {
                    return DropdownMenuItem<String>(
                      value: operator['value'],
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: operator['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${operator['name']} (${operator['value']})",
                          style: TextStyle(
                            color: operator['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: isComputed
                      ? null
                      : (value) {
                          if (value != null) {
                            updateTerm(index, 'operator', value);
                          }
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTermButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: addTerm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECA8C),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0xFF4ECA8C).withOpacity(0.3),
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Add Term',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Text(
                'Result: ${formatNumber(result)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    showBreakdown = !showBreakdown;
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    showBreakdown ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      height: showBreakdown ? null : 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  showBreakdown = !showBreakdown;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Color(0xFFFFAB40),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Computation Breakdown',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: showBreakdown ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  ...computationSteps.asMap().entries.map((entry) {
                    final step = entry.value;
                    final stepNumber = entry.key + 1;
                    String educationalExplanation =
                        _generateEducationalExplanation(step, stepNumber);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: entry.key % 2 == 0
                            ? const Color(0xFFF7FAFF)
                            : const Color(0xFFF4F1FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: entry.key % 2 == 0
                              ? const Color(0xFFE5EDFF)
                              : const Color(0xFFE3DFFF),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6C63FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Step $stepNumber',
                                  style: const TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                step['step'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Educational explanation
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              educationalExplanation,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),

                          // Rules of Signs section
                          if (_shouldShowRuleOfSigns(step))
                            Container(
                              margin: const EdgeInsets.only(top: 8, left: 30),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EDFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.rule,
                                    color: Color(0xFF6C63FF),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getRuleOfSignsExplanation(step),
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Knowledge Check section
                          if (_shouldShowKnowledgeCheck(step))
                            Container(
                              margin: const EdgeInsets.only(top: 8, left: 30),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFFFFAB40),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Did you know? ${_getKnowledgeCheckContent(step)}",
                                      style: const TextStyle(
                                        color: Color(0xFF995500),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Step result
                          if (stepNumber > 1)
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE5EDFF),
                                ),
                              ),
                              child: Text(
                                stepNumber == computationSteps.length
                                    ? 'Final result: ${formatNumber(step['result'])}'
                                    : 'Result so far: ${formatNumber(step['result'])}',
                                style: TextStyle(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      stepNumber == computationSteps.length
                                          ? 24
                                          : 14,
                                ),
                                textAlign: stepNumber == computationSteps.length
                                    ? TextAlign.center
                                    : TextAlign.left,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Summary section
                  if (computationSteps.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF5A54C5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.stars,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Key Math Concepts Used',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _generateSummary(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              crossFadeState: showBreakdown
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputeButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: result == null ? computeResult : resetComputation,
        style: ElevatedButton.styleFrom(
          backgroundColor: result == null
              ? const Color(0xFF6C63FF)
              : const Color(0xFFFFAB40),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shadowColor: result == null
              ? const Color(0xFF6C63FF).withOpacity(0.3)
              : const Color(0xFFFFAB40).withOpacity(0.3),
        ),
        icon: Icon(result == null ? Icons.calculate : Icons.refresh),
        label: Text(
          result == null ? 'Compute' : 'New Computation',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper method to generate more educational explanations
  String _generateEducationalExplanation(
      Map<String, dynamic> step, int stepNumber) {
    final String stepText = step['step'] as String;
    final List<dynamic> values = step['values'] ?? [];
    final double resultValue = step['result'] ?? 0.0;

    String formatNumber(dynamic number) {
      if (number is double) {
        return number % 1 == 0
            ? number.toInt().toString()
            : number.toStringAsFixed(2);
      }
      return number.toString();
    }

    String formatWithParentheses(dynamic number) {
      String formattedNum = formatNumber(number);
      return number < 0 ? "($formattedNum)" : formattedNum;
    }

    if (stepNumber == 1) {
      return "We start with ${formatWithParentheses(values[0])}. In mathematics, we always need a starting point for our calculations.";
    }

    String val1 = formatWithParentheses(values[0]);
    String val2 = formatWithParentheses(values[1]);
    String result = formatWithParentheses(resultValue);

    if (stepText.contains('+')) {
      if (values[1] >= 0) {
        return "When we add a positive number ${val2}, we move to the right on the number line from ${val1}. This gives us ${result}.";
      } else {
        return "When we add a negative number ${val2}, we move to the left on the number line from ${val1}. This gives us ${result}.";
      }
    } else if (stepText.contains('-')) {
      return "Subtracting ${val2} is the same as adding its opposite. So ${val1} - ${val2} is the same as ${val1} + ${formatWithParentheses(-values[1])} = ${result}.";
    } else if (stepText.contains('×')) {
      String explanation =
          "When multiplying ${val1} × ${val2}, we use the sign rules: ";
      if ((values[0] >= 0 && values[1] >= 0) ||
          (values[0] < 0 && values[1] < 0)) {
        explanation +=
            "since both numbers have the same sign, the result ${result} is positive.";
      } else {
        explanation +=
            "since the numbers have different signs, the result ${result} is negative.";
      }
      return explanation;
    } else if (stepText.contains('÷')) {
      if (values[1] == 0) {
        return "Division by zero is undefined. The result remains ${val1}.";
      }
      String explanation =
          "When dividing ${val1} ÷ ${val2}, we use the sign rules: ";
      if ((values[0] >= 0 && values[1] >= 0) ||
          (values[0] < 0 && values[1] < 0)) {
        explanation +=
            "since both numbers have the same sign, the result ${result} is positive.";
      } else {
        explanation +=
            "since the numbers have different signs, the result ${result} is negative.";
      }
      return explanation;
    }

    return step['explanation'] as String;
  }

  // Helper method to check if we should show the rule of signs explanation
  bool _shouldShowRuleOfSigns(Map<String, dynamic> step) {
    final String stepText = step['step'] as String;
    return stepText.contains('×') ||
        stepText.contains('÷') ||
        stepText.contains('-');
  }

  // Helper method to get rule of signs explanation
  String _getRuleOfSignsExplanation(Map<String, dynamic> step) {
    final String stepText = step['step'] as String;
    final List<dynamic> values = step['values'] ?? [];
    double resultValue = step['result'] ?? 0.0;

    // Format numbers to remove decimal if it's a whole number
    String formatNumber(dynamic number) {
      if (number is double) {
        return number % 1 == 0
            ? number.toInt().toString()
            : number.toStringAsFixed(2);
      }
      return number.toString();
    }

    // Add parentheses to negative numbers
    String formatWithParentheses(dynamic number) {
      String formattedNum = formatNumber(number);
      return number < 0 ? "($formattedNum)" : formattedNum;
    }

    String val1 = formatWithParentheses(values[0]);
    String val2 = formatWithParentheses(values[1]);
    String result = formatWithParentheses(resultValue);

    if (stepText.contains('×')) {
      return "Rule applied: Multiplication sign rule\n$val1 × $val2 = $result";
    } else if (stepText.contains('÷')) {
      return "Rule applied: Division sign rule\n$val1 ÷ $val2 = $result";
    } else if (stepText.contains('-')) {
      return "Rule applied: Subtraction as adding the opposite\n$val1 - $val2 = $result";
    } else if (stepText.contains('+')) {
      if (values.any((v) => v < 0)) {
        return "Rule applied: Addition of numbers with different signs\n$val1 + $val2 = $result";
      } else {
        return "Rule applied: Addition of numbers with same signs\n$val1 + $val2 = $result";
      }
    }

    return "";
  }

  // Helper method to determine if we should show a knowledge check
  bool _shouldShowKnowledgeCheck(Map<String, dynamic> step) {
    final String stepText = step['step'] as String;
    final List<dynamic> values = step['values'] ?? [];

    // Get the fact that would be shown
    String potentialFact = _getKnowledgeCheckContent(step);

    // Only show if the fact hasn't been shown before
    if (!shownFacts.contains(potentialFact)) {
      shownFacts.add(potentialFact);
      return true;
    }

    return false;
  }

  // Helper method to get knowledge check content
  String _getKnowledgeCheckContent(Map<String, dynamic> step) {
    final String stepText = step['step'] as String;
    final List<dynamic> values = step['values'] ?? [];

    // Check for specific cases and return relevant facts
    if (values.any((v) => v == 0)) {
      return "Zero is special - it's not positive or negative. It's right in the middle of the number line!";
    }

    if (stepText.contains('×')) {
      if (values.every((v) => v < 0)) {
        return "When you multiply two negative numbers, you get a positive result. Like (-2) × (-3) = 6";
      } else if (values.any((v) => v < 0)) {
        return "Different signs in multiplication (+ × - or - × +) give a negative result";
      } else {
        return "When multiplying or dividing, same signs (+ × + or - × -) give a positive result";
      }
    }

    if (stepText.contains('÷')) {
      if (values[1] == 0) {
        return "Division by zero is undefined! Any number divided by zero has no solution.";
      }
      return values.any((v) => v < 0)
          ? "Different signs in division (+ ÷ - or - ÷ +) give a negative result"
          : "When dividing numbers with the same sign, the result is always positive";
    }

    if (stepText.contains('+')) {
      if (values.every((v) => v < 0)) {
        return "When you add two negative numbers, you get a bigger negative number - like -2 + (-3) = -5";
      } else if (values.any((v) => v < 0)) {
        return "Adding a negative is the same as subtracting! For example: 5 + (-3) is the same as 5 - 3";
      } else {
        return "Think of a number line: positive numbers are to the right of zero, negative numbers are to the left!";
      }
    }

    if (stepText.contains('-')) {
      return "When you subtract a negative number, it's like adding a positive: 5 - (-3) = 5 + 3 = 8";
    }

    return "Just like a thermometer, numbers can go up (positive) or down (negative) from zero.";
  }

// Helper method to generate an overall summary
  String _generateSummary() {
    // Check what operations were used in all steps
    bool additionUsed = false;
    bool subtractionUsed = false;
    bool multiplicationUsed = false;
    bool divisionUsed = false;

    for (var step in computationSteps) {
      final String stepText = step['step'] as String;
      if (stepText.contains('+')) additionUsed = true;
      if (stepText.contains('-')) subtractionUsed = true;
      if (stepText.contains('×')) multiplicationUsed = true;
      if (stepText.contains('÷')) divisionUsed = true;
    }

    // Build a custom summary based on operations used
    List<String> conceptsUsed = [];

    if (additionUsed) {
      conceptsUsed.add("Addition of signed numbers");
    }
    if (subtractionUsed) {
      conceptsUsed.add("Subtraction as adding the opposite");
    }
    if (multiplicationUsed) {
      conceptsUsed.add("Multiplication sign rules");
    }
    if (divisionUsed) {
      conceptsUsed.add("Division sign rules");
    }

    if (conceptsUsed.isEmpty) {
      return "You've explored basic arithmetic operations in this calculation. Great job continuing your math journey!";
    } else {
      return "In this calculation, you've practiced: \n-${conceptsUsed.join("\n-")} \n\nUnderstanding these rules of signs is important for algebra, calculus, and many real-world applications!";
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _breakdownController.dispose();
    _headerAnimationController.dispose();
    _termsAnimationController.dispose();
    _buttonsAnimationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var controller in _termAnimationControllers.values) {
      controller.dispose();
    }
    _splashAnimationController.dispose();
    super.dispose();
  }
}
