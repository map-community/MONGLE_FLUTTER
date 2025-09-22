// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_sheet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapSheetState implements DiagnosticableTreeMixin {

 double get height;
/// Create a copy of MapSheetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapSheetStateCopyWith<MapSheetState> get copyWith => _$MapSheetStateCopyWithImpl<MapSheetState>(this as MapSheetState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MapSheetState'))
    ..add(DiagnosticsProperty('height', height));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSheetState&&(identical(other.height, height) || other.height == height));
}


@override
int get hashCode => Object.hash(runtimeType,height);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MapSheetState(height: $height)';
}


}

/// @nodoc
abstract mixin class $MapSheetStateCopyWith<$Res>  {
  factory $MapSheetStateCopyWith(MapSheetState value, $Res Function(MapSheetState) _then) = _$MapSheetStateCopyWithImpl;
@useResult
$Res call({
 double height
});




}
/// @nodoc
class _$MapSheetStateCopyWithImpl<$Res>
    implements $MapSheetStateCopyWith<$Res> {
  _$MapSheetStateCopyWithImpl(this._self, this._then);

  final MapSheetState _self;
  final $Res Function(MapSheetState) _then;

/// Create a copy of MapSheetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? height = null,}) {
  return _then(_self.copyWith(
height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MapSheetState].
extension MapSheetStatePatterns on MapSheetState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapSheetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapSheetState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapSheetState value)  $default,){
final _that = this;
switch (_that) {
case _MapSheetState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapSheetState value)?  $default,){
final _that = this;
switch (_that) {
case _MapSheetState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapSheetState() when $default != null:
return $default(_that.height);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double height)  $default,) {final _that = this;
switch (_that) {
case _MapSheetState():
return $default(_that.height);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double height)?  $default,) {final _that = this;
switch (_that) {
case _MapSheetState() when $default != null:
return $default(_that.height);case _:
  return null;

}
}

}

/// @nodoc


class _MapSheetState with DiagnosticableTreeMixin implements MapSheetState {
  const _MapSheetState({required this.height});
  

@override final  double height;

/// Create a copy of MapSheetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapSheetStateCopyWith<_MapSheetState> get copyWith => __$MapSheetStateCopyWithImpl<_MapSheetState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MapSheetState'))
    ..add(DiagnosticsProperty('height', height));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapSheetState&&(identical(other.height, height) || other.height == height));
}


@override
int get hashCode => Object.hash(runtimeType,height);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MapSheetState(height: $height)';
}


}

/// @nodoc
abstract mixin class _$MapSheetStateCopyWith<$Res> implements $MapSheetStateCopyWith<$Res> {
  factory _$MapSheetStateCopyWith(_MapSheetState value, $Res Function(_MapSheetState) _then) = __$MapSheetStateCopyWithImpl;
@override @useResult
$Res call({
 double height
});




}
/// @nodoc
class __$MapSheetStateCopyWithImpl<$Res>
    implements _$MapSheetStateCopyWith<$Res> {
  __$MapSheetStateCopyWithImpl(this._self, this._then);

  final _MapSheetState _self;
  final $Res Function(_MapSheetState) _then;

/// Create a copy of MapSheetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? height = null,}) {
  return _then(_MapSheetState(
height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
