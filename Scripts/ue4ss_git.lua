import("core.base.option")
import("devel.git")
import("devel.git.submodule")
import("core.base.semver")

local ue4ss_url = "https://github.com/UE4SS-RE/RE-UE4SS.git"
local ue4ss_dir = "RE-UE4SS"

function main()
    local remote = option.get("remote")
    local update = option.get("update")

    if not (remote and update) then
        print("No arguments. Run 'xmake ue4ss --help'")
        os.exit()
    end
    
    try_clone_ue4ss()

    -- Special handling if the user wants to find the 'latest' release tag.
    if remote == "latest" then
        print("Attempting to find latest release tag...")
        local tags = git.tags(ue4ss_url)
        local latest_tag
        for _,tag in ipairs(tags) do
            if semver.is_valid(tag) then
                if not latest_tag then
                    latest_tag = tag
                end

                if semver.compare(tag, latest_tag) == 1 then
                    latest_tag = tag
                end
            end
        end

        -- Special logic to ensure we don't check out a tag that doesn't have xmake.
        -- This would put the user's local repo into an unrecoverable state.
        if latest_tag then
            if not semver.satisfies(latest_tag, ">3.0.1") then
                print("The latest tag %s is not compatible with xmake. Using 'main' branch instead of a tag.", latest_tag)
                latest_tag = "main"
            end

            print("Using latest tag: %s", latest_tag)
        end

        remote = latest_tag
    end

    -- Returns a matching version/tag/branch based on the provided "remote" string.
    -- Uses semantic versioning or branch naming.
    local remote, type = semver.select(remote, nil, git.tags(ue4ss_url), git.branches(ue4ss_url))
    if not remote then
        print("%s was not found as a valid git remote.")
        os.exit()
    end
    
    git.checkout(remote,{repodir=ue4ss_dir})

    if update then
        -- If the user specifies a tag, then we don't need to pull/update.
        local cur_branch = git.branch({repodir = ue4ss_dir})
        if cur_branch then
            git.pull({remote = "origin", tags = true, repodir = ue4ss_dir})
            submodule.update({repodir = ue4ss_dir, recursive = true})
        else
            print("UE4SS is not currently a branch. Update has no effect")
        end
    end
end

function try_clone_ue4ss()
    local ue4ss_dir = path.join("$(projectdir)", "RE-UE4SS")
    if not os.exists(ue4ss_dir) then
        print("Cloning UE4SS Repository...")
        git.clone(ue4ss_url)
    end
end