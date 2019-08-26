import flatpickr from "flatpickr";

$(window).on('load', function () {
  console.log('...');
  const calendar_input_groups = document.querySelectorAll('div.flatpickr');

  calendar_input_groups.forEach(function(calendar_input_group) {
    const picker_input = calendar_input_group.querySelector('.datepicker-input'),
          toggler = calendar_input_group.querySelector('.flatpickr-toggle');

    const picker = flatpickr(picker_input, {
      dateFormat: 'Y-m-d',
      altInput: true,
      altFormat: 'M j, Y',
      allowInput: true
    });

    // associate toggle button if declared
    if (toggler != undefined) {
      toggler.onclick =  function() {

        // flatpickr handles click outside of bounds as a close so just update our state
        if (toggler.dataset.open == 'true') {
          toggler.dataset.open = false
          return
        }

        toggler.dataset.open = true
        picker.toggle()
      }
    }
  });
})
