// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "alias_desc": MessageLookupByLibrary.simpleMessage(
            "Alias is used to distinguish different models"),
        "alias_empty":
            MessageLookupByLibrary.simpleMessage("Alias cannot be empty"),
        "alias_input":
            MessageLookupByLibrary.simpleMessage("Please enter an alias"),
        "alias_maxlength": MessageLookupByLibrary.simpleMessage(
            "Alias cannot exceed 10 characters"),
        "alias_repeat":
            MessageLookupByLibrary.simpleMessage("Alias cannot be repeated"),
        "alias_required":
            MessageLookupByLibrary.simpleMessage("Alias(required)"),
        "apikey_repeat":
            MessageLookupByLibrary.simpleMessage("API Key cannot be repeated"),
        "app_name": MessageLookupByLibrary.simpleMessage("ChatBot"),
        "auto_title":
            MessageLookupByLibrary.simpleMessage("Auto Generate Title"),
        "btn_add": MessageLookupByLibrary.simpleMessage("Add"),
        "canPaint": MessageLookupByLibrary.simpleMessage("paint"),
        "canTalk": MessageLookupByLibrary.simpleMessage("talk"),
        "canVoice": MessageLookupByLibrary.simpleMessage("voice"),
        "can_not_get_voice_content":
            MessageLookupByLibrary.simpleMessage("No voice content recognized"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "canceling": MessageLookupByLibrary.simpleMessage("canceling..."),
        "cannot_empty": MessageLookupByLibrary.simpleMessage("Cannot be empty"),
        "chat_setting": MessageLookupByLibrary.simpleMessage("Chat Setting"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "conform_resend": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to resend this message?"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copy_success": MessageLookupByLibrary.simpleMessage("Copy success"),
        "default1": MessageLookupByLibrary.simpleMessage("Default"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_config_reminder": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this configuration?"),
        "delete_reminder": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this message?"),
        "downloading": MessageLookupByLibrary.simpleMessage("Downloading..."),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "empty_content_need_add": MessageLookupByLibrary.simpleMessage(
            "The content is empty, please add content"),
        "enter_setting_init_server": MessageLookupByLibrary.simpleMessage(
            "Please enter the service first and configure the service provider"),
        "feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "feedback_question": MessageLookupByLibrary.simpleMessage(
            "What do you think of ChatBot?"),
        "gemini_setting": MessageLookupByLibrary.simpleMessage("Gemini Server"),
        "gemini_setting_desc": MessageLookupByLibrary.simpleMessage(
            "Set the API key and API Server of Gemini"),
        "generate_content_is_empty": MessageLookupByLibrary.simpleMessage(
            "The generated content is empty"),
        "generate_image":
            MessageLookupByLibrary.simpleMessage("Generate Image"),
        "generate_image_fail":
            MessageLookupByLibrary.simpleMessage("Generate image fail"),
        "getmodules_fail":
            MessageLookupByLibrary.simpleMessage("Failed to get models"),
        "has_reduce": MessageLookupByLibrary.simpleMessage("Has been reduced"),
        "hint_addServerDesc":
            MessageLookupByLibrary.simpleMessage("Type server address"),
        "hold_micro_phone_talk": MessageLookupByLibrary.simpleMessage(
            "Hold the bottom microphone to talk"),
        "hold_talk": MessageLookupByLibrary.simpleMessage("Hold to speak"),
        "home_chat": MessageLookupByLibrary.simpleMessage("Chat"),
        "home_factory": MessageLookupByLibrary.simpleMessage("Library"),
        "home_server": MessageLookupByLibrary.simpleMessage("Server"),
        "home_setting": MessageLookupByLibrary.simpleMessage("Setting"),
        "input_name":
            MessageLookupByLibrary.simpleMessage("Please enter a name"),
        "input_text": MessageLookupByLibrary.simpleMessage("Type text here"),
        "is_getting_modules":
            MessageLookupByLibrary.simpleMessage("Getting models..."),
        "is_responsing":
            MessageLookupByLibrary.simpleMessage("The server is responding..."),
        "leave_cancel": MessageLookupByLibrary.simpleMessage("Release Cancel"),
        "leave_send": MessageLookupByLibrary.simpleMessage("Release Send"),
        "library": MessageLookupByLibrary.simpleMessage("Library"),
        "models": MessageLookupByLibrary.simpleMessage("Model"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "natural": MessageLookupByLibrary.simpleMessage("Natural"),
        "new_chat": MessageLookupByLibrary.simpleMessage("New Chat"),
        "new_version": MessageLookupByLibrary.simpleMessage("New version"),
        "no_audio_file":
            MessageLookupByLibrary.simpleMessage("Unable to obtain voice file"),
        "no_module_use":
            MessageLookupByLibrary.simpleMessage("No model available"),
        "not_support_tts": MessageLookupByLibrary.simpleMessage(
            "The current model does not support TTS"),
        "official": MessageLookupByLibrary.simpleMessage("Official"),
        "only_support_dalle3":
            MessageLookupByLibrary.simpleMessage("Only support DALL-E 3"),
        "open_micro_permission": MessageLookupByLibrary.simpleMessage(
            "Please enable recording permission"),
        "openai_setting":
            MessageLookupByLibrary.simpleMessage("ChatGPT Server"),
        "openai_setting_desc": MessageLookupByLibrary.simpleMessage(
            "Set the API key and API Server of ChatGPT"),
        "org_notrequired":
            MessageLookupByLibrary.simpleMessage("Organization(optional)"),
        "other_set": MessageLookupByLibrary.simpleMessage("Other Settings"),
        "recording": MessageLookupByLibrary.simpleMessage("recording..."),
        "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
        "resend": MessageLookupByLibrary.simpleMessage("Resend"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "save_fail": MessageLookupByLibrary.simpleMessage("Save fail"),
        "save_gallary": MessageLookupByLibrary.simpleMessage("Save to Gallery"),
        "save_success": MessageLookupByLibrary.simpleMessage("Save success"),
        "select": MessageLookupByLibrary.simpleMessage("Select"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "send_again": MessageLookupByLibrary.simpleMessage("Send again"),
        "sending_server":
            MessageLookupByLibrary.simpleMessage("Sending to server..."),
        "servers": MessageLookupByLibrary.simpleMessage("Server"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "size": MessageLookupByLibrary.simpleMessage("Size"),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "tempture": MessageLookupByLibrary.simpleMessage("Temperature"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "theme_auto": MessageLookupByLibrary.simpleMessage("Follow System"),
        "theme_dark": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "theme_normal": MessageLookupByLibrary.simpleMessage("Light Mode"),
        "theme_setting": MessageLookupByLibrary.simpleMessage("Theme Setting"),
        "third_party": MessageLookupByLibrary.simpleMessage("Third"),
        "title_promot": MessageLookupByLibrary.simpleMessage(
            "Use four to five words to directly return to the brief topic of this sentence. No explanations, no punctuation, no modal particles, no redundant text, and no bolding. If there is no topic, please directly return to \"small talk\""),
        "tts": MessageLookupByLibrary.simpleMessage("Deacon"),
        "update_now": MessageLookupByLibrary.simpleMessage("Update now"),
        "validate": MessageLookupByLibrary.simpleMessage("Validate"),
        "validate_fail":
            MessageLookupByLibrary.simpleMessage("Validation fail"),
        "validate_success":
            MessageLookupByLibrary.simpleMessage("Validation success"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "vivid": MessageLookupByLibrary.simpleMessage("Vivid"),
        "voiceChat": MessageLookupByLibrary.simpleMessage("Voice Chat"),
        "yes_know": MessageLookupByLibrary.simpleMessage("Got it"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday")
      };
}
