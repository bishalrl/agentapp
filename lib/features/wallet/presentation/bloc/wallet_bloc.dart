import 'package:agentapp/features/wallet/presentation/bloc/events/wallet_event.dart';
import 'package:agentapp/features/wallet/presentation/bloc/states/wallet_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/add_money.dart';
import '../../domain/usecases/get_transactions.dart';


class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final AddMoney addMoney;
  final GetTransactions getTransactions;

  WalletBloc({
    required this.addMoney,
    required this.getTransactions,
  }) : super(WalletInitial()) {
    on<AddMoneyEvent>(_onAddMoney);
    on<GetTransactionsEvent>(_onGetTransactions);
  }

  Future<void> _onAddMoney(
    AddMoneyEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await addMoney(
      amount: event.amount,
      description: event.description,
    );
    if (result is Error<WalletEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(WalletError(errorMessage));
    } else if (result is Success<WalletEntity>) {
      final wallet = result.data;
      emit(MoneyAdded(wallet));
    }
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await getTransactions(
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
      page: event.page,
      limit: event.limit,
    );
    if (result is Error<List<WalletTransactionEntity>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(WalletError(errorMessage));
    } else if (result is Success<List<WalletTransactionEntity>>) {
      final transactions = result.data;
      emit(TransactionsLoaded(transactions));
    }
  }
}
