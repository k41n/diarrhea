window.show_scenarios = (id) ->
  $.ajax "/feature_files/"+id+"/scenarios"