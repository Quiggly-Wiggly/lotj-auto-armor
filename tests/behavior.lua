local sent,output,links,events={},{},{},{}
AutoArmor=nil
function send(t) assert(not t:find(';;',1,true));sent[#sent+1]=t end
function cecho(t) output[#output+1]=t end
function echo(t) output[#output+1]=t end
function resetFormat() end
function setFgColor() end
function setBold() end
function setUnderline() end
function setItalics() end
function echoLink(t,fn) links[#links+1]=fn;echo(t) end
function printCmdLine(...)
  -- Mudlet's two-argument overload treats argument 1 as a command-line name.
  assert(select('#',...)==1,'main input requires exactly one argument')
  local t=...
  assert(type(t)=='string')
  draft=t
end
function getCommandSeparator() return ';;' end
function registerAnonymousEventHandler(name,fn) events[name]=fn end
dofile('src/scripts/core.lua')
assert(#sent==0 and not AutoArmor.active and #AutoArmor.queue==0)
AutoArmor.help();AutoArmor.status();AutoArmor.showList()
local expected={'autoarmor add ','autoarmor enhance ','autoarmor start','autoarmor stop',
  'autoarmor resume','autoarmor next','autoarmor list','autoarmor clear','autoarmor status','autoarmor help'}
assert(#links==#expected)
for i,fn in ipairs(links) do fn();assert(draft==expected[i]) end
assert(#sent==0)
AutoArmor.add('sample');AutoArmor.enhance('sample','example')
AutoArmor.add('bad;;quit');assert(#AutoArmor.queue==1)
AutoArmor.start();assert(sent[#sent]=='enhancearmor sample example')
matches={'','example'};dofile('src/scripts/autoarmor-enhance-next.lua')
assert(sent[#sent]=='makearmor sample' and sent[#sent-1]=='examine sample')
matches={'','sample'};dofile('src/scripts/autoarmor-work-complete.lua')
assert(not AutoArmor.active and #AutoArmor.queue==0)
local n=#sent;dofile('src/scripts/autoarmor-work-continue.lua');assert(#sent==n)
AutoArmor.add('<red>literal');output={};AutoArmor.showList();assert(table.concat(output):find('<red>literal',1,true))
AutoArmor.start();events.sysDisconnectionEvent();assert(not AutoArmor.active)
n=#sent;dofile('src/scripts/autoarmor-work-continue.lua');assert(#sent==n)
print('Armor fresh install, literal UI, review-only links, queues, and disconnect checks passed.')
