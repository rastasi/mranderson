function GameWindow.draw()
  local currentScreenData = Context.screens[Context.current_screen]

  UI.draw_top_bar(currentScreenData.name)

  -- Draw platforms
  for _, p in ipairs(currentScreenData.platforms) do
    rect(p.x, p.y, p.w, p.h, Config.colors.green)
  end

  -- Draw items
  for _, item in ipairs(currentScreenData.items) do
    spr(item.sprite_id, item.x, item.y, 0)
  end

  -- Draw NPCs
  for _, npc in ipairs(currentScreenData.npcs) do
    spr(npc.sprite_id, npc.x, npc.y, 0)
  end

  -- Draw ground
  rect(Context.ground.x, Context.ground.y, Context.ground.w, Context.ground.h, Config.colors.dark_grey)

  -- Draw player
  Player.draw()
end

function GameWindow.update()
  Player.update() -- Call the encapsulated player update logic
end

function GameWindow.set_state(new_state)
  Context.active_window = new_state
  -- Add any state-specific initialization/cleanup here later if needed
end