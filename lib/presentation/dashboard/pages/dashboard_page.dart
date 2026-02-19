import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../widgets/dashboard_phone_layout.dart';
import '../widgets/dashboard_tablet_layout.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<DashboardBloc>().add(FetchDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      phone: DashboardPhoneLayout(onNavigate: widget.onNavigate),
      tablet: DashboardTabletLayout(onNavigate: widget.onNavigate),
    );
  }
}
