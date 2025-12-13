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

function PopupWindow.draw()
  rect(40, 40, 160, 80, Config.colors.black)
  rectb(40, 40, 160, 80, Config.colors.green)

  -- Display the entity's name as the dialog title
  if Context.dialog.active_entity and Context.dialog.active_entity.name then
    Print.text(Context.dialog.active_entity.name, 120 - #Context.dialog.active_entity.name * 2, 45, Config.colors.green)
  end

  -- Display the dialog content (description for "look at", or initial name/dialog for others)
  local wrapped_lines = UI.word_wrap(Context.dialog.text, 25) -- Max 25 chars per line
  local current_y = 55 -- Starting Y position for the first line of content
  for _, line in ipairs(wrapped_lines) do
    Print.text(line, 50, current_y, Config.colors.light_grey)
    current_y = current_y + 8 -- Move to the next line (8 pixels for default font height + padding)
  end
  
  -- Adjust menu position based on the number of wrapped lines
  if not Context.dialog.showing_description then
    UI.draw_menu(Context.dialog.menu_items, Context.dialog.selected_menu_item, 50, current_y + 2)
  else
    Print.text("[A] Go Back", 50, current_y + 10, Config.colors.green)
  end
end
