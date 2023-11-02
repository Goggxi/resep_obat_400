import 'package:intl/intl.dart';

extension ExtDateFormat on DateTime {
  String get toDate {
    return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(this);
  }

  String get toTime {
    return DateFormat('HH.mm', 'id_ID').format(this);
  }

  String get toDateTime {
    return DateFormat("EEEE, dd MMMM yyyy HH:mm", "id_ID").format(this);
  }

  String get toDateTimeDash {
    return DateFormat("yyyy-MM-dd", "id_ID").format(this);
  }
}
