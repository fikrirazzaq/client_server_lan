import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Message extends Equatable {
  final String sender;
  final bool isSystem;
  final String message;

  Message(this.sender, this.isSystem, this.message);
  Message.fromUser(this.sender, this.message) : isSystem = false;
  Message.fromSystem(this.message)
      : sender = 'System',
        isSystem = true;

  @override
  List<Object> get props => [sender, isSystem, message];
}
