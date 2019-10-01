import PropTypes from 'prop-types'
import React, { useState } from 'react'

const Milestone = PropTypes.shape({
  amount: PropTypes.number.isRequired,
  date: PropTypes.string.isRequired,
  description: PropTypes.string,
  id: PropTypes.number.isRequired,
})

const PaymentsForm = props => {
  const [milestones, setMilestones] = useState(props.milestones)
  const [total, setTotal] = useState(Number(props.total))
  const submitButton = document.getElementById('submit-form')
  let errorText
  let sum = 0

  const updateAmount = ({ amount, index }) => {
    const newMilestones = milestones.slice() // create a copy
    newMilestones[index].amount = amount
    setMilestones(newMilestones)
  }

  const milestoneRows = milestones.map((milestone, index) => {
    sum += Number(milestone.amount || 0)
    return (
      <PaymentForm key={index} {...{ index, milestone, total, updateAmount }} />
    )
  })

  const formatCurrency = value =>
    value
      .toLocaleString('en-US', {
        currency: 'USD',
        style: 'currency',
      })
      .replace('$', '')
      .replace('.00', '')

  if (total !== sum) {
    errorText = 'Must add up to 100%'
    submitButton.disabled = true
  } else {
    errorText = null
    submitButton.disabled = false
  }

  return (
    <>
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
              min='1'
              name='milestone_project[amount]'
              onChange={e => setTotal(Number(e.target.value))}
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
        firstClass='font-weight-bold mb-3 mb-sm-0'
        firstContent={props.isClient ? 'Subtotal:' : 'Total:'}
        secondContent={
          <div className='input-group input-group-sm'>
            <div className='input-group-prepend'>
              <span className='input-group-text'>$</span>
            </div>
            <input
              disabled
              className='form-control font-weight-bold'
              value={formatCurrency(sum)}
            />
          </div>
        }
        thirdContent={
          <div className='input-group input-group-sm'>
            <input
              disabled
              className='form-control font-weight-bold text-right'
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
      {props.isClient && (
        <>
          <PaymentsFormRow
            firstClass='font-weight-bold mb-3 mb-sm-0'
            firstContent='LifeWork fee:'
            secondContent={
              <div className='input-group input-group-sm'>
                <div className='input-group-prepend'>
                  <span className='input-group-text'>$</span>
                </div>
                <input
                  disabled
                  className='form-control font-weight-bold'
                  value={formatCurrency(sum * 0.02)}
                />
              </div>
            }
            thirdContent={
              <div className='input-group input-group-sm'>
                <input
                  disabled
                  className='form-control font-weight-bold text-right'
                  value='2'
                />
                <div className='input-group-append'>
                  <span className='input-group-text'>%</span>
                </div>
              </div>
            }
          />
          <PaymentsFormRow
            firstClass='font-weight-bold mb-3 mb-sm-0'
            firstContent='Total:'
            secondContent={
              <div className='input-group input-group-sm'>
                <div className='input-group-prepend'>
                  <span className='input-group-text'>$</span>
                </div>
                <input
                  disabled
                  className='form-control font-weight-bold'
                  value={formatCurrency(sum * 1.02)}
                />
              </div>
            }
          />
        </>
      )}
    </>
  )
}
PaymentsForm.propTypes = {
  isClient: PropTypes.bool.isRequired,
  milestones: PropTypes.arrayOf(Milestone),
  total: PropTypes.number,
}

const PaymentForm = React.memo(({ index, milestone, total, updateAmount }) => {
  const percent =
    total && milestone.amount && Math.round((milestone.amount / total) * 100)
  return (
    <PaymentsFormRow
      firstClass='bg-dark small text-white'
      firstContent={milestone.date}
      secondContent={
        <>
          <label className='sr-only'>Amount</label>
          <div className='input-group input-group-sm'>
            <div className='input-group-prepend'>
              <span className='input-group-text'>$</span>
            </div>
            <input
              value={milestone.amount && Number(milestone.amount)}
              className='form-control'
              inputMode='decimal'
              max='1960'
              name={`milestone_project[milestones_attributes][${index}][amount]`}
              onChange={e =>
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
              onChange={e =>
                updateAmount({
                  amount:
                    e.target.value && (Number(e.target.value) / 100) * total,
                  index: index,
                })
              }
              placeholder='of total'
              type='number'
              value={percent}
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
        <div className='form-row justify-content-center'>{firstContent}</div>
      </div>
      <div className='col-8 col-sm-10 form-inline pr-0'>
        <div className='container p-0'>
          <div className='form-row'>
            <div className='form-group col-6 col-sm-2 form-inline'>
              {secondContent}
            </div>
            <div className='form-group col-6 col-sm-2 form-inline'>
              {thirdContent}
            </div>
            <div className='col-12 col-sm-8 form-inline'>{fourthContent}</div>
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
