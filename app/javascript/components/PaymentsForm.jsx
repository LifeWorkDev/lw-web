import PropTypes from 'prop-types'
import React, { useState } from 'react'
import classNames from 'classnames'

import formatCurrency from 'utils/formatCurrency'

const Milestone = PropTypes.shape({
  amount: PropTypes.number,
  date: PropTypes.string.isRequired,
  description: PropTypes.string,
  id: PropTypes.number.isRequired,
})

const PaymentsForm = ({ isClient, lifeworkFee, projectFee, ...props }) => {
  const [milestones, setMilestones] = useState(props.milestones)
  const [total, setTotal] = useState(Number(props.total))
  const submitButton = document.getElementById('submit-form')
  const ErrorBoundary = window.Bugsnag.getPlugin('react')
  const feesWaived = projectFee == 0 && lifeworkFee > 0
  let errorText
  let sum = 0

  const updateAmount = ({ amount, index }) => {
    const newMilestones = milestones.slice() // create a copy
    newMilestones[index].amount = Number(amount)
    setMilestones(newMilestones)
  }

  const milestoneRows = milestones.map((milestone, index) => {
    sum += Number(milestone.amount || 0)
    return (
      <PaymentForm
        key={index}
        {...{
          index,
          milestone,
          total,
          updateAmount,
        }}
      />
    )
  })

  if (Math.abs(total - sum) > 0.01) {
    console.error(`Total ${total} != Sum ${sum}`)
    errorText = 'Must add up to 100%'
    submitButton.disabled = true
  } else {
    errorText = null
    submitButton.disabled = false
  }

  return (
    <ErrorBoundary>
      <div className='form-group flex-nowrap justify-content-center row'>
        <label
          className='col-form-label col-auto px-0 required'
          htmlFor='milestone_project_amount'
        >
          Total contract amount
        </label>
        <div className='col-auto mw-50 pr-0'>
          <div className='input-group'>
            <div className='input-group-prepend'>
              <span className='input-group-text'>$</span>
            </div>
            <input
              className='form-control'
              defaultValue={total}
              id='milestone_project_amount'
              inputMode='decimal'
              min='10'
              name='milestone_project[amount]'
              onChange={(e) => setTotal(Number(e.target.value))}
              placeholder='0.00'
              required
              step='0.01'
              type='number'
            />
          </div>
        </div>
      </div>
      {milestoneRows}
      <PaymentsFormRow
        firstClass='mb-3 mb-sm-0 text-right'
        firstContent='Total:'
        secondContent={
          <div className='input-group input-group-sm font-weight-bold'>
            <div className='input-group-prepend'>
              <span className='input-group-text'>$</span>
            </div>
            <input
              disabled
              className='form-control'
              value={formatCurrency(sum)}
            />
          </div>
        }
        thirdContent={
          <div className='input-group input-group-sm font-weight-bold'>
            <input
              disabled
              className='form-control text-right'
              value={total && sum && Math.round((sum / total) * 100)}
            />
            <div className='input-group-append'>
              <span className='input-group-text'>%</span>
            </div>
          </div>
        }
        fourthContent={
          <span className='font-sans-serif text-danger'>{errorText}</span>
        }
      />
      {!isClient && lifeworkFee > 0 && (
        <>
          <PaymentsFormRow
            firstClass='mb-3 mb-sm-0 text-right'
            firstContent={
              <>
                <span
                  className='my-auto'
                  title='We charge this fee to cover our costs of running the platform. We only get paid when you do!'
                >
                  Fee:
                </span>
                {feesWaived && (
                  <span
                    className='rubber-stamp ml-2 mt-2 mt-lg-0'
                    title="Thanks for being one of our early customers! As a token of our appreciation, we're waiving our platform fees for your first few projects."
                  >
                    Waived!
                  </span>
                )}
              </>
            }
            secondContent={
              <div className='input-group input-group-sm'>
                <div className='input-group-prepend'>
                  <span className='input-group-text'>$</span>
                </div>
                <input
                  disabled
                  className={classNames('form-control', {
                    'strike-through': feesWaived,
                  })}
                  value={formatCurrency(sum * (projectFee || lifeworkFee))}
                />
              </div>
            }
            thirdContent={
              <div className='input-group input-group-sm'>
                <input
                  disabled
                  className={classNames('form-control', 'text-right', {
                    'strike-through': feesWaived,
                  })}
                  value={(projectFee || lifeworkFee) * 100}
                />
                <div className='input-group-append'>
                  <span className='input-group-text'>%</span>
                </div>
              </div>
            }
          />
          {projectFee > 0 && (
            <PaymentsFormRow
              firstClass='mb-3 mb-sm-0'
              firstContent='Net:'
              secondContent={
                <div className='input-group input-group-sm'>
                  <div className='input-group-prepend'>
                    <span className='input-group-text'>$</span>
                  </div>
                  <input
                    disabled
                    className='form-control'
                    value={formatCurrency(sum * (1 - projectFee))}
                  />
                </div>
              }
            />
          )}
        </>
      )}
    </ErrorBoundary>
  )
}
PaymentsForm.propTypes = {
  isClient: PropTypes.bool.isRequired,
  lifeworkFee: PropTypes.number.isRequired,
  milestones: PropTypes.arrayOf(Milestone),
  projectFee: PropTypes.number.isRequired,
  total: PropTypes.number,
}

