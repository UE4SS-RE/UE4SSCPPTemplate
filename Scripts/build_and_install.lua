import("core.base.option")
import("core.base.task")

function main()
    task.run("build", option.get("name"), "-y")
    task.run("installmod", {exedir=option.get("exedir"), name=option.get("name")})
end
