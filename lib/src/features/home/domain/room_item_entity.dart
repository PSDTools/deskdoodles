import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_item_entity.freezed.dart';

/// {@template deskdoodles.features.home.domain.room_item_entity}
/// Represents an item that can be placed inside a user's room (furniture,
/// decor, or other visual assets).
/// {@endtemplate}
@freezed
@immutable
sealed class RoomItem with _$RoomItem {
  /// {@macro deskdoodles.features.home.domain.room_item_entity}
  ///
  /// Create a new, immutable instance of [RoomItem].
  /// At least one of [widthFactor] or [heightFactor] must be provided.
  @Assert(
    'widthFactor != null || heightFactor != null',
    'At least one dimension factor must be provided.',
  )
  const factory RoomItem({
    /// The unique identifier for this item.
    required String id,

    /// The path to the asset rendered for this item.
    required String assetName,

    /// The normalized (0..1) position inside the room
    /// used as a sensible default placement.
    required Offset defaultPosition,

    /// How the asset is anchored relative to the position.
    /// For example, [Alignment.topCenter] or [Alignment.bottomCenter].
    required Alignment anchor,

    /// Optional size factor (relative to the available room size).
    ///
    /// Must be provided if [widthFactor] is null.
    double? heightFactor,

    /// Optional size factor (relative to the available room size).
    ///
    /// Must be provided if [heightFactor] is null.
    double? widthFactor,

    /// Optional semantic label for accessibility.
    String? semanticLabel,
  }) = _RoomItem;

  const RoomItem._();

  /// Compute the pixel layout for this item inside a room of [availableSize].
  /// [availableSize] is typically the size of the room area in pixels.
  /// The [normalizedPosition] is the anchor position inside the room,
  /// where (-1,-1) is top-left and (1,1) is bottom-right.
  /// The returned offset is the pixel offset
  /// from the anchor point to the top-left corner of the asset.
  /// The [scale] is a multiplicative factor applied to the base size factors.
  ///
  /// Returns a [RoomItemLayout] containing the resolved size and top-left
  /// coordinate in pixels, along with anchor positions.
  RoomItemLayout layoutFor({
    required Size availableSize,
    required Offset normalizedPosition,
    required double scale,
  }) {
    final baseWidth = widthFactor != null
        ? availableSize.width * widthFactor!
        : null;
    final baseHeight = heightFactor != null
        ? availableSize.height * heightFactor!
        : null;

    var width = baseWidth != null ? baseWidth * scale : null;
    var height = baseHeight != null ? baseHeight * scale : null;

    // If only one dimension is known, infer the other to keep aspect-ish ratio.
    if (width == null && height != null) {
      width = height;
    } else if (height == null && width != null) {
      height = width;
    } else {
      assert(false, 'At least one dimension must be known here.');
    }

    final safeWidth = width ?? 0;
    final safeHeight = height ?? 0;

    final anchorWorld = Offset(
      normalizedPosition.dx * availableSize.width,
      normalizedPosition.dy * availableSize.height,
    );
    final offset = anchorOffset(
      anchor: anchor,
      width: safeWidth,
      height: safeHeight,
    );
    final topLeft = anchorWorld - offset;

    return RoomItemLayout(
      itemId: id,
      topLeft: topLeft,
      size: Size(safeWidth, safeHeight),
      anchorNormalized: normalizedPosition,
      anchorWorld: anchorWorld,
    );
  }
}

/// {@template deskdoodles.features.home.domain.room_item_layout}
/// Computed layout information for a [RoomItem].
///
/// Contains both normalized and world (pixel) anchor positions,
/// as well as the top-left corner and the resolved size.
/// {@endtemplate}
@freezed
@immutable
sealed class RoomItemLayout with _$RoomItemLayout {
  /// {@macro deskdoodles.features.home.domain.room_item_layout}
  ///
  /// Create a new, immutable instance of [RoomItemLayout].
  const factory RoomItemLayout({
    /// The [itemId] is the id of the corresponding [RoomItem].
    required String itemId,

    /// The top-left corner of the item in room pixel coordinates.
    required Offset topLeft,

    /// The size of the item in room pixel coordinates.
    required Size size,

    /// The anchor position in normalized (0..1) room coordinates.
    required Offset anchorNormalized,

    /// The anchor position in room pixel coordinates.
    required Offset anchorWorld,
  }) = _RoomItemLayout;

  const RoomItemLayout._();

  /// Center point of the item in room pixel coordinates.
  Offset get center => topLeft + Offset(size.width / 2, size.height / 2);

  /// The bounding rectangle of the item in room pixel coordinates.
  Rect get rect => topLeft & size;

  /// Convert a point in room pixel space into a normalized (0..1) offset.
  Offset normalizedForRoom(Size roomSize, Offset point) {
    return Offset(point.dx / roomSize.width, point.dy / roomSize.height);
  }

  /// Returns the local position of interactive handles
  /// relative to the item's top-left corner.
  Offset handlePosition(Handle handle) {
    return switch (handle) {
      Handle.drag => Offset(size.width / 2, -24),
      Handle.resizeBottomRight => Offset(size.width, size.height),
    };
  }
}

/// Handles available for interacting with an item (drag, resize).
enum Handle {
  /// Centered above the [RoomItem], used for dragging.
  drag,

  /// At the bottom-right corner of the [RoomItem], used for resizing.
  resizeBottomRight,
}

/// Compute an offset that aligns the asset according to [anchor].
///
/// The anchor is an [Alignment],
/// where (-1,-1) is top-left and (1,1) is bottom-right.
/// The returned offset is the pixel offset
/// from the anchor point to the top-left corner of the asset.
Offset anchorOffset({
  required Alignment anchor,
  double? width,
  double? height,
}) {
  final dx = width != null ? width * (anchor.x + 1) / 2 : 0.0;
  final dy = height != null ? height * (anchor.y + 1) / 2 : 0.0;
  return Offset(dx, dy);
}
