if type(AutoArmor) ~= "table" then
  AutoArmor = {}
end

AutoArmor.queue = type(AutoArmor.queue) == "table" and AutoArmor.queue or {}
AutoArmor.enhancements = type(AutoArmor.enhancements) == "table" and AutoArmor.enhancements or {}
AutoArmor.skipped = type(AutoArmor.skipped) == "table" and AutoArmor.skipped or {}

-- v2.1 tracked completed entries with indexes. Convert an existing session to
-- the v2.2 remaining-work queues without repeating completed armor.
if tostring(AutoArmor.version or ""):match("^2%.1%.") then
  local completedEnhancements = math.max(0, (tonumber(AutoArmor.enhanceIndex) or 1) - 1)
  local completedArmor = math.max(0, (tonumber(AutoArmor.workIndex) or 1) - 1)
  for _ = 1, completedEnhancements do
    if #AutoArmor.enhancements > 0 then table.remove(AutoArmor.enhancements, 1) end
  end
  for _ = 1, completedArmor do
    if #AutoArmor.queue > 0 then table.remove(AutoArmor.queue, 1) end
  end
end

AutoArmor.version = "2.3.0"

if AutoArmor.keyword and #AutoArmor.queue == 0 then
  table.insert(AutoArmor.queue, AutoArmor.keyword)
end
AutoArmor.keyword = nil

AutoArmor.active = false
AutoArmor.afk = AutoArmor.afk == true
AutoArmor.managedBot = AutoArmor.managedBot == true
AutoArmor.phase = AutoArmor.phase or "idle"
AutoArmor.workIndex = 1
AutoArmor.enhanceIndex = 1

function AutoArmor.trim(value)
  return tostring(value or ""):match("^%s*(.-)%s*$")
end

function AutoArmor.note(message)
  AutoArmor.text('heading','[AutoArmor] ')
  AutoArmor.text('text',tostring(message)..'\n')
end

function AutoArmor.hasQueuedWork()
  return #AutoArmor.queue > 0 or #AutoArmor.enhancements > 0
end

function AutoArmor.stopBot()
  if AutoArmor.managedBot then
    send("bot stop")
    AutoArmor.managedBot = false
  end
end

function AutoArmor.stop(message)
  AutoArmor.active = false
  AutoArmor.stopBot()
  if message then
    AutoArmor.note(message)
  end
end

function AutoArmor.finish()
  AutoArmor.active = false
  AutoArmor.phase = "done"
  AutoArmor.workIndex = 1
  AutoArmor.enhanceIndex = 1
  AutoArmor.stopBot()
  AutoArmor.note("All queued enhancement and armor work is complete.")
end

function AutoArmor.runCurrent()
  if not AutoArmor.active then
    return false
  end

  if AutoArmor.phase == "enhance" then
    local item = AutoArmor.enhancements[1]
    while item and AutoArmor.skipped[item.keyword] do
      AutoArmor.note("Skipped remaining enhancement for: " .. item.keyword)
      table.remove(AutoArmor.enhancements, 1)
      item = AutoArmor.enhancements[1]
    end

    if item then
      send("enhancearmor " .. item.keyword .. " " .. item.enhancement)
      return true
    end

    AutoArmor.phase = "work"
    AutoArmor.workIndex = 1
    AutoArmor.note("Enhancements complete; starting armor work.")
  end

  if AutoArmor.phase == "work" then
    local keyword = AutoArmor.queue[1]
    while keyword and AutoArmor.skipped[keyword] do
      AutoArmor.note("Skipped armor: " .. keyword)
      table.remove(AutoArmor.queue, 1)
      keyword = AutoArmor.queue[1]
    end

    if keyword then
      send("examine " .. keyword)
      send("makearmor " .. keyword)
      return true
    end
  end

  AutoArmor.finish()
  return false
end

