import 'react-day-picker/lib/style.css'
import DayPicker, { DateUtils } from 'react-day-picker'
import PropTypes from 'prop-types'
import React, { useState } from 'react'

import './DatePicker.scss'

const DatePicker = props => {
  const [milestones, setMilestones] = useState(props.milestones)
  const [selectedDays, setSelectedDays] = useState(
    getMilestoneDays(props.milestones),
  )

  const isMobile = window.innerWidth < 768 // Minimum iPad portrait

  function getMilestoneDays(milestones) {
    let days = []
    let timezoneOffset = new Date().getTimezoneOffset()
    if (milestones != null) {
      milestones.map(milestone => {
        let date = new Date(milestone.date)
        date.setHours(date.getHours() + timezoneOffset / 60)
        days.push(date)
      })
    }
    return days
  }

  function removeMilestoneOfDate(date) {
    const newMilestones = milestones.slice()
    const milestoneIndex = newMilestones.findIndex(
      milestone => milestone.date == date.toLocaleDateString(),
    )
    const milestoneToUpdate = newMilestones[milestoneIndex]
    if (milestoneToUpdate.id !== undefined) {
      milestoneToUpdate.deleted = true
    } else {
      newMilestones.splice(milestoneIndex, 1)
    }
    setMilestones(newMilestones)
  }

  function addMilestoneDate(date) {
    const newMilestones = milestones.slice()
    const milestoneIndex = newMilestones.findIndex(
      milestone => milestone.date == date.toLocaleDateString(),
    )
    if (milestoneIndex > 0) {
      const milestoneToUpdate = milestones[milestoneIndex]
      milestoneToUpdate.deleted = false
    } else {
      newMilestones.push({ date: date.toLocaleDateString() })
    }
    setMilestones(newMilestones)
  }

  const removeData = index => {
    const newSelectedDays = selectedDays.slice()
    removeMilestoneOfDate(newSelectedDays[index])
    delete newSelectedDays[index]
    setSelectedDays(newSelectedDays)
  }

  const handleDayClick = (day, { selected }) => {
    const newSelectedDays = selectedDays.slice()

    if (selected) {
      const selectedIndex = newSelectedDays.findIndex(selectedDay =>
        DateUtils.isSameDay(selectedDay, day),
      )
      removeMilestoneOfDate(day)
      newSelectedDays.splice(selectedIndex, 1)
    } else {
      let minDate = new Date()
      minDate.setHours(0, 0, 0, 0)
      if (
        day.toISOString().slice(0, 10) >= minDate.toISOString().slice(0, 10)
      ) {
        addMilestoneDate(day)
        newSelectedDays.push(day)
      }
    }
    setSelectedDays(newSelectedDays)
  }

  const orderedDays = selectedDays.sort(function(date1, date2) {
    if (date1 > date2) return 1
    if (date1 < date2) return -1
    return 0
  })

  const deletedMilestones = milestones.filter(function(milestone) {
    return milestone.deleted !== undefined && milestone.deleted == true
  })

  return (
    <div className='text-center'>
      <div>
        {deletedMilestones.map((milestone, key) => {
          return (
            <div key={key + selectedDays.length}>
              <input
                type='hidden'
                name={'milestone_project[milestones_attributes][][id]'}
                value={milestone.id}
              />
              <input
                type='hidden'
                name={'milestone_project[milestones_attributes][][date]'}
                value={milestone.date}
              />
              <input
                type='hidden'
                name={'milestone_project[milestones_attributes][][_destroy]'}
                value={milestone.deleted}
              />
            </div>
          )
        })}

        {orderedDays.map((day, key) => {
          return (
            <span
              className='badge badge-primary badge-pill date-pill mr-2 mb-2'
              key={key}
            >
              <span>{day.toLocaleDateString()}</span>
              <input
                type='hidden'
                name={'milestone_project[milestones_attributes][][date]'}
                value={day.toISOString().slice(0, 10)}
              />
              <button
                type='button'
                className='close'
                onClick={() => removeData(key)}
              >
                <span>×</span>
              </button>
            </span>
          )
        })}
      </div>
      <DayPicker
        selectedDays={selectedDays}
        onDayClick={handleDayClick}
        numberOfMonths={isMobile ? 1 : 2}
        disabledDays={{ before: new Date() }}
        firstDayOfWeek={1}
      />
    </div>
  )
}

DatePicker.propTypes = {
  milestones: PropTypes.array.isRequired,
}

export default DatePicker
