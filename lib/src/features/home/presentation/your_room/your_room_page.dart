import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/room_item_entity.dart';

/// {@template deskdoodles.features.home.presentation.your_room.your_room_page}
/// Showcase the current user's personalized room with quick actions.
/// {@endtemplate}
@RoutePage(deferredLoading: true)
class YourRoomPage extends ConsumerStatefulWidget {
  /// {@macro deskdoodles.features.home.presentation.your_room.your_room_page}
  ///
  /// Construct a new [YourRoomPage] widget.
  const YourRoomPage({super.key});

  static const double _roomAspectRatio = 9 / 16;

  static const _items = [
    RoomItem(
      id: 'stringLights',
      assetName: 'assets/your_room/string-light-on.png',
      defaultPosition: Offset(0.5, 0.08),
      widthFactor: 0.92,
      anchor: Alignment.topCenter,
      semanticLabel: 'String lights hanging across the ceiling.',
    ),
    RoomItem(
      id: 'window',
      assetName: 'assets/your_room/window.png',
      defaultPosition: Offset(0.2, 0.32),
      widthFactor: 0.28,
      anchor: Alignment.topCenter,
      semanticLabel: 'Window looking out into the night sky.',
    ),
    RoomItem(
      id: 'clock',
      assetName: 'assets/your_room/clock.png',
      defaultPosition: Offset(0.78, 0.28),
      widthFactor: 0.16,
      anchor: Alignment.topCenter,
      semanticLabel: 'Wall clock showing the current time.',
    ),
    RoomItem(
      id: 'poster',
      assetName: 'assets/your_room/poster.png',
      defaultPosition: Offset(0.78, 0.48),
      widthFactor: 0.18,
      anchor: Alignment.topCenter,
      semanticLabel: 'Framed poster of friends.',
    ),
    RoomItem(
      id: 'dresser',
      assetName: 'assets/your_room/dresser.png',
      defaultPosition: Offset(0.23, 0.78),
      widthFactor: 0.38,
      anchor: Alignment.bottomCenter,
      semanticLabel: 'Wooden dresser with drawers.',
    ),
    RoomItem(
      id: 'lamp',
      assetName: 'assets/your_room/lamp.png',
      defaultPosition: Offset(0.18, 0.58),
      widthFactor: 0.16,
      anchor: Alignment.bottomCenter,
      semanticLabel: 'Bedside lamp glowing warmly.',
    ),
    RoomItem(
      id: 'radio',
      assetName: 'assets/your_room/radio.png',
      defaultPosition: Offset(0.29, 0.61),
      widthFactor: 0.14,
      anchor: Alignment.bottomCenter,
      semanticLabel: 'Little radio for tunes.',
    ),
    RoomItem(
      id: 'chair',
      assetName: 'assets/your_room/chair.png',
      defaultPosition: Offset(0.68, 0.82),
      widthFactor: 0.32,
      anchor: Alignment.bottomCenter,
      semanticLabel: 'Super comfy red chair.',
    ),
  ];

  @override
  ConsumerState<YourRoomPage> createState() => _YourRoomPageState();
}

class _YourRoomPageState extends ConsumerState<YourRoomPage> {
  late Map<String, Offset> _positions;
  late Map<String, double> _scales;
  String? _selectedItemId;
  final _contentBounds = <String, Rect>{};
  var _currentHitRects = <String, Rect>{};
  var _hitOrder = <String>[];
  final _assetKeys = <String, GlobalKey<_InteractiveRoomAssetState>>{};
  var _currentLayouts = <String, RoomItemLayout>{};

  @override
  void initState() {
    super.initState();
    developer.log('YourRoomPage initState', name: 'yourRoom');
    _positions = {
      for (final item in YourRoomPage._items) item.id: item.defaultPosition,
    };
    _scales = {
      for (final item in YourRoomPage._items) item.id: 1,
    };
  }

