--------------------------------------------------------------------------------
-- Menu Actions
--------------------------------------------------------------------------------
function MenuActions.play()
  -- Reset player state and screen for a new game
  Context.player.x = Config.player.start_x
  Context.player.y = Config.player.start_y
  Context.player.vx = 0
  Context.player.vy = 0
  Context.player.jumps = 0
  Context.current_screen = 1
  GameWindow.set_state(WINDOW_GAME)
end

function MenuActions.exit()
  exit()
end

-- Initialize menu items after actions are defined
Context.menu_items = {
  {label = "Play", action = MenuActions.play},
  {label = "Exit", action = MenuActions.exit}
}
