getgenv().XSI_LOADED = nil
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/xsinew/scripts/main/Fluent.lua"))()
local crypt = loadstring(game:HttpGet("https://raw.githubusercontent.com/jqqqi/Lua-HMAC-SHA256/master/sha256.lua"))()
local RunService= game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local WorkingPlaces = {
	["18260029786"] = {
		"팽부대",
		nil
	},
	["5470087938"] = {
		"운테르게임",
		nil
	}
}

local carbonResource
local Remotes = {}

local Options = Fluent.Options

-- print("Server Response: " .. response)

local Window = Fluent:CreateWindow({
	Title = "Dynamic Script",
	SubTitle = "by xsinew",
	TabWidth = 160,
	Size = UDim2.fromOffset(560, 400),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
})

local CLICK_STATUS = {
	KILL = false,
	EXPLODE = false,
	FLING = false
}

local LOOP_STATUS = {
	ICE = false,
	LAGSERVER = false,
	GRABP1 = false,
	SUCIDEP1 = false,
}

local targetText = {
	LocalPlayer.Name,
	LocalPlayer.DisplayName
}

function HideMe(char)
	for idx, obj in pairs(workspace:GetDescendants()) do
		pcall(function()
			if table.find(targetText, obj.Text) then
				obj.Text = "Dynamic Developer"
			end
		end)
	end

	local RealCharacter = char
	local fakeCharacter = Players:CreateHumanoidModelFromUserId(1700571242)
	
	fakeCharacter.Name = LocalPlayer.Name
	LocalPlayer.Character = fakeCharacter
	fakeCharacter.Parent = workspace 
	fakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
	for _, object in ipairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do
		local newObject = object:Clone()
		newObject.Parent = fakeCharacter
	end
	RealCharacter.HumanoidRootPart.Anchored = true
	RealCharacter.HumanoidRootPart.CFrame = CFrame.new(1000, -500, 1000)
end

function startswith(target, str)
	return target:find('^' .. str) ~= nil
end

function CheckPlayer(part)
	if part.ClassName == "Workspace" then
		return false
	elseif Players:GetPlayerFromCharacter(part.Parent) then
		return Players:GetPlayerFromCharacter(part.Parent)
	else
		return CheckPlayer(part.Parent)
	end
end

