local Main = {}
local RunService = game:GetService("RunService")

Main.Functions = {}
Main.__index = {}


local function CalculatePriorities(self, Priority, LimbName)
	self = self --just to make 100% sure
	local GoForIt = true
	local Repeat = 5
	
	while Repeat > Priority do
		if self.CharacterObject.Runtime[LimbName][Repeat] ~= nil and #self.CharacterObject.Runtime[LimbName][Repeat] ~= 0 then
			GoForIt = false
			break
		end
		
		Repeat -= 1
	end
	
	return GoForIt
end

---This part of the script is helping animation runtime!
function Main:AddToRuntime(LimbName, Function)
	local Priority = (self.Priority.Name == "Core" and -1) or self.Priority.Value
	
	local RunningTime = setmetatable({}, Main)
	
	self.CharacterObject.Runtime[LimbName][Priority] = self.CharacterObject.Runtime[LimbName][Priority] or {}
	
	local RuntimeConnect 
	local RunDelta = 0
	local Repeats = 0
	
	RuntimeConnect = RunService.Heartbeat:Connect(function(Deltatime)
		if CalculatePriorities(self, Priority, LimbName) and table.find(self.CharacterObject.Runtime[LimbName][Priority], RuntimeConnect) == 1 then
			
			Function(RunDelta, Repeats, Deltatime, RuntimeConnect)
			
		end
		RunDelta += Deltatime * self.PlaybackSpeed
		if self.Playing == false then
			RuntimeConnect:Disconnect()
		end
		
		if RunDelta >= self.Time then
			RunDelta = 0
			
			if not self.Loop then
				table.remove(self.CharacterObject.Runtime[LimbName][Priority], table.find(self.CharacterObject.Runtime[LimbName][Priority], RuntimeConnect))
				RuntimeConnect:Disconnect()
			end
			
			Repeats += 1
		end
		
	end)
	table.insert(self.CharacterObject.Runtime[LimbName][Priority], RuntimeConnect)
	self.RuntimePrivate[LimbName] = RuntimeConnect
	
end



return Main
