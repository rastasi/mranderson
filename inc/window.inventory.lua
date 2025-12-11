function InventoryWindow.draw()
  UI.draw_top_bar("Inventory")

  if #Context.inventory == 0 then
    print("Inventory is empty.", 70, 70, Config.colors.light_grey)
  else
    for i, item in ipairs(Context.inventory) do
			local color = Config.colors.light_grey
			if i == Context.selected_inventory_item then
				color = Config.colors.green
				print(">", 60, 20 + i * 10, color)
			end
      print(item.name, 70, 20 + i * 10, color)
    end
  end
end

function InventoryWindow.update()
  Context.selected_inventory_item = UI.update_menu(Context.inventory, Context.selected_inventory_item)

  if Input.menu_confirm() and #Context.inventory > 0 then
    local selected_item = Context.inventory[Context.selected_inventory_item]
    PopupWindow.show_menu_dialog(selected_item, {
      {label = "Use", action = Item.use},
      {label = "Drop", action = Item.drop},
      {label = "Look at", action = Item.look_at},
      {label = "Go back", action = Item.go_back_from_inventory_action}
    }, WINDOW_INVENTORY_ACTION)
  end

  if Input.menu_back() then
    GameWindow.set_state(WINDOW_GAME)
  end
end
