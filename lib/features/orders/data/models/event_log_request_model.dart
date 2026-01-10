class EventLogRequestModel {
  final String fkMerchantOrderId;
  final int fkStatusId;
  final int fkFromEntityTypeId;
  final int fkToEntityTypeId;
  final String? fkFromEntityId;
  final String? fkToEntityId;
  final String? fkRiderId;
  final int fkUpdatedByEntityTypeId;
  final String? fkUpdatedBy;

  EventLogRequestModel({
    required this.fkMerchantOrderId,
    required this.fkStatusId,
    required this.fkFromEntityTypeId,
    required this.fkToEntityTypeId,
    this.fkFromEntityId,
    this.fkToEntityId,
    this.fkRiderId,
    required this.fkUpdatedByEntityTypeId,
    this.fkUpdatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'fk_MerchantOrderId': fkMerchantOrderId,
      'fk_StatusId': fkStatusId,
      'fk_FromEntityTypeId': fkFromEntityTypeId,
      'fk_ToEntityTypeId': fkToEntityTypeId,
      'fk_FromEntityId': fkFromEntityId ?? '',
      'fk_ToEntityId': fkToEntityId ?? '',
      'fk_RiderId': fkRiderId ?? '',
      'fk_UpdatedByEntityTypeId': fkUpdatedByEntityTypeId,
      'fk_UpdatedBy': fkUpdatedBy ?? '',
    };
  }
}

