window.ping_node = (id) ->
  $('#ping_link').hide();
  $('#spinner').show();
  $.ajax '/nodes/'+id+'/ping'

window.clear_node = (id) ->
  $('#clear_link').hide();
  $('#spinner').show();
  $.ajax '/nodes/'+id+'/clear'

window.prepare_node = (id) ->
  $('#prepare_link').hide();
  $('#spinner').show();
  $.ajax '/nodes/'+id+'/prepare'