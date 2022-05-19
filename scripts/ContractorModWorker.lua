--
-- ContractorMod
-- Specialization for storing each character data
-- No event plugged, only called when interacting with ContractorMod
--
-- @author  yumi
-- free for noncommercial-usage
--

ContractorModWorker = {};
ContractorModWorker_mt = Class(ContractorModWorker);

ContractorModWorker.debug = false --true --

function ContractorModWorker:getParentComponent(node)
  return self.graphicsRootNode;
end;

function ContractorModWorker:new(name, index, workerStyle)
  if ContractorModWorker.debug then print("ContractorModWorker:new()") end
  local self = {};
  setmetatable(self, ContractorModWorker_mt);

  self.name = name
  self.nickname = name --g_settingsNickname
  -- g_settingsNickname = name
  self.currentVehicle = nil
  self.isPassenger = false    -- to be removed when all code clean
  self.isNewPassenger = false -- to replace isPassenger waiting code cleaning
  
  local connection = g_server.clientConnections[NetworkNode.LOCAL_STREAM_ID]
  local user = g_currentMission.userManager:getUserByConnection(connection)
  local farm = g_farmManager:getFarmByUserId(user:getId())
  local farmId = FarmManager.SPECTATOR_FARM_ID

  if farm ~= nil then
    farmId = farm.farmId
  end
  -- p.model.style.playerName = name
  self.mapHotSpot = nil
  self.color = g_playerColors[(workerStyle.playerColorIndex + 1)].value
  if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
    self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
    self.dx, self.dy, self.dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, 1);
    self.rotX = 0.;
    self.rotY = 0.73;
    self.x = self.x + (1 * index)
    self.playerStyle = PlayerStyle.new()
    self.playerStyle:copyFrom(workerStyle)
    self.farmId = farmId
  end
  return self
end


function ContractorModWorker:displayName(contractorMod)
  --if ContractorModWorker.debug then print("ContractorModWorker:displayName()") end
  if self.name == "PLAYER" then return end
  setTextBold(true);
  setTextAlignment(RenderText.ALIGN_RIGHT);
  
  setTextColor(self.color[1], self.color[2], self.color[3], 1.0);
  local x = 0.9828
  local y = 0.45
  local size = 0.024
  if contractorMod.displaySettings ~= nil and contractorMod.displaySettings.characterName ~= nil then
    x = contractorMod.displaySettings.characterName.x
    y = contractorMod.displaySettings.characterName.y
    size = contractorMod.displaySettings.characterName.size
  end
  renderText(x, y, size, self.name);
  
  if ContractorModWorker.debug then
    if self.currentVehicle ~= nil then
      local vehicleName = ""
      if self.currentVehicle ~= nil then
        vehicleName = self.currentVehicle:getFullName()
      end
      renderText(0.9828, 0.42, 0.012, vehicleName);
    end
    renderText(0.9828, 0.41, 0.012, self.name);
    renderText(0.9828, 0.40, 0.012, "x:" .. tostring(self.x) .. " y:" .. tostring(self.y) .. " z:" .. tostring(self.z));
    renderText(0.9828, 0.39, 0.012, "dx:" .. tostring(self.dx) .. " dy:" .. tostring(self.dy) .. " dz:" .. tostring(self.dz));
    renderText(0.9828, 0.38, 0.012, "rotX:" .. tostring(self.rotX) .. " rotY:" .. tostring(self.rotY));
    -- renderText(0.9828, 0.37, 0.012, "graphicsRotY:" .. tostring(self.player.graphicsRotY));
    -- renderText(0.9828, 0.36, 0.012, "targetGraphicsRotY:" .. tostring(self.player.targetGraphicsRotY));
    renderText(0.9828, 0.35, 0.012, "shouldStopWorker:  " .. tostring(contractorMod.shouldStopWorker));
    renderText(0.9828, 0.33, 0.012, "switching:         " .. tostring(contractorMod.switching));
    renderText(0.9828, 0.31, 0.012, "passengerLeaving:  " .. tostring(contractorMod.passengerLeaving));
    renderText(0.9828, 0.29, 0.012, "passengerEntering: " .. tostring(contractorMod.passengerEntering));
  end
  -- Restore default alignment (to avoid impacting other mods like FarmingTablet)
  setTextAlignment(RenderText.ALIGN_LEFT);
end

