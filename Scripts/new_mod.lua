import("core.base.option")
import("devel.git")
import("devel.git.submodule")
import("core.base.task")
import("detect.sdks.find_vstudio")
import("core.base.task")
import("core.base.semver")

function main()

    -- validate?
    local mod_name = option.get("name")

    if not mod_name then
        print("Please specify a mod name.")
        os.exit()
    end

    -- Step 1: Initialise or update RE-UE4SS repository on the latest release tag.
    if not os.exists(path.join("$(projectdir)", "RE-UE4SS")) then
        print("UE4SS repository not yet cloned. Automatically cloning...")
        task.run("ue4ss", {update={}, remote="latest"})
    end

    -- Step 2: Create mod directory and files.
    local mods_dir = path.join("$(projectdir)", "Mods")

    if os.exists(mod_name) then
        if option.get("regen") then
            print("Regenerating mod directory and files.")
            CreateModFiles(mod_name, mods_dir)
        else 
            print("Mod directory already exists. Run with the --regen flag to regenerate mod files.")
            os.exit()
        end
    else
        CreateModFiles(mod_name, mods_dir)
    end

    -- Step 3: Generate VS project if VS2022 is installed
    local vs_versions = find_vstudio()
    if(vs_versions and vs_versions["2022"]) then
        -- Equivalent to xmake project -k vsxmake2022 -y
        task.run("project", {kind="vsxmake2022", yes={}})
    end
end

function CreateModFiles(mod_name, mods_dir)
    print("Creating mod directory and files...")
    local mod_dir = path.join(mods_dir, mod_name)
    os.mkdir(mod_dir)

    local mod_xmake = path.join(mod_dir, "xmake.lua")
    os.cp(path.join("$(projectdir)", "xmake_template.lua"), mod_xmake)

    io.replace(mod_xmake, "MyAwesomeMod", mod_name)

    local mod_cpp = path.join(mod_dir, "dllmain.cpp")
    os.cp(path.join("$(projectdir)", "dllmain_template.cpp"), mod_cpp)
    io.replace(mod_cpp, "MyAwesomeMod", mod_name)
    io.replace(mod_cpp, "MY_AWESOME_MOD_API", string.upper(mod_name).."_API")
end

