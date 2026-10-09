import 'package:flutter/material.dart';
import '../data/models/post.dart';

/// Satu baris post: avatar id, judul, dan (opsional) cuplikan isi.
/// Dipakai ulang oleh halaman biasa dan halaman paged.
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onTap,
    this.showBody = true,
  });

  final Post post;
  final VoidCallback? onTap;

  /// false untuk tampilan ringkas (hanya judul), seperti di halaman paged.
  final bool showBody;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showBody
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}