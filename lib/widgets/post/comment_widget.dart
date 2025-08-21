import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/comment_model.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';

class CommentWidget extends StatelessWidget {
  final CommentModel comment;

  const CommentWidget({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = comment.isAnonymous 
        ? Helpers.generateAnonymousUsername()
        : (comment.user?.displayName ?? comment.user?.username ?? 'Unknown User');
    
    final avatarUrl = comment.isAnonymous ? null : comment.user?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: comment.isAnonymous 
                ? AppColors.anonymous 
                : AppColors.primary,
            backgroundImage: avatarUrl != null 
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Icon(
                    comment.isAnonymous ? Icons.person_outline : Icons.person,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: comment.isAnonymous 
                              ? AppColors.anonymous 
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (comment.isAnonymous) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.visibility_off,
                          size: 10,
                          color: AppColors.anonymous,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        Helpers.formatTimeAgo(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInputWidget extends StatefulWidget {
  final Function(String content, bool isAnonymous) onSubmit;
  final bool isLoading;

  const CommentInputWidget({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: widget.isLoading 
                      ? null 
                      : (value) {
                          setState(() {
                            _isAnonymous = value ?? false;
                          });
                        },
                  activeColor: AppColors.anonymous,
                ),
                Text(
                  'Comment anonymously',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      maxLength: 200,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        counterText: '',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: widget.isLoading || _controller.text.trim().isEmpty
                        ? null
                        : _submitComment,
                    icon: widget.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    widget.onSubmit(content, _isAnonymous);
    _controller.clear();
    setState(() {
      _isAnonymous = false;
    });
  }
}