function GetPlayer(text)
	local resultPlayer = nil
	for i, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name):sub(1, #text) == string.lower(text) then
			resultPlayer = player
			break
		end
	end

	return resultPlayer
end

function CheckACS()
	local ACS_Engine = game:GetService('ReplicatedStorage'):FindFirstChild('ACS_Engine')

	return ACS_Engine and true or false
end

function LoadACS()
	local Remotes = game:GetService('ReplicatedStorage')['ACS_Engine'].Events

	local CURRENT_SIZE = {
		X = 10,
		Y = 10,
		Z = 10
	}
	local CURRENT_KEY = Enum.KeyCode.R
	local ON_PLACEBLOCK
	
	local AcessId = Remotes:FindFirstChild("AcessId") and Remotes["AcessId"]:InvokeServer(LocalPlayer.UserId) or Remotes["encrypted2436"]:InvokeServer(LocalPlayer.UserId)
	local DamageFunction = Remotes:FindFirstChild("Damage") or Remotes["encrypted6975"]
	local BuildEvent = Remotes:FindFirstChild("Breach") or Remotes["encrypted0092"]
	
	local method = {
	    minDamageMod=150,
	    DamageMod=150
	}
	
	local function TakeDamage(human, st)
	    local gun = ReplicatedStorage:FindFirstChild("ACS_Settings", true).Parent
	    DamageFunction:InvokeServer(gun, human, 25, 1, require(gun.ACS_Settings), st, nil, nil, AcessId .. "-" .. tostring(LocalPlayer.UserId))
	end
	
	local function Kill(target)
	    local char = target.Character
	    if not char then return end
	    
	    local human = char:FindFirstChild("Humanoid")
	    if not human or human.Health < 1 then return end
	    
	    TakeDamage(human, method)
	end

	local function PlaceBlock(Pos, Size)
		Remotes["Refil"]:FireServer(LocalPlayer.Character.ACS_Client.Kit.Fortifications, -99999999)
		BuildEvent:InvokeServer(3,{Fortified={},Destroyable=workspace},CFrame.new(),CFrame.new(),{CFrame=Pos,Size=Size})
	end

	local Main = Window:AddTab({ Title = "ACS Engine", Icon = "" })

	Main:AddParagraph({
		Title = "ACS엔진",
		Content = "ACS엔진을 찾았습니다.\n아래 기능들을 사용할 수 있습니다."
	})
	
	Main:AddButton({
	    Title = "Kill All",
	    Description = "모든 플레이어를 죽입니다",
	    Callback = function()
	        for idx, plr in pairs(Players:GetPlayers()) do
	            if plr ~= LocalPlayer then
	                task.spawn(Kill, plr)
	            end
	        end
	    end
	})
	
	Main:AddButton({
	    Title = "Kill Others",
	    Description = "플레이어를 제외한 다른 객체들을 죽입니다.",
	    Callback = function()
            for idx,obj in pairs(workspace:GetDescendants()) do pcall(function()
                    if obj:IsA("Humanoid") and not Players:FindFirstChild(obj.Parent.Name) then
                        task.spawn(TakeDamage, obj, method)
                    end
                end)
            end
	    end
	})

	local INPUT_X_SIZE = Main:AddInput("INPUT_X_SIZE", {
        Title = "블럭 X사이즈",
        Default = "10",
        Placeholder = "최소크기 3",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
			local Value = tonumber(Value)
            if Value < 3 then
				Value = 3
			end
			rawset(CURRENT_SIZE, "X", Value)
        end
    })

	local INPUT_Y_SIZE = Main:AddInput("INPUT_Y_SIZE", {
        Title = "블럭 Y사이즈",
        Default = "10",
        Placeholder = "최소크기 3",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
			local Value = tonumber(Value)
            if Value < 3 then
				Value = 3
			end
			rawset(CURRENT_SIZE, "Y", Value)
        end
    })

	local INPUT_Z_SIZE = Main:AddInput("INPUT_Z_SIZE", {
        Title = "블럭 Z사이즈",
        Default = "10",
        Placeholder = "최소크기 3",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
			local Value = tonumber(Value)
            if Value < 3 then
				Value = 3
			end
			rawset(CURRENT_SIZE, "Z", Value)
        end
    })

	local TOGGLE_PLACEBLOCK = Main:AddToggle("TOGGLE_PLACEBLOCK", {Title = "Toggle", Default = false })

    TOGGLE_PLACEBLOCK:OnChanged(function()
        ON_PLACEBLOCK = Options.TOGGLE_PLACEBLOCK.Value
    end)

	local KEYBIND_PLACE = Main:AddKeybind("KEYBIND_PLACE", {
        Title = "블럭설치키",
        Mode = "Hold",
        Default = "R",
        ChangedCallback = function(New)
            CURRENT_KEY = New
        end
    })

	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent or not ON_PLACEBLOCK then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CURRENT_KEY then
			PlaceBlock(Mouse.Hit, CURRENT_SIZE)
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			PlaceBlock(Mouse.Hit, CURRENT_SIZE)
		end
	end)
end

