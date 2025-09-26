import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  var _rotations = <String, double>{};
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
    _rotations = {
      for (final item in YourRoomPage._items) item.id: 0,
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

  void _updateRotation(String id, double rotation) {
    final normalized = _normalizeAngle(rotation);
    setState(() {
      _rotations = Map<String, double>.from(_rotations)..[id] = normalized;
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

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              final position = event.localPosition;
              final insideRoom =
                  position.dx >= roomOrigin.dx &&
                  position.dy >= roomOrigin.dy &&
                  position.dx <= roomOrigin.dx + roomSize.width &&
                  position.dy <= roomOrigin.dy + roomSize.height;

              if (!insideRoom) {
                _clearSelection();
                return;
              }

              final roomLocal = position - roomOrigin;
              final handled = _handleTap(roomLocal);

              if (!handled) {
                final selected = _selectedItemId;
                if (selected != null) {
                  final selectionRect = _selectionRectFor(selected);
                  if (selectionRect != null &&
                      selectionRect.contains(roomLocal)) {
                    return;
                  }
                }

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
      final rotation = _rotations[item.id] ?? 0;
      final boundsRect = _contentBounds[item.id];
      final preferredAspectRatio =
          boundsRect != null && boundsRect.width > 0 && boundsRect.height > 0
          ? boundsRect.width / boundsRect.height
          : null;
      final layout = item.layoutFor(
        availableSize: roomSize,
        normalizedPosition: normalizedPosition,
        scale: scale,
        preferredAspectRatio: preferredAspectRatio,
      );
      final resolvedRect =
          (boundsRect != null && boundsRect.width > 0 && boundsRect.height > 0)
          ? boundsRect
          : Rect.fromLTWH(0, 0, layout.size.width, layout.size.height);
      // final contentTopLeft = layout.topLeft + resolvedRect.topLeft; // unused
      final effectiveContentSize = resolvedRect.size;
      final selectionRect = _buildSelectionRect(
        layout,
        resolvedRect,
        rotation,
      );
      hitRects[item.id] = selectionRect;
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
              rotation: rotation,
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
              onRotationChanged: (updatedRotation) =>
                  _updateRotation(item.id, updatedRotation),
              onContentBoundsChanged: handleBounds,
            ),
          ),
        ),
      );

      if (_selectedItemId == item.id) {
        // Compute the axis-aligned bounding box of the rotated selection
        // (world coordinates) so the overlay covers the rotated visuals
        // and handles remain hit-testable even when they extend outside
        // the original layout bounds.
        final selectionRect = _buildSelectionRect(
          layout,
          resolvedRect,
          rotation,
        );

        // Inside the overlay, place the selection frame at an offset so
        // its local (layout) origin matches the original layout.topLeft.
        final innerLeft = layout.topLeft.dx - selectionRect.left;
        final innerTop = layout.topLeft.dy - selectionRect.top;

        widgets.add(
          Positioned(
            left: selectionRect.left,
            top: selectionRect.top,
            width: selectionRect.width,
            height: selectionRect.height,
            child: SizedBox(
              width: selectionRect.width,
              height: selectionRect.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: innerLeft,
                    top: innerTop,
                    width: layout.size.width,
                    height: layout.size.height,
                    child: _SelectionFrame(
                      item: item,
                      layout: layout,
                      roomSize: roomSize,
                      rotation: rotation,
                      currentScale: scale,
                      contentSize: effectiveContentSize,
                      contentRect: resolvedRect,
                      onScaleChanged: (value) => _updateScale(item.id, value),
                      onPositionChanged: (updatedPosition) =>
                          _updatePosition(item.id, updatedPosition),
                      onEnsureSelected: () =>
                          setState(() => _selectedItemId = item.id),
                    ),
                  ),
                ],
              ),
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

  bool _handleTap(Offset localPosition) {
    for (final id in _hitOrder.reversed) {
      final rect = _currentHitRects[id];
      if (rect == null || !rect.contains(localPosition)) continue;

      final layout = _currentLayouts[id];
      final state = _assetKeys[id]?.currentState;

      if (layout != null && state != null) {
        final local = localPosition - layout.topLeft;
        final isSelected = id == _selectedItemId;
        if (!state.hitTestLocal(local) && !isSelected) {
          continue;
        }
      }

      if (_selectedItemId != id) {
        setState(() => _selectedItemId = id);
      }
      return true;
    }

    return false;
  }

  void _clearSelection() {
    if (_selectedItemId == null) return;
    setState(() => _selectedItemId = null);
  }

  Rect? _selectionRectFor(String id) {
    final layout = _currentLayouts[id];
    if (layout == null) return null;

    final bounds = _contentBounds[id];
    final rotation = _rotations[id] ?? 0;
    final resolved = (bounds != null && bounds.width > 0 && bounds.height > 0)
        ? bounds
        : Rect.fromLTWH(0, 0, layout.size.width, layout.size.height);

    return _buildSelectionRect(layout, resolved, rotation);
  }

  Rect _buildSelectionRect(
    RoomItemLayout layout,
    Rect contentRect,
    double rotation,
  ) {
    // Build the local (within layout) selection rect including padding.
    const padding = _SelectionFrame.padding;
    const hitInset = _SelectionFrame.handleHitInset;
    final localLeft = contentRect.left - padding.left - hitInset;
    final localTop = contentRect.top - padding.top - hitInset;
    final localWidth = contentRect.width + padding.horizontal + hitInset * 2;
    final localHeight = contentRect.height + padding.vertical + hitInset * 2;

    // Compute the four corners of the local rect relative to the layout's
    // coordinate space and then rotate them around the layout center.
    final center = Offset(layout.size.width / 2, layout.size.height / 2);

    final corners = <Offset>[
      Offset(localLeft, localTop),
      Offset(localLeft + localWidth, localTop),
      Offset(localLeft + localWidth, localTop + localHeight),
      Offset(localLeft, localTop + localHeight),
    ];

    final rotated = corners.map((pt) {
      final dx = pt.dx - center.dx;
      final dy = pt.dy - center.dy;
      final cosT = math.cos(rotation);
      final sinT = math.sin(rotation);
      final rx = center.dx + dx * cosT - dy * sinT;
      final ry = center.dy + dx * sinT + dy * cosT;
      return Offset(rx, ry);
    }).toList();

    // Find axis-aligned bounding box of rotated corners in layout space.
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;

    for (final p in rotated) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    // Translate to world coordinates by adding layout.topLeft
    final worldLeft = layout.topLeft.dx + minX;
    final worldTop = layout.topLeft.dy + minY;
    final worldRight = layout.topLeft.dx + maxX;
    final worldBottom = layout.topLeft.dy + maxY;

    return Rect.fromLTRB(worldLeft, worldTop, worldRight, worldBottom);
  }

  // helper functions removed; no longer used

  double _normalizeAngle(double angle) {
    const twoPi = 2 * math.pi;
    var normalized = angle % twoPi;
    if (normalized < 0) normalized += twoPi;
    return normalized;
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
    required this.rotation,
    required this.currentScale,
    required this.onScaleChanged,
    required this.onPositionChanged,
    required this.onEnsureSelected,
    required this.contentRect,
  });

  static const double handleSize = 28;
  static const double horizontalPadding = handleSize * 0.6;
  static const double topPadding = handleSize * 1.6;
  static const double bottomPadding = handleSize * 1.0;
  static const double handleHitSize = 44;
  static const double handleHitInset = (handleHitSize - handleSize) / 2;
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
  final double rotation;
  final double currentScale;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onEnsureSelected;
  final Rect contentRect;

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
      ..add(DoubleProperty('rotation', rotation))
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
    properties.add(DiagnosticsProperty<Rect>('contentRect', contentRect));
  }
}