const PaymentForm = React.memo(({ index, milestone, total, updateAmount }) => {
  const percent =
    total && milestone.amount && Math.round((milestone.amount / total) * 100)
  return (
    <PaymentsFormRow
      firstClass='bg-dark small text-white'
      firstContent={
        <>
          <img
            className='align-text-bottom'
            src='https://cdn.jsdelivr.net/npm/@mdi/svg@4.9.95/svg/flag-checkered.svg'
            width={20}
            height={20}
            style={{ filter: 'invert(1)' }}
          />
          <div className='mx-auto'>{milestone.date}</div>
        </>
      }
      secondContent={
        <>
          <label className='sr-only'>Amount</label>
          <div className='input-group input-group-sm'>
            <div className='input-group-prepend'>
              <span className='input-group-text'>$</span>
            </div>
            <input
              value={milestone.amount ? Number(milestone.amount) : ''}
              className='form-control'
              inputMode='decimal'
              min='10'
              name={`milestone_project[milestones_attributes][${index}][amount]`}
              onChange={(e) =>
                updateAmount({ amount: e.target.value, index: index })
              }
              placeholder='0.00'
              step='0.01'
              type='number'
              required
            />
          </div>
        </>
      }
      thirdContent={
        <>
          <label className='sr-only'>Percent</label>
          <div className='input-group input-group-sm'>
            <input
              className='form-control text-right'
              inputMode='decimal'
              onChange={(e) =>
                updateAmount({
                  amount:
                    e.target.value &&
                    ((Number(e.target.value) / 100) * total).toFixed(2),
                  index: index,
                })
              }
              placeholder='of total'
              type='number'
              value={percent || ''}
            />
            <div className='input-group-append'>
              <span className='input-group-text'>%</span>
            </div>
          </div>
        </>
      }
      fourthContent={
        <>
          <label className='sr-only'>Description</label>
          <input
            className='form-control form-control-sm w-100'
            defaultValue={milestone.description}
            name={`milestone_project[milestones_attributes][${index}][description]`}
            placeholder='Describe this milestone'
            type='text'
            required
          />
          <input
            type='hidden'
            value={milestone.id}
            name={`milestone_project[milestones_attributes][${index}][id]`}
          />
        </>
      }
    />
  )
})
PaymentForm.displayName = 'PaymentForm'
PaymentForm.propTypes = {
  index: PropTypes.number.isRequired,
  milestone: Milestone.isRequired,
  total: PropTypes.number,
  updateAmount: PropTypes.func.isRequired,
}

const PaymentsFormRow = React.memo(
  ({
    firstClass,
    firstContent,
    secondContent,
    thirdContent,
    fourthContent,
  }) => (
    <div className='form-group row'>
      <div
        className={`d-flex flex-column justify-content-center col-4 col-sm-2 font-sans-serif ${firstClass}`}
      >
        <div className='form-row justify-content-end'>{firstContent}</div>
      </div>
      <div className='col-8 col-sm-10 pr-0'>
        <div className='container p-0'>
          <div className='form-row'>
            <div className='form-group col-6 col-sm-2 mb-sm-0'>
              {secondContent}
            </div>
            <div className='form-group col-6 col-sm-2 mb-sm-0'>
              {thirdContent}
            </div>
            <div className='col-12 col-sm-8 d-flex'>{fourthContent}</div>
          </div>
        </div>
      </div>
    </div>
  ),
)
PaymentsFormRow.displayName = 'PaymentsFormRow'
PaymentsFormRow.propTypes = {
  firstClass: PropTypes.string,
  firstContent: PropTypes.node,
  fourthContent: PropTypes.node,
  secondContent: PropTypes.node,
  thirdContent: PropTypes.node,
}

export default PaymentsForm
