--
-- ContractorMod
-- Specialization for managing several characters when playing solo game
-- Update attached to update event of the map
--
-- @author  yumi
-- free for noncommercial-usage
--

-- TODO:
-- 

source(Utils.getFilename("scripts/ContractorModWorker.lua", g_currentModDirectory))

ContractorMod = {};
ContractorMod.myCurrentModDirectory = g_currentModDirectory;

ContractorMod.debug = false --true --
ContractorMod.useDebugCommands = false
-- TODO:
-- Passenger: Try to add cameras
-- Try to have workers on different farms (farmId)

-- TO FIX:
-- Wrong rotation of on Foot Characters

function ContractorMod:loadedMission() --[[----------------------------------------------------------------]] print("This is a development version of ContractorMod for FS22, which may and will contain errors, bugs.") end
Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, ContractorMod.loadedMission)

-- @doc First code called during map loading (before we can actually interact)
function ContractorMod:loadMap(name)
  if ContractorMod.debug then print("ContractorMod:loadMap(name)") end
  self.initializing = true
  if self.initialized then
    return;
  end;

  g_playerColors = {
    {
      name = "color_white",
      value = {
        1,
        1,
        1,
        1
      }
    },
    {
      name = "color_lightGrey",
      value = {
        0.7,
        0.7,
        0.75,
        1
      }
    },
    {
      name = "color_darkGrey",
      value = {
        0.12,
        0.12,
        0.14,
        1
      }
    },
    {
      name = "color_black",
      value = {
        0.03,
        0.03,
        0.03,
        1
      }
    },
    {
      name = "color_iceblue",
      value = {
        0.287,
        0.533,
        0.904,
        1
      }
    },
    {
      name = "color_blue",
      value = {
        0.11,
        0.24,
        0.45,
        1
      }
    },
    {
      name = "color_darkBlue",
      value = {
        0.0395,
        0.083,
        0.235,
        1
      }
    },
    {
      name = "color_lakeBlue",
      value = {
        0.0232,
        0.0382,
        0.0844,
        1
      }
    },
    {
      name = "color_brightGreen",
      value = {
        0.296,
        0.439,
        0.107,
        1
      }
    },
    {
      name = "color_green",
      value = {
        0.11,
        0.31,
        0.09,
        1
      }
    },
    {
      name = "color_darkGreen",
      value = {
        0.038,
        0.0865,
        0.0215,
        1
      }
    },
    {
      name = "color_forestGreen",
      value = {
        0.017,
        0.0275,
        0.0131,
        1
      }
    },
    {
      name = "color_pink",
      value = {
        0.855,
        0.255,
        0.404,
        1
      }
    },
    {
      name = "color_brightRed",
      value = {
        0.5,
        0.1,
        0.1,
        1
      }
    },
    {
      name = "color_red",
      value = {
        0.25,
        0.05,
        0.05,
        1
      }
    },
    {
      name = "color_purple",
      value = {
        0.104,
        0.0356,
        0.117,
        1
      }
    },
    {
      name = "color_yellow",
      value = {
        0.839,
        0.597,
        0.235,
        1
      }
    },
    {
      name = "color_darkYellow",
      value = {
        0.468,
        0.314,
        0.104,
        1
      }
    },
    {
      name = "color_lightBrown",
      value = {
        0.21,
        0.123,
        0.063,
        1
      }
    },
    {
      name = "color_brown",
      value = {
        0.07,
        0.041,
        0.021,
        1
      }
    }
  }
  self.initialized = true;
end;

function ContractorMod:deleteMap()
  if ContractorMod.debug then print("ContractorMod:deleteMap()") end
  self.initialized = false;
  self.workers = nil;
end;
 
-- @doc register InputBindings
function ContractorMod:registerActionEvents()
  if ContractorMod.debug then print("ContractorMod:registerActionEvents()") end
  for _,actionName in pairs({ "ContractorMod_WORKER1",
                              "ContractorMod_WORKER2",
                              "ContractorMod_WORKER3",
                              "ContractorMod_WORKER4",
                              "ContractorMod_WORKER5",
                              "ContractorMod_WORKER6",
                              "ContractorMod_WORKER7",
                              "ContractorMod_WORKER8" }) do
    -- print("actionName "..actionName)
    local __, eventName, event, action = InputBinding.registerActionEvent(g_inputBinding, actionName, self, ContractorMod.activateWorker ,false ,true ,false ,true)
    if __ then
      g_inputBinding.events[eventName].displayIsVisible = false
    end
  end

  if ContractorMod.useDebugCommands then
    print("ContractorMod:registerActionEvents() for DEBUG")
    for _,actionName in pairs({ "ContractorMod_DEBUG_MOVE_PASS_LEFT",
                                "ContractorMod_DEBUG_MOVE_PASS_RIGHT",
                                "ContractorMod_DEBUG_MOVE_PASS_TOP",
                                "ContractorMod_DEBUG_MOVE_PASS_BOTTOM",
                                "ContractorMod_DEBUG_MOVE_PASS_FRONT",
                                "ContractorMod_DEBUG_MOVE_PASS_BACK",
                                "ContractorMod_DEBUG_DUMP_PASS" }) do
      -- print("actionName "..actionName)
      local __, eventName, event, action = InputBinding.registerActionEvent(g_inputBinding, actionName, self, ContractorMod.debugCommands ,false ,true ,false ,true)
    end
  end
end

-- @doc registerActionEvents need to be called regularly
function ContractorMod:appRegisterActionEvents()
  if ContractorMod.debug then print("ContractorMod:appRegisterActionEvents()") end
  ContractorMod:registerActionEvents()
end
-- Only needed for global action event 
FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ContractorMod.appRegisterActionEvents);

-- @doc Called by update method only once at the beginning when nothing is initialized yet
function ContractorMod:init()
  if ContractorMod.debug then print("ContractorMod:init()") end

  -- Look for file FS19_ContractorMod.debug in mod directory to activate debug commands
  if g_currentMission ~= nil and g_currentMission:getIsServer() then
    if ContractorMod.myCurrentModDirectory then
      local debugFilePath = ContractorMod.myCurrentModDirectory .. "../FS19_ContractorMod.debug.xml"
      if fileExists(debugFilePath) then
        print("ContractorMod: Activating DEBUG commands")
        ContractorMod.useDebugCommands = true
        -- self:addDebugInputBinding()
      end
    end
  end

  self.currentID = 1.
  self.numWorkers = 4.
  self.workers = {}
  self.initializing = true
  self.shouldStopWorker = true      --Enable to distinguish LeaveVehicle when switchingWorker and when leaving due to player request
  self.enableSeveralDrivers = false --Should be always true when passenger works correctly
  self.switching = false
  self.passengerLeaving = false
  ContractorMod.passengerEntering = false
  ContractorMod.displayPlayerNames = true
  ContractorMod.UniversalPassenger = nil
  ContractorMod.UniversalPassenger_VehiclesOfModHub = nil

  self:manageSpecialVehicles()

  local savegameDir;
  if g_currentMission.missionInfo.savegameDirectory then
    savegameDir = g_currentMission.missionInfo.savegameDirectory;
  end;
  if not savegameDir and g_careerScreen.currentSavegame and g_careerScreen.currentSavegame.savegameIndex then
    savegameDir = ('%ssavegame%d'):format(getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex);
  end;
  if not savegameDir and g_currentMission.missionInfo.savegameIndex ~= nil then
    savegameDir = ('%ssavegame%d'):format(getUserProfileAppPath(), g_careerScreen.missionInfo.savegameIndex);
  end;
  self.savegameFolderPath = savegameDir;
  self.ContractorModXmlFilePath = self.savegameFolderPath .. '/ContractorMod.xml';

  if not self:initFromSave() or #self.workers <= 0 then
    if not self:initFromParam() or #self.workers <= 0 then
      -- default values
      if ContractorMod.debug then print("ContractorMod: No savegame: set default values") end
      local workerStyle = g_currentMission.player:getStyle()
      workerStyle.playerColorIndex = 0;
      local worker = ContractorModWorker:new("Alex", 1, workerStyle)
      table.insert(self.workers, worker)
      workerStyle.playerColorIndex = 1;
      worker = ContractorModWorker:new("Brenda", 2, workerStyle)
      table.insert(self.workers, worker)
      workerStyle.playerColorIndex = 2;
      worker = ContractorModWorker:new("Chris", 3, workerStyle)
      table.insert(self.workers, worker)
      workerStyle.playerColorIndex = 3;
      worker = ContractorModWorker:new("David", 4, workerStyle)
      table.insert(self.workers, worker)
      self.numWorkers = 4
      self.enableSeveralDrivers = true
      self.displaySettings = {}
      self.displaySettings.characterName = {}
      self.displaySettings.characterName.x = 0.9828
      self.displaySettings.characterName.y = 0.90
      self.displaySettings.characterName.size = 0.024
    end
  end
  -- DebugUtil.printTableRecursively(g_currentMission.players, " ", 1, 2)
  -- Associate 1 player to each character and show it if needed
  local index = 1
  for k, p in pairs(g_currentMission.players) do
    if p ~= nil and p.rootNode ~= g_currentMission.player.rootNode then
        local worker = self.workers[index]
        p.isControlled = true
        p:moveTo(worker.x, worker.y-0.8, worker.z, true, true)

        if index > 1 and worker.currentVehicle == nil then
          p:setVisibility(true)
          p.isEntered = false
          -- setRotation(p.graphicsRootNode, 0, worker.rotY + math.rad(180.0), 0) -- + math.rad(120.0), 0)  -- Why 120? difference ???
          -- setRotation(p.cameraNode, worker.rotX, worker.rotY, 0)
        else
          p:moveToAbsoluteInternal(0, -200, 0);
          p:setVisibility(false)
          p.isEntered = true
          setRotation(p.graphicsRootNode, 0, worker.rotY + math.rad(180.0), 0) -- + math.rad(120.0), 0)  -- Why 120? difference ???
          setRotation(p.cameraNode, worker.rotX, worker.rotY, 0)
        end
        p:setStyleAsync(worker.playerStyle, nil, false)
        worker.player = p
        index = index + 1
    end
  end
  if ContractorMod.debug then print("ContractorMod:init()------------") end
  -- DebugUtil.printTableRecursively(self.workers, " ", 1, 3)
end


