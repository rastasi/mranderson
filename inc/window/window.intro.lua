function IntroWindow.draw() 
  local x = (Config.screen.width - 132) / 2 -- Centered text
  print(Context.intro.text, x, Context.intro.y, Config.colors.green)
end

function IntroWindow.update() 
  Context.intro.y = Context.intro.y - Context.intro.speed

  -- Count lines in intro text to determine when scrolling is done
  local lines = 1
  for _ in string.gmatch(Context.intro.text, "\n") do
    lines = lines + 1
  end

  -- When text is off-screen, go to menu
  if Context.intro.y < -lines * 8 then
    GameWindow.set_state(WINDOW_MENU)
  end

  -- Skip intro by pressing A
  if Input.menu_confirm() then
    GameWindow.set_state(WINDOW_MENU)
  end
end

