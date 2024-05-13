// To parse this JSON data, do
//
//     final auditionModel = auditionModelFromJson(jsonString);

import 'dart:convert';

AuditionModel auditionModelFromJson(String str) => AuditionModel.fromJson(json.decode(str));

String auditionModelToJson(AuditionModel data) => json.encode(data.toJson());

class AuditionModel {
    int? status;
    String? message;
    Result? result;

    AuditionModel({
        this.status,
        this.message,
        this.result,
    });

    factory AuditionModel.fromJson(Map<String, dynamic> json) => AuditionModel(
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
    int? id;
    String? audditionCodNumber;
    String? profession;
    String? name;
    String? email;
    String? whatsappNumber;
    String? mobile;
    String? school;
    String? pic;
    String? facebookId;
    String? instaId;
    String? fathername;
    String? mothername;
    int? age;
    DateTime? dob;
    String? address;
    String? city;
    String? state;
    dynamic professsioin;
    String? audditionSong;
    String? musicCompany;
    String? singerName;
    String? filmName;
    String? language;
    String? isShortlisted;
    dynamic round;
    String? audditionCity;
    String? audditionCenterName;
    String? judgeName;
    String? directorName;
    DateTime? createdAt;
    DateTime? updatedAt;

    Result({
        this.id,
        this.audditionCodNumber,
        this.profession,
        this.name,
        this.email,
        this.whatsappNumber,
        this.mobile,
        this.school,
        this.pic,
        this.facebookId,
        this.instaId,
        this.fathername,
        this.mothername,
        this.age,
        this.dob,
        this.address,
        this.city,
        this.state,
        this.professsioin,
        this.audditionSong,
        this.musicCompany,
        this.singerName,
        this.filmName,
        this.language,
        this.isShortlisted,
        this.round,
        this.audditionCity,
        this.audditionCenterName,
        this.judgeName,
        this.directorName,
        this.createdAt,
        this.updatedAt,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        audditionCodNumber: json["auddition_cod_number"],
        profession: json["profession"],
        name: json["name"],
        email: json["email"],
        whatsappNumber: json["whatsappNumber"],
        mobile: json["mobile"],
        school: json["school"],
        pic: json["pic"],
        facebookId: json["facebookId"],
        instaId: json["instaId"],
        fathername: json["fathername"],
        mothername: json["mothername"],
        age: json["age"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        address: json["address"],
        city: json["city"],
        state: json["state"],
        professsioin: json["professsioin"],
        audditionSong: json["auddition_song"],
        musicCompany: json["music_company"],
        singerName: json["singer_name"],
        filmName: json["film_name"],
        language: json["language"],
        isShortlisted: json["isShortlisted"],
        round: json["round"],
        audditionCity: json["auddition_city"],
        audditionCenterName: json["auddition_Center_name"],
        judgeName: json["judge_name"],
        directorName: json["director_name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "auddition_cod_number": audditionCodNumber,
        "profession": profession,
        "name": name,
        "email": email,
        "whatsappNumber": whatsappNumber,
        "mobile": mobile,
        "school": school,
        "pic": pic,
        "facebookId": facebookId,
        "instaId": instaId,
        "fathername": fathername,
        "mothername": mothername,
        "age": age,
        "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
        "address": address,
        "city": city,
        "state": state,
        "professsioin": professsioin,
        "auddition_song": audditionSong,
        "music_company": musicCompany,
        "singer_name": singerName,
        "film_name": filmName,
        "language": language,
        "isShortlisted": isShortlisted,
        "round": round,
        "auddition_city": audditionCity,
        "auddition_Center_name": audditionCenterName,
        "judge_name": judgeName,
        "director_name": directorName,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
