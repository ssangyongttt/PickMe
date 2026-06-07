import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PickMeApp());
}

class PickMeApp extends StatelessWidget {
  const PickMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickMe',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DecisionPickerPage(),
    );
  }
}

class DecisionPickerPage extends StatefulWidget {
  const DecisionPickerPage({super.key});

  @override
  State<DecisionPickerPage> createState() => _DecisionPickerPageState();
}

class _DecisionPickerPageState extends State<DecisionPickerPage> {
  static const int _maxOptions = 20;
  static const int _maxHistory = 5;
  static const String _historyKey = 'decision_history';

  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();
  final List<String> _options = <String>[];
  final List<String> _history = <String>[];

  String? _selectedOption;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _history
        ..clear()
        ..addAll(preferences.getStringList(_historyKey) ?? <String>[]);
    });
  }

  Future<void> _saveHistory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_historyKey, _history);
  }

  void _addOption() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      _showMessage('선택지를 입력해주세요.');
      return;
    }
    if (_options.length >= _maxOptions) {
      _showMessage('선택지는 최대 $_maxOptions개까지 추가할 수 있어요.');
      return;
    }

    setState(() {
      _options.add(value);
      _controller.clear();
      _selectedOption = null;
    });
  }

  void _removeOption(String option) {
    setState(() {
      _options.remove(option);
      if (_selectedOption == option) {
        _selectedOption = null;
      }
    });
  }

  void _clearOptions() {
    setState(() {
      _options.clear();
      _selectedOption = null;
    });
  }

  void _applyExample(List<String> options) {
    setState(() {
      _options
        ..clear()
        ..addAll(options);
      _selectedOption = null;
      _controller.clear();
    });
  }

  Future<void> _pickOption() async {
    if (_options.length < 2) {
      _showMessage('선택지는 2개 이상 필요해요.');
      return;
    }

    setState(() {
      _isPicking = true;
      _selectedOption = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    final String result = _options[_random.nextInt(_options.length)];

    setState(() {
      _selectedOption = result;
      _isPicking = false;
      _history.remove(result);
      _history.insert(0, result);
      if (_history.length > _maxHistory) {
        _history.removeRange(_maxHistory, _history.length);
      }
    });
    await _saveHistory();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('PickMe'),
            Text('골라줘', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              '선택장애 해결용 랜덤 선택 앱',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '고민되는 선택지를 추가하고 Pick Me 버튼을 눌러보세요.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _InputCard(
              controller: _controller,
              optionCount: _options.length,
              maxOptions: _maxOptions,
              onAdd: _addOption,
            ),
            const SizedBox(height: 16),
            _ExampleSection(onSelect: _applyExample),
            const SizedBox(height: 16),
            _ResultCard(selectedOption: _selectedOption, isPicking: _isPicking),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isPicking ? null : _pickOption,
              icon: _isPicking
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.casino_outlined),
              label: const Text('Pick Me'),
            ),
            const SizedBox(height: 20),
            _OptionList(
              options: _options,
              selectedOption: _selectedOption,
              onRemove: _removeOption,
              onClear: _clearOptions,
            ),
            const SizedBox(height: 20),
            _HistoryList(history: _history),
            const SizedBox(height: 16),
            Text(
              'No login. No ads. No analytics.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.optionCount,
    required this.maxOptions,
    required this.onAdd,
  });

  final TextEditingController controller;
  final int optionCount;
  final int maxOptions;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('선택지 추가', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLength: 30,
                    decoration: const InputDecoration(
                      hintText: '예: 치킨',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) => onAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: onAdd, child: const Text('추가')),
              ],
            ),
            const SizedBox(height: 8),
            Text('$optionCount / $maxOptions'),
          ],
        ),
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  const _ExampleSection({required this.onSelect});

  final ValueChanged<List<String>> onSelect;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> examples = <String, List<String>>{
      '짜장 / 짬뽕': <String>['짜장', '짬뽕'],
      '치킨 / 피자': <String>['치킨', '피자'],
      '영화 / 산책': <String>['영화', '산책'],
      '커피 / 차': <String>['커피', '차'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('빠른 예시', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples.entries
              .map(
                (MapEntry<String, List<String>> entry) => ActionChip(
                  label: Text(entry.key),
                  onPressed: () => onSelect(entry.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.selectedOption, required this.isPicking});

  final String? selectedOption;
  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selectedOption == null
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedOption == null
              ? colorScheme.outlineVariant
              : colorScheme.primary,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Icon(
            selectedOption == null ? Icons.help_outline : Icons.check_circle,
            color: selectedOption == null
                ? colorScheme.onSurfaceVariant
                : colorScheme.primary,
            size: 36,
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              isPicking
                  ? '고르는 중...'
                  : selectedOption == null
                  ? '결과가 여기에 표시됩니다'
                  : '$selectedOption 선택됨',
              key: ValueKey<String>('${isPicking}_$selectedOption'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.selectedOption,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '선택지 목록',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: options.isEmpty ? null : onClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('전체 삭제'),
            ),
          ],
        ),
        if (options.isEmpty)
          const _EmptyCard(message: '아직 선택지가 없어요.')
        else
          ...options.map(
            (String option) => Card(
              color: option == selectedOption
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: ListTile(
                title: Text(option),
                leading: const Icon(Icons.radio_button_unchecked),
                trailing: IconButton(
                  tooltip: '삭제',
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemove(option),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('최근 결과', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const _EmptyCard(message: '최근 결과가 없습니다.')
        else
          ...history.map(
            (String item) => Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text('$item 선택됨'),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
