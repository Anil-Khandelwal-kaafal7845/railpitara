// To parse this JSON data, do
//
//     final forceUpdatemodel = forceUpdatemodelFromJson(jsonString);

import 'dart:convert';

ForceUpdatemodel forceUpdatemodelFromJson(String str) => ForceUpdatemodel.fromJson(json.decode(str));

String forceUpdatemodelToJson(ForceUpdatemodel data) => json.encode(data.toJson());

class ForceUpdatemodel {
    int? status;
    String? message;
    Result? result;

    ForceUpdatemodel({
        this.status,
        this.message,
        this.result,
    });

    factory ForceUpdatemodel.fromJson(Map<String, dynamic> json) => ForceUpdatemodel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson(),
    };
}

class Result {
    int? appVersion;
    int? forceUpdate;

    Result({
        this.appVersion,
        this.forceUpdate,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        appVersion: json["app_version"],
        forceUpdate: json["force_update"],
    );

    Map<String, dynamic> toJson() => {
        "app_version": appVersion,
        "force_update": forceUpdate,
    };
}
