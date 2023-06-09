class SpecialDiscountModel {
  String? day;
  List<Timeslot>? timeslot;

  SpecialDiscountModel({this.day, this.timeslot});

  SpecialDiscountModel.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['timeslot'] != null) {
      timeslot = <Timeslot>[];
      json['timeslot'].forEach((v) {
        timeslot!.add(new Timeslot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    if (this.timeslot != null) {
      data['timeslot'] = this.timeslot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Timeslot {
  String? from;
  String? to;
  String? discount;
  String? type;
  String? discount_type;

  Timeslot({this.from, this.to, this.discount, this.type, this.discount_type});

  Timeslot.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    discount = json['discount'];
    type = json['type'];
    discount_type = json['discount_type'] ?? "delivery";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['discount'] = this.discount;
    data['type'] = this.type;
    data['discount_type'] = this.discount_type;
    return data;
  }
}
