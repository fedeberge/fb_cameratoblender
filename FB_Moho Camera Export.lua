-- **************************************************
-- Provide Moho with the name of this script object
-- **************************************************
ScriptName = "FB_cameratoblender"

-- **************************************************
-- General information about this script
-- **************************************************

FB_cameratoblender = {}
function FB_cameratoblender:Name()
    return "FB Camera to Blender"
end

function FB_cameratoblender:Version()
    return "1.0"
end

function FB_cameratoblender:Description()
    return "Export camera data to Blender"
end

function FB_cameratoblender:Creator()
    return "/fedeberge"
end

function FB_cameratoblender:UILabel()
    return ("FB Camera to Blender")
end

-- **************************************************
-- The guts of this script
-- **************************************************

function FB_cameratoblender:Run(moho)

    local mohodoc = moho.document
    local name = string.sub(mohodoc:Name(),1,-6)
    local pathFull = LM.GUI.SaveFile("Save Camera Json")
    if (pathFull == "") then
        return
    end

    --pathFull = "C:\\Users\\fede-msi\\Proyectos\\_scripts\\FB-layout-starter\\Untitled "
    path = ""
    for i in string.gmatch(pathFull, ".*\\") do
        if i ~= "Untitled" then
            path = path.. i.. "\\"
        end
    end
    path = string.sub(path,1,-2)

    local f = io.open(path .. name..".json", "w")

    if (f == nil) then
        return
    end
    local width = mohodoc:Width()
    local height = mohodoc:Height()
    local aspect = mohodoc:AspectRatio()
    local newX = mohodoc:Width() / 2
    local newY = mohodoc:Height() / 2
    local newZ = mohodoc:Height() / 2

    local fps = mohodoc:Fps()
    local startframe = mohodoc:StartFrame()
    local endframe = mohodoc:EndFrame()
    local camPos = mohodoc.fCameraTrack
    local camPanTilt = mohodoc.fCameraPanTilt
    local camRoll = mohodoc.fCameraRoll
    local zoomFactor = (1/ math.tan(math.pi/(2 * 6)))/2 * newZ
    local zoomKeys = mohodoc.fCameraZoom:CountKeys()

    local function Escribir(tab, text)
        tab = tab or 0
        local tabs =""
        if tab > 0 then
            for i = 1, tab do
                tabs=tabs.."\t"
            end    
        end
        f:write(tabs .. text .."\n")
    end

    local function XangleToMatrix(angle)
        return {1,0,0, 0, math.cos(angle),-math.sin(angle), 0, math.sin(angle), math.cos(angle)}
    end

    local function YangleToMatrix(angle)
        return {math.cos(angle),0,-math.sin(angle),0,1,0,math.sin(angle),0,math.cos(angle)}
    end

    local function ZangleToMatrix(angle)
        return {math.cos(angle),-math.sin(angle),0,math.sin(angle),math.cos(angle),0,0,0,1}
    end

    local function MultiplyMatrices(matrix1, matrix2)
        local m1a,m1b,m1c,m1d,m1e,m1f,m1g,m1h,m1i = matrix1[1],matrix1[2],matrix1[3],matrix1[4],matrix1[5],matrix1[6],matrix1[7],matrix1[8],matrix1[9]
        local m2j,m2k,m2l,m2m,m2n,m2o,m2p,m2q,m2r = matrix2[1],matrix2[2],matrix2[3],matrix2[4],matrix2[5],matrix2[6],matrix2[7],matrix2[8],matrix2[9]
        return {m1a*m2j+m1b*m2m+m1c*m2p, m1a*m2k+m1b*m2n+m1c*m2q, m1a*m2l+m1b*m2o+m1c*m2r, m1d*m2j+m1e*m2m+m1f*m2p, m1d*m2k+m1e*m2n+m1f*m2q, m1d*m2l+m1e*m2o+m1f*m2r, m1g*m2j+m1h*m2m+m1i*m2p, m1g*m2k+m1h*m2n+m1i*m2q, m1g*m2l+m1h*m2o+m1i*m2r}
    end

    local function RotationToMatrix(i, camPanTilt, camRoll)
        local camRotX = camPanTilt:GetValue(i).x
        local camRotY = camPanTilt:GetValue(i).y
        local camRotZ = camRoll:GetValue(i)
        local camMatrixX = XangleToMatrix(camRotX)
        local camMatrixY = YangleToMatrix(camRotY)
        local camMatrixZ = ZangleToMatrix(camRotZ)
        local camMatrixXY = MultiplyMatrices(camMatrixX, camMatrixY)
        local camMatrixXYZ = MultiplyMatrices(camMatrixXY, camMatrixZ)
        return (camMatrixXYZ)
    end

    --empieza el archivo
    Escribir(0, "{")
    Escribir(1, "\"layers\": [")
    Escribir(2, "{")
    Escribir(3, "\"name\": \"Camera\",")
    Escribir(3, "\"type\": \"camera\",")
    Escribir(3, "\"index\": 1,")
    Escribir(3, "\"parentIndex\": null,")
    Escribir(3, "\"transform\": {")
    Escribir(4, "\"startFrame\": 0,")
    Escribir(4, "\"keyframes\": [")
    for i = startframe, endframe do
        local camPosX = camPos:GetValue(i).x
        local camPosY = camPos:GetValue(i).y
        local camPosZ = camPos:GetValue(i).z
        local frameMatrix = RotationToMatrix(i, camPanTilt, camRoll)
        local escribirMatrix = frameMatrix[1] .. ", " .. frameMatrix[2] .. ", " .. frameMatrix[3] .. ", " .. camPosX .. ", " .. frameMatrix[4] .. ", " .. frameMatrix[5] .. ", " .. frameMatrix[6] .. ", " .. -camPosY .. ", " .. frameMatrix[7] .. ", " .. frameMatrix[8] .. ", " .. frameMatrix[9] .. ", " .. -camPosZ
        if i == endframe then
            Escribir(5, "[" .. escribirMatrix .. "]")
        else
            Escribir(5, "[" .. escribirMatrix .. "],") 
        end        
    end
    Escribir(4, "]")
    Escribir(3, "},")
    -- zoom
    
    Escribir(3, "\"zoom\": {")
    Escribir(4, "\"numDimensions\": 1,")
    Escribir(4, "\"channels\": [")
    Escribir(5, "{")
    Escribir(6, "\"isKeyframed\": true,")
    Escribir(6, "\"keyframesFormat\": \"bezier\",")
    Escribir(6, "\"keyframes\": [")
    for i = startframe, endframe do
        local tiempo = i/fps
        Escribir(7, "{")
        Escribir(8, "\"value\": 1870.56,")
        Escribir(8, "\"easeIn\": {")
        Escribir(9, "\"speed\": 0,")
        Escribir(9, "\"influence\": 16.666666667")
        Escribir(8, "},")
        Escribir(8, "\"easeOut\": {")
        Escribir(9, "\"speed\": 0,")
        Escribir(9, "\"influence\": 16.666666667")
        Escribir(8, "},")
        Escribir(8, "\"time\": "..tiempo..",")
        Escribir(8, "\"interpolationIn\": \"linear\",")
        Escribir(8, "\"interpolationOut\": \"linear\"")
        if i == endframe then
            Escribir(7, "}")
        else
            Escribir(7, "},")
        end
    end
    Escribir(6, "]")
    Escribir(5, "}")
    Escribir(4, "]")
    Escribir(3, "}")
    Escribir(2, "}")
    Escribir(1, "],")
    Escribir(1, "\"sources\": [],")
    Escribir(1, "\"comp\": {")
    Escribir(2, "\"width\": ".. width .. ",")
    Escribir(2, "\"height\": ".. height .. ",")
    Escribir(2, "\"name\": \"".. name.. "\",")
    Escribir(2, "\"pixelAspect\": 1,")
    Escribir(2, "\"frameRate\": " .. fps ..",")
    Escribir(2, "\"workArea\": [".. startframe/fps .. ", " .. endframe/fps .. "]")
    Escribir(1, "}, ")
    Escribir(1, "\"transformsBaked\": true,")
    Escribir(1, "\"version\": 2")
    Escribir(0, "}")      
    f:close() -- Close the file
end
