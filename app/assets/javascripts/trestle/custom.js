// This file may be used for providing additional customizations to the Trestle
// admin. It will be automatically included within all admin pages.
//
// For organizational purposes, you may wish to define your customizations
// within individual partials and `require` them here.
//
//  e.g. //= require "trestle/custom/my_custom_js"

// Use Bootstrap theme
$.fn.select2.defaults.set('theme', 'bootstrap')

// Copy all classes from select tag to replacement select field (.select2-selection)
$.fn.select2.defaults.set('containerCssClass', ':all:')

// Copy all classes excluding 'form-control'/'form-control-*' from select tag to dropdown container (.select2-dropdown)
$.fn.select2.defaults.set('dropdownCssClass', function (el) {
  return el[0].className.replace(/\s*form-control(-\w+)?\s*/g, '')
})

Trestle.init(function (root) {
  function formatSelect2(option, events) {
    if (!option.id) return option.text; // optgroup
    var $option = $('<span></span>')
    var $link = $(option.element.dataset.link)
    $link.on(events, function(e) { e.stopPropagation() })
    $option.text(option.text)
    $option.append($link)
    return $option
  }

  function formatResult(option) {
    return formatSelect2(option, 'mouseup touchend')
  }

  function formatSelection(option) {
    return formatSelect2(option, 'mousedown touchstart')
  }

  $(root).find('select[data-enable-custom-select2]').select2({
    allowClear: true,
    placeholder: 'Currently blank',
    templateResult: formatResult,
    templateSelection: formatSelection,
  })
})
