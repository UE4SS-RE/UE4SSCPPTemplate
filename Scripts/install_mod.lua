import("core.base.option")
import("core.base.task")
import("core.project.config")
import("core.project.project")

function main()
    -- validate?
    local mod_name = option.get("name")
    local mod_dir = path.join(option.get("exedir"), "Mods", mod_name)

    -- Get the current build mode. ex: Game__Shipping__Win64
    config.load()
    local mode = config.get("mode")
    print("Using the mode from xmake config: %s", mode)

    -- Load the dll location from the xmake target for the mod.
    local target = project.target(mod_name)

    if not target then
        print("Target %s not found.", mod_name)
        os.exit()
    end
    
    -- Step 1: Check if we have build output.
    if not os.exists(target:targetfile()) then
        print("Build output not detected at %s", target:targetfile())
        os.exit()
    end

    -- Step 2: Copy to the mods folder.
    local dll_dir = path.join(mod_dir, "dlls")
    if not os.exists(dll_dir) then
        print("%s not found. Creating...", dll_dir)
        os.mkdir(dll_dir)
    end

    os.cp(target:targetfile(), path.join(dll_dir, "main.dll"))

    if os.exists(target:symbolfile()) then
        print("Symbol file detected. Copying to mod directory...")
        os.cp(target:symbolfile(), path.join(dll_dir, "main.pdb"))
    end

    -- Step 3: Create the enabled.txt in the mods folder.
    if not os.exists(path.join(mod_dir, "enabled.txt")) then
        print("enabled.txt not found. Creating...")
        io.writefile(path.join(mod_dir, "enabled.txt"))
    end
end