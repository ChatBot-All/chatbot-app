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
        content!.add(new Content.fromJson(v));
      });
    }
    model = json['model'];
    stopReason = json['stop_reason'];
    stopSequence = json['stop_sequence'];
    usage = json['usage'] != null ? new Usage.fromJson(json['usage']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }
    data['model'] = this.model;
    data['stop_reason'] = this.stopReason;
    data['stop_sequence'] = this.stopSequence;
    if (this.usage != null) {
      data['usage'] = this.usage!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['input_tokens'] = this.inputTokens;
    data['output_tokens'] = this.outputTokens;
    return data;
  }
}
