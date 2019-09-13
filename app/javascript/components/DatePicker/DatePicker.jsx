import 'react-day-picker/lib/style.css'
import DayPicker, { DateUtils } from 'react-day-picker'
import React from 'react'

import './Datepicker.scss'

export default class DatePicker extends React.Component {
  constructor(props) {
    super(props)
    this.handleDayClick = this.handleDayClick.bind(this)
    let defaultDate = props.defaultDate

    let selectedDays = []
    let timezoneOffset = new Date().getTimezoneOffset()
    console.log(timezoneOffset)
    if (defaultDate != null) {
      defaultDate.map(day => {
        let date = new Date(day)
        date.setHours(date.getHours() + timezoneOffset / 60)
        selectedDays.push(date)
      })
    }

    this.state = {
      selectedDays,
    }
  }

  isMobile = () => {
    const result = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent,
    )
    return result
  }

  displayFormatDate = date => {
    let d = new Date(date),
      month = '' + (d.getMonth() + 1),
      day = '' + d.getDate(),
      year = d.getFullYear()

    if (month.length < 2) month = '0' + month
    if (day.length < 2) day = '0' + day

    return [month, day, year].join('/')
  }

  shortFormatDate = date => {
    let d = new Date(date),
      month = '' + (d.getMonth() + 1),
      day = '' + d.getDate(),
      year = d.getFullYear()

    if (month.length < 2) month = '0' + month
    if (day.length < 2) day = '0' + day

    return [year, month, day].join('-')
  }

  removeData = index => {
    let { selectedDays } = this.state
    delete selectedDays[index]

    this.setState({ selectedDays })
  }

  handleDayClick(day, { selected }) {
    const { selectedDays } = this.state
    if (selected) {
      const selectedIndex = selectedDays.findIndex(selectedDay =>
        DateUtils.isSameDay(selectedDay, day),
      )
      selectedDays.splice(selectedIndex, 1)
    } else {
      let minDate = new Date()
      minDate.setDate(minDate.getDate() - 1)
      if (day > minDate) {
        selectedDays.push(day)
      }
    }
    this.setState({ selectedDays })
  }

  render() {
    const { selectedDays } = this.state
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
              <span>{this.displayFormatDate(day)}</span>
              <input
                type='hidden'
                name={'milestone_project[milestones_attributes][][date]'}
                value={this.shortFormatDate(day)}
              />
              <button
                type='button'
                className='close'
                onClick={() => this.removeData(key)}
              >
                <span>×</span>
              </button>
            </span>
          ))}
        </div>
        <DayPicker
          selectedDays={this.state.selectedDays}
          onDayClick={this.handleDayClick}
          numberOfMonths={this.isMobile() ? 1 : 2}
          disabledDays={{ before: new Date() }}
        />
      </div>
    )
  }
}
