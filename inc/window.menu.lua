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

function MenuWindow.play()
  -- Reset player state and screen for a new game
  Context.player.x = Config.player.start_x
  Context.player.y = Config.player.start_y
  Context.player.vx = 0
  Context.player.vy = 0
  Context.player.jumps = 0
  Context.current_screen = 1
  GameWindow.set_state(WINDOW_GAME)
end

function MenuWindow.exit()
  exit()
end

-- Initialize menu items after actions are defined
Context.menu_items = {
  {label = "Play", action = MenuWindow.play},
  {label = "Exit", action = MenuWindow.exit}
}