function ContractorMod:onSwitchVehicle(action)
  if ContractorMod.debug then print("ContractorMod:onSwitchVehicle()") end
  self.switching = true
  if action == "SWITCH_VEHICLE" then
    if ContractorMod.debug then print('ContractorMod_NEXTWORKER pressed') end
    local nextID = 0
    if ContractorMod.debug then print("ContractorMod: self.currentID " .. tostring(self.currentID)) end
    if ContractorMod.debug then print("ContractorMod: self.numWorkers " .. tostring(self.numWorkers)) end
    if self.currentID < self.numWorkers then
      nextID = self.currentID + 1
    else
      nextID = 1
    end
    if ContractorMod.debug then print("ContractorMod: nextID " .. tostring(nextID)) end
    self:setCurrentContractorModWorker(nextID)
  elseif action == "SWITCH_VEHICLE_BACK" then
    if ContractorMod.debug then print('ContractorMod_PREVWORKER pressed') end
    local prevID = 0
    if self.currentID > 1 then
      prevID = self.currentID - 1
    else
      prevID = self.numWorkers
    end    
    self:setCurrentContractorModWorker(prevID)
  end
end

-- @doc Replace switch vehicle by switch worker
function ContractorMod:replaceOnSwitchVehicle(superfunc, action, direction)
  ContractorMod:onSwitchVehicle(action)
end
BaseMission.onSwitchVehicle = Utils.overwrittenFunction(BaseMission.onSwitchVehicle, ContractorMod.replaceOnSwitchVehicle);

-- @doc Switch directly to another worker
function ContractorMod:activateWorker(actionName, keyStatus)
	if ContractorMod.debug then print("ContractorMod:activateWorker") end
  if ContractorMod.debug then print("actionName "..tostring(actionName)) end
  if string.sub(actionName, 1, 20) == "ContractorMod_WORKER" then
    local workerIndex = tonumber(string.sub(actionName, -1))
    if self.numWorkers >= workerIndex and workerIndex ~= self.currentID then
      self:setCurrentContractorModWorker(workerIndex)
    end
  end
end

-- @doc Debug commands to set passenger location
function ContractorMod:debugCommands(actionName, keyStatus)
	if ContractorMod.debug then print("ContractorMod:debugCommands") end
  if ContractorMod.debug then print("actionName "..tostring(actionName)) end
  local x1, y1, z1 = getTranslation(g_currentMission.controlledVehicle.passengers[1].characterNode)
  if string.sub(actionName, 1, 30) == "ContractorMod_DEBUG_MOVE_PASS_" then
    if actionName == "ContractorMod_DEBUG_MOVE_PASS_LEFT" then
      -- print("+x")
      x1 = x1 + 0.05
    elseif actionName == "ContractorMod_DEBUG_MOVE_PASS_RIGHT" then
      -- print("-x")
      x1 = x1 - 0.05
    elseif actionName == "ContractorMod_DEBUG_MOVE_PASS_TOP" then
      -- print("+z")
      z1 = z1 + 0.05
    elseif actionName == "ContractorMod_DEBUG_MOVE_PASS_BOTTOM" then
      -- print("-z")
      z1 = z1 - 0.05
    elseif actionName == "ContractorMod_DEBUG_MOVE_PASS_FRONT" then
      -- print("+y")
      y1 = y1 + 0.05
    elseif actionName == "ContractorMod_DEBUG_MOVE_PASS_BACK" then
      -- print("-y")
      y1 = y1 - 0.05
    end
    setTranslation(g_currentMission.controlledVehicle.passengers[1].characterNode, x1, y1, z1)
    print("x1: "..tostring(x1).." y1: "..tostring(y1).." z1: "..tostring(z1))
    DebugUtil.drawDebugReferenceAxisFromNode(g_currentMission.controlledVehicle.passengers[1].characterNode)
  end
  if actionName == "ContractorMod_DEBUG_DUMP_PASS" then
    print("passenger location")
    local configFileName = g_currentMission.controlledVehicle.configFileName
    print("<Passenger vehiclesName=\""..configFileName.."\" seatIndex=\"1\" x=\""..string.format("%2.4f", x1).."\" y=\""..string.format("%2.4f", y1).."\" z=\""..string.format("%2.4f", z1).."\" rx=\"0\" ry=\"0\" rz=\"0\" />")
  end
end

-- @doc Load ContractorMod parameters from savegame
function ContractorMod:initFromSave()
  if ContractorMod.debug then print("ContractorMod:initFromSave") end
  if g_currentMission ~= nil and g_currentMission:getIsServer() then
    -- Copy ContractorMod.xml from zip to modSettings dir
    ContractorMod:CopyContractorModXML()
    if self.savegameFolderPath and self.ContractorModXmlFilePath then
      createFolder(self.savegameFolderPath);
      local xmlFile;
      if fileExists(self.ContractorModXmlFilePath) then
        xmlFile = XMLFile.load('ContractorMod', self.ContractorModXmlFilePath);
      else
        xmlFile = XMLFile.create('ContractorMod', self.ContractorModXmlFilePath, 'ContractorMod');
        xmlFile:save()
        xmlFile:delete();
        return false;
      end;

      if xmlFile ~= nil then
        local xmlKey = "ContractorMod.workers"
        local numWorkers = 0
        numWorkers = xmlFile:getInt(xmlKey .. string.format("#numWorkers"));
        if numWorkers ~= nil then
          --print("numWorkers " .. tostring(numWorkers))
          for i = 1, numWorkers do
            local key = xmlKey .. string.format(".worker(%d)", i - 1)
            local workerName = xmlFile:getString(key.."#name");
            
            if ContractorMod.debug then print(workerName) end
            local workerStyle = PlayerStyle.new()
            workerStyle:loadFromXMLFile(xmlFile, key .. ".style")
            local playerColorIndex = xmlFile:getInt(key .. string.format("#playerColorIndex"));
            if playerColorIndex == nil then
              playerColorIndex = 0
            end
            workerStyle.playerColorIndex = playerColorIndex
            local worker = ContractorModWorker:new(workerName, i, workerStyle)
            if ContractorMod.debug then print(xmlFile:getString(key.."#position")) end
            local x, y, z = string.getVector(xmlFile:getString(key.."#position"));
            if ContractorMod.debug then print("x "..tostring(x)) end
            local xRot, yRot, zRot = string.getVector(xmlFile:getString(key.."#rotation"));
            if x ~= nil and y ~= nil and z ~= nil and xRot ~= nil and yRot ~= nil and zRot ~= nil then
              worker.x = x
              worker.y = y
              worker.z = z
              worker.dx = xRot
              worker.dy = yRot
              worker.rotY = yRot
              worker.dz = zRot
              local vehicleID = xmlFile:getString(key.."#vehicleID");
              if vehicleID ~= "0" then
                if ContractorMod.mapVehicleLoad ~= nil then
                  -- map savegame vehicle id and network id
                  local saveId = ContractorMod.mapVehicleLoad[vehicleID]
                  local vehicle = NetworkUtil.getObject(tonumber(saveId))
                  if vehicle ~= nil then
                    if ContractorMod.debug then print("ContractorMod: vehicle not nil") end
                    worker.currentVehicle = vehicle
                    local currentSeat = xmlFile:getInt(key.."#currentSeat");
                    if currentSeat ~= nil then
                      worker.currentSeat = currentSeat
                    end
                  end
                end
              end
            end;
            table.insert(self.workers, worker)
            -- Display visual drivers when loading savegame
            -- Done here since we don't know which of the drivers entering during initialization
            if worker.currentVehicle ~= nil and worker.currentSeat ~= nil then
              ContractorMod:placeVisualWorkerInVehicle(worker, worker.currentVehicle, worker.currentSeat)
            end
          end
          local enableSeveralDrivers = xmlFile:getBool(xmlKey .. string.format("#enableSeveralDrivers"));
          if enableSeveralDrivers ~= nil then
            self.enableSeveralDrivers = enableSeveralDrivers
          else
            self.enableSeveralDrivers = false
          end
          xmlKey = "ContractorMod.displaySettings.characterName"
          self.displaySettings = {}
          self.displaySettings.characterName = {}
          local x = xmlFile:getFloat(xmlKey .. string.format("#x"));
          if x == nil then
            x = 0.9828
          end
          self.displaySettings.characterName.x = x
          local y = xmlFile:getFloat(xmlKey .. string.format("#y"));
          if y == nil then
            y = 0.90
          end
          self.displaySettings.characterName.y = y
          local size = xmlFile:getFloat(xmlKey .. string.format("#size"));
          if size == nil then
            size = 0.024
          end
          self.displaySettings.characterName.size = size
          xmlKey = "ContractorMod.displaySettings.playerName"
          ContractorMod.displayPlayerNames = Utils.getNoNil(xmlFile:getBool(xmlKey .. string.format("#displayPlayerNames")), true);
        end
        self.numWorkers = numWorkers
        return true
      end
    end
  end
end

