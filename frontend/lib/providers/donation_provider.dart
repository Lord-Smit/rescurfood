import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import '../services/donation_service.dart';

class DonationState {
  final List<DonationModel> myDonations;
  final List<DonationModel> availableDonations;
  final List<DonationModel> allDonations;
  final List<RequestModel> myRequests;
  final bool isLoading;
  final String? error;

  const DonationState({
    this.myDonations = const [],
    this.availableDonations = const [],
    this.allDonations = const [],
    this.myRequests = const [],
    this.isLoading = false,
    this.error,
  });

  DonationState copyWith({
    List<DonationModel>? myDonations,
    List<DonationModel>? availableDonations,
    List<DonationModel>? allDonations,
    List<RequestModel>? myRequests,
    bool? isLoading,
    String? error,
  }) {
    return DonationState(
      myDonations: myDonations ?? this.myDonations,
      availableDonations: availableDonations ?? this.availableDonations,
      allDonations: allDonations ?? this.allDonations,
      myRequests: myRequests ?? this.myRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DonationNotifier extends StateNotifier<DonationState> {
  final DonationService _donationService;

  DonationNotifier(this._donationService) : super(const DonationState()) {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      loadMyDonations(),
      loadAvailableDonations(),
      loadAllDonations(),
      loadMyRequests(),
    ]);
  }

  Future<void> loadMyDonations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getMyDonations();
      state = state.copyWith(myDonations: donations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAvailableDonations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getAvailableDonations();
      state = state.copyWith(availableDonations: donations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllDonations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final donations = await _donationService.getAllDonations();
      state = state.copyWith(allDonations: donations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMyRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await _donationService.getMyRequests();
      state = state.copyWith(myRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createDonation(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _donationService.createDonation(data);
      await loadMyDonations();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final donationProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  return DonationNotifier(DonationService());
});
