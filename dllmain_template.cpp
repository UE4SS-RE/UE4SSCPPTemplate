#include <Mod/CppUserModBase.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>

using namespace RC;
using namespace RC::Unreal;

class MyAwesomeMod : public CppUserModBase
{
public:
    MyAwesomeMod() : CppUserModBase()
    {
        ModName = STR("MyAwesomeMod");
        ModVersion = STR("1.0");
        ModDescription = STR("This is my awesome mod");
        ModAuthors = STR("UE4SS Team");
        // Do not change this unless you want to target a UE4SS version
        // other than the one you're currently building with somehow.
        //ModIntendedSDKVersion = STR("2.6");
        
        Output::send<LogLevel::Verbose>(STR("MyAwesomeMod says hello\n"));
    }

    ~MyAwesomeMod() override {}

    auto on_update() -> void override {}

    auto on_unreal_init() -> void override
    {
        auto Object = UObjectGlobals::StaticFindObject<UObject*>(nullptr, nullptr, STR("/Script/CoreUObject.Object"));
        Output::send<LogLevel::Verbose>(STR("Object Name: {}\n"), Object->GetFullName());
    }
};

#define MY_AWESOME_MOD_API __declspec(dllexport)
extern "C"
{
    MY_AWESOME_MOD_API CppUserModBase* start_mod()
    {
        return new MyAwesomeMod();
    }

    MY_AWESOME_MOD_API void uninstall_mod(CppUserModBase* mod)
    {
        delete mod;
    }
}