function LoadCarbon()
	function KillPlayer(player)
		local char = player.Character
		local humanoid = char:FindFirstChild("Humanoid")
		local key = {"nil", "Auth", "nil", "nil"}
		Remotes["DamageEvent"]:FireServer(humanoid, 100, "Head", key)
	end
	
	function ExplodePos(pos, justLag)
		if justLag == true then
			print("JustLag")
			Remotes["ExplosiveEvent"]:FireServer("Xsi-On-Top", pos, 0, 0, 0, nil, nil, nil, nil, nil, nil,nil, "Auth", nil)
		else
			print("Kill")
			Remotes["ExplosiveEvent"]:FireServer("Xsi-On-Top", pos, 500000, 120, 120, nil, nil, nil, nil, nil, nil,nil, "Auth", nil)
		end
	end
	
	function MouseEvent()
		local targetP = Mouse.Target
		local target = CheckPlayer(targetP)
		if CLICK_STATUS["EXPLODE"] == true then
			ExplodePos(Mouse.Hit.p)
		elseif CLICK_STATUS["KILL"] == true and target then
			KillPlayer(target)
		end
	end
	Mouse.Button1Down:Connect(MouseEvent)

	function CarbonKillAll()
		if not carbonResource then
			return
		end
	
		for idx, player in pairs(Players:GetPlayers()) do
			local char = player.Character
			if player ~= LocalPlayer and char then
				xpcall(function()
					Remotes["DamageEvent"]:FireServer(char:FindFirstChildOfClass("Humanoid"), math.huge, "Head", {"nil", "Auth", "nil", "nil"})
				end, function(err)
					warn([[
		건킷종합스크 - 크시
	
		오류: ]]..err)
				end)
			end
		end
		local char = LocalPlayer.Character
		xpcall(function()
			Remotes["DamageEvent"]:FireServer(char:FindFirstChildOfClass("Humanoid"), math.huge, "Head", {"nil", "Auth", "nil", "nil"})
		end, function(err)
			warn([[
	건킷종합스크 - 크시
	
	오류: ]]..err)
		end)
	end
	
	function CarbonExplodeAll(justLag)
		for idx, player in pairs(Players:getPlayers()) do
			local char = player.Character
			if char then
				xpcall(function()
					ExplodePos(char.HumanoidRootPart.Position, justLag)
				end, function(err)
					warn([[
		건킷종합스크 - 크시
		
		오류: ]]..err)
				end)
			end
		end
	end
	
	function CarbonHitAll()
		if not carbonResource then
			return
		end
	
		for idx, player in pairs(Players:GetPlayers()) do
			local char = LocalPlayer.Character
			if char then
				xpcall(function()
					Remotes["HitEvent"]:FireServer(char:FindFirstChild("HumanoidRootPart").Position, Vector3.new(0, 0, 0), 10, nil, "Auth", "Part", char:FindFirstChild("Head"))
				end, function(err)
					warn([[
		건킷종합스크 - 크시
		
		오류: ]]..err)
				end)
			end
		end
	end

	local Main = Window:AddTab({ Title = "Carbon", Icon = "" })

	Main:AddParagraph({
		Title = "카본엔진",
		Content = "카본엔진을 찾았습니다.\n아래 기능들을 사용할 수 있습니다."
	})

	Main:AddButton({
		Title = "Kill All",
		Description = "모든 플레이어를 죽입니다",
		Callback = function()
			CarbonKillAll()
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "킬올을 실행했습니다",
				Duration = 5
			})
		end
	})

	Main:AddButton({
		Title = "Explode All",
		Description = "모든 플레이어를 죽입니다",
		Callback = function()
			CarbonExplodeAll(false)
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "폭발을 실행했습니다",
				Duration = 5
			})
		end
	})

	local CLICKEVENT_KILL = Main:AddToggle("CLICKEVENT_KILL", {
		Title = "Click Kill",
		Description = "마우스 클릭으로 플레이어를 죽입니다",
		Default = false
	})

	local CLICKEVENT_EXPLODE = Main:AddToggle("CLICKEVENT_EXPLODE", {
		Title = "Click Explode",
		Description = "마우스 클릭 위치에 폭팔을 생성합니다",
		Default = false
	})

	CLICKEVENT_KILL:OnChanged(function()
		if Options.CLICKEVENT_KILL.Value then
			Options.CLICKEVENT_EXPLODE:SetValue(false)
			CLICK_STATUS["EXPLODE"] = false
		end
		CLICK_STATUS["KILL"] = Options.CLICKEVENT_KILL.Value
	end)

	CLICKEVENT_EXPLODE:OnChanged(function()
		if Options.CLICKEVENT_EXPLODE.Value then
			Options.CLICKEVENT_KILL:SetValue(false)
			CLICK_STATUS["KILL"] = false
		end
		CLICK_STATUS["EXPLODE"] = Options.CLICKEVENT_EXPLODE.Value
	end)

	local LOOPEVENT_LAGSERVER = Main:AddToggle("LOOPEVENT_LAGSERVER", {
		Title = "Lag Server",
		Description = "서버에 부하를 겁니다.",
		Default = false
	})

	LOOPEVENT_LAGSERVER:OnChanged(function()
		if Options.LOOPEVENT_LAGSERVER.Value then
			Options.CLICKEVENT_EXPLODE:SetValue(false)
			CLICK_STATUS["EXPLODE"] = false
		end
		LOOP_STATUS["LAGSERVER"] = Options.LOOPEVENT_LAGSERVER.Value
	end)

	CLICKEVENT_EXPLODE:OnChanged(function()
		if Options.CLICKEVENT_EXPLODE.Value then
			Options.CLICKEVENT_KILL:SetValue(false)
			CLICK_STATUS["KILL"] = false
		end
		CLICK_STATUS["EXPLODE"] = Options.CLICKEVENT_EXPLODE.Value
	end)
	
	local KILL_INPUT = Main:AddInput("Input", {
		Title = "Kill Player",
		Default = "",
		Placeholder = "Enter Player Name",
		Numeric = false,
		Finished = true
	})
	
	KILL_INPUT:OnChanged(function()
		if KILL_INPUT.Value == "" then return end
		local target = GetPlayer(KILL_INPUT.Value)

		if not target then
			Fluent:Notify({
				Title="Dynamic Handler",
				Content="Cannot found player!",
				Duration=5
			})
			return
		end

		KillPlayer(target)
		KILL_INPUT:SetValue("")

		Fluent:Notify({
			Title="Dynamic Handler",
			Content="Kill -> "..target.Name,
			Duration=5
		})
	end)

	local EXPLODE_INPUT = Main:AddInput("Input", {
		Title = "Explode Player",
		Default = "",
		Placeholder = "Enter Player Name",
		Numeric = false,
		Finished = true
	})
	
	EXPLODE_INPUT:OnChanged(function()
		if EXPLODE_INPUT.Value == "" then return end
		local target = GetPlayer(EXPLODE_INPUT.Value)

		if not target then
			Fluent:Notify({
				Title="Dynamic Handler",
				Content="Cannot found player!",
				Duration=5
			})
			return
		end

		local char = target.Character or target.CharacterAdded:Wait()
		ExplodePos(char:WaitForChild("Torso").Position)
		EXPLODE_INPUT:SetValue("")

		Fluent:Notify({
			Title="Dynamic Handler",
			Content="Explode -> "..target.Name,
			Duration=5
		})
	end)

	RunService.RenderStepped:Connect(function()
		if LOOP_STATUS["LAGSERVER"] then
			task.spawn(function()
				RunService.RenderStepped:Connect(function()
					CarbonExplodeAll(true)
				end)
			end)
		end
	end)
