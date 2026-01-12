import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/usecases/create_bus.dart';
import '../../domain/usecases/update_bus.dart';
import '../../domain/usecases/delete_bus.dart';
import '../../domain/usecases/get_my_buses.dart';
import '../../domain/usecases/activate_bus.dart';
import '../../domain/usecases/deactivate_bus.dart';
import 'events/bus_event.dart';
import 'states/bus_state.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  final CreateBus createBus;
  final UpdateBus updateBus;
  final DeleteBus deleteBus;
  final GetMyBuses getMyBuses;
  final ActivateBus activateBus;
  final DeactivateBus deactivateBus;

  BusBloc({
    required this.createBus,
    required this.updateBus,
    required this.deleteBus,
    required this.getMyBuses,
    required this.activateBus,
    required this.deactivateBus,
  }) : super(const BusState()) {
    on<CreateBusEvent>(_onCreateBus);
    on<UpdateBusEvent>(_onUpdateBus);
    on<DeleteBusEvent>(_onDeleteBus);
    on<GetMyBusesEvent>(_onGetMyBuses);
    on<ActivateBusEvent>(_onActivateBus);
    on<DeactivateBusEvent>(_onDeactivateBus);
  }

  Future<void> _onCreateBus(
    CreateBusEvent event,
    Emitter<BusState> emit,
  ) async {
    print('🔵 BusBloc._onCreateBus called');
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await createBus(
      name: event.name,
      vehicleNumber: event.vehicleNumber,
      from: event.from,
      to: event.to,
      date: event.date,
      time: event.time,
      arrival: event.arrival,
      price: event.price,
      totalSeats: event.totalSeats,
      busType: event.busType,
      driverContact: event.driverContact,
      commissionRate: event.commissionRate,
      allowedSeats: event.allowedSeats,
    );

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success<BusEntity>) {
      final bus = result.data;
      emit(state.copyWith(
        isLoading: false,
        createdBus: bus,
        successMessage: 'Bus created successfully!',
        buses: [...state.buses, bus],
      ));
    }
  }

  Future<void> _onUpdateBus(
    UpdateBusEvent event,
    Emitter<BusState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await updateBus(
      busId: event.busId,
      name: event.name,
      vehicleNumber: event.vehicleNumber,
      from: event.from,
      to: event.to,
      date: event.date,
      time: event.time,
      arrival: event.arrival,
      price: event.price,
      totalSeats: event.totalSeats,
      busType: event.busType,
      driverContact: event.driverContact,
      commissionRate: event.commissionRate,
      allowedSeats: event.allowedSeats,
    );

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BusEntity>) {
      final updatedBus = result.data;
      final updatedBuses = state.buses.map((bus) {
        return bus.id == updatedBus.id ? updatedBus : bus;
      }).toList();
      emit(state.copyWith(
        isLoading: false,
        updatedBus: updatedBus,
        buses: updatedBuses,
        successMessage: 'Bus updated successfully!',
      ));
    }
  }

  Future<void> _onDeleteBus(
    DeleteBusEvent event,
    Emitter<BusState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await deleteBus(event.busId);

    if (result is Error<void>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<void>) {
      final updatedBuses = state.buses.where((bus) => bus.id != event.busId).toList();
      emit(state.copyWith(
        isLoading: false,
        buses: updatedBuses,
        successMessage: 'Bus deleted successfully!',
      ));
    }
  }

  Future<void> _onGetMyBuses(
    GetMyBusesEvent event,
    Emitter<BusState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await getMyBuses(
      date: event.date,
      route: event.route,
      status: event.status,
    );

    if (result is Error<List<BusEntity>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else if (failure is NetworkFailure) {
        final message = failure.message.toLowerCase();
        if (message.contains('no route to host') || 
            message.contains('connection refused') ||
            message.contains('failed host lookup')) {
          errorMessage = 'Unable to connect to server. Please check your internet connection and try again.';
        } else if (message.contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        } else {
          errorMessage = 'Network error: ${failure.message}. Please check your internet connection.';
        }
      } else if (failure is ServerFailure) {
        // Check if it's a "no data" scenario vs actual server error
        final message = failure.message.toLowerCase();
        if (message.contains('no data') || 
            message.contains('not found') ||
            message.contains('empty')) {
          // Treat as empty data, not an error
          emit(state.copyWith(
            isLoading: false,
            buses: [],
            errorMessage: null,
          ));
          return;
        }
        errorMessage = failure.message;
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<List<BusEntity>>) {
      // Success - even if list is empty, it's still a success (no data, not an error)
      emit(state.copyWith(
        isLoading: false,
        buses: result.data,
        errorMessage: null, // Clear any previous errors
      ));
    }
  }

  Future<void> _onActivateBus(
    ActivateBusEvent event,
    Emitter<BusState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await activateBus(event.busId);

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BusEntity>) {
      final activatedBus = result.data;
      final updatedBuses = state.buses.map((bus) {
        return bus.id == activatedBus.id ? activatedBus : bus;
      }).toList();
      emit(state.copyWith(
        isLoading: false,
        updatedBus: activatedBus,
        buses: updatedBuses,
        successMessage: 'Bus activated successfully!',
      ));
    }
  }

  Future<void> _onDeactivateBus(
    DeactivateBusEvent event,
    Emitter<BusState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await deactivateBus(event.busId);

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BusEntity>) {
      final deactivatedBus = result.data;
      final updatedBuses = state.buses.map((bus) {
        return bus.id == deactivatedBus.id ? deactivatedBus : bus;
      }).toList();
      emit(state.copyWith(
        isLoading: false,
        updatedBus: deactivatedBus,
        buses: updatedBuses,
        successMessage: 'Bus deactivated successfully!',
      ));
    }
  }
}

