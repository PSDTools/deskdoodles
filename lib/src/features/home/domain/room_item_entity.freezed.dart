// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoomItem implements DiagnosticableTreeMixin {

/// The unique identifier for this item.
 String get id;/// The path to the asset rendered for this item.
 String get assetName;/// The normalized (0..1) position inside the room
/// used as a sensible default placement.
 Offset get defaultPosition;/// How the asset is anchored relative to the position.
/// For example, [Alignment.topCenter] or [Alignment.bottomCenter].
 Alignment get anchor;/// Optional size factor (relative to the available room size).
///
/// Must be provided if [widthFactor] is null.
 double? get heightFactor;/// Optional size factor (relative to the available room size).
///
/// Must be provided if [heightFactor] is null.
 double? get widthFactor;/// Optional semantic label for accessibility.
 String? get semanticLabel;
/// Create a copy of RoomItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomItemCopyWith<RoomItem> get copyWith => _$RoomItemCopyWithImpl<RoomItem>(this as RoomItem, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RoomItem'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('assetName', assetName))..add(DiagnosticsProperty('defaultPosition', defaultPosition))..add(DiagnosticsProperty('anchor', anchor))..add(DiagnosticsProperty('heightFactor', heightFactor))..add(DiagnosticsProperty('widthFactor', widthFactor))..add(DiagnosticsProperty('semanticLabel', semanticLabel));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomItem&&(identical(other.id, id) || other.id == id)&&(identical(other.assetName, assetName) || other.assetName == assetName)&&(identical(other.defaultPosition, defaultPosition) || other.defaultPosition == defaultPosition)&&(identical(other.anchor, anchor) || other.anchor == anchor)&&(identical(other.heightFactor, heightFactor) || other.heightFactor == heightFactor)&&(identical(other.widthFactor, widthFactor) || other.widthFactor == widthFactor)&&(identical(other.semanticLabel, semanticLabel) || other.semanticLabel == semanticLabel));
}


@override
int get hashCode => Object.hash(runtimeType,id,assetName,defaultPosition,anchor,heightFactor,widthFactor,semanticLabel);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RoomItem(id: $id, assetName: $assetName, defaultPosition: $defaultPosition, anchor: $anchor, heightFactor: $heightFactor, widthFactor: $widthFactor, semanticLabel: $semanticLabel)';
}


}

/// @nodoc
abstract mixin class $RoomItemCopyWith<$Res>  {
  factory $RoomItemCopyWith(RoomItem value, $Res Function(RoomItem) _then) = _$RoomItemCopyWithImpl;
@useResult
$Res call({
 String id, String assetName, Offset defaultPosition, Alignment anchor, double? heightFactor, double? widthFactor, String? semanticLabel
});




}
/// @nodoc
class _$RoomItemCopyWithImpl<$Res>
    implements $RoomItemCopyWith<$Res> {
  _$RoomItemCopyWithImpl(this._self, this._then);

  final RoomItem _self;
  final $Res Function(RoomItem) _then;

/// Create a copy of RoomItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetName = null,Object? defaultPosition = null,Object? anchor = null,Object? heightFactor = freezed,Object? widthFactor = freezed,Object? semanticLabel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetName: null == assetName ? _self.assetName : assetName // ignore: cast_nullable_to_non_nullable
as String,defaultPosition: null == defaultPosition ? _self.defaultPosition : defaultPosition // ignore: cast_nullable_to_non_nullable
as Offset,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as Alignment,heightFactor: freezed == heightFactor ? _self.heightFactor : heightFactor // ignore: cast_nullable_to_non_nullable
as double?,widthFactor: freezed == widthFactor ? _self.widthFactor : widthFactor // ignore: cast_nullable_to_non_nullable
as double?,semanticLabel: freezed == semanticLabel ? _self.semanticLabel : semanticLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _RoomItem extends RoomItem with DiagnosticableTreeMixin {
  const _RoomItem({required this.id, required this.assetName, required this.defaultPosition, required this.anchor, this.heightFactor, this.widthFactor, this.semanticLabel}): assert(widthFactor != null || heightFactor != null, 'At least one dimension factor must be provided.'),super._();
  

/// The unique identifier for this item.
@override final  String id;
/// The path to the asset rendered for this item.
@override final  String assetName;
/// The normalized (0..1) position inside the room
/// used as a sensible default placement.
@override final  Offset defaultPosition;
/// How the asset is anchored relative to the position.
/// For example, [Alignment.topCenter] or [Alignment.bottomCenter].
@override final  Alignment anchor;
/// Optional size factor (relative to the available room size).
///
/// Must be provided if [widthFactor] is null.
@override final  double? heightFactor;
/// Optional size factor (relative to the available room size).
///
/// Must be provided if [heightFactor] is null.
@override final  double? widthFactor;
/// Optional semantic label for accessibility.
@override final  String? semanticLabel;

/// Create a copy of RoomItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomItemCopyWith<_RoomItem> get copyWith => __$RoomItemCopyWithImpl<_RoomItem>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RoomItem'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('assetName', assetName))..add(DiagnosticsProperty('defaultPosition', defaultPosition))..add(DiagnosticsProperty('anchor', anchor))..add(DiagnosticsProperty('heightFactor', heightFactor))..add(DiagnosticsProperty('widthFactor', widthFactor))..add(DiagnosticsProperty('semanticLabel', semanticLabel));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomItem&&(identical(other.id, id) || other.id == id)&&(identical(other.assetName, assetName) || other.assetName == assetName)&&(identical(other.defaultPosition, defaultPosition) || other.defaultPosition == defaultPosition)&&(identical(other.anchor, anchor) || other.anchor == anchor)&&(identical(other.heightFactor, heightFactor) || other.heightFactor == heightFactor)&&(identical(other.widthFactor, widthFactor) || other.widthFactor == widthFactor)&&(identical(other.semanticLabel, semanticLabel) || other.semanticLabel == semanticLabel));
}


@override
int get hashCode => Object.hash(runtimeType,id,assetName,defaultPosition,anchor,heightFactor,widthFactor,semanticLabel);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RoomItem(id: $id, assetName: $assetName, defaultPosition: $defaultPosition, anchor: $anchor, heightFactor: $heightFactor, widthFactor: $widthFactor, semanticLabel: $semanticLabel)';
}


}

