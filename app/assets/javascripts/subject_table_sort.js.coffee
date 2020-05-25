$(document).on 'turbolinks:load', ->
  if $('#subject-sortable').length > 0
    table_width = $('#subject-sortable').width()
    cells = $('.table').find('tr')[0].cells.length
    desired_width = table_width / cells + 'px'
    $('.table td').css('width', desired_width)

    $('#subject-sortable').sortable(
      axis: 'y'
      items: '.item'
      cursor: 'move'

      sort: (e, ui) ->
        ui.item.addClass('active-item-shadow')
      stop: (e, ui) ->
        ui.item.removeClass('active-item-shadow')
        # highlight the row on drop to indicate an update
        ui.item.children('td').effect('highlight', {color: "#17a2b8"}, 1000)
      update: (e, ui) ->
        item_id = ui.item.data('item-id')
        console.log(item_id)
        project_id = ui.item.data('project-id')
        position = ui.item.index()
        category_index = ui.item.data('index')
        $.ajax(
          type: 'POST'
          url: '/projects/'+project_id+'/subjects/update_row_order'
          dataType: 'json'
          data: { subject: {subject_id: item_id, row_order_position: position-category_index-1 } }
        )
    )
