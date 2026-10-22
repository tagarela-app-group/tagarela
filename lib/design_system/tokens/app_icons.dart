import 'package:flutter/material.dart';

/// Único ponto de ícones do app. Trocar o pacote de ícones = mexer só aqui.
abstract final class AppIcons {
  // Navegação
  static const home = Icons.home_outlined;
  static const vocabulary = Icons.style_outlined;
  static const inbox = Icons.inbox_outlined;
  static const profile = Icons.person_outline_rounded;
  static const back = Icons.chevron_left_rounded;
  static const more = Icons.more_vert_rounded;

  // Ações
  static const add = Icons.add_rounded;
  static const search = Icons.search_rounded;
  static const listen = Icons.volume_up_outlined;
  static const play = Icons.play_arrow_rounded;
  static const newGroup = Icons.create_new_folder_outlined;
  static const review = Icons.autorenew_rounded;
  static const showPassword = Icons.visibility_outlined;
  static const hidePassword = Icons.visibility_off_outlined;

  // Captura
  static const camera = Icons.photo_camera_outlined;
  static const audio = Icons.mic_none_rounded;
  static const text = Icons.title_rounded;

  // Estado e campos
  static const streak = Icons.local_fire_department_rounded;
  static const offline = Icons.wifi_off_rounded;
  static const mail = Icons.mail_outline_rounded;
  static const lock = Icons.lock_outline_rounded;
  static const chat = Icons.chat_bubble_rounded;

  // Grupos
  static const travel = Icons.flight_rounded;
  static const work = Icons.work_outline_rounded;
  static const layers = Icons.layers_outlined;
  static const talk = Icons.chat_bubble_outline_rounded;
  static const tv = Icons.live_tv_outlined;
  static const food = Icons.coffee_outlined;
}
