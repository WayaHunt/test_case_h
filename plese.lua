local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- 밥밥부대 탈옥감지 무력화
local lineObject = game:GetService("ReplicatedStorage"):FindFirstChild("line")

if lineObject then
    lineObject:Destroy() -- line 객체를 제거합니다.
end

-- 플래그 및 상태 변수
local isKeyValid = false
local dragging = false
local dragInput, mousePos, framePos
local teleporting = false
local isFlying = false
local spinSpeed = 2
local flySpeed = 2
local spinning = false
local noclip = false
local userName = ""
local espEnabled = false
local espObjects = {}

-- 기능 플래그
local CurrentValue = false
local flyEnabled = false
local noclipEnabled = false
local spinEnabled = false
local KillAuraEnabled = false
local AimBotEnabled = false
local StaticCuffEnabled = false
local TpKillEnabled = false
local swordAttackEnabled = false -- swordattack 기능 상태
local increaseSize = false -- 작대기 크기 증가 상태
local swordEquipEnabled = false  -- 검 꺼내기 상태
local swordSizeIncreaseEnabled = false  -- 검 크기 키우기 상태

-- Aimbot 관련 변수
local aimAssistEnabled = false
local currentTarget = nil
local renderSteppedConnection
local frame = nil
local uiStroke = nil
local colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(128, 0, 128),
    Color3.fromRGB(0, 0, 0)
}
local baseSize = 100
local sizeIncrement = 50
local currentColorIndex = 1

local ToggleFly, ToggleNoclip, ToggleESP, ToggleSpin, ToggleKillAura, ToggleAimBot, ToggleStaticCuff, ToggleTpKill
local ToggleWeaponSize, ToggleSwordAttack

-- 상태를 업데이트하는 함수
local function updateButtonStates()
    if ToggleFly then ToggleFly.Text = flyEnabled and "Fly: ON" or "Fly: OFF" end
    if ToggleNoclip then ToggleNoclip.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF" end
    if ToggleESP then ToggleESP.Text = espEnabled and "ESP: ON" or "ESP: OFF" end
    if ToggleSpin then ToggleSpin.Text = spinEnabled and "Spin: ON" or "Spin: OFF" end
    if ToggleKillAura then ToggleKillAura.Text = KillAuraEnabled and "Kill Aura: ON" or "Kill Aura: OFF" end
    if ToggleAimBot then ToggleAimBot.Text = AimBotEnabled and "Aim Bot: ON" or "Aim Bot: OFF" end
    if ToggleStaticCuff then ToggleStaticCuff.Text = StaticCuffEnabled and "세계 밖으로 떨구기 Cuff: ON\n(수갑 들어야지만 가능)" or "세계 밖으로 떨구기 Cuff: OFF\n(수갑 들어야지만 가능)" end
    if ToggleTpKill then ToggleTpKill.Text = TpKillEnabled and "Tp Kill: ON" or "Tp Kill: OFF" end
    if ToggleWeaponSize then ToggleWeaponSize.Text = increaseSize and "작대기 크기 키우기: ON" or "작대기 크기 키우기: OFF (Fly 같이쓰는거 추천)" end
    if ToggleSwordAttack then ToggleSwordAttack.Text = swordAttackEnabled and "작대기 자동공격: ON" or "작대기 자동공격: OFF" end
end

-- Pastebin 링크
local dataUrl = 'https://pastebin.com/raw/HFHDpMQR'

-- 데이터를 가져오는 코드
local success, response = pcall(function()
    local jsonData = game:HttpGet(dataUrl)
    return HttpService:JSONDecode(jsonData)
end)

if success then
    keysData = response
else
    warn("Failed to fetch JSON data: " .. tostring(response))
end

local function getTargetPlayers()
    local targetPlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if player ~= Player then
                table.insert(targetPlayers, player)
            end
        end
    end
    return targetPlayers
end

local function attackAllPlayers()
    local meleeEvent = ReplicatedStorage:WaitForChild("meleeEvent")
    local targetPlayers = getTargetPlayers()
    for _, player in pairs(targetPlayers) do
        meleeEvent:FireServer(player)
    end
end

-- 서비스와 플레이어 참조
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

