--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CDTL2:AddUsedBy(type, id, guid)
	for _, data in pairs(CDTL2.db.profile.tables[type]) do
		if data["id"] == id then
			table.insert(data["usedBy"], guid)
		end
	end
end

function CDTL2:AuraExists(unit, aura)
	for i = 1, 40, 1 do
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HELPFUL")
		
		if name then
			if aura == name then
				local s = {
					id = spellId,
					bCD = duration * 1000,
					name = name,
					type = "buffs",
					icon = icon,
					stacks = count,
					endTime = expirationTime,
				}
				
				return s
			end
		end
	end
	
	for i = 1, 40, 1 do
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HARMFUL")
		
		if name then
			if aura == name then
				local s = {
					id = spellId,
					bCD = duration * 1000,
					name = name,
					type = "buffs",
					icon = icon,
					stacks = count,
					endTime = expirationTime,
				}
				
				return s
			end
		end
	end
	
	return nil
end

function CDTL2:Autohide(f, s)
	local fAlpha = 1
	if s then
		fAlpha = s["alpha"]
	end
	
	--CDTL2:Print(fAlpha)
	
	if CDTL2.db.profile.global["autohide"] and not CDTL2.db.profile.global["unlockFrames"] and not CDTL2.db.profile.global["debugMode"] then
		if f.overrideAutohide then
			--f:SetAlpha(1)
			f:SetAlpha(fAlpha)
		else
			if f.childCount == 0 or f.forceHide then
			--if f.currentCount == 0 or f.forceHide then
				if f:GetAlpha() ~= 0 then
					if f.animateOut then
						if not f.animateOut:IsPlaying() then
							f.animateOut:Play()
						end
					else
						f:SetAlpha(0)
					end
				end
			else
				--if f:GetAlpha() ~= 1 then
				if f:GetAlpha() ~= fAlpha then
					--f:SetAlpha(1)
					
					if f.animateIn then
						if not f.animateIn:IsPlaying() then
							f.animateIn:Play()
						end
					else
						--f:SetAlpha(1)
						f:SetAlpha(fAlpha)
					end
				end
			end
		end
	else
		--if f:GetAlpha() ~= 1 then
		if f:GetAlpha() ~= fAlpha then
			--f:SetAlpha(1)
			f:SetAlpha(fAlpha)
		end
	end
end

