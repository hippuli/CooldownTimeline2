--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
	
	Update notes:
		- Almost complete re-write, see changelog in game for details
]]--

CDTL2 = LibStub("AceAddon-3.0"):NewAddon("CDTL2", "AceConsole-3.0", "AceEvent-3.0")
CDTL2.Masque = LibStub("Masque", true)
CDTL2.LSM = LibStub("LibSharedMedia-3.0")

CDTL2.version = 1.6
CDTL2.noticeVersion = 1.5
CDTL2.cdUID = 999
CDTL2.lanes = {}
CDTL2.barFrames = {}
CDTL2.readyFrames = {}
CDTL2.holders = {}
CDTL2.offensives = {}
CDTL2.player = {}
CDTL2.cooldowns = {}
CDTL2.tracking = {
	mhSwingTime = -1,
	ohSwingTime = -1,
	rSwingTime = -1,
}
CDTL2.spellData = {}
CDTL2.colors = {
	bg = {},
	db = { r = 0.1, g = 0.1, b = 0.1, a = 0.85 },
}
CDTL2.combat = false
CDTL2.enabled = false
local private = {}

local defaults = {
    profile = {
		global = {
			firstRun = true,
			previousVersion = 0,

			unlockFrames = true,
			debugMode = false,
			
			autohide = false,
			enableTooltip = false,
			zoom = 1,
			
			detectSharedCD = false,
			hideIgnored = true,
			
			notUsableTint = false,
			notUsableDesaturate = false,
			notUsableColor = { r = 0.75, g = 0.1, b = 0.1, a = 1 },
			
			enabledAlways = true,
			enabledGroup = false,
			enabledInstance = false,
			
			spells = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
			
			items = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
			
			buffs = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 120,
				defaultLane = 2,
				defaultReady = 2,
				defaultBar = 2,
			},
			
			debuffs = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 300,
				defaultLane = 3,
				defaultReady = 3,
				defaultBar = 3,
			},
			
			offensives = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 600,
				defaultLane = 0,
				defaultReady = 0,
				defaultBar = 0,
			},
			
			petspells = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},

			runes = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
		},
	
		lanes = {	
			lane1 = {
				enabled = true,
				name = "Lane 1",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -250,
				width = 400,
				height = 44,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "GCD",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stWidth = 5,
					stHeight = 44,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.77647, g = 0.11765, b = 0.28235, a = 1 },
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 40,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 1 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 11,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 2,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 16,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 11,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 2,
						offY = 5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
						timeFormat = "XhYmZs",
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 2,
						s1v = 10,
						s1p = 0.33,
						s2v = 33,
						s2p = 0.66,
						s3v = 66,
						s3p = 0.75,
					},
					splitAbs = {
						max = 120,
						hideTimeSurplus = true,
						timeFormat = "XhYmZs",
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
					},
				},
				
				modeText = {
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = true,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = true,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			lane2 = {
				enabled = true,
				name = "Lane 2",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -200,
				width = 400,
				height = 5,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "NONE",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stHeight = 30,
					stWidth = 5,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.52941, g = 0.77647, b = 0.24314, a = 1 },
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 30,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 0,
						offY = -5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 13,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "BOTTOMRIGHT",
						offX = 0,
						offY = 5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 25,
						s2p = 0.5,
						s3v = 50,
						s3p = 0.75,
					},
					splitAbs = {
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
						max = 120,
						hideTimeSurplus = true,
					},
				},
				
				modeText = {
					text1 = {
						enabled = false,
						used = true,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			lane3 = {
				enabled = true,
				name = "Lane 3",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -160,
				width = 400,
				height = 5,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "NONE",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stHeight = 20,
					stWidth = 5,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.15294, g = 0.63922, b = 0.77647, a = 1 },
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 30,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 0,
						offY = -3,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 13,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						offX = -10,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,						
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 3,
						s1v = 5,
						s1p = 0.25,
						s2v = 25,
						s2p = 0.5,
						s3v = 50,
						s3p = 0.75,
					},
					splitAbs = {
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
						max = 120,
						hideTimeSurplus = true,
					},
				},
				
				modeText = {
					text1 = {
						enabled = false,
						used = true,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
		},
		
		barFrames = {
			frame1 = {
				enabled = true,
				name = "Bar Frame 1",
				grow = "UP",
				horizontal = false,
				sorting = "DESCENDING",
				padding = 0,
				
				posX = -300,
				posY = 0,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.77647, g = 0.11765, b = 0.28235, a = 1 },
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
			frame2 = {
				enabled = true,
				name = "Bar Frame 2",
				grow = "UP",
				horizontal = false,
				padding = 0,
				
				posX = 300,
				posY = 0,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.52941, g = 0.77647, b = 0.24314, a = 1 },
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
			frame3 = {
				enabled = true,
				name = "Bar Frame 3",
				grow = "UP",
				horizontal = false,
				padding = 0,
				
				posX = 0,
				posY = 175,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.15294, g = 0.63922, b = 0.77647, a = 1 },
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
		},
		
		ready = {
			ready1 = {
				enabled = true,
				name = "Ready 1",
				grow = "DOWN",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Click",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = -300,
				posY = -75,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			ready2 = {
				enabled = true,
				name = "Ready 2",
				grow = "DOWN",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Tinks",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = 300,
				posY = -75,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			ready3 = {
				enabled = true,
				name = "Ready 3",
				grow = "CENTER_H",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Tinks",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = 0,
				posY = 100,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
		},
		
		holders = {
			iconPadding = 12,
			iconSize = 48,
			barPadding = 6,
			barWidth = 150,
			barHeight = 22,
			fontSize = 10,
		},
		
		tables = {
			spells = {
				
			},
			petspells = {
				
			},
			items = {
				
			},
			buffs = {
				
			},
			debuffs = {
				
			},
			offensives = {
				
			},
			runes = {
				
			},
		},
	}
}

function CDTL2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CDTL2DB", defaults, true)
	self.registry = LibStub("AceConfigRegistry-3.0")
	self.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2", CDTL2:GetMainOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Lanes", CDTL2:GetLaneOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Ready", CDTL2:GetReadyOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2BarFrames", CDTL2:GetBarFrameOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Filters", CDTL2:GetFilterOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Profiles", self.profile)
	
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2", "CDTL2")
	self.optionsFrame.oLanes = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Lanes", "Lanes", "CDTL2")
	self.optionsFrame.oReady = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Ready", "Ready", "CDTL2")
	self.optionsFrame.oBarFrames = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2BarFrames", "Bars", "CDTL2")
	self.optionsFrame.oFilter = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Filters", "Filters", "CDTL2")
	self.optionsFrame.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Profiles", "Profiles", "CDTL2")
	
	self:RegisterChatCommand("cdtl2", "ChatCommand")
    self:RegisterChatCommand("cooldowntimeline2", "ChatCommand")
end

function CDTL2:OnEnable()
	--self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	--self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	--self:RegisterEvent("ITEM_LOCK_CHANGED")
	
	--self:RegisterEvent("PLAYER_REGEN_DISABLED")
	--self:RegisterEvent("PLAYER_REGEN_ENABLED")
	--self:RegisterEvent("UNIT_POWER_FREQUENT")
	--self:RegisterEvent("UNIT_POWER_UPDATE")
	
	--self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_LEFT")

	CDTL2:CreateLanes()
	CDTL2:CreateBarFrames()
	CDTL2:CreateReadyFrames()
	CDTL2:CreateHolders()
	
	private.CreateUnlockFrame()
	private.CreateDebugFrame()
	
	CDTL2:Print("Loaded version: "..CDTL2.version)
	CDTL2:Print("Type /cdtl2 or /cooldowntimeline2 for options")
	
	CDTL2.tracking["manaTime"] = GetTime()
	CDTL2.tracking["manaPrevious"] = 0
	CDTL2.tracking["energyTimeCount"] = 2
	CDTL2.tracking["energyPrevious"] = 0
	
	C_Timer.After(5, function()
		CDTL2:GetCharacterData()
		CDTL2:ScanCurrentCooldowns(CDTL2.player["class"], CDTL2.player["race"])
		if CDTL2.player["class"] == "DEATHKNIGHT" then
			self:RegisterEvent("RUNE_POWER_UPDATE")
		end
	end)
	
	if CDTL2.db.profile.global["firstRun"] or CDTL2.db.profile.global["previousVersion"] < CDTL2.noticeVersion then
		C_Timer.After(10, function()
			private.CreateFirstRunFrame()
		end)
	end
end

function CDTL2:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame.profile)
        InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame)
	elseif input:trim() == "lock" then
		CDTL2:ToggleFrameLock()
	elseif input:trim() == "unlock" then
		CDTL2:ToggleFrameLock()
	elseif input:trim() == "debug" then
		CDTL2:ToggleDebug()
    end
