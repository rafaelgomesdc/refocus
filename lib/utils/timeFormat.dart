Map<String, int> convertMili(int? tempo) {
  int conv = 0;

  if (tempo != null && tempo > 0) {
    conv = (tempo / 60000).toInt(); // Converte em minutos
  }

  var time = {
    'h': 0,
    'm': 0
  };

  if (conv <= 0) {
    return time;
  }
  else if (conv > 0 && conv < 60) {
    time['m'] = conv;
  }
  else if (conv >= 60) {
    int hora = (conv ~/ 60).toInt();
    int minuto = (conv % 60).toInt();

    time['h'] = hora;
    time['m'] = minuto;
  }

  return time;
}

String timeFormat(int tempo) {
  Map<String, int> conv = convertMili(tempo);
  String text = "${conv['h']}h${conv['m']}";

  if (conv['m']! < 10) {
    text = "${conv['h']}h0${conv['m']}";
  }

  return text;
}