import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../services/app_state.dart';

const _ink = Color(0xFF151B2D);
const _mutedInk = Color(0xFF778198);
const _violet = Color(0xFF665BFF);
const _mint = Color(0xFF35C9B2);
const _canvas = Color(0xFFF5F7FB);

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final conversation = state.selectedConversation;

    return Scaffold(
      backgroundColor: _canvas,
      drawer: isWide
          ? null
          : const Drawer(
              backgroundColor: Color(0xFF151B2D),
              child: _Sidebar(isWide: false),
            ),
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: Colors.transparent,
        titleSpacing: isWide ? 28 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation?.title ?? 'Votre espace IA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Chatboot  ·  assistant intelligent',
              style: TextStyle(
                color: _mutedInk,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: FilledButton.icon(
                onPressed: () => _createConversation(context, state),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nouvelle conversation'),
                style: FilledButton.styleFrom(
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Nouvelle conversation',
              onPressed: () => _createConversation(context, state),
              icon: const Icon(Icons.add_comment_outlined),
            ),
          PopupMenuButton<String>(
            tooltip: 'Options de conversation',
            onSelected: (value) async {
              if (value == 'logout') {
                await state.logout();
              } else if (value == 'rename' && conversation != null) {
                if (context.mounted) {
                  _showRenameDialog(context, state, conversation);
                }
              } else if (value == 'delete' && conversation != null) {
                await state.deleteConversation(conversation);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Renommer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 10),
                    Text('Supprimer'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 10),
                    Text('Se déconnecter'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isWide) const SizedBox(width: 286, child: _Sidebar(isWide: true)),
          Expanded(child: _ChatPanel(conversation: conversation)),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    AppState state,
    Conversation conversation,
  ) {
    final controller = TextEditingController(text: conversation.title);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renommer la conversation'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await state.renameConversation(conversation, controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

Future<void> _createConversation(BuildContext context, AppState state) async {
  try {
    await state.createConversation();
  } on Exception catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation créée ici, mais non synchronisée : $error'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF151B2D), Color(0xFF202442)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 18, 24),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_violet, _mint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chatboot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'VOTRE ESPACE IA',
                        style: TextStyle(
                          color: Color(0xFF9BA5C1),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                key: const ValueKey('sidebar-new-conversation'),
                onPressed: () async {
                  await _createConversation(context, state);
                  if (!isWide && context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nouvelle conversation'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 30, 18, 10),
              child: Text(
                'RÉCENT',
                style: TextStyle(
                  color: Color(0xFF9BA5C1),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Expanded(
              child: state.conversations.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Vos conversations apparaîtront ici.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9BA5C1),
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: state.conversations.length,
                      itemBuilder: (_, index) {
                        final conversation = state.conversations[index];
                        final selected =
                            conversation.id == state.selectedConversationId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            color: selected
                                ? const Color(0xFF303653)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selected: selected,
                              selectedTileColor: Colors.transparent,
                              leading: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: selected
                                    ? const Color(0xFFBEB7FF)
                                    : const Color(0xFF9BA5C1),
                              ),
                              title: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFFD8DCEC),
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                '${conversation.messages.length} messages',
                                style: const TextStyle(
                                  color: Color(0xFF9BA5C1),
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () {
                                state.selectConversation(conversation.id);
                                if (!isWide) Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: Color(0x333C4562)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF3B4261),
                    child: Text(
                      (state.currentEmail?.isNotEmpty ?? false)
                          ? state.currentEmail![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.currentEmail ?? 'Utilisateur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Se déconnecter',
                    onPressed: state.logout,
                    icon: const Icon(Icons.logout_rounded, size: 19),
                    color: const Color(0xFFB8C0D6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.conversation});

  final Conversation? conversation;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    context.read<AppState>().sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conversation = widget.conversation;

    if (conversation == null) {
      return _WelcomePanel(
        onCreate: () => _createConversation(context, state),
      );
    }

    final messages = conversation.messages;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FD), _canvas],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const _ConversationStarter()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    itemCount: messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (index == messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 44, top: 8),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: _violet,
                              ),
                            ),
                          ),
                        );
                      }
                      return _MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            isSending: state.isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FD), Color(0xFFEEF1FA)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _AssistantMark(size: 76),
              const SizedBox(height: 26),
              Text(
                'Votre prochaine idée commence ici.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Créez une conversation et explorez tout ce que Chatboot peut faire.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedInk, height: 1.5),
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Démarrer une conversation'),
                style: FilledButton.styleFrom(
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationStarter extends StatelessWidget {
  const _ConversationStarter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AssistantMark(size: 64),
            const SizedBox(height: 20),
            Text(
              'Que voulez-vous explorer ?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Posez une question, partagez une idée ou commencez par ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedInk),
            ),
            const SizedBox(height: 24),
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _SuggestionChip(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Trouver une idée',
                ),
                _SuggestionChip(
                  icon: Icons.edit_note_rounded,
                  label: 'Écrire quelque chose',
                ),
                _SuggestionChip(
                  icon: Icons.school_outlined,
                  label: 'Apprendre un sujet',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMark extends StatelessWidget {
  const _AssistantMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, Color(0xFF988BFF), _mint],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: _violet.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.46,
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7EAF2)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F1830),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: _violet),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_violet, Color(0xFF5548E8)],
              )
            : null,
        color: isUser ? null : Colors.white,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isUser ? const Radius.circular(6) : null,
          bottomLeft: isUser ? null : const Radius.circular(6),
        ),
        border: isUser ? null : Border.all(color: const Color(0xFFE9ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x090F1830),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isUser ? Colors.white : _ink,
          height: 1.55,
          fontSize: 14,
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: bubble,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 10),
            child: _AssistantMark(size: 30),
          ),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 7, 8, 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE6E9F1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C192341),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Écrivez votre message...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Envoyer le message',
                    onPressed: isSending ? null : onSend,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(46, 46),
                      backgroundColor: _violet,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
