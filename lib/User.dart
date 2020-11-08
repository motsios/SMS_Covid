class User {
  String name;
  String surname;
  String address;
  String city;
  User({this.name, this.surname, this.address, this.city});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'name': name, 'surname': surname, 'address': address, 'city': city};
  }
}
