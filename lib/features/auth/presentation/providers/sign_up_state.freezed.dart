// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {

 SignUpStep get step; String? get email; String? get verificationToken; DateTime? get tokenExpiryTime;// verificationToken 만료 시간 (10분)
 String? get password;// 🆕 비밀번호 임시 저장
 String? get nickname; bool get termsAgreed;// 🆕 서비스 이용약관 동의
 bool get privacyAgreed;// 🆕 개인정보 처리방침 동의
 String? get errorMessage; bool get isLoading; DateTime? get lastCodeSentAt;// 마지막 인증 코드 발송 시간
 int get codeSendCount;
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateCopyWith<SignUpState> get copyWith => _$SignUpStateCopyWithImpl<SignUpState>(this as SignUpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState&&(identical(other.step, step) || other.step == step)&&(identical(other.email, email) || other.email == email)&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken)&&(identical(other.tokenExpiryTime, tokenExpiryTime) || other.tokenExpiryTime == tokenExpiryTime)&&(identical(other.password, password) || other.password == password)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.termsAgreed, termsAgreed) || other.termsAgreed == termsAgreed)&&(identical(other.privacyAgreed, privacyAgreed) || other.privacyAgreed == privacyAgreed)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.lastCodeSentAt, lastCodeSentAt) || other.lastCodeSentAt == lastCodeSentAt)&&(identical(other.codeSendCount, codeSendCount) || other.codeSendCount == codeSendCount));
}


@override
int get hashCode => Object.hash(runtimeType,step,email,verificationToken,tokenExpiryTime,password,nickname,termsAgreed,privacyAgreed,errorMessage,isLoading,lastCodeSentAt,codeSendCount);

@override
String toString() {
  return 'SignUpState(step: $step, email: $email, verificationToken: $verificationToken, tokenExpiryTime: $tokenExpiryTime, password: $password, nickname: $nickname, termsAgreed: $termsAgreed, privacyAgreed: $privacyAgreed, errorMessage: $errorMessage, isLoading: $isLoading, lastCodeSentAt: $lastCodeSentAt, codeSendCount: $codeSendCount)';
}


}

/// @nodoc
abstract mixin class $SignUpStateCopyWith<$Res>  {
  factory $SignUpStateCopyWith(SignUpState value, $Res Function(SignUpState) _then) = _$SignUpStateCopyWithImpl;
@useResult
$Res call({
 SignUpStep step, String? email, String? verificationToken, DateTime? tokenExpiryTime, String? password, String? nickname, bool termsAgreed, bool privacyAgreed, String? errorMessage, bool isLoading, DateTime? lastCodeSentAt, int codeSendCount
});




}
/// @nodoc
class _$SignUpStateCopyWithImpl<$Res>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._self, this._then);

  final SignUpState _self;
  final $Res Function(SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? email = freezed,Object? verificationToken = freezed,Object? tokenExpiryTime = freezed,Object? password = freezed,Object? nickname = freezed,Object? termsAgreed = null,Object? privacyAgreed = null,Object? errorMessage = freezed,Object? isLoading = null,Object? lastCodeSentAt = freezed,Object? codeSendCount = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as SignUpStep,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,verificationToken: freezed == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String?,tokenExpiryTime: freezed == tokenExpiryTime ? _self.tokenExpiryTime : tokenExpiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,termsAgreed: null == termsAgreed ? _self.termsAgreed : termsAgreed // ignore: cast_nullable_to_non_nullable
as bool,privacyAgreed: null == privacyAgreed ? _self.privacyAgreed : privacyAgreed // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,lastCodeSentAt: freezed == lastCodeSentAt ? _self.lastCodeSentAt : lastCodeSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,codeSendCount: null == codeSendCount ? _self.codeSendCount : codeSendCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpState].
extension SignUpStatePatterns on SignUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpState value)  $default,){
final _that = this;
switch (_that) {
case _SignUpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpState value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SignUpStep step,  String? email,  String? verificationToken,  DateTime? tokenExpiryTime,  String? password,  String? nickname,  bool termsAgreed,  bool privacyAgreed,  String? errorMessage,  bool isLoading,  DateTime? lastCodeSentAt,  int codeSendCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.step,_that.email,_that.verificationToken,_that.tokenExpiryTime,_that.password,_that.nickname,_that.termsAgreed,_that.privacyAgreed,_that.errorMessage,_that.isLoading,_that.lastCodeSentAt,_that.codeSendCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SignUpStep step,  String? email,  String? verificationToken,  DateTime? tokenExpiryTime,  String? password,  String? nickname,  bool termsAgreed,  bool privacyAgreed,  String? errorMessage,  bool isLoading,  DateTime? lastCodeSentAt,  int codeSendCount)  $default,) {final _that = this;
switch (_that) {
case _SignUpState():
return $default(_that.step,_that.email,_that.verificationToken,_that.tokenExpiryTime,_that.password,_that.nickname,_that.termsAgreed,_that.privacyAgreed,_that.errorMessage,_that.isLoading,_that.lastCodeSentAt,_that.codeSendCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SignUpStep step,  String? email,  String? verificationToken,  DateTime? tokenExpiryTime,  String? password,  String? nickname,  bool termsAgreed,  bool privacyAgreed,  String? errorMessage,  bool isLoading,  DateTime? lastCodeSentAt,  int codeSendCount)?  $default,) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.step,_that.email,_that.verificationToken,_that.tokenExpiryTime,_that.password,_that.nickname,_that.termsAgreed,_that.privacyAgreed,_that.errorMessage,_that.isLoading,_that.lastCodeSentAt,_that.codeSendCount);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpState implements SignUpState {
  const _SignUpState({this.step = SignUpStep.emailInput, this.email, this.verificationToken, this.tokenExpiryTime, this.password, this.nickname, this.termsAgreed = false, this.privacyAgreed = false, this.errorMessage, this.isLoading = false, this.lastCodeSentAt, this.codeSendCount = 0});
  

@override@JsonKey() final  SignUpStep step;
@override final  String? email;
@override final  String? verificationToken;
@override final  DateTime? tokenExpiryTime;
// verificationToken 만료 시간 (10분)
@override final  String? password;
// 🆕 비밀번호 임시 저장
@override final  String? nickname;
@override@JsonKey() final  bool termsAgreed;
// 🆕 서비스 이용약관 동의
@override@JsonKey() final  bool privacyAgreed;
// 🆕 개인정보 처리방침 동의
@override final  String? errorMessage;
@override@JsonKey() final  bool isLoading;
@override final  DateTime? lastCodeSentAt;
// 마지막 인증 코드 발송 시간
@override@JsonKey() final  int codeSendCount;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpStateCopyWith<_SignUpState> get copyWith => __$SignUpStateCopyWithImpl<_SignUpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpState&&(identical(other.step, step) || other.step == step)&&(identical(other.email, email) || other.email == email)&&(identical(other.verificationToken, verificationToken) || other.verificationToken == verificationToken)&&(identical(other.tokenExpiryTime, tokenExpiryTime) || other.tokenExpiryTime == tokenExpiryTime)&&(identical(other.password, password) || other.password == password)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.termsAgreed, termsAgreed) || other.termsAgreed == termsAgreed)&&(identical(other.privacyAgreed, privacyAgreed) || other.privacyAgreed == privacyAgreed)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.lastCodeSentAt, lastCodeSentAt) || other.lastCodeSentAt == lastCodeSentAt)&&(identical(other.codeSendCount, codeSendCount) || other.codeSendCount == codeSendCount));
}


