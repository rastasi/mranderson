function Player.draw()
  spr(Context.player.sprite_id, Context.player.x, Context.player.y, 0)
end

function Player.update()
  -- Handle input
  if Input.left() then
    Context.player.vx = -Config.physics.move_speed
  elseif Input.right() then
    Context.player.vx = Config.physics.move_speed
  else
    Context.player.vx = 0
  end

  if Input.player_jump() and Context.player.jumps < Config.physics.max_jumps then
    Context.player.vy = Config.physics.jump_power
    Context.player.jumps = Context.player.jumps + 1
  end

  -- Update player position
  Context.player.x = Context.player.x + Context.player.vx
  Context.player.y = Context.player.y + Context.player.vy

  -- Screen transition
  if Context.player.x > Config.screen.width - Context.player.w then
    if Context.current_screen < #Context.screens then
      Context.current_screen = Context.current_screen + 1
      Context.player.x = 0
    else
      Context.player.x = Config.screen.width - Context.player.w
    end
  elseif Context.player.x < 0 then
    if Context.current_screen > 1 then
      Context.current_screen = Context.current_screen - 1
      Context.player.x = Config.screen.width - Context.player.w
    else
      Context.player.x = 0
    end
  end

  -- Apply gravity
  Context.player.vy = Context.player.vy + Config.physics.gravity

  local currentScreenData = Context.screens[Context.current_screen]
  -- Collision detection with platforms
  for _, p in ipairs(currentScreenData.platforms) do
    if Context.player.vy > 0 and Context.player.y + Context.player.h >= p.y and Context.player.y + Context.player.h <= p.y + p.h and Context.player.x + Context.player.w > p.x and Context.player.x < p.x + p.w then
      Context.player.y = p.y - Context.player.h
      Context.player.vy = 0
      Context.player.jumps = 0
    end
  end

  -- Collision detection with ground
  if Context.player.y + Context.player.h > Context.ground.y then
    Context.player.y = Context.ground.y - Context.player.h
    Context.player.vy = 0
    Context.player.jumps = 0
  end

  -- Entity interaction
  if Input.player_interact() then
    local interaction_found = false
    -- NPC interaction
    for _, npc in ipairs(currentScreenData.npcs) do
      if math.abs(Context.player.x - npc.x) < Config.physics.interaction_radius_npc and math.abs(Context.player.y - npc.y) < Config.physics.interaction_radius_npc then
        PopupWindow.show_menu_dialog(npc, {
          {label = "Talk to", action = NPC.talk_to},
          {label = "Fight", action = NPC.fight},
          {label = "Go back", action = NPC.go_back}
        }, WINDOW_POPUP)
        interaction_found = true
        break
      end
    end

    if not interaction_found then
      -- Item interaction
      for _, item in ipairs(currentScreenData.items) do
        if math.abs(Context.player.x - item.x) < Config.physics.interaction_radius_item and math.abs(Context.player.y - item.y) < Config.physics.interaction_radius_item then
          PopupWindow.show_menu_dialog(item, {
            {label = "Use", action = Item.use},
            {label = "Look at", action = Item.look_at},
            {label = "Put away", action = Item.put_away},
            {label = "Go back", action = Item.go_back_from_item_dialog}
          }, WINDOW_POPUP)
          interaction_found = true
          break
        end
      end
    end

    -- If no interaction happened, open inventory
    if not interaction_found then
      GameWindow.set_state(WINDOW_INVENTORY)
    end
  end
end
