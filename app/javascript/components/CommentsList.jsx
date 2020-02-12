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
  const ErrorBoundary = window.bugsnagClient.getPlugin('react')
  const commentForm = document.getElementById('comment-form')

  const handleCommentChange = event => {
    setCommentText(event.target.value)
  }

  const editingOff = () => {
    commentForm?.classList.remove('d-none')
    setEditing(false)
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
        editingOff()
        if (response.ok) return response.json()
        else setIsError(true)
      })
  }

  return (
    <ErrorBoundary>
      <div
        className={`comment-item list-group-item list-group-item-action ${
          isCurrentUser ? 'text-right' : 'text-left'
        }`}
      >
        <h5>
          {comment.commenter.name}
          <small> {comment.formatted_created_at}</small>
        </h5>

        {!editing && (
          <div className='comment'>
            <p className='mb-1'>{commentText}</p>
            {isError && (
              <span className='error text-danger'>
                Unable to Save Comment, Try again.
              </span>
            )}
            {isCurrentUser &&
              (comment.read_by ? (
                <div className='small'>
                  Read by {comment.read_by.name} {comment.formatted_read_at}
                </div>
              ) : (
                <button
                  className='btn btn-sm btn-white'
                  onClick={() => {
                    commentForm?.classList.add('d-none')
                    setEditing(true)
                  }}
                >
                  <img
                    src='https://cdn.jsdelivr.net/npm/@mdi/svg@4.9.95/svg/pencil.svg'
                    width={12}
                    height={12}
                  />
                  {' Edit'}
                </button>
              ))}
          </div>
        )}

        {isCurrentUser && editing && (
          <div className='comment-inline-edit'>
            <textarea
              className='form-control'
              value={commentText}
              onChange={handleCommentChange}
            />
            <button
              className='btn btn-sm btn-outline-white mt-1 mr-2'
              onClick={() => {
                setCommentText(props.comment.comment)
                editingOff()
              }}
            >
              Cancel
            </button>
            <button className='btn btn-sm btn-white mt-1' onClick={save}>
              Save
            </button>
          </div>
        )}
      </div>
    </ErrorBoundary>
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