class _SelectionFrameState extends State<_SelectionFrame> {
  static const double _handleSize = _SelectionFrame.handleSize;
  static const double _handleHitSize = _SelectionFrame.handleHitSize;
  static const double _handleHitInset = _SelectionFrame.handleHitInset;

  var _dragging = false;
  var _resizing = false;

  late Offset _dragAnchorWorldOrigin;
  Offset _dragAnchorDelta = Offset.zero;
  Offset? _dragLastLocalPosition;
  Offset? _dragLastGlobalPosition;

  late double _initialScale;
  late double _initialWidth;
  late double _initialHeight;
  late double _baseWidth;
  late double _baseHeight;
  late Offset _initialTopLeft;
  Offset _resizeAccumulated = Offset.zero;
  late Offset _initialContentLocal;
  late Offset _initialContentTopLeftWorld;

  // Rotate a world-space delta into the layout's unrotated local space.
  Offset _rotateDeltaToUnrotated(Offset delta, double rotation) {
    if (rotation == 0) return delta;
    final cosT = math.cos(-rotation);
    final sinT = math.sin(-rotation);
    return Offset(
      delta.dx * cosT - delta.dy * sinT,
      delta.dx * sinT + delta.dy * cosT,
    );
  }

  Offset _rotateVector(Offset vector, double angle) {
    if (angle == 0) return vector;
    final cosT = math.cos(angle);
    final sinT = math.sin(angle);
    return Offset(
      vector.dx * cosT - vector.dy * sinT,
      vector.dx * sinT + vector.dy * cosT,
    );
  }