-- @doc Load ContractorMod parameters from default parameters (for new game)
function ContractorMod:initFromParam()
  if ContractorMod.debug then print("ContractorMod:initFromParam") end
  if g_currentMission ~= nil and g_currentMission:getIsServer() then
    -- Copy ContractorMod.xml from zip to modSettings dir
    ContractorMod:CopyContractorModXML()
    if ContractorMod.myCurrentModDirectory then
      local xmlFilePath = ContractorMod.myCurrentModDirectory .. "../../modSettings/ContractorMod.xml"
      local xmlFile;
      if fileExists(xmlFilePath) then
        xmlFile = XMLFile.load('ContractorMod', xmlFilePath);
      else
        return false;
      end;

      if xmlFile ~= nil then
        local xmlKey = "ContractorMod.workers"
        local numWorkers = 0
        numWorkers = xmlFile:getInt(xmlKey .. string.format("#numWorkers"));
        if numWorkers ~= nil then
          if ContractorMod.debug then print("ContractorMod: numWorkers " .. tostring(numWorkers)) end
          for i = 1, numWorkers do
            local key = xmlKey .. string.format(".worker(%d)", i - 1)
            local workerName = xmlFile:getString(key.."#name");
            if ContractorMod.debug then print(workerName) end
            local workerStyle = PlayerStyle.new()
            if i < 2 then
              -- First character get configured style and name for new game
              workerStyle = g_currentMission.player:getStyle()
              workerName = g_currentMission.playerNickname
            else
              workerStyle:loadFromXMLFile(xmlFile, key .. ".style")
            end
            local playerColorIndex = xmlFile:getInt(key .. string.format("#playerColorIndex"));
            if playerColorIndex == nil then
              playerColorIndex = 0
            end
            workerStyle.playerColorIndex = playerColorIndex
            if ContractorMod.debug then print(workerName) end
            local farmId = 1
            local worker = ContractorModWorker:new(workerName, i, workerStyle)
            if ContractorMod.debug then print(xmlFile:getString(key.."#position")) end
            local x, y, z = string.getVector(xmlFile:getString(key.."#position"));
            if ContractorMod.debug then print("x "..tostring(x)) end
            local xRot, yRot, zRot = string.getVector(xmlFile:getString(key.."#rotation"));
            if x ~= nil and y ~= nil and z ~= nil and xRot ~= nil and yRot ~= nil and zRot ~= nil then
              worker.x = x
              worker.y = y
              worker.z = z
              worker.dx = xRot
              worker.dy = yRot
              worker.dz = zRot
            end;
            table.insert(self.workers, worker)
          end
          local enableSeveralDrivers = xmlFile:getBool(xmlKey .. string.format("#enableSeveralDrivers"));
          if enableSeveralDrivers ~= nil then
            self.enableSeveralDrivers = enableSeveralDrivers
          else
            self.enableSeveralDrivers = false
          end
          xmlKey = "ContractorMod.displaySettings.characterName"
          self.displaySettings = {}
          self.displaySettings.characterName = {}
          local x = xmlFile:getFloat(xmlKey .. string.format("#x"));
          if x == nil then
            x = 0.9828
          end
          self.displaySettings.characterName.x = x
          local y = xmlFile:getFloat(xmlKey .. string.format("#y"));
          if y == nil then
            y = 0.90
          end
          self.displaySettings.characterName.y = y
          local size = xmlFile:getFloat(xmlKey .. string.format("#size"));
          if size == nil then
            size = 0.024
          end
          self.displaySettings.characterName.size = size
          xmlKey = "ContractorMod.displaySettings.playerName"
          ContractorMod.displayPlayerNames = Utils.getNoNil(xmlFile:getBool(xmlKey .. string.format("#displayPlayerNames")), true);
        end
        self.numWorkers = numWorkers
        return true
      end
    end
  end
end

-- @doc Copy default parameters from mod mod zip file to mods directory so end-user can edit it
function ContractorMod:CopyContractorModXML()
  if ContractorMod.debug then print("ContractorMod:CopyContractorModXML") end
  if g_currentMission ~= nil and g_currentMission:getIsServer() then
    if ContractorMod.myCurrentModDirectory then
      local modSettingsDir = ContractorMod.myCurrentModDirectory .. "../../modSettings"
      local xmlFilePath = modSettingsDir.."/ContractorMod.xml"
      if ContractorMod.debug then print("ContractorMod:CopyContractorModXML_1") end
      local xmlFile;
      if not fileExists(xmlFilePath) then
        if ContractorMod.debug then print("ContractorMod:CopyContractorModXML_2") end
        local xmlSourceFilePath = ContractorMod.myCurrentModDirectory .. "ContractorMod.xml"
        local xmlSourceFile;
        if fileExists(xmlSourceFilePath) then
          if ContractorMod.debug then print("ContractorMod:CopyContractorModXML_3") end
          xmlSourceFile = loadXMLFile('ContractorMod', xmlSourceFilePath);
          createFolder(modSettingsDir)
          saveXMLFileTo(xmlSourceFile, xmlFilePath);
          if ContractorMod.debug then print("ContractorMod:CopyContractorModXML_4") end
        end
      end;
    end
  end
end

-- @doc Remove characters (driver & passengers) from vehicle when sold or when exiting game
function ContractorMod:ManageSoldVehicle(vehicle, callDelete)
  local vehicleName = ""
  if vehicle ~= nil then
    if vehicle.name ~= nil then
      vehicleName = vehicle.name
    end
  end
  if ContractorMod.debug then print("ContractorMod:ManageSoldVehicle " .. vehicleName) end
  if self.workers ~= nil then
    if #self.workers > 0 then
      for i = 1, self.numWorkers do
        local worker = self.workers[i]
        if worker.currentVehicle == vehicle then
          if ContractorMod.debug then print("ContractorMod: This worker was in a vehicle that has been removed : " .. worker.name) end
          if callDelete == nil then
            worker.x, worker.y, worker.z = getWorldTranslation(worker.currentVehicle.rootNode);
            if worker.y ~= nil then
              worker.y = worker.y + 2 --to avoid being under the ground
            end
            worker.dx, worker.dy, worker.dz = localDirectionToWorld(worker.currentVehicle.rootNode, 0, 0, 1);
          end
          -- Remove passengers
          for p = 1, #worker.currentVehicle.passengers do
            if worker.currentVehicle.passengers[p] ~= nil then
              worker.currentVehicle.passengers[p]:delete()
            end
          end
          worker.currentVehicle = nil
          -- Remove mapHotSpot
          -- g_currentMission:removeMapHotspot(worker.mapHotSpot)
          -- worker.mapHotSpot:delete()
          -- worker.mapHotSpot = nil
          --break
        end
      end
    end
  end
end
function ContractorMod:removeVehicle(vehicle, callDelete)
  -- callDelete is always nil now
  ContractorMod:ManageSoldVehicle(vehicle, callDelete)
end
BaseMission.removeVehicle = Utils.prependedFunction(BaseMission.removeVehicle, ContractorMod.removeVehicle);

-- @doc Load VehicleCharacter for a passenger and put it at the given location
function ContractorMod.addPassenger(vehicle, x, y, z, rx, ry, rz)
    if ContractorMod.debug then print("ContractorMod.addPassenger") end
        local id = loadI3DFile(ContractorMod.myCurrentModDirectory.."passenger.i3d", false, false, false)
        local passengerNode = getChildAt(id, 0)
        link(vehicle.components[1].node, passengerNode)
        local ChildIndex = getChildIndex(passengerNode)
        setTranslation(passengerNode, x, y, z)
        setRotation(passengerNode, rx, ry, rz)
        
        local xmltext = " \z
        <vehicle> \z
        <enterable> \z
        <characterNode node=\"0>"..ChildIndex.."\" cameraMinDistance=\"1.5\" spineRotation=\"-90 0 90\" > \z
            <target ikChain=\"rightFoot\" targetNode=\"0>"..ChildIndex.."|1\" /> \z
            <target ikChain=\"leftFoot\"  targetNode=\"0>"..ChildIndex.."|2\" /> \z
            <target ikChain=\"rightArm\"  targetNode=\"0>"..ChildIndex.."|3\" poseId=\"wideFingers\"/> \z
            <target ikChain=\"leftArm\"   targetNode=\"0>"..ChildIndex.."|4\" poseId=\"wideFingers\"/> \z
        </characterNode></enterable></vehicle> \z
        "
        local xmlFile = loadXMLFileFromMemory("passengerConfig", xmltext)
        local passengerXMLFile = XMLFile.new("passengerXMLFile", "", xmlFile, Vehicle.xmlSchema)
        local passenger = VehicleCharacter.new(vehicle)
        passenger:load(passengerXMLFile, "vehicle.enterable.characterNode")

        --[[ Trying to add camera like passenger
        local cameraId = loadI3DFile(ContractorMod.myCurrentModDirectory.."camera.i3d", false, false, false)
        local cameraNode = getChildAt(cameraId, 0)
        link(vehicle.components[1].node, cameraNode)
        local cameraChildIndex = getChildIndex(cameraNode)
        setTranslation(cameraNode, x, y, z)
        setRotation(cameraNode, rx, ry, rz)
print("child "..cameraChildIndex)
        print("Passenger: x:"..tostring(x).." y:"..tostring(y).." z:"..tostring(z))
        local xmlCameraText = " \z
        <vehicle> \z
        <cameras count=\"1\"> \z
            <camera1 index=\"0>"..cameraChildIndex.."\" rotatable=\"true\" limit=\"true\" rotMinX=\"-1.1\" rotMaxX=\"0.4\" transMin=\"0\" transMax=\"0\" useMirror=\"true\" isInside=\"true\" /> \z
        </cameras></vehicle> \z
        "
        local xmlCameraFile = loadXMLFileFromMemory("passengerCameraConfig", xmlCameraText)
        local camera = VehicleCamera.new(vehicle)
        camera:loadFromXML(xmlCameraFile, "vehicle.cameras")]]
        -- get vehicleCharacter position (from xml ?)
        -- local characterNode = vehicle.vehicleCharacter.nodeId
        -- print(tostring(characterNode))
        -- local x1, y2, z1 = getTranslation(characterNode)
        -- print("x1:"..tostring(x1).." y1:"..tostring(y1).." z1:"..tostring(z1))
        -- compute transform
        -- local transformCam = localToLocal(passengerNode, characterNode)
        -- print(tostring(transformCam))
        -- add new camera

        return passenger
end

-- @doc Called when loading a vehicle (load game or buy new vehicle) to retrieve and add passengers info
function ContractorMod:ManageNewVehicle(vehicle)
    if ContractorMod.debug then print("ContractorMod.ManageNewVehicle") end

    if SpecializationUtil.hasSpecialization(Enterable, vehicle.specializations) then
      vehicle.passengers = {}
      local foundConfig = false
      -- Don't display warning by default in log, only if displayWarning = true
      local xmlPath = "ContractorMod.passengerSeats"
      local modDirectoryXMLFilePath = ContractorMod.myCurrentModDirectory .. "../../modSettings/ContractorMod.xml"
      local displayWarning = false
      if fileExists(modDirectoryXMLFilePath) then
        local xmlFile = loadXMLFile('ContractorMod', modDirectoryXMLFilePath);
        displayWarning = Utils.getNoNil(getXMLBool(xmlFile, xmlPath.."#displayWarning"), false);
      end
      -- xml file in zip containing mainly base game vehicles
      foundConfig = ContractorMod:loadPassengersFromXML(vehicle, ContractorMod.myCurrentModDirectory.."passengerseats.xml");
      if foundConfig == false then
        -- Try xml file in mods dir containing user mods
        foundConfig = ContractorMod:loadPassengersFromXML(vehicle, modDirectoryXMLFilePath);
        if foundConfig == false and ContractorMod.UniversalPassenger then
          -- Try xml file from UniversalPassenger
          local UniversalPassengerXML = ContractorMod.UniversalPassenger.modDir .. "xml/BaseVehicles.xml"
          foundConfig = ContractorMod:loadPassengersFromUniversalPassengerXML(vehicle, UniversalPassengerXML);
          if foundConfig == false and ContractorMod.UniversalPassenger_VehiclesOfModHub then
            UniversalPassengerXML = ContractorMod.UniversalPassenger_VehiclesOfModHub.modDir .. "xml/VehiclesOfModHub.xml"
            -- Try xml file from UniversalPassenger
            foundConfig = ContractorMod:loadPassengersFromUniversalPassengerXML(vehicle, UniversalPassengerXML);
          end
        end
      end
      if foundConfig == false and displayWarning == true then
        print("[ContractorMod]No passenger seat configured for vehicle "..vehicle.configFileName)
        print("[ContractorMod]Please edit modSettings/ContractorMod.xml to set passenger position")
      end
    end
