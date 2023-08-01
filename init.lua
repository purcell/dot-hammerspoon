local hotkey = require "hs.hotkey"
local mash = {"ctrl", "cmd", "alt"}

-- https://github.com/dsanson/hs.tiling
local tiling = require "hs.tiling"
hotkey.bind(mash, "i", function() tiling.cycleLayout() end)
hotkey.bind(mash, "l", function() tiling.cycle(1) end)
hotkey.bind(mash, "j", function() tiling.cycle(-1) end)
hotkey.bind(mash, "k", function() tiling.promote() end)
hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)

tiling.set('layouts', {
  'fullscreen', 'main-vertical', 'gp-vertical', 'columns'
})

-- https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
-- TODO: maybe prefer http://www.hammerspoon.org/docs/hs.grid.html
local positions = {
  maximized = hs.layout.maximized,
  centerCol = {x=0.33, y=0, w=0.34, h=1},
  centerRow = {x=0, y=0.33, w=1, h=0.34},

  left33 = {x=0, y=0, w=0.33, h=1},
  left50 = hs.layout.left50,
  left67 = {x=0, y=0, w=0.67, h=1},

  right33 = {x=0.67, y=0, w=0.33, h=1},
  right50 = hs.layout.right50,
  right67 = {x=0.33, y=0, w=0.67, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper33 = {x=0, y=0, w=1, h=0.33},
  upper67 = {x=0, y=0, w=1, h=0.67},

  upper50Left33 = {x=0, y=0, w=0.33, h=0.5},
  upper50Left67 = {x=0, y=0, w=0.67, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},

  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},
  upper50Right33 = {x=0.67, y=0, w=0.33, h=0.5},
  upper50Right67 = {x=0.33, y=0, w=0.67, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower67 = {x=0, y=0.33, w=1, h=0.67},
  lower33 = {x=0, y=0.67, w=1, h=0.33},

  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Left33 = {x=0, y=0.5, w=0.33, h=0.5},
  lower50Left67 = {x=0, y=0.5, w=0.67, h=0.5},

  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5},
  lower50Right33 = {x=0.67, y=0.5, w=0.33, h=0.5},
  lower50Right67 = {x=0.33, y=0.5, w=0.67, h=0.5}
}

-- Repeated presses of these keys cycle the selected window through the listed placements,
local grid = {
  {key="q", units={positions.upper50Left50, positions.upper50Left67, positions.upper50Left33}},
  {key="w", units={positions.upper50, positions.upper67, positions.upper33}},
  {key="e", units={positions.upper50Right50, positions.upper50Right67, positions.upper50Right33}},

  {key="a", units={positions.left50, positions.left67, positions.left33}},
  {key="s", units={positions.maximized, positions.centerCol, positions.centerRow}},
  {key="d", units={positions.right50, positions.right67, positions.right33}},

  {key="z", units={positions.lower50Left50, positions.lower50Left67, positions.lower50Left33}},
  {key="x", units={positions.lower50, positions.lower67, positions.lower33}},
  {key="c", units={positions.lower50Right50, positions.lower50Right67, positions.lower50Right33}}
}

local rectToGeom = function(unit)
  local screen = hs.screen.mainScreen()
  return hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
end

hs.fnutils.each(grid, function(entry)
  hotkey.bind(mash, entry.key, function()
    local units = entry.units
    local window = hs.window.focusedWindow()
    local windowGeo = window:frame():floor()

    local index = 0
    hs.fnutils.find(units, function(unit)
      index = index + 1
      local geo = rectToGeom(unit)
      return windowGeo:equals(geo)
    end)
    if index == #units then index = 0 end
    window:moveToUnit(units[index + 1])
  end)
end)

hotkey.bind(mash, "/", function()
    local window = hs.window.focusedWindow()
    local otherScreen = hs.fnutils.find(hs.screen.allScreens(), function(s)
                                           return s ~= window:screen()
    end)
    if otherScreen ~= nil then
       window:moveToScreen(otherScreen)
    end
end)

-- hs.window.highlight.ui.overlay = true
-- hs.window.highlight.ui.overlayColor = {0,0,0,0.0000000001}
-- hs.window.highlight.ui.frameWidth = 3 -- seems to only work if overlayColor is non-transparent
-- hs.window.highlight.ui.frameColor = {1,0,0,1}
-- hs.window.highlight.start()


-- Trying out hs.window.tiling
hotkey.bind(mash, "p", function()
               local window = hs.window.focusedWindow()
               local allScreenWindows = {window, table.unpack(window:otherWindowsSameScreen())}
               hs.window.tiling.tileWindows(allScreenWindows, window:screen():fullFrame())
end)



-- Stop and start NepTunes scrobbler with Music
local applicationWatcher = function(appName, eventType, appObject)
  if (appName == "Music") then
    if (eventType == hs.application.watcher.launched) then
      hs.application.launchOrFocus("NepTunes")
    elseif (eventType == hs.application.watcher.terminated) then
      local app = hs.appfinder.appFromName("NepTunes")
      if app then
        app:kill()
      end
    end
  end
end

local musicWatcher = hs.application.watcher.new(applicationWatcher)
musicWatcher:start()
