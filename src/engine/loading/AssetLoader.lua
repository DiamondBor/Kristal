---@class AssetLoader<TAssetType, TTask, TTaskResult> : Class
---@overload fun(valid_subfolders: string[], valid_extensions: string[]) : AssetLoader
local AssetLoader, super = Class(nil, "AssetLoader")

---@param valid_subfolders string[]
---@param valid_extensions string[]
function AssetLoader:init(valid_subfolders, valid_extensions)
    self.valid_subfolders = valid_subfolders
    self.valid_extensions = valid_extensions
end

---@param file FilePath
---@param queue table<string, TTask>
function AssetLoader:beginLoad(file, queue) end

---@param asset_id string
---@param task TTask
---@param predecoded table? Data decoded ahead of time by a worker thread, keyed by file path
---|string
---|love.Data
---@return TTaskResult
function AssetLoader:load(asset_id, task, predecoded)
    error(ClassUtils.getClassName(self) .. " has not overriden load!")
end

--- Files that this loader wants decoded on a worker thread ahead of load().
--- Loaders that return nil are loaded synchronously
---@param task TTask
---@return {kind: "image"|"sound", path: string}[]? files
function AssetLoader:getDecodeJobs(task) end

---@param asset_id string
---@param output TTaskResult
---@return TAssetType
function AssetLoader:apply(asset_id, output)
    error(ClassUtils.getClassName(self) .. " has not overriden apply!")
end

---@protected
function AssetLoader:logDebug(message) end

---@protected
function AssetLoader:logError(message)
    -- TODO: How the hell will this work on a seperate thread?
    Kristal.Console:error(message)
end

---@protected
function AssetLoader:logWarn(message)
    -- TODO: How the hell will this work on a seperate thread?
    Kristal.Console:warn(message)
end

return AssetLoader