  void _updateContentBounds(String id, Rect bounds) {
    final current = _contentBounds[id];
    if (current != null && _rectsClose(current, bounds)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _contentBounds[id] = bounds);
    });
  }

  bool _rectsClose(Rect a, Rect b, [double epsilon = 0.001]) {
    return (a.left - b.left).abs() < epsilon &&
        (a.top - b.top).abs() < epsilon &&
        (a.width - b.width).abs() < epsilon &&
        (a.height - b.height).abs() < epsilon;
  }

  void _updatePosition(String id, Offset newPosition) {
    const slack = 0.5;
    final clamped = Offset(
      newPosition.dx.clamp(-slack, 1 + slack),
      newPosition.dy.clamp(-slack, 1 + slack),
    );

    setState(() {
      _positions = Map<String, Offset>.from(_positions)..[id] = clamped;
    });
  }

  void _updateScale(String id, double scale) {
    final clamped = scale.clamp(
      _InteractiveRoomAsset.minScale,
      _InteractiveRoomAsset.maxScale,
    );

    setState(() {
      _scales = Map<String, double>.from(_scales)..[id] = clamped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomSize = _resolveRoomSize(
            constraints,
            MediaQuery.sizeOf(context),
          );
          final floorHeight = roomSize.height * 0.18;
          final availableSize = constraints.biggest;
          final originX = availableSize.width.isFinite
              ? (availableSize.width - roomSize.width) / 2
              : 0.0;
          final originY = availableSize.height.isFinite
              ? (availableSize.height - roomSize.height) / 2
              : 0.0;
          final roomOrigin = Offset(originX, originY);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              final position = details.localPosition;
              final insideRoom = position.dx >= roomOrigin.dx &&
                  position.dy >= roomOrigin.dy &&
                  position.dx <= roomOrigin.dx + roomSize.width &&
                  position.dy <= roomOrigin.dy + roomSize.height;

              if (insideRoom) {
                _handleTap(position - roomOrigin);
              } else {
                _clearSelection();
              }
            },
            child: Stack(
              children: [
                Positioned(
                  left: roomOrigin.dx,
                  top: roomOrigin.dy,
                  width: roomSize.width,
                  height: roomSize.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF8E6CE),
                              Color(0xFF173E96),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: floorHeight,
                        child: const SizedBox(
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFF2F1B0F),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: floorHeight,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF5F3A1B),
                          ),
                        ),
                      ),
                      ..._buildRoomItems(roomSize),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildRoomItems(Size roomSize) {
    final widgets = <Widget>[];
    final hitRects = <String, Rect>{};
    final layouts = <String, RoomItemLayout>{};
    final order = <String>[];

    for (final item in YourRoomPage._items) {
      final normalizedPosition = _positions[item.id] ?? item.defaultPosition;
      final scale = _scales[item.id] ?? 1;
      final layout = item.layoutFor(
        availableSize: roomSize,
        normalizedPosition: normalizedPosition,
        scale: scale,
      );
      final boundsRect = _contentBounds[item.id];
      final resolvedRect =
          (boundsRect != null && boundsRect.width > 0 && boundsRect.height > 0)
          ? boundsRect
          : Rect.fromLTWH(0, 0, layout.size.width, layout.size.height);
      final contentTopLeft = layout.topLeft + resolvedRect.topLeft;
      final effectiveContentSize = resolvedRect.size;
      final hitRect = Rect.fromLTWH(
        contentTopLeft.dx,
        contentTopLeft.dy,
        effectiveContentSize.width,
        effectiveContentSize.height,
      );
      hitRects[item.id] = hitRect;
      order.add(item.id);

      final assetKey = _assetKeys.putIfAbsent(
        item.id,
        GlobalKey<_InteractiveRoomAssetState>.new,
      );

      void handleBounds(Rect bounds) => _updateContentBounds(item.id, bounds);

      widgets.add(
        Positioned(
          left: layout.topLeft.dx,
          top: layout.topLeft.dy,
          child: SizedBox(
            width: layout.size.width,
            height: layout.size.height,
            child: _InteractiveRoomAsset(
              key: assetKey,
              item: item,
              layout: layout,
              normalizedPosition: normalizedPosition,
              scale: scale,
              roomSize: roomSize,
              onSelected: () {
                developer.log(
                  'item tapped',
                  name: 'yourRoom.selection',
                  error: item.id,
                );
                setState(() => _selectedItemId = item.id);
              },
              onPositionChanged: (updatedPosition) =>
                  _updatePosition(item.id, updatedPosition),
              onScaleChanged: (updatedScale) =>
                  _updateScale(item.id, updatedScale),
              onContentBoundsChanged: handleBounds,
            ),
          ),
        ),
      );

      if (_selectedItemId == item.id) {
        widgets.add(
          Positioned(
            left: contentTopLeft.dx - _SelectionFrame.padding.left,
            top: contentTopLeft.dy - _SelectionFrame.padding.top,
            width:
                effectiveContentSize.width + _SelectionFrame.padding.horizontal,
            height:
                effectiveContentSize.height + _SelectionFrame.padding.vertical,
            child: _SelectionFrame(
              item: item,
              layout: layout,
              roomSize: roomSize,
              currentScale: scale,
              contentSize: effectiveContentSize,
              onScaleChanged: (value) => _updateScale(item.id, value),
              onPositionChanged: (updatedPosition) =>
                  _updatePosition(item.id, updatedPosition),
              onEnsureSelected: () => setState(() => _selectedItemId = item.id),
            ),
          ),
        );
      }

      layouts[item.id] = layout;
    }

    _currentHitRects = hitRects;
    _hitOrder = order;
    _currentLayouts = layouts;
    return widgets;
  }

  void _handleTap(Offset localPosition) {
    for (final id in _hitOrder.reversed) {
      final rect = _currentHitRects[id];
      if (rect == null || !rect.contains(localPosition)) continue;

      final layout = _currentLayouts[id];
      final state = _assetKeys[id]?.currentState;

      if (layout != null && state != null) {
        final local = localPosition - layout.topLeft;
        if (!state.hitTestLocal(local)) {
          continue;
        }
      }

      if (_selectedItemId != id) {
        setState(() => _selectedItemId = id);
      }
      return;
    }

    _clearSelection();
  }

  void _clearSelection() {
    if (_selectedItemId == null) return;
    setState(() => _selectedItemId = null);
  }
}