function AutoArmor.start()
  if not AutoArmor.hasQueuedWork() then
    AutoArmor.note("Nothing queued. Use autoarmor add <keyword> first.")
    return
  end

  AutoArmor.workIndex = 1
  AutoArmor.enhanceIndex = 1
  AutoArmor.skipped = {}
  AutoArmor.phase = #AutoArmor.enhancements > 0 and "enhance" or "work"
  AutoArmor.active = true
  AutoArmor.note("Started with " .. #AutoArmor.enhancements .. " enhancement(s) and " .. #AutoArmor.queue .. " armor piece(s).")
  AutoArmor.runCurrent()
end

function AutoArmor.resume()
  if not AutoArmor.hasQueuedWork() then
    AutoArmor.note("Nothing queued.")
    return
  end

  if AutoArmor.phase == "idle" or AutoArmor.phase == "done" then
    AutoArmor.start()
    return
  end

  AutoArmor.active = true
  AutoArmor.note("Resuming " .. AutoArmor.phase .. " queue.")
  AutoArmor.runCurrent()
end

function AutoArmor.next()
  if not AutoArmor.active then
    AutoArmor.note("Not running.")
    return
  end

  if AutoArmor.phase == "enhance" then
    table.remove(AutoArmor.enhancements, 1)
    AutoArmor.enhanceIndex = 1
  elseif AutoArmor.phase == "work" then
    table.remove(AutoArmor.queue, 1)
    AutoArmor.workIndex = 1
  end
  AutoArmor.runCurrent()
end

local colors={heading={255,190,70},command={70,220,235},text={235,240,245},muted={155,170,185},error={255,120,120}}
function AutoArmor.text(tone,value)
  resetFormat(); setBold(false); setUnderline(false); setItalics(false)
  setFgColor(unpack(colors[tone] or colors.text)); echo(value); resetFormat()
end
function AutoArmor.commandRow(cmd,description)
  AutoArmor.text('command','  '); setFgColor(unpack(colors.command))
  if echoLink and printCmdLine then
    echoLink(cmd,function() printCmdLine(cmd:gsub('<.*','')) end,'Fill the input line; review and press Enter.',true)
  else echo(cmd) end
  AutoArmor.text('muted','  '..description..'\n')
end
function AutoArmor.valid(value)
  local sep=getCommandSeparator and getCommandSeparator() or ';;'
  return value~='' and #value<=120 and not value:find('[%c;]') and (sep=='' or not value:find(sep,1,true))
end
function AutoArmor.add(value)
  value=AutoArmor.trim(value)
  if not AutoArmor.valid(value) then AutoArmor.text('error','Use autoarmor add <keyword>.\n'); return end
  table.insert(AutoArmor.queue,value); AutoArmor.note('Queued: '..value)
end
function AutoArmor.enhance(keyword,value)
  keyword,value=AutoArmor.trim(keyword),AutoArmor.trim(value)
  if not AutoArmor.valid(keyword) or not AutoArmor.valid(value) then
    AutoArmor.text('error','Use autoarmor enhance <keyword> <enhancement>.\n'); return
  end
  table.insert(AutoArmor.enhancements,{keyword=keyword,enhancement=value})
  AutoArmor.note('Queued: '..keyword..' + '..value)
end
function AutoArmor.showList()
  AutoArmor.text('heading','\n  AUTO ARMOR | Queues\n')
  for i,k in ipairs(AutoArmor.queue) do AutoArmor.text('text','  Armor '..i..': '..k..'\n') end
  for i,k in ipairs(AutoArmor.enhancements) do AutoArmor.text('text','  Enhance '..i..': '..k.keyword..' + '..k.enhancement..'\n') end
  if not AutoArmor.hasQueuedWork() then AutoArmor.text('muted','  Empty. Use autoarmor add <keyword>.\n') end
end
function AutoArmor.status()
  AutoArmor.text('heading','\n  AUTO ARMOR v'..AutoArmor.version..' | Status\n')
  AutoArmor.text('text','  '..(AutoArmor.active and 'Running' or 'Stopped')..' / '..AutoArmor.phase..'\n')
  AutoArmor.text('muted','  Armor: '..#AutoArmor.queue..' / Enhancements: '..#AutoArmor.enhancements..'\n')
end
function AutoArmor.help()
  AutoArmor.text('heading','\n  AUTO ARMOR v'..AutoArmor.version..' | Commands\n')
  for _,r in ipairs({{'autoarmor add <keyword>','Queue armor'},
    {'autoarmor enhance <keyword> <enhancement>','Queue enhancement'},
    {'autoarmor start','Start queues'}, {'autoarmor stop','Pause'},
    {'autoarmor resume','Resume'}, {'autoarmor next','Skip current'},
    {'autoarmor list','View queues'}, {'autoarmor clear','Clear queues'},
    {'autoarmor status','Progress'}, {'autoarmor help','Commands'}}) do
    AutoArmor.commandRow(r[1],r[2])
  end
  AutoArmor.text('muted','  Enhancements run first. Click to edit; Enter runs it.\n')
end
-- Loading never resumes automation; reconnect requires an explicit command.
registerAnonymousEventHandler('sysDisconnectionEvent',function()
  AutoArmor.active=false; AutoArmor.managedBot=false
end)