end
BaseMission.addVehicle = Utils.appendedFunction(BaseMission.addVehicle, ContractorMod.ManageNewVehicle);

-- @doc Define empty passenger for special vehicles like trains, crane
function ContractorMod:manageSpecialVehicles()
  if ContractorMod.debug then print("ContractorMod:manageSpecialVehicles") end
  for k, v in pairs(g_currentMission.nodeToObject) do
    if v ~= nil then
      --DebugUtil.printTableRecursively(v, " ", 1, 2);
      local loco = v.typeName
      if loco ~= nil and loco == "locomotive" then
        -- no passengers for train
        v.passengers = {}
      else
        -- @FS19: to identify crane if any
        if v.stationCraneId ~= nil then
          -- no passengers for Station Crane
          v.passengers = {}
        end
      end
    end
  end
end

-- @doc Retrieve passengers info from xml files for standard and mods enterable vehicles
function ContractorMod:loadPassengersFromXML(vehicle, xmlFilePath)
  if ContractorMod.debug then print("ContractorMod:loadPassengersFromXML") end
  local foundConfig = false
  if fileExists(xmlFilePath) then 
    local xmlFile = loadXMLFile('ContractorMod', xmlFilePath);
    local i = 0
    local xmlVehicleName = ''
    while hasXMLProperty(xmlFile, "ContractorMod.passengerSeats"..string.format(".Passenger(%d)", i)) do
        xmlPath = "ContractorMod.passengerSeats"..string.format(".Passenger(%d)", i)
        xmlVehicleName = getXMLString(xmlFile, xmlPath.."#vehiclesName")
        --> ==Manage DLC & mods thanks to dural==
        --replace $pdlcdir by the full path
        if string.sub(xmlVehicleName, 1, 8):lower() == "$pdlcdir" then
          --xmlVehicleName = getUserProfileAppPath() .. "pdlc/" .. string.sub(xmlVehicleName, 10)
          --required for steam users
          xmlVehicleName = NetworkUtil.convertFromNetworkFilename(xmlVehicleName)
        elseif string.sub(xmlVehicleName, 1, 7):lower() == "$moddir" then --20171116 - fix for Horsch CTF vehicle pack
          xmlVehicleName = NetworkUtil.convertFromNetworkFilename(xmlVehicleName)
        end
        -- if ContractorMod.debug then print("Trying to add passenger to "..xmlVehicleName) end
        --< ======================================
        -- if ContractorMod.debug then print("Compare to vehicle config  "..vehicle.configFileName) end
        if vehicle.configFileName == xmlVehicleName then
          foundConfig = true
          local seatIndex = getXMLInt(xmlFile, xmlPath.."#seatIndex")
          local x = getXMLFloat(xmlFile, xmlPath.."#x")
          local y = getXMLFloat(xmlFile, xmlPath.."#y")
          local z = getXMLFloat(xmlFile, xmlPath.."#z")
          local rx = getXMLFloat(xmlFile, xmlPath.."#rx")
          local ry = getXMLFloat(xmlFile, xmlPath.."#ry")
          local rz = getXMLFloat(xmlFile, xmlPath.."#rz")
          if seatIndex == 1 and x == 0.0 and y == 0.0 and z == 0.0 then
            print("[ContractorMod]Passenger seat not configured yet for vehicle "..xmlVehicleName)
            local characterNode = vehicle.spec_enterable.defaultCharacterNode
            -- print("Driver position node is: "..tostring(characterNode))
            -- local x1, y1, z1 = getTranslation(characterNode)
            -- print("x1: "..tostring(x1).." y1: "..tostring(y1).." z1: "..tostring(z1))
            local dx,dy,dz = localToLocal(vehicle.rootNode, characterNode, 0,0,0);
            -- print("x=\""..tostring(dx).."\" y=\""..tostring(dy).."\" z=\""..tostring(dz))
            if ContractorMod.useDebugCommands then
              x = -dx
              y = -dy
              z = -dz
              seatIndex = 1
            end
          end
          if seatIndex > 0 then
            if ContractorMod.debug then print('Adding seat '..tostring(seatIndex)..' for '..xmlVehicleName) end
            vehicle.passengers[seatIndex] = ContractorMod.addPassenger(vehicle, x, y, z, rx, ry, rz)
          end
        end
        i = i + 1
    end
  end
  return foundConfig
end

-- @doc Load and display characters in vehicle for drivers & passengers instead of default methods
function ContractorMod:placeVisualWorkerInVehicle(worker, vehicle, seat)
  if ContractorMod.debug then print("ContractorMod:placeVisualWorkerInVehicle") end
  if vehicle.spec_enterable.vehicleCharacter == nil and ContractorMod.debug then print("ContractorMod: vehicle.spec_enterable.vehicleCharacter == nil" ) end          
  if vehicle.passengers == nil then print("ContractorMod: vehicle.passengers == nil" ) end          

  -- if ContractorMod.debug then print("ContractorMod: playerStyle "..tostring(worker.playerStyle.selectedColorIndex)) end

  local character = vehicle:getVehicleCharacter()
  if seat == 0 and character ~= nil then
    -- Driver
    if ContractorMod.debug then print("ContractorMod: setVehicleCharacter as driver") end
    character = vehicle:setVehicleCharacter(worker.playerStyle)
  else
    -- Passenger
    if vehicle.passengers ~= nil then
      if vehicle.passengers[seat] ~= nil then
        if ContractorMod.debug then print("ContractorMod: setVehicleCharacter as passenger") end
        vehicle.passengers[seat]:loadCharacter(worker.playerStyle, vehicle, ContractorMod.vehicleCharacterLoaded, seat)
      end
    end
  end
end

function ContractorMod:vehicleCharacterLoaded(success, seat)
  if ContractorMod.debug then print("ContractorMod:vehicleCharacterLoaded "..tostring(success)) end
  -- printCallstack()
  if success and seat then
		self.passengers[seat]:updateVisibility()
		self.passengers[seat]:updateIKChains()
	end

	-- SpecializationUtil.raiseEvent(self, "onVehicleCharacterChanged", self.passengers[seat])
	-- g_messageCenter:subscribe(MessageType.PLAYER_STYLE_CHANGED, self.onPlayerStyleChanged, self)
end

-- @doc Decide to load driver or passenger character when entering a vehicle
function ContractorMod:ReplaceEnterVehicle(superFunc, isControlling, playerStyle, farmId)
  if ContractorMod.debug then print("ContractorMod:ReplaceEnterVehicle") end

  -- @FS19
    -- local tmpXmlFilename = PlayerUtil.playerIndexToDesc[playerIndex].xmlFilename
    -- PlayerUtil.playerIndexToDesc[playerIndex].xmlFilename = ContractorMod.workers[ContractorMod.currentID].xmlFile
      local tmpXmlFilename = g_currentMission.player.xmlFilename
      g_currentMission.player.xmlFilename = ContractorMod.workers[ContractorMod.currentID].xmlFile
      -- Find free passengerSeat.
      -- 0 is drivers seat
      local seat
      local firstFreepassengerSeat = -1 -- no seat assigned. nil: not in vehicle.
      local nbSeats = 0
      if self.passengers ~= nil then
        nbSeats = #self.passengers
        -- print("nbSeats "..tostring(nbSeats))
      end
      for seat = 0, nbSeats do
        local seatUsed = false
        if ContractorMod.debug then print("loop on workers") end
        for i = 1, ContractorMod.numWorkers do
          local worker = ContractorMod.workers[i]
          if ContractorMod.debug then print(worker.name) end
            if ContractorMod.debug then print("currentSeat "..tostring(worker.currentSeat)) end
              if ContractorMod.debug then print("seat        "..tostring(seat)) end
          if worker.currentVehicle ~= nil then
            if ContractorMod.debug then print("currentVehicle "..worker.currentVehicle:getFullName()) end
          end
          if self ~= nil then
            if ContractorMod.debug then print("self           "..self:getFullName()) end
          end
          if worker.currentSeat == seat and worker.currentVehicle == self then
            seatUsed = true
            break
          end
        end
        if seatUsed == false and ( self.passengers[1] ~= nil or seat == 0 ) then
          firstFreepassengerSeat = seat
          for i = 1, ContractorMod.numWorkers do
            local worker = ContractorMod.workers[i]
            if seat == 0 and worker.currentVehicle == self then
              --Check if character is not already passenger
              if worker.currentSeat > 0 and ContractorMod.switching then
                --set him as driver instead since no driver in the vehicle (only when switching, not when entering the vehicle again)
                self.passengers[worker.currentSeat]:delete()
                worker.currentSeat = 0
                break
              end
            end
          end
          if ContractorMod.debug then print("firstFreepassengerSeat "..tostring(firstFreepassengerSeat)) end
          break
        end
      end

      if self.typeName == "horse" then
        if ContractorMod.debug then print("ContractorMod: horse: "..self:getFullName()) end
        superFunc(self, isControlling, ContractorMod.workers[ContractorMod.currentID].playerStyle, farmId)
        return
      end
      if firstFreepassengerSeat > 0 then
        if ContractorMod.debug then print("passenger entering "..tostring(firstFreepassengerSeat)) end
        -- We should set true if no more driver but passenger still in the vehicle
        ContractorMod.passengerEntering = true
        if ContractorMod.debug then print("ContractorMod.passengerEntering "..tostring(ContractorMod.passengerEntering)) end
      end
      -- local tmpVehicleCharacter = self.spec_enterable.vehicleCharacter
      local tmpPlayerStyle = self.spec_enterable.playerStyle
      self.spec_enterable.playerStyle = nil
      local tmpFarmId = self.farmId
      -- self.spec_enterable.vehicleCharacter = nil -- Keep it from beeing modified
      superFunc(self, isControlling, ContractorMod.workers[ContractorMod.currentID].playerStyle, farmId)
      -- self.spec_enterable.vehicleCharacter = tmpVehicleCharacter
      self.spec_enterable.playerStyle = tmpPlayerStyle
      self.farmId = tmpFarmId

      -- When Initializing we are called when ContractorMod.currentID is not set.
      -- When switching vehicle we are called for drivers already entered but then currentSeat ~= nil.
      if ContractorMod.workers[ContractorMod.currentID].currentSeat == nil and not ContractorMod.initializing  then 
        ContractorMod.workers[ContractorMod.currentID].currentSeat = firstFreepassengerSeat
        ContractorMod:placeVisualWorkerInVehicle(ContractorMod.workers[ContractorMod.currentID], self, firstFreepassengerSeat)
        --if firstFreepassengerSeat > 0 and ContractorMod.workers[ContractorMod.currentID].currentSeat == nil and not ContractorMod.initializing then
        if firstFreepassengerSeat > 0 then
          if ContractorMod.debug then print("passenger entering") end
            ContractorMod.workers[ContractorMod.currentID].isNewPassenger = true
          -- TODO: Test somewhere if current worker is passenger/driver => update camera position
          -- get playerRoot vehicle
          -- compute seat - playerRoot transfo
          -- apply transfo to inside camera
          if ContractorMod.debug then print("Passenger should not be able to drive") end
        end
      end
  -- @FS19
    -- PlayerUtil.playerIndexToDesc[playerIndex].xmlFilename = tmpXmlFilename
    g_currentMission.player.xmlFilename = tmpXmlFilename
    ContractorMod.passengerEntering = false
