/// 工单基本信息
class Ticket {
  final int id;
  final int level; // 优先级: 0=低, 1=中, 2=高
  final int replyStatus; // 回复状态: 0=已回复, 1=等待回复
  final int status; // 工单状态: 0=处理中, 1=已关闭
  final String subject;
  final String? message;
  final int createdAt;
  final int updatedAt;
  final int userId;

  Ticket({
    required this.id,
    required this.level,
    required this.replyStatus,
    required this.status,
    required this.subject,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      level: json['level'] as int,
      replyStatus: json['reply_status'] as int,
      status: json['status'] as int,
      subject: json['subject'] as String,
      message: json['message'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'reply_status': replyStatus,
      'status': status,
      'subject': subject,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
    };
  }
}

/// 工单消息
class TicketMessage {
  final int id;
  final int ticketId;
  final bool isMe;
  final String message;
  final int createdAt;
  final int updatedAt;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.isMe,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      isMe: json['is_me'] == true,
      message: json['message'] as String,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'is_me': isMe,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// 工单详情（含消息列表）
class TicketDetail {
  final int id;
  final int level;
  final int replyStatus;
  final int status;
  final String subject;
  final List<TicketMessage> messages;
  final int createdAt;
  final int updatedAt;
  final int userId;

  TicketDetail({
    required this.id,
    required this.level,
    required this.replyStatus,
    required this.status,
    required this.subject,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['message'] as List?)?.map((e) => TicketMessage.fromJson(e)).toList() ?? [];
    return TicketDetail(
      id: json['id'] as int,
      level: json['level'] as int,
      replyStatus: json['reply_status'] as int,
      status: json['status'] as int,
      subject: json['subject'] as String,
      messages: messagesList,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'reply_status': replyStatus,
      'status': status,
      'subject': subject,
      'message': messages.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
    };
  }
} 