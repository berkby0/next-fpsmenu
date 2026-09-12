local Citizen_Wait = Citizen.Wait
local PlayerPedId = PlayerPedId
local DoesEntityExist = DoesEntityExist
local GetEntityCoords = GetEntityCoords
local GetGamePool = GetGamePool
local SetPedLodMultiplier = SetPedLodMultiplier
local SetVehicleLodMultiplier = SetVehicleLodMultiplier
local RemoveParticleFxInRange = RemoveParticleFxInRange
local OverrideLodscaleThisFrame = OverrideLodscaleThisFrame
local DisableOcclusionThisFrame = DisableOcclusionThisFrame
local SetDisableDecalRenderingThisFrame = SetDisableDecalRenderingThisFrame
local DisableVehicleDistantlights = DisableVehicleDistantlights
local SetFlashLightFadeDistance = SetFlashLightFadeDistance
local SetLightsCutoffDistanceTweak = SetLightsCutoffDistanceTweak
local SetArtificialLightsState = SetArtificialLightsState
local ClearBrief = ClearBrief
local ClearAllBrokenGlass = ClearAllBrokenGlass
local ClearPedBloodDamage = ClearPedBloodDamage
local ClearPedWetness = ClearPedWetness
local ClearPedEnvDirt = ClearPedEnvDirt
local ResetPedVisibleDamage = ResetPedVisibleDamage
local SetRainLevel = SetRainLevel
local SetWindSpeed = SetWindSpeed
local CascadeShadowsClearShadowSampleType = CascadeShadowsClearShadowSampleType
local RopeDrawShadowEnabled = RopeDrawShadowEnabled
local CascadeShadowsSetAircraftMode = CascadeShadowsSetAircraftMode
local CascadeShadowsEnableEntityTracker = CascadeShadowsEnableEntityTracker
local CascadeShadowsSetDynamicDepthMode = CascadeShadowsSetDynamicDepthMode
local CascadeShadowsSetEntityTrackerScale = CascadeShadowsSetEntityTrackerScale
local CascadeShadowsSetDynamicDepthValue = CascadeShadowsSetDynamicDepthValue
local CascadeShadowsSetCascadeBoundsScale = CascadeShadowsSetCascadeBoundsScale
local SetTimecycleModifier = SetTimecycleModifier
local SetTimecycleModifierStrength = SetTimecycleModifierStrength
local ClearTimecycleModifier = ClearTimecycleModifier
local ClearExtraTimecycleModifier = ClearExtraTimecycleModifier
local CreateModelSwap = CreateModelSwap
local RemoveModelSwap = RemoveModelSwap
local RequestModel = RequestModel
local HasModelLoaded = HasModelLoaded
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local IsModelValid = IsModelValid
local RequestStreamedTextureDict = RequestStreamedTextureDict
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local SetStreamedTextureDictAsNoLongerNeeded = SetStreamedTextureDictAsNoLongerNeeded
local GetHashKey = GetHashKey
local SetResourceKvp = SetResourceKvp
local GetResourceKvpString = GetResourceKvpString
local SendNUIMessage = SendNUIMessage
local SetNuiFocus = SetNuiFocus

local CurrentSettings = {}
local isNuiLoaded = false
local KVP_KEY = "next-fpsmenu"

local hasPerFrameHooks = false
local optLowTexture = false
local optLights = false
local optParticles = false
local optPeds = false
local optVehicles = false
local optObjects = false
local optBroken = false
local optPed = false
local optRain = false
local optUnnecessary = false
local optPeriodic = false

local optRealismMaster = false
local optRealismStyle = "vibrant"
local optRealismLod = false
local optRealismModels = false
local optRealismLights = false
local optRealismShadows = false

local frameThreadRunning = false
local particleThreadRunning = false
local periodicThreadRunning = false
local realismFrameThreadRunning = false
local realismModelThreadRunning = false

local SaveSettings
local RefreshStateFlags
local StartRealismFrameThread
local StartRealismModelThread
local StartFrameThread
local StartParticleThread
local StartPeriodicThread
local ApplyGraphicPack
local ApplyRealismTimecycle
local ApplyRealismShadows
local ApplyRealismLights
local ApplyShadowOptimization
local RestoreDefaultLights
local UnloadActivePackAssets
local ApplyModelSwapsAtCoords
local StartSwapUpdaterThread

