import 'flatpickr/dist/flatpickr.css'
import Flatpickr from 'stimulus-flatpickr'
import flatpickr from 'flatpickr'

export default class extends Flatpickr {
  static targets = ['hiddenInput', 'selections', 'template']

  connect() {
    this._initializeEvents()
    this._initializeOptions()
    this._initializeDateFormats()

    this.fp = flatpickr(this.hiddenInputTarget, {
      ...this.config,
    })

    this._initializeElements()
  }

  change(selectedDates) {
    this.selectionsTarget.innerHTML = '&nbsp;'
    selectedDates.sort(this.dateSortAsc)
    selectedDates.forEach((date, index) => {
      const pill = document.importNode(this.templateTarget.content, true)
      const closeButton = pill.querySelector('.close')
      closeButton.setAttribute('data-action', 'flatpickr#removeDate')
      closeButton.setAttribute('data-index', index)
      pill.querySelector(
        '.selected-date',
      ).textContent = date.toLocaleDateString()
      this.selectionsTarget.appendChild(pill)
    })
  }

  dateSortAsc(date1, date2) {
    if (date1 > date2) return 1
    if (date1 < date2) return -1
    return 0
  }

  removeDate(event) {
    const index = parseInt(event.currentTarget.getAttribute('data-index'))
    // Slice is to copy so selectedDates isn't modified by splice
    const dates = this.fp.selectedDates.slice(0)
    dates.splice(index, 1)
    this.fp.setDate(dates, true)
  }
}
