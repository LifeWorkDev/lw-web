import PropTypes from 'prop-types'
import React, { useState } from 'react'

const User = PropTypes.shape({
  id: PropTypes.number,
  name: PropTypes.string,
})

const Comment = PropTypes.shape({
  comment: PropTypes.string,
  commenter: User,
  formatted_created_at: PropTypes.string,
  formatted_read_at: PropTypes.string,
  id: PropTypes.number,
  read_by: User,
})

const CommentItem = props => {
  const [comment, setComment] = useState(props.comment)
  const [currentUser] = useState(props.currentUser)
  const isCurrentUser = comment.commenter.id === currentUser.id
  const [editing, setEditing] = useState(false)
  const [commentText, setCommentText] = useState(comment.comment)
  const [isError, setIsError] = useState(false)

  const handleCommentChange = event => {
    setCommentText(event.target.value)
  }

  const save = () => {
    comment.comment = commentText
    setComment(comment)
    let data = {
      comment: commentText,
    }
    const csrf = document
      .querySelector("meta[name='csrf-token']")
      .getAttribute('content')
    window
      .fetch(`/comments/${comment.id}`, {
        body: JSON.stringify(data),
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrf,
        },
        method: 'PUT',
        mode: 'cors',
      })
      .then(response => {
        setEditing(false)
        if (response.ok) return response.json()
        else setIsError(true)
      })
  }

  return (
    <div
      className={`comment-item list-group-item list-group-item-action ${
        isCurrentUser ? 'text-right' : 'text-left'
      }`}
    >
      <h5>
        {comment.commenter.name}
        <small> at {comment.formatted_created_at}</small>
      </h5>

      {!editing && (
        <div className='comment'>
          <p>{commentText}</p>
          {isError && (
            <span className='error text-red'>
              Unable to Save Comment, Try again.
            </span>
          )}
          {isCurrentUser && (
            <span
              className='edit badge badge-secondary'
              onClick={() => {
                setEditing(true)
              }}
            >
              Edit
            </span>
          )}
        </div>
      )}

      {isCurrentUser && editing && (
        <div className='comment-inline-edit'>
          <textarea value={commentText} onChange={handleCommentChange} />
          <span className='update badge badge-secondary' onClick={save}>
            Save
          </span>
        </div>
      )}

      {comment.read_by !== null && (
        <small>
          Read by {comment.read_by.name} at {comment.formatted_read_at}
        </small>
      )}
    </div>
  )
}

CommentItem.propTypes = {
  comment: Comment,
  currentUser: User,
}

const CommentsList = props => {
  const [comments] = useState(props.comments)
  const [currentUser] = useState(props.currentUser)

  return (
    <div className={'list-group comments-list'}>
      {comments.map((comment, index) => {
        return (
          <CommentItem
            key={index}
            comment={comment}
            currentUser={currentUser}
          />
        )
      })}
    </div>
  )
}

CommentsList.propTypes = {
  comments: PropTypes.arrayOf(Comment),
  currentUser: User,
}

export default CommentsList