local QBCore = nil
local ESX = nil

CreateThread(function()
    Citizen_Wait(500)
    if GetResourceState('qb-core') == 'started' then
        pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
    end
    if GetResourceState('es_extended') == 'started' then
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
    end
end)

local function ShowNotification(message, notifyType)
    if not Config.Notify or not message or message == "" then return end
    notifyType = notifyType or 'info'

    local system = Config.NotifySystem or 'auto'

    if system == 'custom' and Config.CustomNotify and type(Config.CustomNotify) == 'function' then
        local success = pcall(Config.CustomNotify, message, notifyType)
        if success then return end
    end

    if system == 'auto' then
        if GetResourceState('ox_lib') == 'started' then
            system = 'ox_lib'
        elseif GetResourceState('okokNotify') == 'started' then
            system = 'okok'
        elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
            system = 'qb'
        elseif GetResourceState('es_extended') == 'started' then
            system = 'esx'
        elseif GetResourceState('mythic_notify') == 'started' then
            system = 'mythic'
        elseif Config.CustomNotify and type(Config.CustomNotify) == 'function' then
            local success = pcall(Config.CustomNotify, message, notifyType)
            if success then return end
            system = 'default'
        else
            system = 'default'
        end
    end

    if system == 'ox_lib' then
        pcall(function()
            exports['ox_lib']:notify({
                title = 'FPS Booster',
                description = message,
                type = (notifyType == 'success' and 'success') or (notifyType == 'error' and 'error') or 'info',
                position = 'top-right'
            })
        end)
    elseif system == 'okok' then
        pcall(function()
            exports['okokNotify']:Alert('FPS Booster', message, 4500, (notifyType == 'success' and 'success') or (notifyType == 'error' and 'error') or 'info')
        end)
    elseif system == 'qb' then
        local qbType = (notifyType == 'success' and 'success') or (notifyType == 'error' and 'error') or 'primary'
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            QBCore.Functions.Notify(message, qbType, 5000)
        else
            TriggerEvent('QBCore:Notify', message, qbType, 5000)
        end
    elseif system == 'esx' then
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(message)
        else
            TriggerEvent('esx:showNotification', message)
        end
    elseif system == 'mythic' then
        pcall(function()
            exports['mythic_notify']:DoHudText((notifyType == 'success' and 'success') or (notifyType == 'error' and 'error') or 'inform', message)
        end)
    else
        BeginTextCommandThefeedPost("STRING")
        if #message > 99 then
            for i = 1, #message, 99 do
                AddTextComponentSubstringPlayerName(string.sub(message, i, i + 98))
            end
        else
            AddTextComponentSubstringPlayerName(message)
        end
        EndTextCommandThefeedPostTicker(false, true)
    end
end

ApplyShadowOptimization = function(enabled)
    if optRealismMaster and optRealismShadows then return end
    local state = not enabled
    local depth = enabled and 0.0 or 1.0

    CascadeShadowsClearShadowSampleType()
    RopeDrawShadowEnabled(state)
    CascadeShadowsSetAircraftMode(state)
    CascadeShadowsEnableEntityTracker(state)
    CascadeShadowsSetDynamicDepthMode(state)
    CascadeShadowsSetEntityTrackerScale(depth)
    CascadeShadowsSetDynamicDepthValue(depth)
    CascadeShadowsSetCascadeBoundsScale(depth)
end

RestoreDefaultLights = function()
    if optRealismMaster and optRealismLights then return end
    SetFlashLightFadeDistance(10.0)
    SetLightsCutoffDistanceTweak(10.0)
    SetArtificialLightsState(false)
    DisableVehicleDistantlights(true)
end

local activeModelSwaps = {}
local activeTextureSwaps = {}
local currentActivePack = nil
local lastSwapCoords = vector3(0.0, 0.0, 0.0)
local swapUpdaterRunning = false

