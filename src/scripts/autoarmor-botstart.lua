if AutoArmor.active and AutoArmor.hasQueuedWork() then
  if AutoArmor.afk then
    send("afk")
  end
  send("bot start")
  AutoArmor.managedBot = true
  AutoArmor.runCurrent()
end
