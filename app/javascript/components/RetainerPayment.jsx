import PropTypes from 'prop-types'
import React, { useState } from 'react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { DateUtils } from 'react-day-picker'
import { format, parseISO, parse } from 'date-fns'

import 'styles/DayPicker.scss'

export default function RetainerPayment(props) {
  const [startDate, setStartDate] = useState(
    props.startDate && parseISO(props.startDate),
  )

  return (
    <>
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
          onDayChange={(day) => setStartDate(day)}
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
      {props.middleText}
      <br className='d-sm-none' />
      <div className='form-group form-inline form-underline d-inline-block mb-0 mx-2'>
        <input
          required
          type='number'
          className='form-control text-center'
          defaultValue={props.disbursementDay || startDate?.getDate()}
          name='retainer_project[disbursement_day]'
          style={{ width: '2.2rem' }}
          min='1'
          max='31'
          step='1'
          inputMode='decimal'
        />
      </div>
      {props.endText}.
    </>
  )
}

RetainerPayment.propTypes = {
  disbursementDay: PropTypes.string,
  endText: PropTypes.string.isRequired,
  middleText: PropTypes.string.isRequired,
  startDate: PropTypes.string,
}
