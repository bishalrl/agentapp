import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/bus_entity.dart';

class BusState extends BaseBlocState {
  final List<BusEntity> buses;
  final BusEntity? createdBus;
  final BusEntity? updatedBus;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BusState({
    this.buses = const [],
    this.createdBus,
    this.updatedBus,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  BusState copyWith({
    List<BusEntity>? buses,
    BusEntity? createdBus,
    BusEntity? updatedBus,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return BusState(
      buses: buses ?? this.buses,
      createdBus: createdBus ?? this.createdBus,
      updatedBus: updatedBus ?? this.updatedBus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [buses, createdBus, updatedBus, isLoading, errorMessage, successMessage];
}

