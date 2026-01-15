'use client';

import { useState } from 'react';
import { Reply, Pencil, Trash2 } from 'lucide-react';
import { Comment, VoteType } from '@/types/forum';
import { formatDistanceToNow } from '@/lib/utils';
import { VoteButtons } from './VoteButtons';

interface CommentThreadProps {
  comments: Comment[];
  onVote: (commentId: string, voteType: VoteType) => void;
  onReply: (commentId: string, content: string) => void;
  onEdit?: (commentId: string, content: string) => void;
  onDelete?: (commentId: string) => void;
  currentUserId?: string;
}

export function CommentThread({
  comments,
  onVote,
  onReply,
  onEdit,
  onDelete,
  currentUserId,
}: CommentThreadProps) {
  return (
    <div className="space-y-6">
      {comments.map((comment) => (
        <CommentItem
          key={comment.id}
          comment={comment}
          onVote={onVote}
          onReply={onReply}
          onEdit={onEdit}
          onDelete={onDelete}
          currentUserId={currentUserId}
        />
      ))}
    </div>
  );
}

interface CommentItemProps {
  comment: Comment;
  onVote: (commentId: string, voteType: VoteType) => void;
  onReply: (commentId: string, content: string) => void;
  onEdit?: (commentId: string, content: string) => void;
  onDelete?: (commentId: string) => void;
  currentUserId?: string;
}

function CommentItem({
  comment,
  onVote,
  onReply,
  onEdit,
  onDelete,
  currentUserId,
}: CommentItemProps) {
  const [isReplying, setIsReplying] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [replyContent, setReplyContent] = useState('');
  const [editContent, setEditContent] = useState(comment.content);

  const isOwner = currentUserId === comment.author.id;

  const handleSubmitReply = () => {
    if (replyContent.trim()) {
      onReply(comment.id, replyContent.trim());
      setReplyContent('');
      setIsReplying(false);
    }
  };

  const handleSubmitEdit = () => {
    if (editContent.trim() && editContent !== comment.content) {
      onEdit?.(comment.id, editContent.trim());
      setIsEditing(false);
    } else {
      setIsEditing(false);
    }
  };

  return (
    <div className={`${comment.depth > 0 ? 'ml-8 pl-6 border-l-2 border-white/5' : ''}`}>
      <div className="flex gap-4">
        <VoteButtons
          voteCount={comment.voteCount}
          userVote={comment.userVote}
          onVote={(voteType) => onVote(comment.id, voteType)}
          size="sm"
        />

        <div className="flex-1 min-w-0">
          {/* Meta */}
          <div className="flex items-center gap-2 mb-2">
            <span className="text-[10px] font-black uppercase tracking-widest text-cyan-400">
              u/{comment.author.username}
            </span>
            <span className="text-neutral-700">•</span>
            <span className="text-[10px] text-neutral-600">{formatDistanceToNow(comment.createdAt)}</span>
            {comment.updatedAt !== comment.createdAt && (
              <>
                <span className="text-neutral-700">•</span>
                <span className="text-[10px] text-neutral-600 italic">edited</span>
              </>
            )}
          </div>

          {/* Content */}
          {isEditing ? (
            <div className="space-y-3">
              <textarea
                value={editContent}
                onChange={(e) => setEditContent(e.target.value)}
                className="w-full bg-neutral-900/50 border border-white/10 rounded-xl p-4 text-sm text-white placeholder-neutral-600 focus:border-cyan-500/50 focus:outline-none resize-none"
                rows={4}
              />
              <div className="flex gap-3">
                <button
                  onClick={handleSubmitEdit}
                  className="px-4 py-2 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-lg hover:bg-cyan-400 transition-all"
                >
                  Save
                </button>
                <button
                  onClick={() => {
                    setIsEditing(false);
                    setEditContent(comment.content);
                  }}
                  className="px-4 py-2 text-neutral-500 text-[10px] font-black uppercase tracking-widest hover:text-white transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          ) : (
            <p className="text-neutral-300 text-sm leading-relaxed whitespace-pre-wrap">
              {comment.content}
            </p>
          )}

          {/* Actions */}
          {!isEditing && (
            <div className="flex items-center gap-2 mt-3">
              <button
                onClick={() => setIsReplying(!isReplying)}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-600 hover:bg-white/5 hover:text-cyan-400 transition-all"
              >
                <Reply size={12} />
                Reply
              </button>
              {isOwner && onEdit && (
                <button
                  onClick={() => setIsEditing(true)}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-600 hover:bg-white/5 hover:text-white transition-all"
                >
                  <Pencil size={12} />
                  Edit
                </button>
              )}
              {isOwner && onDelete && (
                <button
                  onClick={() => {
                    if (confirm('Are you sure you want to delete this comment?')) {
                      onDelete(comment.id);
                    }
                  }}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-600 hover:bg-red-500/10 hover:text-red-400 transition-all"
                >
                  <Trash2 size={12} />
                  Delete
                </button>
              )}
            </div>
          )}

          {/* Reply form */}
          {isReplying && (
            <div className="mt-4 space-y-3">
              <textarea
                value={replyContent}
                onChange={(e) => setReplyContent(e.target.value)}
                placeholder="Write a reply..."
                className="w-full bg-neutral-900/50 border border-white/10 rounded-xl p-4 text-sm text-white placeholder-neutral-600 focus:border-cyan-500/50 focus:outline-none resize-none"
                rows={3}
              />
              <div className="flex gap-3">
                <button
                  onClick={handleSubmitReply}
                  disabled={!replyContent.trim()}
                  className="px-4 py-2 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-lg hover:bg-cyan-400 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                >
                  Reply
                </button>
                <button
                  onClick={() => {
                    setIsReplying(false);
                    setReplyContent('');
                  }}
                  className="px-4 py-2 text-neutral-500 text-[10px] font-black uppercase tracking-widest hover:text-white transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Nested replies */}
      {comment.replies.length > 0 && (
        <div className="mt-6 space-y-6">
          {comment.replies.map((reply) => (
            <CommentItem
              key={reply.id}
              comment={reply}
              onVote={onVote}
              onReply={onReply}
              onEdit={onEdit}
              onDelete={onDelete}
              currentUserId={currentUserId}
            />
          ))}
        </div>
      )}
    </div>
  );
}
