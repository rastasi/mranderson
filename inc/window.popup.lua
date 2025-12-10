function PopupWindow.set_dialog_node(node_key)
  local npc = Context.dialog.active_entity
  local node = npc.dialog[node_key]

  if not node then
    GameWindow.set_state(WINDOW_GAME)
    return
  end

  Context.dialog.current_node_key = node_key
  Context.dialog.text = node.text

  local menu_items = {}
  if node.options then
    for _, option in ipairs(node.options) do
      table.insert(menu_items, {
        label = option.label,
        action = function()
          PopupWindow.set_dialog_node(option.next_node)
        end
      })
    end
  end

  -- if no options, it's the end of this branch.
  if #menu_items == 0 then
      table.insert(menu_items, {
          label = "Go back",
          action = function() GameWindow.set_state(WINDOW_GAME) end
      })
  end

  Context.dialog.menu_items = menu_items
  Context.dialog.selected_menu_item = 1
  Context.dialog.showing_description = false
  GameWindow.set_state(WINDOW_POPUP)
end

function PopupWindow.update()
  if Context.dialog.showing_description then
    if Input.menu_confirm() or Input.menu_back() then
      Context.dialog.showing_description = false
      Context.dialog.text = "" -- Clear the description text
      -- No need to change active_window, as it remains in WINDOW_POPUP or WINDOW_INVENTORY_ACTION
    end
  else
    Context.dialog.selected_menu_item = UI.update_menu(Context.dialog.menu_items, Context.dialog.selected_menu_item)

    if Input.menu_confirm() then
      local selected_item = Context.dialog.menu_items[Context.dialog.selected_menu_item]
      if selected_item and selected_item.action then
        selected_item.action()
      end
    end
    
    if Input.menu_back() then
      GameWindow.set_state(WINDOW_GAME)
    end
  end
end

function PopupWindow.show_menu_dialog(entity, menu_items, dialog_active_window)
  Context.dialog.active_entity = entity
  Context.dialog.text = "" -- Initial dialog text is empty, name is title
  GameWindow.set_state(dialog_active_window or WINDOW_POPUP)
  Context.dialog.showing_description = false
  Context.dialog.menu_items = menu_items
  Context.dialog.selected_menu_item = 1
end

function PopupWindow.show_description_dialog(entity, description_text)
  Context.dialog.active_entity = entity
  Context.dialog.text = description_text
  GameWindow.set_state(WINDOW_POPUP)
  Context.dialog.showing_description = true
  -- No menu items needed for description dialog
end