end

function CheckCarbon()
	carbonResource = ReplicatedStorage:FindFirstChild("CarbonResource") or nil

	if not carbonResource then return end
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

	if char then
		local oldPos = char:WaitForChild("HumanoidRootPart").CFrame
		local h = char:WaitForChild("Humanoid")
		table.foreach(char:GetDescendants(), function (key, value)
			if value.ClassName == "Part" or value.ClassName == "BasePart" then
				value.Anchored = true
			end
		end)
		h.Health = 0

		repeat
			task.wait()
		until carbonResource:WaitForChild("Events"):GetChildren()[1].Name ~= ""

		if game.PlaceId == 13785298879 then
			for idx, remote in pairs(game:GetService("ReplicatedFirst").CarbonResource:WaitForChild("Events"):GetChildren()) do
				warn(remote.Name)
				Remotes[remote.Name] = remote
			end
		else
			for idx, remote in pairs(carbonResource:WaitForChild("Events"):GetChildren()) do
				warn(remote.Name)
				Remotes[remote.Name] = remote
			end
		end

		task.spawn(function()
			LocalPlayer.CharacterAdded:Wait()
			LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = oldPos
		end)

		return true
	end
	return false
end

WorkingPlaces["18260029786"][2] = function()
	local RemoteFunction = ReplicatedStorage:FindFirstChild("InflictTarget",true)
	local flingPower = 10000

	function Gun()
		return ReplicatedStorage.AWP
	end
	
	function GetRandomPlayer(target)
		local resultPlayer = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
	
		repeat
			resultPlayer = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
		until resultPlayer ~= target and resultPlayer.UserId ~= 0x14C7A9A28
	
		return resultPlayer
	end
	
	function KillPlayer(target)
		local gun = Gun()
		RemoteFunction:InvokeServer(gun, GetRandomPlayer(target), target.Character.Humanoid, target.Character.HumanoidRootPart, math.huge, { 0, 0, false, false, gun.GunScript_Server.IgniteScript, gun.GunScript_Server.IcifyScript, 100, 100 }, { false, 5, 3 }, target.Character.Head, { false, { 1930359546 }, 1, 1.5 })
	end

	function IcePlayer(target)
		local gun = Gun()
		RemoteFunction:InvokeServer(gun, GetRandomPlayer(target), target.Character.Humanoid, target.Character.HumanoidRootPart, 0, { 0, 0, false, true, gun.GunScript_Server.IgniteScript, gun.GunScript_Server.IcifyScript, 100, 100 }, { false, 5, 3 }, target.Character.Head, { false, { 1930359546 }, 1, 1.5 })
	end

	function FlingPlayer(target)
		local gun = Gun()
		RemoteFunction:InvokeServer(gun, GetRandomPlayer(target), target.Character.Humanoid, target.Character.HumanoidRootPart, 0, { flingPower, 0, false, false, gun.GunScript_Server.IgniteScript, gun.GunScript_Server.IcifyScript, 100, 100 }, { false, 5, 3 }, target.Character.Head, { false, { 1930359546 }, 1, 1.5 })
	end
	
	function MouseEvent()
		local targetP = Mouse.Target
		local target = CheckPlayer(targetP)
		if CLICK_STATUS["KILL"] == true and target then
			KillPlayer(target)
		elseif CLICK_STATUS["FLING"] == true and target then
			FlingPlayer(target)
		end
	end
	Mouse.Button1Down:Connect(MouseEvent)

	function FangKillAll()
		for i,plr in pairs(Players:GetPlayers()) do
			if plr ~= Players.LocalPlayer then
				task.spawn(function()
					pcall(KillPlayer, plr)
				end)
			end
		end
		task.wait(0.5)
		pcall(KillPlayer, Players.LocalPlayer)
		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "킬올을 실행했습니다",
			Duration = 5
		})
	end

	function FangFlingAll()
		for i,plr in pairs(Players:GetPlayers()) do
			task.spawn(function ()
				for i=1, 15 do
					pcall(FlingPlayer, plr)
					task.wait()
				end
			end)
		end
		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "플링올을 실행했습니다",
			Duration = 5
		})
	end

	local Main = Window:AddTab({ Title = "팽부대", Icon = "" })

	Main:AddParagraph({
		Title = "팽부대",
		Content = "팽부대에 들어와있습니다.\n아래 기능들을 사용할 수 있습니다."
	})

	Main:AddButton({
		Title = "Kill All",
		Description = "모든 플레이어를 죽입니다",
		Callback = function()
			FangKillAll()
		end
	})

	Main:AddButton({
		Title = "Fling All",
		Description = "모든 플레이어를 날립니다",
		Callback = function()
			FangFlingAll()
		end
	})

	local SLIDER_FLINGPOWER = Main:AddSlider("SLIDER_FLINGPOWER", {
        Title = "Fling Power",
        Description = "사람을 날리는 힘을 조절합니다",
        Default = flingPower,
        Min = 1,
        Max = 99999,
        Rounding = 0,
        Callback = function(Value)
            flingPower = Value
        end
    })

	local CLICKEVENT_KILL = Main:AddToggle("CLICKEVENT_KILL", {
		Title = "Click Kill",
		Description = "마우스 클릭으로 플레이어를 죽입니다",
		Default = false
	})

	CLICKEVENT_KILL:OnChanged(function()
		CLICK_STATUS["KILL"] = Options.CLICKEVENT_KILL.Value
	end)

	local CLICKEVENT_FLING = Main:AddToggle("CLICKEVENT_FLING", {
		Title = "Click Fling",
		Description = "클릭한 플레이어를 날립니다.",
		Default = false
	})

	CLICKEVENT_FLING:OnChanged(function()
		CLICK_STATUS["FLING"] = Options.CLICKEVENT_FLING.Value
	end)

	local CLICKEVENT_ICE = Main:AddToggle("CLICKEVENT_ICE", {
		Title = "Ice All",
		Description = "모든 플레이어를 얼립니다.",
		Default = false
	})

	CLICKEVENT_ICE:OnChanged(function()
		LOOP_STATUS["ICE"] = Options.CLICKEVENT_ICE.Value
	end)

	local KILL_INPUT = Main:AddInput("Input", {
		Title = "Kill Player",
		Default = "",
		Placeholder = "Enter Player Name",
		Numeric = false,
		Finished = true
	})
	
	KILL_INPUT:OnChanged(function()
		if KILL_INPUT.Value == "" then return end
		local target = GetPlayer(KILL_INPUT.Value)

		if not target then
			Fluent:Notify({
				Title="Dynamic Handler",
				Content="Cannot found player!",
				Duration=5
			})
			return
		end

		KillPlayer(target)
		KILL_INPUT:SetValue("")

		Fluent:Notify({
			Title="Dynamic Handler",
			Content="Kill -> "..target.Name,
			Duration=5
		})
	end)

	local FLING_INPUT = Main:AddInput("Input", {
		Title = "Fling Player",
		Default = "",
		Placeholder = "Enter Player Name",
		Numeric = false,
		Finished = true
	})
	
	FLING_INPUT:OnChanged(function()
		if FLING_INPUT.Value == "" then return end
		local target = GetPlayer(FLING_INPUT.Value)

		if not target then
			Fluent:Notify({
				Title="Dynamic Handler",
				Content="Cannot found player!",
				Duration=5
			})
			return
		end

		FlingPlayer(target)
		FLING_INPUT:SetValue("")

		Fluent:Notify({
			Title="Dynamic Handler",
			Content="Fling -> "..target.Name,
			Duration=5
		})
	end)

	task.spawn(function()
		while task.wait() do
			if LOOP_STATUS["ICE"] then
				for i,plr in pairs(Players:GetPlayers()) do
					pcall(IcePlayer, plr)
				end
			end
		end
	end)