end
Enterable.enterVehicle = Utils.overwrittenFunction(Enterable.enterVehicle, ContractorMod.ReplaceEnterVehicle)

-- Manage wardrobe change when character is in a vehicle
function ContractorMod:ReplaceOnPlayerStyleChanged(superFunc, style, userId)
  if ContractorMod.debug then print("ContractorMod:ReplaceOnPlayerStyleChanged "..userId) end
  -- printCallstack()
  local worker = ContractorMod.workers[ContractorMod.currentID]
  worker.playerStyle:copyFrom(style)
  if worker.currentVehicle ~= nil and worker.currentSeat ~= nil then
    ContractorMod:placeVisualWorkerInVehicle(worker, worker.currentVehicle, worker.currentSeat)
  end
  -- superFunc(style, userId)
end
Enterable.onPlayerStyleChanged = Utils.overwrittenFunction(Enterable.onPlayerStyleChanged, ContractorMod.ReplaceOnPlayerStyleChanged)

-- Display character name in wardrobe screen
function ContractorMod:beforeOnOpenWardrobeScreen()
  if ContractorMod.debug then print("ContractorMod:beforeOnOpenWardrobeScreen ") end

  --print("player"..tostring(g_currentMission.player))
  --print("model "..tostring(g_currentMission.player.model))
  --print("style "..tostring(g_currentMission.player.model.style))
  --DebugUtil.printTableRecursively(g_currentMission.player.model, " ", 1, 2)
  g_currentMission.player.model.style:copyFrom(ContractorMod.workers[ContractorMod.currentID].playerStyle)
  g_currentMission.playerNickname = ContractorMod.workers[ContractorMod.currentID].name
end
ShopOthersFrame.onOpenWardrobeScreen = Utils.prependedFunction(ShopOthersFrame.onOpenWardrobeScreen, ContractorMod.beforeOnOpenWardrobeScreen)

-- Update character when opening wardrobe screen
function ContractorMod:appOnOpenWardrobeScreen()
  if ContractorMod.debug then print("ContractorMod:appOnOpenWardrobeScreen ") end
  g_wardrobeScreen.temporaryPlayerStyle:copyFrom(ContractorMod.workers[ContractorMod.currentID].playerStyle)
  g_wardrobeScreen:updateCharacter()
end
ShopOthersFrame.onOpenWardrobeScreen = Utils.appendedFunction(ShopOthersFrame.onOpenWardrobeScreen, ContractorMod.appOnOpenWardrobeScreen)

-- Change character name from wardrobe screen player nickname
function ContractorMod:setPlayerNickname(player, nickname, userId, noEventSend)
  if ContractorMod.debug then print("ContractorMod:setPlayerNickname "..tostring(nickname)) end
  if ContractorMod.workers then
    ContractorMod.workers[ContractorMod.currentID].name = nickname
  end
end
FSBaseMission.setPlayerNickname = Utils.prependedFunction(FSBaseMission.setPlayerNickname, ContractorMod.setPlayerNickname)
-- @doc Prevent to replace driver character when activating a worker
function ContractorMod:ReplaceSetRandomVehicleCharacter()
  if ContractorMod.debug then print("ContractorMod:ReplaceSetRandomVehicleCharacter") end
end
Enterable.setRandomVehicleCharacter = Utils.overwrittenFunction(Enterable.setRandomVehicleCharacter, ContractorMod.ReplaceSetRandomVehicleCharacter)

-- @doc Prevent to replace driver character when stopping a worker
function ContractorMod:ReplaceRestoreVehicleCharacter()
  if ContractorMod.debug then print("ContractorMod:ReplaceRestoreVehicleCharacter") end
end
Enterable.restoreVehicleCharacter = Utils.overwrittenFunction(Enterable.restoreVehicleCharacter, ContractorMod.ReplaceRestoreVehicleCharacter)

-- @doc Prevent to replace driver character when entering as passenger
function ContractorMod:ReplaceSetVehicleCharacter(superFunc, playerStyle)
  if ContractorMod.debug then print("ContractorMod:ReplaceSetVehicleCharacter") end
  if not ContractorMod.passengerEntering then
    if ContractorMod.debug then print("ContractorMod: not passengerEntering") end
    if playerStyle == nil then
      print("ContractorMod: playerStyle is nil")
      playerStyle = g_currentMission.player:getStyle()
    end
    superFunc(self, playerStyle)
  end
  if ContractorMod.debug then print("ContractorMod: passengerEntering return") end
  ContractorMod.passengerEntering = false
end
Enterable.setVehicleCharacter = Utils.overwrittenFunction(Enterable.setVehicleCharacter, ContractorMod.ReplaceSetVehicleCharacter)

-- @doc Prevent error with FS19_Inspector
function ContractorMod:ReplaceGetControllerName(superFunc)
  if ContractorMod.debug then print("ContractorMod:ReplaceGetControllerName") end
  if self.spec_enterable.playerStyle ~= nil then
    return superFunc(self)
  end
  if #ContractorMod.workers > 0 then
    return ContractorMod.workers[ContractorMod.currentID].name
  end
  return "NO PLAYER NAME"
end
Enterable.getControllerName = Utils.overwrittenFunction(Enterable.getControllerName, ContractorMod.ReplaceGetControllerName)

-- Enterable:enter()        => loadCharacter if isHired == false
-- Enterable:leaveVehicle() => deleteCharacter if disableCharacterOnLeave == true
function ContractorMod:ManageBeforeEnterVehicle(vehicle, playerStyle)
  local vehicleName = ""
  if vehicle ~= nil then
    if vehicle.name ~= nil then
      vehicleName = vehicle.name
    end
  end
  if ContractorMod.debug then print("ContractorMod:prependedEnterVehicle >>" .. vehicleName) end
  -- if ContractorMod.debug then DebugUtil.printTableRecursively(vehicle, " ", 1, 1) end
  
  local doExit = false
  if self.workers ~= nil then
    if #self.workers > 0 and not self.initializing and not self.enableSeveralDrivers then
      for i = 1, self.numWorkers do
        local worker = self.workers[i]
        if worker.currentVehicle == vehicle then
          if worker.name ~= self.workers[self.currentID].name then
            if ContractorMod.debug then print("ContractorMod: "..worker.name .. " already in ") end
            if worker.isPassenger == false then
              if ContractorMod.debug then print("as driver") end
              doExit = true
            else
              if ContractorMod.debug then print("as passenger") end
              doExit = false
            end
          else
            doExit = false
          end
        end
      end
    end
  end
  if doExit then
    if ContractorMod.debug then print("ContractorMod: Player will leave before enter" ) end
    g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, g_i18n:getText("ContractorMod_VEHICLE_NOT_FREE"))
    if vehicle.spec_enterable.vehicleCharacter ~= nil then
      vehicle.spec_enterable.vehicleCharacter:delete();
    end
  end

  if self.switching then
    if not self.initializing then
      vehicle.isHired = true
    end
    -- Needed ??
    vehicle.currentHelper = g_helperManager:getRandomHelper()
    if ContractorMod.debug then print("ContractorMod: switching " .. tostring(vehicle.isHired)) end
  else
    vehicle.isHired = false
  end
  
  if ContractorMod.debug then print("ContractorMod: 268 " .. tostring(vehicle.isHired)) end
    -- vehicle.disableCharacterOnLeave = false;
  -- else
  vehicle.disableCharacterOnLeave = true;
  -- end
  
  if ContractorMod.debug then print("ContractorMod:prependedEnterVehicle <<" .. vehicle:getFullName()) end
  if vehicle ~= nil then
    if ContractorMod.debug then print("isHired " .. tostring(vehicle.isHired) .. " disableChar " .. tostring(vehicle.disableCharacterOnLeave) .. " steering " .. tostring(vehicle.steeringEnabled)) end
  end
end

function ContractorMod:beforeEnterVehicle(vehicle, playerStyle)
    if ContractorMod.debug then print("ContractorMod:beforeEnterVehicle " .. vehicle:getFullName()) end
  
    if ContractorMod.debug and g_currentMission.player:getStyle() and ContractorMod.workers and playerStyle then
      print("\ng_currentMission.player:getStyle()")
      -- DebugUtil.printTableRecursively(g_currentMission.player:getStyle(), " ", 1, 2)
      print("\nworker:getStyle()")
      -- DebugUtil.printTableRecursively(ContractorMod.workers[ContractorMod.currentID].playerStyle, " ", 1, 2)
      print("\nplayerStyle")
      -- DebugUtil.printTableRecursively(playerStyle, " ", 1, 2)
    end
    ContractorMod:ManageBeforeEnterVehicle(vehicle, playerStyle)
end
BaseMission.onEnterVehicle = Utils.prependedFunction(BaseMission.onEnterVehicle, ContractorMod.beforeEnterVehicle);

