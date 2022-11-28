import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BoardingScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}



class GetBoardingScreenData extends BoardingScreenEvent {}