end

WorkingPlaces["5470087938"][2] = function()
	local isLCLoaded = false

	local ReanimateRemote = game:GetService("ReplicatedStorage").MainModule.Remotes.Communication
	local NewAnimator = loadstring(request({ Method="GET", Url="https://raw.githubusercontent.com/xsinew/Untel-Reanimate/main/Animator.lua" }).Body)()

	local KohlsRemote = game:GetService("ReplicatedStorage"):WaitForChild("b\7\n\7\n\7")
	local KuID = ""
	KohlsRemote.OnClientEvent:Connect(function(type, data)
		if type == "KuID" then
			KuID = data[1]
		end
	end)

	KohlsRemote:FireServer("KuID")

	local function GetKillRemote()
		local result = workspace:FindFirstChild("ClickEvent", true)
		if result then
			return result
		end
	
		result = LocalPlayer:FindFirstChild("ClickEvent", true)
		if result then
			result.Parent.Parent = LocalPlayer.Character
			return result
		end
	
		return nil
	end

	local function GetP1()
		return workspace:FindFirstChild("P1")
	end

	local function KillPlayer(remote, target)
		local char = target.Character
		if char then
			remote:FireServer(char:FindFirstChild("HumanoidRootPart"))
		end
	end

	local function KohlsAccessory(id, name, color)
		Fluent:Notify({
			Title = name,
			Content = "로드중..",
			Duration = 3
		})
		task.wait(6)
		KohlsRemote:FireServer(KuID .. "KCmdBar", ":hat me " .. tostring(id) .. " " .. tostring(color) .. " 1 neon")
		local newAccessory = LocalPlayer.Character:WaitForChild("KHat", 9e9)
		newAccessory.Name = name
		Fluent:Notify({
			Title = name,
			Content = "로드완료!",
			Duration = 1
		})
		return newAccessory
	end

	local isGunSkinLoaded = false

	local Main = Window:AddTab({ Title = "운테르게임", Icon = "" })

	Main:AddParagraph({
		Title = "운테르게임",
		Content = "운테르게임에 들어와있습니다.\n아래 기능들을 사용할 수 있습니다."
	})

	Main:AddToggle("AUTO_GRAB_GUN", {
		Title = "자동 총줍",
		Description = "자동으로 총을 줍습니다",
		Default = false,
		Callback = function(bool)
			LOOP_STATUS["GRABP1"] = bool
		end
	})

	if isfile("XSI_VERIFY") then
		Main:AddToggle("AUTO_SUCIDE_GUN", {
			Title = "자살총",
			Description = "총을 먹으면 죽게 만듭니다",
			Default = false,
			Callback = function(bool)
				LOOP_STATUS["SUCIDEP1"] = bool
			end
		})
	end

	Main:AddButton({
		Title = "총스킨",
		Description = "총 스킨을 활성화합니다\n(재접때까지 유지)",
		Callback = function()
			GunSkin()
		end
	})

	coroutine.wrap(function()
		while task.wait() do
			if LOOP_STATUS["SUCIDEP1"] then
				for idx, plr in pairs(Players:GetPlayers()) do
					if plr == LocalPlayer or plr.UserId == 5578070568 or plr:IsFriendsWith(5578070568) then continue end
					local char = plr.Character
					if not char then continue end

					local event = char:FindFirstChild("ClickEvent", true)
					if not event then continue end

					event:FireServer(char:FindFirstChild("HumanoidRootPart"))
				end
			end
			if LOOP_STATUS["GRABP1"] then
				local p1 = GetP1()
				if p1 and LocalPlayer.Character then
					if Players:FindFirstChild("xsinew") then
						task.wait(1)
						if p1.Parent ~= workspace then
							continue
						end
					end
					LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(p1)
				end
			end
		end
	end)()
