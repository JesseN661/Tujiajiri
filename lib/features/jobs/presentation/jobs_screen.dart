import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/job_repository.dart';
import '../models/job.dart';
import '../state/job_search_controller.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const List<String> employmentTypes = [
    'All',
    'Internship',
    'Full-time',
    'Part-time',
    'Contract',
  ];

  @override
  Widget build(BuildContext context) {
    final repository = JobRepository();
    final controller = context.watch<JobSearchController>();

    final searchQuery = controller.searchQuery.trim().toLowerCase();
    final selectedType = controller.selectedEmploymentType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        actions: [
          if (searchQuery.isNotEmpty || selectedType != 'All')
            IconButton(
              tooltip: 'Clear search and filters',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: controller.clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search jobs, skills, or locations',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: repository.watchPublishedJobs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Unable to load jobs. Please check your '
                        'connection and Firebase permissions.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allJobs = snapshot.data ?? [];

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

                if (jobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        allJobs.isEmpty
                            ? 'No jobs are available right now.'
                            : 'No jobs match your search and filters. '
                                  'Try another keyword or select All.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: jobs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];

                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(job: job),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          job.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.employerName),
                              const SizedBox(height: 4),
                              Text(job.location),
                              const SizedBox(height: 4),
                              Text(job.employmentType),
                              if (job.isVerified) ...[
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text('Verified employer'),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
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
}
