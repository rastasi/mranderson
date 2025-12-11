function Item.use()
  print("Used item: " .. Context.dialog.active_entity.name)
  GameWindow.set_state(WINDOW_INVENTORY)
end
function Item.look_at()
  PopupWindow.show_description_dialog(Context.dialog.active_entity, Context.dialog.active_entity.desc)
end
function Item.put_away()
  -- Add item to inventory
  table.insert(Context.inventory, Context.dialog.active_entity)

  -- Remove item from screen
  local currentScreenData = Context.screens[Context.current_screen]
  for i, item in ipairs(currentScreenData.items) do
    if item == Context.dialog.active_entity then
      table.remove(currentScreenData.items, i)
      break
    end
  end

  -- Go back to game
  GameWindow.set_state(WINDOW_GAME)
end
function Item.go_back_from_item_dialog()
  GameWindow.set_state(WINDOW_GAME)
end

function Item.go_back_from_inventory_action()
	GameWindow.set_state(WINDOW_GAME)
end

function Item.drop()
  -- Remove item from inventory
  for i, item in ipairs(Context.inventory) do
    if item == Context.dialog.active_entity then
      table.remove(Context.inventory, i)
      break
    end
  end

  -- Add item to screen
  local currentScreenData = Context.screens[Context.current_screen]
	Context.dialog.active_entity.x = Context.player.x
	Context.dialog.active_entity.y = Context.player.y
  table.insert(currentScreenData.items, Context.dialog.active_entity)

  -- Go back to inventory
  GameWindow.set_state(WINDOW_INVENTORY)
end