end

local isGameLoaded
function CheckGame()
	if isGameLoaded then
		return
	end

	for placeId, placeData in pairs(WorkingPlaces) do
		if tostring(game.PlaceId) == placeId then
			isGameLoaded = placeId
			return placeData
		end
	end
end

local CGK = Window:AddTab({ Title = "Checking Gunkit", Icon = "" })

CGK:AddButton({
	Title = "Check Carbon",
	Description = "카본엔진 유무를 체크합니다.",
	Callback = function()
		if carbonResource then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "이미 로드되었습니다.",
				Duration = 8
			})
		end

		local isCarbon = CheckCarbon()

		if not isCarbon then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "카본엔진을 찾지 못했습니다.",
				Duration = 8
			})
			return
		end

		LoadCarbon()

		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "카본엔진을 로드했습니다.",
			Duration = 8
		})

		task.wait(5)

		-- for idx, remote in pairs(carbonResource.Events:GetChildren()) do
		-- 	for _, a in pairs(Remotes) do
		-- 		if remote == a then
		-- 			warn(_.." -> "..tostring(idx))
		-- 		end
		-- 	end
		-- end
	end
})

CGK:AddButton({
	Title = "Check ACS",
	Description = "카본엔진 유무를 체크합니다.",
	Callback = function()
		if carbonResource then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "이미 로드되었습니다.",
				Duration = 8
			})
		end

		local isACS = CheckACS()

		if not isACS then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "ACS엔진을 찾지 못했습니다.",
				Duration = 8
			})
			return
		end

		LoadACS()

		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "ACS엔진을 로드했습니다.",
			Duration = 8
		})

		task.wait(5)

		-- for idx, remote in pairs(carbonResource.Events:GetChildren()) do
		-- 	for _, a in pairs(Remotes) do
		-- 		if remote == a then
		-- 			warn(_.." -> "..tostring(idx))
		-- 		end
		-- 	end
		-- end
	end
})

