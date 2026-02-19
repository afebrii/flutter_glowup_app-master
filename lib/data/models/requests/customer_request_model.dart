class CustomerRequestModel {
  final String name;
  final String phone;
  final String? email;
  final String? birthdate;
  final String? gender;
  final String? address;
  final String? skinType;
  final List<String>? skinConcerns;
  final String? allergies;
  final String? notes;
  final String? referralCode;

  CustomerRequestModel({
    required this.name,
    required this.phone,
    this.email,
    this.birthdate,
    this.gender,
    this.address,
    this.skinType,
    this.skinConcerns,
    this.allergies,
    this.notes,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
    };

    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (birthdate != null && birthdate!.isNotEmpty) map['birthdate'] = birthdate;
    if (gender != null && gender!.isNotEmpty) map['gender'] = gender;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    if (skinType != null && skinType!.isNotEmpty) map['skin_type'] = skinType;
    if (skinConcerns != null && skinConcerns!.isNotEmpty) {
      map['skin_concerns'] = skinConcerns;
    }
    if (allergies != null && allergies!.isNotEmpty) map['allergies'] = allergies;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    if (referralCode != null && referralCode!.isNotEmpty) {
      map['referral_code'] = referralCode;
    }

    return map;
  }
}
