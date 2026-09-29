if AutoArmor.active and AutoArmor.phase == "work" then
  local keyword = AutoArmor.queue[1]
  if keyword then
    table.remove(AutoArmor.queue, 1)
  end
  AutoArmor.workIndex = 1
  AutoArmor.note("Finished: " .. matches[2] .. " armor" .. (keyword and " (removed " .. keyword .. " from queue)" or ""))
  AutoArmor.runCurrent()
end