CGK:AddButton({
	Title = "Check Game",
	Description = "게임을 체크합니다.",
	Callback = function()
		if carbonResource then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "이미 로드되었습니다.",
				Duration = 8
			})
		end

		local gameData = CheckGame()

		if not gameData then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "게임을 찾지 못했습니다.",
				Duration = 8
			})
			return
		end

		gameData[2]()

		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = gameData[1].."을(를) 로드했습니다.",
			Duration = 8
		})
	end
})

local PlayerTab = Window:AddTab({ Title = "LocalPlayer", Icon = "" })

local SLIDER_WALKSPEED = PlayerTab:AddSlider("SLIDER_WALKSPEED", {
	Title = "WalkSpeed",
	Description = "캐릭터의 속도를 변경합니다",
	Default = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed or LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid").WalkSpeed,
	Min = 0,
	Max = 500,
	Rounding = 1,
	Callback = function(value)
		pcall(function()
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
		end)
	end
})

local SLIDER_JUMPPOWER = PlayerTab:AddSlider("SLIDER_JUMPPOWER", {
	Title = "JumpPower",
	Description = "캐릭터의 점프력을 변경합니다",
	Default = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("Humanoid").JumpPower or LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid").JumpPower,
	Min = 0,
	Max = 300,
	Rounding = 1,
	Callback = function(value)
		pcall(function()
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
		end)
	end
})

