// To parse this JSON data, do
//
//     final sectionTypeModel = sectionTypeModelFromJson(jsonString);

import 'dart:convert';

SectionTypeModel sectionTypeModelFromJson(String str) => SectionTypeModel.fromJson(json.decode(str));

String sectionTypeModelToJson(SectionTypeModel data) => json.encode(data.toJson());

class SectionTypeModel {
    int? status;
    String? message;
    List<Result>? result;

    SectionTypeModel({
        this.status,
        this.message,
        this.result,
    });

    factory SectionTypeModel.fromJson(Map<String, dynamic> json) => SectionTypeModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    String? name;
    int? type;
    String? isMainMenu;
    int? orderNumber;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? typeId;

    Result({
        this.id,
        this.name,
        this.type,
        this.isMainMenu,
        this.orderNumber,
        this.createdAt,
        this.updatedAt,
        this.typeId,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        isMainMenu: json["is_main_menu"],
        orderNumber: json["order_number"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        typeId: json["type_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "is_main_menu": isMainMenu,
        "order_number": orderNumber,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "type_id": typeId,
    };
}