function CDTL2:CheckEdgeCases(spellName)
	-- Vanish should also spawn a Stealth icon/bar
	if spellName == "Vanish" then
		local s = CDTL2:GetSpellSettings("Stealth", "spells")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown("Stealth", "spells")
				if ef then
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
				else
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						
						if CDTL2:IsUsedBy("spells", s["id"]) then
							--CDTL2:Print("USEDBY MATCH: "..s["id"])
						else
							--CDTL2:Print("NEW USEDBY: "..s["id"])
							CDTL2:AddUsedBy("spells", s["id"], CDTL2.player["guid"])
						end
					end
				end
			end
		else
			s = CDTL2:GetSpellData(0, "Stealth")
			if s then
				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["spells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["spells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["spells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["spells"]["showByDefault"]
				s["highlight"] = false
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				
				local link, _ = GetSpellLink(s["id"])
				s["link"] = link
				
				if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 < CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end
				
				table.insert(CDTL2.db.profile.tables["spells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
					end
				end
			end
		end
	end
	
	if spellName == "Shadowmeld" then
		local s = CDTL2:GetSpellSettings("Shadowmeld", "spells")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown("Shadowmeld", "spells")
				if ef then
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
				else
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						
						if CDTL2:IsUsedBy("spells", s["id"]) then
							--CDTL2:Print("USEDBY MATCH: "..s["id"])
						else
							--CDTL2:Print("NEW USEDBY: "..s["id"])
							CDTL2:AddUsedBy("spells", s["id"], CDTL2.player["guid"])
						end
					end
				end
			end
		else
			s = CDTL2:GetSpellData(0, "Shadowmeld")
			if s then
				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["spells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["spells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["spells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["spells"]["showByDefault"]
				s["highlight"] = false
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				
				local link, _ = GetSpellLink(s["id"])
				s["link"] = link
				
				if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 < CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end
				
				table.insert(CDTL2.db.profile.tables["spells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
					end
				end
			end
		end
	end
end

function CDTL2:ConvertTime(raw, style)
	local t = ""
	
	if style == "XhYmZs" then
		local h = math.floor(raw / 3600)
		raw = raw % 3600
		local m = math.floor(raw / 60)
		raw = raw % 60
		local s = math.floor(raw / 1)
		raw = raw % 1
		
		if s > 0 then
			t = s.."s"
		end
		if m > 0 then
			t = m.."m"..t
		end
		if h > 0 then
			t = h.."h"..t
		end
	elseif style == "H:MM:SS" then
		local h = math.floor(raw / 3600)
		raw = raw % 3600
		local m = math.floor(raw / 60)
		raw = raw % 60
		local s = math.floor(raw / 1)
		raw = raw % 1
		
		if h > 0 then
			t = h..":"..string.format("%02d", m)..":"..string.format("%02d", s)
		else
			if m > 0 then
				t = m..":"..string.format("%02d", s)
			else
				t = s
			end
		end		
	else
		if raw > 9.9 then
			t = tonumber(string.format("%.0f", raw))
		else
			t = tonumber(string.format("%.1f", raw))
		end
	end
	
	return t
end

function CDTL2:GetCharacterData()
	if CDTL2.player["class"] == nil then
		local playerGUID = UnitGUID("player")
		local _, engClass, _, engRace, gender, name, server = GetPlayerInfoByGUID(playerGUID)
		
		if engClass ~= nil then
			CDTL2.player = {
				guid = playerGUID,
				name = name,
				race = engRace,
				class = engClass,
				classPower = CDTL2:GetPlayerPower(engClass),
			}
		
			CDTL2.spellData = CDTL2:GetAllSpellData(engClass, engRace)
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("PLAYER: "..CDTL2.player["name"].." - "..CDTL2.player["race"].." - "..CDTL2.player["class"].." - "..CDTL2.player["classPower"])
			end
		end
	end
end

function CDTL2:GetItemSpell(id)
	-- EQUIPPED ITEMS
	for i = 0, 23, 1 do
		local itemId = GetInventoryItemID("player", i)
		local spellName, spellID = GetItemSpell(itemId)
		
		if spellID == id then
			local start, duration, enabled = GetItemCooldown(itemId)
			
			--if duration < 1.51 then
				--CDTL2:Print("FOUND-EQUIPPED: "..itemId.." - TOO LOW!!!")
			--else
				--CDTL2:Print("FOUND-EQUIPPED: "..itemId.." - Lower!")
			--end
			
			local s = {}
				s["name"] = spellName
				s["id"] = spellID
				s["bCD"] = 0
				s["itemID"] = itemId
				s["lane"] = CDTL2.db.profile.global["items"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["items"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["items"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["items"]["showByDefault"]
				s["highlight"] = false
				s["pinned"] = false
				
			local item = Item:CreateFromItemID(itemId)
			item:ContinueOnItemLoad(function()
				s["itemName"] = item:GetItemName()
				s["icon"] = item:GetItemIcon()
				s["link"] = item:GetItemLink()
			end)

			return s
		end
	end
	
	-- INVENTORY
	for i = 0, 4, 1 do
		local numberOfSlots = GetContainerNumSlots(i)
		for x = 0, numberOfSlots, 1 do
			local itemId = GetContainerItemID(i, x)
			local spellName, spellID = GetItemSpell(itemId)
			
			if spellID == id then
				local s = {}
					s["name"] = spellName
					s["id"] = spellID
					s["bCD"] = 0
					s["itemID"] = itemId
					s["lane"] = 1
					s["barFrame"] = 1
					s["readyFrame"] = 1
					s["enabled"] = true
					s["highlight"] = false
					s["pinned"] = false
					
				local item = Item:CreateFromItemID(itemId)
				item:ContinueOnItemLoad(function()
					s["itemName"] = item:GetItemName()
					s["icon"] = item:GetItemIcon()
					s["link"] = item:GetItemLink()
				end)
				
				return s
			end
			
		end
	end
	
	return nil
end

function CDTL2:GetPlayerPower(class)
	if class == "ROGUE" then
		return Enum.PowerType.Energy
	elseif class == "DEATHKNIGHT" then
		return Enum.PowerType.RunicPower
	elseif class == "WARRIOR" then
		return Enum.PowerType.Rage
	elseif class == "DRUID" then
		local form = GetShapeshiftForm()
		if form == 1 then
			return Enum.PowerType.Rage
		elseif form == 3 then
			return Enum.PowerType.Energy
		else
			return Enum.PowerType.Mana
		end
	else
		return Enum.PowerType.Mana
	end
end

function CDTL2:GetReadableTime(t)
	local readableTimeLeft = t

	if t > 60 then
		readableTimeLeft = math.floor(t*math.pow(10,0)+0.5) / math.pow(10,0)
		
		local minutes = tostring(math.floor(readableTimeLeft / 60))
		local seconds = readableTimeLeft % 60
		
		if seconds >= 10 then
			seconds = tostring(seconds)
		elseif seconds > 0 then
			seconds = tostring("0"..seconds)
		else
			seconds = "00"
		end
		
		readableTimeLeft = minutes..":"..seconds
		
	elseif t > 10 then
		readableTimeLeft = tonumber(string.format("%.0f", readableTimeLeft))
	else
		readableTimeLeft = tonumber(string.format("%.1f", readableTimeLeft))
		if readableTimeLeft == math.floor(readableTimeLeft) then
			readableTimeLeft = readableTimeLeft..".0"
		end
	end
	
	return readableTimeLeft
end

function CDTL2:GetShortTime(t)
	local readableTimeLeft = t
	
	if t >= 60 then
		local minutes = tostring(math.floor(t / 60))
		local seconds = readableTimeLeft % 60
		
		readableTimeLeft = minutes.."m"
		
		if seconds ~= 0 then
			readableTimeLeft = readableTimeLeft..seconds.."s"
		end
	else
		readableTimeLeft = tonumber(string.format("%.0f", readableTimeLeft)).."s"
	end
	
	return readableTimeLeft
end

function CDTL2:GetExistingCooldown(name, type, targetID)
	for _, e in pairs(CDTL2.cooldowns) do
		if e.data["name"] == name and e.data["type"] == type then
			if targetID then
				if targetID == e.data["targetID"] then
					return e
				end
			else
				return e
			end
		end
	end
	
	return nil
end

function CDTL2:GetSpellSettings(name, type, id)
	for _, e in pairs(CDTL2.db.profile.tables[type]) do
		if id then
			if e["id"] == id then
				return e
			end
		else
			if e["name"] == name then
				return e
			end
		end
	end
	
	return nil
end

function CDTL2:GetSpellName(id)
	for _, spell in pairs(CDTL2.spellData) do
		if spell["id"] == id then
			return spell["name"]
		end
	end
	
	return nil
end

function CDTL2:GetUID()
	CDTL2.cdUID = CDTL2.cdUID + 1
	return CDTL2.cdUID
end

function CDTL2:GetValidChildren(f)
	local children = { f:GetChildren() }
	local validChildren = {}
	
	local count = 0
	for _, child in ipairs(children) do
		if child.uid then
			count = count + 1
			table.insert(validChildren, child)
		end
	end
	
	return validChildren
end

function CDTL2:IsUsedBy(type, id)
	if CDTL2.player["class"] == nil then
		CDTL2:GetCharacterData()
	end

	for _, spell in pairs(CDTL2.db.profile.tables[type]) do
		if spell["id"] == id then
			for _, data in pairs(spell["usedBy"]) do
				if CDTL2.player["guid"] == data then
					return true
				end
			end
		end
	end
	
	return false
end

function CDTL2:IsValidItem(itemID)
	local _, itemType, itemSubType, _, _, classID, subclassID = GetItemInfoInstant(itemID)
	
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:Print("ITEM: "..itemType.." - "..itemSubType)
	end
	
	-- CONSUMABLE
	if classID == 0 then
		if
			subclassID == 0 or	-- Generic
			subclassID == 1 or	-- Potion
			subclassID == 2 	-- Elixir
		then
			return true
		end
	end
	
	-- WEAPON
	if classID == 2 then
		return true
	end
	
	-- ARMOR
	if classID == 4 then
		return true
	end
	
	-- QUEST
	if classID == 12 then
		return true
	end
	
	-- MISCELLANEOUS
	if classID == 15 then
		if
			subclassID == 4		-- Other
		then
			return true
		end
	end
	
	return false
end

function CDTL2:LoadFilterList(type)
	local list = {}
	
	for _, data in pairs(CDTL2.db.profile.tables[type]) do
		for _, guid in pairs(data["usedBy"]) do
			if CDTL2:IsUsedBy(type, data["id"]) then
				if CDTL2.db.profile.global["hideIgnored"] then
					if not data["ignored"] then
						list[data["name"]] = data["name"]
					end
				else
					list[data["name"]] = data["name"]
				end
			end
		end
	end
	
	return list
end

function CDTL2:RecycleOffensiveCD()
	for k, child in ipairs(CDTL2.cooldowns) do
		if child.data["type"] == "offensives" then
			if child.data["currentCD"] < 0 then
				return child
			end
		end
	end
	
	return nil
end

function CDTL2:RefreshConfig()	
	for k, f in pairs(CDTL2.readyFrames) do
		CDTL2:RefreshReady(k)
	end
	
	for k, f in pairs(CDTL2.barFrames) do
		CDTL2:RefreshBarFrame(k)
	end
	
	for k, f in pairs(CDTL2.lanes) do
		CDTL2:RefreshLane(k)
	end
	
	CDTL2:RefreshAllIcons()
	CDTL2:RefreshAllBars()
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2", CDTL2:GetMainOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Lanes", CDTL2:GetLaneOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Ready", CDTL2:GetReadyOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2BarFrames", CDTL2:GetBarFrameOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Filters", CDTL2:GetFilterOptions())
	
	if CDTL2.db.profile.global["unlockFrames"] then
		CDTL2.unlockFrame:Show()
	end
end

function CDTL2:RemoveHighlights(f, s)
	if f.hl.agBorderPulse then
		f.hl.agBorderPulse:Stop()
	end
	
	if f.hl.agPulse then
		f.hl.agPulse:Stop()
	end
	
	ActionButton_HideOverlayGlow(f)
	f.hl:SetBackdropBorderColor(
		s["icons"]["highlight"]["border"]["color"]["r"],
		s["icons"]["highlight"]["border"]["color"]["g"],
		s["icons"]["highlight"]["border"]["color"]["b"],
		0
	)
	f.hl.tx:SetColorTexture( 1, 1, 1, 0 )
end

function CDTL2:ScanSharedSpellCooldown(initialName, initialDuration)
	local sd = CDTL2:GetAllSpellData(CDTL2.player["class"], CDTL2.player["race"])
	
	-- SPELLS
	for _, spell in pairs(sd) do
		if spell["name"] ~= initialName then
			local start, duration, enabled, _ = GetSpellCooldown(spell["id"])
			local difference = math.abs(initialDuration - duration)
			
			if difference < 0.2 then
				if duration > 1.5 then
					local ef = CDTL2:GetExistingCooldown(spell["name"], "spells")
					if ef then
						CDTL2:SendToLane(ef)
						CDTL2:SendToBarFrame(ef)
					else
						local s = CDTL2:GetSpellSettings(spell["name"], "spells")
						if s then
							if not s["ignored"] then
								CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
								
								if not CDTL2:IsUsedBy("spells", spellID) then
									CDTL2:AddUsedBy("spells", spellID, CDTL2.player["guid"])
								end
							end
						else
							local _, _, icon, _, _, _, _ = GetSpellInfo(spell["id"])
							
							local s = {
								id = spell["id"],
								bCD = duration,
								name = spell["name"],
								type = "spells",
								icon = icon,
								lane = CDTL2.db.profile.global["spells"]["defaultLane"],
								barFrame = CDTL2.db.profile.global["spells"]["defaultBar"],
								readyFrame = CDTL2.db.profile.global["spells"]["defaultReady"],
								enabled = CDTL2.db.profile.global["spells"]["showByDefault"],
								highlight = false,
								pinned = false,
								usedBy = { CDTL2.player["guid"] },
							}
							
							if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 < CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
								s["ignored"] = false
							else
								s["ignored"] = true
							end
							
							table.insert(CDTL2.db.profile.tables["spells"], s)
							
							if not s["ignored"] then
								CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
							end
						end
					end
				end
			end
		end
	end
end

function CDTL2:ScanCurrentCooldowns(class, race)
	local sd = CDTL2:GetAllSpellData(class, race)
	
	-- SPELLS
	for _, spell in pairs(sd) do
		local start, duration, enabled, _ = GetSpellCooldown(spell["id"])
		
		if duration > 1.5 then
			if CDTL2:GetExistingCooldown(spell["name"], "spells") then
				--CDTL2:Print("    EXISTING FOUND: "..spell["id"].." - "..spell["name"])
			else
				local s = CDTL2:GetSpellSettings(spell["name"], "spells")
				if s then
					if not s["ignored"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						
						if not CDTL2:IsUsedBy("spells", spellID) then
							CDTL2:AddUsedBy("spells", spellID, CDTL2.player["guid"])
						end
					end
				else
					local _, _, icon, _, _, _, _ = GetSpellInfo(spell["id"])
					
					local s = {
						id = spell["id"],
						bCD = duration,
						name = spell["name"],
						type = "spells",
						icon = icon,
						lane = CDTL2.db.profile.global["spells"]["defaultLane"],
						barFrame = CDTL2.db.profile.global["spells"]["defaultBar"],
						readyFrame = CDTL2.db.profile.global["spells"]["defaultReady"],
						enabled = CDTL2.db.profile.global["spells"]["showByDefault"],
						highlight = false,
						pinned = false,
						usedBy = { CDTL2.player["guid"] },
					}
					
					if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 < CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
						s["ignored"] = false
					else
						s["ignored"] = true
					end
					
					table.insert(CDTL2.db.profile.tables["spells"], s)
					
					if not s["ignored"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
					end
				end
			end
		end
	end
	
	-- ITEMS EQUIPPED
	for i = 0, 23, 1 do
		local itemId = GetInventoryItemID("player", i)
		local spellName, spellID = GetItemSpell(itemId)
		
		if spellName then
			if itemID then
				if CDTL2:IsValidItem(itemID) then
					local start, duration, enabled = GetItemCooldown(itemId)
					
					if duration > 1.5 then
						if CDTL2:GetExistingCooldown(spellName, "items") then
							--CDTL2:Print("    EXISTING FOUND: "..spell["id"].." - "..spell["name"])
						else
							local s = CDTL2:GetSpellSettings(spellName, "items")
							if s then
								if not s["ignored"] then
									CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
									
									if not CDTL2:IsUsedBy("items", spellID) then
										CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
									end
								end
							else
								s = {}
									s["name"] = spellName
									s["id"] = spellID
									s["bCD"] = duration * 1000
									s["itemID"] = itemId
									s["lane"] = CDTL2.db.profile.global["items"]["defaultLane"]
									s["barFrame"] = CDTL2.db.profile.global["items"]["defaultBar"]
									s["readyFrame"] = CDTL2.db.profile.global["items"]["defaultReady"]
									s["enabled"] = CDTL2.db.profile.global["items"]["showByDefault"]
									s["highlight"] = false
									s["pinned"] = false
									s["usedBy"] = { CDTL2.player["guid"] }
									
								local item = Item:CreateFromItemID(itemId)
								item:ContinueOnItemLoad(function()
									s["itemName"] = item:GetItemName()
									s["icon"] = item:GetItemIcon()
									s["link"] = item:GetItemLink()
								end)
								
								if duration > 3 and duration < CDTL2.db.profile.global["items"]["ignoreThreshold"] then
									s["ignored"] = false
								else
									s["ignored"] = true
								end
								
								table.insert(CDTL2.db.profile.tables["items"], s)
								
								if not s["ignored"] then
									CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- ITEMS BAGS
	for i = 0, 4, 1 do
		local numberOfSlots = GetContainerNumSlots(i)
		for x = 0, numberOfSlots, 1 do
			local itemId = GetContainerItemID(i, x)
			local spellName, spellID = GetItemSpell(itemId)
			
			if spellName then
				if itemID then
					if CDTL2:IsValidItem(itemId) then
						local start, duration, enabled = GetItemCooldown(itemId)
						
						if duration > 1.5 then
							if CDTL2:GetExistingCooldown(spellName, "items") then
								--CDTL2:Print("    EXISTING FOUND: "..spell["id"].." - "..spell["name"])
							else
								local s = CDTL2:GetSpellSettings(spellName, "items")
								if s then
									if not s["ignored"] then
										CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
										
										if not CDTL2:IsUsedBy("items", spellID) then
											CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
										end
									end
								else
									s = {}
										s["name"] = spellName
										s["id"] = spellID
										s["bCD"] = duration * 1000
										s["itemID"] = itemId
										s["lane"] = CDTL2.db.profile.global["items"]["defaultLane"]
										s["barFrame"] = CDTL2.db.profile.global["items"]["defaultBar"]
										s["readyFrame"] = CDTL2.db.profile.global["items"]["defaultReady"]
										s["enabled"] = CDTL2.db.profile.global["items"]["showByDefault"]
										s["highlight"] = false
										s["pinned"] = false
										s["usedBy"] = { CDTL2.player["guid"] }
										
									local item = Item:CreateFromItemID(itemId)
									item:ContinueOnItemLoad(function()
										s["itemName"] = item:GetItemName()
										s["icon"] = item:GetItemIcon()
										s["link"] = item:GetItemLink()
									end)
									
									if duration > 3 and duration < CDTL2.db.profile.global["items"]["ignoreThreshold"] then
										s["ignored"] = false
									else
										s["ignored"] = true
									end
									
									table.insert(CDTL2.db.profile.tables["items"], s)
									
									if not s["ignored"] then
										CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
end

function CDTL2:SetBorder(f, s)
	local inset = s["inset"]
	local padding = s["padding"]

	f:SetBackdrop({
		bgFile = CDTL2.LSM:Fetch("background", "None"),
		edgeFile = CDTL2.LSM:Fetch("border", s["style"]),
		tile = false,
		tileSize = 0,
		edgeSize = s["size"],
		insets = { left = inset, right = inset, top = inset, bottom = inset }
	})
	f:SetBackdropBorderColor(
		s["color"]["r"],
		s["color"]["g"],
		s["color"]["b"],
		s["color"]["a"]
	)
	f:SetPoint("TOPLEFT", f:GetParent(), "TOPLEFT", -padding, padding)
	f:SetPoint("BOTTOMRIGHT", f:GetParent(), "BOTTOMRIGHT", padding, -padding)
end

function CDTL2:SetSpellData(name, type, k, v)
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:Print("DATASAVE: "..name.." - "..type.." - "..k..":"..tostring(v))
	end
	
	for _, e in pairs(CDTL2.db.profile.tables[type]) do
		if e["name"] == name then
			e[k] = v
		end
	end
end

function CDTL2:ToggleDebug()
	local debugMode = CDTL2.db.profile.global["debugMode"]
	
	if debugMode then
		CDTL2.db.profile.global["debugMode"] = false
		CDTL2.debugFrame:Hide()
		
		for _, f in pairs(CDTL2.holders) do
			f:SetAlpha(0)
		end
		
		for _, f in pairs(CDTL2.lanes) do
			private.DebugOff(f)
		end
		
		for _, f in pairs(CDTL2.barFrames) do
			private.DebugOff(f)
		end
		
		for _, f in pairs(CDTL2.readyFrames) do
			private.DebugOff(f)
		end
		
		for _, f in pairs(CDTL2.cooldowns) do
			private.DebugOff(f.bar)
			private.DebugOff(f.icon)
		end
		
		CDTL2:Print("Debug Mode Disabled")
	else
		CDTL2.db.profile.global["debugMode"] = true
		CDTL2.debugFrame:Show()
		
		for _, f in pairs(CDTL2.holders) do
			f:SetAlpha(1)
		end
		
		for _, f in pairs(CDTL2.lanes) do
			private.DebugOn(f)
		end
		
		for _, f in pairs(CDTL2.barFrames) do
			private.DebugOn(f)
		end
		
		for _, f in pairs(CDTL2.readyFrames) do
			private.DebugOn(f)
		end
		
		for _, f in pairs(CDTL2.cooldowns) do
			private.DebugOff(f.bar)
			private.DebugOff(f.icon)
		end
		
		CDTL2:Print("Debug Mode Enabled")
	end
end

function CDTL2:ToggleFrameLock()
	local unlockFrames = CDTL2.db.profile.global["unlockFrames"]
	
	if unlockFrames then
		CDTL2.db.profile.global["unlockFrames"] = false
		CDTL2.unlockFrame:Hide()

		for _, f in pairs(CDTL2.lanes) do
			private.FrameLock(f)
		end
		
		for _, f in pairs(CDTL2.barFrames) do
			private.FrameLock(f)
		end
		
		for _, f in pairs(CDTL2.readyFrames) do
			private.FrameLock(f)
		end
		
		CDTL2:Print("Frames Locked")
	else
		CDTL2.db.profile.global["unlockFrames"] = true
		CDTL2.unlockFrame:Show()
		
		for _, f in pairs(CDTL2.lanes) do
			private.FrameUnlock(f)
		end
		
		for _, f in pairs(CDTL2.barFrames) do
			private.FrameUnlock(f)
		end
		
		for _, f in pairs(CDTL2.readyFrames) do
			private.FrameUnlock(f)
		end
		
		CDTL2:Print("Frames Unlocked")
	end
end

function CDTL2:FrameLock(f)
	private.FrameLock(f)
end

function CDTL2:FrameUnlock(f)
	private.FrameUnlock(f)
end

function CDTL2:DebugOn(f)
	private.DebugOn(f)
end

function CDTL2:DebugOff(f)
	private.DebugOff(f)
end

private.DebugOff = function(f)	
	f.db:Hide()
	
	if CDTL2.db.profile.global["unlockFrames"] then
		private.FrameUnlock(f)
	end
end

private.DebugOn = function(f)
	f.db.text:SetText(f:GetName())
	f.db:Show()
end

private.FrameLock = function(f)
	f:SetMovable(false)
	f:EnableMouse(false)
	
	f.db.text:SetText(f.name)
	
	f.db:Hide()
	
	if CDTL2.db.profile.global["debugMode"] then
		private.DebugOn(f)
	end
end

private.FrameUnlock = function(f)
	f:SetMovable(true)
	f:EnableMouse(true)
	
	f.db.text:SetText(f.name)

	f.db:Show()
end