UnloadActivePackAssets = function()
    for i = 1, #activeModelSwaps do
        local swap = activeModelSwaps[i]
        if swap and swap.coords and swap.origHash and swap.newHash then
            pcall(RemoveModelSwap, swap.coords.x, swap.coords.y, swap.coords.z, swap.radius or 1000.0, swap.origHash, swap.newHash, false)
            pcall(SetModelAsNoLongerNeeded, swap.newHash)
        end
    end
    activeModelSwaps = {}

    if RemoveReplaceTexture then
        for i = 1, #activeTextureSwaps do
            local tSwap = activeTextureSwaps[i]
            if tSwap and tSwap.origTxd and tSwap.origTx then
                pcall(RemoveReplaceTexture, tSwap.origTxd, tSwap.origTx)
                if tSwap.newTxd then
                    pcall(SetStreamedTextureDictAsNoLongerNeeded, tSwap.newTxd)
                end
            end
        end
    end
    activeTextureSwaps = {}
    currentActivePack = nil
end

ApplyModelSwapsAtCoords = function(coords, modelSwaps)
    if not modelSwaps or #modelSwaps == 0 then return end

    for _, swap in ipairs(modelSwaps) do
        local origHash = type(swap.original) == "number" and swap.original or GetHashKey(swap.original)
        local newHash = type(swap.replacement) == "number" and swap.replacement or GetHashKey(swap.replacement)

        if IsModelValid(newHash) then
            RequestModel(newHash)
            local timeout = 0
            while not HasModelLoaded(newHash) and timeout < 30 do
                Citizen_Wait(50)
                timeout = timeout + 1
            end

            if HasModelLoaded(newHash) then
                pcall(CreateModelSwap, coords.x, coords.y, coords.z, 1000.0, origHash, newHash, false)
                table.insert(activeModelSwaps, {
                    coords = coords,
                    radius = 1000.0,
                    origHash = origHash,
                    newHash = newHash
                })

                if #activeModelSwaps > 40 then
                    local oldSwap = table.remove(activeModelSwaps, 1)
                    if oldSwap and oldSwap.coords then
                        pcall(RemoveModelSwap, oldSwap.coords.x, oldSwap.coords.y, oldSwap.coords.z, oldSwap.radius or 1000.0, oldSwap.origHash, oldSwap.newHash, false)
                    end
                end
            end
        end
    end
end

StartSwapUpdaterThread = function()
    if swapUpdaterRunning then return end
    swapUpdaterRunning = true

    CreateThread(function()
        while optRealismMaster and currentActivePack do
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                local dist = #(coords - lastSwapCoords)
                if dist > 350.0 and Config.GraphicPacks and Config.GraphicPacks[currentActivePack] then
                    lastSwapCoords = coords
                    local pack = Config.GraphicPacks[currentActivePack]
                    if pack.modelSwaps then
                        ApplyModelSwapsAtCoords(coords, pack.modelSwaps)
                    end
                end
            end
            Citizen_Wait(3500)
        end
        swapUpdaterRunning = false
    end)
end

ApplyRealismTimecycle = function(style)
    if not optRealismMaster then
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        return
    end

    style = style or optRealismStyle or "vibrant"
    local pack = Config.GraphicPacks and Config.GraphicPacks[style]

    if pack then
        SetTimecycleModifier(pack.timecycle or "rply_saturation")
        SetTimecycleModifierStrength(pack.timecycleStrength or 1.35)
        if pack.extraTimecycle then
            SetExtraTimecycleModifier(pack.extraTimecycle)
            SetExtraTimecycleModifierStrength(pack.extraStrength or 0.70)
        else
            ClearExtraTimecycleModifier()
        end
    else
        SetTimecycleModifier("rply_saturation")
        SetTimecycleModifierStrength(1.35)
        SetExtraTimecycleModifier("cinema")
        SetExtraTimecycleModifierStrength(0.70)
    end
end

