import 'flatpickr/dist/flatpickr.css'
import Flatpickr from 'stimulus-flatpickr'
import flatpickr from 'flatpickr'

export default class extends Flatpickr {
  static targets = ['selections', 'template']

  connect() {
    this._initializeEvents()
    this._initializeOptions()
    this._initializeDateFormats()
    const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent,
    )

    this.fp = flatpickr(this.selectionsTarget, {
      ...this.config,
      showMonths: isMobile ? 1 : 2,
    })

    this._initializeElements()

    this.calendarContainerTarget.classList.add('mx-auto')
  }

  change(selectedDates) {
    this.selectionsTarget.innerHTML = '&nbsp;'
    selectedDates.sort(this.dateSortAsc)
    selectedDates.forEach((date, index) => {
      const formattedDate = date.toLocaleDateString()
      const pill = document.importNode(this.templateTarget.content, true)
      const closeButton = pill.querySelector('.close')
      closeButton.setAttribute('data-action', 'flatpickr#removeDate')
      closeButton.setAttribute('data-index', index)
      pill.querySelector('.selected-date').textContent = formattedDate
      pill.querySelector('input').value = formattedDate
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
