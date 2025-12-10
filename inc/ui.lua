--------------------------------------------------------------------------------
-- UI Module
--------------------------------------------------------------------------------
function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.dark_grey)
  print(title, 3, 2, Config.colors.green)
end

function UI.draw_dialog()
  PopupWindow.draw()
end

function PopupWindow.draw()
  rect(40, 40, 160, 80, Config.colors.black)
  rectb(40, 40, 160, 80, Config.colors.green)

  -- Display the entity's name as the dialog title
  if Context.dialog.active_entity and Context.dialog.active_entity.name then
    print(Context.dialog.active_entity.name, 120 - #Context.dialog.active_entity.name * 2, 45, Config.colors.green)
  end

  -- Display the dialog content (description for "look at", or initial name/dialog for others)
  local wrapped_lines = UI.word_wrap(Context.dialog.text, 25) -- Max 25 chars per line
  local current_y = 55 -- Starting Y position for the first line of content
  for _, line in ipairs(wrapped_lines) do
    print(line, 50, current_y, Config.colors.light_grey)
    current_y = current_y + 8 -- Move to the next line (8 pixels for default font height + padding)
  end
  
  -- Adjust menu position based on the number of wrapped lines
  if not Context.dialog.showing_description then
    UI.draw_menu(Context.dialog.menu_items, Context.dialog.selected_menu_item, 50, current_y + 2)
  else
    -- If description is showing, provide a "Go back" option automatically, or close dialog on action
    -- For now, let's just make it implicitly wait for Input.menu_confirm() or Input.menu_back() to close
    -- Or we can add a specific "Back" option here.
    -- Let's add a "Back" option for explicit return from description.
    print("[A] Go Back", 50, current_y + 10, Config.colors.green)
  end
end

function UI.draw_menu(items, selected_item, x, y)
  for i, item in ipairs(items) do
    local current_y = y + (i-1)*10
    if i == selected_item then
      print(">", x - 8, current_y, Config.colors.green)
    end
    print(item.label, x, current_y, Config.colors.green)
  end
end

function UI.update_menu(items, selected_item)
  if Input.up() then
    selected_item = selected_item - 1
    if selected_item < 1 then
      selected_item = #items
    end
  elseif Input.down() then
    selected_item = selected_item + 1
    if selected_item > #items then
      selected_item = 1
    end
  end
  return selected_item
end

function UI.word_wrap(text, max_chars_per_line)
    if text == nil then return {""} end
    local lines = {}
    
    for input_line in (text .. "\n"):gmatch("(.-)\n") do
        local current_line = ""
        local words_in_line = 0
        for word in input_line:gmatch("%S+") do
            words_in_line = words_in_line + 1
            if #current_line == 0 then
                current_line = word
            elseif #current_line + #word + 1 <= max_chars_per_line then
                current_line = current_line .. " " .. word
            else
                table.insert(lines, current_line)
                current_line = word
            end
        end
        
        if words_in_line > 0 then
            table.insert(lines, current_line)
        else
            table.insert(lines, "")
        end
    end
    
    if #lines == 0 then
        return {""}
    end
    
    return lines
end

