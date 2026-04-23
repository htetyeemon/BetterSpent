import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (context) => _AppDateRangePickerDialog(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    ),
  );
}

class _AppDateRangePickerDialog extends StatefulWidget {
  const _AppDateRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    required this.initialDateRange,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialDateRange;

  @override
  State<_AppDateRangePickerDialog> createState() =>
      _AppDateRangePickerDialogState();
}

class _AppDateRangePickerDialogState extends State<_AppDateRangePickerDialog> {
  DateTime? _start;
  DateTime? _end;

  late int _displayYear;
  late int _displayMonth;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateRange?.start ?? widget.lastDate;
    _start = widget.initialDateRange?.start;
    _end = widget.initialDateRange?.end;
    _displayYear = initial.year;
    _displayMonth = initial.month;
  }

  List<int> get _years {
    final years = <int>[];
    for (var y = widget.firstDate.year; y <= widget.lastDate.year; y++) {
      years.add(y);
    }
    return years;
  }

  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSelectable(DateTime day) {
    return !day.isBefore(_dateOnly(widget.firstDate)) &&
        !day.isAfter(_dateOnly(widget.lastDate));
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _onDayTapped(DateTime day) {
    if (!_isSelectable(day)) return;
    final normalized = _dateOnly(day);

    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = normalized;
        _end = null;
        return;
      }

      if (_end == null) {
        final start = _start!;
        if (normalized.isBefore(start)) {
          _start = normalized;
        } else {
          _end = normalized;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final background = AppColors.surface;
    return Dialog(
      backgroundColor: background,
      insetPadding: const EdgeInsets.all(AppConstants.spacingLg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.spacingMd),
            _buildMonthYearRow(),
            const SizedBox(height: AppConstants.spacingMd),
            _buildWeekdayHeader(),
            const SizedBox(height: AppConstants.spacingSm),
            _buildCalendarGrid(),
            const SizedBox(height: AppConstants.spacingMd),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Select date range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Clear',
          onPressed: () => setState(() {
            _start = null;
            _end = null;
          }),
          icon: const Icon(Icons.backspace_outlined),
          color: AppColors.textSecondary,
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMonthYearRow() {
    return Row(
      children: [
        Expanded(
          child: _Dropdown<int>(
            value: _displayMonth,
            items: List.generate(
              12,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_monthLabels[i]),
              ),
            ),
            onChanged: (m) {
              if (m == null) return;
              setState(() => _displayMonth = m);
            },
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: _Dropdown<int>(
            value: _displayYear,
            items: _years
                .map(
                  (y) => DropdownMenuItem(
                    value: y,
                    child: Text('$y'),
                  ),
                )
                .toList(),
            onChanged: (y) {
              if (y == null) return;
              setState(() => _displayYear = y);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdayLabels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstOfMonth = DateTime(_displayYear, _displayMonth, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_displayYear, _displayMonth);
    final offset = firstOfMonth.weekday - DateTime.monday; // Monday-start
    final totalCells = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppConstants.spacingXs,
        crossAxisSpacing: AppConstants.spacingXs,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - offset + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = DateTime(_displayYear, _displayMonth, dayNumber);
        final selectable = _isSelectable(day);

        final start = _start;
        final end = _end;

        final isStart = start != null && _isSameDay(day, start);
        final isEnd = end != null && _isSameDay(day, end);
        final isInRange = start != null &&
            end != null &&
            !day.isBefore(start) &&
            !day.isAfter(end);

        final bool isSelected = isStart || isEnd;

        Color backgroundColor = Colors.transparent;
        if (isSelected) {
          backgroundColor = AppColors.primary;
        } else if (isInRange) {
          backgroundColor = AppColors.primary.withOpacity(0.18);
        }

        final textColor = !selectable
            ? AppColors.textSecondary.withOpacity(0.5)
            : (isSelected ? Colors.black : AppColors.textPrimary);

        return InkWell(
          onTap: selectable ? () => _onDayTapped(day) : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canApply = _start != null;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.borderLight),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingSm,
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: ElevatedButton(
            onPressed: !canApply
                ? null
                : () {
                    final start = _start!;
                    final end = _end ?? start;
                    Navigator.of(context).pop(DateTimeRange(start: start, end: end));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.borderDark,
              disabledForegroundColor:
                  AppColors.textSecondary.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingSm,
              ),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceLight,
          iconEnabledColor: AppColors.textPrimary,
          style: const TextStyle(color: AppColors.textPrimary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
