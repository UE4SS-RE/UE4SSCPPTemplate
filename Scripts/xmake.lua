task("ue4ss")
    on_run("ue4ss_git")
    set_menu {
        usage = "xmake ue4ss [options]",
        description = "Change the version of ue4ss that is fetched from github.",
        options = 
        {
            {'r', 'remote', "v", "latest", "Tag/branch of UE4SS to use. Ex: 'latest', 'v3.0.1', 'experimental', 'main'"},
            {'u', 'update', "k", nil, "Fetches and downloads any remote changes. Only works when the --remote arg is a git branch."},
        }
    }

task("newmod")
    on_run("new_mod")
    set_menu {
        usage = "xmake newmod [options] [modname]",
        description = "Bootstrap a new mod",
        options = 
        {
            {'r', 'regen', "k", nil, "Forcibly regenerate the mod."},
            {nil, 'name', "v", nil, "Name of the new mod to create."},
        }
    }

task("installmod")
    on_run("install_mod")
    set_menu {
        usage = "xmake installmod [options] [modname]",
        description = "Installs a mod into the specified game directory.",
        options = 
        {
            {'d', 'exedir', "v", nil, "Path of the game's executable folder"},
            {nil, 'name', "v", nil, "Name of the mod to install."},
        }
    }

task("bi")
    on_run("build_and_install")
    set_menu {
        usage = "xmake bi [options] [modname]",
        description = "Build and install a mod. Equivalent to 'xmake build' followed by 'xmake installmod'",
        options = 
        {
            {'d', 'exedir', "v", nil, "Path of the game's executable folder"},
            {nil, 'name', "v", nil, "Name of the mod to build and install."},
        }
    }