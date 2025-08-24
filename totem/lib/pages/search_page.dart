import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String selectedMuscleGroup = 'Chest';

  final List<String> muscleGroups = [
    'Chest',
    'Triceps',
    'Biceps',
    'Shoulders',
    'Back',
    'Lats',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abs',
    'Core',
  ];

  final Map<String, List<String>> exercises = {
    'Chest': [
      'Push-ups',
      'Bench Press',
      'Incline Press',
      'Chest Flyes',
      'Dips',
    ],
    'Triceps': [
      'Tricep Dips',
      'Close-Grip Push-ups',
      'Overhead Press',
      'Tricep Extensions',
      'Diamond Push-ups',
    ],
    'Biceps': [
      'Bicep Curls',
      'Hammer Curls',
      'Chin-ups',
      'Preacher Curls',
      'Cable Curls',
    ],
    'Shoulders': [
      'Shoulder Press',
      'Lateral Raises',
      'Front Raises',
      'Rear Delt Flyes',
      'Upright Rows',
    ],
    'Back': ['Pull-ups', 'Rows', 'Deadlifts', 'Superman', 'Back Extensions'],
    'Lats': [
      'Pull-ups',
      'Chin-ups',
      'Lat Pulldowns',
      'T-Bar Rows',
      'Cable Rows',
      'Pull-overs',
    ],
    'Quads': [
      'Squats',
      'Lunges',
      'Leg Press',
      'Bulgarian Split Squats',
      'Wall Sits',
    ],
    'Hamstrings': [
      'Romanian Deadlifts',
      'Leg Curls',
      'Good Mornings',
      'Reverse Lunges',
      'Glute Bridges',
    ],
    'Glutes': [
      'Hip Thrusts',
      'Glute Bridges',
      'Squats',
      'Clamshells',
      'Fire Hydrants',
    ],
    'Calves': [
      'Calf Raises',
      'Jump Rope',
      'Wall Sits',
      'Seated Calf Raises',
      'Single-Leg Raises',
    ],
    'Abs': [
      'Crunches',
      'Plank',
      'Russian Twists',
      'Leg Raises',
      'Mountain Climbers',
    ],
    'Core': ['Plank', 'Dead Bug', 'Bird Dog', 'Hollow Body Hold', 'Side Plank'],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muscle Groups Title
            const Text(
              'Filter by Muscle Group',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Muscle Group Dropdown
            GlassContainer(
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMuscleGroup,
                  dropdownColor: Colors.grey.shade800,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedMuscleGroup = newValue;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    }
                  },
                  items: muscleGroups.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _getMuscleGroupIcon(value),
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exercise List with Animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _animation.value)),
                  child: Opacity(
                    opacity: _animation.value,
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getMuscleGroupIcon(selectedMuscleGroup),
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$selectedMuscleGroup Exercises',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...exercises[selectedMuscleGroup]!.map((exercise) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: GlassContainer(
                                borderRadius: 8,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                blur: 6,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        exercise,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade500,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.expand_more;
      case 'triceps':
      case 'biceps':
        return Icons.fitness_center;
      case 'shoulders':
        return Icons.expand_less;
      case 'back':
      case 'lats':
        return Icons.expand_more;
      case 'quads':
      case 'hamstrings':
      case 'glutes':
        return Icons.directions_run;
      case 'calves':
        return Icons.directions_walk;
      case 'abs':
      case 'core':
        return Icons.crop_square;
      default:
        return Icons.fitness_center;
    }
  }
}