Size _resolveRoomSize(BoxConstraints constraints, Size fallbackSize) {
  const ratio = YourRoomPage._roomAspectRatio;
  final fallbackWidth = fallbackSize.width.isFinite && fallbackSize.width > 0
      ? fallbackSize.width
      : 360.0;
  final fallbackHeight = fallbackWidth / ratio;

  var maxWidth = constraints.hasBoundedWidth
      ? constraints.maxWidth
      : fallbackWidth;
  var maxHeight = constraints.hasBoundedHeight
      ? constraints.maxHeight
      : fallbackHeight;

  if (!maxWidth.isFinite || maxWidth <= 0) {
    maxWidth = fallbackWidth;
  }

  if (!maxHeight.isFinite || maxHeight <= 0) {
    maxHeight = fallbackHeight;
  }

  var width = maxWidth;
  var height = width / ratio;

  if (height > maxHeight) {
    height = maxHeight;
    width = height * ratio;
  }

  if (width <= 0 || height <= 0) {
    width = fallbackWidth;
    height = fallbackHeight;
  }

  return Size(width, height);
}

class _SelectionFrame extends StatefulWidget {
  const _SelectionFrame({
    required this.item,
    required this.layout,
    required this.contentSize,
    required this.roomSize,
    required this.currentScale,
    required this.onScaleChanged,
    required this.onPositionChanged,
    required this.onEnsureSelected,
  });

