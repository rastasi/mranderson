function SplashWindow.draw()
  Print.text("Mr. Anderson's", 78, 60, Config.colors.green)
  Print.text("Addventure", 90, 70, Config.colors.green)
end

function SplashWindow.update()
  Context.splash_timer = Context.splash_timer - 1
  if Context.splash_timer <= 0 or Input.menu_confirm() then
    GameWindow.set_state(WINDOW_INTRO)
  end
end
