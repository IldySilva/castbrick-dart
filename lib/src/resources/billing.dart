import '../client.dart';
import '../models.dart';

class BillingResource {
  final CastBrickClient _client;

  BillingResource(this._client);

  Future<BillingBalance> getBalance() {
    return _client.get<Map<String, dynamic>>('/billing/balance')
        .then(BillingBalance.fromJson);
  }

  Future<List<CreditPack>> listPackages() {
    return _client.get<List<dynamic>>('/billing/packages')
        .then((list) => list.map((e) => CreditPack.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<InitiatePaymentResponse> initiatePayment({
    required String packageId,
    required String provider,
    required String method,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
    required String successUrl,
    required String failureUrl,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/billing/payments/initiate',
      body: {
        'packageId': packageId,
        'provider': provider,
        'method': method,
        'currency': currency,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
        'successUrl': successUrl,
        'failureUrl': failureUrl,
      },
    ).then(InitiatePaymentResponse.fromJson);
  }

  Future<PaginatedCursorResult<PaymentInfo>> listPayments({
    String? cursor,
    int? limit,
    String? status,
    String? from,
    String? to,
  }) {
    final params = <String, dynamic>{
      if (cursor != null) 'cursor': cursor,
      if (limit != null) 'limit': limit,
      if (status != null) 'status': status,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    return _client.get<Map<String, dynamic>>(
      '/billing/payments',
      params: params,
    ).then((json) => PaginatedCursorResult<PaymentInfo>.fromJson(json, PaymentInfo.fromJson));
  }

  Future<PaginatedCursorResult<CreditLedgerEntry>> listTransactions({String? cursor}) {
    final params = <String, dynamic>{
      if (cursor != null) 'cursor': cursor,
    };
    return _client.get<Map<String, dynamic>>(
      '/billing/transactions',
      params: params,
    ).then((json) => PaginatedCursorResult<CreditLedgerEntry>.fromJson(json, CreditLedgerEntry.fromJson));
  }
}