-- @doc Prevent from removing driver character
function ContractorMod:replaceGetDisableVehicleCharacterOnLeave(superfunc)
  if ContractorMod.debug then print("ContractorMod:replaceGetDisableVehicleCharacterOnLeave ") end
  if ContractorMod.switching then
    ContractorMod.switching = false
    if ContractorMod.debug then print("switching return false") end
    return false
  end
  if ContractorMod.passengerLeaving then
    ContractorMod.passengerLeaving = false
    if ContractorMod.debug then print("passengerLeaving return false") end
    return false
  end
  return true
end
Enterable.getDisableVehicleCharacterOnLeave = Utils.overwrittenFunction(Enterable.getDisableVehicleCharacterOnLeave, ContractorMod.replaceGetDisableVehicleCharacterOnLeave);

-- @doc Prevent to enter a vehicle when no more space
function ContractorMod:replaceVehicleEnterRequestEventRun(superfunc, connection)
  if ContractorMod.debug then print("ContractorMod:replaceVehicleEnterRequestEventRun ") end
  -- TODO: Manage forestry truck
  local canEnterWhenSwitching = false
  -- 0 is drivers seat
  local seat
  local firstFreepassengerSeat = -1 -- no seat assigned. nil: not in vehicle.
  local nbSeats = 0
  if self.object ~= nil and self.object.passengers ~= nil then
    nbSeats = #self.object.passengers
    -- print("nbSeats "..tostring(nbSeats))
  end
  for seat = 0, nbSeats do
    local seatUsed = false
    if ContractorMod.debug then print("loop on workers") end
    for i = 1, ContractorMod.numWorkers do
      local worker = ContractorMod.workers[i]
      if ContractorMod.debug then print(worker.name) end
      if ContractorMod.debug then print("currentSeat "..tostring(worker.currentSeat)) end
      if ContractorMod.debug then print("seat        "..tostring(seat)) end
      if worker.currentVehicle ~= nil then
        if ContractorMod.debug then print("currentVehicle "..worker.currentVehicle:getFullName()) end
      end
      if self.object ~= nil then
        local fullName = "nil"
        if self.object.getFullName ~= nil then
          fullName = self.object:getFullName()
        end
        if ContractorMod.debug then print("self           "..fullName) end
      end
      if worker.currentSeat == seat and worker.currentVehicle == self.object and worker == ContractorMod.workers[ContractorMod.currentID] then
        canEnterWhenSwitching = true
      end
      if worker.currentSeat == seat and worker.currentVehicle == self.object then
        seatUsed = true
        break
      end
    end
    if seatUsed == false and ( seat == 0 or self.object.passengers[1] ~= nil ) then
      firstFreepassengerSeat = seat
      break
    end
  end
  if ContractorMod.debug then print("firstFreepassengerSeat "..tostring(firstFreepassengerSeat)) end

  if not canEnterWhenSwitching then
    if firstFreepassengerSeat < 0 and not ContractorMod.initializing then
      if ContractorMod.debug then print("ContractorMod:replaceVehicleEnterRequestEventRun ") end
      g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, g_i18n:getText("ContractorMod_NO_MORE_PASSENGER"))
      return
    end
  end
  -- local enterableSpec = self.object.spec_enterable
  -- print("self.object "..tostring(self.object))
  -- DebugUtil.printTableRecursively(self.object, " ", 1, 1)
  -- print("enterableSpec "..tostring(enterableSpec))
  -- print("enterableSpec.isControlled "..tostring(enterableSpec.isControlled))
  -- print("objectId "..tostring(self.objectId))
  -- local object = NetworkUtil.getObject(self.objectId)
  -- print("object "..tostring(object))
  -- if object ~= nil then 
  --   DebugUtil.printTableRecursively(object, " ", 1, 1)
  -- end
  return superfunc(self, connection)
end
VehicleEnterRequestEvent.run = Utils.overwrittenFunction(VehicleEnterRequestEvent.run, ContractorMod.replaceVehicleEnterRequestEventRun);

-- @doc Make some checks before leaving a vehicle to manage passengers and hired worker
function ContractorMod:ManageLeaveVehicle(controlledVehicle)
  if ContractorMod.debug then print("ContractorMod:prependedLeaveVehicle >>") end
  if controlledVehicle ~= nil then
    if ContractorMod.debug then print("isHired " .. tostring(controlledVehicle.isHired) .. " disableChar " .. tostring(controlledVehicle.disableCharacterOnLeave) .. " steering " .. tostring(controlledVehicle.steeringEnabled)) end
  end

  if controlledVehicle ~= nil then
    if self.shouldStopWorker then
    
      local occupants = 0
      
      for i = 1, self.numWorkers do
        local worker = self.workers[i]
        if worker.currentVehicle == controlledVehicle then
          occupants = occupants + 1
        end
      end
      if occupants == 1 then -- Last driver leaving
        --Leaving vehicle
        if ContractorMod.debug then print("controlled vehicle " .. controlledVehicle:getFullName()) end
        if ContractorMod.debug then print("controlledVehicle.spec_enterable.isControlled " .. tostring(controlledVehicle.spec_enterable.isControlled)) end
        --if not controlledVehicle.spec_enterable.isControlled then
        if controlledVehicle:getIsAIActive() then
        --@FS19 if not controlledVehicle.steeringEnabled and controlledVehicle.stationCraneId == nil then
          --Leaving and AI activated
          g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, g_i18n:getText("ContractorMod_WORKER__STOP"))
          --Manage CoursePlay vehicles
          if controlledVehicle.cp ~= nil then
            if controlledVehicle.cp.isDriving then
             -- Try to stop the CP vehicle
              if ContractorMod.debug then print("setCourseplayFunc stop") end
              controlledVehicle:setCourseplayFunc('stop', nil, false, 1);
            else
              controlledVehicle:stopCurrentAIJob(AIMessageSuccessStoppedByUser.new())
            end
          else
            controlledVehicle:stopCurrentAIJob(AIMessageSuccessStoppedByUser.new())
          end
          --Leaving and no AI activated
          --Bear
          controlledVehicle.disableCharacterOnLeave = true;
        end
      else
        -- Drivers left
        controlledVehicle.disableCharacterOnLeave = false;
      end
      if ContractorMod.workers[ContractorMod.currentID].currentSeat == 0 then
        if ContractorMod.debug then print("ContractorMod: driver leaving") end
        if controlledVehicle:getIsAIActive() then
            --Driver Leaving and AI activated
            g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, g_i18n:getText("ContractorMod_WORKER__STOP"))
            controlledVehicle:stopCurrentAIJob(AIMessageSuccessStoppedByUser.new())
        end
        if controlledVehicle.vehicleCharacter ~= nil then
          -- to manage vehicles without character like belt system
          controlledVehicle.vehicleCharacter:delete()
        end
      else
        if controlledVehicle.passengers[ContractorMod.workers[ContractorMod.currentID].currentSeat] ~= nil then
          local passengerNode = controlledVehicle.passengers[ContractorMod.workers[ContractorMod.currentID].currentSeat].characterNode
          local xPassenger, _, _ = getTranslation(passengerNode)
          local exitPoint = controlledVehicle:getExitNode()
          local x, y, z = getTranslation(exitPoint)
          -- print(string.format("x: %3.4f, y: %3.4f, z: %3.4f", x, y, z))
          -- print(string.format("xPassenger: %3.4f", xPassenger))
          if (x - xPassenger) > x then
            -- Set exit point on the other side for vehicles where passenger is on the other side
            -- Backup exitPoint
            controlledVehicle.backupExitPoint = createTransformGroup("backupExitPoint")
            link(controlledVehicle.rootNode, controlledVehicle.backupExitPoint)
            setTranslation(controlledVehicle.backupExitPoint, x, y, z)
            setTranslation(exitPoint, -x, y, z)
            x, y, z = getWorldTranslation(exitPoint)
            -- print(string.format("x: %3.4f, y: %3.4f, z: %3.4f", x, y, z))
            x, y, z = getTranslation(controlledVehicle.backupExitPoint)
            -- print(string.format("x: %3.4f, y: %3.4f, z: %3.4f", x, y, z))
          end

          controlledVehicle.passengers[ContractorMod.workers[ContractorMod.currentID].currentSeat]:delete()
          ContractorMod.workers[ContractorMod.currentID].isNewPassenger = false
          if ContractorMod.debug then print("passenger leaving") end
          self.passengerLeaving = true
          if controlledVehicle.vehicleCharacter ~= nil then
            if controlledVehicle.isEntered then
              -- Seems new issue after patch 1.5: character not visible when exiting passenger with inCab camera
              if ContractorMod.debug then print("ContractorMod:setCharacterVisibility") end
              controlledVehicle.vehicleCharacter:setCharacterVisibility(true)
            end
          end
        end
      end
      ContractorMod.workers[ContractorMod.currentID].currentSeat = nil
    else
      --Switching
      if controlledVehicle.spec_enterable.isControlled then
      --if controlledVehicle.steeringEnabled then
        if ContractorMod.debug then print("ContractorMod: steeringEnabled TRUE") end
        --No AI activated
        --controlledVehicle.isHired = true;
        --controlledVehicle.currentHelper = g_helperManager:getRandomHelper()
        controlledVehicle.disableCharacterOnLeave = false;
        controlledVehicle.isHirableBlocked = true;
        controlledVehicle.forceIsActive = true;
        controlledVehicle.stopMotorOnLeave = false;
        if controlledVehicle.vehicleCharacter ~= nil then
          if controlledVehicle.isEntered then
            -- Seems new issue after patch 1.5: character not visible when switching with inCab camera
            if ContractorMod.debug then print("ContractorMod:setCharacterVisibility") end
            controlledVehicle.vehicleCharacter:setCharacterVisibility(true)
          end
        end
      else
        if ContractorMod.debug then print("ContractorMod: steeringEnabled FALSE") end
        controlledVehicle.isHired = true;
        controlledVehicle.currentHelper = g_helperManager:getRandomHelper()
        controlledVehicle.disableCharacterOnLeave = false;
      end
    end
    -- if self.switching then
      -- controlledVehicle.disableCharacterOnLeave = false;
    -- else
      -- controlledVehicle.disableCharacterOnLeave = true;
    -- end
    if ContractorMod.debug then print("ContractorMod:prependedLeaveVehicle <<" .. controlledVehicle:getFullName()) end
  end
  if controlledVehicle ~= nil then
    if ContractorMod.debug then print("isHired " .. tostring(controlledVehicle.isHired) .. " disableChar " .. tostring(controlledVehicle.disableCharacterOnLeave) .. " steering " .. tostring(controlledVehicle.steeringEnabled)) end
  end
