import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/usecases/create_bus.dart';
import '../../domain/usecases/update_bus.dart';
import '../../domain/usecases/delete_bus.dart';
import '../../domain/usecases/get_my_buses.dart';
import '../../domain/usecases/get_assigned_buses.dart';
import '../../domain/usecases/search_bus_by_number.dart';
import '../../domain/usecases/activate_bus.dart';
import '../../domain/usecases/deactivate_bus.dart';
import 'events/bus_event.dart';
import 'states/bus_state.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  final CreateBus createBus;
  final UpdateBus updateBus;
  final DeleteBus deleteBus;
  final GetMyBuses getMyBuses;
  final GetAssignedBuses getAssignedBuses;
  final SearchBusByNumber searchBusByNumber;
  final ActivateBus activateBus;
  final DeactivateBus deactivateBus;

  BusBloc({
    required this.createBus,
    required this.updateBus,
    required this.deleteBus,
    required this.getMyBuses,
    required this.getAssignedBuses,
    required this.searchBusByNumber,
    required this.activateBus,
    required this.deactivateBus,
  }) : super(const BusState()) {
    on<CreateBusEvent>(_onCreateBus);
    on<UpdateBusEvent>(_onUpdateBus);
    on<DeleteBusEvent>(_onDeleteBus);
    on<GetMyBusesEvent>(_onGetMyBuses);
    on<GetAssignedBusesEvent>(_onGetAssignedBuses);
    on<GetAllAvailableBusesEvent>(_onGetAllAvailableBuses);
    on<SearchBusByNumberEvent>(_onSearchBusByNumber);
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
      timeFormat: event.timeFormat,
      arrivalFormat: event.arrivalFormat,
      tripDirection: event.tripDirection,
      price: event.price,
      totalSeats: event.totalSeats,
      busType: event.busType,
      driverContact: event.driverContact,
      driverEmail: event.driverEmail,
      driverName: event.driverName,
      driverLicenseNumber: event.driverLicenseNumber,
      driverId: event.driverId,
      commissionRate: event.commissionRate,
      allowedSeats: event.allowedSeats,
      seatConfiguration: event.seatConfiguration,
      amenities: event.amenities,
      boardingPoints: event.boardingPoints,
      droppingPoints: event.droppingPoints,
      routeId: event.routeId,
      scheduleId: event.scheduleId,
      distance: event.distance,
      estimatedDuration: event.estimatedDuration,
      isRecurring: event.isRecurring,
      recurringDays: event.recurringDays,
      recurringStartDate: event.recurringStartDate,
      recurringEndDate: event.recurringEndDate,
      recurringFrequency: event.recurringFrequency,
      autoActivate: event.autoActivate,
      activeFromDate: event.activeFromDate,
      activeToDate: event.activeToDate,
    );

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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
      driverEmail: event.driverEmail,
      driverName: event.driverName,
      driverLicenseNumber: event.driverLicenseNumber,
      driverId: event.driverId,
      commissionRate: event.commissionRate,
      allowedSeats: event.allowedSeats,
      seatConfiguration: event.seatConfiguration,
      amenities: event.amenities,
      boardingPoints: event.boardingPoints,
      droppingPoints: event.droppingPoints,
      routeId: event.routeId,
      scheduleId: event.scheduleId,
      distance: event.distance,
      estimatedDuration: event.estimatedDuration,
    );

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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

  Future<void> _onGetAssignedBuses(
    GetAssignedBusesEvent event,
    Emitter<BusState> emit,
  ) async {
    print('🔵 BusBloc._onGetAssignedBuses called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getAssignedBuses(
      date: event.date,
      from: event.from,
      to: event.to,
    );

    if (result is Error<List<BusEntity>>) {
      final failure = result.failure;
      print('   ❌ GetAssignedBuses Error: ${failure.message}');
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success<List<BusEntity>>) {
      final buses = result.data;
      print('   ✅ GetAssignedBuses Success: ${buses.length} buses');
      emit(state.copyWith(
        buses: buses,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  /// Fetches all available buses: assigned buses + my buses, merged and deduplicated by id.
  Future<void> _onGetAllAvailableBuses(
    GetAllAvailableBusesEvent event,
    Emitter<BusState> emit,
  ) async {
    print('🔵 BusBloc._onGetAllAvailableBuses called');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final assignedResult = await getAssignedBuses(
      date: event.date,
      from: event.from,
      to: event.to,
    );
    final myBusesResult = await getMyBuses(
      date: event.date,
      route: null,
      status: null,
    );

    final List<BusEntity> assigned = assignedResult is Success<List<BusEntity>>
        ? assignedResult.data
        : [];
    final List<BusEntity> myBuses = myBusesResult is Success<List<BusEntity>>
        ? myBusesResult.data
        : [];

    final Set<String> seenIds = {};
    final List<BusEntity> merged = [];
    for (final bus in assigned) {
      if (seenIds.add(bus.id)) merged.add(bus);
    }
    for (final bus in myBuses) {
      if (seenIds.add(bus.id)) merged.add(bus);
    }

    if (assignedResult is Error<List<BusEntity>> && myBusesResult is Error<List<BusEntity>>) {
      final failure = assignedResult.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        buses: merged,
        isLoading: false,
        errorMessage: errorMessage,
      ));
      return;
    }

    print('   ✅ GetAllAvailableBuses: ${assigned.length} assigned + ${myBuses.length} my = ${merged.length} total');
    emit(state.copyWith(
      buses: merged,
      isLoading: false,
      errorMessage: null,
    ));
  }

  Future<void> _onSearchBusByNumber(
    SearchBusByNumberEvent event,
    Emitter<BusState> emit,
  ) async {
    print('🔵 BusBloc._onSearchBusByNumber called');
    emit(state.copyWith(isLoading: true, errorMessage: null, searchedBus: null));

    final result = await searchBusByNumber(
      busNumber: event.busNumber,
    );

    if (result is Error<BusEntity>) {
      final failure = result.failure;
      print('   ❌ SearchBusByNumber Error: ${failure.message}');
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        searchedBus: null,
      ));
    } else if (result is Success<BusEntity>) {
      final bus = result.data;
      print('   ✅ SearchBusByNumber Success: Bus found - ${bus.name}');
      emit(state.copyWith(
        searchedBus: bus,
        isLoading: false,
        errorMessage: null,
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
      // Check if it's a "no data" scenario vs actual server error
      if (failure is ServerFailure) {
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
      }
      
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
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

