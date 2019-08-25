/* eslint no-console:0 */


import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import 'bootstrap/dist/js/bootstrap';

import '../stylesheets/application.scss'

import * as d3 from 'd3';
import * as nvd3 from 'nvd3';

require('chartkick');
require('chart.js');

require('./tagify');
require('./flatpickr');

Rails.start();
Turbolinks.start();

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})

