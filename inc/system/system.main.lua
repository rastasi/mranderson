local STATE_HANDLERS = {
  [WINDOW_SPLASH] = function()
    SplashWindow.update()
    SplashWindow.draw()
  end,
  [WINDOW_INTRO] = function()
    IntroWindow.update()
    IntroWindow.draw()
  end,
  [WINDOW_MENU] = function()
    MenuWindow.update()
    MenuWindow.draw()
  end,
  [WINDOW_GAME] = function()
    GameWindow.update()
    GameWindow.draw()
  end,
  [WINDOW_POPUP] = function()
    GameWindow.draw()
    PopupWindow.update()
    PopupWindow.draw()
  end,
  [WINDOW_INVENTORY] = function()
    InventoryWindow.update()
    InventoryWindow.draw()
  end,
  [WINDOW_INVENTORY_ACTION] = function()
    InventoryWindow.draw()
    PopupWindow.draw()
    PopupWindow.update()
  end,
  [WINDOW_CONFIGURATION] = function()
    ConfigurationWindow.update()
    ConfigurationWindow.draw()
  end,
}

function TIC()
  cls(Config.colors.black)
  local handler = STATE_HANDLERS[Context.active_window]
  if handler then
    handler()
  end
end
