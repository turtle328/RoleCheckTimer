local ADDON_NAME = ...
local CHECK_SECONDS = 30

RoleCheckTimerDB = RoleCheckTimerDB or {}

local frame = CreateFrame("Frame", "RoleCheckTimerFrame", UIParent, "BackdropTemplate")
frame:SetSize(280, 54)
frame:SetPoint(
    RoleCheckTimerDB.point or "CENTER",
    UIParent,
    RoleCheckTimerDB.relativePoint or "CENTER",
    RoleCheckTimerDB.x or 0,
    RoleCheckTimerDB.y or 180
)
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:Hide()

frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
frame:SetBackdropColor(0.05, 0.05, 0.05, 0.92)
frame:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -7)
title:SetText("Dungeon Queue Ready")

local statusBar = CreateFrame("StatusBar", nil, frame)
statusBar:SetPoint("BOTTOMLEFT", 10, 10)
statusBar:SetPoint("BOTTOMRIGHT", -10, 10)
statusBar:SetHeight(20)
statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
statusBar:SetMinMaxValues(0, CHECK_SECONDS)
statusBar:SetValue(CHECK_SECONDS)

local barBackground = statusBar:CreateTexture(nil, "BACKGROUND")
barBackground:SetAllPoints()
barBackground:SetColorTexture(0.12, 0.12, 0.12, 1)

local countdown = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
countdown:SetPoint("CENTER")
countdown:SetText("30.0")

local endTime
local active = false

local function SavePosition()
    local point, _, relativePoint, x, y = frame:GetPoint()
    RoleCheckTimerDB.point = point
    RoleCheckTimerDB.relativePoint = relativePoint
    RoleCheckTimerDB.x = x
    RoleCheckTimerDB.y = y
end

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

local function StopTimer()
    active = false
    endTime = nil
    frame:SetScript("OnUpdate", nil)
    frame:Hide()
end

local function StartTimer(label)
    active = true
    endTime = GetTime() + CHECK_SECONDS
    title:SetText(label or "Dungeon Queue Ready")
    statusBar:SetMinMaxValues(0, CHECK_SECONDS)
    statusBar:SetValue(CHECK_SECONDS)
    countdown:SetText("30.0")
    frame:Show()

    frame:SetScript("OnUpdate", function()
        if not active or not endTime then
            return
        end

        local remaining = math.max(0, endTime - GetTime())
        statusBar:SetValue(remaining)
        countdown:SetFormattedText("%.1f", remaining)

        if remaining <= 0 then
            StopTimer()
        end
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")

-- Fired when the matched dungeon invite with Accept/Decline appears.
events:RegisterEvent("LFG_PROPOSAL_SHOW")
events:RegisterEvent("LFG_PROPOSAL_DONE")
events:RegisterEvent("LFG_PROPOSAL_FAILED")
events:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")

-- Retain support for earlier LFG stages.
events:RegisterEvent("LFG_READY_CHECK_SHOW")
events:RegisterEvent("LFG_READY_CHECK_HIDE")
events:RegisterEvent("LFG_READY_CHECK_DECLINED")
events:RegisterEvent("LFG_ROLE_CHECK_SHOW")
events:RegisterEvent("LFG_ROLE_CHECK_HIDE")
events:RegisterEvent("LFG_ROLE_CHECK_DECLINED")

events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end
        RoleCheckTimerDB = RoleCheckTimerDB or {}
        return
    end

    if event == "LFG_PROPOSAL_SHOW" then
        StartTimer("Dungeon Queue Ready")
    elseif event == "LFG_READY_CHECK_SHOW" then
        StartTimer("Dungeon Ready Check")
    elseif event == "LFG_ROLE_CHECK_SHOW" then
        StartTimer("Dungeon Role Check")
    elseif event == "LFG_PROPOSAL_DONE"
        or event == "LFG_PROPOSAL_FAILED"
        or event == "LFG_PROPOSAL_SUCCEEDED"
        or event == "LFG_READY_CHECK_HIDE"
        or event == "LFG_READY_CHECK_DECLINED"
        or event == "LFG_ROLE_CHECK_HIDE"
        or event == "LFG_ROLE_CHECK_DECLINED" then
        StopTimer()
    end
end)

SLASH_ROLECHECKTIMER1 = "/rct"
SlashCmdList.ROLECHECKTIMER = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "test" then
        StartTimer("Dungeon Queue Ready (Test)")
    elseif msg == "stop" then
        StopTimer()
    elseif msg == "reset" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
        SavePosition()
        print("|cff33ff99Role Check Timer:|r position reset.")
    else
        print("|cff33ff99Role Check Timer commands:|r")
        print("/rct test - show a 30-second test timer")
        print("/rct stop - hide the timer")
        print("/rct reset - reset its position")
        print("Drag the timer with the left mouse button while visible.")
    end
end