ApplyGraphicPack = function(packId)
    if not packId then return end
    if not Config.GraphicPacks or not Config.GraphicPacks[packId] then
        packId = "vibrant"
    end

    local pack = Config.GraphicPacks[packId]
    if not pack then return end

    CurrentSettings.realismMaster = true
    CurrentSettings.realismStyle = packId
    CurrentSettings.realismLod = true
    CurrentSettings.realismModels = true
    CurrentSettings.realismLights = true
    CurrentSettings.realismShadows = true

    CurrentSettings.peds = false
    CurrentSettings.vehicles = false
    CurrentSettings.objects = false
    CurrentSettings.particles = false
    CurrentSettings.broken = false
    CurrentSettings.ped = false
    CurrentSettings.unnecessary = false
    CurrentSettings.rain = false
    CurrentSettings.shadows = false
    CurrentSettings.lights = false
    CurrentSettings.lowTexture = false

    UnloadActivePackAssets()
    currentActivePack = packId

    local ped = PlayerPedId()
    local coords = DoesEntityExist(ped) and GetEntityCoords(ped) or vector3(0.0, 0.0, 0.0)
    lastSwapCoords = coords

    if pack.modelSwaps and #pack.modelSwaps > 0 then
        CreateThread(function()
            ApplyModelSwapsAtCoords(coords, pack.modelSwaps)
        end)
        StartSwapUpdaterThread()
    end

    if pack.textureSwaps and #pack.textureSwaps > 0 and AddReplaceTexture then
        CreateThread(function()
            for _, tSwap in ipairs(pack.textureSwaps) do
                if tSwap.newTxd and tSwap.origTxd and tSwap.origTx and tSwap.newTx then
                    RequestStreamedTextureDict(tSwap.newTxd, false)
                    local timeout = 0
                    while not HasStreamedTextureDictLoaded(tSwap.newTxd) and timeout < 30 do
                        Citizen_Wait(50)
                        timeout = timeout + 1
                    end
                    if HasStreamedTextureDictLoaded(tSwap.newTxd) then
                        pcall(AddReplaceTexture, tSwap.origTxd, tSwap.origTx, tSwap.newTxd, tSwap.newTx)
                        table.insert(activeTextureSwaps, {
                            origTxd = tSwap.origTxd,
                            origTx = tSwap.origTx,
                            newTxd = tSwap.newTxd
                        })
                    end
                end
            end
        end)
    end

    ApplyRealismTimecycle(packId)

    SaveSettings()

    SendNUIMessage({
        action = "updateSettings",
        settings = CurrentSettings
    })
end

ApplyRealismShadows = function(enabled)
    if enabled then
        CascadeShadowsSetCascadeBoundsScale(5.0)
        CascadeShadowsSetDynamicDepthMode(true)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetEntityTrackerScale(5.0)
        CascadeShadowsSetDynamicDepthValue(5.0)
        RopeDrawShadowEnabled(true)
    else
        CascadeShadowsSetCascadeBoundsScale(1.0)
        CascadeShadowsSetEntityTrackerScale(1.0)
        CascadeShadowsSetDynamicDepthValue(1.0)
    end
end

ApplyRealismLights = function(enabled)
    if enabled then
        DisableVehicleDistantlights(false)
        SetLightsCutoffDistanceTweak(500.0)
        SetFlashLightFadeDistance(150.0)
        SetArtificialLightsState(false)
    else
        SetFlashLightFadeDistance(10.0)
        SetLightsCutoffDistanceTweak(10.0)
        DisableVehicleDistantlights(true)
    end
end

