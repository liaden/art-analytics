export function init_subnav() {
  $('#subnavbar').on('hidden.bs.collapse', function() {
    var sticky_item = document.querySelector('.sticky-bottom');
    if (sticky_item != undefined) {
      sticky_item.classList.remove('handle-subnav')
    }
  });

  $('#subnavbar').on('shown.bs.collapse', function() {
    var sticky_item = document.querySelector('.sticky-bottom');
    if (sticky_item != undefined) {
      sticky_item.classList.add('handle-subnav')
    }
  });
}

export default {
};
