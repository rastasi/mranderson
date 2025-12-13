function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.dark_grey)
  Print.text(title, 3, 2, Config.colors.green)
end

function UI.draw_dialog()
  PopupWindow.draw()
end

function UI.draw_menu(items, selected_item, x, y)
  for i, item in ipairs(items) do
    local current_y = y + (i-1)*10
    if i == selected_item then
      Print.text(">", x - 8, current_y, Config.colors.green)
    end
    Print.text(item.label, x, current_y, Config.colors.green)
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

function UI.create_numeric_stepper(label, value_getter, value_setter, min, max, step, format)
  return {
    label = label,
    get = value_getter,
    set = value_setter,
    min = min,
    max = max,
    step = step,
    format = format or "%.1f",
    type = "numeric_stepper"
  }
end

function UI.create_action_item(label, action)
  return {
    label = label,
    action = action,
    type = "action_item"
  }
end
