local ProjectLoading = {}

function ProjectLoading:init()
end

function ProjectLoading:enter(from, after)
    self.after = after
    self.finished_loading = false
end

function ProjectLoading:update()
    if self.finished_loading then
        return
    end

    local bucket = Assets.getBucket("project")
    if bucket.assets_loaded >= bucket.assets_total then
        self.finished_loading = true
        MOD_LOADING = false
        self.after()
    end
end

function ProjectLoading:draw()
    local bucket = Assets.getBucket("project")
    local total = math.max(bucket.assets_total, 1)
    local progress = MathUtils.clamp(bucket.assets_loaded / total, 0, 1)

    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    Draw.setColor(COLORS.white)
    love.graphics.rectangle("fill", 80, 232, 480, 16)
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", 82, 234, 476, 12)
    Draw.setColor(COLORS.white)
    love.graphics.rectangle("fill", 84, 236, 472 * progress, 8)

    love.graphics.setFont(Assets.getFont("main"))
    Draw.printShadow("Loading...", 0, 200, 2, "center", SCREEN_WIDTH)
end

return ProjectLoading