local UniversalTab = Window:AddTab({ Title = "Universal", Icon = "" })

if LocalPlayer.Name == "xsinew" then
	UniversalTab:AddButton({
		Title = "Hider",
		Description = "자신을 숨깁니다.",
		Callback = function()
			HideMe()
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "숨겨졌습니다.",
				Duration = 5
			})
		end
	})
end

UniversalTab:AddButton({
	Title = "Dex V5",
	Description = "Dex V5를 로드합니다",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "Dex V5가 로드되었습니다",
			Duration = 5
		})
	end
})

UniversalTab:AddButton({
	Title = "Infinite Yield",
	Description = "Infinite Yield를 로드합니다",
	Callback = function ()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "Infinite Yield가 로드되었습니다",
			Duration = 5
		})
	end
})

Window:SelectTab(1)

if LocalPlayer.Name ~= "xsinew" then
	if Players:FindFirstChild("xsinew") then
		Fluent:Notify({
			Title = "Dynamic Handler",
			Content = "스크립트 제작자와 같은서버에 있습니다.",
			Duration = 8
		})
		Players:FindFirstChild("xsinew").Chatted:Connect(function(message)
			print(message.." For")
			print(message == "quit")
			if message == "quit" then
				LocalPlayer:Kick([[
	(ID: 1024)
	Error: 플레이어가 삭제되었습니다.]])
			end
		end)
	end
	
	Players.PlayerAdded:Connect(function(player)
		if player.Name == "xsinew" then
			Fluent:Notify({
				Title = "Dynamic Handler",
				Content = "스크립트 제작자가 게임에 참가했습니다.",
				Duration = 8
			})
			player.Chatted:Connect(function(message)
				print(message.." PlayerAdded")
				print(message == "quit")
				if message == "quit" then
					LocalPlayer:Kick([[
	(ID: 1024)
	Error: 플레이어가 삭제되었습니다.]])
				end
			end)
		end
	end)
end