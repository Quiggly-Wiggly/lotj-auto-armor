if AutoArmor.active and AutoArmor.phase == "enhance" then
  local item = AutoArmor.enhancements[1]
  if item then
    AutoArmor.skipped[item.keyword] = true
    AutoArmor.note("Skipping " .. item.keyword .. " during armor work because its enhancement could not be applied.")
    table.remove(AutoArmor.enhancements, 1)
  end
  AutoArmor.enhanceIndex = 1
  AutoArmor.runCurrent()
end
