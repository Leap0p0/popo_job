local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

local gangpoint = {}
local name = nil
local label = nil
local name_suppr = nil
local name_petit = nil
local name_moyen = nil
local name_grand = nil
local name_boss = nil
local first_place = nil
local second_place = nil
local GUI               = {}
GUI.Time                = 0
local OnFaction         = false
local PlayerData                = {}
local name_job = nil
local boss_pos = nil
local job = nil
local job_grade = nil
local stock_pos = nil
local builder = {
  first_coord = nil,
  second_coord = nil
}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RMenu.Add("popojob", "categorie", RageUI.CreateMenu("Souhaitez-vous", "~b~ Créer / Supprimer"))
RMenu:Get("popojob", "categorie").Closed = function()
end

RMenu.Add("popojob", "garage", RageUI.CreateMenu("Souhaitez-vous", nil))
RMenu:Get("popojob", "garage").Closed = function()
end

RMenu.Add("popojob", "stock", RageUI.CreateMenu("Souhaitez-vous", "~b~ Prendre / Déposer"))
RMenu:Get("popojob", "stock").Closed = function()
end
RMenu.Add("popojob", "boss", RageUI.CreateMenu("Souhaitez-vous", "Souhaitez-vous : "))
RMenu:Get("popojob", "boss").Closed = function()
end

RMenu.Add("popojob", "create", RageUI.CreateSubMenu(RMenu:Get("popojob", "categorie"), "lolo", nil))
RMenu:Get("popojob", "create").Closed = function()
end

RMenu.Add("popojob", "grade", RageUI.CreateSubMenu(RMenu:Get("popojob", "create"), "test", nil))
RMenu:Get("popojob", "grade").Closed = function()
end

RMenu.Add("popojob", "delete", RageUI.CreateSubMenu(RMenu:Get("popojob", "categorie"), "eded", nil))
RMenu:Get("popojob", "delete").Closed = function()
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
ESX.PlayerData = xPlayer
PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job2)
ESX.PlayerData.job = job
end)

local function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
  AddTextEntry(entryTitle, textEntry)
  DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
blockinput = true

  while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
      Citizen.Wait(0)
  end

  if UpdateOnscreenKeyboard() ~= 2 then
      local result = GetOnscreenKeyboardResult()
      Citizen.Wait(500)
  blockinput = false
      return result
  else
      Citizen.Wait(500)
  blockinput = false
      return nil
  end
end

local function OpenGetStocksMenu(society_name)

ESX.TriggerServerCallback('popojob:getStockItems', function(items, society_name)

  print(json.encode(items))

  local elements = {}

  for i=1, #items, 1 do
    if (items[i].count ~= 0) then
      table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end
  end

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
      title    = 'Stock',
      align    = 'top-left',
      elements = elements
    }, function(data, menu)

      local itemName = data.current.value

      ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
          title = _U('quantity')
        }, function(data2, menu2)
  
          local count = tonumber(data2.value)

          if count == nil or count <= 0 then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            menu.close()
            OpenGetStocksMenu(society_name)

            TriggerServerEvent('popojob:getStockItems', itemName, count, society_name)
          end
        end, function(data2, menu2)
          menu2.close()
        end)
    end, function(data, menu)
      menu.close()
    end)
end)
end

local function OpenPutStocksMenu(society_name)

ESX.TriggerServerCallback('popojob:getPlayerInventory', function(inventory)

  local elements = {}

  for i=1, #inventory.items, 1 do

    local item = inventory.items[i]

    if item.count > 0 then
      table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
    end
  end

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
      title    = _U('inventory'),
      elements = elements
    }, function(data, menu)

      local itemName = data.current.value

      ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
          title = _U('quantity')
        }, function(data2, menu2)

          local count = tonumber(data2.value)

          if count == nil or count <= 0 then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            menu.close()
            OpenPutStocksMenu(society_name)

            TriggerServerEvent('popojob:putStockItems', itemName, count)
          end
        end, function(data2, menu2)
          menu2.close()
        end)
    end, function(data, menu)
      menu.close()
    end)
end)
end

--STOCK MENU RageUI--