  Offset _contentTopLeftWorld({
    required Offset topLeft,
    required Size size,
    required Rect contentRect,
    required double rotation,
  }) {
    final halfSize = Offset(size.width / 2, size.height / 2);
    final local = contentRect.topLeft;
    final rotated = _rotateVector(local - halfSize, rotation);
    return topLeft + halfSize + rotated;
  }

  Offset _resolveTopLeftFromPivot({
    required Offset pivotWorld,
    required Size size,
    required Offset pivotLocal,
    required double rotation,
  }) {
    final halfSize = Offset(size.width / 2, size.height / 2);
    final rotated = _rotateVector(pivotLocal - halfSize, rotation);
    return pivotWorld - halfSize - rotated;
  }

  void _syncContentMetrics({Offset? topLeftOverride, Size? sizeOverride}) {
    final topLeft = topLeftOverride ?? widget.layout.topLeft;
    final size = sizeOverride ?? widget.layout.size;
    _initialContentLocal = widget.contentRect.topLeft;
    _initialContentTopLeftWorld = _contentTopLeftWorld(
      topLeft: topLeft,
      size: size,
      contentRect: widget.contentRect,
      rotation: widget.rotation,
    );
  }

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
      _dragLastLocalPosition = null;
      _dragLastGlobalPosition = null;
    }
    if (!_resizing) {
      _initialScale = widget.currentScale;
      _initialWidth = widget.layout.size.width;
      _initialHeight = widget.layout.size.height;
      final safeScale = _initialScale == 0 ? 1.0 : _initialScale;
      _baseWidth = _initialWidth / safeScale;
      _baseHeight = _initialHeight / safeScale;
      _resizeAccumulated = Offset.zero;
      _syncContentMetrics(
        topLeftOverride: widget.layout.topLeft,
        sizeOverride: widget.layout.size,
      );
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
    _resizeAccumulated = Offset.zero;
    _dragLastLocalPosition = null;
    _dragLastGlobalPosition = null;
    _syncContentMetrics(
      topLeftOverride: _initialTopLeft,
      sizeOverride: Size(_initialWidth, _initialHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = _SelectionFrame.padding;
    const hitInset = _SelectionFrame.handleHitInset;

    final overlayWidth =
        widget.contentSize.width + padding.horizontal + hitInset * 2;
    final overlayHeight =
        widget.contentSize.height + padding.vertical + hitInset * 2;
    final overlayLeft = widget.contentRect.left - padding.left - hitInset;
    final overlayTop = widget.contentRect.top - padding.top - hitInset;

    return Transform.rotate(
      angle: widget.rotation,
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.layout.size.width,
        height: widget.layout.size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: overlayLeft,
              top: overlayTop,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    const padding = _SelectionFrame.padding;
    var dragTop = padding.top - _handleSize * 0.9 - _handleHitInset;
    if (dragTop < 0) {
      dragTop = 0;
    }
    final dragLeft =
        padding.left + widget.contentSize.width / 2 - _handleHitSize / 2;

    return Positioned(
      top: dragTop,
      left: dragLeft,
      child: SizedBox(
        width: _handleHitSize,
        height: _handleHitSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onPanDown: (details) {
            widget.onEnsureSelected();
            developer.log(
              'drag panDown position=${details.localPosition}',
              name: 'selection.${widget.item.id}',
            );
            _dragLastLocalPosition = details.localPosition;
            _dragLastGlobalPosition = details.globalPosition;
          },
          onTapDown: (_) {
            widget.onEnsureSelected();
            developer.log(
              'drag handle tap',
              name: 'selection.${widget.item.id}',
            );
          },
          onPanStart: (details) {
            widget.onEnsureSelected();
            _dragging = true;
            _dragAnchorWorldOrigin = widget.layout.anchorWorld;
            _dragAnchorDelta = Offset.zero;
            developer.log(
              'drag start anchor=$_dragAnchorWorldOrigin',
              name: 'selection.${widget.item.id}',
            );
            _dragLastLocalPosition = details.localPosition;
            _dragLastGlobalPosition = details.globalPosition;
          },
          onPanUpdate: (details) {
            final currentGlobal = details.globalPosition;
            final lastGlobal = _dragLastGlobalPosition ?? currentGlobal;
            final delta = currentGlobal - lastGlobal;
            _dragLastLocalPosition = details.localPosition;
            _dragLastGlobalPosition = currentGlobal;

            _dragAnchorDelta += delta;
            developer.log(
              'drag delta=$_dragAnchorDelta (step=$delta)',
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
            _dragLastLocalPosition = null;
            _dragLastGlobalPosition = null;
            developer.log(
              'drag end anchor=$_dragAnchorWorldOrigin',
              name: 'selection.${widget.item.id}',
            );
          },
          onPanCancel: () {
            _dragging = false;
            _dragAnchorDelta = Offset.zero;
            _dragLastLocalPosition = null;
            _dragLastGlobalPosition = null;
          },
          child: const Center(
            child: _HandleVisual(
              icon: Icons.open_with_rounded,
              size: _handleSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    const padding = _SelectionFrame.padding;

    final left =
        padding.left +
        widget.contentSize.width -
        _handleSize * 0.5 -
        _handleHitInset;
    final top =
        padding.top +
        widget.contentSize.height -
        _handleSize * 0.5 -
        _handleHitInset;

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: _handleHitSize,
        height: _handleHitSize,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
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
            _syncContentMetrics(
              topLeftOverride: _initialTopLeft,
              sizeOverride: Size(_initialWidth, _initialHeight),
            );
          },
          onPointerMove: (event) {
            if (!_resizing) return;
            final rawDelta = event.delta;
            final unrotatedDelta = _rotateDeltaToUnrotated(
              rawDelta,
              widget.rotation,
            );
            _resizeAccumulated += unrotatedDelta;

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
            final safeInitialScale = _initialScale == 0 ? 1.0 : _initialScale;
            final scaleRatio = nextScale / safeInitialScale;
            final newSize = Size(newWidth, newHeight);
            final newContentLocal = _initialContentLocal * scaleRatio;
            final newTopLeft = _resolveTopLeftFromPivot(
              pivotWorld: _initialContentTopLeftWorld,
              size: newSize,
              pivotLocal: newContentLocal,
              rotation: widget.rotation,
            );

            final offset = anchorOffset(
              anchor: widget.item.anchor,
              width: newWidth,
              height: newHeight,
            );
            final anchorWorld = newTopLeft + offset;
            final normalized = Offset(
              anchorWorld.dx / widget.roomSize.width,
              anchorWorld.dy / widget.roomSize.height,
            );

            widget.onScaleChanged(nextScale);
            widget.onPositionChanged(normalized);
          },
          onPointerUp: (event) {
            if (!_resizing) return;
            _resizing = false;
            _initialScale = widget.currentScale;
            _initialWidth = widget.layout.size.width;
            _initialHeight = widget.layout.size.height;
            _initialTopLeft = widget.layout.topLeft;
            final safeScale = _initialScale == 0 ? 1.0 : _initialScale;
            _baseWidth = _initialWidth / safeScale;
            _baseHeight = _initialHeight / safeScale;
            _resizeAccumulated = Offset.zero;
            _syncContentMetrics(
              topLeftOverride: _initialTopLeft,
              sizeOverride: Size(_initialWidth, _initialHeight),
            );
          },
          onPointerCancel: (event) {
            if (!_resizing) return;
            _resizing = false;
            _resizeAccumulated = Offset.zero;
            _syncContentMetrics(
              topLeftOverride: widget.layout.topLeft,
              sizeOverride: widget.layout.size,
            );
          },
          child: const Center(
            child: _HandleVisual(
              icon: Icons.zoom_out_map_rounded,
              size: _handleSize,
            ),
          ),
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
    required this.rotation,
    required this.roomSize,
    required this.onSelected,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.onRotationChanged,
    this.onContentBoundsChanged,
    super.key,
  });

  final RoomItem item;
  final RoomItemLayout layout;
  final Offset normalizedPosition;
  final double scale;
  final double rotation;
  final Size roomSize;
  final VoidCallback onSelected;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotationChanged;
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
        ObjectFlagProperty<ValueChanged<double>>.has(
          'onRotationChanged',
          onRotationChanged,
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
  late double _startRotation;
  static const double _snapThreshold = math.pi / 36;

  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  ui.Image? _decodedImage;
  Rect? _lastContentBounds;

  @override
  void initState() {
    super.initState();
    _startPosition = widget.normalizedPosition;
    _startScale = widget.scale;
    _startFocalNormalized = _computeFocalNormalized(Offset.zero);
    _startGlobalFocalPoint = Offset.zero;
    _pivotDelta = _startPosition - _startFocalNormalized;
    _startRotation = widget.rotation;
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _InteractiveRoomAsset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.assetName != widget.item.assetName) {
      _resolveImage();
    }
    if (widget.onContentBoundsChanged != null && _decodedImage != null) {
      _maybeNotifyContentBounds();
    }
    if (!_isInteracting) {
      _startPosition = widget.normalizedPosition;
      _startScale = widget.scale;
      _startFocalNormalized = _computeFocalNormalized(Offset.zero);
      _pivotDelta = _startPosition - _startFocalNormalized;
      _startRotation = widget.rotation;
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
    return _HitTestRegion(
      hitTest: hitTestLocal,
      child: GestureDetector(
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
          _startRotation = widget.rotation;
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

          final rawRotation = _startRotation + details.rotation;
          final snappedRotation = _applySnap(rawRotation);
          widget.onRotationChanged(snappedRotation);

          final scaleRatio = _startScale == 0 ? 1.0 : nextScale / _startScale;
          final pivotNormalized = _startFocalNormalized + normalizedTranslation;
          final anchorNormalized = pivotNormalized + (_pivotDelta * scaleRatio);
          widget.onPositionChanged(anchorNormalized);
        },
        onScaleEnd: (_) {
          if (!_interactionActive) return;
          _interactionActive = false;
          _isInteracting = false;
          final snappedRotation = _applySnap(widget.rotation);
          widget.onRotationChanged(snappedRotation);
          _startPosition = widget.normalizedPosition;
          _startScale = widget.scale;
          _startRotation = snappedRotation;
          _startFocalNormalized = _computeFocalNormalized(Offset.zero);
          _pivotDelta = _startPosition - _startFocalNormalized;
        },
        child: Semantics(
          label: widget.item.semanticLabel,
          container: true,
          child: SizedBox(
            width: widget.layout.size.width,
            height: widget.layout.size.height,
            child: Transform.rotate(
              angle: widget.rotation,
              alignment: Alignment.center,
              child: _RoomAssetImage(
                assetName: widget.item.assetName,
                semanticLabel: widget.item.semanticLabel,
              ),
            ),
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
    _imageListener = ImageStreamListener((imageInfo, _) {
      _decodedImage = imageInfo.image;
      _maybeNotifyContentBounds();
      if (mounted) {
        setState(() {});
      }
    });

    stream.addListener(_imageListener!);
  }

  void _maybeNotifyContentBounds() {
    final image = _decodedImage;
    final callback = widget.onContentBoundsChanged;

    if (image == null || callback == null) return;

    final bounds = _calculateContentBounds(image);

    if (_lastContentBounds != null &&
        _rectsClose(_lastContentBounds!, bounds)) {
      return;
    }

    _lastContentBounds = bounds;
    callback(bounds);
  }

  Rect _calculateContentBounds(ui.Image image) {
    final layoutSize = widget.layout.size;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, layoutSize);
    final renderSize = fittedSizes.destination;
    final offsetX = (layoutSize.width - renderSize.width) / 2;
    final offsetY = (layoutSize.height - renderSize.height) / 2;
    return Rect.fromLTWH(offsetX, offsetY, renderSize.width, renderSize.height);
  }

  bool _rectsClose(Rect a, Rect b, [double epsilon = 0.001]) {
    return (a.left - b.left).abs() < epsilon &&
        (a.top - b.top).abs() < epsilon &&
        (a.width - b.width).abs() < epsilon &&
        (a.height - b.height).abs() < epsilon;
  }

  Offset _toUnrotated(Offset point, double angle) {
    if (angle == 0) return point;
    final center = Offset(
      widget.layout.size.width / 2,
      widget.layout.size.height / 2,
    );

    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final cosTheta = math.cos(-angle);
    final sinTheta = math.sin(-angle);

    return Offset(
      center.dx + dx * cosTheta - dy * sinTheta,
      center.dy + dx * sinTheta + dy * cosTheta,
    );
  }

  double _normalizeAngle(double angle) {
    const twoPi = 2 * math.pi;
    var normalized = angle % twoPi;
    if (normalized < 0) normalized += twoPi;
    return normalized;
  }

  double _applySnap(double angle) {
    final base = _normalizeAngle(angle);
    final snaps = <double>[
      0,
      math.pi / 2,
      math.pi,
      3 * math.pi / 2,
      2 * math.pi,
    ];

    var closest = base;
    var minDiff = double.infinity;
    for (final target in snaps) {
      var diff = (base - target).abs();
      if (diff > math.pi) diff = 2 * math.pi - diff;
      if (diff < minDiff) {
        minDiff = diff;
        closest = target;
      }
    }

    if (minDiff <= _snapThreshold) {
      final correction = angle - base;
      return correction + closest;
    }

    return angle;
  }

  bool hitTestLocal(Offset localPosition) {
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > widget.layout.size.width ||
        localPosition.dy > widget.layout.size.height) {
      return false;
    }

    final unrotated = _toUnrotated(localPosition, widget.rotation);
    final bounds = _lastContentBounds;
    if (bounds != null) {
      return bounds.contains(unrotated);
    }

    final width = widget.layout.size.width;
    final height = widget.layout.size.height;
    return unrotated.dx >= 0 &&
        unrotated.dy >= 0 &&
        unrotated.dx <= width &&
        unrotated.dy <= height;
  }
}

typedef _HitTestPredicate = bool Function(Offset position);

class _HitTestRegion extends SingleChildRenderObjectWidget {
  const _HitTestRegion({
    required this.hitTest,
    required super.child,
  });

  final _HitTestPredicate hitTest;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HitTestRegionRenderBox(hitTest);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _HitTestRegionRenderBox renderObject,
  ) {
    renderObject.hitTestPredicate = hitTest;
  }
}

class _HitTestRegionRenderBox extends RenderProxyBox {
  _HitTestRegionRenderBox(this.hitTestPredicate);

  _HitTestPredicate hitTestPredicate;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hitTestPredicate(position)) {
      return false;
    }
    return super.hitTest(result, position: position);
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
