// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'payload.dart';
abstract class IMqttListener
{
  onMqttData({Payload? payload});
}