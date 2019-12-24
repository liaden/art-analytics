import ax from 'packs/axios';

function toggle() {
  var element = this;
  var path = element.closest('tr').dataset.tagpath;

  element.disabled = true;

  if (element.checked) {
    ax.post(path, { tag: element.value }).then(
      function(response) {
        // todo: make clear tags button work again
        element.disabled = false;
    }).catch(function(response) {
      console.log(response);
    });

  } else {
    ax.delete(path + "/" + element.value).then(function(response) {
      element.disabled = false;
    }).catch(function(response) {
      console.log(response);
    });
  }
}

function clear(element) {
  var path = element.closest('tr').dataset.tagpath;

  ax.delete(path).then(function(response) {
    element.closest('tr').querySelectorAll('td > input[type=checkbox]').forEach(function(cb) { cb.checked = false; });
  }).catch(function(response) { console.log(response); });
}

function filter(element) {
  var table = element.closest('table');
  var regex = new RegExp(element.value);

  var datatable = $.fn.dataTable.Api('#'+table.id)

  datatable.columns().every(function() {
    var lnk = this.header().querySelector('.tag-col-header > a');
    if(lnk != null) {
      this.visible(lnk.innerText.match(regex));
    }

  });

  element.focus();
}

export function init_table(datatable, element) {
  var tbody = element.querySelector('tbody');

  tbody.querySelectorAll('td > input[type=checkbox]').forEach(function(cb) {
    cb.onclick = toggle;
  });

  tbody.querySelectorAll('a.clear-tags').forEach(function(lnk) {
    lnk.onclick = function() {
      clear(lnk); };
  });

  var tagfilter = element.querySelector('input[name=tagsearch]');

  tagfilter.oninput = function() {
    filter(tagfilter);
  };
}

export default {

};
