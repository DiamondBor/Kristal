local in_channel = love.thread.getChannel("asset_decode_in")
local out_channel = love.thread.getChannel("asset_decode_out")

while true do
    local job = in_channel:demand()
    if job == "stop" then
        break
    end

    local results = {}
    local ok = pcall(function()
        for _, file in ipairs(job.files) do
            if file.kind == "image" then
                results[file.path] = love.image.newImageData(file.path)
            elseif file.kind == "sound" then
                results[file.path] = love.sound.newSoundData(file.path)
            end
        end
    end)
    out_channel:push({
        bucket = job.bucket,
        type = job.type,
        id = job.id,
        results = ok and results or nil,
    })
end