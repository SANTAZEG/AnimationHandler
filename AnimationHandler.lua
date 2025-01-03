local Main = {}
Main.Functions = {}
Main.__index = Main.Functions

local CharacterHandler = require(script.CharacterHandler)
local RuntimeHandler = require(script.RuntimeHandler)

Main.CharacterHandler = CharacterHandler
Main.CreateCharacterObject = CharacterHandler.CreateCharacterObject
Main.Functions.AddToRuntime = RuntimeHandler.AddToRuntime

function Main:LoadAnimation(CharacterObject:"Return of Main:CreateCharacterObject()", KeyframeSequence:KeyframeSequence)
	local Animation = setmetatable({}, Main)
	
	Animation.CharacterObject = CharacterObject
	Animation.KeyframeSequence = KeyframeSequence
	
	Animation.Priority = KeyframeSequence.Priority
	Animation.Loop = KeyframeSequence.Loop
	
	Animation.PlaybackSpeed = 1
	
	Animation.Playing = false
	
	Animation.RuntimePrivate = {}
	
	local KeyframeSequenceInOrder = KeyframeSequence:GetChildren()
	table.sort(KeyframeSequenceInOrder, function(a, b)
		return a.Time < b.Time
	end)
	
	Animation.Keyframes = KeyframeSequenceInOrder
	Animation.Time = KeyframeSequenceInOrder[#KeyframeSequenceInOrder].Time
	
	local KeyframeFormat = {}
	for _, Keyframe in ipairs(KeyframeSequenceInOrder) do
		
		for _, LimbFrame in ipairs(Keyframe:GetDescendants()) do
			
			if LimbFrame.Name ~= "Null" and LimbFrame.Name ~= "HumanoidRootPart" and LimbFrame:FindFirstChild("Null") == nil then
				KeyframeFormat[LimbFrame.Name] = KeyframeFormat[LimbFrame.Name] or {}
				
				table.insert(KeyframeFormat[LimbFrame.Name], {Time = Keyframe.Time, Keyframe = LimbFrame})
			end
			
		end
		
	end
	Animation.KeyframeTable = KeyframeFormat
	
	return Animation
end

function Main.Functions:Play(Playin, Playout)
	--local Keys = self.KeyframeSequence
	
	self.Playing = true
	--print(self.KeyframeTable)
	for LimbName, Limb in pairs(self.KeyframeTable) do
		local Previous = Limb[1]
		local Slot = 1
		
		local LimbMotor = self.CharacterObject.Motors[LimbName]
		local default = self.CharacterObject.DefaultC0[LimbName]
		local truedefault = self.CharacterObject.DefaultC0[LimbName]
		
		local KeyframeAmount = #Limb
		local Repeats = 0
		
		local Max = Limb[#Limb]
		
		self:AddToRuntime(LimbName, function(Runtime, RepeatsDetect)
			if Runtime > Max.Time then
				LimbMotor.C0 = default * Max.Keyframe.CFrame
				return
			end
			
			if Repeats ~= RepeatsDetect then
				Repeats = RepeatsDetect
				default = truedefault
				Slot = 1
				Previous = Limb[1]
			end
			
			while true do
				
				
				if Runtime > Previous.Time and Slot ~= KeyframeAmount then
					Slot += 1
					Previous = Limb[Slot]
				else
					break
				end
				
			end

			
			local CalculatedTime
			
			if Slot == 1 then
				CalculatedTime = {Time = 0, Keyframe = {CFrame = CFrame.new(0, 0, 0)} }
			else
				CalculatedTime = Limb[Slot-1]
			end
			
			local Calculation = 1
			if Slot ~= 1 then
				Calculation = (Runtime - CalculatedTime.Time) / (Previous.Time - CalculatedTime.Time)
			end
			

			local CalculatedCFrame = CalculatedTime.Keyframe.CFrame:Lerp(Previous.Keyframe.CFrame,  math.clamp(Calculation, 0, 1))
			LimbMotor.C0 = default * CalculatedCFrame
			
		end)
		
	end
	
end

function Main.Functions:Stop()
	local Priority = (self.Priority.Name == "Core" and -1) or self.Priority.Value
	self.Playing = false
	for LimbName, Thread in pairs(self.RuntimePrivate) do
		table.remove(self.CharacterObject.Runtime[LimbName][Priority], table.find(self.CharacterObject.Runtime[LimbName][Priority], Thread) )
		
		local Times = 0
		for _, Items in pairs(self.CharacterObject.Runtime[LimbName]) do
			
			Times += #Items
			
		end
		print(Times)
		if Times == 0 then
			self.CharacterObject.Motors[LimbName].C0 = self.CharacterObject.DefaultC0[LimbName]
		end
		
	end
	self.RuntimePrivate = {}
end



return Main
