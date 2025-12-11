function NPC.talk_to()
  local npc = Context.dialog.active_entity
  if npc.dialog and npc.dialog.start then
    PopupWindow.set_dialog_node("start")
  else
    -- if no dialog, go back
    GameWindow.set_state(WINDOW_GAME)
  end
end
function NPC.fight() end
function NPC.go_back()
  GameWindow.set_state(WINDOW_GAME)
end
