// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpRequest {

 String get email; String get password; String get nickname; String get verificationToken; String? get profileImageKey;
/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpRequestCopyWith<SignUpRequest> get copyWith => _$SignUpRequestCopyWithImpl<SignUpRequest>(this as SignUpRequest, _$identity);

  /// Serializes this SignUpRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken)&&(identical(other.profileImageKey, profileImageKey) || other.profileImageKey == profileImageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,nickname,verificationToken,profileImageKey);

@override
String toString() {
  return 'SignUpRequest(email: $email, password: $password, nickname: $nickname, verificationToken: $verificationToken, profileImageKey: $profileImageKey)';
}


}

/// @nodoc
abstract mixin class $SignUpRequestCopyWith<$Res>  {
  factory $SignUpRequestCopyWith(SignUpRequest value, $Res Function(SignUpRequest) _then) = _$SignUpRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password, String nickname, String verificationToken, String? profileImageKey
});




}
/// @nodoc
class _$SignUpRequestCopyWithImpl<$Res>
    implements $SignUpRequestCopyWith<$Res> {
  _$SignUpRequestCopyWithImpl(this._self, this._then);

  final SignUpRequest _self;
  final $Res Function(SignUpRequest) _then;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? nickname = null,Object? verificationToken = null,Object? profileImageKey = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,verificationToken: null == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String,profileImageKey: freezed == profileImageKey ? _self.profileImageKey : profileImageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpRequest].
extension SignUpRequestPatterns on SignUpRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpRequest value)  $default,){
final _that = this;
switch (_that) {
case _SignUpRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String nickname,  String verificationToken,  String? profileImageKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
return $default(_that.email,_that.password,_that.nickname,_that.verificationToken,_that.profileImageKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String nickname,  String verificationToken,  String? profileImageKey)  $default,) {final _that = this;
switch (_that) {
case _SignUpRequest():
return $default(_that.email,_that.password,_that.nickname,_that.verificationToken,_that.profileImageKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String nickname,  String verificationToken,  String? profileImageKey)?  $default,) {final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
return $default(_that.email,_that.password,_that.nickname,_that.verificationToken,_that.profileImageKey);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _SignUpRequest implements SignUpRequest {
  const _SignUpRequest({required this.email, required this.password, required this.nickname, required this.verificationToken, this.profileImageKey});
  factory _SignUpRequest.fromJson(Map<String, dynamic> json) => _$SignUpRequestFromJson(json);

@override final  String email;
@override final  String password;
@override final  String nickname;
@override final  String verificationToken;
@override final  String? profileImageKey;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpRequestCopyWith<_SignUpRequest> get copyWith => __$SignUpRequestCopyWithImpl<_SignUpRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignUpRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken)&&(identical(other.profileImageKey, profileImageKey) || other.profileImageKey == profileImageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,nickname,verificationToken,profileImageKey);

@override
String toString() {
  return 'SignUpRequest(email: $email, password: $password, nickname: $nickname, verificationToken: $verificationToken, profileImageKey: $profileImageKey)';
}


}

/// @nodoc
abstract mixin class _$SignUpRequestCopyWith<$Res> implements $SignUpRequestCopyWith<$Res> {
  factory _$SignUpRequestCopyWith(_SignUpRequest value, $Res Function(_SignUpRequest) _then) = __$SignUpRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String nickname, String verificationToken, String? profileImageKey
});




}
/// @nodoc
class __$SignUpRequestCopyWithImpl<$Res>
    implements _$SignUpRequestCopyWith<$Res> {
  __$SignUpRequestCopyWithImpl(this._self, this._then);

  final _SignUpRequest _self;
  final $Res Function(_SignUpRequest) _then;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? nickname = null,Object? verificationToken = null,Object? profileImageKey = freezed,}) {
  return _then(_SignUpRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,verificationToken: null == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String,profileImageKey: freezed == profileImageKey ? _self.profileImageKey : profileImageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