StartRealismFrameThread = function()
    if realismFrameThreadRunning then return end
    realismFrameThreadRunning = true

    CreateThread(function()
        while optRealismMaster do
            ApplyRealismTimecycle(optRealismStyle)

            local pack = Config.GraphicPacks and Config.GraphicPacks[optRealismStyle]
            local targetLod = (pack and pack.lodScale) or 4.0
            local targetShadow = (pack and pack.shadowBounds) or 5.0
            local targetLights = (pack and pack.lightsCutoff) or 800.0

            if optRealismLod then
                OverrideLodscaleThisFrame(targetLod)
            end

            if optRealismShadows then
                CascadeShadowsSetCascadeBoundsScale(targetShadow)
                CascadeShadowsSetDynamicDepthMode(true)
                CascadeShadowsEnableEntityTracker(true)
                CascadeShadowsSetEntityTrackerScale(targetShadow)
                CascadeShadowsSetDynamicDepthValue(targetShadow)
                RopeDrawShadowEnabled(true)
            end

            if optRealismLights then
                DisableVehicleDistantlights(false)
                SetLightsCutoffDistanceTweak(targetLights)
                SetFlashLightFadeDistance(250.0)
                SetArtificialLightsState(false)
            end

            local myPed = PlayerPedId()
            if DoesEntityExist(myPed) then
                SetPedLodMultiplier(myPed, 5.0)
            end

            Citizen_Wait(0)
        end

        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        OverrideLodscaleThisFrame(1.0)
        CascadeShadowsSetCascadeBoundsScale(1.0)
        CascadeShadowsSetEntityTrackerScale(1.0)
        CascadeShadowsSetDynamicDepthValue(1.0)
        SetLightsCutoffDistanceTweak(10.0)
        SetFlashLightFadeDistance(10.0)
        DisableVehicleDistantlights(true)

        realismFrameThreadRunning = false
    end)
end

StartRealismModelThread = function()
    if realismModelThreadRunning then return end
    realismModelThreadRunning = true

    CreateThread(function()
        while optRealismMaster and optRealismModels do
            local peds = GetGamePool('CPed')
            for i = 1, #peds do
                SetPedLodMultiplier(peds[i], 5.0)
            end
            local vehs = GetGamePool('CVehicle')
            for i = 1, #vehs do
                SetVehicleLodMultiplier(vehs[i], 5.0)
            end
            Citizen_Wait(1000)
        end
        realismModelThreadRunning = false
    end)
end

StartFrameThread = function()
    if frameThreadRunning then return end
    frameThreadRunning = true

    CreateThread(function()
        while hasPerFrameHooks do
            if optLowTexture then
                OverrideLodscaleThisFrame(0.6)
                DisableOcclusionThisFrame()
                SetDisableDecalRenderingThisFrame()
            end

            if optLights then
                DisableVehicleDistantlights(false)
                SetFlashLightFadeDistance(3.0)
                SetLightsCutoffDistanceTweak(3.0)
                SetArtificialLightsState(true)
            end

            Citizen_Wait(0)
        end
        frameThreadRunning = false
    end)
end

StartParticleThread = function()
    if particleThreadRunning then return end
    particleThreadRunning = true

    CreateThread(function()
        while optParticles do
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                RemoveParticleFxInRange(coords.x, coords.y, coords.z, 30.0)
            end
            Citizen_Wait(800)
        end
        particleThreadRunning = false
    end)
end

StartPeriodicThread = function()
    if periodicThreadRunning then return end
    periodicThreadRunning = true

    CreateThread(function()
        while optPeriodic do
            if optPeds then
                local peds = GetGamePool('CPed')
                local myPed = PlayerPedId()
                for i = 1, #peds do
                    local p = peds[i]
                    if p ~= myPed then
                        SetPedLodMultiplier(p, 0.5)
                    end
                end
            end

            if optVehicles then
                local vehs = GetGamePool('CVehicle')
                for i = 1, #vehs do
                    SetVehicleLodMultiplier(vehs[i], 0.5)
                end
            end

            if optUnnecessary then
                ClearBrief()
                ClearGpsFlags()
                ClearPrints()
                ClearSmallPrints()
                ClearReplayStats()
                ClearFocus()
                ClearHdArea()
                LeaderboardsReadClearAll()
                LeaderboardsClearCacheData()
                if not optRealismMaster then
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                end
                DisableScreenblurFade()
            end

            if optBroken then
                ClearAllBrokenGlass()
            end

            if optPed then
                local ped = PlayerPedId()
                if DoesEntityExist(ped) then
                    ClearPedBloodDamage(ped)
                    ClearPedWetness(ped)
                    ClearPedEnvDirt(ped)
                    ResetPedVisibleDamage(ped)
                end
            end

            if optRain then
                SetRainLevel(0.0)
                SetWindSpeed(0.0)
            end

            Citizen_Wait(3000)
        end
        periodicThreadRunning = false
    end)
end