end
function ContractorMod:onLeaveVehicle(superFunc, ...)
  if ContractorMod.debug then print("ContractorMod:onLeaveVehicle ") end
  local controlledVehicle = g_currentMission.controlledVehicle
  if controlledVehicle ~= nil then
    ContractorMod:ManageLeaveVehicle(controlledVehicle)
  end
  superFunc(self, ...)
  if controlledVehicle ~= nil and controlledVehicle.backupExitPoint then
    -- Restore exitPoint
    local x, y, z = getTranslation(controlledVehicle.backupExitPoint)
    local exitPoint = controlledVehicle:getExitNode()
    setTranslation(exitPoint, x, y, z)
  end
end
BaseMission.onLeaveVehicle = Utils.overwrittenFunction(BaseMission.onLeaveVehicle, ContractorMod.onLeaveVehicle);

-- @doc Set mapping between savegame vehicle id and vehicle network id when vehicle is loaded
ContractorMod.appEnterableOnLoad = function(self, savegame)
  if ContractorMod.debug then print("ContractorMod:appEnterableOnLoad ") end
  if savegame ~= nil then
    -- When loading savegame
    if ContractorMod.mapVehicleLoad == nil then
      ContractorMod.mapVehicleLoad = {}
    end
    local key = savegame.key
    -- key is something like vehicles.vehicle(saveId)
    local saveId = 1 + tonumber(string.sub(key, string.find(key, '(', 1, true) + 1, string.find(key, ')', 1, true) - 1))
    local vehicleID = self.id
    -- print("saveId "..tostring(saveId))
    -- print("vehicleID "..tostring(vehicleID).." - "..self:getFullName())
    -- Set mapping between savegame vehicle id and vehicle network id once loaded
    ContractorMod.mapVehicleLoad[tostring(saveId)] = vehicleID
    -- DebugUtil.printTableRecursively(ContractorMod.mapVehicleLoad, " ", 1, 2);
  end
end
Enterable.onLoad = Utils.appendedFunction(Enterable.onLoad, ContractorMod.appEnterableOnLoad)

-- @doc Save workers info to restore them when starting game
function ContractorMod:onSaveCareerSavegame()
  if ContractorMod.debug then print("ContractorMod:onSaveCareerSavegame ") end
  if self.workers ~= nil then
    local xmlFile;
    if fileExists(self.ContractorModXmlFilePath) then
      xmlFile = XMLFile.load('ContractorMod', self.ContractorModXmlFilePath);
    else
      xmlFile = XMLFile.create('ContractorMod', self.ContractorModXmlFilePath, 'ContractorMod');
      xmlFile:save()
    end;

    if xmlFile ~= nil then
      local rootXmlKey = "ContractorMod"

      -- update current worker position
      local currentWorker = self.workers[self.currentID]
      if currentWorker ~= nil then
        currentWorker:beforeSwitch(true)
      end
      
      local workerKey = rootXmlKey .. ".workers"
      xmlFile:setInt(workerKey.."#numWorkers", self.numWorkers);
      xmlFile:setBool(workerKey .."#enableSeveralDrivers", self.enableSeveralDrivers);
      for i = 1, self.numWorkers do
        local worker = self.workers[i]
        local key = string.format(rootXmlKey .. ".workers.worker(%d)", i - 1);
        xmlFile:setString(key.."#name", worker.name);
        worker.playerStyle:saveToXMLFile(xmlFile, key .. ".style")
        if worker.currentSeat ~= nil then
          xmlFile:setInt(key.."#currentSeat", worker.currentSeat);
        end
        local pos = worker.x..' '..worker.y..' '..worker.z
        xmlFile:setString(key.."#position", pos);
        local rot = worker.dx..' '..worker.dy..' '..worker.dz
        xmlFile:setString(key.."#rotation", rot);
        local vehicleID = "0"
        if worker.currentVehicle ~= nil then
          -- This id was not stable enough when saving
          -- vehicleID = NetworkUtil.getObjectId(worker.currentVehicle)
          vehicleID = worker.saveId
        end
        xmlFile:setString(key.."#vehicleID", vehicleID);
      end
      -- currentWorker.player:moveToAbsoluteInternal(0, -200, 0);
      local xmlKey = rootXmlKey .. ".displaySettings.characterName"
      xmlFile:setFloat(xmlKey .. "#x", self.displaySettings.characterName.x);
      xmlFile:setFloat(xmlKey .. "#y", self.displaySettings.characterName.y);
      xmlFile:setFloat(xmlKey .. "#size", self.displaySettings.characterName.size);
      xmlKey = rootXmlKey .. ".displaySettings.playerName"
      xmlFile:setBool(xmlKey .. "#displayPlayerNames", ContractorMod.displayPlayerNames);
      xmlFile:save()
      xmlFile:delete()
    end
  end
end

-- @doc Will call dedicated save method
SavegameController.onSaveComplete = Utils.prependedFunction(SavegameController.onSaveComplete, function(self)
    -- if self.isValid and self.xmlKey ~= nil then
    ContractorMod:onSaveCareerSavegame()
    -- end
end);

-- @doc store savegame vehicle id if worker is in this vehicle
function ContractorMod:mapVehicleSave(vehicle, saveId)
  if ContractorMod.debug then print("ContractorMod:mapVehicleSave ") end
  if self.workers ~= nil then
    if #self.workers > 0 then
      for i = 1, self.numWorkers do
        local worker = self.workers[i]
        if worker ~= nil and worker.currentVehicle ~= nil then
          if vehicle == worker.currentVehicle then
            -- store savegame vehicle id 
            worker.saveId = saveId
          end
        end
      end
    end
  end
end

-- @doc Set mapping between savegame vehicle id and vehicle network id when vehicle is saved
function ContractorMod:preVehicleSave(xmlFile, key, usedModNames)
  -- key is something like vehicles.vehicle(saveId)
  local saveId = 1 + tonumber(string.sub(key, string.find(key, '(', 1, true) + 1, string.find(key, ')', 1, true) - 1))
  if SpecializationUtil.hasSpecialization(Enterable, self.specializations) then
    ContractorMod:mapVehicleSave(self, tostring(saveId))
  end
end
Vehicle.saveToXMLFile = Utils.prependedFunction(Vehicle.saveToXMLFile, ContractorMod.preVehicleSave);

-- Append character name when worker is active (not really visible)
function ContractorMod:setAIHelperName(superfunc, name)
  self.name = name .. " (" .. ContractorMod.workers[ContractorMod.currentID].name .. ")"
end
AIHotspot.setAIHelperName = Utils.overwrittenFunction(AIHotspot.setAIHelperName, ContractorMod.setAIHelperName);

-- @doc Draw worker name and hotspots on map
function ContractorMod:draw()
  --if ContractorModWorker.debug then print("ContractorMod:draw()") end
  --Display current worker name
  if self.workers ~= nil then
    if #self.workers > 0 and g_currentMission.hud.isVisible then
      local currentWorker = self.workers[self.currentID]
      if currentWorker ~= nil then
        --Display current worker name
        currentWorker:displayName(self)
      end
--       for i = 1, self.numWorkers do
--         local worker = self.workers[i]
--         if worker.mapHotSpot ~= nil then
-- -- g_currentMission:removeMapHotspot(worker.mapHotSpot)
-- -- worker.mapHotSpot:delete()
--           worker.mapHotSpot = nil
--         end
--         --@FS19 Display workers on the minimap: To review marker and text size
--         local _, textSize = getNormalizedScreenValues(0, 9);
--         local _, textOffsetY = getNormalizedScreenValues(0, 24);
--         local width, height = getNormalizedScreenValues(12, 12);
--         if worker.currentVehicle == nil then
--           --worker.mapHotSpot = g_currentMission.ingameMap:createMapHotspot(tostring(worker.name), tostring(worker.name), ContractorMod.myCurrentModDirectory .. "images/worker" .. tostring(i) .. ".dds", nil, nil, worker.x, worker.z, g_currentMission.ingameMap.mapArrowWidth / 3, g_currentMission.ingameMap.mapArrowHeight / 3, false, false, false, 0);
--           worker.mapHotSpot = MapHotspot:new(tostring(worker.name), MapHotspot.CATEGORY_AI)
--           worker.mapHotSpot:setSize(width, height)
--           -- worker.mapHotSpot:setLinkedNode(0)
--           worker.mapHotSpot:setText(tostring(worker.name))
--           -- worker.mapHotSpot:setBorderedImage(nil, getNormalizedUVs({768, 768, 256, 256}), {worker.color[1], worker.color[2], worker.color[3], 1.0})
--           worker.mapHotSpot:setImage(nil, getNormalizedUVs({768, 768, 256, 256}), {worker.color[1], worker.color[2], worker.color[3], 1.0})
--           worker.mapHotSpot:setBackgroundImage(nil, getNormalizedUVs({768, 768, 256, 256}))
--           worker.mapHotSpot:setIconScale(0.7)
--           worker.mapHotSpot:setTextOptions(textSize, nil, textOffsetY, {worker.color[1], worker.color[2], worker.color[3], 1.0}, Overlay.ALIGN_VERTICAL_MIDDLE)
--           worker.mapHotSpot:setWorldPosition(worker.x, worker.z)
--           -- nil, getNormalizedUVs({768, 768, 256, 256}), {worker.color[1], worker.color[2], worker.color[3], 1.0},
--           -- worker.x, worker.z, width, height, false, false, true, 0, true,
--           -- MapHotspot.CATEGORY_DEFAULT, textSize, textOffsetY, {worker.color[1], worker.color[2], worker.color[3], 1.0},
--           --nil, getNormalizedUVs({768, 768, 256, 256}), Overlay.ALIGN_VERTICAL_MIDDLE, 0.7));
--         else
--           if worker.currentVehicle.components ~= nil then
--             --worker.mapHotSpot = g_currentMission:addMapHotspot(tostring(worker.name), tostring(worker.name), ContractorMod.myCurrentModDirectory .. "images/worker" .. tostring(i) .. ".dds", nil, nil, worker.x, worker.z, g_currentMission.ingameMap.mapArrowWidth / 3, g_currentMission.ingameMap.mapArrowHeight / 3, false, false, false, worker.currentVehicle.components[1].node, true);
--             worker.mapHotSpot = MapHotspot:new(tostring(worker.name), MapHotspot.CATEGORY_AI)
--             worker.mapHotSpot:setSize(width, height)
--             worker.mapHotSpot:setLinkedNode(worker.currentVehicle.components[1].node)
--             worker.mapHotSpot:setText(tostring(worker.name))
--             worker.mapHotSpot:setImage(nil, getNormalizedUVs({768, 768, 256, 256}), {worker.color[1], worker.color[2], worker.color[3], 1.0})
--             worker.mapHotSpot:setBackgroundImage(nil, getNormalizedUVs({768, 768, 256, 256}))
--             worker.mapHotSpot:setIconScale(0.7)
--             worker.mapHotSpot:setTextOptions(textSize, nil, textOffsetY, {worker.color[1], worker.color[2], worker.color[3], 1.0}, Overlay.ALIGN_VERTICAL_MIDDLE)
--             --   nil, getNormalizedUVs({768, 768, 256, 256}), {worker.color[1], worker.color[2], worker.color[3], 1.0},
--             -- worker.x, worker.z, width, height, false, false, true, worker.currentVehicle.components[1].node, true,
--             -- MapHotspot.CATEGORY_DEFAULT, textSize, textOffsetY, {worker.color[1], worker.color[2], worker.color[3], 1.0},
--             -- nil, getNormalizedUVs({768, 768, 256, 256}), Overlay.ALIGN_VERTICAL_MIDDLE, 0.7);
--           else
--             -- TODO: Analyze in which situation this happens
--             if ContractorMod.debug then print("ContractorMod: worker.currentVehicle.components == nil" ) end          
--           end
--         end
--         if (worker.mapHotSpot ~= nil) then
--           g_currentMission:addMapHotspot(worker.mapHotSpot)
--         end
--       end
    end
  end
