import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: 20),
          // Statistics Overview
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Applications',
                  '156',
                  Icons.assignment,
                  AppColors.primaryRed,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Hire Rate',
                  '23%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg. Time to Hire',
                  '28 days',
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Cost per Hire',
                  '\$4,200',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // Application Funnel Chart
          GlassmorphicContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Funnel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<FunnelData, String>(
                        dataSource: [
                          FunnelData('Applied', 156),
                          FunnelData('Screened', 120),
                          FunnelData('Assessed', 85),
                          FunnelData('Interviewed', 45),
                          FunnelData('Hired', 36),
                        ],
                        xValueMapper: (FunnelData data, _) => data.stage,
                        yValueMapper: (FunnelData data, _) => data.count,
                        color: AppColors.primaryRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Time to Fill by Department
          GlassmorphicContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time to Fill by Department (days)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(minimum: 0, maximum: 60),
                    series: <ChartSeries>[
                      BarSeries<DepartmentData, String>(
                        dataSource: [
                          DepartmentData('Engineering', 42),
                          DepartmentData('Marketing', 28),
                          DepartmentData('Sales', 35),
                          DepartmentData('Operations', 31),
                          DepartmentData('HR', 26),
                        ],
                        xValueMapper: (DepartmentData data, _) =>
                            data.department,
                        yValueMapper: (DepartmentData data, _) => data.days,
                        color: AppColors.accentRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }
}

class FunnelData {
  final String stage;
  final int count;

  FunnelData(this.stage, this.count);
}

class DepartmentData {
  final String department;
  final int days;

  DepartmentData(this.department, this.days);
}