RefreshStateFlags = function()
    optLowTexture = CurrentSettings.lowTexture == true
    optLights = CurrentSettings.lights == true
    hasPerFrameHooks = optLowTexture or optLights

    optParticles = CurrentSettings.particles == true

    optPeds = CurrentSettings.peds == true
    optVehicles = CurrentSettings.vehicles == true
    optObjects = CurrentSettings.objects == true
    optBroken = CurrentSettings.broken == true
    optPed = CurrentSettings.ped == true
    optRain = CurrentSettings.rain == true
    optUnnecessary = CurrentSettings.unnecessary == true
    optPeriodic = optPeds or optVehicles or optObjects or optBroken or optPed or optRain or optUnnecessary

    optRealismMaster = CurrentSettings.realismMaster == true
    optRealismStyle = CurrentSettings.realismStyle or "vibrant"
    optRealismLod = CurrentSettings.realismLod == true
    optRealismModels = CurrentSettings.realismModels == true
    optRealismLights = CurrentSettings.realismLights == true
    optRealismShadows = CurrentSettings.realismShadows == true

    if hasPerFrameHooks then StartFrameThread() end
    if optParticles then StartParticleThread() end
    if optPeriodic then StartPeriodicThread() end

    if optRealismMaster then
        StartRealismFrameThread()
        if optRealismModels then
            StartRealismModelThread()
        end
    else
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        ApplyRealismShadows(false)
        if not optLights then
            RestoreDefaultLights()
        end
    end
end

SaveSettings = function()
    SetResourceKvp(KVP_KEY, json.encode(CurrentSettings))
    RefreshStateFlags()
end

CreateThread(function()
    Citizen_Wait(800)

    local saved = GetResourceKvpString(KVP_KEY)
    if saved and saved ~= "" then
        local success, decoded = pcall(json.decode, saved)
        if success and type(decoded) == "table" then
            CurrentSettings = decoded
            for k, v in pairs(Config.GlobalSettings) do
                if CurrentSettings[k] == nil then
                    CurrentSettings[k] = v
                end
            end
        else
            CurrentSettings = Config.GlobalSettings
        end
    else
        CurrentSettings = Config.GlobalSettings
    end

    RefreshStateFlags()

    if CurrentSettings.realismMaster then
        ApplyGraphicPack(CurrentSettings.realismStyle or "vibrant")
    elseif CurrentSettings.shadows then
        ApplyShadowOptimization(true)
    end

    local activeLocale = Locales[Config.Locale] or Locales['en'] or Locales['tr']
    SendNUIMessage({
        ui = "new",
        title = Config.MenuTitle or "NextFps",
        locale = activeLocale,
        lang = Config.Locale or 'en'
    })

    Citizen_Wait(600)
    isNuiLoaded = true
end)

local function ApplyPreset(presetName)
    if not Config.Presets or not Config.Presets[presetName] then return end

    local presetData = Config.Presets[presetName]
    for key, val in pairs(presetData) do
        CurrentSettings[key] = val
    end

    if presetName == "realism" then
        ApplyGraphicPack(CurrentSettings.realismStyle or "vibrant")
        ShowNotification(_U('realism_enabled'), 'success')
    else
        UnloadActivePackAssets()
        ApplyShadowOptimization(CurrentSettings.shadows)
        if not CurrentSettings.lights then
            RestoreDefaultLights()
        end
        local localizedName = _U('preset_' .. presetName)
        ShowNotification(_U('preset_applied', localizedName), 'success')
    end

    SaveSettings()

    SendNUIMessage({
        action = "updateSettings",
        settings = CurrentSettings
    })
end

