class CustomerOrderModel {
  final String pkMerchantOrderId;
  final String fkMerchantId;
  final String orderReferenceNumber;
  final String shipmentDescription;
  final String fkFromEntityId;
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
  final String receiverCity;
  final double orderAmount;
  final String receiverName;
  final String receiverContactNumber;
  final String deliveryAddress;
  final String deliveryLandmark;
  final String paymentMethod;
  final bool isReturnable;

  CustomerOrderModel({
    required this.pkMerchantOrderId,
    required this.fkMerchantId,
    required this.orderReferenceNumber,
    required this.shipmentDescription,
    required this.fkFromEntityId,
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
    required this.receiverCity,
    required this.orderAmount,
    required this.receiverName,
    required this.receiverContactNumber,
    required this.deliveryAddress,
    required this.deliveryLandmark,
    required this.paymentMethod,
    required this.isReturnable,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderModel(
      pkMerchantOrderId: json['pk_MerchantOrderId'] ?? json['pkMerchantOrderId'] ?? '',
      fkMerchantId: json['fk_MerchantId'] ?? json['fkMerchantId'] ?? '',
      orderReferenceNumber: json['orderReferenceNumber'] ?? '',
      shipmentDescription: json['shipmentDescription'] ?? '',
      fkFromEntityId: json['fk_FromEntityId'] ?? json['fkFromEntityId'] ?? '',
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
      receiverCity: json['receiverCity'] ?? '',
      orderAmount: (json['orderAmount'] ?? 0).toDouble(),
      receiverName: json['receiverName'] ?? '',
      receiverContactNumber: json['receiverContactNumber'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryLandmark: json['deliveryLandmark'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      isReturnable: json['isReturnable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk_MerchantOrderId': pkMerchantOrderId,
      'fk_MerchantId': fkMerchantId,
      'orderReferenceNumber': orderReferenceNumber,
      'shipmentDescription': shipmentDescription,
      'fk_FromEntityId': fkFromEntityId,
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
      'receiverCity': receiverCity,
      'orderAmount': orderAmount,
      'receiverName': receiverName,
      'receiverContactNumber': receiverContactNumber,
      'deliveryAddress': deliveryAddress,
      'deliveryLandmark': deliveryLandmark,
      'paymentMethod': paymentMethod,
      'isReturnable': isReturnable,
    };
  }
}

