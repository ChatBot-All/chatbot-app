class ClaudeContentBean {
  String? id;
  List<Content>? content;
  String? model;
  String? stopReason;
  String? stopSequence;
  Usage? usage;

  ClaudeContentBean(
      {this.id,
        this.content,
        this.model,
        this.stopReason,
        this.stopSequence,
        this.usage});

  ClaudeContentBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['content'] != null) {
      content = <Content>[];
      json['content'].forEach((v) {
        content!.add(Content.fromJson(v));
      });
    }
    model = json['model'];
    stopReason = json['stop_reason'];
    stopSequence = json['stop_sequence'];
    usage = json['usage'] != null ? Usage.fromJson(json['usage']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (content != null) {
      data['content'] = content!.map((v) => v.toJson()).toList();
    }
    data['model'] = model;
    data['stop_reason'] = stopReason;
    data['stop_sequence'] = stopSequence;
    if (usage != null) {
      data['usage'] = usage!.toJson();
    }
    return data;
  }
}

class Content {
  String? text;

  Content({this.text});

  Content.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

class Usage {
  int? inputTokens;
  int? outputTokens;

  Usage({this.inputTokens, this.outputTokens});

  Usage.fromJson(Map<String, dynamic> json) {
    inputTokens = json['input_tokens'];
    outputTokens = json['output_tokens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_tokens'] = inputTokens;
    data['output_tokens'] = outputTokens;
    return data;
  }
}
