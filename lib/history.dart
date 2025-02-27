class History{
  String method;
  String time;

  History({required this.method, required this.time});
  factory History.fromJson(Map<String, dynamic> json){
    return History(method: json['Method'], time: json['Time']);
  }
}