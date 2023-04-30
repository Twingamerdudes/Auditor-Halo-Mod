local PlayerName
local IsAuditor = false
local JustHealed = false
function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function NormalState()
    JustHealed = false
end
function Callback(ctype, args)
    if ctype == "character" then
        if args[1] == "Auditor Halo" then
            IsAuditor = true
        else
            IsAuditor = false
        end
    end
    if ctype == "corpus" then
        local name = mysplit(args[1], "[")[1]
        if name == "Auditor Halo " and not JustHealed then
            JustHealed = true
            RunAfter(0.2, "NormalState")
            ChangeProperty(args[1], {3}, "corpus")
        end
    end
end

function Teleport()
    ChangeProperty(Player, GetMouseWorldPos(), "position")
end
function Start()
    PlayerName = mysplit(Player, "]")[1]
    if PlayerName == "Auditor Halo " then
        IsAuditor = true
    end
end

function DestroyObject(objname)
    if HasCombatantBase(objname) then
        Destroy(objname)
    end
end

function UpdateAnim(objname)
    if not HasCombatantBase(objname) then
        return
    end
    math.randomseed(os.time())
    local pos = GetProperty(Player, "position")
    ChangeProperty(objname, {pos[1] + math.random(0.5, 1), pos[2], pos[3] + math.random(0.5, 1)}, "position")
    local scale = GetProperty(objname, "scale");
    local newScale = {scale[1] * 0.99, scale[2] * 0.99, scale[3] * 0.99}
    ChangeProperty(objname, newScale, "scale")
    if HasCombatantBase(objname) then
        RunAfter(0.01, "UpdateAnim", {objname})
    end
end
function AnimateObject(objname)
    --bring the object closer to the player over 2 seconds, make the object change scale slowly before destroying it
    local obj = GetProperty(objname, "position")
    if objname == Player or not HasCombatantBase(objname) then
        return
    end
    local player = GetProperty(Player, "position")

    RunAfter(2, "DestroyObject", {objname})
    UpdateAnim(objname)
end
function Update()
    if IsAuditor then
        if GetMouseButtonDown(2) then
            PlayCutscene("test.json")
            RunAfter(0.1, "Teleport")
        end
        if GetKeyDown("Semicolon") then
            local objects = OverlapSphere(GetProperty(Player, "position"), 10)
            for i = 1, #objects do
                if objects[i] != Player and HasCombatantBase(objects[i]) then
                    RemoveColliders(objects[i])
                    AnimateObject(objects[i])
                end
            end
        end
    end
end
