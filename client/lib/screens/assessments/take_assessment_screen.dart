import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class TakeAssessmentScreen extends StatefulWidget {
  const TakeAssessmentScreen({super.key});

  @override
  _TakeAssessmentScreenState createState() => _TakeAssessmentScreenState();
}

class _TakeAssessmentScreenState extends State<TakeAssessmentScreen> {
  final PageController _pageController = PageController();
  final List<String> _questions = [
    'What is the time complexity of a binary search algorithm?',
    'Explain the concept of polymorphism in object-oriented programming.',
    'How would you handle a memory leak in a Python application?',
    'Describe the difference between TCP and UDP protocols.',
    'What are the advantages of using a relational database over a NoSQL database?',
  ];
  final List<List<String>> _options = [
    ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
    [
      'Ability to take many forms',
      'Inheritance of properties',
      'Data encapsulation',
      'Method overloading',
    ],
    [
      'Use garbage collection',
      'Implement reference counting',
      'Use context managers',
      'All of the above',
    ],
    [
      'TCP is connection-oriented, UDP is connectionless',
      'TCP is faster, UDP is more reliable',
      'TCP is for video, UDP is for text',
      'TCP uses less bandwidth than UDP',
    ],
    [
      'Better scalability',
      'Stronger consistency',
      'Flexible schema',
      'Faster writes',
    ],
  ];
  final List<int> _correctAnswers = [1, 0, 3, 0, 1];
  final List<int> _selectedAnswers = List.filled(5, -1);

  int _currentPage = 0;
  int _timeRemaining = 2700; // 45 minutes in seconds
  bool _assessmentStarted = false;
  bool _assessmentCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if (_assessmentStarted && !_assessmentCompleted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _timeRemaining > 0) {
          setState(() {
            _timeRemaining--;
          });
          _startTimer();
        } else if (_timeRemaining == 0) {
          _completeAssessment();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical Assessment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_assessmentStarted && !_assessmentCompleted)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
        ],
      ),
      body: _assessmentCompleted
          ? _buildResultsScreen()
          : _assessmentStarted
          ? _buildAssessmentScreen()
          : _buildIntroductionScreen(),
    );
  }

  Widget _buildIntroductionScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassmorphicContainer(
            child: Column(
              children: [
                Icon(Icons.quiz, size: 60, color: AppColors.primaryRed),
                const SizedBox(height: 20),
                Text(
                  'Technical Skills Assessment',
                  style: AppTextStyles.glassTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  'This assessment will test your knowledge in various technical areas. You will have 45 minutes to complete 5 questions.',
                  style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildInstructionItem('45 minutes time limit'),
                _buildInstructionItem('5 multiple-choice questions'),
                _buildInstructionItem('No going back to previous questions'),
                _buildInstructionItem('70% passing score required'),
                const SizedBox(height: 30),
                GradientButton(
                  text: 'Start Assessment',
                  onPressed: () {
                    setState(() {
                      _assessmentStarted = true;
                    });
                    _startTimer();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentScreen() {
    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentPage + 1) / _questions.length,
          backgroundColor: AppColors.lightGray,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
        ),
        // Questions
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: GlassmorphicContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1} of ${_questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _questions[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: _options[index].asMap().entries.map((entry) {
                          final optionIndex = entry.key;
                          final optionText = entry.value;
                          return _buildOptionButton(
                            optionIndex,
                            optionText,
                            index,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      if (index == _questions.length - 1)
                        GradientButton(
                          text: 'Submit Assessment',
                          onPressed: () {
                            if (_selectedAnswers[index] != -1) {
                              _completeAssessment();
                            }
                          },
                        )
                      else
                        GradientButton(
                          text: 'Next Question',
                          onPressed: () {
                            if (_selectedAnswers[index] != -1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final correctAnswers = _calculateScore();
    final score = (correctAnswers / _questions.length) * 100;
    final passed = score >= 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassmorphicContainer(
            child: Column(
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: passed ? Colors.green : AppColors.primaryRed,
                ),
                const SizedBox(height: 20),
                Text(
                  passed ? 'Assessment Passed!' : 'Assessment Failed',
                  style: AppTextStyles.glassTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your score: ${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 24),
                _buildResultItem(
                  'Total Questions',
                  _questions.length.toString(),
                ),
                _buildResultItem('Correct Answers', '$correctAnswers'),
                _buildResultItem(
                  'Time Taken',
                  '${45 - (_timeRemaining ~/ 60)} minutes',
                ),
                _buildResultItem('Passing Score', '70%'),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryRed, // ✅ updated
                          side: BorderSide(color: AppColors.primaryRed),
                        ),
                        child: const Text('Back to Dashboard'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed, // ✅ updated
                          foregroundColor: Colors.white, // ✅ updated
                        ),
                        child: const Text('Review Answers'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryRed, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    int optionIndex,
    String optionText,
    int questionIndex,
  ) {
    final isSelected = _selectedAnswers[questionIndex] == optionIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedAnswers[questionIndex] = optionIndex;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryRed
              : Colors.white, // ✅ updated
          foregroundColor: isSelected
              ? Colors.white
              : AppColors.darkText, // ✅ updated
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.lightGray),
          ),
        ),
        child: Text(optionText),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _correctAnswers[i]) {
        correct++;
      }
    }
    return correct;
  }

  void _completeAssessment() {
    setState(() {
      _assessmentCompleted = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
