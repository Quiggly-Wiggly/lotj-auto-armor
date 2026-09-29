if AutoArmor.active and AutoArmor.phase == "enhance" then
  AutoArmor.note("Enhancement failed; retrying current item.")
  AutoArmor.runCurrent()
end
