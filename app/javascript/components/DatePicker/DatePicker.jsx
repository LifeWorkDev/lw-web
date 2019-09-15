import 'react-day-picker/lib/style.css'
import DayPicker, { DateUtils } from 'react-day-picker'
import PropTypes from 'prop-types'
import React, { useState } from 'react'

import './Datepicker.scss'

const DatePicker = props => {
  const [selectedDays, setSelectedDays] = useState(
    stringsToDates(props.defaultDays),
  )

  const isMobile = () => {
    const result = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent,
    )
    return result
  }

  function stringsToDates(dayStrings) {
    // const stringsToDates = dayStrings => {
    let days = []
    let timezoneOffset = new Date().getTimezoneOffset()
    if (dayStrings != null) {
      dayStrings.map(day => {
        let date = new Date(day)
        date.setHours(date.getHours() + timezoneOffset / 60)
        days.push(date)
      })
    }
    return days
  }

  const displayFormatDate = date => {
    let d = new Date(date),
      month = '' + (d.getMonth() + 1),
      day = '' + d.getDate(),
      year = d.getFullYear()

    if (month.length < 2) month = '0' + month
    if (day.length < 2) day = '0' + day

    return [month, day, year].join('/')
  }

  const shortFormatDate = date => {
    let d = new Date(date),
      month = '' + (d.getMonth() + 1),
      day = '' + d.getDate(),
      year = d.getFullYear()

    if (month.length < 2) month = '0' + month
    if (day.length < 2) day = '0' + day

    return [year, month, day].join('-')
  }

  const removeData = index => {
    const newSelectedDays = selectedDays.slice()
    delete newSelectedDays[index]
    setSelectedDays(newSelectedDays)
  }

  // const handleDayClick = (day, { selected }) => {
  const handleDayClick = (day, { selected }) => {
    const newSelectedDays = selectedDays.slice()
    if (selected) {
      const selectedIndex = newSelectedDays.findIndex(selectedDay =>
        DateUtils.isSameDay(selectedDay, day),
      )
      newSelectedDays.splice(selectedIndex, 1)
    } else {
      let minDate = new Date()
      minDate.setDate(minDate.getDate() - 1)
      if (day > minDate) {
        newSelectedDays.push(day)
      }
    }
    setSelectedDays(newSelectedDays)
  }

  let orderedDays = selectedDays.sort(function(date1, date2) {
    if (date1 > date2) return 1
    if (date1 < date2) return -1
    return 0
  })

  return (
    <div className='text-align-center'>
      <div>
        {orderedDays.map((day, key) => (
          <span
            className='badge badge-primary badge-pill date-pill mr-2 mb-2'
            key={key}
          >
            <span>{displayFormatDate(day)}</span>
            <input
              type='hidden'
              name={'milestone_project[milestones_attributes][][date]'}
              value={shortFormatDate(day)}
            />
            <button
              type='button'
              className='close'
              onClick={() => removeData(key)}
            >
              <span>×</span>
            </button>
          </span>
        ))}
      </div>
      <DayPicker
        selectedDays={selectedDays}
        onDayClick={handleDayClick}
        numberOfMonths={isMobile() ? 1 : 2}
        disabledDays={{ before: new Date() }}
      />
    </div>
  )
}

DatePicker.propTypes = {
  defaultDays: PropTypes.array.isRequired,
}

export default DatePicker
