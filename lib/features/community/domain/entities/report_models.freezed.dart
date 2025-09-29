// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportedContent {

 String get id; ReportContentType get type;
/// Create a copy of ReportedContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportedContentCopyWith<ReportedContent> get copyWith => _$ReportedContentCopyWithImpl<ReportedContent>(this as ReportedContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportedContent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,type);

@override
String toString() {
  return 'ReportedContent(id: $id, type: $type)';
}


}

/// @nodoc
abstract mixin class $ReportedContentCopyWith<$Res>  {
  factory $ReportedContentCopyWith(ReportedContent value, $Res Function(ReportedContent) _then) = _$ReportedContentCopyWithImpl;
@useResult
$Res call({
 String id, ReportContentType type
});




}
/// @nodoc
class _$ReportedContentCopyWithImpl<$Res>
    implements $ReportedContentCopyWith<$Res> {
  _$ReportedContentCopyWithImpl(this._self, this._then);

  final ReportedContent _self;
  final $Res Function(ReportedContent) _then;

/// Create a copy of ReportedContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReportContentType,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportedContent].
extension ReportedContentPatterns on ReportedContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportedContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportedContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportedContent value)  $default,){
final _that = this;
switch (_that) {
case _ReportedContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportedContent value)?  $default,){
final _that = this;
switch (_that) {
case _ReportedContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ReportContentType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportedContent() when $default != null:
return $default(_that.id,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ReportContentType type)  $default,) {final _that = this;
switch (_that) {
case _ReportedContent():
return $default(_that.id,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ReportContentType type)?  $default,) {final _that = this;
switch (_that) {
case _ReportedContent() when $default != null:
return $default(_that.id,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _ReportedContent implements ReportedContent {
  const _ReportedContent({required this.id, required this.type});
  

@override final  String id;
@override final  ReportContentType type;

/// Create a copy of ReportedContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportedContentCopyWith<_ReportedContent> get copyWith => __$ReportedContentCopyWithImpl<_ReportedContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportedContent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,type);

@override
String toString() {
  return 'ReportedContent(id: $id, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ReportedContentCopyWith<$Res> implements $ReportedContentCopyWith<$Res> {
  factory _$ReportedContentCopyWith(_ReportedContent value, $Res Function(_ReportedContent) _then) = __$ReportedContentCopyWithImpl;
@override @useResult
$Res call({
 String id, ReportContentType type
});




}
/// @nodoc
class __$ReportedContentCopyWithImpl<$Res>
    implements _$ReportedContentCopyWith<$Res> {
  __$ReportedContentCopyWithImpl(this._self, this._then);

  final _ReportedContent _self;
  final $Res Function(_ReportedContent) _then;

/// Create a copy of ReportedContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,}) {
  return _then(_ReportedContent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReportContentType,
  ));
}


}

// dart format on
