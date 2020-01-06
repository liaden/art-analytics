export function init_subnav() {
  $('#subnavbar').on('hidden.bs.collapse', function() {
    document.querySelectorAll('.sticky-bottom').forEach(function(sticky_item) {
      sticky_item.classList.remove('handle-subnav')

    });
  });

  $('#subnavbar').on('shown.bs.collapse', function() {
    document.querySelectorAll('.sticky-bottom').forEach(function(sticky_item) {
      sticky_item.classList.add('handle-subnav')
    });
  });
}

export default {
};
