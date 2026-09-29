if AutoArmor.active and AutoArmor.phase == "enhance" then
  local item = AutoArmor.enhancements[1]
  if item then
    send("examine " .. item.keyword)
    table.remove(AutoArmor.enhancements, 1)
  end
  AutoArmor.enhanceIndex = 1
  AutoArmor.runCurrent()
end