local function openStockMenu(society_name)
RageUI.Visible(RMenu:Get("popojob","stock"), true)
Citizen.CreateThread(function()
  while true do
    RageUI.IsVisible(RMenu:Get("popojob","stock"),true,true,true,function()
      RageUI.Button(_U('get_stock'), _U('get_stock'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
          RageUI.CloseAll()
          OpenGetStocksMenu(society_name)
                  end
              end)
      RageUI.Button(_U('put_stock'), _U('put_stock'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
          RageUI.CloseAll()
          OpenPutStocksMenu(society_name)
                  end
              end)
    end, function()end)
    Citizen.Wait(0)
  end
end)
end

--open the boss menu in RageUI--
local function boss()
  RageUI.Visible(RMenu:Get("popojob","boss"), true)
  Citizen.CreateThread(function()
  while true do
      RageUI.IsVisible(RMenu:Get("popojob","boss"),true,true,true,function()
          RageUI.Button("Retirer argent de société" , "Retirer argent de société", {RightLabel = "~g~>>>"}, true,function(h,a,s)
              if (s) then
                  RageUI.CloseAll()
                  local amount = KeyboardInput("POPO_BOX_retirer", "Retirer", "", 15)
                  amount = tonumber(amount)
                  if amount == nil then
                      ESX.ShowNotification('Montant invalide')
                  else
                      TriggerServerEvent('esx_society:withdrawMoney', tostring(ESX.PlayerData.job.name), amount)
                  end
              end
          end)
          RageUI.Button("Déposer argent de société" , "Déposer argent de société", {RightLabel = "~g~>>>"}, true,function(h,a,s)
              if (s) then
                RageUI.CloseAll()
                  local amount = KeyboardInput("POPO_BOX_prendre", "Déposer :", "", 15)
                  amount = tonumber(amount)
                  if amount == nil then
                      ESX.ShowNotification('Montant invalide')
                  else
                      TriggerServerEvent('esx_society:depositMoney', tostring(ESX.PlayerData.job.name), amount)
                  end
              end
          end)
      end, function()end)
      Citizen.Wait(0)
  end
end)
end

--Show marker--
local function show_marker()
  while true do
      local interval = 500
      local pos = GetEntityCoords(PlayerPedId())
      local job = ESX.PlayerData.job.name
      local job_grade = ESX.PlayerData.job.grade_name
      for i, teleportpoints in pairs(gangpoint) do
          local a = teleportpoints.first_coord
          local b = teleportpoints.second_coord
          print(job)
          print(teleportpoints.gang_name)
          
          --POINT COFFRE--
          local dist = #(pos - a)
              if (dist <= 100) and job == teleportpoints.gang_name then
                  interval = 0
                  DrawMarker(25, a.x, a.y, (a.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, false, false, false, false)
                  if (dist <= 1) then
                      AddTextEntry("try", _U('open_stock'))
                      DisplayHelpTextThisFrame("try", false)
                      if (IsControlJustPressed(0, 51)) then
                          local society_name = "society_"..teleportpoints.gang_name
                          openStockMenu(society_name)
                      end
                  end
              end
  
          --POINT BOSS--
          dist = #(pos - b)
              if (dist <= 100) and job == teleportpoints.gang_name and job_grade == 'boss' then
                  interval = 0
                  DrawMarker(25, b.x, b.y, (b.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, false, false, false, false)
                  if (dist <= 1) then
                      AddTextEntry("tryb", _U('open_boss'))

                      DisplayHelpTextThisFrame("tryb", false)
                      if (IsControlJustPressed(0, 51)) then
                          boss()
                      end
                  end
              end
      end
      Wait(interval)
  end
end

--open the menu in RageUI--
local function openMenu()

  RageUI.Visible(RMenu:Get("popojob","categorie"), true)
  Citizen.CreateThread(function()
      while true do
          --Create / Delete--
          RageUI.IsVisible(RMenu:Get("popojob","categorie"),true,true,true,function()
              RageUI.Button("Créer" , "Créer", {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
                  end
              end, RMenu:Get("popojob", "create"))
              RageUI.Button(_U('delete') , _U('delete'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
                  end
              end, RMenu:Get("popojob", "delete"))
          end, function()end)

          --Create Menu--
          RageUI.IsVisible(RMenu:Get("popojob","create"),true,true,true,function()
              RageUI.Button(_U('name') , _U('name'), {RightLabel = builder.gang_name}, true,function(h,a,s)
                  if (s) then
                      name = KeyboardInput("POPO_BOX_NAME", _U('name'), "", 15)
                      if name and name ~= "" then
                          builder.gang_name = tostring(name)
                          builder.gang_name = string.lower(string.gsub(builder.gang_name, "%s+", "_"))
                      end
                  end
              end)
              RageUI.Button(_U('label') , _U('label'), {RightLabel = builder.label_name}, true,function(h,a,s)
                  if (s) then
                      label = KeyboardInput("POPO_BOX_LABEL", _U('label'), "", 15)
                      if label and label ~= "" then
                          builder.label_name = tostring(label)
              builder.label_name = string.lower(string.gsub(builder.label_name, "%s+", "_"))
                      end
                  end
              end)
              RageUI.Button(_U('grade') , _U('grade'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
                  end
              end, RMenu:Get("popojob", "grade"))
        if builder.first_coord == nil then 
          first_place = "~r~❌"
        else 
          first_place = "~b~✅"
        end 
              RageUI.Button(_U('first_point') , _U('first_point'), {RightLabel = first_place}, true,function(h,a,s)
                  if (s) then
                      local Ped = PlayerPedId()
            local pedCoords = GetEntityCoords(Ped)
                      builder.first_coord = pedCoords
                      ESX.ShowNotification(_U('first'))
                  end
              end)
        if builder.second_coord == nil then 
          second_place = "~r~❌"
        else 
          second_place = "~b~✅"
        end 
              RageUI.Button(_U('second_point') , _U('second_point'), {RightLabel = second_place}, true,function(h,a,s)
                  if (s) then
                      local Ped = PlayerPedId()
            local pedCoords = GetEntityCoords(Ped)
                      builder.second_coord = pedCoords
                      ESX.ShowNotification(_U('second'))
                  end
              end)
              RageUI.Button(_U('create') , _U('create'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
                    if second_place == "~b~✅" and first_place == "~b~✅" and builder.gang_name and builder.label_name then
                      RageUI.CloseAll()
                          TriggerServerEvent('popo_job:register_job', builder)
                          TriggerServerEvent('popo_job:register_Inventory_account', builder)
                          TriggerServerEvent('popo_job:register_job_grades', builder)
                          ESX.ShowNotification(_U('good_create')..builder.gang_name.._U('good_create_bis'))
                          second_place = "~r~❌"
                          first_place = "~r~❌"
                          name = nil
                          builder.gang_name = nil
                          builder.label_name = nil
                          first_place = nil
                          second_place = nil
                          builder.first_coord = nil
                          builder.second_coord = nil
                      else
                          ESX.ShowNotification(_U('no'))
                      end
                  end
              end)
          end, function()end, 1)

           --Delete Menu--

          RageUI.IsVisible(RMenu:Get("popojob","delete"),true,true,true,function()
              RageUI.Button(_U('name') , _U('name'), {RightLabel = name_suppr}, true,function(h,a,s)
                  if (s) then
                      name_suppr = KeyboardInput("POPO_BOX_BIS", _U('name'), "", 15)
                      name_suppr = tostring(name_suppr)
                      name_suppr = string.lower(string.gsub(name_suppr, "%s+", "_"))
                  end
              end)
              RageUI.Button(_U('delete'), _U('delete'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                  if (s) then
                      if name_suppr and name_suppr ~= "" then
                          RageUI.CloseAll()
                          TriggerServerEvent('popo_job:delete_job', name_suppr)
                          ESX.ShowNotification(_U('good_delete')..name_suppr.._U('good_delete_bis'))
                          name_suppr = nil
                      else
                          ESX.ShowNotification(_U('no_bis'))
                      end
                  end
              end)
          end, function()end, 1)
          --Grade Menu--
          RageUI.IsVisible(RMenu:Get("popojob","grade"),true,true,true,function()
              RageUI.Button(_U('petit') , _U('petit'), {RightLabel = builder.name_petit}, true,function(h,a,s)
                  if (s) then
                      builder.name_petit = KeyboardInput("POPO_BOX_first", _U('petit'), "", 15)
                      builder.name_petit = tostring(builder.name_petit)
                  end
              end)
              RageUI.Button(_U('moyen') , _U('moyen'), {RightLabel = builder.name_moyen}, true,function(h,a,s)
                  if (s) then
                      builder.name_moyen = KeyboardInput("POPO_BOX_second", _U('moyen'), "", 15)
                      builder.name_moyen = tostring(builder.name_moyen)
                  end
              end)
              RageUI.Button(_U('grand') , _U('grand'), {RightLabel = builder.name_grand}, true,function(h,a,s)
                  if (s) then
                      builder.name_grand = KeyboardInput("POPO_BOX_third", _U('grand'), "", 15)
                      builder.name_grand = tostring(builder.name_grand)
                  end
              end)
              RageUI.Button(_U('boss') , _U('boss'), {RightLabel = builder.name_boss}, true,function(h,a,s)
                  if (s) then
                      builder.name_boss = KeyboardInput("POPO_BOX_last", _U('boss'), "", 15)
                      builder.name_boss = tostring(builder.name_boss)
                  end
              end)
          end, function()end)
          Citizen.Wait(0)
      end
  end)
end

Citizen.CreateThread(function()
while ESX == nil do
  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
  Citizen.Wait(1)
end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setjob')
AddEventHandler('esx:setjob', function(job2)
PlayerData.job = job
end)

RegisterNetEvent("popo_job:nbgang", function(point)
  gangpoint = point
  show_marker()
end)

SetTimeout(1500, function()
  xPlayer = ESX.GetPlayerData()
  TriggerServerEvent("popo_job:requestgang")
end)

RegisterCommand("popojob", function()
  openMenu()
end, false)