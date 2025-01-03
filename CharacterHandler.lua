local Main = {}
Main.Functions = {}
Main.Objects = {}
Main.__index = Main.Functions

function Main:CreateCharacterObject(Character)
	
	if Main.Objects[Character.Name] ~= nil then
		return Main.Objects[Character.Name]
	end
	
	local CharacterObject = setmetatable({}, Main)
	CharacterObject.Character = Character
	
	local Motors = {}
	local DefaultC0 = {}
	local RuntimePrep = {}
	
	for _, Motor:Motor6D in pairs( Character:GetDescendants() ) do
		if Motor:IsA("Motor6D") then
			Motors[Motor.Part1.Name] = Motor
			DefaultC0[Motor.Part1.Name] = Motor.C0
			RuntimePrep[Motor.Part1.Name] = {}
		end
	end
	
	CharacterObject.Motors = Motors
	CharacterObject.DefaultC0 = DefaultC0
	CharacterObject.Runtime = RuntimePrep
	
	Main.Objects[Character.Name] = CharacterObject
	
	Character:FindFirstChildOfClass("Humanoid").Died:Once(function()
		Main.Objects[Character.Name] = nil
	end)
	
	return CharacterObject
end


return Main
