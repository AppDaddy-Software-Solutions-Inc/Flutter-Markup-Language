// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class TestDataModel extends DataSourceModel implements IDataSource {

  int rows = 100;

  @override
  bool get autoexecute => super.autoexecute ?? true;

  TestDataModel(super.parent, super.id, {dynamic datastring});

  static TestDataModel? fromXml(Model parent, XmlElement xml) {
    TestDataModel? model;
    try {

      model = TestDataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);

      model.rows = toInt(Xml.get(node: xml, tag: 'rows'))  ?? 100;
      var delay = toInt(Xml.get(node: xml, tag: 'delay')) ?? 0;

      if (delay <= 0) {
        var data = generate(model.rows);
        model.onSuccess(data, code: 200, message: "Ok");
        return model;
      }

      // delayed for testing
      model.busy = true;
      Future.delayed(Duration(seconds: delay), () {
        var data = generate(model!.rows);
        model.onSuccess(data, code: 200, message: "Ok");
        model.busy = false;
      });
    }
    catch (e) {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "start":
      case "load":
        data = generate(toInt(elementAt(arguments, 0)) ?? rows);
        onSuccess(data!, code: 200, message: "Ok");
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  static Data generate(int rows) {
    Data data = Data();
    for (int i = 0; i < rows; i++) {
      var first = _names[Random().nextInt(_names.length)];
      var last = _surnames[Random().nextInt(_surnames.length)];
      var user = "$first.$last${Random().nextInt(100)}".toUpperCase();

      var row = <String, dynamic>{};
      row["index"] = "$i";
      row["rights"] = Random().nextInt(16);
      row["user"] = user;
      row["first"] = first;
      row["last"] = last;
      row["age"] = Random().nextInt(100);
      row["city"] = _cities[Random().nextInt(_cities.length)];
      row["occupation"] = _jobs[Random().nextInt(_jobs.length)];
      row["company"] = _companies[Random().nextInt(_companies.length)];
      row["email"] = "$user@gmail.com".toLowerCase();
      data.add(row);
    }
    return data;
  }

  static final List<String> _cities = [
    "Tokyo",
    "Jakarta",
    "Delhi",
    "Guangzhou",
    "Guangdong",
    "Mumbai",
    "Mahārāshtra",
    "Manila",
    "Shanghai",
    "São Paulo",
    "Seoul",
    "Mexico City",
    "Cairo",
    "New York",
    "Dhaka",
    "Beijing",
    "Bangkok",
    "Shenzhen",
    "Moscow",
    "Buenos Aires",
    "Lagos",
    "Istanbul",
    "Karachi",
    "Bangalore",
    "Ho Chi Minh City",
    "Ōsaka",
    "Chengdu",
    "Sichuan",
    "Tehran",
    "Rio de Janeiro",
    "Toronto",
    "Montreal"
  ];

  static final List<String> _names = [
    "John",
    "William",
    "James",
    "Charles",
    "George",
    "Frank",
    "Joseph",
    "Thomas",
    "Henry",
    "Robert",
    "Edward",
    "Harry",
    "Walter",
    "Arthur",
    "Fred",
    "Albert",
    "Samuel",
    "David",
    "Louis",
    "Joe",
    "Charlie",
    "Clarence",
    "Richard",
    "Andrew",
    "Daniel",
    "Ernest",
    "Will",
    "Jesse",
    "Oscar",
    "Lewis",
    "Peter",
    "Benjamin",
    "Frederick",
    "Willie",
    "Alfred",
    "Sam",
    "Roy",
    "Herbert",
    "Jacob",
    "Tom",
    "Elmer",
    "Carl",
    "Lee",
    "Howard",
    "Martin",
    "Michael",
    "Bert",
    "Herman",
    "Jim",
    "Francis",
    "Harvey",
    "Earl",
    "Eugene",
    "Ralph",
    "Ed",
    "Claude",
    "Edwin",
    "Ben",
    "Charley",
    "Paul",
    "Edgar",
    "Isaac",
    "Otto",
    "Luther",
    "Lawrence",
    "Ira",
    "Patrick",
    "Guy",
    "Oliver",
    "Theodore",
    "Hugh",
    "Clyde",
    "Alexander",
    "August",
    "Floyd",
    "Homer",
    "Jack",
    "Leonard",
    "Horace",
    "Marion",
    "Philip",
    "Allen",
    "Archie",
    "Stephen",
    "Chester",
    "Willis",
    "Raymond",
    "Rufus",
    "Warren",
    "Jessie",
    "Milton",
    "Alex",
    "Leo",
    "Julius",
    "Ray",
    "Sidney",
    "Bernard",
    "Dan",
    "Jerry",
    "Calvin",
    "Perry",
    "Dave",
    "Anthony",
    "Eddie",
    "Amos",
    "Dennis",
    "Clifford",
    "Leroy",
    "Wesley",
    "Alonzo",
    "Garfield",
    "Franklin",
    "Emil",
    "Leon",
    "Nathan",
    "Harold",
    "Matthew",
    "Levi",
    "Moses",
    "Everett",
    "Lester",
    "Winfield",
    "Adam",
    "Lloyd",
    "Mack",
    "Fredrick",
    "Jay",
    "Jess",
    "Melvin",
    "Noah",
    "Aaron",
    "Alvin",
    "Norman",
    "Gilbert",
    "Elijah",
    "Victor",
    "Gus",
    "Nelson",
    "Jasper",
    "Silas",
    "Christopher",
    "Jake",
    "Mike",
    "Percy",
    "Adolph",
    "Maurice",
    "Cornelius",
    "Felix",
    "Reuben",
    "Wallace",
    "Claud",
    "Roscoe",
    "Sylvester",
    "Earnest",
    "Hiram",
    "Otis",
    "Simon",
    "Willard",
    "Irvin",
    "Mark",
    "Jose",
    "Wilbur",
    "Abraham",
    "Virgil",
    "Clinton",
    "Elbert",
    "Leslie",
    "Marshall",
    "Owen",
    "Wiley",
    "Anton",
    "Morris",
    "Manuel",
    "Phillip",
    "Augustus",
    "Emmett",
    "Eli"
  ];

  static final List<String> _surnames = [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Miller",
    "Davis",
    "Garcia",
    "Rodriguez",
    "Wilson",
    "Martinez",
    "Anderson",
    "Taylor",
    "Thomas",
    "Hernandez",
    "Moore",
    "Martin",
    "Jackson",
    "Thompson",
    "White",
    "Lopez",
    "Lee",
    "Gonzalez",
    "Harris",
    "Clark",
    "Lewis",
    "Robinson",
    "Walker",
    "Perez",
    "Hall",
    "Young",
    "Allen",
    "Sanchez",
    "Wright",
    "King",
    "Scott",
    "Green",
    "Baker",
    "Adams",
    "Nelson",
    "Hill",
    "Ramirez",
    "Campbell",
    "Mitchell",
    "Roberts",
    "Carter",
    "Phillips",
    "Evans",
    "Turner",
    "Torres",
    "Parker",
    "Collins",
    "Edwards",
    "Stewart",
    "Flores",
    "Morris",
    "Nguyen",
    "Murphy",
    "Rivera",
    "Cook",
    "Rogers",
    "Morgan",
    "Peterson",
    "Cooper",
    "Reed",
    "Bailey",
    "Bell",
    "Gomez",
    "Kelly",
    "Howard",
    "Ward",
    "Cox",
    "Diaz",
    "Richardson",
    "Wood",
    "Watson",
    "Brooks",
    "Bennett",
    "Gray",
    "James",
    "Reyes",
    "Cruz",
    "Hughes",
    "Price",
    "Myers",
    "Long",
    "Foster",
    "Sanders",
    "Ross",
    "Morales",
    "Powell",
    "Sullivan",
    "Russell",
    "Ortiz",
    "Jenkins",
    "Gutierrez",
    "Perry",
    "Butler",
    "Barnes",
    "Fisher",
    "Henderson",
    "Coleman",
    "Simmons",
    "Patterson",
    "Jordan",
    "Reynolds"
  ];

  static final List<String> _jobs = [
    "Veterinarian",
    "Firefighter",
    "Software Developer",
    "Registered Nurse",
    "Physician",
    "Dentist",
    "Engineer",
    "Financial Manager",
    "Lawyer",
    "Electrician",
    "Physician Assistant",
    "Police Officer",
    "Pharmacist",
    "Civil Engineer",
    "Nurse Practitioner",
    "Actuary",
    "Doctor",
    "Architect",
    "Accountant",
    "Air Traffic Controller",
    "Pilot",
    "Plumber",
    "Psychologist",
    "Physical Therapist",
    "Engineer",
    "Manager",
    "Hair Dresser",
    "Realtor"
  ];

  static final List<String> _companies = [
    "Apple",
    "Microsoft",
    "Saudi Aramco",
    "Alphabet (Google)",
    "Amazon",
    "Berkshire Hathaway",
    "NVIDIA",
    "Meta Platforms (Facebook)",
    "Tesla",
    "Johnson & Johnson",
    "Visa",
    "Exxon Mobil",
    "LVMH",
    "UnitedHealth",
    "TSMC",
    "Tencent",
    "Walmart",
    "JPMorgan Chase",
    "Eli Lilly",
    "Novo Nordisk",
    "Procter & Gamble",
    "Mastercard",
    "Nestlé",
    "Samsung",
    "Kweichow Moutai",
    "Chevron",
    "Home Depot",
    "Merck",
    "Coca-Cola",
    "AbbVie",
    "Pepsico",
    "Broadcom",
    "Oracle",
    "L'Oréal",
    "Roche",
    "ASML",
    "AstraZeneca",
    "International Holding Company",
    "Bank of America",
    "ICBC",
    "Hermès",
    "Alibaba",
    "Costco",
    "Pfizer",
    "Novartis",
    "McDonald",
    "Thermo Fisher Scientific",
    "Shell",
    "Reliance Industries",
    "PetroChina",
    "Salesforce",
    "Nike",
    "Cisco",
    "Abbott Laboratories",
    "China Mobile",
    "Walt Disney",
    "Toyota",
    "Linde",
    "Accenture",
    "Danaher",
    "Comcast",
    "T-Mobile US",
    "Adobe",
    "Agricultural Bank of China",
    "China Construction Bank",
    "Dior",
    "Verizon",
    "SAP",
    "TotalEnergies",
    "Philip Morris",
    "Nextera Energy",
    "United Parcel Service",
    "Wells Fargo",
    "Texas Instruments",
    "Morgan Stanley",
    "Prosus",
    "BHP Group",
    "CATL",
    "Netflix",
    "Raytheon Technologies",
    "Bank of China",
    "AMD",
    "HSBC",
    "Tata Consultancy Services",
    "Bristol-Myers Squibb",
    "Unilever",
    "Royal Bank Of Canada",
    "Ping An Insurance",
    "Sanofi",
    "Honeywell",
    "China Life Insurance",
    "Starbucks",
    "QUALCOMM",
    "Siemens",
    "HDFC Bank",
    "Intel",
    "Anheuser-Busch Inbev",
    "Amgen",
    "AT&T",
    "AIA"
  ];
}
