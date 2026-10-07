import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ScrollController _scrollController = ScrollController();
  final double _monthTileHeight =
      380; // fixed height per month for predictable scrolling

  final List<String> _monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<int> _monthDays = const [
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  final List<String> _notifications = [];
  final List<String> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  late final DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int monthIndex = _now.month - 1;
      final double offset = monthIndex * _monthTileHeight;
      _scrollController.jumpTo(offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addNotification() {
    setState(() {
      _notifications.add(
        'Important event at ${TimeOfDay.now().format(context)}',
      );
    });
  }

  void _addTask(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _tasks.add(text.trim());
      _taskController.clear();
    });
  }

  Widget _buildNotificationBar() {
    return Container(
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: _notifications.isEmpty
                ? const Text('No notifications')
                : Text(_notifications.join(' • ')),
          ),
          TextButton(onPressed: _addNotification, child: const Text('Add')),
        ],
      ),
    );
  }

  Widget _buildTaskBar() {
    return Container(
      color: Colors.blueGrey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: 'Add task',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onSubmitted: _addTask,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addTask(_taskController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (_tasks.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _tasks
            .map(
              (t) => Row(
                children: [
                  const Icon(Icons.check_box_outline_blank, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonthTile(int index) {
    final String name = _monthNames[index];
    final int days = _monthDays[index];
    final bool isCurrentMonth = (index + 1) == _now.month;

    return SizedBox(
      height: _monthTileHeight,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCurrentMonth)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(days, (i) {
                      final int day = i + 1;
                      final bool isToday = isCurrentMonth && day == _now.day;
                      return Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.black87,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNotificationBar(),
          _buildTasksList(),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 12,
                itemBuilder: (context, index) => _buildMonthTile(index),
              ),
            ),
          ),
          _buildTaskBar(),
        ],
      ),
    );
  }
}