/// @nodoc
abstract mixin class _$RoomItemCopyWith<$Res> implements $RoomItemCopyWith<$Res> {
  factory _$RoomItemCopyWith(_RoomItem value, $Res Function(_RoomItem) _then) = __$RoomItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetName, Offset defaultPosition, Alignment anchor, double? heightFactor, double? widthFactor, String? semanticLabel
});




}
/// @nodoc
class __$RoomItemCopyWithImpl<$Res>
    implements _$RoomItemCopyWith<$Res> {
  __$RoomItemCopyWithImpl(this._self, this._then);

  final _RoomItem _self;
  final $Res Function(_RoomItem) _then;

/// Create a copy of RoomItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetName = null,Object? defaultPosition = null,Object? anchor = null,Object? heightFactor = freezed,Object? widthFactor = freezed,Object? semanticLabel = freezed,}) {
  return _then(_RoomItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetName: null == assetName ? _self.assetName : assetName // ignore: cast_nullable_to_non_nullable
as String,defaultPosition: null == defaultPosition ? _self.defaultPosition : defaultPosition // ignore: cast_nullable_to_non_nullable
as Offset,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as Alignment,heightFactor: freezed == heightFactor ? _self.heightFactor : heightFactor // ignore: cast_nullable_to_non_nullable
as double?,widthFactor: freezed == widthFactor ? _self.widthFactor : widthFactor // ignore: cast_nullable_to_non_nullable
as double?,semanticLabel: freezed == semanticLabel ? _self.semanticLabel : semanticLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RoomItemLayout implements DiagnosticableTreeMixin {

/// The [itemId] is the id of the corresponding [RoomItem].
 String get itemId;/// The top-left corner of the item in room pixel coordinates.
 Offset get topLeft;/// The size of the item in room pixel coordinates.
 Size get size;/// The anchor position in normalized (0..1) room coordinates.
 Offset get anchorNormalized;/// The anchor position in room pixel coordinates.
 Offset get anchorWorld;
/// Create a copy of RoomItemLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomItemLayoutCopyWith<RoomItemLayout> get copyWith => _$RoomItemLayoutCopyWithImpl<RoomItemLayout>(this as RoomItemLayout, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RoomItemLayout'))
    ..add(DiagnosticsProperty('itemId', itemId))..add(DiagnosticsProperty('topLeft', topLeft))..add(DiagnosticsProperty('size', size))..add(DiagnosticsProperty('anchorNormalized', anchorNormalized))..add(DiagnosticsProperty('anchorWorld', anchorWorld));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomItemLayout&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.size, size) || other.size == size)&&(identical(other.anchorNormalized, anchorNormalized) || other.anchorNormalized == anchorNormalized)&&(identical(other.anchorWorld, anchorWorld) || other.anchorWorld == anchorWorld));
}


