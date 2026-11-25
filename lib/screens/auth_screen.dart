import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

const _night = Color(0xFF11182A);
const _violet = Color(0xFF665BFF);
const _mint = Color(0xFF35C9B2);
const _muted = Color(0xFF8992A8);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isRegister = false;
  bool _obscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final state = context.read<AppState>();
    try {
      final error = _isRegister
          ? await state.register(
              _emailController.text,
              _passwordController.text,
              _confirmController.text,
            )
          : await state.login(
              _emailController.text,
              _passwordController.text,
            );
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _night,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF10172A),
                    Color(0xFF171A36),
                    Color(0xFF102A36),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -150,
            right: -100,
            child: _GlowOrb(color: _violet.withValues(alpha: 0.2), size: 390),
          ),
          Positioned(
            bottom: -180,
            left: -120,
            child: _GlowOrb(color: _mint.withValues(alpha: 0.12), size: 420),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 860;
                final content = isWide
                    ? Row(
                        children: [
                          const Expanded(child: _BrandPanel()),
                          const SizedBox(width: 56),
                          SizedBox(width: 420, child: _buildFormCard(context)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _CompactBrand(),
                          const SizedBox(height: 28),
                          _buildFormCard(context),
                        ],
                      );

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 48 : 22,
                    vertical: 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 32, 30, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 42,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isRegister ? 'Créer un compte' : 'Bon retour',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF171D31),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              _isRegister
                  ? 'Rejoignez votre nouvel espace de conversation.'
                  : 'Connectez-vous pour retrouver vos conversations.',
              style: const TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: _inputDecoration(
                label: 'Adresse e-mail',
                icon: Icons.alternate_email_rounded,
              ),
              validator: (value) =>
                  value == null || !value.contains('@')
                      ? 'Veuillez saisir une adresse e-mail valide.'
                      : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              autofillHints: _isRegister
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              decoration: _inputDecoration(
                label: 'Mot de passe',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _obscure
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => value == null || value.length < 6
                  ? 'Le mot de passe doit contenir au moins 6 caractères.'
                  : null,
            ),
            if (_isRegister) ...[
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure,
                decoration: _inputDecoration(
                  label: 'Confirmer le mot de passe',
                  icon: Icons.verified_user_outlined,
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Les mots de passe ne correspondent pas.'
                    : null,
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isRegister ? 'Créer mon compte' : 'Se connecter',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() => _isRegister = !_isRegister),
              child: Text(
                _isRegister
                    ? 'Déjà inscrit ? Se connecter'
                    : 'Nouveau ici ? Créer un compte',
                style: const TextStyle(
                  color: _violet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 15, color: _muted),
                SizedBox(width: 6),
                Text(
                  'Connexion sécurisée avec Firebase',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6E9F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6E9F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _violet, width: 1.5),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BrandLockup(),
          const SizedBox(height: 54),
          const Text(
            'Vos idées.\nEn plus grand.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.6,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Un espace intelligent pour réfléchir, créer et avancer. '
            'Votre prochain projet commence par une conversation.',
            style: TextStyle(
              color: Color(0xFFB6BED2),
              fontSize: 16,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 34),
          const _FeatureLine(
            icon: Icons.bolt_rounded,
            text: 'Des réponses pour aller plus loin',
          ),
          const SizedBox(height: 16),
          const _FeatureLine(
            icon: Icons.forum_outlined,
            text: 'Vos conversations organisées au même endroit',
          ),
          const SizedBox(height: 16),
          const _FeatureLine(
            icon: Icons.devices_outlined,
            text: 'Une expérience simple sur tous vos écrans',
          ),
        ],
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: _BrandLockup(),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_violet, _mint],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _violet.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24,
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'THINK · CREATE · GROW',
              style: TextStyle(
                color: Color(0xFF9BA5BD),
                fontSize: 9,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _mint, size: 18),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE0E4EF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
