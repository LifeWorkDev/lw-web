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
  const [comment] = useState(props.comment)
  const [currentUser] = useState(props.currentUser)
  const isCurrentUser = comment.commenter.id === currentUser.id

  return (
    <div
      className={`list-group-item list-group-item-action ${
        isCurrentUser ? 'text-right' : 'text-left'
      }`}
    >
      <h5>
        {comment.commenter.name}
        <small> at {comment.formatted_created_at}</small>
      </h5>
      <p>{comment.comment}</p>

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
