local api = require('vfiler/actions/api')
local directory = require('vfiler/actions/directory')

local M = {}

function M.open_by_choose_or_open_tree(vfiler, context, view)
  local item = view:get_item()
  if item.type == 'directory' then
    directory.open_tree(vfiler, context, view)
  else
    api.open_file(vfiler, context, view, item.path, 'choose')
  end
end

function M.close_tree(vfiler, context, view)
  local item = view:get_item()
  local level = item and item.level or 0
  if (level > 1 or (level == 1 and item.opened)) then
      directory.close_tree(vfiler, context, view)
  end
end

function M.wipeout(vfiler, context, view)
  vfiler:wipeout()
end

return M
