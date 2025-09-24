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

  void _updatePosition(String id, Offset newPosition) {
    final clamped = Offset(
      newPosition.dx.clamp(0.0, 1.0),
      newPosition.dy.clamp(0.0, 1.0),
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

          return Center(
            child: SizedBox(
              width: roomSize.width,
              height: roomSize.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _selectedItemId = null),
                    ),
                  ),
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
          );
        },
      ),
    );
  }

  List<Widget> _buildRoomItems(Size roomSize) {
    final widgets = <Widget>[];

    for (final item in YourRoomPage._items) {
      final normalizedPosition = _positions[item.id] ?? item.defaultPosition;
      final scale = _scales[item.id] ?? 1;
      final layout = item.layoutFor(
        availableSize: roomSize,
        normalizedPosition: normalizedPosition,
        scale: scale,
      );

      widgets.add(
        Positioned(
          left: layout.topLeft.dx,
          top: layout.topLeft.dy,
          child: SizedBox(
            width: layout.size.width,
            height: layout.size.height,
            child: _InteractiveRoomAsset(
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
            ),
          ),
        ),
      );

      if (_selectedItemId == item.id) {
        widgets.add(
          Positioned(
            left: layout.topLeft.dx - _SelectionFrame.horizontalPadding,
            top: layout.topLeft.dy - _SelectionFrame.topPadding,
            width: layout.size.width + _SelectionFrame.horizontalPadding * 2,
            height:
                layout.size.height +
                _SelectionFrame.topPadding +
                _SelectionFrame.bottomPadding,
            child: _SelectionFrame(
              item: item,
              layout: layout,
              roomSize: roomSize,
              currentScale: scale,
              onScaleChanged: (value) => _updateScale(item.id, value),
              onPositionChanged: (updatedPosition) =>
                  _updatePosition(item.id, updatedPosition),
            ),
          ),
        );
      }
    }

    return widgets;
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
    required this.roomSize,
    required this.currentScale,
    required this.onScaleChanged,
    required this.onPositionChanged,
  });

  static const double handleSize = 28;
  static const double horizontalPadding = handleSize * 0.6;
  static const double topPadding = handleSize * 1.6;
  static const double bottomPadding = handleSize * 1.0;

  final RoomItem item;
  final RoomItemLayout layout;
  final Size roomSize;
  final double currentScale;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<Offset> onPositionChanged;

  @override
  State<_SelectionFrame> createState() => _SelectionFrameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('itemId', item.id))
      ..add(DoubleProperty('currentScale', currentScale))
      ..add(DiagnosticsProperty<Size>('layoutSize', layout.size))
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
    const extraSide = _SelectionFrame.horizontalPadding;
    const extraTop = _SelectionFrame.topPadding;
    const extraBottom = _SelectionFrame.bottomPadding;

    final overlayWidth = widget.layout.size.width + extraSide * 2;
    final overlayHeight = widget.layout.size.height + extraTop + extraBottom;
    const borderLeft = extraSide;
    const borderTop = extraTop;

    return SizedBox(
      width: overlayWidth,
      height: overlayHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: borderLeft,
            top: borderTop,
            width: widget.layout.size.width,
            height: widget.layout.size.height,
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
          _buildDragHandle(),
          _buildResizeHandle(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    const borderLeft = _SelectionFrame.horizontalPadding;
    const borderTop = _SelectionFrame.topPadding;
    var dragTop = borderTop - _handleSize * 0.9;
    if (dragTop < 0) {
      dragTop = 0;
    }
    final dragLeft =
        borderLeft + widget.layout.size.width / 2 - _handleSize / 2;

    return Positioned(
      top: dragTop,
      left: dragLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onPanDown: (details) => developer.log(
          'drag panDown position=${details.localPosition}',
          name: 'selection.${widget.item.id}',
        ),
        onTapDown: (_) => developer.log(
          'drag handle tap',
          name: 'selection.${widget.item.id}',
        ),
        onPanStart: (_) {
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
    const borderLeft = _SelectionFrame.horizontalPadding;
    const borderTop = _SelectionFrame.topPadding;

    final left = borderLeft + widget.layout.size.width - _handleSize * 0.5;
    final top = borderTop + widget.layout.size.height - _handleSize * 0.5;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanStart: (_) {
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
  });

  final RoomItem item;
  final RoomItemLayout layout;
  final Offset normalizedPosition;
  final double scale;
  final Size roomSize;
  final VoidCallback onSelected;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<double> onScaleChanged;

  static const minScale = 0.5;
  static const maxScale = 2.5;

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

  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  ui.Image? _decodedImage;
  ByteData? _decodedBytes;

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
        if (_isOpaqueHit(details.localPosition)) {
          widget.onSelected();
        } else {
          developer.log(
            'tap ignored at ${details.localPosition}',
            name: 'selection.${widget.item.id}',
          );
        }
      },
      onScaleStart: (details) {
        _isInteracting = true;
        _startPosition = widget.normalizedPosition;
        _startScale = widget.scale;
        _startFocalNormalized = _computeFocalNormalized(
          details.localFocalPoint,
        );
        _pivotDelta = _startPosition - _startFocalNormalized;
        _startGlobalFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
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
      if (mounted) {
        setState(() {});
      }
    });

    stream.addListener(_imageListener!);
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
