import Tagify from '@yaireo/tagify';

$(function initialize_tagify() {
  var inputs = document.querySelectorAll('input[name*=tag]');
  Array.prototype.forEach.call(inputs, function(input, index) {
    // use rails naming convention to get resource name
    var resource = input.dataset.resource,
        tagify   = new Tagify(input, {
            enforceWhitelist: true,
            keepInvalidTags: true
        });

    var controller;

    tagify.on('input', fetchTags);

    function fetchTags(e) {
      var prefix = e.detail.value;
      tagify.settings.whitelist.length = 0; // reset the whitelist

      // https://developer.mozilla.org/en-US/docs/Web/API/AbortController/abort
      controller && controller.abort();
      controller = new AbortController();

      fetch('/tags?resources='+resource+'&tag_prefix='+prefix, {
          signal: controller.signal,
          credentials: 'same-origin',
      })
        .then(RES => RES.json())
        .then(function(json){
          tagify.settings.whitelist = json[resource];
          tagify.dropdown.show.call(tagify, prefix);
      });
    }
  });
});