@override
int get hashCode => Object.hash(runtimeType,itemId,topLeft,size,anchorNormalized,anchorWorld);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RoomItemLayout(itemId: $itemId, topLeft: $topLeft, size: $size, anchorNormalized: $anchorNormalized, anchorWorld: $anchorWorld)';
}


}

/// @nodoc
abstract mixin class $RoomItemLayoutCopyWith<$Res>  {
  factory $RoomItemLayoutCopyWith(RoomItemLayout value, $Res Function(RoomItemLayout) _then) = _$RoomItemLayoutCopyWithImpl;
@useResult
$Res call({
 String itemId, Offset topLeft, Size size, Offset anchorNormalized, Offset anchorWorld
});




}
/// @nodoc
class _$RoomItemLayoutCopyWithImpl<$Res>
    implements $RoomItemLayoutCopyWith<$Res> {
  _$RoomItemLayoutCopyWithImpl(this._self, this._then);

  final RoomItemLayout _self;
  final $Res Function(RoomItemLayout) _then;

/// Create a copy of RoomItemLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? topLeft = null,Object? size = null,Object? anchorNormalized = null,Object? anchorWorld = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as Offset,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as Size,anchorNormalized: null == anchorNormalized ? _self.anchorNormalized : anchorNormalized // ignore: cast_nullable_to_non_nullable
as Offset,anchorWorld: null == anchorWorld ? _self.anchorWorld : anchorWorld // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}

}



/// @nodoc


class _RoomItemLayout extends RoomItemLayout with DiagnosticableTreeMixin {
  const _RoomItemLayout({required this.itemId, required this.topLeft, required this.size, required this.anchorNormalized, required this.anchorWorld}): super._();
  

/// The [itemId] is the id of the corresponding [RoomItem].
@override final  String itemId;
/// The top-left corner of the item in room pixel coordinates.
@override final  Offset topLeft;
/// The size of the item in room pixel coordinates.
@override final  Size size;
/// The anchor position in normalized (0..1) room coordinates.
@override final  Offset anchorNormalized;
/// The anchor position in room pixel coordinates.
@override final  Offset anchorWorld;

/// Create a copy of RoomItemLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomItemLayoutCopyWith<_RoomItemLayout> get copyWith => __$RoomItemLayoutCopyWithImpl<_RoomItemLayout>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RoomItemLayout'))
    ..add(DiagnosticsProperty('itemId', itemId))..add(DiagnosticsProperty('topLeft', topLeft))..add(DiagnosticsProperty('size', size))..add(DiagnosticsProperty('anchorNormalized', anchorNormalized))..add(DiagnosticsProperty('anchorWorld', anchorWorld));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomItemLayout&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.size, size) || other.size == size)&&(identical(other.anchorNormalized, anchorNormalized) || other.anchorNormalized == anchorNormalized)&&(identical(other.anchorWorld, anchorWorld) || other.anchorWorld == anchorWorld));
}


@override
int get hashCode => Object.hash(runtimeType,itemId,topLeft,size,anchorNormalized,anchorWorld);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RoomItemLayout(itemId: $itemId, topLeft: $topLeft, size: $size, anchorNormalized: $anchorNormalized, anchorWorld: $anchorWorld)';
}


}

/// @nodoc
abstract mixin class _$RoomItemLayoutCopyWith<$Res> implements $RoomItemLayoutCopyWith<$Res> {
  factory _$RoomItemLayoutCopyWith(_RoomItemLayout value, $Res Function(_RoomItemLayout) _then) = __$RoomItemLayoutCopyWithImpl;
@override @useResult
$Res call({
 String itemId, Offset topLeft, Size size, Offset anchorNormalized, Offset anchorWorld
});




}
/// @nodoc
class __$RoomItemLayoutCopyWithImpl<$Res>
    implements _$RoomItemLayoutCopyWith<$Res> {
  __$RoomItemLayoutCopyWithImpl(this._self, this._then);

  final _RoomItemLayout _self;
  final $Res Function(_RoomItemLayout) _then;

/// Create a copy of RoomItemLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? topLeft = null,Object? size = null,Object? anchorNormalized = null,Object? anchorWorld = null,}) {
  return _then(_RoomItemLayout(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as Offset,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as Size,anchorNormalized: null == anchorNormalized ? _self.anchorNormalized : anchorNormalized // ignore: cast_nullable_to_non_nullable
as Offset,anchorWorld: null == anchorWorld ? _self.anchorWorld : anchorWorld // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

// dart format on
