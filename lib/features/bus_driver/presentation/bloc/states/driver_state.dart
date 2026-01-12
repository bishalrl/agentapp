import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/driver_entity.dart';

class DriverState extends BaseBlocState {
  final DriverEntity? driver;
  final List<BusEntity> buses;
  final bool isLoading;
  final String? errorMessage;

  const DriverState({
    this.driver,
    this.buses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DriverState copyWith({
    DriverEntity? driver,
    List<BusEntity>? buses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DriverState(
      driver: driver ?? this.driver,
      buses: buses ?? this.buses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [driver, buses, isLoading, errorMessage];
}