RegisterNUICallback("changeOption", function(data, cb)
    local option = data.option
    local boolean = data.boolean

    if option then
        CurrentSettings[option] = boolean

        if option == "shadows" then
            ApplyShadowOptimization(boolean)
        end

        if option == "lights" and not boolean then
            RestoreDefaultLights()
        end

        if option == "realismMaster" then
            if boolean then
                CurrentSettings.realismMaster = true
                CurrentSettings.realismLod = true
                CurrentSettings.realismModels = true
                CurrentSettings.realismLights = true
                CurrentSettings.realismShadows = true

                CurrentSettings.peds = false
                CurrentSettings.vehicles = false
                CurrentSettings.objects = false
                CurrentSettings.particles = false
                CurrentSettings.broken = false
                CurrentSettings.ped = false
                CurrentSettings.unnecessary = false
                CurrentSettings.rain = false
                CurrentSettings.shadows = false
                CurrentSettings.lights = false
                CurrentSettings.lowTexture = false

                ApplyGraphicPack(CurrentSettings.realismStyle or "vibrant")
                ShowNotification(_U('realism_enabled'), 'success')
            else
                CurrentSettings.realismMaster = false
                CurrentSettings.realismLod = false
                CurrentSettings.realismModels = false
                CurrentSettings.realismLights = false
                CurrentSettings.realismShadows = false

                UnloadActivePackAssets()
                ShowNotification(_U('realism_disabled'), 'info')
            end

            SendNUIMessage({
                action = "updateSettings",
                settings = CurrentSettings
            })
        end

        SaveSettings()
    end

    if cb then cb("ok") end
end)

RegisterNUICallback("changeGraphicPack", function(data, cb)
    local packKey = data and (data.pack or data.style)
    if packKey then
        ApplyGraphicPack(packKey)
        local packName = (Config.GraphicPacks and Config.GraphicPacks[packKey] and Config.GraphicPacks[packKey].name) or packKey
        ShowNotification(_U('pack_applied', packName), 'success')
    end
    if cb then cb("ok") end
end)

RegisterNUICallback("changeRealismStyle", function(data, cb)
    local packKey = data and (data.pack or data.style)
    if packKey and packKey ~= currentActivePack then
        ApplyGraphicPack(packKey)
    end
    if cb then cb("ok") end
end)

local isMenuOpen = false

local function StartFpsMeterThread()
    CreateThread(function()
        while isMenuOpen do
            local frames = 0
            local startTime = GetGameTimer()
            while isMenuOpen and (GetGameTimer() - startTime) < 500 do
                frames = frames + 1
                Citizen_Wait(0)
            end
            local elapsed = GetGameTimer() - startTime
            if elapsed > 0 and isMenuOpen then
                local realFps = math.floor((frames * 1000) / elapsed)
                SendNUIMessage({
                    action = "updateFps",
                    fps = realFps
                })
            end
        end
    end)
end

RegisterNUICallback("exitMenu", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    if cb then cb("ok") end
end)

RegisterNUICallback("applyPreset", function(data, cb)
    if data.preset then
        ApplyPreset(data.preset)
    end
    if cb then cb("ok") end
end)

RegisterNUICallback("getLocaleData", function(data, cb)
    local lang = Config.Locale or 'en'
    if cb then
        cb({
            locale = Locales[lang] or Locales['en'] or Locales['tr'],
            lang = lang
        })
    end
end)

local function OpenFpsMenu()
    isMenuOpen = true
    SetNuiFocus(true, true)
    local activeLocale = Locales[Config.Locale] or Locales['en'] or Locales['tr']
    SendNUIMessage({
        action = "openMenu",
        title = Config.MenuTitle or "NextFps",
        settings = CurrentSettings,
        locale = activeLocale,
        lang = Config.Locale or 'en'
    })

    ShowNotification(_U('footer_tip'), 'info')
    StartFpsMeterThread()
end

RegisterCommand(Config.CommandString, function()
    OpenFpsMenu()
end, false)

RegisterNetEvent("fpsBooster:OpenMenu", function()
    ExecuteCommand(Config.CommandString)
end)

if not Config.DisableKeybind then
    RegisterKeyMapping(Config.CommandString, "FPS Booster Menu", "keyboard", Config.Key)
end

exports("setSetting", function(option, value)
    if option and value ~= nil then
        CurrentSettings[option] = value
        if option == "shadows" then ApplyShadowOptimization(value) end
        if option == "lights" and not value then RestoreDefaultLights() end
        SaveSettings()
    end
end)

exports("getSettings", function()
    return CurrentSettings
end)

exports("applyPreset", function(presetName)
    ApplyPreset(presetName)
end)

exports("openMenu", function()
    OpenFpsMenu()
end)