@override
int get hashCode => Object.hash(runtimeType,step,email,verificationToken,tokenExpiryTime,password,nickname,termsAgreed,privacyAgreed,errorMessage,isLoading,lastCodeSentAt,codeSendCount);

@override
String toString() {
  return 'SignUpState(step: $step, email: $email, verificationToken: $verificationToken, tokenExpiryTime: $tokenExpiryTime, password: $password, nickname: $nickname, termsAgreed: $termsAgreed, privacyAgreed: $privacyAgreed, errorMessage: $errorMessage, isLoading: $isLoading, lastCodeSentAt: $lastCodeSentAt, codeSendCount: $codeSendCount)';
}


}

/// @nodoc
abstract mixin class _$SignUpStateCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory _$SignUpStateCopyWith(_SignUpState value, $Res Function(_SignUpState) _then) = __$SignUpStateCopyWithImpl;
@override @useResult
$Res call({
 SignUpStep step, String? email, String? verificationToken, DateTime? tokenExpiryTime, String? password, String? nickname, bool termsAgreed, bool privacyAgreed, String? errorMessage, bool isLoading, DateTime? lastCodeSentAt, int codeSendCount
});




}
/// @nodoc
class __$SignUpStateCopyWithImpl<$Res>
    implements _$SignUpStateCopyWith<$Res> {
  __$SignUpStateCopyWithImpl(this._self, this._then);

  final _SignUpState _self;
  final $Res Function(_SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? email = freezed,Object? verificationToken = freezed,Object? tokenExpiryTime = freezed,Object? password = freezed,Object? nickname = freezed,Object? termsAgreed = null,Object? privacyAgreed = null,Object? errorMessage = freezed,Object? isLoading = null,Object? lastCodeSentAt = freezed,Object? codeSendCount = null,}) {
  return _then(_SignUpState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as SignUpStep,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,verificationToken: freezed == verificationToken ? _self.verificationToken : verificationToken // ignore: cast_nullable_to_non_nullable
as String?,tokenExpiryTime: freezed == tokenExpiryTime ? _self.tokenExpiryTime : tokenExpiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,termsAgreed: null == termsAgreed ? _self.termsAgreed : termsAgreed // ignore: cast_nullable_to_non_nullable
as bool,privacyAgreed: null == privacyAgreed ? _self.privacyAgreed : privacyAgreed // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,lastCodeSentAt: freezed == lastCodeSentAt ? _self.lastCodeSentAt : lastCodeSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,codeSendCount: null == codeSendCount ? _self.codeSendCount : codeSendCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
