# UE4SSCPPTemplate

To setup your project, run the following command in this directory, replacing "YourModName" with the name of your mod (no spaces or special characters, please!):

```bash
.\new_mod_setup.bat YourModName
```

This will create a directory vsxmake2022 with a `.sln` file that you can open.

Then, when you are ready to build and install your mod into your game, run the following command in this directory:

```bash
.\build_and_install_mod.bat YourModName "Path\To\Your\Game\UE4SS\Install\Directory" Build__Configuration 
```

For example:

```bash
.\build_and_install_mod.bat MyAwesomeMod "C:\Program Files (x86)\Steam\steamapps\common\Deep Rock Galactic\FSD\Binaries\Win64" Game__Shipping__Win64
```