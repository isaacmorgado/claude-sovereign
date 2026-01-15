'use client';

import { useState } from 'react';
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
    <div className="space-y-4">
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
    <div className={`${comment.depth > 0 ? 'ml-6 pl-4 border-l border-neutral-800' : ''}`}>
      <div className="flex gap-3">
        <VoteButtons
          voteCount={comment.voteCount}
          userVote={comment.userVote}
          onVote={(voteType) => onVote(comment.id, voteType)}
          size="sm"
        />

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <span className="font-medium text-neutral-300">u/{comment.author.username}</span>
            <span>·</span>
            <span>{formatDistanceToNow(comment.createdAt)}</span>
            {comment.updatedAt !== comment.createdAt && (
              <>
                <span>·</span>
                <span className="italic">edited</span>
              </>
            )}
          </div>

          {isEditing ? (
            <div className="mt-2">
              <textarea
                value={editContent}
                onChange={(e) => setEditContent(e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded-lg p-3 text-sm text-white placeholder-neutral-500 focus:border-[#00f3ff] focus:outline-none resize-none"
                rows={3}
              />
              <div className="flex gap-2 mt-2">
                <button
                  onClick={handleSubmitEdit}
                  className="px-3 py-1.5 bg-[#00f3ff] text-black text-xs font-medium rounded hover:bg-[#00f3ff]/90"
                >
                  Save
                </button>
                <button
                  onClick={() => {
                    setIsEditing(false);
                    setEditContent(comment.content);
                  }}
                  className="px-3 py-1.5 text-neutral-400 text-xs hover:text-white"
                >
                  Cancel
                </button>
              </div>
            </div>
          ) : (
            <p className="text-neutral-300 text-sm mt-1 whitespace-pre-wrap">
              {comment.content}
            </p>
          )}

          <div className="flex items-center gap-4 mt-2 text-xs text-neutral-500">
            <button
              onClick={() => setIsReplying(!isReplying)}
              className="hover:text-neutral-300"
            >
              Reply
            </button>
            {isOwner && onEdit && (
              <button
                onClick={() => setIsEditing(true)}
                className="hover:text-neutral-300"
              >
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
                className="hover:text-red-400"
              >
                Delete
              </button>
            )}
          </div>

          {isReplying && (
            <div className="mt-3">
              <textarea
                value={replyContent}
                onChange={(e) => setReplyContent(e.target.value)}
                placeholder="Write a reply..."
                className="w-full bg-neutral-800 border border-neutral-700 rounded-lg p-3 text-sm text-white placeholder-neutral-500 focus:border-[#00f3ff] focus:outline-none resize-none"
                rows={3}
              />
              <div className="flex gap-2 mt-2">
                <button
                  onClick={handleSubmitReply}
                  disabled={!replyContent.trim()}
                  className="px-3 py-1.5 bg-[#00f3ff] text-black text-xs font-medium rounded hover:bg-[#00f3ff]/90 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Reply
                </button>
                <button
                  onClick={() => {
                    setIsReplying(false);
                    setReplyContent('');
                  }}
                  className="px-3 py-1.5 text-neutral-400 text-xs hover:text-white"
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
        <div className="mt-4 space-y-4">
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
