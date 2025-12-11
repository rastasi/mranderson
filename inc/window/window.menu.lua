function MenuWindow.draw()
  UI.draw_top_bar("Main Menu")
  UI.draw_menu(Context.menu_items, Context.selected_menu_item, 108, 70)
end

function MenuWindow.update()
  Context.selected_menu_item = UI.update_menu(Context.menu_items, Context.selected_menu_item)

  if Input.menu_confirm() then
    local selected_item = Context.menu_items[Context.selected_menu_item]
    if selected_item and selected_item.action then
      selected_item.action()
    end
  end
end

function MenuWindow.new_game()
  Context.new_game() -- This function will be created in Context
  GameWindow.set_state(WINDOW_GAME)
end

function MenuWindow.load_game()
  Context.load_game() -- This function will be created in Context
  GameWindow.set_state(WINDOW_GAME)
end

function MenuWindow.save_game()
  Context.save_game() -- This function will be created in Context
end

function MenuWindow.exit()
  exit()
end

function MenuWindow.configuration()
  ConfigurationWindow.init()
  GameWindow.set_state(WINDOW_CONFIGURATION)
end

function MenuWindow.refresh_menu_items()
  Context.menu_items = {
    {label = "New Game", action = MenuWindow.new_game},
    {label = "Load Game", action = MenuWindow.load_game},
  }

  if Context.game_in_progress then
    table.insert(Context.menu_items, {label = "Save Game", action = MenuWindow.save_game})
  end

  table.insert(Context.menu_items, {label = "Configuration", action = MenuWindow.configuration})
  table.insert(Context.menu_items, {label = "Exit", action = MenuWindow.exit})
  Context.selected_menu_item = 1 -- Reset selection after refreshing
end