end

private.CreateDebugFrame = function()
	local frameName = "CDTL2_Debug_Frame"
	local f = CreateFrame("Frame", frameName, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f:ClearAllPoints()
	f:SetPoint("TOP", 300, -75)
	f:SetSize(300, 200)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 
		CDTL2.colors["db"]["r"],
		CDTL2.colors["db"]["g"],
		CDTL2.colors["db"]["b"],
		CDTL2.colors["db"]["a"]
	)
	
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText("CDTL2: Debug Enabled")
	f.text:SetPoint("TOP", 0, -5)
	
	f.t1 = f:CreateFontString(nil,"ARTWORK")
	f.t1:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t1:SetShadowColor( 0, 0, 0, 1 )
	f.t1:SetShadowOffset(1.5, -1)
	f.t1:SetText("Text 1")
	f.t1:SetPoint("TOP", 0, -30)
	
	f.t2 = f:CreateFontString(nil,"ARTWORK")
	f.t2:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t2:SetShadowColor( 0, 0, 0, 1 )
	f.t2:SetShadowOffset(1.5, -1)
	f.t2:SetText("Text 2")
	f.t2:SetPoint("TOP", 0, -60)
	
	f.t3 = f:CreateFontString(nil,"ARTWORK")
	f.t3:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t3:SetShadowColor( 0, 0, 0, 1 )
	f.t3:SetShadowOffset(1.5, -1)
	f.t3:SetText("Text 3")
	f.t3:SetPoint("TOP", 0, -90)
	
	local b = CreateFrame("Button", frameName.."_B_Reload", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Reload")
	b:SetPoint("TOPLEFT", 5, -25)
	b:SetScript("OnClick", function()
		ReloadUI()
	end)
	
	local b = CreateFrame("Button", frameName.."_B_Options", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Options")
	b:SetPoint("TOPLEFT", 5, -50)
	b:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame.profile)
        InterfaceOptionsFrame_OpenToCategory(CDTL2.optionsFrame)
	end)
	
	local b = CreateFrame("Button", frameName.."_B_UnLock", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("(Un)Lock")
	b:SetPoint("TOPLEFT", 5, -75)
	b:SetScript("OnClick", function()
		CDTL2:ToggleFrameLock()
	end)
	
	local b = CreateFrame("Button", frameName.."_B_TestCode1", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("TestCode1")
	b:SetPoint("TOPLEFT", 5, -100)
	b:SetScript("OnClick", function()
		--CDTL2:ScanSpellData("WARLOCK")
		
		--for _, spell in pairs(CDTL2.spellData) do
			--CDTL2:Print("SPELL DATA: "..spell["id"].." - "..spell["name"].." - "..spell["rank"])
		--end
	end)
		
	local b = CreateFrame("Button", frameName.."_B_TestCode2", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("TestCode2")
	b:SetPoint("TOPLEFT", 5, -125)
	b:SetScript("OnClick", function()
		--[[local s = {}
		
		s["name"] = "Test Cooldown"
		--s["type"] = "test"
		s["icon"] = 134400
		s["lane"] = 1
		s["barFrame"] = 1
		s["readyFrame"] = 1
		
		s["enabled"] = true
		s["highlight"] = false
		s["pinned"] = false
		s["ignored"] = false
		
		s["bCD"] = 180 * 1000
		s["usedBy"] = { CDTL2.player["guid"] }
		
		CDTL2:CreateCooldown(CDTL2:GetUID(),"test" , s)]]--
	end)
	
	-- ON UPDATE
	f:HookScript("OnUpdate", function(self, elapsed)
		--self.t1:SetText("CDTL2_Lane_1: "..CDTL2_Lane_1.currentCount)
		--self.t2:SetText("CDTL2_BarFrame_1: "..CDTL2_BarFrame_1.currentCount)
		--self.t3:SetText("CDTL2_Ready_1: "..CDTL2_Ready_1.currentCount)
	end)
		
	-- DRAG AND DROP MOVEMENT
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	
	if not CDTL2.db.profile.global["debugMode"] then
		f:Hide()
	end
	
	CDTL2.debugFrame = f
end

private.CreateFirstRunFrame = function()
	local f = CreateFrame("Frame", "CDTL2_First_Run", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	local text = "\124cff00ccffWelcome to CDTL2\124r"
	
	if CDTL2.db.profile.global["previousVersion"] == 0 then
		text = text.."\n\n\n"
		text = text.."This is a complete re-write of Cooldown Timeline\n"
		text = text.."Access to the options panel is now via:\n\n"
		text = text.."\124cffADFF2F/cdtl2\124r or \124cffADFF2F/cooldowntimeline2\124r\n\n"
		text = text.."Due to the number of changes made, settings\nfrom Cooldown Timeline will not carry over to CDTL2\n\n"
		text = text.."Old settings are still saved, and you can manually\ninstall old versions"
	end
	
	if CDTL2.db.profile.global["previousVersion"] < CDTL2.noticeVersion then
		text = text.."\n\n\n"
		text = text.."This latest version contains many changes\n"
		text = text.."that should greatly improve performance.\n\n"
		text = text.."Everything should function just as before,\n"
		text = text.."but if you notice something isn't quite right,\n"
		text = text.."please feel free to let me know via Curse"
	end
	
	text = text.."\n\n"
	text = text.."Good luck, and have fun!\n"
	
	-- TEXT
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText(text)
	f.text:SetNonSpaceWrap(true)
	f.text:SetPoint("TOP", 0, -5)
	
	f.text1 = f:CreateFontString(nil,"ARTWORK")
	f.text1:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text1:SetShadowColor( 0, 0, 0, 1 )
	f.text1:SetShadowOffset(1.5, -1)
	f.text1:SetText("Show this message next login/reload?")
	f.text1:SetPoint("BOTTOM", 0, 33)
	
	--local textHeight = f.text:GetStringHeight()
	local textHeight = f.text:GetHeight()
	f:ClearAllPoints()
	f:SetPoint("TOP", 0, -200)
	f:SetSize(300, textHeight + 80)
	f:SetFrameLevel(200)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 
		CDTL2.colors["db"]["r"],
		CDTL2.colors["db"]["g"],
		CDTL2.colors["db"]["b"],
		CDTL2.colors["db"]["a"]
	)
	
	-- BORDER
	f.bd = CreateFrame("Frame", "CDTL2_First_Run_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.bd:SetParent(f)
	CDTL2:SetBorder(f.bd, {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				})
	f.bd:SetFrameLevel(f:GetFrameLevel() + 1)
	
	
	
	local b = CreateFrame("Button", "CDTL2_First_Run_Yes", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Yes")
	b:SetPoint("BOTTOM", -45, 4)
	b:SetScript("OnClick", function()
		f:Hide()
	end)
	
	local b = CreateFrame("Button", "CDTL2_First_Run_No", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("No")
	b:SetPoint("BOTTOM", 45, 4)
	b:SetScript("OnClick", function()
		CDTL2.db.profile.global["firstRun"] = false
		CDTL2.db.profile.global["previousVersion"] = CDTL2.version
		f:Hide()
	end)
	
	
	
	--CDTL2.unlockFrame = f
end

private.CreateUnlockFrame = function()
	local f = CreateFrame("Frame", "CDTL2_Unlock_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f:ClearAllPoints()
	f:SetPoint("TOP", 0, -70)
	f:SetSize(180, 70)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 
		CDTL2.colors["db"]["r"],
		CDTL2.colors["db"]["g"],
		CDTL2.colors["db"]["b"],
		CDTL2.colors["db"]["a"]
	)
	
	-- BORDER
	f.bd = CreateFrame("Frame", "CDTL2_Unlock_Frame_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.bd:SetParent(f)
	CDTL2:SetBorder(f.bd, {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				})
	f.bd:SetFrameLevel(f:GetFrameLevel() + 1)
	
	-- TEXT
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText("CDTL2\nFrames currently unlocked\nDrag and drop to move")
	f.text:SetPoint("TOP", 0, -5)
	
	local b = CreateFrame("Button", "CDTL2_Unlock_Frame_Button", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Lock")
	b:SetPoint("BOTTOM", 0, 4)
	b:SetScript("OnClick", function()
		CDTL2:ToggleFrameLock()
		f:Hide()
	end)
	
	-- ON UPDATE
	f:HookScript("OnUpdate", function(self, elapsed)
		
	end)
	
	if not CDTL2.db.profile.global["unlockFrames"] then
		f:Hide()
	end
	
	CDTL2.unlockFrame = f
end

function CDTL2:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = CombatLogGetCurrentEventInfo()
	
	if subevent == "SPELL_AURA_APPLIED" then
		if sourceGUID == CDTL2.player["guid"] or destGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA APPLIED: "..spellID.." - "..spellName.." - "..auraType.." - "..tostring(sourceName).." - "..destName)
			end
			
			-- PLAYER AURAS
			if destGUID == CDTL2.player["guid"] then
				local s = CDTL2:GetSpellSettings(spellName, auraType)
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], auraType)
						if ef then
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
						else
							if CDTL2.db.profile.global["buffs"]["enabled"] and auraType == "buffs" then
								CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
								if not CDTL2:IsUsedBy("buffs", spellID) then
									CDTL2:AddUsedBy("buffs", spellID, CDTL2.player["guid"])
								end
							elseif CDTL2.db.profile.global["debuffs"]["enabled"] and auraType == "debuffs" then
								CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
								if not CDTL2:IsUsedBy("debuffs", spellID) then
									CDTL2:AddUsedBy("debuffs", spellID, CDTL2.player["guid"])
								end
							end
						end
					end
				else
					s = CDTL2:AuraExists("player", spellName)
					if s then
						s["highlight"] = false
						s["pinned"] = false
						
						s["usedBy"] = { CDTL2.player["guid"] }
						
						local ignoreThreshold = 0
						local link, _ = GetSpellLink(spellID)
						s["link"] = link
						
						if auraType == "buffs" then
							ignoreThreshold = CDTL2.db.profile.global["buffs"]["ignoreThreshold"]
							
							s["enabled"] = CDTL2.db.profile.global["buffs"]["showByDefault"]
							s["lane"] = CDTL2.db.profile.global["buffs"]["defaultLane"]
							s["barFrame"] = CDTL2.db.profile.global["buffs"]["defaultBar"]
							s["readyFrame"] = CDTL2.db.profile.global["buffs"]["defaultReady"]
						elseif auraType == "debuffs" then
							ignoreThreshold = CDTL2.db.profile.global["debuffs"]["ignoreThreshold"]
							
							s["enabled"] = CDTL2.db.profile.global["debuffs"]["showByDefault"]
							s["lane"] = CDTL2.db.profile.global["debuffs"]["defaultLane"]
							s["barFrame"] = CDTL2.db.profile.global["debuffs"]["defaultBar"]
							s["readyFrame"] = CDTL2.db.profile.global["debuffs"]["defaultReady"]
						end
						
						if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= ignoreThreshold then
							s["ignored"] = false
						else
							s["ignored"] = true
						end

						table.insert(CDTL2.db.profile.tables[auraType], s)
						
						if not s["ignored"] then
							if CDTL2.db.profile.global["buffs"]["enabled"] and auraType == "buffs" then
								CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
							elseif CDTL2.db.profile.global["debuffs"]["enabled"] and auraType == "debuffs" then
								CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
							end
						end
					end
				end
			
			-- OFFENSIVE AURAS
			else
				local s = CDTL2:GetSpellSettings(spellName, "offensives")
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], "offensives", destGUID)
						if ef then
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
							
							ef.data["currentCD"] = ef.data["baseCD"]
							ef.data["targetID"] = destGUID
							ef.data["targetName"] = destName
						else
							local rcd = CDTL2:RecycleOffensiveCD()
							if rcd then
								rcd.data["id"] = s["id"]
								rcd.data["name"] = s["name"]
								rcd.data["rank"] = s["rank"]
								rcd.data["desc"] = s["desc"]
								rcd.data["icon"] = s["icon"]
								
								rcd.data["ignored"] = ""
								rcd.data["highlighted"] = ""
								
								rcd.data["lane"] = s["lane"]
								rcd.data["barFrame"] = s["barFrame"]
								rcd.data["readyFrame"] = s["readyFrame"]
								
								rcd.data["baseCD"] = s["bCD"] / 1000
								rcd.data["currentCD"] = s["bCD"] / 1000
								
								rcd.icon.icon = rcd.data["icon"]
								rcd.icon.name = rcd.data["name"]
								rcd.icon.rank = rcd.data["rank"]
								rcd.icon.lane = rcd.data["lane"]
								
								rcd.data["targetID"] = destGUID
								rcd.data["targetName"] = destName
								
								CDTL2:SendToLane(rcd)
								CDTL2:SendToBarFrame(rcd)
								
								--CDTL2:RefreshBar(rcd)
								--CDTL2:RefreshIcon(rcd)
							else
								s["targetID"] = destGUID
								s["targetName"] = destName
								
								if CDTL2.db.profile.global["offensives"]["enabled"] then
									CDTL2:CreateCooldown(CDTL2:GetUID(),"offensives" , s)
									if not CDTL2:IsUsedBy("offensives", spellID) then
										CDTL2:AddUsedBy("offensives", spellID, CDTL2.player["guid"])
									end
								end
							end
						end
					end
				else
					local _, _, icon, _, _, _, _ = GetSpellInfo(spellID)
					
					local s = {
						id = spellID,
						bCD = 0,
						name = spellName,
						type = "offensives",
						icon = icon,
						lane = CDTL2.db.profile.global["offensives"]["defaultLane"],
						barFrame = CDTL2.db.profile.global["offensives"]["defaultBar"],
						readyFrame = CDTL2.db.profile.global["offensives"]["defaultReady"],
					}
					
					s["enabled"] = CDTL2.db.profile.global["offensives"]["showByDefault"]
					s["highlight"] = false
					s["pinned"] = false
					
					s["usedBy"] = { CDTL2.player["guid"] }
					
					local link, _ = GetSpellLink(spellID)
					s["link"] = link
					
					table.insert(CDTL2.db.profile.tables["offensives"], s)
										
					if CDTL2.db.profile.global["offensives"]["enabled"] then
						s["targetID"] = destGUID
						s["targetName"] = destName
						
						CDTL2:CreateCooldown(CDTL2:GetUID(),"offensives" , s)
					end
				end
			end
		end
	elseif subevent == "SPELL_AURA_REFRESH" then
		if sourceGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA REFRESH: "..spellID.." - "..spellName.." - "..auraType.." - "..sourceName.." - "..destName)
			end
			
			local ef = CDTL2:GetExistingCooldown(spellName, "offensives", destGUID)
			if ef then
				ef.data["currentCD"] = ef.data["baseCD"]
			end
		end		
	elseif subevent == "SPELL_AURA_REMOVED" then
		if sourceGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA REMOVED: "..spellID.." - "..spellName.." - "..auraType.." - "..sourceName.." - "..destName)
			end
			
			local ef = CDTL2:GetExistingCooldown(spellName, "offensives", destGUID)
			if ef then
				ef.data["currentCD"] = -1
			end
		end
		
	-- SWING DAMAGE
	elseif subevent == "SWING_DAMAGE" then
		if sourceGUID == CDTL2.player["guid"] then
			local amount, _, _, _, _, _, _, _, _, isOffHand = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if isOffHand then
				CDTL2.tracking["ohSwingTime"] = ohSpeed
			else
				CDTL2.tracking["mhSwingTime"] = mhSpeed
			end
		end
	
	-- SWING MISSED
	elseif subevent == "SWING_MISSED" then
		if sourceGUID == CDTL2.player["guid"] then
			local _, isOffHand, _, _ = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if isOffHand then
				CDTL2.tracking["ohSwingTime"] = ohSpeed
			else
				CDTL2.tracking["mhSwingTime"] = mhSpeed
			end
		end
	end
end

function CDTL2:UNIT_SPELLCAST_SUCCEEDED(...)
	local _, unitTarget, castGUID, spellID = ...
	
	-- Spell ID 836 is a spell that gets cast on login
	if unitTarget == "player" and spellID ~= 836 then
		CDTL2:GetCharacterData()
		
		local _, _, icon, _, _, _, _ = GetSpellInfo(spellID)
		local subtext = GetSpellSubtext()
		
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("SPELLCAST: "..castGUID)
		end
		
		-- SPECIAL CASE FOR AUTOSHOT
		if spellID == 75 then
			local rSwingTime, _, _, _, _, _ = UnitRangedDamage("player");
			
			CDTL2.tracking["rSwingTime"] = rSwingTime
		end
		
		-- STANDARD SPELLS
		local spellName = CDTL2:GetSpellName(spellID, CDTL2.player["class"], CDTL2.player["race"])
		local s = CDTL2:GetSpellSettings(spellName, "spells")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown(s["name"], "spells")
				if ef then
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
					CDTL2:CheckEdgeCases(spellName)
				else
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						CDTL2:CheckEdgeCases(spellName)
						
						if CDTL2:IsUsedBy("spells", spellID) then
							--CDTL2:Print("USEDBY MATCH: "..s["id"])
						else
							--CDTL2:Print("NEW USEDBY: "..s["id"])
							CDTL2:AddUsedBy("spells", spellID, CDTL2.player["guid"])
						end
					end
				end
			end
		else
			s = CDTL2:GetSpellData(spellID)
			if s then
				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["spells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["spells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["spells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["spells"]["showByDefault"]
				s["highlight"] = false
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				
				local link, _ = GetSpellLink(spellID)
				s["link"] = link
				
				if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end
				
				table.insert(CDTL2.db.profile.tables["spells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						CDTL2:CheckEdgeCases(spellName)
					end
				end
			else
				-- ITEM SPELLS
				local s = CDTL2:GetSpellSettings(spellName, "items", spellID)				
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], "items")
						if ef then
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
						else
							if CDTL2.db.profile.global["items"]["enabled"] then
								if not CDTL2:IsUsedBy("items", spellID) then
									CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
								end
								
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					end
				else
					s = CDTL2:GetItemSpell(spellID)
					if s then
						if CDTL2:IsValidItem(s["itemID"]) then
							s["usedBy"] = { CDTL2.player["guid"] }
							table.insert(CDTL2.db.profile.tables["items"], s)
							
							if CDTL2.db.profile.global["items"]["enabled"] then
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					else
						--CDTL2:Print("NOTFOUND: "..spellID)
					end
				end
			end
		end
	elseif unitTarget == "pet" then
		local _, _, icon, _, _, _, _ = GetSpellInfo(spellID)
		local subtext = GetSpellSubtext()
		
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("PETCAST: "..castGUID)
		end
		
		-- PET SPELLS		
		local spellName = CDTL2:GetSpellName(spellID, CDTL2.player["class"], CDTL2.player["race"])
		local s = CDTL2:GetSpellSettings(spellName, "petspells")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown(s["name"], "petspells")
				if ef then
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
				else
					if CDTL2.db.profile.global["petspells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"petspells" , s)
						
						if not CDTL2:IsUsedBy("petspells", spellID) then
							CDTL2:AddUsedBy("petspells", spellID, CDTL2.player["guid"])
						end
					end
				end
			end
		else
			s = CDTL2:GetSpellData(spellID)
			if s then
				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["petspells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["petspells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["petspells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["petspells"]["showByDefault"]
				s["highlight"] = false
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				
				local link, _ = GetSpellLink(spellID)
				s["link"] = link
				
				if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["petspells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end
				
				table.insert(CDTL2.db.profile.tables["petspells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["petspells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"petspells" , s)
					end
				end
			end
		end
	end
end

function CDTL2:ITEM_LOCK_CHANGED(...)
	-- Detect item lock cooldowns
	-- Most commonly trinkets being equipped, that will begin a 30 second cooldown
	local _, bagOrSlotIndex, slotIndex = ...
	
	if not IsInventoryItemLocked(bagOrSlotIndex) and not IsInventoryItemLocked(slotIndex) then
		if slotIndex == nil then
			local itemId = GetInventoryItemID("player", bagOrSlotIndex)
			local spellName, spellID = GetItemSpell(itemId)
			
			if spellID then
				local s = CDTL2:GetSpellSettings(spellName, "items", spellID)
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], "items")
						if ef then
							ef.data["bCD"] = 30000
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
						else
							if CDTL2.db.profile.global["items"]["enabled"] then
								if not CDTL2:IsUsedBy("items", spellID) then
									CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
								end
								
								s["bCD"] = 30000
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					end
				else
					s = CDTL2:GetItemSpell(spellID)
					if s then
						if CDTL2:IsValidItem(s["itemID"]) then
							s["usedBy"] = { CDTL2.player["guid"] }
							table.insert(CDTL2.db.profile.tables["items"], s)
							
							if CDTL2.db.profile.global["items"]["enabled"] then
								s["bCD"] = 30000
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					else
						--CDTL2:Print("NOTFOUND: "..spellID)
					end
				end
			end
		end
	end
end

function CDTL2:PLAYER_REGEN_DISABLED()
	--CDTL2:Print("Combat")
	CDTL2.combat = true
	
	local ready1Enabled = CDTL2.db.profile.ready["ready1"]["enabled"]
	local ready2Enabled = CDTL2.db.profile.ready["ready2"]["enabled"]
	local ready3Enabled = CDTL2.db.profile.ready["ready3"]["enabled"]
	
	if CDTL2_Ready_1 then
		CDTL2_Ready_1.combatTimer = CDTL2.db.profile.ready["ready1"]["pTime"]
	end
	
	if CDTL2_Ready_2 then
		CDTL2_Ready_2.combatTimer = CDTL2.db.profile.ready["ready2"]["pTime"]
	end
	
	if CDTL2_Ready_3 then
		CDTL2_Ready_3.combatTimer = CDTL2.db.profile.ready["ready3"]["pTime"]
	end
end

function CDTL2:PLAYER_REGEN_ENABLED()
	--CDTL2:Print("No Combat")
	CDTL2.combat = false
	
	if CDTL2_Ready_1 then
		CDTL2_Ready_1.combatTimer = 0
	end
	
	if CDTL2_Ready_2 then
		CDTL2_Ready_2.combatTimer = 0
	end
	
	if CDTL2_Ready_3 then
		CDTL2_Ready_3.combatTimer = 0
	end
end

function CDTL2:UNIT_POWER_FREQUENT(...)
	local _, unitTarget, powerType = ...
	
	if unitTarget == "player" and powerType == "MANA" then
		if	CDTL2.db.profile.lanes["lane1"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane1"]["tracking"]["secondaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["secondaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["secondaryTracking"] == "MANA_TICK"
		then
			local currentTime = GetTime()
			local currentMana = UnitPower("player", Enum.PowerType.Mana)
			if currentMana ~= UnitPowerMax("player", Enum.PowerType.Mana) then
				local difference = currentMana - CDTL2.tracking["manaPrevious"]
							
				local timeDifference = 0
				if CDTL2.tracking["manaTime"] then
					timeDifference = currentTime - CDTL2.tracking["manaTime"]
				end
				
				if difference < 0 then
					if CDTL2.combat then
						CDTL2.tracking["manaTime"] = currentTime
						CDTL2.tracking["fsr"] = true
					end
				end
				
				if difference > 0 then
					local low = 0.1
					local high = 1.9
					
					if CDTL2.tracking["fsr"] then
						local high = 4.9
					end
					
					if timeDifference < low or  timeDifference > high then
						CDTL2.tracking["fsr"] = false
						CDTL2.tracking["manaTime"] = currentTime
						--CDTL2:Print("TICK")
					end
				end
				
				CDTL2.tracking["manaPrevious"] = currentMana
			end
		end
	end
end

function CDTL2:UNIT_POWER_UPDATE(...)
	local _, unitTarget, powerType = ...
	
	if unitTarget == "player" and powerType == "ENERGY" then
		if	CDTL2.db.profile.lanes["lane1"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane1"]["tracking"]["secondaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["secondaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["secondaryTracking"] == "ENERGY_TICK"
		then
			local currentTime = GetTime()
			local maxenergy = UnitPowerMax("player", Enum.PowerType.Energy)
			local currentEnergy = UnitPower("player", Enum.PowerType.Energy)
			
			if currentEnergy < maxenergy then
				local difference = currentEnergy - CDTL2.tracking["energyPrevious"]
				if (difference > 18 and difference < 22) or (difference > 38 and difference < 42) then
					CDTL2.tracking["energyTimeCount"] = 0
				end
			end
			
			CDTL2.tracking["energyPrevious"] = currentEnergy
		end
	end
end

function CDTL2:RUNE_POWER_UPDATE(...)
	local _, runeIndex, added = ...
	
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:Print("RUNES UPDATE: "..tostring(runeIndex).." - "..tostring(added))
	end
	
	if not added then
		--CDTL2:Print("CREATING RUNE COOLDOWN")
		local spellName = ""
		local icon = 0
		if runeIndex == 1 or runeIndex == 2 then
			spellName = "Blood Rune "..tostring(runeIndex)
			icon = 135770
		elseif runeIndex == 3 or runeIndex == 4 then
			spellName = "Unholy Rune "..tostring(runeIndex)
			icon = 135775
		elseif runeIndex == 5 or runeIndex == 6 then
			spellName = "Frost Rune "..tostring(runeIndex)
			icon = 135773
		end
		
		local s = CDTL2:GetSpellSettings(spellName, "runes")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown(s["name"], "runes")
				if ef then					
					local graceTime = GetTime() - ef.data["runeGraceTime"]
					if graceTime >= 2.5 then
						ef.data["baseCD"] = 7.5
					elseif graceTime > 0 then
						ef.data["baseCD"] = 10 - graceTime
					else
						ef.data["baseCD"] = 10
					end
					
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
				else
					if CDTL2.db.profile.global["runes"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"runes" , s)
					end
				end
			end
		else
			local s = {}
		
			s["name"] = spellName
			s["type"] = "runes"
			s["runeIndex"] = runeIndex
			s["icon"] = icon
			s["lane"] = CDTL2.db.profile.global["runes"]["defaultLane"]
			s["barFrame"] = CDTL2.db.profile.global["runes"]["defaultBar"]
			s["readyFrame"] = CDTL2.db.profile.global["runes"]["defaultReady"]
			s["enabled"] = CDTL2.db.profile.global["runes"]["showByDefault"]
			s["highlight"] = false
			s["pinned"] = false
			
			local start, duration, runeReady = GetRuneCooldown(runeIndex)
			
			s["bCD"] = duration * 1000
			s["usedBy"] = { CDTL2.player["guid"] }
			
			if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["runes"]["ignoreThreshold"] then
				s["ignored"] = false
			else
				s["ignored"] = true
			end
			
			table.insert(CDTL2.db.profile.tables["runes"], s)
			
			if not s["ignored"] then
				if CDTL2.db.profile.global["runes"]["enabled"] then
					CDTL2:CreateCooldown(CDTL2:GetUID(),"runes" , s)
				end
			end
		end
	else
		for _, rune in pairs(CDTL2.cooldowns) do
			if rune.data["runeIndex"] == runeIndex then
				rune.data["runeGraceTime"] = GetTime()
			end
		end
	end
end

function CDTL2:ACTIVE_TALENT_GROUP_CHANGED()
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:Print("SPEC CHANGE")
	end
	
	for _, cd in pairs(CDTL2.cooldowns) do		
		if IsSpellKnown(cd.data["id"]) then			
			local start, duration, enabled, _ = GetSpellCooldown(cd.data["id"])
			if duration > 1.5 then
				CDTL2:SendToLane(cd)
				CDTL2:SendToBarFrame(cd)
			end
		else
			cd.data["currentCD"] = 0
		end
	end
end

function CDTL2:PLAYER_ENTERING_WORLD()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:GROUP_JOINED()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:GROUP_LEFT()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:DetermineOnOff()
	local turnOn = false
	
	if CDTL2.db.profile.global["enabledAlways"] then
		turnOn = true
	else
		local inInstance, instanceType = IsInInstance()
		local inGroup = IsInGroup()
		
		if inInstance or inGroup then
			if inInstance and CDTL2.db.profile.global["enabledInstance"] then
				turnOn = true
			end
			
			if inGroup and CDTL2.db.profile.global["enabledGroup"] then
				turnOn = true
			end
		end
	end
	
	return turnOn
end

function CDTL2:TurnOn()	
	if not CDTL2.enabled then
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("ENABLING DETECTION")
		end
	
		CDTL2:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CDTL2:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		CDTL2:RegisterEvent("ITEM_LOCK_CHANGED")
		CDTL2:RegisterEvent("PLAYER_REGEN_DISABLED")
		CDTL2:RegisterEvent("PLAYER_REGEN_ENABLED")
		CDTL2:RegisterEvent("UNIT_POWER_FREQUENT")
		CDTL2:RegisterEvent("UNIT_POWER_UPDATE")
		CDTL2:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		
		CDTL2.enabled = true
	end
end

function CDTL2:TurnOff()
	if CDTL2.enabled then
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("DISABLING DETECTION")
		end
		
		CDTL2:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CDTL2:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		CDTL2:UnregisterEvent("ITEM_LOCK_CHANGED")
		CDTL2:UnregisterEvent("PLAYER_REGEN_DISABLED")
		CDTL2:UnregisterEvent("PLAYER_REGEN_ENABLED")
		CDTL2:UnregisterEvent("UNIT_POWER_FREQUENT")
		CDTL2:UnregisterEvent("UNIT_POWER_UPDATE")
		CDTL2:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		
		CDTL2.enabled = false
	end
end