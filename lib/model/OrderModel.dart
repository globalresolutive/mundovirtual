// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gromartstore/model/AddressModel.dart';
import 'package:gromartstore/model/OrderProductModel.dart';
import 'package:gromartstore/model/TaxModel.dart';
import 'package:gromartstore/model/User.dart';
import 'package:gromartstore/model/VendorModel.dart';

class OrderModel {
  String authorID;

  User? author;

  User? driver;

  String? driverID;

  List<OrderProductModel> orderProduct;
  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;

  AddressModel address;
  bool payment_shared = true;

  String id;

  List<dynamic> rejectedByDrivers;

  String deliveryAddress() => '${this.address.line1} ${this.address.line2} ${this.address.city} '
      '${this.address.postalCode}';
  final bool? takeAway;

  dynamic discount;
  String? couponCode;
  String? couponId;

  // var extras = [];
  //String? extra_size;
  TaxModel? taxModel;
  String? tipValue;
  String? notes;
  String? adminCommission;
  String? adminCommissionType;
  String? deliveryCharge;
  String? paymentMethod;

  OrderModel(
      {address,
      this.author,
      this.driver,
      this.driverID,
      this.authorID = '',
      this.paymentMethod = "",
      createdAt,
      this.id = '',
      this.orderProduct = const [],
      this.status = '',
      vendor,
      this.discount = 0,
      this.couponCode = '',
      this.payment_shared = true,
      this.couponId = '',
      this.notes,
      this.tipValue,
      taxModel,
      this.adminCommission,
      this.adminCommissionType,
      this.vendorID = '',
      this.deliveryCharge,
      this.rejectedByDrivers = const [],
      this.takeAway})
      : this.address = address ?? AddressModel(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.taxModel = taxModel ?? null,
        this.vendor = vendor ?? VendorModel(specialDiscountEnable: false);

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderProductModel> orderProduct = parsedJson.containsKey('products')
        ? List<OrderProductModel>.from((parsedJson['products'] as List<dynamic>).map((e) => OrderProductModel.fromJson(e))).toList()
        : [].cast<OrderProductModel>();

    log("product is ${jsonEncode(orderProduct)} id ${parsedJson['id']}");

    return new OrderModel(
        address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
        author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
        authorID: parsedJson['authorID'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        id: parsedJson['id'] ?? '',
        orderProduct: orderProduct,
        status: parsedJson['status'] ?? '',
        payment_shared: parsedJson['payment_shared'] ?? true,
        discount: parsedJson['discount'] ?? 0.0,
        paymentMethod: parsedJson["payment_method"] ?? '',
        couponCode: parsedJson['couponCode'] ?? '',
        couponId: parsedJson['couponId'] ?? '',
        vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
        vendorID: parsedJson['vendorID'] ?? '',
        driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
        driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
        adminCommission: parsedJson["adminCommission"] != null ? parsedJson["adminCommission"] : "",
        adminCommissionType: parsedJson["adminCommissionType"] != null ? parsedJson["adminCommissionType"] : "",
        tipValue: parsedJson["tip_amount"] != null ? parsedJson["tip_amount"] : "",
        taxModel: (parsedJson.containsKey('taxSetting') && parsedJson['taxSetting'] != null) ? TaxModel.fromJson(parsedJson['taxSetting']) : null,
        notes: (parsedJson["notes"] != null && parsedJson["notes"].toString().isNotEmpty) ? parsedJson["notes"] : "",
        takeAway: parsedJson["takeAway"] != null ? parsedJson["takeAway"] : false,
        deliveryCharge: parsedJson["deliveryCharge"],
        rejectedByDrivers: parsedJson.containsKey('rejectedByDrivers') ? parsedJson['rejectedByDrivers'] : [].cast<String>());
  }

  Map<String, dynamic> toJson() {
    return {
      'address': this.address.toJson(),
      'author': this.author?.toJson(),
      'authorID': this.authorID,
      'createdAt': this.createdAt,
      'id': this.id,
      'payment_shared': this.payment_shared,
      'products': this.orderProduct.map((e) => e.toJson()).toList(),
      'status': this.status,
      'discount': this.discount,
      'couponCode': this.couponCode,
      'payment_method': this.paymentMethod,
      'couponId': this.couponId,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'notes': this.notes,
      'adminCommission': this.adminCommission,
      'adminCommissionType': this.adminCommissionType,
      "tip_amount": this.tipValue,
      if (taxModel != null) "taxSetting": this.taxModel!.toJson(),
      // "extras":this.extras,
      //"extras_price":this.extra_size,
      "takeAway": this.takeAway,
      "deliveryCharge": this.deliveryCharge,
    };
  }
}
