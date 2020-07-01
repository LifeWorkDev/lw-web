import PropTypes from 'prop-types'
import React, { useState } from 'react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { DateUtils } from 'react-day-picker'
import { format, parseISO, parse } from 'date-fns'

import formatCurrency from 'utils/formatCurrency'

import 'styles/DayPicker.scss'

export default function RetainerPayment({
  achMax,
  beginText,
  endText,
  middleText,
  projectFee,
  ...props
}) {
  const [amount, setAmount] = useState(props.amount)
  const [disbursementDay, setDisbursementDay] = useState(props.disbursementDay)
  const [startDate, setStartDate] = useState(
    props.startDate && parseISO(props.startDate),
  )

  return (
    <>
      {beginText + ' $'}
      <div className='form-group form-inline form-underline d-inline-block mb-0 mr-2'>
        <input
          required
          type='number'
          className='form-control text-center'
          value={amount || ''}
          onChange={(e) => setAmount(Number(e.target.value) || '')}
          name='retainer_project[amount]'
          style={{ width: '4.4rem' }}
          min='1'
          max={achMax}
          step='0.01'
          inputMode='decimal'
        />
      </div>
      <br className='d-sm-none' />
      {middleText}
      <div className='form-group form-inline form-underline d-inline-block mb-0 mx-2'>
        <DayPickerInput
          dayPickerProps={{ disabledDays: { before: new Date() } }}
          format='M/d/y'
          formatDate={(date, fmt, locale) => format(date, fmt, { locale })}
          inputProps={{
            className: 'form-control text-center',
            id: 'retainer_project_start_date_picker',
            inputMode: 'none',
            onBlur: (e) => (e.target.readOnly = false),
            onFocus: (e) => (e.target.readOnly = true),
            required: true,
            style: { width: '6rem' },
          }}
          onDayChange={(day) => {
            setStartDate(day)
            !disbursementDay && setDisbursementDay(day.getDate())
          }}
          parseDate={(str, format, locale) => {
            const parsed = parse(str, format, new Date(), { locale })
            return DateUtils.isDate(parsed) ? parsed : undefined
          }}
          placeholder=''
          value={startDate}
        />
        <input
          required
          name='retainer_project[start_date]'
          type='hidden'
          value={startDate ? format(startDate, 'yyyy-MM-dd') : ''}
        />
      </div>
      <br className='d-sm-none' />
      {endText[0]}
      <div className='form-group form-inline form-underline d-inline-block mb-0 mx-2'>
        <input
          required
          type='number'
          className='form-control text-center'
          value={disbursementDay || ''}
          onChange={(e) => setDisbursementDay(Number(e.target.value))}
          name='retainer_project[disbursement_day]'
          style={{ width: '2.2rem' }}
          min='1'
          max='31'
          step='1'
          inputMode='decimal'
        />
      </div>
      day
      <br className='d-sm-none' />
      {endText[1]}
      {disbursementDay >= 28 ? (
        <>
          ,
          <br />
          or the last calendar day of the month,
          <br className='d-sm-none' /> if there are less days in that month
        </>
      ) : (
        ''
      )}
      .
      {amount > 0 && projectFee > 0 ? (
        <>
          <br />
          You will receive{' '}
          <strong>${formatCurrency(amount * (1 - projectFee))}</strong> per
          month,
          <br className='d-sm-none' /> net of LifeWork&lsquo;s{' '}
          {projectFee * 100}% fee.
        </>
      ) : (
        ''
      )}
    </>
  )
}

RetainerPayment.propTypes = {
  achMax: PropTypes.number.isRequired,
  amount: PropTypes.number,
  beginText: PropTypes.string.isRequired,
  disbursementDay: PropTypes.number,
  endText: PropTypes.array.isRequired,
  middleText: PropTypes.string.isRequired,
  projectFee: PropTypes.number.isRequired,
  startDate: PropTypes.string,
}