  static const double handleSize = 28;
  static const double horizontalPadding = handleSize * 0.6;
  static const double topPadding = handleSize * 1.6;
  static const double bottomPadding = handleSize * 1.0;
  static const padding = EdgeInsets.only(
    left: horizontalPadding,
    right: horizontalPadding,
    top: topPadding,
    bottom: bottomPadding,
  );

  final RoomItem item;
  final RoomItemLayout layout;
  final Size contentSize;
  final Size roomSize;
  final double currentScale;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onEnsureSelected;

  @override
  State<_SelectionFrame> createState() => _SelectionFrameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('itemId', item.id))
      ..add(DoubleProperty('currentScale', currentScale))
      ..add(DiagnosticsProperty<Size>('layoutSize', layout.size))
      ..add(DiagnosticsProperty<Size>('contentSize', contentSize))
      ..add(DiagnosticsProperty<Size>('roomSize', roomSize))
      ..add(
        ObjectFlagProperty<ValueChanged<double>>.has(
          'onScaleChanged',
          onScaleChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<Offset>>.has(
          'onPositionChanged',
          onPositionChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<VoidCallback>.has(
          'onEnsureSelected',
          onEnsureSelected,
        ),
      );
  }
}

class _SelectionFrameState extends State<_SelectionFrame> {
  static const double _handleSize = _SelectionFrame.handleSize;

  var _dragging = false;
  var _resizing = false;

  late Offset _dragAnchorWorldOrigin;
  Offset _dragAnchorDelta = Offset.zero;

  late double _initialScale;
  late double _initialWidth;
  late double _initialHeight;
  late double _baseWidth;
  late double _baseHeight;
  late Offset _initialTopLeft;
  Offset _resizeAccumulated = Offset.zero;

  @override
  void initState() {
    super.initState();
    _syncBaseValues();
  }

