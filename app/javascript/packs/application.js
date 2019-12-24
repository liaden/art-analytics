/* eslint no-console:0 */


import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import './bootstrap';

import '../stylesheets/application.scss'

import * as d3 from 'd3';
import * as nvd3 from 'nvd3';

import * as Tags from 'packs/tags';

require('chartkick');
require('chart.js');

require('./tagify');
require('./flatpickr');

require('imports-loader?define=>false!datatables.net')(window, $);

Rails.start();
Turbolinks.start();

$(function () {
  $('[data-toggle="tooltip"]').tooltip();

  var datatables  = $('.datatable').DataTable( {
    paging: false,
    autoWidth: false,
    columnDefs: [
      { targets: [0,1], orderable: true },
      { targets: '_all', orderable: false },
    ],
    order: [[0, 'asc']],
  });

  datatables.columns().every(function() {
    var col = this;
    $( 'input', this.footer() ).on( 'keyup change clear', function () {
        if ( col.search() !== this.value ) {
          col.search( this.value ).draw();
        }
     });
  });

  document.querySelectorAll('.tag-table').forEach(function(tbl) {
    console.log(datatables);
    Tags.init_table(datatables.tables(), tbl);
  });
})


