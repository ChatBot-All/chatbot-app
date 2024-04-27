import 'base.dart';

bool isDebug = !kReleaseMode;
bool isAndroid = Platform.isAndroid;
bool isIOS = Platform.isIOS;
bool productMode = false;

const ttsModelKey = "tts-";
const whisperModelKey = "whisper-";
const dallModelKey = "dall-e-";