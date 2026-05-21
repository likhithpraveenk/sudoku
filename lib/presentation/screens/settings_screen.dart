// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sudoku/presentation/shared/grid_placement.dart';
// import 'package:sudoku/providers/settings_provider.dart';

// class SettingsScreen extends ConsumerStatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends ConsumerState<SettingsScreen> {
//   double _gridWidth = 320;
//   double _hSpacing = 8;
//   double _vSpacing = 8;
//   GridPlacement _placement = GridPlacement.left;

//   @override
//   void initState() {
//     super.initState();
//     final svc = ref.read(settingsServiceProvider);
//     _gridWidth = svc.gridWidth;
//     _hSpacing = svc.horizontalSpacing;
//     _vSpacing = svc.verticalSpacing;
//     _placement = svc.placement;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final svc = ref.watch(settingsServiceProvider);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         padding: const EdgeInsets.all(8),
//         children: [
//           Container(
//             height: 180,
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               border: Border.all(color: Theme.of(context).colorScheme.outline),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: _buildLayoutPreview(),
//           ),
//           SwitchListTile(
//             title: const Text('Show remaining counts'),
//             value: svc.showRemaining,
//             onChanged: (v) async {
//               await svc.setShowRemaining(value: v);
//               ref.invalidate(settingsServiceProvider);
//             },
//           ),
//           SwitchListTile(
//             title: const Text('Show timer'),
//             value: svc.showTimer,
//             onChanged: (v) async {
//               await svc.setShowTimer(value: v);
//               ref.invalidate(settingsServiceProvider);
//             },
//           ),
//           const Divider(),
//           ListTile(
//             title: const Text('Grid width'),
//             subtitle: Slider(
//               value: _gridWidth.clamp(200, 520),
//               min: 200,
//               max: 520,
//               onChanged: (v) => setState(() => _gridWidth = v),
//               onChangeEnd: (v) async {
//                 await svc.setGridWidth(value: v);
//                 ref.invalidate(settingsServiceProvider);
//               },
//             ),
//           ),
//           ListTile(
//             title: const Text('Horizontal spacing'),
//             subtitle: Slider(
//               value: _hSpacing.clamp(0, 48),
//               max: 48,
//               onChanged: (v) => setState(() => _hSpacing = v),
//               onChangeEnd: (v) async {
//                 await svc.setHorizontalSpacing(value: v);
//                 ref.invalidate(settingsServiceProvider);
//               },
//             ),
//           ),
//           ListTile(
//             title: const Text('Vertical spacing'),
//             subtitle: Slider(
//               value: _vSpacing.clamp(0, 48),
//               max: 48,
//               onChanged: (v) => setState(() => _vSpacing = v),
//               onChangeEnd: (v) async {
//                 await svc.setVerticalSpacing(value: v);
//                 ref.invalidate(settingsServiceProvider);
//               },
//             ),
//           ),
//           ListTile(
//             title: const Text('Grid placement'),
//             subtitle: DropdownButton<GridPlacement>(
//               value: _placement,
//               items: GridPlacement.values
//                   .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
//                   .toList(),
//               onChanged: (p) async {
//                 if (p != null) {
//                   setState(() => _placement = p);
//                   await svc.setPlacement(p);
//                   ref.invalidate(settingsServiceProvider);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLayoutPreview() {
//     final cs = Theme.of(context).colorScheme;
//     final gridBox = Container(
//       margin: EdgeInsets.all(_hSpacing / 4),
//       decoration: BoxDecoration(
//         color: cs.primaryContainer,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: cs.primary),
//       ),
//       child: const Center(child: Text('GRID', style: TextStyle(fontSize: 10))),
//     );
//     final ctrlBox = Container(
//       margin: EdgeInsets.all(_hSpacing / 4),
//       decoration: BoxDecoration(
//         color: cs.secondaryContainer,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: cs.secondary),
//       ),
//       child: const Center(child: Text('CTRL', style: TextStyle(fontSize: 10))),
//     );
//     final isHorizontal = _placement == .left || _placement == .right;
//     final main = isHorizontal
//         ? Row(
//             children: [
//               if (_placement == .left)
//                 Expanded(child: gridBox)
//               else
//                 Expanded(child: ctrlBox),
//               SizedBox(width: _hSpacing),
//               if (_placement == .left)
//                 Expanded(child: ctrlBox)
//               else
//                 Expanded(child: gridBox),
//             ],
//           )
//         : Column(
//             children: [
//               if (_placement == .top)
//                 Expanded(child: gridBox)
//               else
//                 Expanded(child: ctrlBox),
//               SizedBox(height: _vSpacing),
//               if (_placement == .top)
//                 Expanded(child: ctrlBox)
//               else
//                 Expanded(child: gridBox),
//             ],
//           );
//     return Padding(padding: const .all(12), child: main);
//   }
// }
