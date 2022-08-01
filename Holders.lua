--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CDTL2:CreateHolders()
	local d = {}
	
	-- ICON HOLDING
	d["fName"] = "CDTL2_Active_Icon_Holding"
	d["posX"] = 500
	d["posY"] = -300
	d["anchor"] = "TOPLEFT"
	d["sizeX"] = 150
	d["sizeY"] = 25
	d["dName"] = "Active Icon Holding"
	d["type"] = "ICON"
	private.CreateHolder(d)
	
	-- BAR HOLDING
	d["fName"] = "CDTL2_Bar_Holding"
	d["posX"] = 300
	d["posY"] = -300
	d["anchor"] = "TOPLEFT"
	d["sizeX"] = 170
	d["sizeY"] = 25
	d["dName"] = "Bar Holding"
	d["type"] = "BAR"
	private.CreateHolder(d)
	
	-- INACTIVE ICON HOLDING
	d["fName"] = "CDTL2_Inactive_Icon_Holding"
	d["posX"] = 0
	d["posY"] = -300
	d["anchor"] = "TOP"
	d["sizeX"] = 150
	d["sizeY"] = 25
	d["dName"] = "Inactive Icon Holding"
	d["type"] = "ICON"
	private.CreateHolder(d)
	
	-- OFFENSIVE ICON HOLDING
	d["fName"] = "CDTL2_Offensive_Icon_Holding"
	d["posX"] = -500
	d["posY"] = -300
	d["anchor"] = "TOPRIGHT"
	d["sizeX"] = 170
	d["sizeY"] = 25
	d["dName"] = "Offensive Icon Holding"
	d["type"] = "BAR"
	private.CreateHolder(d)
	
	-- OFFENSIVE BAR HOLDING
	d["fName"] = "CDTL2_Offensive_Bar_Holding"
	d["posX"] = -300
	d["posY"] = -300
	d["anchor"] = "TOPRIGHT"
	d["sizeX"] = 170
	d["sizeY"] = 25
	d["dName"] = "Offensive Bar Holding"
	d["type"] = "BAR"
	private.CreateHolder(d)
end

private.CreateHolder = function(d)
	local f = CreateFrame("Frame", d["fName"], UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f.type = d["type"]
	f:SetPoint("CENTER", UIParent, d["anchor"], d["posX"], d["posY"])
	f:SetSize(d["sizeX"], d["sizeY"])
	
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 0.1, 0.1, 0.1, 0.5 )
	
	f:HookScript("OnUpdate", function(self,elapsed)
		if CDTL2.db.profile.global["debugMode"] then
			private.HolderUpdate(f, elapsed)
		end
	end)
		
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText(d["dName"])
	f.text:SetPoint("CENTER", 0, 0)
	
	if not CDTL2.db.profile.global["debugMode"] then
		f:SetAlpha(0)
	end
	
	table.insert(CDTL2.holders, f)
end

private.HolderUpdate = function(f, elapsed)
	local s = CDTL2.db.profile.holders
	local children = { f:GetChildren() }
	local validChildren = {}
	
	local count = 0
	for _, child in ipairs(children) do
		if child.valid then
			count = count + 1
			table.insert(validChildren, child)
		end
	end
	
	for k, child in ipairs(validChildren) do
		local yOffset = (k - 1) * child:GetHeight() + (k - 1 * 5) + child:GetHeight()
		child:ClearAllPoints()
		child:SetPoint("CENTER", 0, -yOffset)
	end
end