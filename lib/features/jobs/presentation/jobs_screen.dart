import '../../auth/presentation/bloc/auth_cubit.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/job_repository.dart';
import '../domain/entities/job.dart';
import 'job_details_screen.dart';
import 'job_form_screen.dart';
import 'state/job_search_controller.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, this.canPostJobs = false});

  final bool canPostJobs;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  static const List<String> employmentTypes = [
    'All',
    'Internship',
    'Full-time',
    'Part-time',
    'Contract',
  ];

  final JobRepository _repository = JobRepository();
  final TextEditingController _searchTextController = TextEditingController();

  void _clearFilters() {
    _searchTextController.clear();
    context.read<JobSearchController>().clearFilters();
  }

  void _postJob() {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobFormScreen(
          employerId: user.uid,
          employerName: user.displayName.isEmpty
              ? user.email
              : user.displayName,
          repository: _repository,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<JobSearchController>();

    final searchQuery = controller.searchQuery.trim().toLowerCase();
    final selectedType = controller.selectedEmploymentType;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
          if (searchQuery.isNotEmpty || selectedType != 'All')
            IconButton(
              tooltip: 'Clear search and filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilters,
            ),
        ],
      ),
      floatingActionButton: widget.canPostJobs
          ? FloatingActionButton.extended(
              onPressed: _postJob,
              icon: const Icon(Icons.add),
              label: const Text('Post a job'),
            )
          : null,
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchTextController,
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search jobs, skills, or locations',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Employment type filters
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: employmentTypes.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = employmentTypes[index];
                final isSelected = selectedType == type;

                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.updateEmploymentType(type);
                  },
                );
              },
            ),
          ),

          // Jobs loaded from Firestore
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: _repository.watchPublishedJobs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Unable to load jobs.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check your internet connection and '
                            'Firebase permissions, then try again.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allJobs = snapshot.data ?? [];

                // Apply search and employment type filters.
                final jobs = allJobs.where((job) {
                  final matchesSearch =
                      searchQuery.isEmpty ||
                      job.title.toLowerCase().contains(searchQuery) ||
                      job.employerName.toLowerCase().contains(searchQuery) ||
                      job.location.toLowerCase().contains(searchQuery) ||
                      job.employmentType.toLowerCase().contains(searchQuery) ||
                      job.experienceLevel.toLowerCase().contains(searchQuery) ||
                      job.requiredSkills.any(
                        (skill) => skill.toLowerCase().contains(searchQuery),
                      );

                  final matchesType =
                      selectedType == 'All' ||
                      job.employmentType.toLowerCase() ==
                          selectedType.toLowerCase();

                  return matchesSearch && matchesType;
                }).toList();

                // Empty state
                if (jobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 52,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allJobs.isEmpty
                                ? 'No jobs available yet'
                                : 'No matching jobs found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            allJobs.isEmpty
                                ? 'Please check back later for new '
                                      'opportunities.'
                                : 'Try a different keyword or change '
                                      'your employment filter.',
                            textAlign: TextAlign.center,
                          ),
                          if (allJobs.isNotEmpty &&
                              (searchQuery.isNotEmpty ||
                                  selectedType != 'All')) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Job listing cards
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: jobs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(
                                job: job,
                                repository: _repository,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Job title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      job.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Employer name
                              Text(
                                job.employerName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),

                              const SizedBox(height: 12),

                              // Location and employment type
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _jobInfo(
                                    Icons.location_on_outlined,
                                    job.location,
                                  ),
                                  _jobInfo(
                                    Icons.work_outline,
                                    job.employmentType,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Experience level
                              _jobInfo(
                                Icons.school_outlined,
                                job.experienceLevel,
                              ),

                              // Required skills preview
                              if (job.requiredSkills.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  'Required skills',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: job.requiredSkills
                                      .take(3)
                                      .map(
                                        (skill) => Chip(
                                          label: Text(skill),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.zero,
                                        ),
                                      )
                                      .toList(),
                                ),
                                if (job.requiredSkills.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '+${job.requiredSkills.length - 3} '
                                      'more skills',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade700,
                                          ),
                                    ),
                                  ),
                              ],

                              // Verified employer badge
                              if (job.isVerified) ...[
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Verified employer',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable layout for job information.
  Widget _jobInfo(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 5),
        Flexible(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