  @override
  void didUpdateWidget(covariant _SelectionFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging) {
      _dragAnchorWorldOrigin = widget.layout.anchorWorld;
      _initialTopLeft = widget.layout.topLeft;
      _dragAnchorDelta = Offset.zero;
    }
    if (!_resizing) {
      _initialScale = widget.currentScale;
      _initialWidth = widget.layout.size.width;
      _initialHeight = widget.layout.size.height;
      final safeScale = _initialScale == 0 ? 1.0 : _initialScale;
      _baseWidth = _initialWidth / safeScale;
      _baseHeight = _initialHeight / safeScale;
      _resizeAccumulated = Offset.zero;
    }
  }

  void _syncBaseValues() {
    _dragAnchorWorldOrigin = widget.layout.anchorWorld;
    _initialScale = widget.currentScale;
    _initialWidth = widget.layout.size.width;
    _initialHeight = widget.layout.size.height;
    _initialTopLeft = widget.layout.topLeft;
    final safeScale = _initialScale == 0 ? 1.0 : _initialScale;
    _baseWidth = _initialWidth / safeScale;
    _baseHeight = _initialHeight / safeScale;
  }

  @override
  Widget build(BuildContext context) {
    const padding = _SelectionFrame.padding;

    final overlayWidth = widget.contentSize.width + padding.horizontal;
    final overlayHeight = widget.contentSize.height + padding.vertical;

    return SizedBox(
      width: overlayWidth,
      height: overlayHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: padding,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildDragHandle(),
          _buildResizeHandle(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    const padding = _SelectionFrame.padding;
    var dragTop = padding.top - _handleSize * 0.9;
    if (dragTop < 0) {
      dragTop = 0;
    }
    final dragLeft =
        padding.left + widget.contentSize.width / 2 - _handleSize / 2;

    return Positioned(
      top: dragTop,
      left: dragLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onPanDown: (details) {
          widget.onEnsureSelected();
          developer.log(
            'drag panDown position=${details.localPosition}',
            name: 'selection.${widget.item.id}',
          );
        },
        onTapDown: (_) {
          widget.onEnsureSelected();
          developer.log(
            'drag handle tap',
            name: 'selection.${widget.item.id}',
          );
        },
        onPanStart: (_) {
          widget.onEnsureSelected();
          _dragging = true;
          _dragAnchorWorldOrigin = widget.layout.anchorWorld;
          _dragAnchorDelta = Offset.zero;
          developer.log(
            'drag start anchor=$_dragAnchorWorldOrigin',
            name: 'selection.${widget.item.id}',
          );
        },
        onPanUpdate: (details) {
          _dragAnchorDelta += details.delta;
          developer.log(
            'drag delta=$_dragAnchorDelta',
            name: 'selection.${widget.item.id}',
          );
          final newAnchorWorld = _dragAnchorWorldOrigin + _dragAnchorDelta;
          final normalized = Offset(
            newAnchorWorld.dx / widget.roomSize.width,
            newAnchorWorld.dy / widget.roomSize.height,
          );
          developer.log(
            'drag normalized=$normalized room=${widget.roomSize}',
            name: 'selection.${widget.item.id}',
          );

          widget.onPositionChanged(normalized);
        },
        onPanEnd: (_) {
          _dragging = false;
          _dragAnchorWorldOrigin = widget.layout.anchorWorld;
          _initialTopLeft = widget.layout.topLeft;
          _dragAnchorDelta = Offset.zero;
          developer.log(
            'drag end anchor=$_dragAnchorWorldOrigin',
            name: 'selection.${widget.item.id}',
          );
        },
        child: const _HandleVisual(
          icon: Icons.open_with_rounded,
          size: _handleSize,
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    const padding = _SelectionFrame.padding;

    final left = padding.left + widget.contentSize.width - _handleSize * 0.5;
    final top = padding.top + widget.contentSize.height - _handleSize * 0.5;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onPanDown: (_) => widget.onEnsureSelected(),
        onTapDown: (_) => widget.onEnsureSelected(),
        onPanStart: (_) {
          widget.onEnsureSelected();
          _resizing = true;
          _initialScale = widget.currentScale;
          _initialWidth = widget.layout.size.width;
          _initialHeight = widget.layout.size.height;
          _initialTopLeft = widget.layout.topLeft;
          _baseWidth = _initialScale == 0
              ? _initialWidth
              : _initialWidth / _initialScale;
          _baseHeight = _initialScale == 0
              ? _initialHeight
              : _initialHeight / _initialScale;
          _resizeAccumulated = Offset.zero;
        },
        onPanUpdate: (details) {
          _resizeAccumulated += details.delta;
          final targetWidth = (_initialWidth + _resizeAccumulated.dx).clamp(
            24,
            widget.roomSize.width,
          );
          final targetHeight = (_initialHeight + _resizeAccumulated.dy).clamp(
            24,
            widget.roomSize.height,
          );

          final widthRatio = targetWidth / _initialWidth;
          final heightRatio = targetHeight / _initialHeight;
          final ratio = ((widthRatio + heightRatio) / 2).clamp(0.01, 100.0);

          final nextScale = (_initialScale * ratio).clamp(
            _InteractiveRoomAsset.minScale,
            _InteractiveRoomAsset.maxScale,
          );

          final newWidth = _baseWidth * nextScale;
          final newHeight = _baseHeight * nextScale;

          final offset = anchorOffset(
            anchor: widget.item.anchor,
            width: newWidth,
            height: newHeight,
          );
          final anchorWorld = _initialTopLeft + offset;
          final normalized = Offset(
            anchorWorld.dx / widget.roomSize.width,
            anchorWorld.dy / widget.roomSize.height,
          );

          widget.onScaleChanged(nextScale);
          widget.onPositionChanged(normalized);
        },
        onPanEnd: (_) {
          _resizing = false;
          _initialScale = widget.currentScale;
          _initialWidth = widget.layout.size.width;
          _initialHeight = widget.layout.size.height;
          _initialTopLeft = widget.layout.topLeft;
          final safeScale = _initialScale == 0 ? 1.0 : _initialScale;
          _baseWidth = _initialWidth / safeScale;
          _baseHeight = _initialHeight / safeScale;
          _resizeAccumulated = Offset.zero;
        },
        child: const _HandleVisual(
          icon: Icons.zoom_out_map_rounded,
          size: _handleSize,
        ),
      ),
    );
  }
}

class _HandleVisual extends StatelessWidget {
  const _HandleVisual({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.6, color: theme.colorScheme.primary),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(DoubleProperty('size', size));
  }
}

class _InteractiveRoomAsset extends StatefulWidget {
  const _InteractiveRoomAsset({
    required this.item,
    required this.layout,
    required this.normalizedPosition,
    required this.scale,
    required this.roomSize,
    required this.onSelected,
    required this.onPositionChanged,
    required this.onScaleChanged,
    this.onContentBoundsChanged,
    super.key,
  });

  final RoomItem item;
  final RoomItemLayout layout;
  final Offset normalizedPosition;
  final double scale;
  final Size roomSize;
  final VoidCallback onSelected;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<Rect>? onContentBoundsChanged;

  static const minScale = 0.5;
  static const maxScale = 200.5;

  @override
  State<_InteractiveRoomAsset> createState() => _InteractiveRoomAssetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('itemId', item.id))
      ..add(StringProperty('assetName', item.assetName))
      ..add(DoubleProperty('width', layout.size.width))
      ..add(DoubleProperty('height', layout.size.height))
      ..add(
        DiagnosticsProperty<Offset>('normalizedPosition', normalizedPosition),
      )
      ..add(DoubleProperty('scale', scale))
      ..add(DiagnosticsProperty<Size>('roomSize', roomSize))
      ..add(ObjectFlagProperty<VoidCallback>.has('onSelected', onSelected))
      ..add(
        ObjectFlagProperty<ValueChanged<Offset>>.has(
          'onPositionChanged',
          onPositionChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<double>>.has(
          'onScaleChanged',
          onScaleChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<Rect>>.has(
          'onContentBoundsChanged',
          onContentBoundsChanged,
        ),
      );
  }
}

class _InteractiveRoomAssetState extends State<_InteractiveRoomAsset> {
  late Offset _startPosition;
  late double _startScale;
  late Offset _startFocalNormalized;
  late Offset _startGlobalFocalPoint;
  late Offset _pivotDelta;
  var _isInteracting = false;
  var _interactionActive = false;

  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  ui.Image? _decodedImage;
  ByteData? _decodedBytes;
  Rect? _lastContentBounds;

  @override
  void initState() {
    super.initState();
    _startPosition = widget.normalizedPosition;
    _startScale = widget.scale;
    _startFocalNormalized = _computeFocalNormalized(Offset.zero);
    _startGlobalFocalPoint = Offset.zero;
    _pivotDelta = _startPosition - _startFocalNormalized;
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _InteractiveRoomAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.assetName != widget.item.assetName) {
      _resolveImage();
    }
    if (widget.onContentBoundsChanged != null &&
        _decodedImage != null &&
        _decodedBytes != null) {
      _maybeNotifyContentBounds();
    }
    if (!_isInteracting) {
      _startPosition = widget.normalizedPosition;
      _startScale = widget.scale;
      _startFocalNormalized = _computeFocalNormalized(Offset.zero);
      _pivotDelta = _startPosition - _startFocalNormalized;
    }
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (hitTestLocal(details.localPosition)) {
          widget.onSelected();
        } else {
          developer.log(
            'tap ignored at ${details.localPosition}',
            name: 'selection.${widget.item.id}',
          );
        }
      },
      onScaleStart: (details) {
        final local = details.localFocalPoint;
        if (!hitTestLocal(local)) {
          _interactionActive = false;
          return;
        }
        widget.onSelected();
        _interactionActive = true;
        _isInteracting = true;
        _startPosition = widget.normalizedPosition;
        _startScale = widget.scale;
        _startFocalNormalized = _computeFocalNormalized(local);
        _pivotDelta = _startPosition - _startFocalNormalized;
        _startGlobalFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
        if (!_interactionActive) return;
        final translation = details.focalPoint - _startGlobalFocalPoint;
        final normalizedTranslation = Offset(
          translation.dx / widget.roomSize.width,
          translation.dy / widget.roomSize.height,
        );

        final nextScale = (_startScale * details.scale).clamp(
          _InteractiveRoomAsset.minScale,
          _InteractiveRoomAsset.maxScale,
        );
        widget.onScaleChanged(nextScale);

        final scaleRatio = _startScale == 0 ? 1.0 : nextScale / _startScale;
        final pivotNormalized = _startFocalNormalized + normalizedTranslation;
        final anchorNormalized = pivotNormalized + (_pivotDelta * scaleRatio);
        widget.onPositionChanged(anchorNormalized);
      },
      onScaleEnd: (_) {
        if (!_interactionActive) return;
        _interactionActive = false;
        _isInteracting = false;
        _startPosition = widget.normalizedPosition;
        _startScale = widget.scale;
        _startFocalNormalized = _computeFocalNormalized(Offset.zero);
        _pivotDelta = _startPosition - _startFocalNormalized;
      },
      child: Semantics(
        label: widget.item.semanticLabel,
        container: true,
        child: SizedBox(
          width: widget.layout.size.width,
          height: widget.layout.size.height,
          child: _RoomAssetImage(
            assetName: widget.item.assetName,
            semanticLabel: widget.item.semanticLabel,
          ),
        ),
      ),
    );
  }

  void _resolveImage() {
    final provider = AssetImage(widget.item.assetName);
    final stream = provider.resolve(ImageConfiguration.empty);

    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }

    _imageStream = stream;
    _imageListener = ImageStreamListener((imageInfo, _) async {
      _decodedImage = imageInfo.image;
      _decodedBytes = await imageInfo.image.toByteData();
      _maybeNotifyContentBounds();
      if (mounted) {
        setState(() {});
      }
    });

    stream.addListener(_imageListener!);
  }

  void _maybeNotifyContentBounds() {
    final image = _decodedImage;
    final bytes = _decodedBytes;
    final callback = widget.onContentBoundsChanged;

    if (image == null || bytes == null || callback == null) return;

    final bounds = _calculateContentBounds(image, bytes);

    if (_lastContentBounds != null &&
        _rectsClose(_lastContentBounds!, bounds)) {
      return;
    }

    _lastContentBounds = bounds;
    callback(bounds);
  }

  Rect _calculateContentBounds(ui.Image image, ByteData bytes) {
    final width = image.width;
    final height = image.height;

    var minX = width;
    var minY = height;
    var maxX = -1;
    var maxY = -1;

    final totalLength = bytes.lengthInBytes;
    final rowBytes = totalLength ~/ height;
    final lastValidIndex = totalLength - 4;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final offset = y * rowBytes + x * 4;
        if (offset > lastValidIndex) continue;
        if (offset + 3 > lastValidIndex) continue;
        final alpha = bytes.getUint8(offset + 3);

        if (alpha > 10) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < minX || maxY < minY) {
      return Rect.fromLTWH(
        0,
        0,
        widget.layout.size.width,
        widget.layout.size.height,
      );
    }

    final imageSize = Size(width.toDouble(), height.toDouble());
    final fittedSizes = applyBoxFit(
      BoxFit.contain,
      imageSize,
      widget.layout.size,
    );
    final renderSize = fittedSizes.destination;
    final offsetX = (widget.layout.size.width - renderSize.width) / 2;
    final offsetY = (widget.layout.size.height - renderSize.height) / 2;
    final scaleX = renderSize.width / width;
    final scaleY = renderSize.height / height;

    final left = (offsetX + minX * scaleX).clamp(0.0, widget.layout.size.width);
    final top = (offsetY + minY * scaleY).clamp(0.0, widget.layout.size.height);
    final right = (offsetX + (maxX + 1) * scaleX).clamp(
      0.0,
      widget.layout.size.width,
    );
    final bottom = (offsetY + (maxY + 1) * scaleY).clamp(
      0.0,
      widget.layout.size.height,
    );

    return Rect.fromLTRB(left, top, right, bottom);
  }

  bool _rectsClose(Rect a, Rect b, [double epsilon = 0.001]) {
    return (a.left - b.left).abs() < epsilon &&
        (a.top - b.top).abs() < epsilon &&
        (a.width - b.width).abs() < epsilon &&
        (a.height - b.height).abs() < epsilon;
  }

  bool _isOpaqueHit(Offset localPosition) {
    final image = _decodedImage;
    final bytes = _decodedBytes;
    if (image == null || bytes == null) {
      return true;
    }

    final destinationSize = widget.layout.size;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, destinationSize);
    final renderSize = fittedSizes.destination;

    final offsetX = (destinationSize.width - renderSize.width) / 2;
    final offsetY = (destinationSize.height - renderSize.height) / 2;

    final dx = localPosition.dx - offsetX;
    final dy = localPosition.dy - offsetY;

    if (dx < 0 || dy < 0 || dx > renderSize.width || dy > renderSize.height) {
      return false;
    }

    final u = (dx / renderSize.width) * image.width;
    final v = (dy / renderSize.height) * image.height;

    final px = u.clamp(0, image.width - 1).floor();
    final py = v.clamp(0, image.height - 1).floor();

    final byteOffset = (py * image.width + px) * 4;
    final alpha = bytes.getUint8(byteOffset + 3);

    return alpha > 10;
  }

  bool hitTestLocal(Offset localPosition) {
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > widget.layout.size.width ||
        localPosition.dy > widget.layout.size.height) {
      return false;
    }

    final bounds = _lastContentBounds;
    if (bounds != null) {
      final expanded = Rect.fromLTRB(
        (bounds.left - _SelectionFrame.padding.left)
            .clamp(0.0, widget.layout.size.width),
        (bounds.top - _SelectionFrame.padding.top)
            .clamp(0.0, widget.layout.size.height),
        (bounds.right + _SelectionFrame.padding.right)
            .clamp(0.0, widget.layout.size.width),
        (bounds.bottom + _SelectionFrame.padding.bottom)
            .clamp(0.0, widget.layout.size.height),
      );

      if (expanded.contains(localPosition)) {
        return true;
      }

      return false;
    }

    return _isOpaqueHit(localPosition);
  }
}

extension on _InteractiveRoomAssetState {
  Offset _computeFocalNormalized(Offset localFocalPoint) {
    final width = widget.layout.size.width;
    final height = widget.layout.size.height;
    final offset = anchorOffset(
      anchor: widget.item.anchor,
      width: width,
      height: height,
    );

    final anchorWorld = Offset(
      _startPosition.dx * widget.roomSize.width,
      _startPosition.dy * widget.roomSize.height,
    );
    final topLeft = anchorWorld - offset;
    final focalWorld = topLeft + localFocalPoint;

    return Offset(
      focalWorld.dx / widget.roomSize.width,
      focalWorld.dy / widget.roomSize.height,
    );
  }
}

class _RoomAssetImage extends StatelessWidget {
  const _RoomAssetImage({
    required this.assetName,
    this.semanticLabel,
  });

  final String assetName;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) => _MissingAssetPlaceholder(
        assetName: assetName,
        semanticLabel: semanticLabel,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('assetName', assetName))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}

class _MissingAssetPlaceholder extends StatelessWidget {
  const _MissingAssetPlaceholder({
    required this.assetName,
    this.semanticLabel,
  });

  final String assetName;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assetLabel = assetName.split('/').last;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Add $assetLabel',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('assetName', assetName))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}