end

-- Display character name instead of player name when not i a vehicle
function ContractorMod:drawUIInfo()
	if ContractorMod.displayPlayerNames and self.isClient and self.isControlled and not self.isEntered and not g_gui:getIsGuiVisible() and not g_noHudModeEnabled and g_gameSettings:getValue(GameSettings.SETTING.SHOW_MULTIPLAYER_NAMES) then
		local x, y, z = getTranslation(self.graphicsRootNode)
		local x1, y1, z1 = getWorldTranslation(getCamera())
		local diffX = x - x1
		local diffY = y - y1
		local diffZ = z - z1
		local dist = MathUtil.vector3LengthSq(diffX, diffY, diffZ)

		if dist <= 10000 then
			y = y + self.baseInformation.tagOffset[2]
      local currentWorker = nil
      if ContractorMod.workers ~= nil then
        for i = 1, #ContractorMod.workers do
          local worker = ContractorMod.workers[i]
          if worker.player.rootNode == self.rootNode then
            currentWorker = worker
            break
          end
        end
      end
			if currentWorker ~= nil then
				Utils.renderTextAtWorldPosition(x, y, z, currentWorker.name, getCorrectTextSize(0.02), 0)
			end
		end
	end
end
Player.drawUIInfo = Utils.overwrittenFunction(Player.drawUIInfo, ContractorMod.drawUIInfo);

-- function ContractorMod:setVisibility(superFunc, visibility)
--   print("ContractorMod:setVisibility player "..self.rootNode..": "..tostring(visibility))
--   printCallstack()
--   superFunc(self, visibility)
-- end
-- Player.setVisibility = Utils.overwrittenFunction(Player.setVisibility, ContractorMod.setVisibility);

-- @doc Launch init at first call and then update workers positions and states
function ContractorMod:update(dt)
  -- DebugUtil.printTableRecursively(g_currentMission.player, " ", 1, 3)
  if self.workers == nil and g_currentMission.player.controllerIndex > 0 and g_currentMission.player.time > 1000 then
    -- DebugUtil.printTableRecursively(g_currentMission.player, " ", 1, 3)
    -- default values
    self:init()
    -- DebugUtil.printTableRecursively(self.workers, " ", 1, 3)
    local firstWorker = self.workers[self.currentID]
    if g_currentMission.player and g_currentMission.player ~= nil then
      if ContractorMod.debug then print("ContractorMod: moveToAbsolute"); end
      -- setTranslation(g_currentMission.player.rootNode, firstWorker.x, firstWorker.y, firstWorker.z);
      -- g_currentMission.player:moveRootNodeToAbsolute(firstWorker.x, firstWorker.y, firstWorker.z);
      firstWorker.x, firstWorker.y, firstWorker.z, firstWorker.rotY = g_currentMission.player:getPositionData()
      g_currentMission.player:moveTo(firstWorker.x, firstWorker.y, firstWorker.z, true, true)
      -- DebugUtil.printTableRecursively(firstWorker, " ", 1, 2)
      g_currentMission.player:setRotation(firstWorker.rotX, firstWorker.rotY)
      if firstWorker.currentVehicle ~= nil then
        firstWorker:afterSwitch()
      end
    end
    self.initializing = false
  end
  
  if self.workers ~= nil and #self.workers > 0 then
    for i = 1, self.numWorkers do
      worker = self.workers[i]
      if i == self.currentID then
        -- For current player character
        if g_currentMission.controlledVehicle == nil then
          -- local passengerHoldingVehicle = g_currentMission.passengerHoldingVehicle;
          -- if passengerHoldingVehicle ~= nil then
          --   worker.isPassenger = true
          --   worker.currentVehicle = passengerHoldingVehicle;
          --   worker.passengerPlace = g_currentMission.passengerPlace
          -- else
            -- not in a vehicle
            -- worker.x, worker.y, worker.z = getWorldTranslation(g_currentMission.player.rootNode);
            worker.x, worker.y, worker.z, worker.rotY = g_currentMission.player:getPositionData()
            worker.rotX = g_currentMission.player.rotX
            -- worker.rotY = g_currentMission.player.rotY
            worker.isPassenger = false
            worker.passengerPlace = 0
            worker.currentVehicle = nil;
            -- print("Current worker")
            -- DebugUtil.printTableRecursively(worker.playerStateMachine, " ", 1, 3);
          -- end
        else
          -- in a vehicle
          worker.x, worker.y, worker.z = getWorldTranslation(g_currentMission.controlledVehicle.rootNode); -- for miniMap update
          worker.currentVehicle = g_currentMission.controlledVehicle;
          -- forbid motor stop when switching between workers
          worker.currentVehicle.motorStopTimer = worker.currentVehicle.motorStopTimerDuration
          -- Trick to make FollowMe work as expected when stopping it
          if worker.currentVehicle.followMeIsStarted ~= nil then
            if worker.currentVehicle.followMeIsStarted then
              if worker.currentVehicle.followMeIsStarted ~= worker.followMeIsStarted then
                --Starting FollowMe
                if ContractorMod.debug then print("FollowMe has been started for current vehicle") end
                worker.followMeIsStarted = worker.currentVehicle.followMeIsStarted
              end
            else
              if worker.currentVehicle.followMeIsStarted ~= worker.followMeIsStarted then
                --Stopping FollowMe
                if ContractorMod.debug then print("FollowMe has been stopped for current vehicle") end
                worker.currentVehicle.isHired = false;
                worker.currentVehicle.steeringEnabled = true;
                worker.followMeIsStarted = worker.currentVehicle.followMeIsStarted
              end
            end
          end
        end
      else
        -- For other characters
        if worker.currentVehicle ~= nil and worker.currentVehicle.rootNode ~= nil then
          -- update if in a vehicle
          worker.x, worker.y, worker.z = getWorldTranslation(worker.currentVehicle.rootNode); -- for miniMap update
          -- forbid motor stop when switching between workers
          worker.currentVehicle.motorStopTimer = worker.currentVehicle.motorStopTimerDuration
          
          -- Trick to make FollowMe work as expected when stopping it
          if worker.currentVehicle.followMeIsStarted ~= nil then
            if worker.currentVehicle.followMeIsStarted then
              if worker.currentVehicle.followMeIsStarted ~= worker.followMeIsStarted then
                --Starting FollowMe
                if ContractorMod.debug then print("FollowMe has been started") end
                worker.followMeIsStarted = worker.currentVehicle.followMeIsStarted
              end
            else
              if worker.currentVehicle.followMeIsStarted ~= worker.followMeIsStarted then
                --Stopping FollowMe
                if ContractorMod.debug then print("FollowMe has been stopped") end
                worker.currentVehicle.isHired = false;
                worker.currentVehicle.steeringEnabled = true;
                worker.followMeIsStarted = worker.currentVehicle.followMeIsStarted
              end
            end
          end
        end
      end
    end
  end
end

-- @doc Change active worker
function ContractorMod:setCurrentContractorModWorker(setID)
  if ContractorMod.debug then print("ContractorMod:setCurrentContractorModWorker(setID) " .. tostring(setID)) end
  local currentWorker = self.workers[self.currentID]
  if currentWorker ~= nil then
    self.shouldStopWorker = false
    self.switching = true
    currentWorker:beforeSwitch()
  end
  self.currentID = setID
  currentWorker = self.workers[self.currentID]
  if currentWorker ~= nil then
    currentWorker:afterSwitch()
    self.shouldStopWorker = true
    self.switching = false
  end
  --DebugUtil.printTableRecursively(self.workers, " ", 1, 3)
end

function ContractorMod:doNothing()
  if ContractorMod.debug then print("ContractorMod:doNothing ") end
  -- print("Prevent entering as passenger")
end

function ContractorMod:onPlayerEnter(isControlling)
  if ContractorMod.debug then print("ContractorMod:onPlayerEnter ") end
  if g_currentMission.player:getStyle() and ContractorMod.workers then
    if ContractorMod.debug then
      print("\ng_currentMission.player:getStyle()")
      -- DebugUtil.printTableRecursively(g_currentMission.player:getStyle(), " ", 1, 2)
      print("\nworker:getStyle()")
      -- DebugUtil.printTableRecursively(ContractorMod.workers[ContractorMod.currentID].playerStyle, " ", 1, 2)
    end
    -- printCallstack()
    g_currentMission.player:getStyle():copyFrom(ContractorMod.workers[ContractorMod.currentID].playerStyle)
  end
end
Player.onEnter = Utils.appendedFunction(Player.onEnter, ContractorMod.onPlayerEnter)

function ContractorMod:onItemSelectionConfirmed()
  ContractorMod.workers[ContractorMod.currentID].playerStyle:copyFrom(self.currentPlayerStyle)
end
WardrobeScreen.onItemSelectionConfirmed = Utils.appendedFunction(WardrobeScreen.onItemSelectionConfirmed, ContractorMod.onItemSelectionConfirmed)

addModEventListener(ContractorMod);
