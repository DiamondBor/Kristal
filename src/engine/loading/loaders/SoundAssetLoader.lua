---@class SoundAssetLoader : AssetLoader<Sound, SoundAssetLoader.Task, SoundAssetLoader.Result>
---@overload fun(valid_subfolders: string[], audio_extensions: string[], metadata_extension: string) : SoundAssetLoader
local SoundAssetLoader, super = Class(AssetLoader, "ShaderAssetLoader"), AssetLoader

---@class SoundAssetLoader.Task
---@field source_path string
---@field metadata_path string?

---@class SoundAssetLoader.Result
---@field sound_data love.SoundData
---@field metadata Assets.sound_settings?

function SoundAssetLoader:init(valid_subfolders, audio_extensions, metadata_extension)
    self.audio_extensions = audio_extensions
    self.metadata_extension = metadata_extension
    super.init(self, valid_subfolders, {metadata_extension, unpack(audio_extensions)})
end

function SoundAssetLoader:beginLoad(file, queue)
    -- Pass the file path to the load thread
    queue[file.identifier] = queue[file.identifier] or {}
    if file.extension == self.metadata_extension then
        queue[file.identifier].metadata_path = file.full_path
    else
        queue[file.identifier].source_path = file.full_path 
    end
end

---@param task SoundAssetLoader.Task
function SoundAssetLoader:getDecodeJobs(task)
    if not task.source_path then
        return nil
    end
    return { { kind = "sound", path = task.source_path } }
end

function SoundAssetLoader:load(asset_id, task, predecoded)
    assert(task.source_path)
    ---@type SoundAssetLoader.Result
    local result = {
        sound_data = predecoded and predecoded[task.source_path] or love.sound.newSoundData(task.source_path),
        metadata = task.metadata_path and JSON.decode(love.filesystem.read(task.metadata_path)) or nil,
    }
    return result
end

function SoundAssetLoader:apply(asset_id, output)
    -- Finally, the shader can be created on the main thread
    return Sound(output.sound_data, output.metadata)
end

return SoundAssetLoader
