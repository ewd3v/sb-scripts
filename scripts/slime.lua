local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Sounds = {
	["Jump"] = {"rbxassetid://836796971", "rbxassetid://836797474"};
	["Land"] = "rbxassetid://344167846";
	["Smash"] = "rbxassetid://6306635390";
}

local SoundPlayer = nil
function PlaySound(Name,Position,Volume)
	if not Volume then
		Volume = 1
	end
	
	pcall(function()
		local SoundId = ""
		if Sounds[Name] then
			if typeof(Sounds[Name]) == "table" then
				SoundId = Sounds[Name][Random.new():NextInteger(1,#Sounds[Name])]
			else
				SoundId = Sounds[Name]
			end
		else
			SoundId = Name
		end

		local Player = Instance.new("SpawnLocation")
		Player.CanCollide = false
		Player.Anchored = true
		Player.Position = Position

		if not SoundPlayer then
			SoundPlayer = Instance.new("Sound")
		end
		
		xpcall(function()
			SoundPlayer.Parent = Player
		end,function()
			SoundPlayer:Destroy()
			SoundPlayer = Instance.new("Sound")
			SoundPlayer.Parent = Player
		end)
		
		SoundPlayer.SoundId = SoundId
		SoundPlayer.PlayOnRemove = true

		Player.Parent = Workspace
		SoundPlayer.Parent = nil
		Player:Destroy()
	end)
end

local Player = owner
local Character = Player.Character

task.wait()

if not Character then
	script:Destroy()
	error("No character exists.", 0)
end

for _, c in ipairs(Character:GetChildren()) do
	if c:IsA("BasePart") or c:IsA("Accessory") or c:IsA("Hat") then
		c:Destroy()
	end
end

script.Parent = Player.Character

local Size = 9
local Mass = Size ^ 3
local SizeDivMul = 1 / Size

local PrimaryColor = Color3.new()
local SecondaryColor = Color3.new()
local NametagText = Player.Name == Player.DisplayName and "@"..Player.Name or Player.DisplayName.." (@"..Player.Name..")"
do
	local PrimaryColors =
		{
			Color3.new(253/255, 41/255, 67/255), -- OK
			Color3.new(1/255, 152/255, 235/255), -- OK
			Color3.new(2/255, 184/255, 87/255), -- OK
			Color3.new(0.419608, 0.196078, 0.486275), -- OK
			Color3.new(0.854902, 0.521569, 0.254902), -- OK
			Color3.new(0.860784, 0.703922, 0.188235), -- OK
			Color3.new(0.859804, 0.629412, 0.684314), -- OK
			Color3.new(0.743137, 0.672549, 0.503922), -- 
		}
	local SecondaryColors =
		{
			Color3.new(147/255, 62/255, 87/255), --  OK
			Color3.new(30/255, 134/255, 155/255), -- OK
			Color3.fromRGB(87, 121, 85), -- OK
			Color3.new(0.319608, 0.236078, 0.386275), -- OK
			Color3.new(0.654902, 0.421569, 0.304902), -- OK
			Color3.new(0.560784, 0.503922, 0.188235), -- OK
			Color3.new(0.69804, 0.479412, 0.534314), -- OK
			Color3.new(0.643137, 0.572549, 0.503922), -- 
		}
	local function GetNameValue(pName)
		local value=0
		for index = 1,#pName do
			local cValue=string.byte(string.sub(pName,index,index))
			local reverseIndex=#pName-index+1
			if #pName%2==1 then
				reverseIndex=reverseIndex-1
			end
			if reverseIndex%4>=2 then
				cValue=-cValue
			end
			value=value+cValue
		end
		return value
	end
	PrimaryColor = PrimaryColors[(GetNameValue(Player.Name)%#PrimaryColors)+1]
	SecondaryColor = SecondaryColors[(GetNameValue(Player.Name)%#SecondaryColors)+1]
end

local TopHeight = Size - 1
local BottomCFrame = CFrame.new(0, 100, 0)

local TargetTopHeight = TopHeight
local TargetBottomCFrame = BottomCFrame

function Lerp(a, b, t)
	return a + (b - a) * t
end

local Inner = Instance.new("SpawnLocation")
Inner.Name = "Inner"
Inner.Color = PrimaryColor
Inner.Transparency = 0.5
Inner.Material = Enum.Material.Neon
Inner.Enabled = false
Inner.Parent = script

local Outer = Instance.new("SpawnLocation")
Outer.Name = "Outer"
Outer.Color = SecondaryColor
Outer.Transparency = 0.5
Outer.Material = Enum.Material.Neon
Outer.Enabled = false
Outer.Parent = script

local RightEye = Instance.new("SpawnLocation")
RightEye.Name = "RightEye"
RightEye.Color = Color3.fromRGB(0, 0, 0)
RightEye.Material = Enum.Material.Plastic
RightEye.Enabled = false
RightEye.Parent = script

local LeftEye = Instance.new("SpawnLocation")
LeftEye.Name = "LeftEye"
LeftEye.Color = Color3.fromRGB(0, 0, 0)
LeftEye.Material = Enum.Material.Plastic
LeftEye.Enabled = false
LeftEye.Parent = script

local Nametag = Instance.new("BillboardGui")
Nametag.Name = "Nametag"
Nametag.Adornee = Outer
Nametag.Size = UDim2.new(8, 0, 1.5, 0)
Nametag.StudsOffset = Vector3.new(0, Size * 0.5 + 2,0)
Nametag.Parent = Outer

local Text = Instance.new("TextBox")
Text.Name = "Text"
Text.TextEditable = false
Text.ClearTextOnFocus = false
Text.TextScaled = true
Text.Text = NametagText
Text.Size = UDim2.new(1, 0, 1, 0)
Text.BackgroundTransparency = 1
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextStrokeTransparency = 0
Text.Parent = Nametag

local InnerColor = nil
local OuterColor = nil

local RefitPart = {}
local PartEvents = {}
local PartData = {
	CFrame = {
		Inner = CFrame.identity;
		Outer = CFrame.identity;
		RightEye = CFrame.identity;
		LeftEye = CFrame.identity;
	};
	
	Size = {
		Inner = Vector3.zero;
		Outer = Vector3.zero;
		RightEye = Vector3.zero;
		LeftEye = Vector3.zero;
	};
}

local RemoteEvent = Instance.new("RemoteEvent", script)
RemoteEvent.OnServerEvent:Connect(function(_Player, Action, Data)
	if Player ~= _Player then
		return
	end
	
	if Action == "Set" then
		TargetTopHeight = Data[1]
		TargetBottomCFrame = Data[2]
	elseif Action == "PlaySound" then
		PlaySound(unpack(Data))
	elseif Action == "Smash" then
		PlaySound("Smash",Data,1)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	TopHeight = Lerp(TopHeight,TargetTopHeight, math.clamp(30 * dt, 0, 1))
	BottomCFrame = BottomCFrame:Lerp(TargetBottomCFrame, math.clamp(30 * dt, 0, 1))
	
	do
		local TopCFrame = BottomCFrame * CFrame.new(0, TopHeight, 0)
		
		local TopPosition = (TopCFrame * CFrame.new(0, 0.5, 0)).Position
		local BottomPosition = (BottomCFrame * CFrame.new(0,-0.5,0)).Position
		
		local Height = math.clamp((TopPosition - BottomPosition).Magnitude, 1, 100)
		local Width = math.clamp((Mass / Height) ^ 0.5, 1, 100)
		
		PartData.CFrame.Outer = BottomCFrame:Lerp(TopCFrame, 0.5)
		PartData.Size.Outer = Vector3.new(Width, Height, Width)
		
		PartData.CFrame.Inner = PartData.CFrame.Outer
		PartData.Size.Inner = PartData.Size.Outer - Vector3.new(1, 1, 1)
		
		PartData.CFrame.RightEye = PartData.CFrame.Outer * CFrame.new((2 * PartData.Size.Inner.X) * SizeDivMul, (1 * PartData.Size.Inner.Y) * SizeDivMul, -PartData.Size.Inner.Z * 0.5 - 0.075)
		PartData.Size.RightEye = Vector3.new((1.6 * PartData.Size.Inner.X) * SizeDivMul, (3 * PartData.Size.Inner.Y) * SizeDivMul, 0.15)
		
		PartData.CFrame.LeftEye = PartData.CFrame.Outer * CFrame.new((-2 * PartData.Size.Inner.X) * SizeDivMul, (1 * PartData.Size.Inner.Y) * SizeDivMul, -PartData.Size.Inner.Z * 0.5 - 0.075)
		PartData.Size.LeftEye = PartData.Size.RightEye
	end
	
	Inner.CFrame = PartData.CFrame.Inner
	Outer.CFrame = PartData.CFrame.Outer
	RightEye.CFrame = PartData.CFrame.RightEye
	LeftEye.CFrame = PartData.CFrame.LeftEye
	
	Inner.Size = PartData.Size.Inner
	Outer.Size = PartData.Size.Outer
	RightEye.Size = PartData.Size.RightEye
	LeftEye.Size = PartData.Size.LeftEye
end)

Character.AncestryChanged:Connect(function()
	if Character.Parent ~= nil then
		return
	end
	
	warn("Please say g/no. to fully stop the script.")
	script:Destroy()
end)

local Client = NLS([==[
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera

repeat RunService.RenderStepped:Wait() until script:GetAttribute("Ready") == true

local Size = tonumber(script:GetAttribute("Size"))
local Mass = tonumber(script:GetAttribute("Mass"))
local SizeDivMul = 1 / Size

local ServerScript = script.Parent
local Character = ServerScript.Parent

local RemoteEvent = ServerScript:FindFirstChildOfClass("RemoteEvent")
local Inner = ServerScript:WaitForChild("Inner")
local Outer = ServerScript:WaitForChild("Outer")
local RightEye = ServerScript:WaitForChild("RightEye")
local LeftEye = ServerScript:WaitForChild("LeftEye")

local Bottom = Instance.new("SpawnLocation")
Bottom.CFrame = CFrame.new(0, 100, 0)
Bottom.Transparency = 1
Bottom.Enabled = false
Bottom.Parent = script

local Top = Instance.new("SpawnLocation")
Top.CFrame = CFrame.new(0, 100 + Size - 1, 0)
Top.Transparency = 1
Top.Enabled = false
Top.Parent = script

local Attachment0 = Instance.new("Attachment")
Attachment0.Position = Vector3.new(0, 0.5, 0)
Attachment0.Orientation = Vector3.new(0, 0, 90)
Attachment0.Parent = Bottom

local Attachment1 = Instance.new("Attachment")
Attachment1.Position = Vector3.new(0, -0.5, 0)
Attachment1.Orientation = Vector3.new(0, 0, 90)
Attachment1.Parent = Top

local Spring = Instance.new("SpringConstraint")
Spring.Visible = false
Spring.Damping = 200
Spring.FreeLength = 8
Spring.LimitsEnabled = true
Spring.MaxForce = math.huge
Spring.Stiffness = 7000
Spring.MaxLength = 15
Spring.MinLength = 2
Spring.Attachment0 = Attachment0
Spring.Attachment1 = Attachment1
Spring.Parent = Bottom

local Prismatic = Instance.new("PrismaticConstraint")
Prismatic.Visible = false
Prismatic.Attachment0 = Attachment0
Prismatic.Attachment1 = Attachment1
Prismatic.Parent = Bottom

local BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = Vector3.new(1, 1, 1) * math.huge
BodyGyro.D = 100
BodyGyro.CFrame = CFrame.new()
BodyGyro.Parent = Bottom

local Wall1 = Instance.new("SpawnLocation")
Wall1.Massless = true
Wall1.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
Wall1.Transparency = 1
Wall1.Enabled = false
Wall1.Parent = Bottom

local Weld1 = Instance.new("Weld")
Weld1.Part0 = Bottom
Weld1.Part1 = Wall1
Weld1.Parent = Wall1

local Wall2 = Instance.new("SpawnLocation")
Wall2.Massless = true
Wall2.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
Wall2.Transparency = 1
Wall2.Enabled = false
Wall2.Parent = Bottom

local Weld2 = Instance.new("Weld")
Weld2.Part0 = Bottom
Weld2.Part1 = Wall2
Weld2.Parent = Wall2

local Wall3 = Instance.new("SpawnLocation")
Wall3.Massless = true
Wall3.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
Wall3.Transparency = 1
Wall3.Enabled = false
Wall3.Parent = Bottom

local Weld3 = Instance.new("Weld")
Weld3.Part0 = Bottom
Weld3.Part1 = Wall3
Weld3.Parent = Wall3

local Wall4 = Instance.new("SpawnLocation")
Wall4.Massless = true
Wall4.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
Wall4.Transparency = 1
Wall4.Enabled = false
Wall4.Parent = Bottom

local Weld4 = Instance.new("Weld")
Weld4.Part0 = Bottom
Weld4.Part1 = Wall4
Weld4.Parent = Wall4

local NoCollide = {Top,Bottom,Wall1,Wall2,Wall3,Wall4}

for _, i in ipairs(NoCollide) do
	for _, o in ipairs(NoCollide) do
		if i ~= o then
			local NCC = Instance.new("NoCollisionConstraint")
			NCC.Enabled = true
			NCC.Part0 = i
			NCC.Part1 = o
			NCC.Parent = i
		end
	end
end

local PartData = {
	CFrame = {
		Inner = CFrame.identity;
		Outer = CFrame.identity;
		RightEye = CFrame.identity;
		LeftEye = CFrame.identity;
	};

	Size = {
		Inner = Vector3.zero;
		Outer = Vector3.zero;
		RightEye = Vector3.zero;
		LeftEye = Vector3.zero;
	};
}

function ToSpawn()
	local r = 30
	local X = math.random(-r, r)
	local Z = math.random(-r, r)
	
	Bottom.Anchored = true
	Top.Anchored = true
	
	task.delay(0.1, function()
		Bottom.Anchored = false
		Top.Anchored = false
		
		Bottom.Velocity = Vector3.new()
		Top.Velocity = Vector3.new()
	end)
	
	Bottom.CFrame = CFrame.new(X, 100, Z)
	Top.CFrame = CFrame.new(X, 100 + Size - 1, Z)
	
	Bottom.Velocity = Vector3.new()
	Top.Velocity = Vector3.new()
	
	local bp1 = Instance.new("BodyPosition", Bottom)
	bp1.MaxForce = Vector3.new(1, 1, 1) * math.huge
	bp1.Position = Bottom.Position
	
	local bp2 = Instance.new("BodyPosition", Top)
	bp2.MaxForce = Vector3.new(1, 1, 1) * math.huge
	bp2.Position = Top.Position
	
	Debris:AddItem(bp1, 1)
	Debris:AddItem(bp2, 1)
end

function PlaySound(...)
	RemoteEvent:FireServer("PlaySound", {...})
end

ToSpawn()

local CameraPart = Instance.new("Part")
CameraPart:Destroy()

local LookPart = Instance.new("Part")
LookPart:Destroy()

local MouseHitPosition = Mouse.Hit.Position

local MouseRaycastParams = RaycastParams.new()
MouseRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
MouseRaycastParams.IgnoreWater = true

local GroundRaycastParams = RaycastParams.new()
GroundRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
GroundRaycastParams.IgnoreWater = true

local LastLand = tick()
local LastOnGround = tick()

local OnGround = false
local Smashing = false
local Crouch = false

RunService.RenderStepped:Connect(function(dt)
	Camera = Workspace.CurrentCamera
	
	local RayIgnore = {Top, Bottom, Wall1, Wall2, Wall3, Wall4, CameraPart, LookPart, Inner, Outer, RightEye, LeftEye}
	
	do
		local Position = UIS:GetMouseLocation()
		local ray = Camera:ViewportPointToRay(Position.X, Position.Y)
		
		local Result = nil
		local i = 0
		local Cast
		Cast = function()
			i = i + 1
			
			if i > 50 then
				return
			end
			
			MouseRaycastParams.FilterDescendantsInstances = RayIgnore
			
			local _Result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, MouseRaycastParams)
			if _Result then
				if _Result.Instance.CanCollide == false then
					table.insert(RayIgnore, _Result.Instance)
					
					Cast()
				else
					Result = _Result
				end
			end
		end
		Cast()
		
		if Result and Result.Position then
			MouseHitPosition = Result.Position
		else
			MouseHitPosition = Mouse.Hit.Position
		end
	end
	
	do
		local TopPosition = (Top.CFrame * CFrame.new(0, 0.5, 0)).Position
		local BottomPosition = (Bottom.CFrame * CFrame.new(0, -0.5, 0)).Position

		local Height = math.clamp((TopPosition - BottomPosition).Magnitude, 0.1, 2000)
		local Width = math.clamp((Mass / Height) ^ 0.5, 0.1, 2000)
		
		Top.Size = Vector3.new(Width, 1, Width)
		Bottom.Size = Vector3.new(Width, 1, Width)
		
		local function SetWall(Wall,Weld,Rotation)
			Wall.Size = Vector3.new(Width, Height - 1, 1)
			Weld.C0 = CFrame.Angles(0, math.rad(Rotation), 0) * CFrame.new(0,Wall.Size.Y * 0.5,-Width * 0.5)
		end
		
		SetWall(Wall1, Weld1, 0)
		SetWall(Wall2, Weld2, 90)
		SetWall(Wall3, Weld3, 180)
		SetWall(Wall4, Weld4, 270)
		
		PartData.CFrame.Outer = Bottom.CFrame:Lerp(Top.CFrame, 0.5)
		PartData.Size.Outer = Vector3.new(Width, Height, Width)

		PartData.CFrame.Inner = PartData.CFrame.Outer
		PartData.Size.Inner = PartData.Size.Outer - Vector3.new(1, 1, 1)

		PartData.CFrame.RightEye = PartData.CFrame.Outer * CFrame.new((2 * PartData.Size.Inner.X) * SizeDivMul, (1 * PartData.Size.Inner.Y) * SizeDivMul, -PartData.Size.Inner.Z * 0.5 - 0.075)
		PartData.Size.RightEye = Vector3.new((1.6 * PartData.Size.Inner.X) * SizeDivMul, (3 * PartData.Size.Inner.Y) * SizeDivMul, 0.15)

		PartData.CFrame.LeftEye = PartData.CFrame.Outer * CFrame.new((-2 * PartData.Size.Inner.X) * SizeDivMul, (1 * PartData.Size.Inner.Y) * SizeDivMul, -PartData.Size.Inner.Z * 0.5 - 0.075)
		PartData.Size.LeftEye = PartData.Size.RightEye
	end

	Inner.CFrame = PartData.CFrame.Inner
	Outer.CFrame = PartData.CFrame.Outer
	RightEye.CFrame = PartData.CFrame.RightEye
	LeftEye.CFrame = PartData.CFrame.LeftEye

	Inner.Size = PartData.Size.Inner
	Outer.Size = PartData.Size.Outer
	RightEye.Size = PartData.Size.RightEye
	LeftEye.Size = PartData.Size.LeftEye
	
	LookPart.CFrame = Camera.CFrame
	LookPart.Position = Bottom.Position
	LookPart.Orientation = Vector3.new(0, LookPart.Orientation.Y, 0)
	
	do
		local Result = nil
		local i = 0
		local Cast
		Cast = function()
			i = i + 1
			
			if i > 50 then
				return
			end
			
			GroundRaycastParams.FilterDescendantsInstances = RayIgnore
			
			local _Result = Workspace:Raycast(Bottom.Position, Vector3.new(0, -Bottom.Size.Y * 0.5 - (Smashing and 0.75 or 0.1), 0), GroundRaycastParams)
			if _Result then
				if _Result.Instance.CanCollide == false then
					table.insert(RayIgnore,_Result.Instance)
					
					Cast()
				else
					Result = _Result
				end
			end
		end
		Cast()
		
		if Result and Result.Instance then
			if OnGround == false then
				if tick() - LastLand >= 0.1 and not Smashing then
					LastLand = tick()
					
					PlaySound("Land", Bottom.Position, 1)
				end
			end
			if Smashing then
				Smashing = false
				RemoteEvent:FireServer("Smash", Bottom.Position)
			end
			
			OnGround = true
			LastOnGround = tick()
		else
			OnGround = false
		end
	end
	
	Crouch = UIS:GetFocusedTextBox() == nil and UIS:IsKeyDown(Enum.KeyCode.LeftControl)
	if Crouch and not OnGround and tick() - LastOnGround > 0.3 then
		Smashing = true
	end
	
	if Smashing then
		Bottom.Velocity = Vector3.new(Bottom.Velocity.X, -(125 + (30 * (tick() - LastOnGround))), Bottom.Velocity.Z)
	end
	
	do
		if UIS:GetFocusedTextBox() == nil then
			local Speed = OnGround and (Crouch and 3.5 or 7) or (Crouch and 15 or 20)
			
			local X = 0
			local Z = 0
			
			local WS = 0
			if UIS:IsKeyDown(Enum.KeyCode.W) then WS = WS + 1 end
			if UIS:IsKeyDown(Enum.KeyCode.S) then WS = WS - 1 end
			
			local AD = 0
			if UIS:IsKeyDown(Enum.KeyCode.A) then AD = AD + 1 end
			if UIS:IsKeyDown(Enum.KeyCode.D) then AD = AD - 1 end
			
			if WS ~= 0 then
				if UIS:IsKeyDown(Enum.KeyCode.W) then
					local Velocity = LookPart.CFrame.LookVector * Speed
					X = X + Velocity.X
					Z = Z + Velocity.Z
				elseif UIS:IsKeyDown(Enum.KeyCode.S) then
					local Velocity = LookPart.CFrame.LookVector * -Speed
					X = X + Velocity.X
					Z = Z + Velocity.Z
				end
			end
			
			if AD ~= 0 then
				if UIS:IsKeyDown(Enum.KeyCode.A) then
					local Velocity = LookPart.CFrame.RightVector * -Speed
					X = X + Velocity.X
					Z = Z + Velocity.Z
				elseif UIS:IsKeyDown(Enum.KeyCode.D) then
					local Velocity = LookPart.CFrame.RightVector * Speed
					X = X + Velocity.X
					Z = Z + Velocity.Z
				end
			end
			
			if not OnGround and X == 0 and Z == 0 then
				X = Bottom.Velocity.X
				Z = Bottom.Velocity.Z
			end

			Bottom.Velocity = Vector3.new(X, Bottom.Velocity.Y, Z)
			
			if UIS:IsKeyDown(Enum.KeyCode.Space) and OnGround then
				OnGround = false
				Bottom.Velocity = Vector3.new(Bottom.Velocity.X,Crouch and 100 or 150, Bottom.Velocity.Z)
				
				PlaySound("Jump",Bottom.Position,3)
			end
		else
			if OnGround then
				Bottom.Velocity = Vector3.new(0, Bottom.Velocity.Y, 0)
			end
		end
	end
	
	Spring.FreeLength = Crouch and 5.75 or 8
	
	if Bottom.Position.Y <= Workspace.FallenPartsDestroyHeight + 30 or Top.Position.Y <= Workspace.FallenPartsDestroyHeight + 30 then
		ToSpawn()
	end
	
	Camera.CameraSubject = CameraPart
	Camera.CameraType = Enum.CameraType.Custom
	Player.CameraMode = Enum.CameraMode.Classic
	
	BodyGyro.CFrame = CFrame.new(Bottom.Position * Vector3.new(1, 0, 1), MouseHitPosition * Vector3.new(1, 0, 1))
end)

RunService.Heartbeat:Connect(function(dt)
	CameraPart.CFrame = CameraPart.CFrame:Lerp(Bottom.CFrame:Lerp(Top.CFrame, 0.5), math.clamp(12 * dt, 0, 1))
	
	RemoteEvent:FireServer("Set", {(Bottom.Position - Top.Position).Magnitude, Bottom.CFrame})
end)

UIS.InputBegan:Connect(function(io)
	if UIS:GetFocusedTextBox() ~= nil then return end
	
	local KeyCode = io.KeyCode
	if KeyCode then
		if KeyCode == Enum.KeyCode.Q then
			ToSpawn()
		end
	end
end)
]==], script)

Client:SetAttribute("Size", Size)
Client:SetAttribute("Mass", Mass)
Client:SetAttribute("Ready", true)

print("Slime loaded! Created by ew_001.\nSay 'g/r no.' to respawn, the 'no.' is to clear up the script.")