function Transparency_toggle_bt()
    --Settings:
    local ScriptStarted = false
    local Keybind = "H" --Set to whatever you want, has to be the name of a KeyCode Enum.
    local Transparency = true --Will make you slightly transparent when you are invisible. No reason to disable.
    local NoClip = false --Will make your fake character no clip.

    local Player = game:GetService("Players").LocalPlayer
    local RealCharacter = Player.Character or Player.CharacterAdded:Wait()

    local IsInvisible = false

    RealCharacter.Archivable = true
    local FakeCharacter = RealCharacter:Clone()
    local Part
    Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(200, 1, 200)
    Part.CFrame = CFrame.new(0, -500, 0) --Set this to whatever you want, just far away from the map.
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

    for i, v in pairs(RealCharacter:GetChildren()) do
    if v:IsA("LocalScript") then
        local clone = v:Clone()
        clone.Disabled = true
        clone.Parent = FakeCharacter
    end
    end
    if Transparency then
    for i, v in pairs(FakeCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.7
        end
    end
    end
    local CanInvis = true
    function RealCharacterDied()
    CanInvis = false
    RealCharacter:Destroy()
    RealCharacter = Player.Character
    CanInvis = true
    isinvisible = false
    FakeCharacter:Destroy()
    workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid

    RealCharacter.Archivable = true
    FakeCharacter = RealCharacter:Clone()
    Part:Destroy()
    Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(200, 1, 200)
    Part.CFrame = CFrame.new(9999, 9999, 9999) --Set this to whatever you want, just far away from the map.
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

    for i, v in pairs(RealCharacter:GetChildren()) do
        if v:IsA("LocalScript") then
            local clone = v:Clone()
            clone.Disabled = true
            clone.Parent = FakeCharacter
        end
    end
    if Transparency then
        for i, v in pairs(FakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.7
            end
        end
    end
    RealCharacter.Humanoid.Died:Connect(function()
    RealCharacter:Destroy()
    FakeCharacter:Destroy()
    end)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
    end
    RealCharacter.Humanoid.Died:Connect(function()
    RealCharacter:Destroy()
    FakeCharacter:Destroy()
    end)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
    local PseudoAnchor
    game:GetService "RunService".RenderStepped:Connect(
    function()
        if PseudoAnchor ~= nil then
            PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
        end
        if NoClip then
        FakeCharacter.Humanoid:ChangeState(11)
        end
    end
    )

    PseudoAnchor = FakeCharacter.HumanoidRootPart
    local function Invisible()
    if IsInvisible == false then
        local StoredCF = RealCharacter.HumanoidRootPart.CFrame
        RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = StoredCF
        RealCharacter.Humanoid:UnequipTools()
        Player.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
        PseudoAnchor = RealCharacter.HumanoidRootPart
        for i, v in pairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = false
            end
        end

        IsInvisible = true
    else
        local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
        
        RealCharacter.HumanoidRootPart.CFrame = StoredCF
        
        FakeCharacter.Humanoid:UnequipTools()
        Player.Character = RealCharacter
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
        PseudoAnchor = FakeCharacter.HumanoidRootPart
        for i, v in pairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = true
            end
        end
        IsInvisible = false
    end
    end

    game:GetService("UserInputService").InputBegan:Connect(
    function(key, gamep)
        if gamep then
            return
        end
        if key.KeyCode.Name:lower() == Keybind:lower() and CanInvis and RealCharacter and FakeCharacter then
            if RealCharacter:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("HumanoidRootPart") then
                Invisible()
            end
        end
    end
    )
    local Sound = Instance.new("Sound",game:GetService("SoundService"))
    Sound.SoundId = "rbxassetid://232127604"
    Sound:Play()
    game:GetService("StarterGui"):SetCore("SendNotification",{["Title"] = "Invisible Toggle Loaded",["Text"] = "Press "..Keybind.." to become change visibility.",["Duration"] = 20,["Button1"] = "Okay."})
end

--kill용 은신
function Transparency_toggle_bt_kill()
    --Settings:
    local ScriptStarted = false
    local Keybind = "H" --Set to whatever you want, has to be the name of a KeyCode Enum.
    local Transparency = true --Will make you slightly transparent when you are invisible. No reason to disable.
    local NoClip = false --Will make your fake character no clip.

    local Player = game:GetService("Players").LocalPlayer
    local RealCharacter = Player.Character or Player.CharacterAdded:Wait()

    local IsInvisible = false

    RealCharacter.Archivable = true
    local FakeCharacter = RealCharacter:Clone()
    local Part
    Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(200, 1, 200)
    Part.CFrame = CFrame.new(0, -1000, 0) --Set this to whatever you want, just far away from the map.
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

    for i, v in pairs(RealCharacter:GetChildren()) do
    if v:IsA("LocalScript") then
        local clone = v:Clone()
        clone.Disabled = true
        clone.Parent = FakeCharacter
    end
    end
    if Transparency then
    for i, v in pairs(FakeCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.7
        end
    end
    end
    local CanInvis = true
    function RealCharacterDied()
    CanInvis = false
    RealCharacter:Destroy()
    RealCharacter = Player.Character
    CanInvis = true
    isinvisible = false
    FakeCharacter:Destroy()
    workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid

    RealCharacter.Archivable = true
    FakeCharacter = RealCharacter:Clone()
    Part:Destroy()
    Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(200, 1, 200)
    Part.CFrame = CFrame.new(9999, 9999, 9999) --Set this to whatever you want, just far away from the map.
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

    for i, v in pairs(RealCharacter:GetChildren()) do
        if v:IsA("LocalScript") then
            local clone = v:Clone()
            clone.Disabled = true
            clone.Parent = FakeCharacter
        end
    end
    if Transparency then
        for i, v in pairs(FakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.7
            end
        end
    end
    RealCharacter.Humanoid.Died:Connect(function()
    RealCharacter:Destroy()
    FakeCharacter:Destroy()
    end)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
    end
    RealCharacter.Humanoid.Died:Connect(function()
    RealCharacter:Destroy()
    FakeCharacter:Destroy()
    end)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
    local PseudoAnchor
    game:GetService "RunService".RenderStepped:Connect(
    function()
        if PseudoAnchor ~= nil then
            PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
        end
        if NoClip then
        FakeCharacter.Humanoid:ChangeState(11)
        end
    end
    )

    PseudoAnchor = FakeCharacter.HumanoidRootPart
    local function Invisible()
    if IsInvisible == false then
        local StoredCF = RealCharacter.HumanoidRootPart.CFrame
        RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = StoredCF
        RealCharacter.Humanoid:UnequipTools()
        Player.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
        PseudoAnchor = RealCharacter.HumanoidRootPart
        for i, v in pairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = false
            end
        end

        IsInvisible = true
    else
        local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
        
        RealCharacter.HumanoidRootPart.CFrame = StoredCF
        
        FakeCharacter.Humanoid:UnequipTools()
        Player.Character = RealCharacter
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
        PseudoAnchor = FakeCharacter.HumanoidRootPart
        for i, v in pairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = true
            end
        end
        IsInvisible = false
    end
    end

    game:GetService("UserInputService").InputBegan:Connect(
    function(key, gamep)
        if gamep then
            return
        end
        if key.KeyCode.Name:lower() == Keybind:lower() and CanInvis and RealCharacter and FakeCharacter then
            if RealCharacter:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("HumanoidRootPart") then
                Invisible()
            end
        end
    end
    )
    local Sound = Instance.new("Sound",game:GetService("SoundService"))
    Sound.SoundId = "rbxassetid://232127604"
    Sound:Play()
    game:GetService("StarterGui"):SetCore("SendNotification",{["Title"] = "Invisible Toggle Loaded",["Text"] = "Press "..Keybind.." to become change visibility.",["Duration"] = 20,["Button1"] = "Okay."})
end

-- 화면에 원 생성
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 100, 0, 100)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundTransparency = 1
frame.Visible = false  -- 스크립트 실행 시 초기 상태에서 UI를 숨김

-- 원의 테두리 설정
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.new(1, 0, 0)
uiStroke.Thickness = 2

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(1, 0)

-- 에임 타겟팅 및 원 표시 상태
local aimAssistEnabled = false

-- 원 크기 조정 함수
local function adjustFrameSize(change)
    local currentSize = frame.Size.X.Offset
    local newSize = currentSize + change
    -- 최소 크기 설정
    if newSize < baseSize then
        newSize = baseSize
    end
    frame.Size = UDim2.new(0, newSize, 0, newSize)
end

-- 원 색상 변경 함수
local function changeFrameColor()
    currentColorIndex = (currentColorIndex % #colors) + 1
    uiStroke.Color = colors[currentColorIndex]
end

-- 원 안에 위치하는지 확인하는 함수
local function isPlayerInAimCircle(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then
        return false
    end

    local headPosition = camera:WorldToScreenPoint(character.Head.Position)
    local frameSize = frame.AbsoluteSize
    local framePosition = frame.AbsolutePosition
    local frameCenter = framePosition + frameSize / 2
    local radius = frameSize.X / 2

    local distance = (Vector2.new(headPosition.X, headPosition.Y) - frameCenter).magnitude
    return distance <= radius
end

-- 플레이어와의 시선 사이에 장애물이 있는지 확인하는 함수
local function isPlayerVisible(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then
        return false
    end

    local targetPosition = character.Head.Position
    local ray = Ray.new(camera.CFrame.Position, (targetPosition - camera.CFrame.Position).unit * (targetPosition - camera.CFrame.Position).magnitude)
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, localPlayer.Character, false, true)

    -- 장애물이 없거나 장애물이 타겟 캐릭터의 일부인 경우
    return hitPart == nil or hitPart:IsDescendantOf(character)
end

-- 가장 가까운 적 플레이어 찾는 함수
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(players:GetPlayers()) do
        -- 플레이어가 로컬 플레이어가 아니고 캐릭터가 존재하며,
        -- Humanoid와 Head가 있는지 확인합니다.
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- 같은 팀의 플레이어는 제외
            if player.Team ~= localPlayer.Team then
                -- 플레이어가 원 안에 있는지 확인하고 가시성을 체크합니다.
                if isPlayerInAimCircle(player) and isPlayerVisible(player) then
                    local distance = (camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    -- 거리 비교 후 가장 가까운 플레이어를 선택합니다.
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function onTargetPlayerDied()
    currentTarget = nil
end

local keyPressConnection
local renderSteppedConnection

local function enableAimbot()
    if aimAssistEnabled then return end  -- 이미 활성화된 경우 아무것도 하지 않음

    aimAssistEnabled = true
    frame.Visible = true  -- Aimbot이 활성화되었을 때 UI 표시

    renderSteppedConnection = runService.RenderStepped:Connect(function()
        if not aimAssistEnabled then
            return
        end

        -- 현재 타겟 플레이어가 사라졌거나 사망한 경우, 새로운 타겟 플레이어 찾기
        if not currentTarget or not currentTarget.Character or not isPlayerInAimCircle(currentTarget) or not isPlayerVisible(currentTarget) or (currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health <= 0) then
            currentTarget = getClosestEnemy()
            
            -- 새로 찾은 타겟이 존재하고 캐릭터가 존재한다면
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
                currentTarget.Character.Humanoid.Died:Connect(onTargetPlayerDied)
            end
        end
        
        -- 현재 타겟이 설정되어 있고, 머리 위치가 보이면 카메라를 조정
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") and isPlayerInAimCircle(currentTarget) and isPlayerVisible(currentTarget) then
            local targetPosition = currentTarget.Character.Head.Position
            camera.CFrame = CFrame.lookAt(
                camera.CFrame.Position,
                targetPosition
            )
        end
    end)

    -- 키 입력 핸들러 추가 (E 키 제거)
    keyPressConnection = userInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.T then
            adjustFrameSize(sizeIncrement)
        elseif input.KeyCode == Enum.KeyCode.Z then
            adjustFrameSize(-sizeIncrement)
        elseif input.KeyCode == Enum.KeyCode.X then
            changeFrameColor()
        end
    end)
end

local function disableAimbot()
    if not aimAssistEnabled then return end  -- 이미 비활성화된 경우 아무것도 하지 않음

    aimAssistEnabled = false
    frame.Visible = false  -- Aimbot이 비활성화되었을 때 UI 숨김
    -- 카메라 고정 해제
    camera.CFrame = camera.CFrame
    -- E, Z, X, T 키 입력 핸들러 제거
    if keyPressConnection then
        keyPressConnection:Disconnect()
        keyPressConnection = nil
    end

    -- RenderStepped 이벤트 연결 해제
    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
    end
end

-- 루트 파트를 가져오는 함수
local function getRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

-- 숫자를 반올림하는 함수
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- 특정 플레이어에 대한 ESP 생성 함수
local function createESP(plr)
    if plr == Player then return end -- 자기 자신에 대해서는 ESP를 적용하지 않음

    local function setupESP()
        local character = plr.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        
        local rootPart = getRoot(character)
        if not rootPart then return end

        local playerGui = Player:WaitForChild("PlayerGui")
        local existingESP = espObjects[plr.UserId]
        if existingESP then
            existingESP:Destroy()
            espObjects[plr.UserId] = nil
        end

        local ESPholder = Instance.new("Folder")
        ESPholder.Name = plr.Name..'_ESP'
        ESPholder.Parent = playerGui
        espObjects[plr.UserId] = ESPholder

        -- 캐릭터의 각 파트에 대해 ESP 박스 생성
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local adornment = Instance.new("BoxHandleAdornment")
                adornment.Name = plr.Name
                adornment.Parent = ESPholder
                adornment.Adornee = part
                adornment.AlwaysOnTop = true
                adornment.ZIndex = 10
                adornment.Size = part.Size
                adornment.Transparency = 0.5
                adornment.Color3 = plr.TeamColor.Color
            end
        end

        -- 캐릭터의 머리 위에 표시할 텍스트 GUI 생성
        local head = character:FindFirstChild("Head")
        if head then
            local BillboardGui = Instance.new("BillboardGui")
            local TextLabel = Instance.new("TextLabel")
            BillboardGui.Adornee = head
            BillboardGui.Name = plr.Name
            BillboardGui.Parent = ESPholder
            BillboardGui.Size = UDim2.new(0, 100, 0, 150)
            BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
            BillboardGui.AlwaysOnTop = true
            TextLabel.Parent = BillboardGui
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0, 0, 0, -50)
            TextLabel.Size = UDim2.new(0, 100, 0, 100)
            TextLabel.Font = Enum.Font.SourceSansSemibold
            TextLabel.TextSize = 20
            TextLabel.TextColor3 = Color3.new(1, 1, 1)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
            TextLabel.Text = 'Name: '..plr.Name

            -- ESP 업데이트 함수
            local function updateESP()
                if not ESPholder.Parent then return end
                if character and rootPart and character:FindFirstChildOfClass("Humanoid") then
                    local distance = round((rootPart.Position - getRoot(Player.Character).Position).Magnitude, 1)
                    local health = round(character:FindFirstChildOfClass('Humanoid').Health, 1)
                    TextLabel.Text = 'Name: '..plr.Name..' | Health: '..health..' | Studs: '..distance
                end
            end

            -- RenderStepped에서 ESP 업데이트 루프 실행
            local espLoopFunc = RunService.RenderStepped:Connect(updateESP)

            -- 캐릭터가 제거될 때 ESP 및 업데이트 루프 제거
            local function onCharacterRemoving()
                espLoopFunc:Disconnect()
                if ESPholder.Parent then
                    ESPholder:Destroy()
                end
            end

            -- 새 캐릭터가 추가될 때 ESP 재설정
            local function onCharacterAdded(newCharacter)
                setupESP() -- 새로운 캐릭터가 추가되면 ESP 재설정
            end

            -- 이벤트 연결
            plr.CharacterRemoving:Connect(onCharacterRemoving)
            plr.CharacterAdded:Connect(onCharacterAdded)

            -- 팀 색상 변경 시 ESP 색상 업데이트
            local function onTeamChanged()
                for _, adornment in pairs(ESPholder:GetChildren()) do
                    if adornment:IsA("BoxHandleAdornment") then
                        adornment.Color3 = plr.TeamColor.Color
                    end
                end
            end
            plr:GetPropertyChangedSignal("TeamColor"):Connect(onTeamChanged)
        end
    end

    -- 캐릭터가 존재할 경우 ESP 설정
    if plr.Character then
        setupESP()
    end

    -- 새로 추가된 캐릭터에 대해서도 ESP 설정
    plr.CharacterAdded:Connect(setupESP)
end

-- 플레이어가 떠날 때 ESP 제거
local function removeESPForPlayer(plr)
    local esp = espObjects[plr.UserId]
    if esp then
        esp:Destroy()
        espObjects[plr.UserId] = nil
    end
end

-- 모든 플레이어에 대한 ESP 설정
local function applyESP()
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

-- 모든 플레이어에 대한 ESP 제거
local function removeESP()
    for _, esp in pairs(espObjects) do
        if esp then
            esp:Destroy()
        end
    end
    espObjects = {}
end

-- 자신의 캐릭터가 추가될 때 모든 플레이어에게 ESP 적용
Player.CharacterAdded:Connect(function()
    if espEnabled then
        applyESP()
    end
end)

-- 새로 추가된 플레이어에게 ESP 적용
Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createESP(plr)
    end
end)

-- 플레이어가 떠날 때 ESP 제거
Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

-- 게임 시작 시 이미 존재하는 플레이어들에게 ESP 적용
if espEnabled then
    applyESP()
end

local function teleport_f()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local targetPosition = Vector3.new(-936, 93, 2056)
    local originalPosition = humanoidRootPart.Position
    local function teleportToPosition(position)
        humanoidRootPart.CFrame = CFrame.new(position)
    end
    local function hasAK47()
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item.Name == "AK-47" then
                return true
            end
        end
        return false
    end
    local function performAction()
        local ak47Item = workspace.Prison_ITEMS.giver:FindFirstChild("AK-47")
        if ak47Item and ak47Item:IsA("Model") and ak47Item:FindFirstChild("ITEMPICKUP") then
            local args = { ak47Item.ITEMPICKUP }
            workspace.Remote.ItemHandler:InvokeServer(unpack(args))
        else
            warn("AK-47 item not found or ITEMPICKUP not available.")
        end
    end
    local function returnToOriginalPosition()
        humanoidRootPart.CFrame = CFrame.new(originalPosition)
    end
    local function teleportAndPerformAction()
        teleportToPosition(targetPosition)
        wait(0.1)
        while not hasAK47() do
            performAction()
            wait(0.1)
        end
        returnToOriginalPosition()
    end
    teleportAndPerformAction()
end

local function startFlying()
    if isFlying then return end
    isFlying = true
    local T = Player.Character.HumanoidRootPart
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = T.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            repeat wait()
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = flySpeed * 40
                elseif SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.velocity = Vector3.new(0, 0, 0)
                end
                BG.cframe = workspace.CurrentCamera.CoordinateFrame
            until not isFlying
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if Player.Character:FindFirstChildOfClass('Humanoid') then
                Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    local function onKeyPress(KEY)
        if KEY:lower() == 'w' then
            CONTROL.F = 1
        elseif KEY:lower() == 's' then
            CONTROL.B = -1
        elseif KEY:lower() == 'a' then
            CONTROL.L = -1
        elseif KEY:lower() == 'd' then
            CONTROL.R = 1
        elseif KEY:lower() == 'e' then
            CONTROL.Q = 1
        elseif KEY:lower() == 'q' then
            CONTROL.E = -1
        end
    end

    local function onKeyRelease(KEY)
        if KEY:lower() == 'w' then
            CONTROL.F = 0
        elseif KEY:lower() == 's' then
            CONTROL.B = 0
        elseif KEY:lower() == 'a' then
            CONTROL.L = 0
        elseif KEY:lower() == 'd' then
            CONTROL.R = 0
        elseif KEY:lower() == 'e' then
            CONTROL.Q = 0
        elseif KEY:lower() == 'q' then
            CONTROL.E = 0
        end
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
            onKeyPress(input.KeyCode.Name)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            onKeyRelease(input.KeyCode.Name)
        end
    end)

    FLY()
end

local function stopFlying()
    if not isFlying then return end
    isFlying = false
    if Player.Character:FindFirstChildOfClass('Humanoid') then
        Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
end

local function startSpinning(speed)
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    for _, v in pairs(humanoidRootPart:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end
    
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.Name = "Spinning"
    bodyAngularVelocity.Parent = humanoidRootPart
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    
    local angularVelocityMagnitude = math.rad(speed) * 700
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, angularVelocityMagnitude, 0)
end

local function stopSpinning()
    local character = Player.Character
    if not character then return end
    
    for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end
end

local function NoclipLoop()
    if noclip and Player.Character then
        for _, child in pairs(Player.Character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then
                child.CanCollide = false
            end
        end
    end
end

local function setNoclip(value)
    noclip = value
    if noclip then
        while noclip do
            NoclipLoop()
            task.wait(0.1)
        end
    else
        for _, child in pairs(Player.Character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end
    end
end

local function stopProcessing()
    teleporting = false
    print("Processing stopped.")
end

-- 팽 부대
-- 서비스 참조
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- M16A3 및 AK-47 총을 소유한 플레이어를 찾는 함수
local function findPlayerWithM16A3orAK47()
    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            if backpack:FindFirstChild("M16A3") or backpack:FindFirstChild("AK-47") then
                return player
            end
        end
    end
    return nil
end

-- 상태 점검 함수
local function isHoldingGun(character)
    return character:FindFirstChild("M16A3") ~= nil or character:FindFirstChild("AK-47") ~= nil
end

-- 총을 들고 있을 때의 데미지 처리 함수
local function inflictDamageWhileHoldingGun(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if isHoldingGun(character) then
        local gun = character:FindFirstChild("M16A3") or character:FindFirstChild("AK-47")
        if gun and gun:FindFirstChild("WAP") then
            gun.WAP.act:FireServer()
        end

        if gun and gun:FindFirstChild("Model") then
            gun.Model.casing:FireServer()
        end

        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                local targetHumanoid = targetPlayer.Character.Humanoid
                local targetHumanoidRootPart = targetPlayer.Character.HumanoidRootPart
                local damageArgs = {
                    [1] = targetHumanoid,
                    [2] = targetHumanoidRootPart,
                    [3] = 100, -- 데미지 값
                    [4] = Vector3.new(-0.9704689979553223, -0.021105706691741943, 1),
                    [5] = 0,
                    [6] = 0,
                    [7] = false
                }
                if gun and gun:FindFirstChild("GunScript_Server") then
                    gun.GunScript_Server.InflictTarget:FireServer(unpack(damageArgs))
                end
            end
        end

        local visualizeArgs = {
            [1] = gun.Handle,
            [2] = Vector3.new(0, 0.6000000238418579, 0),
            [3] = Vector3.new(62.77738571166992, 4.901161193847656, 0),
            [4] = gun.GunScript_Local.MuzzleEffect,
            [5] = gun.GunScript_Local.HitEffect,
            [6] = 186809249,
            [7] = { [1] = false },
            [8] = { [1] = 25, [2] = Vector3.new(0.25, 0.25, 100), [3] = BrickColor.new(1), [4] = 0.25, [5] = Enum.Material.Neon, [6] = 0.25 },
            [9] = true,
            [10] = true
        }
        if gun and gun:FindFirstChild("VisualizeBullet") then
            gun.VisualizeBullet:FireServer(unpack(visualizeArgs))
        end
    else
        local backpack = player.Backpack
        local gun = backpack:FindFirstChild("M16A3") or backpack:FindFirstChild("AK-47")
        if gun and gun:FindFirstChild("WAP") then
            gun.WAP.dct:FireServer()
        end

        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                local targetHumanoid = targetPlayer.Character.Humanoid
                local targetHumanoidRootPart = targetPlayer.Character.HumanoidRootPart
                local damageArgs = {
                    [1] = targetHumanoid,
                    [2] = targetHumanoidRootPart,
                    [3] = 100, -- 데미지 값
                    [4] = Vector3.new(-0.9704689979553223, -0.021105706691741943, 1),
                    [5] = 0,
                    [6] = 0,
                    [7] = false
                }
                if gun and gun:FindFirstChild("GunScript_Server") then
                    gun.GunScript_Server.InflictTarget:FireServer(unpack(damageArgs))
                end
            end
        end
    end
end

-- 특정 플레이어를 대상으로 데미지를 입히는 함수
local function onePlayerDemager()
    local killerPlayer = findPlayerWithM16A3orAK47()
    if not killerPlayer then
        print("No player with M16A3 or AK-47 found.")
        return
    end

    local targetPlayer = Players:FindFirstChild(userName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        local gun = killerPlayer.Backpack:FindFirstChild("M16A3") or killerPlayer.Backpack:FindFirstChild("AK-47")
        if gun then
            if gun:FindFirstChild("WAP") then
                gun.WAP.act:FireServer()
            end

            if gun:FindFirstChild("Model") then
                gun.Model.casing:FireServer()
            end

            local targetHumanoid = targetPlayer.Character.Humanoid
            local targetHumanoidRootPart = targetPlayer.Character.HumanoidRootPart
            local damageArgs = {
                [1] = targetHumanoid,
                [2] = targetHumanoidRootPart,
                [3] = 100, -- 데미지 값
                [4] = Vector3.new(-0.9704689979553223, -0.021105706691741943, 1),
                [5] = 0,
                [6] = 0,
                [7] = false
            }

            gun.GunScript_Server.InflictTarget:FireServer(unpack(damageArgs))

            -- 시각 효과 추가 (선택 사항)
            local visualizeArgs = {
                [1] = gun.Handle,
                [2] = Vector3.new(0, 0.6000000238418579, 0),
                [3] = Vector3.new(62.77738571166992, 4.901161193847656, 0),
                [4] = gun.GunScript_Local.MuzzleEffect,
                [5] = gun.GunScript_Local.HitEffect,
                [6] = 186809249,
                [7] = { [1] = false },
                [8] = { [1] = 25, [2] = Vector3.new(0.25, 0.25, 100), [3] = BrickColor.new(1), [4] = 0.25, [5] = Enum.Material.Neon, [6] = 0.25 },
                [9] = true,
                [10] = true
            }
            if gun:FindFirstChild("VisualizeBullet") then
                gun.VisualizeBullet:FireServer(unpack(visualizeArgs))
            end

        else
            print("No gun found or gun script missing.")
        end
    else
        print("Target player not found or invalid.")
    end
end

-- 수갑을 소유한 플레이어를 찾는 함수
local function findPlayerWithCuffs()
    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack and backpack:FindFirstChild("수갑") then
            return player
        end
    end
    return nil
end

-- 특정 플레이어에게 수갑을 거는 함수
local function cuffSpecificPlayer()
    local playerWithCuffs = findPlayerWithCuffs()
    if not playerWithCuffs then
        print("No player with handcuffs found.")
        return
    end

    local targetPlayer = Players:FindFirstChild(userName)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
        print("Target player or target player's character or head is nil")
        return
    end

    local backpack = playerWithCuffs:FindFirstChild("Backpack")
    local cuffs = backpack and backpack:FindFirstChild("수갑")

    if cuffs and cuffs:FindFirstChild("RemoteEvent") then
        local remoteEvent = cuffs.RemoteEvent

        local args = {
            [1] = "Cuff",
            [2] = targetPlayer.Character.Head
        }

        local success, err = pcall(function()
            remoteEvent:FireServer(unpack(args))
        end)

        if not success then
            warn("Error firing RemoteEvent for:", targetPlayer.Name, err)
        end
    else
        print("Player with cuffs does not have the RemoteEvent.")
    end
end

-- 모든 플레이어를 수갑으로 묶는 함수
local function cuffAllPlayers()
    local playerWithCuffs = findPlayerWithCuffs()
    if playerWithCuffs then
        local backpack = playerWithCuffs:FindFirstChild("Backpack")
        local cuffs = backpack and backpack:FindFirstChild("수갑")

        if cuffs and cuffs:FindFirstChild("RemoteEvent") then
            local remoteEvent = cuffs.RemoteEvent

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= playerWithCuffs and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                    local args = {
                        [1] = "Cuff",
                        [2] = targetPlayer.Character.Head
                    }

                    local success, err = pcall(function()
                        remoteEvent:FireServer(unpack(args))
                    end)
                    
                    if not success then
                        warn("Error firing RemoteEvent for:", targetPlayer.Name, err)
                    end

                    wait(0.1) -- 요청이 서버에서 처리되도록 지연
                end
            end
        else
            print("Player with cuffs does not have the RemoteEvent.")
        end
    else
        print("No player with handcuffs found.")
    end
end

-- 밥밥 부대
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local teleportingStatic = false  -- Static cuff 기능의 상태를 추적하는 변수

local outOfWorldPosition = Vector3.new(98.03588104248047, -17.422523498535156, -61.581932067871094)
local cuffRange = 50  -- 수갑 채울 수 있는 범위
local teleportSpeed = 50  -- 텔레포트 속도 조정 (값을 낮춤)

local swordAttackEnabled = false -- swordattack 기능 상태
local increaseSize = false -- 작대기 크기 증가 상태
local isGlockAllKillEnabled = false -- 글록 ALL KILL 함수 정의

-- 텔레포트 위치 설정
local targetPosition = Vector3.new(238.11863708496094, -18.850393295288086, 222.54690551757812)

local function GlockAllKill()
    if not isGlockAllKillEnabled then return end  -- 스위치가 꺼져 있으면 아무것도 하지 않음

    local targetPlayer = LocalPlayer
    
    -- 체크: 플레이어가 존재하는지 확인
    if not targetPlayer then
        warn("Target player not found")
        return
    end

    -- 체크: 총을 들고 있는지 확인
    local gun = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Glock 17")
    if not gun then
        warn(targetPlayer.Name .. " is not holding the gun")
        return
    end

    -- 팀이 다른 모든 플레이어에게 데미지를 입히는 루프
    while isGlockAllKillEnabled do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= targetPlayer and player.Team ~= targetPlayer.Team then
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoidRootPart and gun then
                    -- 20번 데미지를 입히는 루프
                    for i = 1, 20 do
                        if humanoid and humanoid.Health and humanoid.Health > 0 then
                            local args = {
                                [1] = "Gun",
                                [2] = gun,
                                [3] = {
                                    ["ModuleName"] = "1",
                                    ["ChargeAlterTable"] = {},
                                    ["BaseDamage"] = 20,
                                },
                                [4] = humanoid,
                                [5] = humanoidRootPart,
                                [6] = humanoidRootPart,
                                [7] = {
                                    ["ChargeLevel"] = 0,
                                    ["ExplosionEffectFolder"] = game:GetService("ReplicatedStorage").Miscs.GunVisualEffects.Common.ExplosionEffect,
                                    ["BloodEffectFolder"] = game:GetService("ReplicatedStorage").Miscs.GunVisualEffects.Common.BloodEffect,
                                    ["HitEffectFolder"] = game:GetService("ReplicatedStorage").Miscs.GunVisualEffects.Common.HitEffect,
                                    ["MuzzleFolder"] = game:GetService("ReplicatedStorage").Miscs.GunVisualEffects.Common.MuzzleEffect,
                                    ["GoreEffect"] = game:GetService("ReplicatedStorage").Miscs.GunVisualEffects.Common.GoreEffect
                                }
                            }

                            local success, errorMessage = pcall(function()
                                game:GetService("ReplicatedStorage").Remotes.InflictTarget:InvokeServer(unpack(args))
                            end)

                            if not success then
                                warn("Error invoking server:", errorMessage)
                            end

                            if humanoid.Health <= 0 then
                                print(player.Name .. " has been killed.")
                                break
                            end
                        else
                            warn("Humanoid is nil, health is invalid, or player is dead:", player.Name)
                            break
                        end
                    end
                else
                    warn("Humanoid, HumanoidRootPart, or Gun not found for player:", player.Name)
                end
            end
        end
        wait()
    end
end

local function stopGlockAllKill()
    isGlockAllKillEnabled = false
end

-- "Glock 17"이라는 이름의 도구가 캐릭터에 장착되었을 때 이벤트를 감지하는 함수
local function onToolEquipped(tool)
    if tool.Name == "Glock 17" and isGlockAllKillEnabled then
        GlockAllKill() -- 총을 들었을 때 모든 플레이어를 죽이는 함수 호출
    end
end

-- 텔레포트 함수
local function teleportToPosition(position)
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(position)
    local VirtualInputManager = game:GetService('VirtualInputManager')
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    wait(3)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- 무기 크기 조절 함수
local function adjustWeaponSize(increase)
    local character = LocalPlayer.Character
    if not character then return end

    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            if increase then
                handle.Size = Vector3.new(100, 100, 100) -- 작대기 크기 증가
            else
                handle.Size = Vector3.new(10, 10, 10) -- 기본 크기로 돌아감
            end
        end
    end
end

-- swordattack 실행 함수
local function startSwordAttack()
    while swordAttackEnabled do
        game:GetService("ReplicatedStorage"):WaitForChild("swordattack"):FireServer()
        wait(0.2) -- 0.2초마다 실행
    end
end

-- 인벤토리에서 수갑을 찾아 손에 든다
local function equipCuffs()
    local backpack = LocalPlayer.Backpack
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("cuffs") then
                LocalPlayer.Character.Humanoid:EquipTool(tool)  -- 수갑 장착
                print("Cuffs equipped.")
                return true
            end
        end
    end
    print("Cuffs not found in inventory.")
    return false
end

-- 가장 가까운 플레이어 찾기
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not localHumanoidRootPart then return nil end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHumanoidRootPart then
                local distance = (targetHumanoidRootPart.Position - localHumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = targetPlayer
                end
            end
        end
    end

    return closestPlayer
end

-- 수갑을 채우는 함수
local function tryToCuffPlayer(player)
    local Cuffs = LocalPlayer.Character:FindFirstChild("Cuffs.")
    local CuffRemote = Cuffs and Cuffs:FindFirstChild("CuffsRemote")
    if player and player.Character and CuffRemote then
        local args = {
            [1] = player.Character
        }

        local cuffs = LocalPlayer.Character:FindFirstChild("Cuffs.")
        if cuffs and cuffs:FindFirstChild("CuffsRemote") then
            cuffs.CuffsRemote:FireServer(unpack(args))
            print("Attempted to cuff " .. player.Name)
        return true
        end
    end
    return false
end

-- 가장 가까운 플레이어를 찾는 함수
local function getClosestPlayer()
    local localHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHumanoidRootPart then
                local distance = (targetHumanoidRootPart.Position - localHumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = targetPlayer
                end
            end
        end
    end

    return closestPlayer
end

-- 캐릭터의 충돌 및 중력 비활성화 함수
local function disableCollisionsAndGravity(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
        end
    end
    character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

-- 캐릭터의 충돌 및 중력 활성화 함수
local function enableCollisionsAndGravity(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.Anchored = false
        end
    end
    character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- 지정된 위치로 매우 빠르게 이동하는 함수 (벽 통과 기능 활성화)
local function fastMoveToPosition(targetPosition)
    local localHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if localHumanoidRootPart then
        disableCollisionsAndGravity(LocalPlayer.Character)  -- 충돌 비활성화

        local speed = 100  -- 속도를 매우 빠르게 설정
        local direction = (targetPosition - localHumanoidRootPart.Position).unit
        local lastDistance = (localHumanoidRootPart.Position - targetPosition).magnitude

        while lastDistance > 1 do
            localHumanoidRootPart.CFrame = localHumanoidRootPart.CFrame + direction * speed
            wait(0.01)  -- 이동 속도 제어
            local currentDistance = (localHumanoidRootPart.Position - targetPosition).magnitude

            -- 만약 현재 위치가 목표 위치보다 더 멀어졌다면, 멈추고 정확한 위치로 설정
            if currentDistance > lastDistance then
                localHumanoidRootPart.CFrame = CFrame.new(targetPosition)
                break
            end

            lastDistance = currentDistance
        end

        enableCollisionsAndGravity(LocalPlayer.Character)  -- 도착 후 충돌 활성화
        return true
    end
    return false
end


-- 모든 플레이어를 처리하는 함수
local function processAllPlayers()
    originalPosition = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame  -- 현재 위치를 저장

    while teleportingStatic do
        local targetPlayer = getClosestPlayer()
        if not targetPlayer then
            print("No players left to process.")
            break
        end

        local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if targetHumanoidRootPart and localHumanoidRootPart then
            -- 대상 플레이어의 위치로 텔레포트
            localHumanoidRootPart.CFrame = targetHumanoidRootPart.CFrame
            print("Teleported to " .. targetPlayer.Name .. "'s position")

            -- 거리 체크 후 수갑 채우기 시도 (단 한 번만 시도)
            local distance = (targetHumanoidRootPart.Position - localHumanoidRootPart.Position).Magnitude
            if distance <= cuffRange then
                local success = tryToCuffPlayer(targetPlayer)
                if success then
                    wait(0.5)  -- 수갑 채운 후 잠깐 대기

                    -- 매우 빠르게 벽 통과하여 목표 위치로 이동
                    if fastMoveToPosition(outOfWorldPosition) then
                        print("Moved to the out-of-world position.")
                        wait(0.5)
                        -- 도착 후 수갑 풀기
                        tryToCuffPlayer(targetPlayer)  -- 수갑 풀기 시도

                        wait(0.1)  -- 수갑 풀리는 시간을 위해 잠시 대기

                        -- 수갑이 풀린 후 2초 대기 후 복귀
                        print("Waiting 2 seconds before returning to original position.")
                        wait(2)  -- 2초 대기
                        if LocalPlayer.Character and originalPosition then
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = originalPosition
                            print("Teleported back to original position.")
                        end
                    end
                end
            end

            wait(0.1)  -- 다음 플레이어 처리 전에 잠시 대기
        end
    end
end

-- Static cuff 기능 시작
local function startStaticCuff()
    teleportingStatic = true
    -- 로컬 플레이어의 캐릭터가 로드된 후 도구 장착 이벤트를 연결
    LocalPlayer.CharacterAdded:Connect(function(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                onToolEquipped(child)
            end
        end)
    end)
    
    -- 로컬 플레이어가 처음부터 캐릭터를 가지고 있을 경우를 대비
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                onToolEquipped(child)
            end
        end)
    end
    if LocalPlayer.Character then
        equipCuffs()
        processAllPlayers()
    end
end

-- Static cuff 기능 중지
local function stopStaticCuff()
    teleportingStatic = false
    print("Static cuff stopped.")
end

-- 한국 보이스 쳇

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ToolEvent = ReplicatedStorage:FindFirstChild("ToolEvent")
local NewSword = ReplicatedStorage:FindFirstChild("New Sword")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local toolName = "New Sword"
local swordSize = Vector3.new(2, 2, 800) -- 가로 2, 세로 2, 깊이 800으로 설정

local originalPosition -- 원래 위치를 저장할 변수
local bodyGyro, bodyVelocity -- 중력을 없애기 위해 사용한 객체를 저장할 변수
local targetPlayerName = nil -- 특정 플레이어 이름을 저장할 변수

local mouse = player:GetMouse()  -- 마우스 참조 생성
local connection  -- 마우스 이동 이벤트 연결을 저장할 변수
local clickConnection -- 마우스 클릭 이벤트 연결을 저장할 변수
local highlight  -- 하이라이트 효과를 저장할 변수
local isSelecting = false  -- 선택 기능이 활성화되었는지 여부를 추적

-- 검을 제공하는 함수
local function giveSword()
    if not character:FindFirstChild(toolName) then
        local args = {
            [1] = "steppedOn",
            [2] = NewSword
        }
        ToolEvent:FireServer(unpack(args))
    end
end

-- 검의 크기 조정 함수
local function adjustSwordSize()
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            tool.Handle.Size = swordSize
            tool.Handle.Massless = true
            tool.Handle.Transparency = 0
            tool.Handle.CFrame = character.PrimaryPart.CFrame * CFrame.new(0, -tool.Handle.Size.Y / 2, 0)
        end
    end
end

-- 중력을 없애는 함수
local function removeGravity()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Parent = humanoidRootPart
end

-- 중력을 원래대로 복구하는 함수
local function restoreGravity()
    if bodyGyro then
        bodyGyro:Destroy()
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
end

-- 대상 플레이어를 공격하는 함수
local function teleportToSkyAndAttack(targetPlayer)
    local targetCharacter = targetPlayer.Character
    if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
        -- 현재 위치를 저장
        originalPosition = character.PrimaryPart.CFrame

        -- 중력 제거
        removeGravity()

        while targetCharacter and targetCharacter.Humanoid.Health > 0 do
            -- 대상 플레이어의 좌표를 얻음
            local targetPosition = targetCharacter.HumanoidRootPart.Position

            -- 대상 플레이어 위, 하늘로 이동 (+100의 Y값으로 이동)
            local skyPosition = targetPosition + Vector3.new(0, 400, 0)
            character:SetPrimaryPartCFrame(CFrame.new(skyPosition))

            -- 칼을 들고 크기를 조정 (아래로만 확장)
            giveSword()
            adjustSwordSize()

            -- 대상 플레이어가 나갔는지 확인
            if not targetPlayer:IsDescendantOf(Players) then
                break
            end

            -- 잠시 대기 후 반복
            wait(0.1)
        end

        -- 대상 플레이어가 나갔거나 죽었으면 원래 위치로 돌아감
        if originalPosition then
            character:SetPrimaryPartCFrame(originalPosition)
        end

        -- 중력 복원
        restoreGravity()
    else
        -- 대상 플레이어가 없으면 즉시 원래 위치로 복귀
        if originalPosition then
            character:SetPrimaryPartCFrame(originalPosition)
        end
    end
end

-- 무한 루프와 검 제공 및 크기 조정 기능을 하나로 통합한 함수
local function continuouslyGiveAndResizeSword()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ToolEvent = ReplicatedStorage:FindFirstChild("ToolEvent")
    local NewSword = ReplicatedStorage:FindFirstChild("New Sword")
    local region = Region3.new(Vector3.new(0, 0, 0), Vector3.new(10, 10, 10)) -- 구역의 크기와 위치를 설정합니다.
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local toolName = "New Sword"
    local circleSize = 100 -- 칼의 크기를 100으로 조정합니다.

    local function giveSword()
        if not character:FindFirstChild(toolName) then
            local args = {
                [1] = "steppedOn",
                [2] = NewSword
            }
            ToolEvent:FireServer(unpack(args))
        end
    end

    local function adjustSwordSize()
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(circleSize, circleSize, circleSize)  -- 칼 크기 조정
                tool.Handle.Massless = true
                tool.Handle.Transparency = 0
            end
        end
    end

    local function maintainSword()
        while true do
            local position = character.PrimaryPart.Position
            local inRegion = position.X >= region.CFrame.Position.X - region.Size.X/2 and position.X <= region.CFrame.Position.X + region.Size.X/2 and
                            position.Y >= region.CFrame.Position.Y - region.Size.Y/2 and position.Y <= region.CFrame.Position.Y + region.Size.Y/2 and
                            position.Z >= region.CFrame.Position.Z - region.Size.Z/2 and position.Z <= region.CFrame.Position.Z + region.Size.Z/2

            if inRegion then
                giveSword()
            else
                if not character:FindFirstChild(toolName) then
                    giveSword()
                end
            end

            -- 칼 크기 조정
            adjustSwordSize()

            wait(0.06) -- 0.1초마다 체크
        end
    end

    -- 무한 루프를 통해 칼을 계속 들고 크기를 유지하는 루프 실행
    maintainSword()
end


-- 공격 시작 함수
local function startAttack()
    if targetPlayerName then
        local targetPlayer = Players:FindFirstChild(targetPlayerName)
        if targetPlayer then
            teleportToSkyAndAttack(targetPlayer)
        else
            warn("Target player not found!")
        end
    else
        warn("No target player selected!")
    end
end

-- 선택 기능 비활성화 함수
local function disableSelectionMode()
    -- 기능 비활성화
    print("Selection mode off.")

    -- 기존 하이라이트 제거
    if highlight then
        highlight:Destroy()
        highlight = nil
    end

    -- 마우스 이벤트 연결 해제
    if connection then
        connection:Disconnect()
        connection = nil
    end

    if clickConnection then
        clickConnection:Disconnect()
        clickConnection = nil
    end

    -- 선택 모드 비활성화
    isSelecting = false
end

-- 버튼 클릭 시 실행될 함수
local function onButtonClick()
    if isSelecting then
        disableSelectionMode()
    else
        -- 기능 활성화
        print("Selection mode on.")

        -- 마우스 이동 이벤트 연결
        connection = mouse.Move:Connect(function()
            local target = mouse.Target

            -- 이전에 적용된 하이라이트가 있으면 제거
            if highlight then
                highlight:Destroy()
                highlight = nil
            end

            -- 새로운 대상이 플레이어 캐릭터인지 확인
            if target and target.Parent then
                local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                if targetPlayer then
                    local character = targetPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        -- 플레이어의 HumanoidRootPart에 하이라이트 추가
                        highlight = Instance.new("SelectionBox", character.HumanoidRootPart)
                        highlight.Adornee = character.HumanoidRootPart
                        highlight.LineThickness = 0.05
                        highlight.Color3 = Color3.fromRGB(255, 0, 0) -- 빨간색 테두리
                        highlight.SurfaceTransparency = 0 -- 투명도 설정
                    end
                end
            end
        end)

        -- 마우스 클릭 이벤트 연결
        clickConnection = mouse.Button1Down:Connect(function()
            if highlight then
                local target = highlight.Adornee

                -- 클릭한 플레이어 이름 출력
                if target and target.Parent then
                    local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                    if targetPlayer then
                        print("You clicked on: " .. targetPlayer.Name)
                        targetPlayerName = targetPlayer.Name
                        startAttack()  -- 공격 시작
                    end
                end

                -- 하이라이트 제거 및 선택 모드 비활성화
                disableSelectionMode()
            end
        end)

        -- 선택 모드 활성화
        isSelecting = true
    end
end

local function equipSword()
    if swordEquipEnabled then
        -- 검을 꺼내오는 로직을 여기에 추가
        if not character:FindFirstChild(toolName) then
            local args = {
                [1] = "steppedOn",
                [2] = NewSword
            }
            ToolEvent:FireServer(unpack(args))
        end
    else
        local sword = character:FindFirstChild(toolName)
        if sword then
            sword:Destroy() -- 칼을 제거
            swordEquipped = false
    end
    end
end

local function adjustSwordSize(increase)
    local character = LocalPlayer.Character
    if not character then return end

    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            if increase then
                handle.Size = Vector3.new(100, 100, 100) -- 검 크기 증가
            else
                handle.Size = Vector3.new(10, 10, 10) -- 기본 크기로 돌아감
            end
        end
    end
end

function Toggle_Tebi_tool_giver_f()
    local function addUniqueToolsToInventory()
        -- 로컬 플레이어 가져오기
        local player = game.Players.LocalPlayer
    
        -- 이미 추가된 도구 이름을 저장할 테이블
        local addedTools = {}
    
        -- 가져올 도구 이름 리스트
        local toolNames = {
            "NULL",
            "엘더플레임 AK74",
            "프로토타입 AK12",
            "관통기",
            "프로토타입-S",
            "새해 K2",
            "프라임 벤달",
            "스피커 K2",
            "외교부 키"
        }
    
        -- 게임 내 모든 Tool 탐색
        for _, tool in pairs(game:GetDescendants()) do
            if tool:IsA("Tool") and not addedTools[tool.Name] and table.find(toolNames, tool.Name) then
                -- 중복되지 않고 리스트에 있는 Tool만 추가
                local toolClone = tool:Clone()
                toolClone.Parent = player.Backpack
                addedTools[tool.Name] = true  -- 추가된 도구 이름 기록
            end
        end
    end
    
    -- 함수 실행
    addUniqueToolsToInventory()
end

function Toggle_Tebi_vote_f()
    local function FNDR_fake_script()
        local function visui(ui)
            if ui.Enabled and ui:FindFirstChildWhichIsA("Frame") and ui:FindFirstChildWhichIsA("Frame").Visible then
                ui.Enabled = false
                ui:FindFirstChildWhichIsA("Frame").Visible = false
                return
            end
            if ui.Parent ~= game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") then
                ui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            end
            ui.Enabled = true
            if ui:FindFirstChildWhichIsA("Frame") then
                ui:FindFirstChildWhichIsA("Frame").Visible = true
            end
        end
    
        local function showElectionUI()
            for i, v in pairs(game:GetDescendants()) do
                if v:IsA("ScreenGui") and v.Name == "선거 시스템" then
                    visui(v)
                end
            end
        end
    
        -- 스크립트 실행 시 바로 선거 UI를 가져옴
        showElectionUI()
    end
    
    FNDR_fake_script()
end

local function teleportPlayer()
    -- 미리 정의된 좌표
    local savedPosition = Vector3.new(843.0634765625, 6.300670623779297, -67.28617095947266)

    -- 캐릭터의 HumanoidRootPart 가져오기
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- 미리 정의된 위치로 이동
    humanoidRootPart.CFrame = CFrame.new(savedPosition)
    print("미리 정의된 위치로 이동했습니다: ", savedPosition)
end

-- 샤크부대
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- 수갑을 소유한 플레이어를 찾는 함수
local function findPlayerWithCuffs()
    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack and backpack:FindFirstChild("수갑") then
            return player
        end
    end
    return nil
end

-- 모든 플레이어를 수갑으로 묶는 함수
local function cuffAllPlayers()
    local playerWithCuffs = findPlayerWithCuffs()
    if playerWithCuffs then
        local backpack = playerWithCuffs:FindFirstChild("Backpack")
        local cuffs = backpack and backpack:FindFirstChild("수갑")

        if cuffs and cuffs:FindFirstChild("RemoteEvent") then
            local remoteEvent = cuffs.RemoteEvent

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= localPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                    local args = {
                        [1] = "Cuff",
                        [2] = targetPlayer.Character.Head
                    }

                    local success, err = pcall(function()
                        remoteEvent:FireServer(unpack(args))
                    end)
                    
                    if not success then
                        warn("Error firing RemoteEvent for:", targetPlayer.Name, err)
                    end

                    wait(0.1) -- 요청이 서버에서 처리되도록 지연
                end
            end
        else
            print("Player with cuffs does not have the RemoteEvent.")
        end
    else
        print("No player with handcuffs found.")
    end
end

local function loadMainUI()
    if Player:FindFirstChild("PlayerGui"):FindFirstChild("MainGui") then
        return
    end

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "MainGui"
    MainGui.ResetOnSpawn = false
    MainGui.Parent = Player:WaitForChild("PlayerGui")
    MainGui.DisplayOrder = 10000

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.ClipsDescendants = true   
    MainFrame.Parent = MainGui

    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 15)
    UICornerMain.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "IWV Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = TopBar

    -- 접기 버튼 생성
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = TopBar

    -- 접기 기능 구현
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false  -- 프레임 숨기기

        -- 왼쪽 아래에 다시 키는 버튼 생성
        local ReopenButton = Instance.new("TextButton")
        ReopenButton.Size = UDim2.new(0, 150, 0, 50)
        ReopenButton.Position = UDim2.new(0, 20, 1, -70)  -- 화면 왼쪽 아래에 배치
        ReopenButton.Text = "IWV HUB"
        ReopenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ReopenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ReopenButton.BorderSizePixel = 0
        ReopenButton.Font = Enum.Font.SourceSansBold
        ReopenButton.TextSize = 24
        ReopenButton.Parent = MainGui

        -- ReopenButton 모서리를 둥글게 만들기
        local UICornerMinimize = Instance.new("UICorner")
        UICornerMinimize.CornerRadius = UDim.new(0, 10)  -- 숫자가 클수록 더 둥글어짐
        UICornerMinimize.Parent = ReopenButton

        -- 다시 키는 버튼 클릭 시 프레임을 보이고 버튼 삭제
        ReopenButton.MouseButton1Click:Connect(function()
            MainFrame.Visible = true  -- 프레임 다시 보이기
            ReopenButton:Destroy()  -- 버튼 삭제
        end)
    end)
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TopBar
    
    CloseButton.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    local SideBarScroll = Instance.new("ScrollingFrame")
    SideBarScroll.Size = UDim2.new(0, 150, 1, -40)
    SideBarScroll.Position = UDim2.new(0, 0, 0, 40)
    SideBarScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SideBarScroll.BorderSizePixel = 0
    SideBarScroll.ClipsDescendants = true
    SideBarScroll.ScrollBarThickness = 6
    SideBarScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    SideBarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SideBarScroll.Parent = MainFrame

    local UICornerSide = Instance.new("UICorner")
    UICornerSide.CornerRadius = UDim.new(0, 10)
    UICornerSide.Parent = SideBarScroll

    local Buttons = {
        "기본기능",
        "팽 부대",
        "밥밥 부대",
        "태비 부대",
        "샤크 부대",
        "프리즌 라이프",
        "아스널",
        "스크립트 모음",
        "한국 보이스 챗(작동 x)",
        "스카이 부대(개발 중)",
        "승리 재단(개발 중)",
        "한울 태권도(개발 중)"
    }

    local SectionFrame = Instance.new("ScrollingFrame")
    SectionFrame.Size = UDim2.new(1, -150, 1, -40)
    SectionFrame.Position = UDim2.new(0, 150, 0, 40)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.ClipsDescendants = true
    SectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    SectionFrame.ScrollBarThickness = 6
    SectionFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    SectionFrame.Parent = MainFrame

    local UICornerSection = Instance.new("UICorner")
    UICornerSection.CornerRadius = UDim.new(0, 10)
    UICornerSection.Parent = SectionFrame

    local function updateSideBarCanvasSize()
        SideBarScroll.CanvasSize = UDim2.new(0, 0, 0, #Buttons * 45)
    end
    
    for i, buttonName in ipairs(Buttons) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.Position = UDim2.new(0, 0, 0, (i - 1) * 45)
        Button.Text = buttonName
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.BorderSizePixel = 0
        Button.Font = Enum.Font.SourceSansBold
        Button.TextSize = 18
        Button.Parent = SideBarScroll
    
        Button.MouseButton1Click:Connect(function()
            loadSectionContent(buttonName)
        end)
    end
    
    updateSideBarCanvasSize()

    local function loadSectionContent(section)
        SectionFrame:ClearAllChildren()
        SectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
        local contentHeight = 0

        if section == "기본기능" then
            ToggleFly = Instance.new("TextButton")
            ToggleFly.Size = UDim2.new(0, 300, 0, 40)
            ToggleFly.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleFly.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleFly.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleFly.BorderSizePixel = 0
            ToggleFly.Font = Enum.Font.SourceSansBold
            ToggleFly.TextSize = 18
            ToggleFly.Parent = SectionFrame

            ToggleFly.MouseButton1Click:Connect(function()
                flyEnabled = not flyEnabled
                if flyEnabled then
                    startFlying()
                else
                    stopFlying()
                end
                updateButtonStates()
            end)
            contentHeight = contentHeight + 50

            ToggleNoclip = Instance.new("TextButton")
            ToggleNoclip.Size = UDim2.new(0, 300, 0, 40)
            ToggleNoclip.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleNoclip.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleNoclip.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleNoclip.BorderSizePixel = 0
            ToggleNoclip.Font = Enum.Font.SourceSansBold
            ToggleNoclip.TextSize = 18
            ToggleNoclip.Parent = SectionFrame

            ToggleNoclip.MouseButton1Click:Connect(function()
                noclipEnabled = not noclipEnabled
                updateButtonStates()  -- 상태를 먼저 업데이트

                if noclipEnabled then
                    setNoclip(true)
                else
                    setNoclip(false)
                end
            end)
            contentHeight = contentHeight + 50

            local ToggleESP = Instance.new("TextButton")
            ToggleESP.Size = UDim2.new(0, 300, 0, 40)
            ToggleESP.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleESP.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleESP.BorderSizePixel = 0
            ToggleESP.Font = Enum.Font.SourceSansBold
            ToggleESP.TextSize = 18
            ToggleESP.Parent = SectionFrame
            ToggleESP.Text = espEnabled and "ESP: ON" or "ESP: OFF"

            ToggleESP.MouseButton1Click:Connect(function()
                espEnabled = not espEnabled
                if espEnabled then
                    applyESP()
                else
                    removeESP()
                end
                ToggleESP.Text = espEnabled and "ESP: ON" or "ESP: OFF"
            end)
            
            contentHeight = contentHeight + 50

            for _, plr in pairs(Players:GetPlayers()) do
                if espEnabled then
                    createESP(plr)
                end
            end

            for _, plr in pairs(Players:GetPlayers()) do
                if espEnabled then
                    if plr.Character then
                        createESP(plr)
                    else
                        plr.CharacterAdded:Connect(function()
                            createESP(plr)
                        end)
                    end
                end
            end

            ToggleSpin = Instance.new("TextButton")
            ToggleSpin.Size = UDim2.new(0, 300, 0, 40)
            ToggleSpin.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleSpin.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleSpin.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleSpin.BorderSizePixel = 0
            ToggleSpin.Font = Enum.Font.SourceSansBold
            ToggleSpin.TextSize = 18
            ToggleSpin.Parent = SectionFrame

            ToggleSpin.MouseButton1Click:Connect(function()
                spinEnabled = not spinEnabled
                if spinEnabled then
                    startSpinning(spinSpeed)
                else
                    stopSpinning()
                end
                updateButtonStates()
            end)
            contentHeight = contentHeight + 50

            local ToggleStealth = Instance.new("TextButton")
            ToggleStealth.Size = UDim2.new(0, 300, 0, 40)
            ToggleStealth.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleStealth.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleStealth.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleStealth.BorderSizePixel = 0
            ToggleStealth.Font = Enum.Font.SourceSansBold
            ToggleStealth.TextSize = 18
            ToggleStealth.Parent = SectionFrame
            ToggleStealth.Text = "Transparency(투명, H키)"

            ToggleStealth.MouseButton1Click:Connect(function()
                Transparency_toggle_bt()-- 은신 함수
            end)

            contentHeight = contentHeight + 50

            local ToggleThrowing = Instance.new("TextButton")
            ToggleThrowing.Size = UDim2.new(0, 300, 0, 40)
            ToggleThrowing.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleThrowing.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleThrowing.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleThrowing.BorderSizePixel = 0
            ToggleThrowing.Font = Enum.Font.SourceSansBold
            ToggleThrowing.TextSize = 18
            ToggleThrowing.Parent = SectionFrame
            ToggleThrowing.Text = "플레이어를 세계 밖으로 날려보내기\n(플레이어끼리 통과되면 안 날라감)"

            ToggleThrowing.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()-- 날려버리는 함수
            end)

            contentHeight = contentHeight + 50

            local InputFlySpeed = Instance.new("TextBox")
            InputFlySpeed.Size = UDim2.new(0, 300, 0, 40)
            InputFlySpeed.Position = UDim2.new(0.5, -150, 0, contentHeight)
            InputFlySpeed.PlaceholderText = "Fly Speed (적정 범위: 1~10)"
            InputFlySpeed.Text = ""
            InputFlySpeed.TextColor3 = Color3.fromRGB(0, 0, 0)
            InputFlySpeed.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            InputFlySpeed.BorderSizePixel = 0
            InputFlySpeed.Font = Enum.Font.SourceSans
            InputFlySpeed.TextSize = 18
            InputFlySpeed.Parent = SectionFrame

            local function updateFlySpeed()
                local speed = tonumber(InputFlySpeed.Text)
                if speed then
                    flySpeed = speed
                end
            end

            InputFlySpeed:GetPropertyChangedSignal("Text"):Connect(function()
                updateFlySpeed()
            end)

            contentHeight = contentHeight + 50

            local InputSpinSpeed = Instance.new("TextBox")
            InputSpinSpeed.Size = UDim2.new(0, 300, 0, 40)
            InputSpinSpeed.Position = UDim2.new(0.5, -150, 0, contentHeight)
            InputSpinSpeed.PlaceholderText = "Spin Speed (적정 범위: 1~10)"
            InputSpinSpeed.TextColor3 = Color3.fromRGB(0, 0, 0)
            InputSpinSpeed.Text = ""
            InputSpinSpeed.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            InputSpinSpeed.BorderSizePixel = 0
            InputSpinSpeed.Font = Enum.Font.SourceSans
            InputSpinSpeed.TextSize = 18
            InputSpinSpeed.Parent = SectionFrame

            local function updateSpinSpeed()
                local speed = tonumber(InputSpinSpeed.Text)
                if speed then
                    spinSpeed = speed
                    if isSpinning then
                        startSpinning(spinSpeed)
                    end
                end
            end

            InputSpinSpeed.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    updateSpinSpeed()
                end
            end)

            InputSpinSpeed:GetPropertyChangedSignal("Text"):Connect(updateSpinSpeed)

            contentHeight = contentHeight + 50

        elseif section == "프리즌 라이프" then
            local ButtonGetAK471 = Instance.new("TextButton")
            ButtonGetAK471.Size = UDim2.new(0, 300, 0, 40)
            ButtonGetAK471.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonGetAK471.Text = "ALL KILL (개발중...)"
            ButtonGetAK471.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonGetAK471.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonGetAK471.BorderSizePixel = 0
            ButtonGetAK471.Font = Enum.Font.SourceSansBold
            ButtonGetAK471.TextSize = 18
            ButtonGetAK471.Parent = SectionFrame
        
            ButtonGetAK471.MouseButton1Click:Connect(function()
                teleport_f()
            end)
        
            contentHeight = contentHeight + 50
            
            local ToggleKillAura = Instance.new("TextButton")
            ToggleKillAura.Size = UDim2.new(0, 300, 0, 40)
            ToggleKillAura.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleKillAura.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleKillAura.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleKillAura.BorderSizePixel = 0
            ToggleKillAura.Font = Enum.Font.SourceSansBold
            ToggleKillAura.TextSize = 18
            ToggleKillAura.Text = "Kill Aura: OFF"
            ToggleKillAura.Parent = SectionFrame
            
            ToggleKillAura.MouseButton1Click:Connect(function()
                KillAuraEnabled = not KillAuraEnabled
                ToggleKillAura.Text = KillAuraEnabled and "Kill Aura: ON" or "Kill Aura: OFF"
                
                if KillAuraEnabled then
                    coroutine.wrap(function()
                        while KillAuraEnabled do
                            attackAllPlayers()
                            wait(0.02)
                        end
                    end)()
                end
            end)
            contentHeight = contentHeight + 50
        
            local ButtonGetAK47 = Instance.new("TextButton")
            ButtonGetAK47.Size = UDim2.new(0, 300, 0, 40)
            ButtonGetAK47.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonGetAK47.Text = "AK-47 가져오기"
            ButtonGetAK47.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonGetAK47.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonGetAK47.BorderSizePixel = 0
            ButtonGetAK47.Font = Enum.Font.SourceSansBold
            ButtonGetAK47.TextSize = 18
            ButtonGetAK47.Parent = SectionFrame
        
            ButtonGetAK47.MouseButton1Click:Connect(function()
                teleport_f()
            end)
            contentHeight = contentHeight + 50

        elseif section == "아스널" then
            local aimbotToggleButton = Instance.new("TextButton")
            aimbotToggleButton.Size = UDim2.new(0, 300, 0, 40)
            aimbotToggleButton.Position = UDim2.new(0.5, -150, 0, contentHeight)
            aimbotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            aimbotToggleButton.BorderSizePixel = 0
            aimbotToggleButton.Font = Enum.Font.SourceSansBold
            aimbotToggleButton.TextSize = 18
            aimbotToggleButton.Text = AimBotEnabled and "Aimbot: ON" or "Aimbot: OFF"
            aimbotToggleButton.Parent = SectionFrame
            
            aimbotToggleButton.MouseButton1Click:Connect(function()
                AimBotEnabled = not AimBotEnabled
                if AimBotEnabled then
                    enableAimbot()
                else
                    disableAimbot()
                end
                aimbotToggleButton.Text = AimBotEnabled and "Aimbot: ON" or "Aimbot: OFF"
            end)
                
            contentHeight = contentHeight + 50
            
        elseif section == "팽 부대" then
            local ButtonAllCuff = Instance.new("TextButton")
            ButtonAllCuff.Size = UDim2.new(0, 300, 0, 40)
            ButtonAllCuff.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonAllCuff.Text = "ALL Cuff"
            ButtonAllCuff.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonAllCuff.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonAllCuff.BorderSizePixel = 0
            ButtonAllCuff.Font = Enum.Font.SourceSansBold
            ButtonAllCuff.TextSize = 18
            ButtonAllCuff.Parent = SectionFrame
        
            ButtonAllCuff.MouseButton1Click:Connect(function()
                cuffAllPlayers()
            end)
            contentHeight = contentHeight + 50
            
            local toggle_bt_kill_a = Instance.new("TextButton")
            toggle_bt_kill_a.Size = UDim2.new(0, 300, 0, 40)
            toggle_bt_kill_a.Position = UDim2.new(0.5, -150, 0, contentHeight)
            toggle_bt_kill_a.Text = "kill용 은신 (H 은신)"
            toggle_bt_kill_a.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle_bt_kill_a.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            toggle_bt_kill_a.BorderSizePixel = 0
            toggle_bt_kill_a.Font = Enum.Font.SourceSansBold
            toggle_bt_kill_a.TextSize = 18
            toggle_bt_kill_a.Parent = SectionFrame
        
            toggle_bt_kill_a.MouseButton1Click:Connect(function()
                Transparency_toggle_bt_kill()
            end)
            contentHeight = contentHeight + 50

            local ButtonOneCuff = Instance.new("TextButton")
            ButtonOneCuff.Size = UDim2.new(0, 300, 0, 40)
            ButtonOneCuff.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonOneCuff.Text = "특정 플레이어 지정 Cuff"
            ButtonOneCuff.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonOneCuff.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonOneCuff.BorderSizePixel = 0
            ButtonOneCuff.Font = Enum.Font.SourceSansBold
            ButtonOneCuff.TextSize = 18
            ButtonOneCuff.Parent = SectionFrame
        
            ButtonOneCuff.MouseButton1Click:Connect(function()
                cuffSpecificPlayer()
            end)
            contentHeight = contentHeight + 50
        
            local InputKillOrCuffName = Instance.new("TextBox")
            InputKillOrCuffName.Size = UDim2.new(0, 300, 0, 40)
            InputKillOrCuffName.Position = UDim2.new(0.5, -150, 0, contentHeight)
            InputKillOrCuffName.PlaceholderText = "Kill or Cuff Player Name"
            InputKillOrCuffName.Text = ""
            InputKillOrCuffName.TextColor3 = Color3.fromRGB(0, 0, 0)
            InputKillOrCuffName.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            InputKillOrCuffName.BorderSizePixel = 0
            InputKillOrCuffName.Font = Enum.Font.SourceSans
            InputKillOrCuffName.TextSize = 18
            InputKillOrCuffName.Parent = SectionFrame
            
            -- 실시간으로 userName을 업데이트하는 함수
            local function updateKill_Name()
                local name = InputKillOrCuffName.Text
                userName = name
            end
            
            -- TextBox의 Text 속성이 변경될 때마다 호출
            InputKillOrCuffName:GetPropertyChangedSignal("Text"):Connect(function()
                updateKill_Name()
            end)
            
            contentHeight = contentHeight + 50

            local ButtonAllKill = Instance.new("TextButton")
            ButtonAllKill.Size = UDim2.new(0, 300, 0, 40)
            ButtonAllKill.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonAllKill.Text = "ALL Kill \n( ACS 총으로 변경되어 개발 중 )"
            ButtonAllKill.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonAllKill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonAllKill.BorderSizePixel = 0
            ButtonAllKill.Font = Enum.Font.SourceSansBold
            ButtonAllKill.TextSize = 18
            ButtonAllKill.Parent = SectionFrame
        
            ButtonAllKill.MouseButton1Click:Connect(function()
                local playerWithGun = findPlayerWithM16A3orAK47()
                if playerWithGun then
                    inflictDamageWhileHoldingGun(playerWithGun)
                else
                    print("No player with M16A3 or AK-47 found.")
                end
            end)
            contentHeight = contentHeight + 50

            local ButtonOneKill = Instance.new("TextButton")
            ButtonOneKill.Size = UDim2.new(0, 300, 0, 40)
            ButtonOneKill.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonOneKill.Text = "특정 플레이어 지정 Kill \n( ACS 총으로 변경되어 개발 중 )"
            ButtonOneKill.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonOneKill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonOneKill.BorderSizePixel = 0
            ButtonOneKill.Font = Enum.Font.SourceSansBold
            ButtonOneKill.TextSize = 18
            ButtonOneKill.Parent = SectionFrame
        
            ButtonOneKill.MouseButton1Click:Connect(function()
                onePlayerDemager()
            end)
            contentHeight = contentHeight + 50

        elseif section == "밥밥 부대" then
            local ToggleGlockAllKill = Instance.new("TextButton")
            ToggleGlockAllKill.Size = UDim2.new(0, 300, 0, 40)
            ToggleGlockAllKill.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleGlockAllKill.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleGlockAllKill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleGlockAllKill.BorderSizePixel = 0
            ToggleGlockAllKill.Font = Enum.Font.SourceSansBold
            ToggleGlockAllKill.TextSize = 18
            ToggleGlockAllKill.Text = "글록 ALL KILL : OFF\n(글록 들어야지만 가능)"
            ToggleGlockAllKill.Parent = SectionFrame

            ToggleGlockAllKill.MouseButton1Click:Connect(function()
                isGlockAllKillEnabled = not isGlockAllKillEnabled
                ToggleGlockAllKill.Text = isGlockAllKillEnabled and "글록 ALL KILL : ON\n(글록 들어야지만 가능)" or "글록 ALL KILL : OFF\n(글록 들어야지만 가능)"
                
                if isGlockAllKillEnabled then
                    GlockAllKill()
                else
                    stopGlockAllKill()
                end
            end)
            contentHeight = contentHeight + 50

            ToggleStaticCuff = Instance.new("TextButton")
            ToggleStaticCuff.Size = UDim2.new(0, 300, 0, 40)
            ToggleStaticCuff.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleStaticCuff.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleStaticCuff.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleStaticCuff.BorderSizePixel = 0
            ToggleStaticCuff.Font = Enum.Font.SourceSansBold
            ToggleStaticCuff.TextSize = 18
            ToggleStaticCuff.Text = StaticCuffEnabled and "Static Cuff: ON" or "Static Cuff: OFF"
            ToggleStaticCuff.Parent = SectionFrame
    
            ToggleStaticCuff.MouseButton1Click:Connect(function()
                StaticCuffEnabled = not StaticCuffEnabled
                updateButtonStates()  -- 상태를 업데이트
                if StaticCuffEnabled then
                    startStaticCuff()
                else
                    stopStaticCuff()
                end
            end)
            contentHeight = contentHeight + 50
    
            -- 무기 크기 조절 토글 추가
            local ToggleWeaponSize = Instance.new("TextButton")
            ToggleWeaponSize.Size = UDim2.new(0, 300, 0, 40)
            ToggleWeaponSize.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleWeaponSize.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleWeaponSize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleWeaponSize.BorderSizePixel = 0
            ToggleWeaponSize.Font = Enum.Font.SourceSansBold
            ToggleWeaponSize.TextSize = 18
            ToggleWeaponSize.Text = increaseSize and "작대기 크기 키우기: ON" or "작대기 크기 키우기: OFF"
            ToggleWeaponSize.Parent = SectionFrame
    
            ToggleWeaponSize.MouseButton1Click:Connect(function()
                increaseSize = not increaseSize
                ToggleWeaponSize.Text = increaseSize and "작대기 크기 키우기: ON" or "작대기 크기 키우기: OFF"
                adjustWeaponSize(increaseSize)
            end)
            contentHeight = contentHeight + 50
    
            -- swordattack 기능 추가
            local ToggleSwordAttack = Instance.new("TextButton")
            ToggleSwordAttack.Size = UDim2.new(0, 300, 0, 40)
            ToggleSwordAttack.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleSwordAttack.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleSwordAttack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleSwordAttack.BorderSizePixel = 0
            ToggleSwordAttack.Font = Enum.Font.SourceSansBold
            ToggleSwordAttack.TextSize = 18
            ToggleSwordAttack.Text = swordAttackEnabled and "작대기 자동공격: ON" or "작대기 자동공격: OFF"
            ToggleSwordAttack.Parent = SectionFrame
    
            ToggleSwordAttack.MouseButton1Click:Connect(function()
                swordAttackEnabled = not swordAttackEnabled
                ToggleSwordAttack.Text = swordAttackEnabled and "작대기 자동공격: ON" or "작대기 자동공격: OFF"
                if swordAttackEnabled then
                    coroutine.wrap(startSwordAttack)()
                end
            end)
            contentHeight = contentHeight + 50
            
            -- 작대기 텔포
            local teleportButton = Instance.new("TextButton")
            teleportButton.Size = UDim2.new(0, 300, 0, 40)
            teleportButton.Position = UDim2.new(0.5, -150, 0, contentHeight)
            teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            teleportButton.BorderSizePixel = 0
            teleportButton.Font = Enum.Font.SourceSansBold
            teleportButton.TextSize = 18
            teleportButton.Text = "작대기 텔레포트"
            teleportButton.Parent = SectionFrame
        
            teleportButton.MouseButton1Click:Connect(function()
                teleportToPosition(targetPosition)
            end)
        
        elseif section == "한국 보이스 챗(작동 x)" then
            local ButtonSelectnoti = Instance.new("TextButton")
            ButtonSelectnoti.Size = UDim2.new(0, 300, 0, 40)
            ButtonSelectnoti.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonSelectnoti.Text = "[공지] 제작자가 칼 데미지를 없애버려서\n기능작동 안합니다."
            ButtonSelectnoti.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonSelectnoti.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonSelectnoti.BorderSizePixel = 0
            ButtonSelectnoti.Font = Enum.Font.SourceSansBold
            ButtonSelectnoti.TextSize = 18
            ButtonSelectnoti.Parent = SectionFrame

            contentHeight = contentHeight + 50

            local ToggleSwordEquip = Instance.new("TextButton")
            ToggleSwordEquip.Size = UDim2.new(0, 300, 0, 40)
            ToggleSwordEquip.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleSwordEquip.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleSwordEquip.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleSwordEquip.BorderSizePixel = 0
            ToggleSwordEquip.Font = Enum.Font.SourceSansBold
            ToggleSwordEquip.TextSize = 18
            ToggleSwordEquip.Text = swordEquipEnabled and "검 꺼내오기: ON" or "검 꺼내오기: OFF"
            ToggleSwordEquip.Parent = SectionFrame
        
            ToggleSwordEquip.MouseButton1Click:Connect(function()
                swordEquipEnabled = not swordEquipEnabled
                ToggleSwordEquip.Text = swordEquipEnabled and "검 꺼내오기: ON" or "검 꺼내오기: OFF"
                equipSword()  -- 검 꺼내기 함수 실행
            end)
            contentHeight = contentHeight + 50
        
            local ToggleSwordSize = Instance.new("TextButton")
            ToggleSwordSize.Size = UDim2.new(0, 300, 0, 40)
            ToggleSwordSize.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ToggleSwordSize.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleSwordSize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleSwordSize.BorderSizePixel = 0
            ToggleSwordSize.Font = Enum.Font.SourceSansBold
            ToggleSwordSize.TextSize = 18
            ToggleSwordSize.Text = swordSizeIncreaseEnabled and "검 크기 키우기: ON" or "검 크기 키우기: OFF"
            ToggleSwordSize.Parent = SectionFrame
        
            ToggleSwordSize.MouseButton1Click:Connect(function()
                swordSizeIncreaseEnabled = not swordSizeIncreaseEnabled
                ToggleSwordSize.Text = swordSizeIncreaseEnabled and "검 크기 키우기: ON" or "검 크기 키우기: OFF"
                adjustSwordSize(swordSizeIncreaseEnabled)
            end)
            contentHeight = contentHeight + 50

            local ButtonSelect = Instance.new("TextButton")
            ButtonSelect.Size = UDim2.new(0, 300, 0, 40)
            ButtonSelect.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonSelect.Text = "특정 플레이어 지정 킬 \n(죽일 상대를 클릭)"
            ButtonSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonSelect.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonSelect.BorderSizePixel = 0
            ButtonSelect.Font = Enum.Font.SourceSansBold
            ButtonSelect.TextSize = 18
            ButtonSelect.Parent = SectionFrame
        
            ButtonSelect.MouseButton1Click:Connect(function()
                onButtonClick()
            end)
            contentHeight = contentHeight + 50

            local ButtonAllKill_k = Instance.new("TextButton")
            ButtonAllKill_k.Size = UDim2.new(0, 300, 0, 40)
            ButtonAllKill_k.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonAllKill_k.Text = "올킬 플레이어 킬 \n(무조건 킥당함)"
            ButtonAllKill_k.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonAllKill_k.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonAllKill_k.BorderSizePixel = 0
            ButtonAllKill_k.Font = Enum.Font.SourceSansBold
            ButtonAllKill_k.TextSize = 18
            ButtonAllKill_k.Parent = SectionFrame
        
            ButtonAllKill_k.MouseButton1Click:Connect(function()
                continuouslyGiveAndResizeSword()
            end)
            contentHeight = contentHeight + 50
        
        elseif section == "샤크 부대" then
            -- (샤크 부대 관련 코드)

            local Toggle_sak_cuff_giver = Instance.new("TextButton")
            Toggle_sak_cuff_giver.Size = UDim2.new(0, 300, 0, 40)
            Toggle_sak_cuff_giver.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Toggle_sak_cuff_giver.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle_sak_cuff_giver.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Toggle_sak_cuff_giver.BorderSizePixel = 0
            Toggle_sak_cuff_giver.Font = Enum.Font.SourceSansBold
            Toggle_sak_cuff_giver.TextSize = 18
            Toggle_sak_cuff_giver.Text = "All Cuff"
            Toggle_sak_cuff_giver.Parent = SectionFrame
        
            Toggle_sak_cuff_giver.MouseButton1Click:Connect(function()
                cuffAllPlayers()-- 모든 플레이어를 묶는 함수
            end)
            contentHeight = contentHeight + 50

        elseif section == "스카이 부대(개발 중)" then
            -- (스카이 부대 관련 코드)
            local ButtonSelectnoti1 = Instance.new("TextButton")
            ButtonSelectnoti1.Size = UDim2.new(0, 300, 0, 40)
            ButtonSelectnoti1.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonSelectnoti1.Text = "[공지] 제작중..."
            ButtonSelectnoti1.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonSelectnoti1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonSelectnoti1.BorderSizePixel = 0
            ButtonSelectnoti1.Font = Enum.Font.SourceSansBold
            ButtonSelectnoti1.TextSize = 18
            ButtonSelectnoti1.Parent = SectionFrame

            contentHeight = contentHeight + 50
        elseif section == "태비 부대" then
            -- (태비 부대 관련 코드)

            local Toggle_Tebi_tool_giver = Instance.new("TextButton")
            Toggle_Tebi_tool_giver.Size = UDim2.new(0, 300, 0, 40)
            Toggle_Tebi_tool_giver.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Toggle_Tebi_tool_giver.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle_Tebi_tool_giver.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Toggle_Tebi_tool_giver.BorderSizePixel = 0
            Toggle_Tebi_tool_giver.Font = Enum.Font.SourceSansBold
            Toggle_Tebi_tool_giver.TextSize = 18
            Toggle_Tebi_tool_giver.Text = "모든 총 가져오기"
            Toggle_Tebi_tool_giver.Parent = SectionFrame
        
            Toggle_Tebi_tool_giver.MouseButton1Click:Connect(function()
                Toggle_Tebi_tool_giver_f()  -- 모든 아이템 가져오는 함수
            end)
            contentHeight = contentHeight + 50

            local Toggle_Tebi_vote = Instance.new("TextButton")
            Toggle_Tebi_vote.Size = UDim2.new(0, 300, 0, 40)
            Toggle_Tebi_vote.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Toggle_Tebi_vote.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle_Tebi_vote.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Toggle_Tebi_vote.BorderSizePixel = 0
            Toggle_Tebi_vote.Font = Enum.Font.SourceSansBold
            Toggle_Tebi_vote.TextSize = 18
            Toggle_Tebi_vote.Text = "투표화면 띄우기 (모든 유저가 보임)"
            Toggle_Tebi_vote.Parent = SectionFrame
        
            Toggle_Tebi_vote.MouseButton1Click:Connect(function()
                Toggle_Tebi_vote_f()  -- 투표 화면을 띄움
            end)

            contentHeight = contentHeight + 50
            -- 함수 호출: 스크립트가 실행되면 바로 텔레포트
            local Toggle_Tebi_jang = Instance.new("TextButton")
            Toggle_Tebi_jang.Size = UDim2.new(0, 300, 0, 40)
            Toggle_Tebi_jang.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Toggle_Tebi_jang.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle_Tebi_jang.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Toggle_Tebi_jang.BorderSizePixel = 0
            Toggle_Tebi_jang.Font = Enum.Font.SourceSansBold
            Toggle_Tebi_jang.TextSize = 18
            Toggle_Tebi_jang.Text = "장갑차 위치로 텔포"
            Toggle_Tebi_jang.Parent = SectionFrame
        
            Toggle_Tebi_jang.MouseButton1Click:Connect(function()
                teleportPlayer()  -- 텔포하는 함수
            end)

            contentHeight = contentHeight + 50
            
        elseif section == "승리 재단(개발 중)" then
            -- (승리 재단 관련 코드)
            local ButtonSelectnoti123 = Instance.new("TextButton")
            ButtonSelectnoti123.Size = UDim2.new(0, 300, 0, 40)
            ButtonSelectnoti123.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonSelectnoti123.Text = "[공지] 제작중..."
            ButtonSelectnoti123.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonSelectnoti123.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonSelectnoti123.BorderSizePixel = 0
            ButtonSelectnoti123.Font = Enum.Font.SourceSansBold
            ButtonSelectnoti123.TextSize = 18
            ButtonSelectnoti123.Parent = SectionFrame

            contentHeight = contentHeight + 50
        elseif section == "스크립트 모음" then
            -- (스크립트 모음 관련 코드)
            local Script_collact1 = Instance.new("TextButton")
            Script_collact1.Size = UDim2.new(0, 300, 0, 40)
            Script_collact1.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Script_collact1.Text = "가장 강력한 전장 스크립트\n키 : StrongestBossNew892367!!"
            Script_collact1.TextColor3 = Color3.fromRGB(255, 255, 255)
            Script_collact1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Script_collact1.BorderSizePixel = 0
            Script_collact1.Font = Enum.Font.SourceSansBold
            Script_collact1.TextSize = 18
            Script_collact1.Parent = SectionFrame

            Script_collact1.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/LOLking123456/TSB/main/Crab"))()
            end)
            contentHeight = contentHeight + 50
            
            local Script_collact123 = Instance.new("TextButton")
            Script_collact123.Size = UDim2.new(0, 300, 0, 40)
            Script_collact123.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Script_collact123.Text = "슬랩배틀 스크립트"
            Script_collact123.TextColor3 = Color3.fromRGB(255, 255, 255)
            Script_collact123.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Script_collact123.BorderSizePixel = 0
            Script_collact123.Font = Enum.Font.SourceSansBold
            Script_collact123.TextSize = 18
            Script_collact123.Parent = SectionFrame

            Script_collact123.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Giangplay/Slap_Battles/main/Slap_Battles.lua"))()
            end)
            contentHeight = contentHeight + 50

            local Script_collact1234 = Instance.new("TextButton")
            Script_collact1234.Size = UDim2.new(0, 300, 0, 40)
            Script_collact1234.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Script_collact1234.Text = "블록스피스 스크립트"
            Script_collact1234.TextColor3 = Color3.fromRGB(255, 255, 255)
            Script_collact1234.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Script_collact1234.BorderSizePixel = 0
            Script_collact1234.Font = Enum.Font.SourceSansBold
            Script_collact1234.TextSize = 18
            Script_collact1234.Parent = SectionFrame

            Script_collact123.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet"https://raw.githubusercontent.com/Basicallyy/Basicallyy/main/MinGamingV4.lua")()
            end)
            contentHeight = contentHeight + 50

            local Script_collact12345 = Instance.new("TextButton")
            Script_collact12345.Size = UDim2.new(0, 300, 0, 40)
            Script_collact12345.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Script_collact12345.Text = "디버거 스크립트"
            Script_collact12345.TextColor3 = Color3.fromRGB(255, 255, 255)
            Script_collact12345.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Script_collact12345.BorderSizePixel = 0
            Script_collact12345.Font = Enum.Font.SourceSansBold
            Script_collact12345.TextSize = 18
            Script_collact12345.Parent = SectionFrame

            Script_collact12345.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/debugnation/main/decompilers%20and%20debugging/Debuggers.txt"))() 
            end)
            contentHeight = contentHeight + 50

            local Script_collact12 = Instance.new("TextButton")
            Script_collact12.Size = UDim2.new(0, 300, 0, 40)
            Script_collact12.Position = UDim2.new(0.5, -150, 0, contentHeight)
            Script_collact12.Text = "인피니티 스크립트"
            Script_collact12.TextColor3 = Color3.fromRGB(255, 255, 255)
            Script_collact12.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Script_collact12.BorderSizePixel = 0
            Script_collact12.Font = Enum.Font.SourceSansBold
            Script_collact12.TextSize = 18
            Script_collact12.Parent = SectionFrame

            Script_collact12.MouseButton1Click:Connect(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end)
            contentHeight = contentHeight + 50
        elseif section == "한울 태권도(개발 중)" then
            -- (한울 태권도 관련 코드)
            local ButtonSelectnoti1234 = Instance.new("TextButton")
            ButtonSelectnoti1234.Size = UDim2.new(0, 300, 0, 40)
            ButtonSelectnoti1234.Position = UDim2.new(0.5, -150, 0, contentHeight)
            ButtonSelectnoti1234.Text = "[공지] 제작중..."
            ButtonSelectnoti1234.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonSelectnoti1234.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonSelectnoti1234.BorderSizePixel = 0
            ButtonSelectnoti1234.Font = Enum.Font.SourceSansBold
            ButtonSelectnoti1234.TextSize = 18
            ButtonSelectnoti1234.Parent = SectionFrame

            contentHeight = contentHeight + 50
        end
        SectionFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        updateButtonStates()  -- 상태를 업데이트
        -- SectionFrame의 CanvasSize 업데이트
        SectionFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end

    -- 사이드바의 버튼 생성 코드
    for i, buttonName in ipairs(Buttons) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.Position = UDim2.new(0, 0, 0, (i - 1) * 45)
        Button.Text = buttonName
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.BorderSizePixel = 0
        Button.Font = Enum.Font.SourceSansBold
        Button.TextSize = 18
        Button.Parent = SideBarScroll

        Button.MouseButton1Click:Connect(function()
            loadSectionContent(buttonName)
        end)
    end

    loadSectionContent(Buttons[1])

    Player.CharacterAdded:Connect(function()
        loadMainUI()
    end)

    Player:GetPropertyChangedSignal("Team"):Connect(function()
        loadMainUI()
    end)
end

local function createKeyGUI()
    if Player:FindFirstChild("PlayerGui"):FindFirstChild("CustomScreenGui") then
        Player:FindFirstChild("PlayerGui"):FindFirstChild("CustomScreenGui"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 200)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, -25)
    Title.BackgroundTransparency = 1
    Title.Text = "Key Verification"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0, 300, 0, 40)
    KeyBox.Position = UDim2.new(0.5, -150, 0.4, 0)
    KeyBox.PlaceholderText = "Enter your Key"
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    KeyBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    KeyBox.BorderSizePixel = 0
    KeyBox.Font = Enum.Font.SourceSans
    KeyBox.TextSize = 18
    KeyBox.Parent = Frame

    local UICornerKey = Instance.new("UICorner")
    UICornerKey.CornerRadius = UDim.new(0, 10)
    UICornerKey.Parent = KeyBox

    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0, 300, 0, 40)
    SubmitButton.Position = UDim2.new(0.5, -150, 0.7, 0)
    SubmitButton.Text = "Submit"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Font = Enum.Font.SourceSansBold
    SubmitButton.TextSize = 18
    SubmitButton.Parent = Frame

    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 10)
    UICornerButton.Parent = SubmitButton

    local ResultLabel = Instance.new("TextLabel")
    ResultLabel.Size = UDim2.new(0, 300, 0, 40)
    ResultLabel.Position = UDim2.new(0.5, -150, 0.9, 0)
    ResultLabel.BackgroundTransparency = 1
    ResultLabel.Text = ""
    ResultLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    ResultLabel.Font = Enum.Font.SourceSansBold
    ResultLabel.TextSize = 18
    ResultLabel.Parent = Frame
    
    
    -- 사용자 키와 ID를 확인하는 함수
    local function verifyKeyAndUserId(inputKey)
        local userId = game:GetService("RbxAnalyticsService"):GetClientId()
        for _, entry in ipairs(keysData) do
            print(entry)
            for _, id in ipairs(entry.userId) do
                if entry.key == inputKey and id == userId then
                    ScreenGui:Destroy()
                    isKeyValid = true
                    loadMainUI()
                    return
                end
            end
        end
        
        ResultLabel.Text = "Invalid key or User ID."
        ResultLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end

    SubmitButton.MouseButton1Click:Connect(function()
        local inputKey = KeyBox.Text
        if inputKey == "" then
            local userId = game:GetService("RbxAnalyticsService"):GetClientId()
            print(userId)
            setclipboard(userId)
            ResultLabel.Text = "Please enter your Key. \n(클립보드에 복사된 내용을 IWV DM에 보내주세요)"
            ResultLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            return
        end
        verifyKeyAndUserId(inputKey)
    end)
end

createKeyGUI()
