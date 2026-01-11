import 'package:flutter/foundation.dart';

class MerchantOrderModel {
  final String pkMerchantOrderId;
  final String fkMerchantId;
  final String orderReferenceNumber;
  final String shipmentDescription;
  final int orderQuantity;
  final double orderWeight;
  final double orderLength;
  final double orderHeight;
  final double orderWidth;
  final String specialInstructions;
  final bool isFragile;
  final String orderDate;
  final String fromEntityName;
  final String toEntityName;
  final String eventDateTime;
  final String pickupAddress;
  final String businessName;
  final String merchantPhoneNumber;
  final int fkShipmentStatusId;
  final int? fkFromEntityTypeId;
  final String? fkToEntityId;

  MerchantOrderModel({
    required this.pkMerchantOrderId,
    required this.fkMerchantId,
    required this.orderReferenceNumber,
    required this.shipmentDescription,
    required this.orderQuantity,
    required this.orderWeight,
    required this.orderLength,
    required this.orderHeight,
    required this.orderWidth,
    required this.specialInstructions,
    required this.isFragile,
    required this.orderDate,
    required this.fromEntityName,
    required this.toEntityName,
    required this.eventDateTime,
    required this.pickupAddress,
    required this.businessName,
    required this.merchantPhoneNumber,
    required this.fkShipmentStatusId,
    this.fkFromEntityTypeId,
    this.fkToEntityId,
  });

  factory MerchantOrderModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [MerchantOrderModel] Parsing JSON:');
    debugPrint('   - Available keys: ${json.keys.toList()}');
    debugPrint('   - pk_MerchantOrderId: ${json['pk_MerchantOrderId']}');
    debugPrint('   - pkMerchantOrderId: ${json['pkMerchantOrderId']}');
    debugPrint('   - orderReferenceNumber: ${json['orderReferenceNumber']}');
    debugPrint('   - businessName: ${json['businessName']}');
    debugPrint('   - pickupAddress: ${json['pickupAddress']}');
    debugPrint('   - merchantPhoneNumber: ${json['merchantPhoneNumber']}');
    debugPrint('   - toEntityName: ${json['toEntityName']}');
    
    final model = MerchantOrderModel(
      pkMerchantOrderId: json['pk_MerchantOrderId'] ?? json['pkMerchantOrderId'] ?? '',
      fkMerchantId: json['fk_MerchantId'] ?? json['fkMerchantId'] ?? '',
      orderReferenceNumber: json['orderReferenceNumber'] ?? '',
      shipmentDescription: json['shipmentDescription'] ?? '',
      orderQuantity: json['orderQuantity'] ?? 0,
      orderWeight: (json['orderWeight'] ?? 0).toDouble(),
      orderLength: (json['orderLength'] ?? 0).toDouble(),
      orderHeight: (json['orderHeight'] ?? 0).toDouble(),
      orderWidth: (json['orderWidth'] ?? 0).toDouble(),
      specialInstructions: json['specialInstructions'] ?? '',
      isFragile: json['isFragile'] ?? false,
      orderDate: json['orderDate'] ?? '',
      fromEntityName: json['fromEntityName'] ?? '',
      toEntityName: json['toEntityName'] ?? '',
      eventDateTime: json['eventDateTime'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      businessName: json['businessName'] ?? '',
      merchantPhoneNumber: json['merchantPhoneNumber'] ?? '',
      fkShipmentStatusId: json['fk_ShipmentStatusId'] ?? json['fkShipmentStatusId'] ?? 0,
      fkFromEntityTypeId: json['fk_FromEntityTypeId'] ?? json['fkFromEntityTypeId'],
      fkToEntityId: json['fk_ToEntityId'] ?? json['fkToEntityId'],
    );
    
    debugPrint('📦 [MerchantOrderModel] Parsed model:');
    debugPrint('   - pkMerchantOrderId: ${model.pkMerchantOrderId}');
    debugPrint('   - orderReferenceNumber: ${model.orderReferenceNumber}');
    debugPrint('   - businessName: ${model.businessName}');
    debugPrint('   - pickupAddress: ${model.pickupAddress}');
    debugPrint('   - merchantPhoneNumber: ${model.merchantPhoneNumber}');
    
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'pk_MerchantOrderId': pkMerchantOrderId,
      'fk_MerchantId': fkMerchantId,
      'orderReferenceNumber': orderReferenceNumber,
      'shipmentDescription': shipmentDescription,
      'orderQuantity': orderQuantity,
      'orderWeight': orderWeight,
      'orderLength': orderLength,
      'orderHeight': orderHeight,
      'orderWidth': orderWidth,
      'specialInstructions': specialInstructions,
      'isFragile': isFragile,
      'orderDate': orderDate,
      'fromEntityName': fromEntityName,
      'toEntityName': toEntityName,
      'eventDateTime': eventDateTime,
      'pickupAddress': pickupAddress,
      'businessName': businessName,
      'merchantPhoneNumber': merchantPhoneNumber,
      'fk_ShipmentStatusId': fkShipmentStatusId,
      'fk_FromEntityTypeId': fkFromEntityTypeId,
      'fk_ToEntityId': fkToEntityId,
    };
  }
}

