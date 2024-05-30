includes("RE-UE4SS")

task("init")
    on_run(function ()
        -- Find UE4SS
        if os.isdir("RE-UE4SS") then
            -- already exists, nothing to do
            print("UE4SS already exists.")
            return
        end

        -- get UE4SS, either by git or local
        import("core.base.option")
        if option.get("dir") then
            local dir = path.absolute(option.get("dir"))
            if not os.isdir(dir) then
                print("Directory " .. dir .. " does not exist.")
                return
            end
            print("Using local UE4SS from " .. dir .. "...")
            -- mkdir
            os.mkdir("RE-UE4SS")
            -- oprn RE-UE4SS/xmake.lua and write includes("path/to/RE-UE4SS")
            local file = io.open("RE-UE4SS/xmake.lua", "w")
            file:write('includes("' .. dir .. '")')
            file:write("isOutOfTree = true")
            file:close()
        else
            if option.get("source") then
                print("Cloning UE4SS from " .. option.get("source") .. "...")
                import("devel.git")
                if option.get("branch") then
                    git.clone(option.get("source"), {depth = 1, branch = option.get("branch"), outputdir = "RE-UE4SS", recurse_submodules = true})
                else 
                    git.clone(option.get("source"), {depth = 1, outputdir = "RE-UE4SS", recurse_submodules = true})
                    local tags = git.tags(url)
                end
            end
        end
    end)

    set_menu {
        usage = "xmake init [options]",
        description = "Initialize UE4SS Mod template",
        options = {
            {'s', "source", "kv", "https://github.com/UE4SS-RE/RE-UE4SS", "Set the source repository of UE4SS"},
            {'b', "branch", "kv", "main", "Set the branch of UE4SS"},
            {'d', "dir", "kv", nil, "Set the directory of local UE4SS source tree"},
        }
    }
task_end()

task("update")
    on_run(function () 
        -- Find UE4SS
        if not os.isdir("RE-UE4SS") then
            print("UE4SS not found.")
            return
        end

        -- Check if it is out of tree
        if isOutOfTree then
            print("You are using local UE4SS, please update it manually.")
            return
        end

        -- Found UE4SS, update it to the latest version
        print("Updating UE4SS...")
        git.pull({remote = "origin", repodir = "./RE-UE4SS"})
        import("devel.git.submodule")
        submodule.update({repodir = "./RE-UE4SS", recursive = true})
    end)
    set_menu {
        usage = "xmake update",
        description = "Update UE4SS Repository"
    }
task_end()

    
task("new")
    on_run(function ()

    function gsub_template(template_file, target_file, kw, replace)
        -- open template file and replace the name
        local file = io.open(template_file, "r")
        local content = file:read("*a")
        file:close()

        for k, v in pairs(kw) do
            content = content:gsub(k, v)
        end

        -- write to target file
        local file = io.open(target_file, "w")
        file:write(content)
        file:close()
    end

    function parse_upper_camel_case(name) 
            local len = #name
            local part = ""
            local parts = {}
            local i = 1
            -- ([A-Z]+)(?=[A-Z][a-z]|$)|([A-Z]?[a-z0-9]+)
            while i <= len do
                local c = name:sub(i, i)
                -- if it is uppercase
                if c:match("%u") then
                    local j = i
                    local more_than_one_upper = false
                    local lower_case_exists = false
                    while j + 1 <= len do
                        local d = name:sub(j + 1, j + 1)
                        if d:match("%u") then
                            if lower_case_exists then 
                                -- j + 1 .. is new part
                                -- i .. j is the part
                                break
                            else
                                more_than_one_upper = true
                            end
                        else
                            -- j + 1 is lowercase
                            if more_than_one_upper then
                                -- j, j + 1 is next part
                                -- i .. j - 1 is the part
                                j = j - 1
                                break
                            else
                                lower_case_exists = true
                            end
                        end
                        j = j + 1
                    end
                    table.insert(parts, name:sub(i, j))
                    i = j + 1
                end
            end
            return parts
        end

        -- Find UE4SS
        if not os.isdir("RE-UE4SS") then
            print("UE4SS not found.")
            return
        end

        local exists_and_force = false

        import("core.base.option")

        local name = option.get("name")
        local install_arg = option.get("install")
        
        -- Check if the mod already exists
        if not name then
            print("Please specify the name of the new mod.")
            return
        end

        -- Check if the mod name is a valid upper camel case
        if not name:match("^[A-Z][a-zA-Z0-9]*$") then
            print("Invalid mod name. Please use upper camel case.")
            return
        end

        if os.isdir(name) or os.isfile(name) then
            if option.get("force") and install_arg then
                exists_and_force = true
            else
                print("Mod " .. name .. " already exists.")
                return
            end
        end

        -- convert it to underscore format use regex
        -- [A-Z]+(?=[A-Z][a-z]|$)|[A-Z]?[a-z0-9]+
        local name_parts = parse_upper_camel_case(name)
        -- join the parts with underscore
        local name_underscore = table.concat(name_parts, "_"):upper()

        -- Create the new mod
        if not exists_and_force then
            print("Creating new mod " .. name .. "...")
            os.mkdir(name)
            
            -- open template file and replace the name
            gsub_template("assets/dllmain_template.cpp", name .. "/dllmain.cpp", {["MyAwesomeMod"] = name, ["MY_AWESOME_MOD_API"] = name_underscore:upper() .. "_API"})
            gsub_template("assets/xmake_template.lua", name .. "/xmake.lua", {["MyAwesomeMod"] = name})
        end 
        
        -- save install path
        if install_arg then
            -- escape backslashes
            local install = path.absolute(option.get("install"))
            -- .moddev/config.json
            local config = path.join(".moddev", "config.json")
            import("core.base.json")
            if os.isfile(config) then
                local data = json.loadfile(config)
                data["mods"][name] = {
                    ["name"] = name,
                    ["underscore"] = name_underscore,
                    ["install"] = install,
                    ["type"] = "CppMod"
                }
                json.savefile(config, data)
            else
                local data = {
                    ["mods"] = {
                        [name] = {
                            ["name"] = name,
                            ["underscore"] = name_underscore,
                            ["install"] = install,
                            ["type"] = "CppMod"
                        }
                    },
                    ["version"] = "0.0.1",
                }
                json.savefile(config, data)
            end
        end
    end)

    set_menu {
        usage = "xmake new -n name [options]",
        description = "Create a new RE-UE4SS Mod",
        options = {
            -- mod name
            {'n', "name", "kv", nil, "Set the name of the new mod"},
            -- install location
            {'i', "install", "kv", nil, "Set the install location of the new mod"},
            {'f', "force", "k", false, "Ignore existing mod and create install entry"},
        }
    }

task_end()