import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../services/app_state.dart';

const _paper = Color(0xFFF7F5EF);
const _card = Color(0xFFFFFEFB);
const _ink = Color(0xFF252923);
const _muted = Color(0xFF777D74);
const _green = Color(0xFF246B56);
const _orange = Color(0xFFE78355);
const _line = Color(0xFFE8E5DC);

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final conversation = state.selectedConversation;

    return Scaffold(
      backgroundColor: _paper,
      drawer: isWide
          ? null
          : const Drawer(
              backgroundColor: _card,
              child: _Sidebar(isWide: false),
            ),
      appBar: AppBar(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        titleSpacing: isWide ? 28 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation?.title ?? 'Chatboot',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Votre espace de discussion',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: FilledButton.icon(
                onPressed: () => _createConversation(context, state),
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Nouveau chat'),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
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
            tooltip: 'Options',
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
              const PopupMenuItem(value: 'rename', child: Text('Renommer')),
              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Se déconnecter'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isWide) const SizedBox(width: 258, child: _Sidebar(isWide: true)),
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

    return Container(
      decoration: const BoxDecoration(
        color: _card,
        border: Border(right: BorderSide(color: _line)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 22),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chatboot',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Simplement, à vos côtés.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: FilledButton.icon(
                key: const ValueKey('sidebar-new-conversation'),
                onPressed: () async {
                  await _createConversation(context, state);
                  if (!isWide && context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Nouvelle conversation'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 16, 10),
              child: Text(
                'CONVERSATIONS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: state.conversations.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Text(
                          'Vos échanges récents apparaîtront ici.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted, height: 1.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      itemCount: state.conversations.length,
                      itemBuilder: (_, index) {
                        final conversation = state.conversations[index];
                        final selected =
                            conversation.id == state.selectedConversationId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Material(
                            color: selected
                                ? const Color(0xFFEAF2ED)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              selected: selected,
                              selectedTileColor: Colors.transparent,
                              leading: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: selected ? _green : _muted,
                              ),
                              title: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected ? _green : _ink,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: Text(
                                '${conversation.messages.length} messages',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
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
            const Divider(height: 1, color: _line),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFFEAF2ED),
                    foregroundColor: _green,
                    child: Text(
                      state.currentEmail != null &&
                              state.currentEmail!.isNotEmpty
                          ? state.currentEmail![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      state.currentEmail ?? 'Utilisateur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _ink, fontSize: 11),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Se déconnecter',
                    onPressed: state.logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    color: _muted,
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
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _usePrompt(String prompt) {
    _controller.text = prompt;
    _focusNode.requestFocus();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final warning = await context.read<AppState>().sendMessage(text);
    if (warning != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(warning), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conversation = widget.conversation;

    if (conversation == null) {
      return _WelcomePanel(
        key: const ValueKey('no-conversation'),
        onCreate: () => _createConversation(context, state),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return _ConversationView(
      key: ValueKey(conversation.id),
      conversation: conversation,
      isSending: state.isSending,
      controller: _controller,
      focusNode: _focusNode,
      scrollController: _scrollController,
      onSend: _send,
      onUsePrompt: _usePrompt,
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _paper,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 14 * (1 - value)),
                child: child,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2ED),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: _green,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 23),
                Text(
                  'Une idée à explorer ?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Créez un espace de discussion et commencez quand vous voulez.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, height: 1.5),
                ),
                const SizedBox(height: 23),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Commencer un nouveau chat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView({
    super.key,
    required this.conversation,
    required this.isSending,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.onSend,
    required this.onUsePrompt,
  });

  final Conversation conversation;
  final bool isSending;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final ValueChanged<String> onUsePrompt;

  @override
  Widget build(BuildContext context) {
    final messages = conversation.messages;

    return Container(
      color: _paper,
      child: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              child: messages.isEmpty
                  ? _ConversationStarter(
                      key: ValueKey('starter-${conversation.id}'),
                      email: context.read<AppState>().currentEmail,
                      onUsePrompt: onUsePrompt,
                    )
                  : ListView.builder(
                      key: ValueKey('messages-${conversation.id}'),
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                      itemCount: messages.length,
                      itemBuilder: (_, index) => _MessageBubble(
                        key: ValueKey(
                          '${messages[index].createdAt.microsecondsSinceEpoch}-${messages[index].role}',
                        ),
                        message: messages[index],
                      ),
                    ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isSending
                ? const _ThinkingStatus(key: ValueKey('thinking'))
                : const SizedBox(key: ValueKey('idle'), height: 8),
          ),
          _Composer(
            controller: controller,
            focusNode: focusNode,
            isSending: isSending,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}

class _ConversationStarter extends StatelessWidget {
  const _ConversationStarter({
    super.key,
    required this.email,
    required this.onUsePrompt,
  });

  final String? email;
  final ValueChanged<String> onUsePrompt;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
        ? 'Bon après-midi'
        : 'Bonsoir';
    final name = email?.split('@').first;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name == null ? '$greeting !' : '$greeting, $name',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Qu’aimeriez-vous faire aujourd’hui ?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisissez une idée pour la placer dans votre message, ou écrivez le vôtre.',
                style: TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PromptCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Faire naître une idée',
                    subtitle: 'Brainstorming, projets, inspiration',
                    onTap: () => onUsePrompt(
                      'Aide-moi à trouver une idée originale pour ',
                    ),
                  ),
                  _PromptCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Écrire et améliorer',
                    subtitle: 'Un texte clair, à mon image',
                    onTap: () =>
                        onUsePrompt('Aide-moi à rédiger et améliorer '),
                  ),
                  _PromptCard(
                    icon: Icons.school_outlined,
                    title: 'Comprendre un sujet',
                    subtitle: 'Une explication simple et utile',
                    onTap: () => onUsePrompt('Explique-moi simplement '),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218,
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: _green, size: 20),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isError = message.role == 'error';
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 700),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isUser
            ? _green
            : isError
            ? const Color(0xFFFFF1E8)
            : _card,
        border: isUser
            ? null
            : Border.all(color: isError ? const Color(0xFFF2D3C0) : _line),
        borderRadius: BorderRadius.circular(17).copyWith(
          bottomRight: isUser ? const Radius.circular(5) : null,
          bottomLeft: isUser ? null : const Radius.circular(5),
        ),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isUser
              ? Colors.white
              : isError
              ? const Color(0xFF814A2F)
              : _ink,
          height: 1.55,
          fontSize: 14,
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(isUser ? 12 * (1 - value) : -12 * (1 - value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: isUser
            ? Align(alignment: Alignment.centerRight, child: bubble)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 9),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: isError
                          ? const Color(0xFFFFE4D4)
                          : const Color(0xFFEAF2ED),
                      child: Icon(
                        isError ? Icons.info_outline : Icons.forum_outlined,
                        color: isError ? _orange : _green,
                        size: 16,
                      ),
                    ),
                  ),
                  Flexible(child: bubble),
                ],
              ),
      ),
    );
  }
}

class _ThinkingStatus extends StatelessWidget {
  const _ThinkingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(strokeWidth: 2, color: _green),
          ),
          const SizedBox(width: 9),
          Text(
            'Chatboot réfléchit…',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: _green, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 7, 7, 7),
              decoration: BoxDecoration(
                color: _card,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C2A342C),
                    blurRadius: 16,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Écrivez votre message…',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSending ? _muted : _green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Envoyer le message',
                      onPressed: isSending ? null : onSend,
                      color: Colors.white,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: isSending
                            ? const SizedBox(
                                key: ValueKey('send-progress'),
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                key: ValueKey('send-icon'),
                                size: 20,
                              ),
                      ),
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
