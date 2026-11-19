local addonName = ...
local nameplates = _G.EllesmereNameplates_NS
if not EllesmereUI or not EllesmereUI.IS_FOREVER or not nameplates
    or type(nameplates.plates) ~= "table"
    or type(nameplates._scaleAnim) ~= "table"
    or type(nameplates._ScaleDriverShow) ~= "function"
    or type(UnitThreatSituation) ~= "function" then
    return
end

local minScale, maxScale = 50, 200
local defaults = {
    enabled = true,
    secureAggro = 75,
    losingAggro = 115,
    noAggro = 130,
}
local scaleKeyByThreat = {
    [3] = "secureAggro",
    [2] = "losingAggro",
    [1] = "noAggro",
    [0] = "noAggro",
}
local scaleOptions = {
    { key = "secureAggro", label = "Secure Aggro (%)", tooltip = "Size while you securely hold aggro." },
    { key = "losingAggro", label = "Losing Aggro (%)", tooltip = "Size while you still hold aggro and another player has higher threat." },
    { key = "noAggro", label = "No Aggro (%)", tooltip = "Size while an enemy with reported threat has aggro on someone else." },
}

local settings
local baseScales = setmetatable({}, { __mode = "k" })

local function normalizeScale(key, value)
    if type(value) ~= "number" or value ~= value then
        return defaults[key]
    end
    return math.max(minScale, math.min(maxScale, math.floor(value + 0.5)))
end

local function getThreatScale(unit)
    if not settings or not settings.enabled or not UnitAffectingCombat(unit) or UnitIsDeadOrGhost(unit) then
        return 1
    end

    local threat = UnitThreatSituation("player", unit)
    if issecretvalue and issecretvalue(threat) then
        return 1
    end

    local key = scaleKeyByThreat[threat]
    return key and settings[key] / 100 or 1
end

local function updateScale(plate, base)
    if not plate.unit or type(base) ~= "number" or type(plate._curScale) ~= "number" then
        return
    end

    local destination = base * getThreatScale(plate.unit)
    if plate._destScale == destination then
        return
    end

    -- Let EllesmereUI ease to the adjusted destination and sync its lifted cast bar.
    plate._destScale = destination
    nameplates._scaleAnim[plate] = true
    nameplates._ScaleDriverShow()
end

local function onHostScale(plate)
    -- ApplyScale has just recomputed the unmodified target, cast and mob-type scale.
    -- It also runs when this pooled frame is assigned to another unit.
    local base = plate._destScale
    baseScales[plate] = base
    updateScale(plate, base)
end

local function refreshPlate(plate)
    if not plate or not plate.unit then
        return
    end

    local base = baseScales[plate]
    if not base then
        if type(plate.ApplyScale) ~= "function" or type(plate._destScale) ~= "number"
            or type(plate._curScale) ~= "number" then
            return
        end
        hooksecurefunc(plate, "ApplyScale", onHostScale)
        base = plate._destScale
        baseScales[plate] = base
    end

    updateScale(plate, base)
end

local pendingUnits = {}
local frame = CreateFrame("Frame")
frame:Hide()

local function queueAllPlates()
    for unit in pairs(nameplates.plates) do
        pendingUnits[unit] = true
    end
    frame:Show()
end

local function setOption(key, value)
    if settings[key] ~= value then
        settings[key] = value
        queueAllPlates()
    end
end

local function buildOptions(_, parent, y)
    local widgets = EllesmereUI.Widgets
    local _, height = widgets:SectionHeader(parent, "THREAT SCALING", y)
    y = y - height
    _, height = widgets:Toggle(parent, "Enable Threat Scaling", y,
        function() return settings.enabled end,
        function(value) setOption("enabled", value) end,
        "Scale enemy nameplates based on your aggro.")
    y = y - height
    for _, option in ipairs(scaleOptions) do
        local key = option.key
        _, height = widgets:Slider(parent, option.label, y, minScale, maxScale, 1,
            function() return settings[key] end,
            function(value) setOption(key, normalizeScale(key, value)) end,
            option.tooltip)
        y = y - height
    end
    return math.abs(y)
end

local function initialize()
    if type(EllesmereThreatScaleDB) ~= "table" then
        EllesmereThreatScaleDB = {}
    end
    settings = EllesmereThreatScaleDB
    if type(settings.enabled) ~= "boolean" then
        settings.enabled = defaults.enabled
    end
    for _, option in ipairs(scaleOptions) do
        settings[option.key] = normalizeScale(option.key, settings[option.key])
    end

    if EllesmereUI.RegisterPlugin then
        EllesmereUI.RegisterPlugin(addonName, {
            label = "Threat Scale",
            modules = {
                {
                    key = "Nameplates",
                    title = "Nameplates",
                    description = "Scale enemy nameplates by your aggro. 100% uses the current EllesmereUI size.",
                    pages = { "Threat Scaling" },
                    buildPage = buildOptions,
                    onReset = function()
                        for key, value in pairs(defaults) do
                            settings[key] = value
                        end
                        queueAllPlates()
                    end,
                },
            },
        })
    end
    queueAllPlates()
end

frame:SetScript("OnUpdate", function(self)
    self:Hide()
    -- The host may register or recycle the plate during the same event.
    for unit in pairs(pendingUnits) do
        pendingUnits[unit] = nil
        refreshPlate(nameplates.plates[unit])
    end
end)

frame:SetScript("OnEvent", function(self, event, unit)
    if event == "ADDON_LOADED" then
        if unit == addonName then
            self:UnregisterEvent("ADDON_LOADED")
            initialize()
        end
        return
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        queueAllPlates()
    elseif unit and (event == "NAME_PLATE_UNIT_ADDED" or nameplates.plates[unit]) then
        pendingUnits[unit] = true
        self:Show()
    end
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UNIT_FLAGS")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
