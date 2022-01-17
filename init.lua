--- Lua library for reading PBM/PGM/PPM files.
local pbm = {}

--- Read a PBM/PGM/PPM file.
---@param stream file*
---@return integer, integer, integer[]
---@overload fun(path: string): integer, integer, integer[]
function pbm.read(stream)
    assert(type(stream) == "userdata" or type(stream) == "string", "stream must be a file or a path")
    
    if type(stream) == "string" then
        stream = io.open(stream, "rb")
    end
    assert(stream, "could not open file")

    local version = tonumber(stream:read(2):match("^P(%d)"))
    assert(version, "invalid PBM/PGM/PPM file")
    
    local width, height = stream:read("*n", "*n")
    local data = {}

    if version == 6 then
        local maxval = stream:read("*n")
        assert(maxval, "max value not found")

        while stream:read(1) == "#" do
            stream:read("*l")
        end

        for i = 1, width * height do
            local r, g, b = stream:read(3):byte(1, 3)
            data[i] = r * 0x10000 + g * 0x100 + b
        end
    else
        error(("version %d is invalid or not supported"):format(version))
    end

    stream:close()
    return width, height, data
end

return pbm