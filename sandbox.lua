sandbox_env = {}

local function setfenv(fn, env)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if name == "_ENV" then
      debug.upvaluejoin(fn, i, (function()
        return env
      end), 1)
      break
    elseif not name then
      break
    end

    i = i + 1
  end

  return fn
end

function run_sandbox(sb_env, sb_func, ...)
  if (not sb_func) then return nil end
  setfenv(sb_func, sb_env)
  local sb_ret={_ENV.pcall(sb_func, ...)}
  return _ENV.table.unpack(sb_ret)
end

function verifyTransaction(bytecode)
    local lz4 = require("lz4")
    f = load(lz4.decompress(bytecode))
    pcall_rc, result_or_err_msg = run_sandbox(sandbox_env, f)
    if type(result_or_err_msg) ~= "boolean" then
        return false
    else
        return result_or_err_msg
    end
end
