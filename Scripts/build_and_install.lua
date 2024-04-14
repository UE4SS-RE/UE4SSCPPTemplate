import("core.base.option")
import("core.base.task")

function main()
    task.run("build", {yes=nil}, option.get("name"))
    task.run("installmod", {exedir=option.get("exedir"), name=option.get("name")})
end