-- @doc Capture worker position before switching to another one
function ContractorModWorker:beforeSwitch(noEventSend)
  if ContractorModWorker.debug then print("ContractorModWorker:beforeSwitch()") end
  self.currentVehicle = g_currentMission.controlledVehicle

  if self.currentVehicle == nil then
    -- Old passenger condition
    local passengerHoldingVehicle = g_currentMission.passengerHoldingVehicle;
    if passengerHoldingVehicle ~= nil then
      -- source worker is passenger in a vehicle
    else
      -- source worker is not in a vehicle
      self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
      if ContractorModWorker.debug then print("ContractorModWorker: "..tostring(self.x)..", "..tostring(self.y)..", "..tostring(self.z)) end
      self.rotX = g_currentMission.player.rotX;
      self.rotY = g_currentMission.player.rotY;
      if self.displayOnFoot then
        self.player.isEntered = false
        if noEventSend == nil or noEventSend == false then
          -- print("set visible 1: "..self.name)
          self.player:setVisibility(true)
        end
        -- if ContractorModWorker.debug then print("ContractorModWorker: moveTo "..tostring(self.player.model.style.playerName)); end

        local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, self.x, 300, self.z)
        -- self.y = math.max(terrainHeight + 0.1, self.y + 0.9)
      
        -- self.player:moveRootNodeToAbsolute(self.x, self.y, self.z)
        
        -- local x, y, z = getWorldTranslation(spawnPoint)
        -- local dx, _, dz = localDirectionToWorld(spawnPoint, 0, 0, -1)
        local dx, _, dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, -1)
        local ry = MathUtil.getYRotationFromDirection(dx, dz)
        local y = math.max(self.y, getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, self.x, 0, self.z) + 0.2)

        self.player:moveTo(self.x, y, self.z, true, true)
        self.player:setRotation(0, ry)
        --[[
        self.player.baseInformation.isOnGround = true
        self.player:moveToAbsoluteInternal(self.x, self.y, self.z)
      
        local dx, _, dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, -1)  --]]
        self.rotY = MathUtil.getYRotationFromDirection(dx, dz)
      
        setRotation(self.player.graphicsRootNode, 0, self.rotY + math.rad(180.0), 0)
        setRotation(self.player.cameraNode, self.rotX, self.rotY, 0)
      end
    end
  else
    -- source worker is in a vehicle
    self.x, self.y, self.z = getWorldTranslation(self.currentVehicle.rootNode);
    self.y = self.y + 2 --to avoid being under the ground
    self.dx, self.dy, self.dz = localDirectionToWorld(self.currentVehicle.rootNode, 0, 0, 1);

    if noEventSend == nil or noEventSend == false then
      if ContractorModWorker.debug then print("ContractorModWorker: sendEvent(onLeaveVehicle") end
      g_currentMission:onLeaveVehicle()
    end
  end
end

-- @doc Teleport to target worker when switching 
function ContractorModWorker:afterSwitch(noEventSend)
  if ContractorModWorker.debug then print("ContractorModWorker:afterSwitch()") end
  
  if self.currentVehicle == nil then
    -- target worker is not in a vehicle
    if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
      -- if ContractorModWorker.debug then print("ContractorModWorker: moveTo "..tostring(g_currentMission.player.model.style.playerName)); end
      setTranslation(g_currentMission.player.rootNode, self.x, self.y, self.z);
      g_currentMission.player:moveRootNodeToAbsolute(self.x, self.y-0.2, self.z);
      g_currentMission.player:setRotation(self.rotX, self.rotY)
      if self.displayOnFoot then
        self.player.isEntered = true
        self.player.isControlled = true
        self.player:moveToAbsoluteInternal(0, -200, 0); -- to avoid having player at the same location than current player
        if ContractorModWorker.debug then print("ContractorModWorker: set visible 0: "..self.name); end
        -- TODO --self.player:setVisibility(false)
      end
      if ContractorModWorker.debug then
        print("ContractorModWorker: setStyleAsync ");
        DebugUtil.printTableRecursively(self.playerStyle, " ", 1, 3)
      end
      g_currentMission.player:setStyleAsync(self.playerStyle, nil, false)
      -- g_currentMission.playerInfoStorage:setPlayerStyle(g_currentMission.player.userId, self.playerStyle)
    end

  else
    -- if self.isPassenger then
      -- target worker is passenger
    -- else
      -- target worker is in a vehicle
      if noEventSend == nil or noEventSend == false then
        if ContractorModWorker.debug then print("ContractorModWorker: sendEvent(VehicleEnterRequestEvent:" ) end
        g_client:getServerConnection():sendEvent(VehicleEnterRequestEvent.new(self.currentVehicle, self.playerStyle, self.farmId));
        if ContractorModWorker.debug then print("ContractorModWorker: playerStyle "..tostring(self.playerStyle)) end
      end
    -- end
  end
end
