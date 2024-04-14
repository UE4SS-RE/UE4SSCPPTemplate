import("core.base.option")
import("devel.git")
import("devel.git.submodule")
import("core.base.semver")

local ue4ss_url = "https://github.com/UE4SS-RE/RE-UE4SS.git"
local ue4ss_dir = "RE-UE4SS"

function main()
    local remote = option.get("remote")
    local update = option.get("update")

    if (remote == nil and update == nil) then
        print("No arguments. Run 'xmake ue4ss --help'")
        os.exit()
    end

    local ue4ss_repo = path.join("$(projectdir)", ue4ss_dir)
    if not os.exists(ue4ss_repo) then
        print("Cloning UE4SS Repository...")
        git.clone(ue4ss_url)
    end

    if remote then
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
            remote = latest_tag
        end

        -- Returns a matching version/tag/branch based on the provided "remote" string.
        -- Uses semantic versioning or branch naming.
        local remote, type = semver.select(remote, nil, git.tags(ue4ss_url), git.branches(ue4ss_url))
        if not remote then
            print("%s was not found as a valid git remote.")
            os.exit()
        end

        if type == "tag" then
            -- Special logic to ensure we don't check out a tag that doesn't have xmake.
            -- This would put the user's local repo into an unrecoverable state.
            if not semver.satisfies(remote, ">3.0.1") then
                print("The latest tag %s is not compatible with xmake. Using 'main' branch instead of a tag.", remote)
                remote = "main"
                type = "branch"
            end
        end

        print("Checking out %s %s...", type, remote)
        git.checkout(remote,{repodir=ue4ss_dir})
    end

    if update then
        -- If the user specifies a tag, then we don't need to pull/update.
        local cur_branch = git.branch({repodir = ue4ss_dir})
        if cur_branch then
            git.pull({remote = "origin", tags = true, repodir = ue4ss_dir})
        else
            print("UE4SS is not currently a branch. No remote changes to pull.")
        end

        print("Updating submodule")
        submodule.update({repodir = ue4ss_dir, recursive = true, init=true})
    end
end