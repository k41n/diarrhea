window.enable_run_periodic_refresh = (id) ->
  console.log('enabling run periodic refresh for run '+id);
  window.run_id = id
  setTimeout ->
    if $('#run_status').length > 0
      $.ajax '/runs/'+window.run_id
  , 15000

