// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_code_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyCodeResponse {

 String get verificationToken;
/// Create a copy of VerifyCodeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyCodeResponseCopyWith<VerifyCodeResponse> get copyWith => _$VerifyCodeResponseCopyWithImpl<VerifyCodeResponse>(this as VerifyCodeResponse, _$identity);

  /// Serializes this VerifyCodeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyCodeResponse&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verificationToken);

@override
String toString() {
  return 'VerifyCodeResponse(verificationToken: $verificationToken)';
}


}

/// @nodoc
abstract mixin class $VerifyCodeResponseCopyWith<$Res>  {
  factory $VerifyCodeResponseCopyWith(VerifyCodeResponse value, $Res Function(VerifyCodeResponse) _then) = _$VerifyCodeResponseCopyWithImpl;
@useResult
$Res call({
 String verificationToken
});




}
/// @nodoc
class _$VerifyCodeResponseCopyWithImpl<$Res>
    implements $VerifyCodeResponseCopyWith<$Res> {
  _$VerifyCodeResponseCopyWithImpl(this._self, this._then);

  final VerifyCodeResponse _self;
  final $Res Function(VerifyCodeResponse) _then;

/// Create a copy of VerifyCodeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationToken = null,}) {
  return _then(_self.copyWith(
verificationToken: null == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyCodeResponse].
extension VerifyCodeResponsePatterns on VerifyCodeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyCodeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyCodeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyCodeResponse value)  $default,){
final _that = this;
switch (_that) {
case _VerifyCodeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyCodeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyCodeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String verificationToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyCodeResponse() when $default != null:
return $default(_that.verificationToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String verificationToken)  $default,) {final _that = this;
switch (_that) {
case _VerifyCodeResponse():
return $default(_that.verificationToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String verificationToken)?  $default,) {final _that = this;
switch (_that) {
case _VerifyCodeResponse() when $default != null:
return $default(_that.verificationToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyCodeResponse implements VerifyCodeResponse {
  const _VerifyCodeResponse({required this.verificationToken});
  factory _VerifyCodeResponse.fromJson(Map<String, dynamic> json) => _$VerifyCodeResponseFromJson(json);

@override final  String verificationToken;

/// Create a copy of VerifyCodeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyCodeResponseCopyWith<_VerifyCodeResponse> get copyWith => __$VerifyCodeResponseCopyWithImpl<_VerifyCodeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyCodeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyCodeResponse&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verificationToken);

@override
String toString() {
  return 'VerifyCodeResponse(verificationToken: $verificationToken)';
}


}

/// @nodoc
abstract mixin class _$VerifyCodeResponseCopyWith<$Res> implements $VerifyCodeResponseCopyWith<$Res> {
  factory _$VerifyCodeResponseCopyWith(_VerifyCodeResponse value, $Res Function(_VerifyCodeResponse) _then) = __$VerifyCodeResponseCopyWithImpl;
@override @useResult
$Res call({
 String verificationToken
});




}
/// @nodoc
class __$VerifyCodeResponseCopyWithImpl<$Res>
    implements _$VerifyCodeResponseCopyWith<$Res> {
  __$VerifyCodeResponseCopyWithImpl(this._self, this._then);

  final _VerifyCodeResponse _self;
  final $Res Function(_VerifyCodeResponse) _then;

/// Create a copy of VerifyCodeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationToken = null,}) {
  return _then(_VerifyCodeResponse(
verificationToken: null == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
