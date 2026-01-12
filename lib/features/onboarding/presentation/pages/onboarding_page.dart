import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/events/onboarding_event.dart';
import '../bloc/states/onboarding_state.dart';
import '../bloc/onboarding_page_bloc.dart';
import '../bloc/events/onboarding_page_event.dart';
import '../bloc/states/onboarding_page_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => context.read<OnboardingBloc>()..add(const GetOnboardingStatusEvent()),
        ),
        BlocProvider(create: (context) => OnboardingPageBloc()),
      ],
      child: const _OnboardingPageView(),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView();

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.isCompleted) {
              context.go('/login');
            }
          },
          builder: (context, onboardingState) {
            return BlocBuilder<OnboardingPageBloc, OnboardingPageState>(
              builder: (context, pageState) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          context.read<OnboardingPageBloc>().add(OnboardingPageChangedEvent(index));
                        },
                        children: const [
                          _OnboardingStep(
                            title: 'Welcome to Neelo Sewa',
                            description: 'Manage your bus bookings efficiently with our powerful agent app',
                            icon: Icons.directions_bus,
                            gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          _OnboardingStep(
                            title: 'Track in Real-time',
                            description: 'Monitor bus locations and seat availability in real-time',
                            icon: Icons.location_on,
                            gradient: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          _OnboardingStep(
                            title: 'Easy Booking',
                            description: 'Book seats quickly with our intuitive and modern interface',
                            icon: Icons.event_seat,
                            gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                        ],
                      ),
                    ),
                    _PageIndicator(currentPage: pageState.currentPage),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (pageState.currentPage > 0)
                            TextButton.icon(
                              onPressed: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            )
                          else
                            const SizedBox(),
                          ElevatedButton.icon(
                            onPressed: onboardingState.isLoading
                                ? null
                                : () {
                                    if (pageState.currentPage < 2) {
                                      pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      context.read<OnboardingBloc>().add(const CompleteOnboardingEvent());
                                    }
                                  },
                            icon: onboardingState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(pageState.currentPage < 2 ? Icons.arrow_forward : Icons.check),
                            label: Text(pageState.currentPage < 2 ? 'Next' : 'Get Started'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;

  const _PageIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
