# UE4SSCPPTemplate

This repository includes some custom `xmake` tasks to assist in your mod development.

- `xmake newmod`
- `xmake installmod`
- `xmake bi`
- `xmake ue4ss`

## `xmake newmod [-r, --regen] name`

The `newmod` command will ensure you have the UE4SS repository cloned and then bootstrap new mod creation.

Running `xmake newmod CoolMod` will generate `/Mods/CoolMod/...` in your repository and automatically link it with the xmake system. If you have VS2022 installed then the `newmod` command will also automatically generate a VS project which can be located at `/vsxmake2022/UE4SSCppTemplate.sln`.

## `xmake installmod [-d, --exedir] name`

The `installmod` command will copy your build output to a specific game directory. The configuration of the build you want to install is derived from the currently configured xmake mode (`xmake f -m <mode>`). This configured mode is global to the `RE-UE4SS` repo and all the mods in the `Mods` folder. If you want to specify a specific configuration to install, then you can change the xmake configuration by running `xmake f -m "Game__Debug__Win64"`.

Running `xmake installmod --exedir="Path\To\Your\Game\Dir" CoolMod` will copy the build output and install `CoolMod` in the correct subdir in the game's mod folder.

Note that running `xmake installmod` does not automatically build your mod. You have to manually build it with `xmake build` or use the `xmake bi` task to build and install your mod.

## `xmake bi [-d, --exedir] name`

This is a shorthand task that will run `xmake build -y <modname>` followed by the `xmake installmod` command. This one-liner command facilitates rapid testing/iterating of your mod.

## `xmake ue4ss [-r, --remote] [-u, --update]`

By default, the `xmake newmod` command will attempt to checkout the latest release tag of UE4SS to build your mods against. If you want to build your mods against a different remote then you can specify a branch or tag as the `--remote=` parameter.

`xmake ue4ss --remote="v3.1.0"` will attempt to use tag "v3.1.0" as the checked out UE4SS version.

You can use the latest release tag by specifying `xmake ue4ss --remote="latest"`.

You can also specify branches instead of tags to use. `xmake ue4ss --remote=main` will checkout the `main` branch of UE4SS.

If you want to get upstream changes from remote branches then you can use the `--update` arg to pull remote changes.

`xmake ue4ss --remote=main --update` will pull the latest remote changes from the `main` branch locally.

You can also run `xmake ue4ss --update` and xmake will try to pull changes from whatever branch your local UE4SS is currently on.