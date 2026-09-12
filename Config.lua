Config = {}

Config.MenuTitle = 'NextFps'

Config.Locale = 'tr'

Config.Key = 'F11'
Config.DisableKeybind = false
Config.CommandString = 'fps'

Config.Notify = true
Config.NotifySystem = 'auto'

-- Varsayılan Başlangıç Ayarları
Config.GlobalSettings = {
    ["peds"] = false,
    ["vehicles"] = false,
    ["objects"] = false,
    ["particles"] = false,
    ["broken"] = false,
    ["ped"] = false,
    ["unnecessary"] = false,
    ["rain"] = false,
    ["shadows"] = false,
    ["lights"] = false,
    ["lowTexture"] = false,
    ["realismMaster"] = false,
    ["realismStyle"] = "vibrant",
    ["realismLod"] = false,
    ["realismModels"] = false,
    ["realismLights"] = false,
    ["realismShadows"] = false,
}

-- Hazır FPS Seçimleri
Config.Presets = {
    ['ultra'] = {
        ["peds"] = true,
        ["vehicles"] = true,
        ["objects"] = true,
        ["particles"] = true,
        ["broken"] = true,
        ["ped"] = true,
        ["unnecessary"] = true,
        ["rain"] = true,
        ["shadows"] = true,
        ["lights"] = true,
        ["lowTexture"] = true,
        ["realismMaster"] = false,
        ["realismLod"] = false,
        ["realismModels"] = false,
        ["realismLights"] = false,
        ["realismShadows"] = false,
    },
    ['balanced'] = {
        ["peds"] = true,
        ["vehicles"] = true,
        ["objects"] = false,
        ["particles"] = true,
        ["broken"] = true,
        ["ped"] = true,
        ["unnecessary"] = true,
        ["rain"] = false,
        ["shadows"] = true,
        ["lights"] = true,
        ["lowTexture"] = false,
        ["realismMaster"] = false,
        ["realismLod"] = false,
        ["realismModels"] = false,
        ["realismLights"] = false,
        ["realismShadows"] = false,
    },
    ['default'] = {
        ["peds"] = false,
        ["vehicles"] = false,
        ["objects"] = false,
        ["particles"] = false,
        ["broken"] = false,
        ["ped"] = false,
        ["unnecessary"] = false,
        ["rain"] = false,
        ["shadows"] = false,
        ["lights"] = false,
        ["lowTexture"] = false,
        ["realismMaster"] = false,
        ["realismLod"] = false,
        ["realismModels"] = false,
        ["realismLights"] = false,
        ["realismShadows"] = false,
    },
    ['realism'] = {
        ["peds"] = false,
        ["vehicles"] = false,
        ["objects"] = false,
        ["particles"] = false,
        ["broken"] = false,
        ["ped"] = false,
        ["unnecessary"] = false,
        ["rain"] = false,
        ["shadows"] = false,
        ["lights"] = false,
        ["lowTexture"] = false,
        ["realismMaster"] = true,
        ["realismStyle"] = "vibrant",
        ["realismLod"] = true,
        ["realismModels"] = true,
        ["realismLights"] = true,
        ["realismShadows"] = true,
    }
}

Config.GraphicPacks = {
    ['vibrant'] = {
        name = "Reshade Pack",
        timecycle = "rply_saturation",
        timecycleStrength = 1.35,
        extraTimecycle = "cinema",
        extraStrength = 0.70,
        lodScale = 4.0,
        shadowBounds = 5.0,
        lightsCutoff = 500.0,
        modelSwaps = {
            { original = "prop_tree_birch_01", replacement = "prop_tree_cedar_01" },
            { original = "prop_tree_eng_oak_01", replacement = "prop_tree_pine_01" },
            { original = "prop_tree_stump_01", replacement = "prop_tree_m_birch_01" },
            { original = "prop_bush_lrg_01", replacement = "prop_bush_dead_02" },
        }
    },
    ['cinematic'] = {
        name = "Sinematik Pack",
        timecycle = "cinema",
        timecycleStrength = 1.25,
        extraTimecycle = "rply_saturation",
        extraStrength = 0.85,
        lodScale = 4.0,
        shadowBounds = 5.0,
        lightsCutoff = 500.0,
        modelSwaps = {
            { original = "prop_streetlight_01a", replacement = "prop_streetlight_03" },
            { original = "prop_traffic_01a", replacement = "prop_traffic_03a" },
        }
    },
    ['natural'] = {
        name = "QuantV Pack",
        timecycle = "MP_Powerplay_blend",
        timecycleStrength = 1.15,
        extraTimecycle = "rply_saturation",
        extraStrength = 0.60,
        lodScale = 4.0,
        shadowBounds = 5.0,
        lightsCutoff = 500.0,
        modelSwaps = {
            { original = "prop_tree_birch_01", replacement = "prop_tree_cedar_01" },
            { original = "prop_tree_m_birch_01", replacement = "prop_tree_pine_02" },
        }
    }
}