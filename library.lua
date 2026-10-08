local function uppercasePortuguese(value)
    local letters = { ["á"]="Á", ["à"]="À", ["â"]="Â", ["ã"]="Ã", ["ä"]="Ä", ["é"]="É", ["ê"]="Ê", ["è"]="È", ["í"]="Í", ["ì"]="Ì", ["ó"]="Ó", ["ô"]="Ô", ["õ"]="Õ", ["ò"]="Ò", ["ú"]="Ú", ["ü"]="Ü", ["ù"]="Ù", ["ç"]="Ç" }
    local result = string.upper(tostring(value))
    for lower, upper in pairs(letters) do
        result = result:gsub(lower, upper)
    end
    return result
end
local Palette = {
    Accent = "#E6E6EB",
    AccentSoft = "#DCDCE2",
    Primary = "#505056",
    Background = "#101011",
    BackgroundDeep = "#121214",
    BackgroundAlt = "#141415",
    Panel = "#141415",
    Surface = "#141415",
    SurfaceRaised = "#18181A",
    Hover = "#28282B",
    Border = "#242427",
    Text = "#E8E8EC",
    Muted = "#828288",
    Subtle = "#828288",
    Success = "#96DCAA",
    Warning = "#F0B06C",
    Danger = "#F07878",
}
local RuntimeFactory = (function()
    return function()
        local environment = getfenv()
        if type(getgenv) == "function" then
            local success, value = pcall(getgenv)
            if success and type(value) == "table" then
                environment = value
            end
        end
        local function firstFunction(...)
            for index = 1, select("#", ...) do
                local value = select(index, ...)
                if type(value) == "function" then
                    return value
                end
            end
        end
        local cloneReference = firstFunction(environment.cloneref, cloneref, environment.clonereference, clonereference)
        local parentAPIs, registered = {}, {}
        local function addParentAPI(configuration, name)
            if type(configuration) == "function" and not registered[configuration] then
                registered[configuration] = true
                parentAPIs[#parentAPIs + 1] = { Call = configuration, Name = name }
            end
        end
        addParentAPI(environment.gethui, "gethui")
        addParentAPI(gethui, "gethui")
        addParentAPI(environment.get_hidden_gui, "get_hidden_gui")
        addParentAPI(get_hidden_gui, "get_hidden_gui")
        local runtime = {}
        local services = {}
        function runtime.Reference(object)
            if cloneReference and typeof(object) == "Instance" then
                local success, reference = pcall(cloneReference, object)
                if success and typeof(reference) == "Instance" and reference.ClassName == object.ClassName then
                    return reference
                end
            end
            return object
        end
        function runtime.GetService(name)
            if not services[name] then
                services[name] = runtime.Reference(game:GetService(name))
            end
            return services[name]
        end
        function runtime.GetUIParent()
            for _, api in ipairs(parentAPIs) do
                local success, parent = pcall(api.Call)
                if success and typeof(parent) == "Instance"
                and (parent:IsA("CoreGui") or parent:IsA("ScreenGui") or parent:IsA("Folder")) then
                    return parent, api.Name
                end
            end
            local success, studio = pcall(function()
                return runtime.GetService("RunService"):IsStudio()
            end)
            if success and studio then
                local player = runtime.Reference(runtime.GetService("Players").LocalPlayer)
                return player:WaitForChild("PlayerGui"), "PlayerGui (Studio)"
            end
            error("[UI] gethui/get_hidden_gui indisponível ou inválido. A interface não será criada em PlayerGui ou CoreGui automaticamente.", 0)
        end
        return runtime
    end
end)()
local Runtime = RuntimeFactory()
local Airflow = (function()
    local TweenService2=Runtime.GetService("TweenService")
    local UserInputService=Runtime.GetService("UserInputService")
    local GuiService=Runtime.GetService("GuiService")
    local RunService=Runtime.GetService("RunService")
    local HttpService=Runtime.GetService("HttpService")
    local Players2=Runtime.GetService("Players")
    local LocalPlayer=Runtime.Reference(Players2.LocalPlayer)
    local NativeLibrary={}
    NativeLibrary.Flags={}
    NativeLibrary.Windows={}
    local function normalizeOptions2(source,aliases)
        local entries={}
        if type(source)=="string"then
            entries.Name=source
        elseif type(source)=="table"then
            for index2,entry2 in pairs(source)do
                entries[index2]=entry2
            end
        end
        for index3,entry3 in pairs(aliases or{})do
            if entries[entry3]==nil and entries[index3]~=nil then
                entries[entry3]=entries[index3]
            end
        end
        if entries.Range then
            entries.Min=entries.Min or entries.Range[1]
            entries.Max=entries.Max or entries.Range[2]
        end
        return entries
    end
    local function registerElement(tab2,options,element,frame2,kind2)
        element._type=kind2
        element._frame=frame2
        element._listeners=element._listeners or{}
        local value2=tab2 and tab2.Window
        if options.Flag then
            NativeLibrary.Flags[options.Flag]=element
            if value2 then
                local callback2=options.Callback
                options.Callback=function(...)
                    if type(callback2)=="function"then
                        callback2(...)
                    end
                    value2:_autoSave()
                end
            end
        end
        function element:Destroy()
            if element._destroyed then
                return
            end
            element._destroyed=true
            for index4,entry4 in ipairs(element._listeners)do
                entry4()
            end
            element._listeners={}
            if options.Flag and NativeLibrary.Flags[options.Flag]==element then
                NativeLibrary.Flags[options.Flag]=nil
            end
            if value2 then
                value2._controlsDirty=true
            end
            if frame2 then
                frame2:Destroy()
            end
        end
        return element
    end
    NativeLibrary.Theme={
    Background=Color3.fromHex(Palette.Background),
    Surface=Color3.fromHex(Palette.Surface),
    Surface2=Color3.fromHex(Palette.SurfaceRaised),
    Surface3=Color3.fromHex(Palette.Hover),
    Stroke=Color3.fromHex(Palette.Border),
    StrokeHover=Color3.fromHex(Palette.Primary),
    Accent=Color3.fromHex(Palette.Accent),
    AccentDark=Color3.fromHex(Palette.BackgroundDeep),
    Text=Color3.fromHex(Palette.Text),
    Muted=Color3.fromHex(Palette.Muted),
    Glow=Color3.fromHex(Palette.AccentSoft),
    Warning=Color3.fromHex(Palette.Warning),
    Success=Color3.fromHex(Palette.Success),
    Error=Color3.fromHex(Palette.Danger),
}
    NativeLibrary.Assets={Shadow="rbxassetid://6014261993",Glow="rbxassetid://8992230677",Logo="rbxassetid://97170941541314"}
    local lucideIcons
    local function loadLucideIcons()
        if lucideIcons~=nil then
            return lucideIcons
        end
        local success2,result2=pcall(function()
            local value3=game:HttpGet"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
            return loadstring(value3)()
        end)
        if success2 and type(result2)=="table"then
            lucideIcons=result2
        else
            lucideIcons=false
        end
        return lucideIcons
    end
    local fontPresets={ValleySans={Regular="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Regular.ttf",Medium="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Medium.ttf",SemiBold="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-SemiBold.ttf"}}
    local fontWeights={Regular={400,Enum.FontWeight.Regular},Medium={500,Enum.FontWeight.Medium},SemiBold={600,Enum.FontWeight.SemiBold},Bold={700,Enum.FontWeight.Bold}}
    function NativeLibrary:LoadFont(configuration2)
        local text2="function"
        configuration2=normalizeOptions2(configuration2,{})
        if type(writefile)~=text2 or type(isfile)~=text2 or typeof(getcustomasset)~=text2 then
            return false
        end
        local value4=configuration2.Name or"CustomFont"
        local value5=configuration2.Weights or fontPresets[value4]
        if type(value5)~="table"then
            return false
        end
        local value6=configuration2.Folder or"AirFlowFonts"
        pcall(function()
            if type(isfolder)=="function"and type(makefolder)=="function"and not isfolder(value6)then
                makefolder(value6)
            end
        end)
        local entries2={}
        for index5,entry5 in pairs(value5)do
            local value7=fontWeights[index5]
            if value7 then
                local value8,enabled2=value6.."/"..value4.."-"..index5..".ttf",true
                if not isfile(value8)then
                    enabled2=pcall(function()
                        writefile(value8,game:HttpGet(entry5))
                    end)
                end
                if enabled2 then
                    table.insert(entries2,{name=index5,weight=value7[1],style="normal",assetId=getcustomasset(value8)})
                else
                end
            end
        end
        if#entries2==0 then
            return false
        end
        local value9=value6.."/"..value4..".json"
        local success3=pcall(function()
            writefile(value9,HttpService:JSONEncode{name=value4,faces=entries2})
        end)
        if not success3 then
            return false
        end
        local value10=getcustomasset(value9)
        local function callback3(configuration3,argument)
            local value11=fontWeights[configuration3]
            if value11 and value5[configuration3]then
                return Font.new(value10,value11[2])
            end
            return argument
        end
        NativeLibrary.Fonts.Regular=callback3("Regular",NativeLibrary.Fonts.Regular)
        NativeLibrary.Fonts.Medium=callback3("Medium",callback3("Regular",NativeLibrary.Fonts.Medium))
        NativeLibrary.Fonts.Bold=callback3("SemiBold",callback3("Bold",NativeLibrary.Fonts.Bold))
        return true
    end
    function NativeLibrary:PreloadIcons()
        return loadLucideIcons()~=false
    end
    local function resolveIcon(icon2)
        if typeof(icon2)=="table"then
            return icon2.Image,icon2.RectOffset,icon2.RectSize
        end
        if type(icon2)~="string"then
            return nil
        end
        if icon2:find"^rbxassetid://"or icon2:find"^rbxasset://"or icon2:find"^rbxthumb://"or icon2:find"^http"then
            return icon2
        end
        local value12=icon2:gsub("^lucide:","")
        local value13=loadLucideIcons()
        if not value13 then
            return nil
        end
        local value14=value13.Icons and value13.Icons[value12]or value13[value12]
        if type(value14)=="table"then
            local image2=value14.Image
            if type(image2)=="number"then
                image2="rbxassetid://"..tostring(image2)
            end
            local value15=value13.Spritesheets and value13.Spritesheets[tostring(image2)]or image2
            return value15,value14.ImageRectPosition,value14.ImageRectSize
        elseif type(value14)=="string"then
            return value14
        end
        return nil
    end
    local fontFamily="rbxasset://fonts/families/BuilderSans.json"
    NativeLibrary.Fonts={Regular=Font.new(fontFamily,Enum.FontWeight.Regular),Medium=Font.new(fontFamily,Enum.FontWeight.Medium),Bold=Font.new(fontFamily,Enum.FontWeight.SemiBold)}
    local nativeTheme2=NativeLibrary.Theme
    local nativeAssets=NativeLibrary.Assets
    local nativeFonts=NativeLibrary.Fonts
    local isTouchDevice=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    NativeLibrary.Touch=isTouchDevice
    local cardHeight=isTouchDevice and 54 or 48
    local descriptionCardHeight=isTouchDevice and 70 or 64
    local dropdownOptionHeight=isTouchDevice and 40 or 34
    local chipHeight=isTouchDevice and 34 or 28
    local tweenCache={}
    local function animate(object2,properties2,duration2,style2,direction2)
        duration2=duration2 or.2
        if duration2<=0 then
            for index6,entry6 in pairs(properties2)do
                object2[index6]=entry6
            end
            return nil
        end
        style2=style2 or Enum.EasingStyle.Quart
        direction2=direction2 or Enum.EasingDirection.Out
        local value16=duration2..style2.Name..direction2.Name
        local value17=tweenCache[value16]
        if not value17 then
            value17=TweenInfo.new(duration2,style2,direction2)
            tweenCache[value16]=value17
        end
        local value18=TweenService2:Create(object2,value17,properties2)
        value18:Play()
        return value18
    end
    local function createInstance(className2,properties3,children2)
        local value19=Instance.new(className2)
        for index7,entry7 in pairs(properties3)do
            if index7~="Parent"then
                value19[index7]=entry7
            end
        end
        if children2 then
            for index8,entry8 in ipairs(children2)do
                entry8.Parent=value19
            end
        end
        if properties3.Parent then
            value19.Parent=properties3.Parent
        end
        return value19
    end
    local function addCorner(parent2,radius2)
        local radius=radius2 or UDim.new(0,12)
        if radius.Scale==0 and radius.Offset==6 then
            radius=UDim.new(0,8)
        end
        return createInstance("UICorner",{CornerRadius=radius,Parent=parent2})
    end
    local function addStroke(parent3,color2,transparency2,thickness)
        return createInstance("UIStroke",{Color=color2 or nativeTheme2.Stroke,Transparency=transparency2 or 0,Thickness=thickness or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=parent3})
    end
    local function addPadding(parent4,left2,right2,top,bottom)
        return createInstance("UIPadding",{PaddingLeft=UDim.new(0,left2 or 0),PaddingRight=UDim.new(0,right2 or 0),PaddingTop=UDim.new(0,top or 0),PaddingBottom=UDim.new(0,bottom or 0),Parent=parent4})
    end
    local function createLabel(properties4)
        local entries3={BackgroundTransparency=1,TextColor3=nativeTheme2.Text,TextSize=14,FontFace=nativeFonts.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd}
        for index9,entry9 in pairs(properties4)do
            entries3[index9]=entry9
        end
        return createInstance("TextLabel",entries3)
    end
    local function addGlow(configuration4,argument2,argument3,argument4,argument5)
        local imageLabel=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=argument3,Size=argument2,BackgroundTransparency=1,Image=nativeAssets.Glow,ImageColor3=nativeTheme2.Glow,ImageTransparency=argument4,ZIndex=0,Parent=configuration4})
        createInstance("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(255,255,255),nativeTheme2.Accent),Rotation=argument5 or 90,Parent=imageLabel})
        return imageLabel
    end
    local function addEdgeHighlight(configuration5)
        return createInstance("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.93,BorderSizePixel=0,ZIndex=0,Parent=configuration5})
    end
    local function applyIcon(image3,icon3)
        local imageAsset,imageOffset,imageSize2=resolveIcon(icon3)
        if not imageAsset then
            return
        end
        image3.Image=imageAsset
        image3.ImageRectOffset=imageOffset or Vector2.zero
        image3.ImageRectSize=imageSize2 or Vector2.zero
    end
    local function getInterfaceParent()
        return Runtime.GetUIParent()
    end
    local activeTouch,touchPosition=nil,Vector2.zero
    local function getPointerPosition()
        local value20=time()
        if activeTouch~=value20 then
            activeTouch=value20
            touchPosition=GuiService:GetGuiInset()
        end
        return UserInputService:GetMouseLocation()-touchPosition
    end
    local function isPrimaryInput(input2)
        return input2.UserInputType==Enum.UserInputType.MouseButton1 or input2.UserInputType==Enum.UserInputType.Touch
    end
    local function isPointerMovement(input3)
        return input3.UserInputType==Enum.UserInputType.MouseMovement or input3.UserInputType==Enum.UserInputType.Touch
    end
    local function createIcon(parent5,icon4,tint2,position2)
        local frame3=createInstance("Frame",{AnchorPoint=Vector2.new(0,.5),Position=position2,Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,Parent=parent5})
        local imageLabel2=createInstance("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageColor3=tint2,ScaleType=Enum.ScaleType.Fit,Parent=frame3})
        applyIcon(imageLabel2,icon4)
        return frame3,imageLabel2
    end
    local function measureText(configuration6,argument6,argument7)
        local frame4=createInstance("Frame",{AnchorPoint=Vector2.new(argument6,.5),Position=UDim2.new(argument6,argument7,.5,0),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Parent=configuration6})
        local entries4={}
        local imageLabel3=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=nativeTheme2.Muted,ScaleType=Enum.ScaleType.Fit,Parent=frame4})
        applyIcon(imageLabel3,"chevron-down")
        if imageLabel3.Image~=""then
            function entries4:Set(configuration7)
                animate(imageLabel3,{Rotation=configuration7 and 180 or 0,ImageColor3=configuration7 and nativeTheme2.Accent or nativeTheme2.Muted},.3,Enum.EasingStyle.Quint)
            end
            return entries4
        end
        imageLabel3:Destroy()
        local function callback4(configuration8,argument8)
            return createLabel{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(18,18),Text="›",TextSize=22,TextXAlignment=Enum.TextXAlignment.Center,TextColor3=nativeTheme2.Muted,TextTransparency=argument8,Rotation=configuration8,Parent=frame4}
        end
        local value21=callback4(90,0)
        local value22=callback4(270,1)
        function entries4:Set(configuration9)
            animate(value21,{TextTransparency=configuration9 and 1 or 0},.2)
            animate(value22,{TextTransparency=configuration9 and 0 or 1,TextColor3=configuration9 and nativeTheme2.Accent or nativeTheme2.Muted},.2)
        end
        return entries4
    end
    local textMeasurements={}
    local function wrapText(configuration10)
        local pointerPosition=getPointerPosition()
        local value23=math.max(configuration10.AbsoluteSize.X,configuration10.AbsoluteSize.Y)*2.2
        local value24=table.remove(textMeasurements)
        if not value24 then
            value24=createInstance("Frame",{AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0})
            addCorner(value24,UDim.new(1,0))
        end
        value24.Position=UDim2.fromOffset(pointerPosition.X-configuration10.AbsolutePosition.X,pointerPosition.Y-configuration10.AbsolutePosition.Y)
        value24.Size=UDim2.fromOffset(0,0)
        value24.BackgroundTransparency=.82
        value24.ZIndex=configuration10.ZIndex+1
        value24.Parent=configuration10
        animate(value24,{Size=UDim2.fromOffset(value23,value23),BackgroundTransparency=1},.55)
        task.delay(.55,function()
            value24.Parent=nil
            if#textMeasurements<4 then
                table.insert(textMeasurements,value24)
            else
                value24:Destroy()
            end
        end)
    end
    local function addCardGradient(configuration11)
        if not configuration11 then
            return
        end
        animate(configuration11,{Color=nativeTheme2.Accent,Transparency=.2},.08)
        task.delay(.12,function()
            animate(configuration11,{Color=nativeTheme2.Stroke,Transparency=0},.35)
        end)
    end
    local function decorateCard(configuration12,argument9)
        configuration12.MouseEnter:Connect(function()
            animate(argument9,{Color=nativeTheme2.StrokeHover},.12)
        end)
        configuration12.MouseLeave:Connect(function()
            animate(argument9,{Color=nativeTheme2.Stroke},.25)
        end)
    end
    local keyNames={[Enum.KeyCode.LeftControl]="LCtrl",[Enum.KeyCode.RightControl]="RCtrl",[Enum.KeyCode.LeftShift]="LShift",[Enum.KeyCode.RightShift]="RShift",[Enum.KeyCode.LeftAlt]="LAlt",[Enum.KeyCode.RightAlt]="RAlt",[Enum.KeyCode.Return]="Enter",[Enum.KeyCode.Escape]="Esc",[Enum.KeyCode.Backspace]="Backspace"}
    local function formatKeyName(keyCode2)
        if keyCode2==nil then
            return"None"
        end
        return keyNames[keyCode2]or keyCode2.Name
    end
    local function invokeCallback(callback5,...)
        if type(callback5)~="function"then
            return
        end
        local success4,result3=pcall(callback5,...)
        if not success4 then
        end
    end
    local function createRangeAdapter(configuration13,argument10,argument11)
        local count=0
        local value25=tostring(argument11)
        local value26=value25:find"%."
        if value26 then
            count=#value25-value26
        end
        local value27="%."..count.."f"
        return{snap=function(configuration14)
            configuration14=math.floor(configuration14/argument11+.5)*argument11
            return math.clamp(configuration14,configuration13,argument10)
        end,format=function(configuration15)
            return string.format(value27,configuration15)
        end}
    end
    local function createCard(configuration16,argument12,argument13,argument14)
        local entries5={Size=UDim2.new(1,0,0,argument13),BackgroundColor3=nativeTheme2.Surface2,BorderSizePixel=0,LayoutOrder=configuration16:_nextOrder(),Parent=configuration16.List}
        if argument12=="TextButton"then
            entries5.AutoButtonColor=false
            entries5.Text=""
        end
        local value28=createInstance(argument12,entries5)
        value28:SetAttribute("NoDrag",true)
        addCorner(value28)
        local stroke2=addStroke(value28,nativeTheme2.Stroke)
        return value28,stroke2
    end
    local function createCardLabels(configuration17,argument15,argument16,argument17)
        local value29,value30
        if argument16 then
            local value31=(descriptionCardHeight-38)/2
            value29=createLabel{Position=UDim2.fromOffset(14,value31),Size=UDim2.new(1,-(14+argument17),0,18),Text=argument15,Parent=configuration17}
            value30=createLabel{Position=UDim2.fromOffset(14,value31+20),Size=UDim2.new(1,-(14+argument17),0,17),Text=argument16,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=configuration17}
        else
            value29=createLabel{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-(14+argument17),1,0),Text=argument15,Parent=configuration17}
        end
        return value29,value30
    end
    local function offsetColor(configuration18,argument18,argument19,argument20,argument21,argument22)
        argument18=normalizeOptions2(argument18,argument19)
        local value32=argument18.Desc and descriptionCardHeight or cardHeight
        local cardFrame,cardStroke=createCard(configuration18,argument20 or"Frame",value32,argument18)
        decorateCard(cardFrame,cardStroke)
        local value33,value34
        if argument21 then
            value33,value34=createCardLabels(cardFrame,argument18.Name or argument22,argument18.Desc,argument21)
        end
        return argument18,cardFrame,cardStroke,value32,value33,value34
    end
    local function blendColor(configuration19,argument23,argument24)
        if configuration19 then
            configuration19.Size=UDim2.new(1,-(14+argument24),configuration19.Size.Y.Scale,configuration19.Size.Y.Offset)
        end
        if argument23 then
            argument23.Size=UDim2.new(1,-(14+argument24),0,argument23.Size.Y.Offset)
        end
    end
    local NativeTab={}
    NativeTab.__index=NativeTab
    function NativeTab:_nextOrder()
        self._order+=1
        return self._order
    end
    function NativeTab:Section(configuration20)
        if type(configuration20)=="table"then
            configuration20=configuration20.Name or configuration20.Title or""
        end
        local frame5=createInstance("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List})
        local textLabel=createLabel{Position=UDim2.fromOffset(2,8),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=uppercasePortuguese(configuration20),TextSize=12,TextColor3=nativeTheme2.Muted,TextTruncate=Enum.TextTruncate.None,Parent=frame5}
        local frame6=createInstance("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,0,16),Size=UDim2.new(1,-12,0,1),BackgroundColor3=nativeTheme2.Stroke,BorderSizePixel=0,Parent=frame5})
        textLabel:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
            frame6.Size=UDim2.new(1,-(textLabel.AbsoluteSize.X+14),0,1)
        end)
        task.defer(function()
            frame6.Size=UDim2.new(1,-(textLabel.AbsoluteSize.X+14),0,1)
        end)
        return registerElement(self,{},{Set=function(configuration21,argument25)
            textLabel.Text=uppercasePortuguese(argument25)
        end},frame5,"Section")
    end
    function NativeTab:Divider()
        local frame7=createInstance("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=nativeTheme2.Stroke,BorderSizePixel=0,LayoutOrder=self:_nextOrder(),Parent=self.List})
        return registerElement(self,{},{},frame7,"Divider")
    end
    function NativeTab:Label(configuration22)
        configuration22=normalizeOptions2(configuration22,{Name="Text",Title="Text"})
        local textLabel2=createLabel{Size=UDim2.new(1,0,0,18),Text=configuration22.Text or"",TextSize=13,FontFace=nativeFonts.Regular,TextColor3=configuration22.Color or nativeTheme2.Muted,LayoutOrder=self:_nextOrder(),Parent=self.List}
        addPadding(textLabel2,2)
        local entries6={Set=function(configuration23,argument26)
            textLabel2.Text=tostring(argument26)
        end,Get=function()
            return textLabel2.Text
        end}
        if type(configuration22.Update)=="function"then
            local value35,enabled3=math.max(tonumber(configuration22.UpdateRate)or 1,.05),true
            entries6._listeners=entries6._listeners or{}
            table.insert(entries6._listeners,function()
                enabled3=false
            end)
            task.spawn(function()
                while enabled3 and textLabel2.Parent do
                    local success5,result4=pcall(configuration22.Update)
                    if success5 and result4~=nil then
                        textLabel2.Text=tostring(result4)
                    elseif not success5 then
                    end
                    task.wait(value35)
                end
            end)
            function entries6:SetUpdateRate(configuration24)
                value35=math.max(tonumber(configuration24)or value35,.05)
            end
        end
        return registerElement(self,configuration22,entries6,textLabel2,"Label")
    end
    function NativeTab:Paragraph(configuration25)
        configuration25=normalizeOptions2(configuration25,{Title="Name"})
        local cardFrame2=createCard(self,"Frame",0,configuration25)
        cardFrame2.AutomaticSize=Enum.AutomaticSize.Y
        addPadding(cardFrame2,14,14,11,12)
        createInstance("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=cardFrame2})
        createLabel{Size=UDim2.new(1,0,0,14),Text=configuration25.Name or"",LayoutOrder=1,Parent=cardFrame2}
        local textLabel3=createLabel{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=configuration25.Content or"",TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=cardFrame2}
        return registerElement(self,configuration25,{Set=function(configuration26,argument27)
            textLabel3.Text=argument27
        end},cardFrame2,"Paragraph")
    end
    function NativeTab:Button(config)
        config = normalizeOptions2(config, { Title = "Name", Description = "Desc" })
        local primary = config.Style == "Primary"
        local section = config.Style == "Section"
        local frame, stroke = createCard(self, "TextButton", config.Desc and descriptionCardHeight or cardHeight, config)
        frame.ClipsDescendants = true
        frame:SetAttribute("UIRole", section and "SectionHeader" or "ActionButton")
        local hovered = false
        local leading
        if config.Icon then
            local holder
            holder, leading = createIcon(frame, config.Icon, nativeTheme2.Text, UDim2.new(0, section and 0 or 14, .5, 0))
        end
        local title, description = createCardLabels(frame, config.Name or "Button", config.Desc, section and 36 or 56)
        if section then
            title.FontFace = nativeFonts.Bold
            title.TextSize = 16
            local inset = config.Icon and 26 or 0
            title.Position = UDim2.fromOffset(inset, title.Position.Y.Offset)
            title.Size = UDim2.new(1, -inset - 36, title.Size.Y.Scale, title.Size.Y.Offset)
            if description then
                description.Position = UDim2.fromOffset(inset, description.Position.Y.Offset)
                description.Size = UDim2.new(1, -inset - 36, 0, description.Size.Y.Offset)
            end
        elseif leading then
            title.Position += UDim2.fromOffset(26, 0)
            title.Size -= UDim2.fromOffset(26, 0)
            if description then
                description.Position += UDim2.fromOffset(26, 0)
                description.Size -= UDim2.fromOffset(26, 0)
            end
        end
        local indicator, arrow
        if section then
            local holder
            holder, arrow = createIcon(frame, "chevron-right", nativeTheme2.Muted, UDim2.new(1, -24, .5, 0))
        else
            indicator = createInstance("Frame", {
            Name = "ActionIndicator", AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -12, .5, 0), Size = UDim2.fromOffset(isTouchDevice and 32 or 28, isTouchDevice and 32 or 28),
            BorderSizePixel = 0, Parent = frame,
        })
            addCorner(indicator, UDim.new(0, 8))
            local holder
            holder, arrow = createIcon(indicator, "arrow-up-right", nativeTheme2.AccentDark, UDim2.new(.5, -8, .5, 0))
        end
        local control = {}
        function control:RefreshStyle(animated)
            local monochrome = NativeLibrary.ThemeName == "Mono"
            local accentedPrimary = primary and not monochrome
            local fill = config.Color or (accentedPrimary and nativeTheme2.Accent or nativeTheme2.Surface3)
            local edge = accentedPrimary and nativeTheme2.Accent or nativeTheme2.StrokeHover:Lerp(nativeTheme2.Surface3, .75)
            if hovered and not section then
                fill = fill:Lerp(accentedPrimary and nativeTheme2.Text or nativeTheme2.Accent, .06)
                edge = nativeTheme2.StrokeHover
            end
            local frameProperties = { BackgroundColor3 = fill, BackgroundTransparency = section and 1 or 0 }
            local strokeProperties = { Color = edge, Transparency = section and 1 or 0 }
            if animated then
                animate(frame, frameProperties, .12)
                animate(stroke, strokeProperties, .12)
            else
                for property, value in pairs(frameProperties) do
                    frame[property] = value
                end
                for property, value in pairs(strokeProperties) do
                    stroke[property] = value
                end
            end
            local foreground = accentedPrimary and nativeTheme2.AccentDark or (config.Danger and nativeTheme2.Error or nativeTheme2.Text)
            title.TextColor3 = foreground
            if description then
                description.TextColor3 = accentedPrimary and nativeTheme2.AccentDark:Lerp(nativeTheme2.Accent, .28) or nativeTheme2.Muted
            end
            if leading then
                leading.ImageColor3 = foreground
            end
            if indicator then
                indicator.BackgroundColor3 = monochrome and nativeTheme2.Surface2 or (primary and nativeTheme2.AccentDark or nativeTheme2.Accent)
                arrow.ImageColor3 = monochrome and nativeTheme2.Text or (primary and nativeTheme2.Accent or nativeTheme2.AccentDark)
            else
                arrow.ImageColor3 = hovered and nativeTheme2.Text or nativeTheme2.Muted
            end
        end
        function control:SetText(text)
            title.Text = text
        end
        control:RefreshStyle()
        frame.MouseEnter:Connect(function()
            hovered = true;
            control:RefreshStyle(true)
        end)
        frame.MouseLeave:Connect(function()
            hovered = false;
            control:RefreshStyle(true)
        end)
        frame.MouseButton1Click:Connect(function()
            if not section then
                wrapText(frame)
            end
            invokeCallback(config.Callback)
        end)
        return registerElement(self, config, control, frame, "Button")
    end
    function NativeTab:Toggle(configuration27)
        local value36,value37
        configuration27,value36,value37=offsetColor(self,configuration27,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"},"TextButton",56,"Toggle")
        local frame8=createInstance("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=isTouchDevice and UDim2.fromOffset(44,24)or UDim2.fromOffset(36,20),BackgroundColor3=nativeTheme2.Surface3,BorderSizePixel=0,Parent=value36})
        addCorner(frame8,UDim.new(1,0))
        addStroke(frame8,nativeTheme2.Stroke)
        local frame9=createInstance("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,3,.5,0),Size=isTouchDevice and UDim2.fromOffset(18,18)or UDim2.fromOffset(14,14),BackgroundColor3=nativeTheme2.Muted,BorderSizePixel=0,Parent=frame8})
        addCorner(frame9,UDim.new(1,0))
        local imageLabel4=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,24,1,24),BackgroundTransparency=1,Image=nativeAssets.Glow,ImageColor3=nativeTheme2.Accent,ImageTransparency=1,ZIndex=0,Parent=frame8})
        local entries7={Value=configuration27.Default==true}
        local function callback6(configuration28)
            local value38=entries7.Value
            local value39=configuration28 and.25 or 0
            animate(frame8,{BackgroundColor3=value38 and nativeTheme2.Accent or nativeTheme2.Surface3},value39)
            animate(imageLabel4,{ImageTransparency=value38 and.75 or 1},value39)
            local value40=isTouchDevice and 18 or 14
            animate(frame9,{Position=value38 and UDim2.new(0,(isTouchDevice and 44 or 36)-3-value40,.5,0)or UDim2.new(0,3,.5,0),BackgroundColor3=value38 and nativeTheme2.AccentDark or nativeTheme2.Muted},value39,Enum.EasingStyle.Back)
            if configuration28 then
                animate(frame9,{Size=UDim2.fromOffset(value40+4,value40-2)},.08)
                task.delay(.08,function()
                    animate(frame9,{Size=UDim2.fromOffset(value40,value40)},.2,Enum.EasingStyle.Back)
                end)
            end
        end
        local enabled4=false
        function entries7:Set(configuration29,argument28)
            configuration29=configuration29==true
            if configuration29==entries7.Value then
                return
            end
            entries7.Value=configuration29
            callback6(true)
            if not enabled4 then
                addCardGradient(value37)
            end
            if not argument28 then
                invokeCallback(configuration27.Callback,configuration29)
            end
        end
        function entries7:Get()
            return entries7.Value
        end
        callback6(false)
        value36.MouseButton1Click:Connect(function()
            enabled4=true
            entries7:Set(not entries7.Value)
            enabled4=false
        end)
        local value41=registerElement(self,configuration27,entries7,value36,"Toggle")
        if entries7.Value then
            invokeCallback(configuration27.Callback,true)
        end
        return value41
    end
    function NativeTab:Slider(configuration30)
        local text3="Frame"
        configuration30=normalizeOptions2(configuration30,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"})
        local value42=configuration30.Min or 0
        local value43=configuration30.Max or 100
        local value44=configuration30.Step or 1
        local value45=configuration30.Suffix or""
        local value46=createRangeAdapter(value42,value43,value44)
        local cardFrame3,cardStroke2=createCard(self,text3,descriptionCardHeight,configuration30)
        decorateCard(cardFrame3,cardStroke2)
        local sliderTitle=createLabel{Position=UDim2.fromOffset(14,12),Size=UDim2.new(1,-120,0,18),Text=configuration30.Name or"Slider",Parent=cardFrame3}
        local value47=createInstance(text3,{Name="ValueField",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,0,21),Size=UDim2.fromOffset(56,28),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,ClipsDescendants=true,Parent=cardFrame3})
        addCorner(value47,UDim.new(0,6))
        local stroke3=addStroke(value47)
        local textLabel4=createLabel{Name="Value",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,-20,1,0),TextSize=13,TextColor3=nativeTheme2.Accent,TextYAlignment=Enum.TextYAlignment.Center,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=value47}
        local textBox=createInstance("TextBox",{Name="ValueInput",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,-20,1,0),AutomaticSize=Enum.AutomaticSize.None,BackgroundTransparency=1,Text="",TextColor3=nativeTheme2.Text,TextSize=13,FontFace=nativeFonts.Medium,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,ClearTextOnFocus=false,Visible=false,Parent=value47})
        createInstance("UISizeConstraint",{MinSize=Vector2.new(14,0),Parent=textBox})
        local textLabel5=createLabel{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=value45,TextSize=13,TextColor3=nativeTheme2.Accent,TextTruncate=Enum.TextTruncate.None,Visible=false,Parent=value47}
        local textButton,enabled5=createInstance("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=2,Parent=value47}),false
        local function callback7()
            local scale=math.max(math.min(self.Window.Scale.Scale,1),.01)
            local suffixWidth=enabled5 and textLabel5.TextBounds.X/scale or 0
            local textWidth=(enabled5 and textBox.TextBounds.X or textLabel4.TextBounds.X)/scale
            local width=math.max(56,math.ceil(textWidth+suffixWidth+20))
            value47.Size=UDim2.fromOffset(width,28)
            textBox.Position=UDim2.new(.5,-suffixWidth/2,.5,0)
            textBox.Size=UDim2.new(1,-20-suffixWidth,1,0)
            textLabel5.AnchorPoint=Vector2.new(1,.5)
            textLabel5.Position=UDim2.new(1,-10,.5,0)
            sliderTitle.Size=UDim2.new(1,-width-sliderTitle.Position.X.Offset-28,0,18)
        end
        textLabel4:GetPropertyChangedSignal"TextBounds":Connect(function()
            if not enabled5 then
                callback7(false)
            end
        end)
        textBox:GetPropertyChangedSignal"TextBounds":Connect(function()
            if enabled5 then
                callback7()
            end
        end)
        local valueScaleConnection=self.Window.Scale:GetPropertyChangedSignal"Scale":Connect(callback7)
        local value48=createInstance(text3,{Position=UDim2.new(0,14,0,descriptionCardHeight-18),Size=UDim2.new(1,-28,0,5),BackgroundColor3=nativeTheme2.Surface3,BorderSizePixel=0,Parent=cardFrame3})
        addCorner(value48,UDim.new(1,0))
        local value49=createInstance(text3,{Size=UDim2.new(0,0,1,0),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0,Parent=value48})
        addCorner(value49,UDim.new(1,0))
        local imageLabel5=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,Image=nativeAssets.Glow,ImageColor3=nativeTheme2.Accent,ImageTransparency=.85,ZIndex=2,Parent=value48})
        local value50=createInstance(text3,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0,ZIndex=3,Parent=value48})
        addCorner(value50,UDim.new(1,0))
        local textButton2=createInstance("TextButton",{Position=UDim2.new(0,8,0,descriptionCardHeight-(isTouchDevice and 37 or 31)),Size=UDim2.new(1,-16,0,isTouchDevice and 40 or 28),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=cardFrame3})
        local entries8,enabled6={Value=math.clamp(configuration30.Default or value42,value42,value43)},false
        textButton.MouseEnter:Connect(function()
            animate(stroke3,{Color=nativeTheme2.StrokeHover},.12)
        end)
        textButton.MouseLeave:Connect(function()
            if not textBox:IsFocused()then
                animate(stroke3,{Color=nativeTheme2.Stroke},.2)
            end
        end)
        textButton.MouseButton1Click:Connect(function()
            enabled5=true
            textBox.Text=value46.format(entries8.Value)
            textLabel4.Visible=false
            textBox.Visible=true
            textLabel5.Visible=value45~=""
            textButton.Visible=false
            animate(stroke3,{Color=nativeTheme2.StrokeHover},.12)
            textBox:CaptureFocus()
            task.defer(callback7,false)
        end)
        textBox.FocusLost:Connect(function()
            local value51=tonumber(textBox.Text)
            enabled5=false
            textBox.Visible=false
            textLabel5.Visible=false
            textLabel4.Visible=true
            textButton.Visible=true
            animate(stroke3,{Color=nativeTheme2.Stroke},.2)
            if value51 then
                entries8:Set(value51)
            end
            callback7(false)
        end)
        textButton2.MouseEnter:Connect(function()
            if not enabled6 then
                animate(imageLabel5,{ImageTransparency=.78,Size=UDim2.fromOffset(34,34)},.15)
            end
        end)
        textButton2.MouseLeave:Connect(function()
            if not enabled6 then
                animate(imageLabel5,{ImageTransparency=.85,Size=UDim2.fromOffset(28,28)},.2)
            end
        end)
        local snap=value46.snap
        local function callback8()
            return value43-value42==0 and 0 or(entries8.Value-value42)/(value43-value42)
        end
        local function callback9(configuration31,argument29,argument30)
            argument30=argument30 or Enum.EasingStyle.Linear
            animate(value49,{Size=UDim2.new(configuration31,0,1,0)},argument29,argument30)
            animate(value50,{Position=UDim2.new(configuration31,0,.5,0)},argument29,argument30)
            animate(imageLabel5,{Position=UDim2.new(configuration31,0,.5,0)},argument29,argument30)
        end
        local function callback10(configuration32,argument31)
            callback9(callback8(),configuration32,argument31)
            textLabel4.Text=value46.format(entries8.Value)..value45
        end
        local function callback11(configuration33)
            local value52=callback8()
            local value53=math.max(value48.AbsoluteSize.X,1)
            local value54=(value52>=configuration33 and 1 or-1)*(5/value53)
            callback9(math.clamp(value52+value54,0,1),.22,Enum.EasingStyle.Quint)
            task.delay(.22,function()
                if not enabled6 then
                    callback9(callback8(),.18,Enum.EasingStyle.Quint)
                end
            end)
            textLabel4.Text=value46.format(entries8.Value)..value45
        end
        local function callback12()
            animate(value50,{Size=UDim2.fromOffset(14,12)},.08)
            animate(imageLabel5,{Size=UDim2.fromOffset(32,32),ImageTransparency=.78},.12)
            task.delay(.1,function()
                animate(value50,{Size=UDim2.fromOffset(12,12)},.25,Enum.EasingStyle.Quint)
                animate(imageLabel5,{Size=UDim2.fromOffset(28,28),ImageTransparency=.85},.25)
            end)
        end
        function entries8:Set(configuration34,argument32)
            configuration34=snap(tonumber(configuration34)or value42)
            if configuration34==entries8.Value then
                return
            end
            local value55=callback8()
            entries8.Value=configuration34
            if enabled6 then
                callback10(.05)
            else
                callback11(value55)
                callback12()
                addCardGradient(cardStroke2)
            end
            if not argument32 then
                invokeCallback(configuration30.Callback,configuration34)
            end
        end
        function entries8:Get()
            return entries8.Value
        end
        local function callback13(configuration35)
            local value56=math.clamp((configuration35-value48.AbsolutePosition.X)/value48.AbsoluteSize.X,0,1)
            entries8:Set(value42+(value43-value42)*value56)
        end
        textButton2.InputBegan:Connect(function(configuration36)
            if isPrimaryInput(configuration36)then
                enabled6=true
                animate(value50,{Size=UDim2.fromOffset(16,16)},.15,Enum.EasingStyle.Back)
                animate(imageLabel5,{Size=UDim2.fromOffset(44,44),ImageTransparency=.7},.15)
                callback13(getPointerPosition().X)
            end
        end)
        self.Window:_listen("Changed",function(configuration37)
            if enabled6 and isPointerMovement(configuration37)then
                callback13(getPointerPosition().X)
            end
        end,entries8)
        self.Window:_listen("Ended",function(configuration38)
            if enabled6 and isPrimaryInput(configuration38)then
                enabled6=false
                animate(value50,{Size=UDim2.fromOffset(12,12)},.2)
                animate(imageLabel5,{Size=UDim2.fromOffset(28,28),ImageTransparency=.85},.2)
            end
        end,entries8)
        entries8.Value=snap(entries8.Value)
        callback10(0)
        task.defer(callback7,true)
        table.insert(entries8._listeners,function()
            valueScaleConnection:Disconnect()
        end)
        entries8.TitleLabel=sliderTitle
        entries8.ValueLabel=textLabel4
        entries8.ValueInput=textBox
        return registerElement(self,configuration30,entries8,cardFrame3,"Slider")
    end
    function NativeTab:Dropdown(configuration39)
        local text4="Frame"
        configuration39=normalizeOptions2(configuration39,{Title="Name",Description="Desc",CurrentOption="Default",Value="Default",MultipleOptions="Multi",Values="Options"})
        if configuration39.Multi and type(configuration39.Default)~="table"and configuration39.Default~=nil then
            configuration39.Default={configuration39.Default}
        elseif not configuration39.Multi and type(configuration39.Default)=="table"then
            configuration39.Default=configuration39.Default[1]
        end
        local value57=configuration39.Multi==true
        local value58=configuration39.Options or{}
        local value59,value60,value61
        configuration39,value59,value60,value61=offsetColor(self,configuration39,{},text4)
        value59.ClipsDescendants=true
        local textButton3=createInstance("TextButton",{Size=UDim2.new(1,0,0,value61),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=value59})
        local titleLabel,descriptionLabel=createCardLabels(textButton3,configuration39.Name or"Dropdown",configuration39.Desc,180)
        local value62=createInstance(text4,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(60,chipHeight),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,ClipsDescendants=true,Parent=textButton3})
        addCorner(value62,UDim.new(0,6))
        local stroke4=addStroke(value62)
        local textLabel6=createLabel{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-34,1,0),TextColor3=nativeTheme2.Muted,TextSize=13,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=value62}
        local value63=measureText(value62,1,-6)
        local textLabel7,text5=createLabel{Size=UDim2.fromOffset(0,chipHeight),AutomaticSize=Enum.AutomaticSize.X,TextSize=13,Visible=false,Parent=value62},""
        local function callback14()
            textLabel7.Text=text5
            if textLabel7.TextBounds.X<=146 then
                return text5
            end
            local value64=text5
            while#value64>1 do
                value64=value64:sub(1,-2)
                textLabel7.Text=value64..".."
                if textLabel7.TextBounds.X<=146 then
                    return value64..".."
                end
            end
            return".."
        end
        local function callback15(configuration40)
            local value65=math.clamp(textLabel6.TextBounds.X+10+34,60,190)
            blendColor(titleLabel,descriptionLabel,value65+20)
            if configuration40 then
                value62.Size=UDim2.fromOffset(value65,chipHeight)
            else
                animate(value62,{Size=UDim2.fromOffset(value65,chipHeight)},.2)
            end
        end
        textLabel6:GetPropertyChangedSignal"TextBounds":Connect(function()
            callback15(false)
        end)
        local value66=createInstance(text4,{Position=UDim2.new(0,10,0,value61),Size=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Parent=value59})
        createInstance("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=value66})
        local entries9={Open=false}
        local entries10={}
        local entries11,text6={},""
        local value67=configuration39.SearchAfter or 6
        local value68=createInstance(text4,{Size=UDim2.new(1,0,0,dropdownOptionHeight),BackgroundColor3=nativeTheme2.Surface,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=0,Visible=false,Parent=value66})
        addCorner(value68,UDim.new(0,6))
        local stroke5=addStroke(value68,nativeTheme2.Stroke,1)
        local textBox2=createInstance("TextBox",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text="",PlaceholderText="Search",PlaceholderColor3=nativeTheme2.Muted,TextColor3=nativeTheme2.Text,TextSize=13,FontFace=nativeFonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,TextTransparency=1,Parent=value68})
        local function callback16(configuration41)
            return text6==""or string.find(string.lower(tostring(configuration41)),text6,1,true)~=nil
        end
        if value57 then
            for index10,entry10 in ipairs(configuration39.Default or{})do
                entries10[entry10]=true
            end
        elseif configuration39.Default~=nil then
            entries10[configuration39.Default]=true
        end
        local function callback17()
            if value57 then
                local entries12={}
                for index11,entry11 in ipairs(value58)do
                    if entries10[entry11]then
                        table.insert(entries12,entry11)
                    end
                end
                return entries12
            end
            for index12,entry12 in ipairs(value58)do
                if entries10[entry12]then
                    return entry12
                end
            end
            return nil
        end
        local function callback18()
            local value69=callback17()
            if value57 then
                text5=#value69>0 and table.concat(value69,", ")or"None"
            else
                text5=value69~=nil and tostring(value69)or"None"
            end
            textLabel6.Text=callback14()
            for index13,entry13 in pairs(entries11)do
                local value70=entries10[index13]==true
                if entry13.On~=value70 then
                    entry13.On=value70
                    animate(entry13.Label,{TextColor3=value70 and nativeTheme2.Text or nativeTheme2.Muted},.15)
                    if entries9.Open then
                        animate(entry13.Check,{ImageTransparency=value70 and 0 or 1},.15)
                        animate(entry13.CheckScale,{Scale=value70 and 1 or.6},value70 and.3 or.15,value70 and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
                    end
                end
            end
        end
        local function callback19()
            local count2=0
            for index14,entry14 in ipairs(value58)do
                if callback16(entry14)then
                    count2+=1
                end
            end
            return count2
        end
        local function callback20()
            for index15,entry15 in pairs(entries11)do
                entry15.Frame.Visible=callback16(index15)
            end
        end
        local function callback21()
            local height=value61+8+(value68.Visible and dropdownOptionHeight+4 or 0)
            for _,label in ipairs(value58)do
                if callback16(label)then
                    local row=entries11[label]
                    height+=(row and row.Frame.Size.Y.Offset or dropdownOptionHeight)+4
                end
            end
            return height
        end
        local function callback22(configuration42)
            entries9.Open=configuration42
            value68.Visible=#value58>value67
            if not configuration42 then
                text6=""
                textBox2.Text=""
                callback20()
            end
            animate(value59,{Size=UDim2.new(1,0,0,configuration42 and callback21()or value61)},.3,Enum.EasingStyle.Quint)
            animate(value68,{BackgroundTransparency=configuration42 and 0 or 1},.2)
            animate(stroke5,{Transparency=configuration42 and 0 or 1},.2)
            animate(textBox2,{TextTransparency=configuration42 and 0 or 1},.2)
            value63:Set(configuration42)
            animate(stroke4,{Color=configuration42 and nativeTheme2.StrokeHover or nativeTheme2.Stroke},.2)
            local function callback23(configuration43)
                if not configuration43.Stroke then
                    configuration43.Stroke=addStroke(configuration43.Frame,nativeTheme2.Stroke,1)
                end
                local value71=configuration42 and configuration43.On
                animate(configuration43.Check,{ImageTransparency=value71 and 0 or 1},.18)
                configuration43.CheckScale.Scale=value71 and 1 or.6
                animate(configuration43.Label,{TextTransparency=configuration42 and 0 or 1},.18)
                animate(configuration43.Stroke,{Transparency=configuration42 and 0 or 1},.18)
                animate(configuration43.Frame,{BackgroundTransparency=configuration42 and 0 or 1},.18)
            end
            if configuration42 then
                local value72=(entries9._openGeneration or 0)+1
                entries9._openGeneration=value72
                task.spawn(function()
                    local enabled7=true
                    for index16,entry16 in ipairs(value58)do
                        local value73=entries11[entry16]
                        if value73 and value73.Frame.Visible then
                            if not enabled7 then
                                task.wait(.025)
                                if entries9._openGeneration~=value72 or not entries9.Open then
                                    return
                                end
                            end
                            enabled7=false
                            callback23(value73)
                        end
                    end
                end)
            else
                local value74=(entries9._openGeneration or 0)+1
                entries9._openGeneration=value74
                local entries13={}
                for index17,entry17 in ipairs(value58)do
                    local value75=entries11[entry17]
                    if value75 and value75.Frame.Visible then
                        table.insert(entries13,value75)
                    end
                end
                task.spawn(function()
                    for index18=#entries13,1,-1 do
                        callback23(entries13[index18])
                        if index18>1 then
                            task.wait(.015)
                            if entries9._openGeneration~=value74 or entries9.Open then
                                return
                            end
                        end
                    end
                end)
            end
        end
        local function callback24()
            local entries14={}
            for index19,entry18 in ipairs(value58)do
                entries14[entry18]=index19
            end
            for index20,entry19 in pairs(entries11)do
                if not entries14[index20]then
                    entry19.Frame:Destroy()
                    entries11[index20]=nil
                end
            end
            for index21,entry20 in ipairs(value58)do
                local value76=entries11[entry20]
                if value76 then
                    value76.Frame.LayoutOrder=index21
                    continue
                end
                local textButton4=createInstance("TextButton",{Size=UDim2.new(1,0,0,dropdownOptionHeight),BackgroundColor3=nativeTheme2.Surface,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=index21,Parent=value66})
                addCorner(textButton4,UDim.new(0,6))
                local imageLabel6=createInstance("ImageLabel",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=nativeTheme2.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=textButton4})
                applyIcon(imageLabel6,"check")
                local value77=createInstance("UIScale",{Scale=.6,Parent=imageLabel6})
                local textLabel8=createLabel{Position=UDim2.fromOffset(12,-1),Size=UDim2.new(1,-36,1,0),Text=tostring(entry20),TextSize=13,TextColor3=nativeTheme2.Muted,TextTransparency=1,Parent=textButton4}
                textButton4.MouseEnter:Connect(function()
                    animate(textLabel8,{TextColor3=nativeTheme2.Text},.15)
                    local value78=entries11[entry20]
                    if value78 and value78.Stroke then
                        animate(value78.Stroke,{Color=nativeTheme2.StrokeHover},.12)
                    end
                end)
                textButton4.MouseLeave:Connect(function()
                    animate(textLabel8,{TextColor3=entries10[entry20]and nativeTheme2.Text or nativeTheme2.Muted},.2)
                    local value79=entries11[entry20]
                    if value79 and value79.Stroke then
                        animate(value79.Stroke,{Color=nativeTheme2.Stroke},.2)
                    end
                end)
                textButton4.MouseButton1Click:Connect(function()
                    if entries10[entry20]then
                        entries10[entry20]=nil
                    else
                        if not value57 then
                            entries10={}
                        end
                        entries10[entry20]=true
                    end
                    callback18()
                    invokeCallback(configuration39.Callback,callback17())
                    if not value57 and entries10[entry20]then
                        callback22(false)
                    end
                end)
                entries11[entry20]={Frame=textButton4,Label=textLabel8,Check=imageLabel6,CheckScale=value77,Stroke=nil,On=nil}
            end
            callback20()
            if entries9.Open then
                value59.Size=UDim2.new(1,0,0,callback21())
            end
        end
        function entries9:Set(configuration44,argument33)
            entries10={}
            if value57 then
                for index22,entry21 in ipairs(type(configuration44)=="table"and configuration44 or{configuration44})do
                    entries10[entry21]=true
                end
            elseif configuration44~=nil then
                entries10[configuration44]=true
            end
            callback18()
            addCardGradient(value60)
            if not argument33 then
                invokeCallback(configuration39.Callback,callback17())
            end
        end
        function entries9:Get()
            return callback17()
        end
        function entries9:Refresh(configuration45,argument34)
            value58=configuration45 or{}
            if not argument34 then
                entries10={}
            end
            callback24()
            callback18()
            if entries9.Open then
                callback22(true)
            end
        end
        function entries9:SetOpen(configuration46)
            callback22(configuration46==true)
        end
        textButton3.MouseButton1Click:Connect(function()
            callback22(not entries9.Open)
        end)
        textBox2:GetPropertyChangedSignal"Text":Connect(function()
            text6=string.lower(textBox2.Text)
            callback20()
            if entries9.Open then
                animate(value59,{Size=UDim2.new(1,0,0,callback21())},.2,Enum.EasingStyle.Quint)
            end
        end)
        callback24()
        callback18()
        task.defer(callback15,true)
        entries9.UIOptionRows=entries11
        entries9.UIReflow=function()
            if entries9.Open then
                value59.Size=UDim2.new(1,0,0,callback21())
            end
        end
        return registerElement(self,configuration39,entries9,value59,"Dropdown")
    end
    function NativeTab:Input(configuration47)
        local value80,value81,value82,value83,value84
        configuration47,value80,value81,value82,value83,value84=offsetColor(self,configuration47,{Title="Name",Description="Desc",PlaceholderText="Placeholder",CurrentValue="Default",Value="Default"},"Frame",160,"Input")
        local frame10=createInstance("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(170,30),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value80})
        addCorner(frame10,UDim.new(0,6))
        local stroke6=addStroke(frame10)
        local icon5=configuration47.Icon
        if icon5 then
            createIcon(frame10,icon5,nativeTheme2.Muted,UDim2.new(0,8,.5,0))
        end
        local textBox3=createInstance("TextBox",{Name="ValueInput",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,icon5 and 11 or 0,.5,0),Size=UDim2.new(1,icon5 and-38 or-16,1,0),TextYAlignment=Enum.TextYAlignment.Center,BackgroundTransparency=1,Text=configuration47.Default or"",PlaceholderText=configuration47.Placeholder or"",PlaceholderColor3=nativeTheme2.Muted,TextColor3=nativeTheme2.Text,TextSize=14,FontFace=nativeFonts.Regular,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=frame10})
        frame10.ClipsDescendants=true
        local enabled8=false
        local value85=(icon5 and 30 or 8)+8
        local function callback25(configuration48)
            if value80:GetAttribute("UIMultiline") then
                return
            end
            local value86=value80.AbsoluteSize.X/self.Window.Scale.Scale
            local value87=math.clamp(value86-14-110-20,100,200)
            local text7=textBox3.Text
            local x=textBox3.TextBounds.X
            if#text7==0 then
                x=math.min(textBox3.TextBounds.X,90)
            end
            local value88=math.clamp(x+value85+12,90,value87)+(enabled8 and 8 or 0)
            value88=math.min(value88,value87+8)
            blendColor(value83,value84,value88+20)
            frame10.Size=UDim2.fromOffset(value88,30)
        end
        value80:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
            callback25(true)
        end)
        textBox3:GetPropertyChangedSignal"Text":Connect(function()
            callback25(false)
        end)
        textBox3:GetPropertyChangedSignal"TextBounds":Connect(function()
            callback25(false)
        end)
        task.defer(callback25,true)
        textBox3.Focused:Connect(function()
            enabled8=true
            animate(stroke6,{Color=nativeTheme2.StrokeHover},.15)
            callback25(false)
        end)
        textBox3.FocusLost:Connect(function(configuration49)
            enabled8=false
            animate(stroke6,{Color=nativeTheme2.Stroke},.15)
            callback25(false)
            if configuration47.Numeric then
                local value89=tonumber(textBox3.Text)
                if not value89 then
                    textBox3.Text=""
                    return
                end
            end
            invokeCallback(configuration47.Callback,textBox3.Text,configuration49)
        end)
        local control=registerElement(self,configuration47,{Set=function(configuration50,argument35)
            textBox3.Text=tostring(argument35)
            addCardGradient(value81)
        end,Get=function()
            return textBox3.Text
        end},value80,"Input")
        control.TitleLabel=value83
        control.DescriptionLabel=value84
        control.ValueInput=textBox3
        return control
    end
    function NativeTab:Keybind(configuration51)
        local value90,value91,value92,value93,value94
        configuration51,value90,value91,value92,value93,value94=offsetColor(self,configuration51,{Title="Name",Description="Desc",CurrentKeybind="Default",Value="Default"},"Frame",110,"Keybind")
        if type(configuration51.Default)=="string"then
            configuration51.Default=Enum.KeyCode[configuration51.Default]
        end
        local textButton5=createInstance("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(44,chipHeight),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=value90})
        addCorner(textButton5,UDim.new(0,6))
        local stroke7=addStroke(textButton5)
        local textLabel9=createLabel{Size=UDim2.new(1,0,1,0),TextSize=13,TextColor3=nativeTheme2.Muted,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=textButton5}
        local entries15={Value=configuration51.Default,Listening=false}
        local function callback26(configuration52)
            local value95=math.max(textLabel9.TextBounds.X+20,isTouchDevice and 44 or 36)
            blendColor(value93,value94,value95+20)
            if configuration52 then
                textButton5.Size=UDim2.fromOffset(value95,chipHeight)
            else
                animate(textButton5,{Size=UDim2.fromOffset(value95,chipHeight)},.2)
            end
        end
        textLabel9:GetPropertyChangedSignal"TextBounds":Connect(function()
            callback26(false)
        end)
        local function callback27()
            textLabel9.Text=entries15.Listening and"..."or formatKeyName(entries15.Value)
            animate(stroke7,{Color=entries15.Listening and nativeTheme2.StrokeHover or nativeTheme2.Stroke},.15)
            animate(textLabel9,{TextColor3=entries15.Listening and nativeTheme2.Accent or nativeTheme2.Muted},.15)
        end
        function entries15:Set(configuration53,argument36)
            local listening=entries15.Listening
            entries15.Value=configuration53
            entries15.Listening=false
            callback27()
            if not listening then
                addCardGradient(value91)
            end
            if not argument36 then
                invokeCallback(configuration51.OnChanged,configuration53)
            end
        end
        textButton5.MouseButton1Click:Connect(function()
            entries15.Listening=not entries15.Listening
            callback27()
        end)
        self.Window:_listen("Began",function(configuration54,argument37)
            if configuration54.UserInputType~=Enum.UserInputType.Keyboard then
                return
            end
            if entries15.Listening then
                self.Window._consumedKey=configuration54.KeyCode
                self.Window._consumedAt=os.clock()
                if configuration54.KeyCode==Enum.KeyCode.Escape then
                    entries15.Listening=false
                    callback27()
                else
                    entries15:Set(configuration54.KeyCode)
                end
                return
            end
            if not argument37 and entries15.Value~=nil and configuration54.KeyCode==entries15.Value then
                invokeCallback(configuration51.Callback,configuration54.KeyCode)
            end
        end,entries15)
        callback27()
        task.defer(callback26,true)
        function entries15:Get()
            return entries15.Value
        end
        return registerElement(self,configuration51,entries15,value90,"Keybind")
    end
    function NativeTab:ColorPicker(configuration55)
        local text8,text9,text10,text11="Default","Frame","TextButton","UIGradient"
        local value96,value97,value98
        configuration55,value96,value97,value98=offsetColor(self,configuration55,{Title="Name",Description="Desc",Color=text8,CurrentValue=text8,Value=text8},text9)
        value96.ClipsDescendants=true
        local value99=createInstance(text10,{Size=UDim2.new(1,0,0,value98),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=value96})
        createCardLabels(value99,configuration55.Name or"Color",configuration55.Desc,90)
        local value100=createInstance(text9,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-34,.5,0),Size=UDim2.fromOffset(36,20),BorderSizePixel=0,Parent=value99})
        addCorner(value100,UDim.new(0,6))
        addStroke(value100,nativeTheme2.Stroke)
        local value101=measureText(value99,1,-12)
        local value102=createInstance(text9,{Position=UDim2.fromOffset(14,value98+2),Size=UDim2.new(1,-28,0,156),BackgroundTransparency=1,Visible=false,Parent=value96})
        local value103=createInstance(text10,{Size=UDim2.new(1,-30,0,110),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=value102})
        addCorner(value103,UDim.new(0,6))
        local value104=createInstance(text11,{Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,0,0)),Parent=value103})
        local value105=createInstance(text9,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=value103})
        createInstance(text11,{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90,Parent=value105})
        local value106=createInstance(text9,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,ZIndex=3,Parent=value103})
        addCorner(value106,UDim.new(1,0))
        addStroke(value106,Color3.new(1,1,1),0,2)
        local value107=createInstance(text10,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(14,110),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=value102})
        addCorner(value107,UDim.new(0,6))
        createInstance(text11,{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.16666666666666666,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(.3333333333333333,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(.6666666666666666,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(.8333333333333334,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))},Rotation=90,Parent=value107})
        local value108=createInstance(text9,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(18,5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=3,Parent=value107})
        addCorner(value108,UDim.new(1,0))
        addStroke(value108,nativeTheme2.AccentDark,.4)
        local value109=createInstance(text9,{Position=UDim2.fromOffset(6,122),Size=UDim2.fromOffset(118,28),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value102})
        addCorner(value109,UDim.new(0,6))
        local stroke8=addStroke(value109)
        local textBox4=createInstance("TextBox",{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text="",TextTruncate=Enum.TextTruncate.None,ClipsDescendants=false,TextColor3=nativeTheme2.Text,TextSize=13,FontFace=nativeFonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=value109})
        local textLabel10=createLabel{Position=UDim2.fromOffset(134,122),Size=UDim2.new(1,-134,0,28),TextXAlignment=Enum.TextXAlignment.Right,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=value102}
        local entries16={Open=false}
        local value110,value111,value112=Color3.toHSV(configuration55.Default or nativeTheme2.Accent)
        local value113
        local function callback28(configuration56)
            return string.format("#%02X%02X%02X",math.floor(configuration56.R*255+.5),math.floor(configuration56.G*255+.5),math.floor(configuration56.B*255+.5))
        end
        local function callback29(configuration57)
            local value114=Color3.fromHSV(value110,value111,value112)
            entries16.Value=value114
            value100.BackgroundColor3=value114
            value104.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(value110,1,1))
            animate(value106,{Position=UDim2.fromScale(value111,1-value112)},configuration57,Enum.EasingStyle.Linear)
            animate(value108,{Position=UDim2.new(.5,0,value110,0)},configuration57,Enum.EasingStyle.Linear)
            if not textBox4:IsFocused()then
                textBox4.Text=callback28(value114)
            end
            textLabel10.Text=string.format("RGB %d, %d, %d",math.floor(value114.R*255+.5),math.floor(value114.G*255+.5),math.floor(value114.B*255+.5))
        end
        local function callback30(configuration58,argument38)
            callback29(configuration58)
            if not argument38 then
                invokeCallback(configuration55.Callback,entries16.Value)
            end
        end
        function entries16:Set(configuration59,argument39)
            value110,value111,value112=Color3.toHSV(configuration59)
            callback30(.25,argument39)
            addCardGradient(value97)
        end
        function entries16:Get()
            return entries16.Value
        end
        local function callback31(configuration60)
            entries16.Open=configuration60
            animate(value96,{Size=UDim2.new(1,0,0,configuration60 and value98+168 or value98)},.35,Enum.EasingStyle.Quint)
            value101:Set(configuration60)
            if configuration60 then
                value102.Visible=true
            else
                task.delay(.35,function()
                    if not entries16.Open then
                        value102.Visible=false
                    end
                end)
            end
        end
        function entries16:SetOpen(configuration61)
            callback31(configuration61==true)
        end
        value99.MouseButton1Click:Connect(function()
            callback31(not entries16.Open)
        end)
        local function callback32(configuration62)
            value111=math.clamp((configuration62.X-value103.AbsolutePosition.X)/value103.AbsoluteSize.X,0,1)
            value112=1-math.clamp((configuration62.Y-value103.AbsolutePosition.Y)/value103.AbsoluteSize.Y,0,1)
            callback30(.04)
        end
        local function callback33(configuration63)
            value110=math.clamp((configuration63.Y-value107.AbsolutePosition.Y)/value107.AbsoluteSize.Y,0,.999)
            callback30(.04)
        end
        value103.InputBegan:Connect(function(configuration64)
            if isPrimaryInput(configuration64)then
                value113="sv"
                animate(value106,{Size=UDim2.fromOffset(14,14)},.15,Enum.EasingStyle.Back)
                callback32(getPointerPosition())
            end
        end)
        value107.InputBegan:Connect(function(configuration65)
            if isPrimaryInput(configuration65)then
                value113="hue"
                animate(value108,{Size=UDim2.fromOffset(20,7)},.15,Enum.EasingStyle.Back)
                callback33(getPointerPosition())
            end
        end)
        self.Window:_listen("Changed",function(configuration66)
            if not value113 or not isPointerMovement(configuration66)then
                return
            end
            local pointerPosition2=getPointerPosition()
            if value113=="sv"then
                callback32(pointerPosition2)
            else
                callback33(pointerPosition2)
            end
        end,entries16)
        self.Window:_listen("Ended",function(configuration67)
            if value113 and isPrimaryInput(configuration67)then
                value113=nil
                animate(value106,{Size=UDim2.fromOffset(10,10)},.2)
                animate(value108,{Size=UDim2.fromOffset(18,5)},.2)
            end
        end,entries16)
        textBox4.Focused:Connect(function()
            animate(stroke8,{Color=nativeTheme2.StrokeHover},.15)
        end)
        textBox4.FocusLost:Connect(function()
            animate(stroke8,{Color=nativeTheme2.Stroke},.15)
            local value115,value116,value117=textBox4.Text:match"^%s*#?(%x%x)(%x%x)(%x%x)%s*$"
            if value115 then
                entries16:Set(Color3.fromRGB(tonumber(value115,16),tonumber(value116,16),tonumber(value117,16)))
            else
                textBox4.Text=callback28(entries16.Value)
            end
        end)
        callback29(0)
        return registerElement(self,configuration55,entries16,value96,"ColorPicker")
    end
    function NativeTab:Stepper(configuration68)
        local value118,value119,value120,value121,value122
        configuration68,value118,value119,value120,value121,value122=offsetColor(self,configuration68,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"},"Frame",150,"Stepper")
        local value123=configuration68.Min or 0
        local value124=configuration68.Max or 100
        local value125=configuration68.Step or 1
        local value126=configuration68.Suffix or""
        local value127=createRangeAdapter(value123,value124,value125)
        local frame11=createInstance("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(0,chipHeight),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value118})
        addCorner(frame11,UDim.new(0,6))
        local stroke9=addStroke(frame11)
        createInstance("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=frame11})
        local function callback34(configuration69,argument40)
            local textButton6=createInstance("TextButton",{Size=UDim2.fromOffset(chipHeight,chipHeight),BackgroundTransparency=1,Text=configuration69,TextColor3=nativeTheme2.Muted,TextSize=18,FontFace=nativeFonts.Medium,AutoButtonColor=false,LayoutOrder=argument40,Parent=frame11})
            textButton6.MouseEnter:Connect(function()
                animate(textButton6,{TextColor3=nativeTheme2.Accent},.12)
            end)
            textButton6.MouseLeave:Connect(function()
                animate(textButton6,{TextColor3=nativeTheme2.Muted},.2)
            end)
            return textButton6
        end
        local value128=callback34("−",1)
        local textLabel11=createLabel{Size=UDim2.new(0,30,1,0),TextSize=13,TextColor3=nativeTheme2.Accent,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,LayoutOrder=2,Parent=frame11}
        local value129=callback34("+",3)
        local function callback35(configuration70)
            local value130=math.max(textLabel11.TextBounds.X+12,30)
            if configuration70 then
                textLabel11.Size=UDim2.new(0,value130,1,0)
            else
                animate(textLabel11,{Size=UDim2.new(0,value130,1,0)},.2)
            end
        end
        textLabel11:GetPropertyChangedSignal"TextBounds":Connect(function()
            callback35(false)
        end)
        frame11:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
            blendColor(value121,value122,frame11.AbsoluteSize.X/self.Window.Scale.Scale+20)
        end)
        local entries17={Value=math.clamp(configuration68.Default or value123,value123,value124)}
        local snap2,enabled9=value127.snap,false
        local function callback36()
            textLabel11.Text=value127.format(entries17.Value)..value126
            animate(value128,{TextTransparency=entries17.Value<=value123 and.6 or 0},.15)
            animate(value129,{TextTransparency=entries17.Value>=value124 and.6 or 0},.15)
        end
        function entries17:Set(configuration71,argument41)
            configuration71=snap2(tonumber(configuration71)or value123)
            if configuration71==entries17.Value then
                return
            end
            entries17.Value=configuration71
            callback36()
            if not enabled9 then
                addCardGradient(value119)
            end
            if not argument41 then
                invokeCallback(configuration68.Callback,configuration71)
            end
        end
        function entries17:Get()
            return entries17.Value
        end
        local function callback37(configuration72)
            enabled9=true
            entries17:Set(entries17.Value+configuration72*value125)
            enabled9=false
            animate(stroke9,{Color=nativeTheme2.StrokeHover},.08)
            task.delay(.12,function()
                animate(stroke9,{Color=nativeTheme2.Stroke},.2)
            end)
        end
        local function callback38(configuration73,argument42)
            local enabled10=false
            configuration73.InputBegan:Connect(function(configuration74)
                if not isPrimaryInput(configuration74)then
                    return
                end
                enabled10=true
                callback37(argument42)
                task.delay(.4,function()
                    while enabled10 do
                        callback37(argument42)
                        task.wait(.07)
                    end
                end)
            end)
            configuration73.InputEnded:Connect(function(configuration75)
                if isPrimaryInput(configuration75)then
                    enabled10=false
                end
            end)
            configuration73.MouseLeave:Connect(function()
                enabled10=false
            end)
        end
        callback38(value128,-1)
        callback38(value129,1)
        callback36()
        task.defer(callback35,true)
        return registerElement(self,configuration68,entries17,value118,"Stepper")
    end
    function NativeTab:Progress(configuration76)
        configuration76=normalizeOptions2(configuration76,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"})
        local cardFrame4,cardStroke3=createCard(self,"Frame",configuration76.Desc and descriptionCardHeight+10 or cardHeight+10,configuration76)
        decorateCard(cardFrame4,cardStroke3)
        local value131=configuration76.Desc and(descriptionCardHeight-38)/2-2 or 12
        createLabel{Position=UDim2.fromOffset(14,value131),Size=UDim2.new(1,-110,0,18),Text=configuration76.Name or"Progress",Parent=cardFrame4}
        if configuration76.Desc then
            createLabel{Position=UDim2.fromOffset(14,value131+20),Size=UDim2.new(1,-110,0,17),Text=configuration76.Desc,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=cardFrame4}
        end
        local textLabel12=createLabel{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,value131),Size=UDim2.fromOffset(90,18),TextXAlignment=Enum.TextXAlignment.Right,TextSize=13,TextColor3=nativeTheme2.Accent,Parent=cardFrame4}
        local frame12=createInstance("Frame",{Position=UDim2.new(0,14,1,-16),Size=UDim2.new(1,-28,0,5),BackgroundColor3=nativeTheme2.Surface3,BorderSizePixel=0,Parent=cardFrame4})
        addCorner(frame12,UDim.new(1,0))
        local frame13=createInstance("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=configuration76.Color or nativeTheme2.Accent,BorderSizePixel=0,Parent=frame12})
        addCorner(frame13,UDim.new(1,0))
        local entries18={Value=math.clamp(configuration76.Default or 0,0,1)}
        local format=configuration76.Format
        local function callback39(configuration77)
            local value132=entries18.Value
            animate(frame13,{Size=UDim2.new(value132,0,1,0)},configuration77,Enum.EasingStyle.Quint)
            if type(format)=="function"then
                textLabel12.Text=tostring(format(value132))
            else
                textLabel12.Text=string.format("%d%%",math.floor(value132*100+.5))
            end
        end
        function entries18:Set(configuration78,argument43)
            configuration78=math.clamp(tonumber(configuration78)or 0,0,1)
            if configuration78==entries18.Value then
                return
            end
            entries18.Value=configuration78
            callback39(.35)
            if not argument43 then
                invokeCallback(configuration76.Callback,configuration78)
            end
        end
        function entries18:Get()
            return entries18.Value
        end
        function entries18:SetColor(configuration79)
            frame13.BackgroundColor3=configuration79
        end
        callback39(0)
        return registerElement(self,configuration76,entries18,cardFrame4,"Progress")
    end
    function NativeTab:ConfigManager(configuration80)
        configuration80=normalizeOptions2(configuration80,{})
        local window2=self.Window
        local entries19={}
        self:Section(configuration80.Name or"Configs")
        local value133=self:Input{Name="Config name",Placeholder=window2.ConfigName,Callback=function(configuration81,argument44)
            if argument44 and#configuration81>0 then
                entries19:Save(configuration81)
            end
        end}
        local value134=self:Dropdown{Name="Saved configs",Options=window2:ListConfigs(),Default=window2.ConfigName,Callback=function(configuration82)
            if configuration82 then
                value133:Set(configuration82)
            end
        end}
        function entries19:Refresh()
            value134:Refresh(window2:ListConfigs(),true)
        end
        function entries19:Save(configuration83)
            configuration83=configuration83 or value134:Get()or window2.ConfigName
            local value135,value136=window2:SaveConfig(configuration83)
            entries19:Refresh()
            value134:Set(configuration83,true)
            window2:Notify{Title=value135 and"Config saved"or"Save failed",Content=value135 and configuration83 or tostring(value136),Type=value135 and"Success"or"Error",Duration=3}
        end
        function entries19:Load(configuration84)
            configuration84=configuration84 or value134:Get()
            if not configuration84 then
                return
            end
            local value137,value138=window2:LoadConfig(configuration84)
            window2:Notify{Title=value137 and"Config loaded"or"Load failed",Content=value137 and configuration84 or tostring(value138),Type=value137 and"Success"or"Error",Duration=3}
        end
        function entries19:Delete(configuration85)
            configuration85=configuration85 or value134:Get()
            if not configuration85 then
                return
            end
            local value139,value140=window2:DeleteConfig(configuration85)
            entries19:Refresh()
            window2:Notify{Title=value139 and"Config deleted"or"Delete failed",Content=value139 and configuration85 or tostring(value140),Type=value139 and"Info"or"Error",Duration=3}
        end
        self:Button{Name="Save",Desc="Writes every flagged element to the selected name",Icon="save",Style="Primary",Callback=function()
            local value141=value133:Get()
            entries19:Save(#value141>0 and value141 or nil)
        end}
        self:Button{Name="Load",Icon="folder-open",Callback=function()
            entries19:Load()
        end}
        self:Button{Name="Delete",Icon="trash-2",Callback=function()
            local value142=value134:Get()
            if not value142 then
                return
            end
            window2:Confirm{Title="Delete config",Content="Remove "..value142.."? This cannot be undone.",Icon="trash-2",ConfirmText="Delete",Callback=function()
                entries19:Delete(value142)
            end}
        end}
        self:Toggle{Name="Auto save",Desc="Save whenever a flagged element changes",Default=window2._autoSaveEnabled,Callback=function(configuration86)
            window2._autoSaveEnabled=configuration86
        end}
        return entries19
    end
    for nativeTheme3,animate2 in pairs(table.clone(NativeTab))do
        if type(animate2)=="function"and nativeTheme3:sub(1,1)~="_"and nativeTheme3:sub(1,6)~="Create"then
            NativeTab["Create"..nativeTheme3]=animate2
        end
    end
    local function detectExecutor()
        local value143
        pcall(function()
            if typeof(identifyexecutor)=="function"then
                value143=(identifyexecutor())
            elseif typeof(getexecutorname)=="function"then
                value143=getexecutorname()
            end
        end)
        if type(value143)=="string"and#value143>0 then
            return value143
        end
        return RunService:IsStudio()and"Studio"or"Unknown"
    end
    local function detectGameName()
        local success6,result5=pcall(function()
            return Runtime.GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        if success6 and type(result5)=="table"and result5.Name then
            return result5.Name
        end
        return"Unknown game"
    end
    local notificationColors={Success=nativeTheme2.Success,Warning=nativeTheme2.Warning,Error=nativeTheme2.Error}
    local NativeWindow={}
    NativeWindow.__index=NativeWindow
    function NativeLibrary.Window(configuration87,argument45)
        local text12,text13,text14,text15,text16,text17="AirflowUI","Frame","CanvasGroup","UIListLayout","AbsoluteSize","table"
        argument45=normalizeOptions2(argument45,{Name="Title",LoadingSubtitle="Subtitle",ToggleUIKeybind="Keybind"})
        if type(argument45.Keybind)=="string"then
            argument45.Keybind=Enum.KeyCode[argument45.Keybind]
        end
        local value144=argument45.Size or UDim2.fromOffset(640,480)
        local value145=argument45.Keybind or Enum.KeyCode.RightControl
        local value146=setmetatable({Tabs={},CurrentTab=nil,Open=true,Keybind=value145,_connections={},_controls={},_inputListeners={Began={},Changed={},Ended={},Render={}},_frameSteps={},_destroyed=false},NativeWindow)
        local function callback40(configuration88)
            return function(...)
                for index23,entry22 in ipairs(value146._inputListeners[configuration88])do
                    entry22(...)
                end
            end
        end
        local value147=callback40"Render"
        table.insert(value146._connections,RunService.RenderStepped:Connect(function(configuration89)
            value147(configuration89)
            for index24,entry23 in ipairs(value146._frameSteps)do
                entry23(configuration89)
            end
        end))
        table.insert(value146._connections,UserInputService.InputBegan:Connect(callback40"Began"))
        table.insert(value146._connections,UserInputService.InputChanged:Connect(callback40"Changed"))
        table.insert(value146._connections,UserInputService.InputEnded:Connect(callback40"Ended"))
        local screenGui=createInstance("ScreenGui",{Name=argument45.Name or text12,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
        value146.Gui=screenGui
        local value148=createInstance(text13,{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=value144,BackgroundTransparency=1,Parent=screenGui})
        value146.Root=value148
        local value149=createInstance("UIScale",{Parent=value148})
        value146.Scale=value149
        local imageLabel7=createInstance("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=nativeAssets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=.6,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),Parent=value148})
        value146.Shadow=imageLabel7
        local value150=createInstance(text14,{Name="Body",Size=UDim2.fromScale(1,1),BackgroundColor3=nativeTheme2.Background,BorderSizePixel=0,Parent=value148})
        value146.Body=value150
        addCorner(value150,UDim.new(0,16))
        value146.BodyStroke=addStroke(value150,nativeTheme2.Stroke)
        addEdgeHighlight(value150)
        addGlow(value150,UDim2.fromOffset(500,180),UDim2.new(.5,0,1,8),.86,270)
        addGlow(value150,UDim2.fromOffset(130,60),UDim2.new(0,-10,1,-10),.75,90)
        addGlow(value150,UDim2.fromOffset(520,240),UDim2.new(1,-14,0,10),.92,90)
        local value151=createInstance(text13,{Name="Sidebar",Size=UDim2.new(0,170,1,0),BackgroundTransparency=1,Parent=value150})
        createInstance(text13,{Position=UDim2.new(0,170,0,28),Size=UDim2.new(0,1,1,-56),BackgroundColor3=nativeTheme2.Stroke,BorderSizePixel=0,Parent=value150})
        local value152=createInstance(text13,{Name="Header",Size=UDim2.new(1,0,0,72),BackgroundTransparency=1,Parent=value151})
        local imageLabel8=createInstance("ImageLabel",{Position=UDim2.fromOffset(22,27),Size=UDim2.fromOffset(30,28),BackgroundTransparency=1,Image="",ImageColor3=nativeTheme2.Accent,ScaleType=Enum.ScaleType.Fit,Parent=value152})
        applyIcon(imageLabel8,argument45.Icon or nativeAssets.Logo)
        createLabel{Position=UDim2.fromOffset(60,25),Size=UDim2.new(1,-70,0,20),Text=argument45.Title or"Airflow",TextSize=20,Parent=value152}
        createLabel{Position=UDim2.fromOffset(60,45),Size=UDim2.new(1,-70,0,14),Text=argument45.Subtitle or"",TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=value152}
        local scrollingFrame=createInstance("ScrollingFrame",{Name="Tabs",Position=UDim2.fromOffset(0,80),Size=UDim2.new(1,0,1,-116),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=value151})
        value146.TabList=scrollingFrame
        addPadding(scrollingFrame,16,16,4,4)
        createInstance(text15,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=scrollingFrame})
        local value153=createInstance(text13,{AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(3,18),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0,Visible=false,ZIndex=2,Parent=value151})
        addCorner(value153,UDim.new(1,0))
        value146.Indicator=value153
        local y=scrollingFrame.CanvasPosition.Y
        table.insert(value146._frameSteps,function()
            local y2=scrollingFrame.CanvasPosition.Y
            if y2==y or not value146.CurrentTab or not value146._introDone then
                return
            end
            y=y2
            local value154=value146:_indicatorY(value146.CurrentTab)
            local offset2=scrollingFrame.Position.Y.Offset
            local value155=offset2+scrollingFrame.AbsoluteSize.Y/value146.Scale.Scale
            value153.Visible=value154>offset2 and value154<value155
            value153.Position=UDim2.fromOffset(6,value154)
        end)
        local value156=createInstance(text13,{Name="KeybindFooter",Position=UDim2.new(0,22,1,-36),Size=UDim2.new(1,-44,0,22),BackgroundTransparency=1,Parent=value151})
        local value157=createInstance(text13,{Size=UDim2.fromOffset(0,22),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value156})
        addCorner(value157,UDim.new(0,5))
        addStroke(value157)
        addPadding(value157,7,7)
        local textLabel13=createLabel{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=formatKeyName(value145),TextSize=11,TextColor3=nativeTheme2.Muted,TextTruncate=Enum.TextTruncate.None,Parent=value157}
        value146._keyChipLabel=textLabel13
        local textLabel14=createLabel{Size=UDim2.new(1,0,1,0),Text="Abrir / minimizar",TextSize=12,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=value156}
        local function callback41()
            textLabel14.Position=UDim2.fromOffset(value157.AbsoluteSize.X/value146.Scale.Scale+8,0)
        end
        value157:GetPropertyChangedSignal(text16):Connect(callback41)
        task.defer(callback41)
        local value158=createInstance(text13,{Name="Content",Position=UDim2.fromOffset(171,0),Size=UDim2.new(1,-171,1,0),BackgroundTransparency=1,ClipsDescendants=true,Parent=value150})
        value146.Content=value158
        value146._outLayer=createInstance(text14,{Name="TransitionOut",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=2,Parent=value158})
        value146._inLayer=createInstance(text14,{Name="TransitionIn",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3,Parent=value158})
        local textButton7=createInstance("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=nativeTheme2.Surface2,BackgroundTransparency=1,Text="×",TextColor3=nativeTheme2.Muted,TextSize=28,FontFace=nativeFonts.Bold,AutoButtonColor=false,ZIndex=5,Parent=value158})
        addPadding(textButton7,0,0,1,0)
        addCorner(textButton7,UDim.new(0,8))
        textButton7.MouseEnter:Connect(function()
            animate(textButton7,{BackgroundTransparency=0,TextColor3=nativeTheme2.Text},.15)
        end)
        textButton7.MouseLeave:Connect(function()
            animate(textButton7,{BackgroundTransparency=1,TextColor3=nativeTheme2.Muted},.2)
        end)
        value146.CloseButton=textButton7
        textButton7.MouseButton1Click:Connect(function()
            if value146.RequestClose then
                value146:RequestClose()
            end
        end)
        local value159=createInstance(text13,{Name="Notifications",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),Size=UDim2.new(0,280,1,-40),BackgroundTransparency=1,Parent=screenGui})
        local function callback42()
            value159.Size=UDim2.new(0,math.min(280,screenGui.AbsoluteSize.X-40),1,-40)
        end
        table.insert(value146._connections,screenGui:GetPropertyChangedSignal(text16):Connect(callback42))
        createInstance(text15,{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,4),Parent=value159})
        value146.NotifyHolder=value159
        value146._notifyOrder=0
        value146._toasts={}
        value146.MaxNotifications=argument45.MaxNotifications or 4
        value146._controlsDirty=true
        table.insert(value146._connections,value150.DescendantAdded:Connect(function()
            value146._controlsDirty=true
        end))
        table.insert(value146._connections,value150.DescendantRemoving:Connect(function()
            value146._controlsDirty=true
        end))
        value146:_enableDrag()
        value146.MaxSize=argument45.MaxSize
        value146.KeepOnScreen=argument45.KeepOnScreen~=false
        value146:_enableResize(argument45.MinSize or Vector2.new(480,360))
        local configurationSaving=argument45.ConfigurationSaving
        if type(configurationSaving)==text17 and configurationSaving.Enabled~=false then
            value146.ConfigFolder=configurationSaving.FolderName or text12
            value146.ConfigName=configurationSaving.FileName or"default"
            value146._autoSaveEnabled=true
        else
            value146.ConfigFolder=text12
            value146.ConfigName="default"
            value146._autoSaveEnabled=false
        end
        table.insert(value146._connections,UserInputService.InputBegan:Connect(function(configuration90,argument46)
            if argument46 then
                return
            end
            if configuration90.UserInputType==Enum.UserInputType.Keyboard and configuration90.KeyCode==value146.Keybind then
                task.defer(function()
                    local value160=value146._consumedKey==configuration90.KeyCode and os.clock()-(value146._consumedAt or 0)<.2
                    value146._consumedKey=nil
                    if not value160 and not value146._destroyed then
                        value146:Toggle(not value146.Open)
                    end
                end)
            end
        end))
        pcall(function()
            if typeof(syn)=="table"and typeof(syn.protect_gui)=="function"then
                syn.protect_gui(screenGui)
            end
        end)
        screenGui.Parent=argument45.Parent or getInterfaceParent()
        value149.Scale=.9
        value150.GroupTransparency=1
        imageLabel7.ImageTransparency=1
        value146.BodyStroke.Transparency=1
        value148.Visible=false
        value146:_fitToScreen(true)
        table.insert(value146._connections,screenGui:GetPropertyChangedSignal(text16):Connect(function()
            value146:_fitToScreen()
            value146:_clampToScreen()
        end))
        if argument45.OpenButton~=nil and argument45.OpenButton~=false or argument45.OpenButton==nil and isTouchDevice then
            value146:_createOpenButton(type(argument45.OpenButton)==text17 and argument45.OpenButton or{})
        end
        value146._introDone=false
        table.insert(NativeLibrary.Windows,value146)
        if argument45.Home then
            value146:_buildHome(type(argument45.Home)==text17 and argument45.Home or{})
        end
        local loading=argument45.Loading
        if type(loading)==text17 then
            argument45.LoadingDuration=loading.Duration or argument45.LoadingDuration
            argument45.LoadingText=loading.Text or loading.Subtitle or argument45.LoadingText
            argument45.LoadingSteps=loading.Steps or argument45.LoadingSteps
            argument45.LoadingTitle=loading.Title or argument45.LoadingTitle
            loading=loading.Enabled~=false
        end
        if loading==false then
            task.defer(function()
                value146:_playIntro()
            end)
        else
            value146:_showLoader(argument45)
        end
        return value146
    end
    NativeLibrary.CreateWindow=NativeLibrary.Window
    function NativeLibrary:Notify(configuration91)
        local value161=NativeLibrary.Windows[#NativeLibrary.Windows]
        if value161 then
            return value161:Notify(configuration91)
        end
    end
    function NativeLibrary:Confirm(configuration92)
        local value162=NativeLibrary.Windows[#NativeLibrary.Windows]
        if value162 then
            return value162:Confirm(configuration92)
        end
    end
    function NativeLibrary:Dialog(configuration93)
        local value163=NativeLibrary.Windows[#NativeLibrary.Windows]
        if value163 then
            return value163:Dialog(configuration93)
        end
    end
    local function containsPoint(point,object3)
        local absolutePosition,absoluteSize=object3.AbsolutePosition,object3.AbsoluteSize
        return point.X>=absolutePosition.X and point.X<=absolutePosition.X+absoluteSize.X and point.Y>=absolutePosition.Y and point.Y<=absolutePosition.Y+absoluteSize.Y
    end
    local function isControlVisible(configuration94,argument47,argument48)
        local value164=configuration94
        while value164 and value164~=argument47 and value164:IsA"GuiObject"do
            if not value164.Visible then
                return false
            end
            local parent6=value164.Parent
            if parent6 and parent6~=argument47 and parent6:IsA"GuiObject"and(parent6.ClipsDescendants or parent6:IsA"ScrollingFrame")and not containsPoint(argument48,parent6)then
                return false
            end
            value164=parent6
        end
        return true
    end
    function NativeWindow:_refreshControls()
        local entries20={}
        for index25,entry24 in ipairs(self.Body:GetDescendants())do
            if entry24:IsA"GuiButton"or entry24:IsA"TextBox"or entry24:GetAttribute"NoDrag"then
                table.insert(entries20,entry24)
            end
        end
        self._controls=entries20
        self._controlsDirty=false
    end
    function NativeWindow:_overControl(configuration95)
        if self._dialog then
            return true
        end
        if self._controlsDirty then
            self:_refreshControls()
        end
        for index26,entry25 in ipairs(self._controls)do
            if entry25.Parent and containsPoint(configuration95,entry25)and isControlVisible(entry25,self.Body,configuration95)then
                return true
            end
        end
        return false
    end
    function NativeWindow:_enableDrag()
        local enabled11=false
        local zero=Vector2.zero
        local value165
        local function callback43()
            local root=self.Root
            return root.AbsolutePosition+root.AbsoluteSize*root.AnchorPoint-self.Gui.AbsolutePosition
        end
        table.insert(self._connections,UserInputService.InputBegan:Connect(function(configuration96)
            if not isPrimaryInput(configuration96)then
                return
            end
            if not self.Open or not self.Root.Visible then
                return
            end
            local pointerPosition3=getPointerPosition()
            if not containsPoint(pointerPosition3,self.Body)or self:_overControl(pointerPosition3)then
                return
            end
            enabled11=true
            zero=pointerPosition3-callback43()
        end))
        table.insert(self._connections,UserInputService.InputEnded:Connect(function(configuration97)
            if not enabled11 then
                return
            end
            if isPrimaryInput(configuration97)then
                enabled11,value165=false,nil
                self:_clampToScreen()
            end
        end))
        table.insert(self._frameSteps,function(configuration98)
            if not enabled11 then
                return
            end
            value165=getPointerPosition()-zero
            local value166=callback43()
            local value167=1-math.exp(-configuration98*45)
            local value168=value166:Lerp(value165,value167)
            self.Root.Position=UDim2.fromOffset(value168.X,value168.Y)
        end)
    end
    local function revealElement(configuration99,argument49,argument50)
        if not configuration99.Visible and not argument50 then
            return
        end
        configuration99.Visible=false
        task.delay(argument49,function()
            if not configuration99.Parent then
                return
            end
            local value169=createInstance("UIScale",{Scale=.94,Parent=configuration99})
            configuration99.Visible=true
            animate(value169,{Scale=1},.4,Enum.EasingStyle.Back)
            task.delay(.4,function()
                value169:Destroy()
            end)
        end)
    end
    function NativeWindow:_revealCards(configuration100,argument51)
        if configuration100._revealed then
            return
        end
        configuration100._revealed=true
        local count3=0
        for index27,entry26 in ipairs(configuration100.List:GetChildren())do
            if entry26:IsA"GuiObject"then
                revealElement(entry26,(argument51 or 0)+count3*.035)
                count3+=1
            end
        end
    end
    function NativeWindow:_playIntro(configuration101)
        if self._introDone then
            return
        end
        self._introDone=true
        task.delay(1,function()
            self._autoSaveReady=true
        end)
        local root2,body2,shadow,scale2=self.Root,self.Body,self.Shadow,self.Scale
        if self.CurrentTab then
            self:_revealCards(self.CurrentTab,configuration101 and.15 or.25)
        end
        root2.Visible=true
        if configuration101 then
            scale2.Scale=self._fitScale or 1
            root2.Position=UDim2.fromScale(.5,.5)
            animate(body2,{GroupTransparency=0},.3)
            animate(self.BodyStroke,{Transparency=0},.3)
            animate(shadow,{ImageTransparency=.6},.3)
        else
            root2.Position=UDim2.new(.5,0,.5,24)
            animate(scale2,{Scale=self._fitScale or 1},.5,Enum.EasingStyle.Back)
            animate(root2,{Position=UDim2.fromScale(.5,.5)},.5,Enum.EasingStyle.Quint)
            animate(body2,{GroupTransparency=0},.35)
            animate(self.BodyStroke,{Transparency=0},.35)
        end
        if not configuration101 then
            animate(shadow,{ImageTransparency=.6},.5)
        end
        for index28,entry27 in ipairs(self.Tabs)do
            revealElement(entry27._button,.1+index28*.05,true)
        end
        self.Indicator.Visible=false
        task.delay(.15+#self.Tabs*.05,function()
            if self.CurrentTab then
                self:_placeIndicator(self.CurrentTab)
            end
        end)
    end
    function NativeWindow:_showLoader(configuration102)
        local text18="Frame"
        local value170=configuration102.LoadingDuration or 1.6
        local gui=self.Gui
        local canvasGroup=createInstance("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,16),Size=UDim2.fromOffset(300,132),BackgroundColor3=nativeTheme2.Background,BorderSizePixel=0,GroupTransparency=1,ZIndex=10,Parent=gui})
        local corner=addCorner(canvasGroup,UDim.new(0,12))
        local stroke10=addStroke(canvasGroup,nativeTheme2.Stroke,1)
        addEdgeHighlight(canvasGroup)
        addGlow(canvasGroup,UDim2.fromOffset(320,140),UDim2.new(1,-20,0,-20),.85,90)
        addGlow(canvasGroup,UDim2.fromOffset(240,100),UDim2.new(0,10,1,10),.9,270)
        local value171=createInstance("UIScale",{Scale=.92,Parent=canvasGroup})
        local imageLabel9=createInstance("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=nativeAssets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=canvasGroup})
        local value172=createInstance(text18,{Position=UDim2.fromOffset(24,26),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Parent=canvasGroup})
        local imageLabel10=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.5,.5),Rotation=-14,BackgroundTransparency=1,ImageColor3=nativeTheme2.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=value172})
        applyIcon(imageLabel10,configuration102.Icon or nativeAssets.Logo)
        task.delay(.15,function()
            animate(imageLabel10,{Size=UDim2.fromScale(.85,.85),Rotation=0,ImageTransparency=0},.6,Enum.EasingStyle.Back)
        end)
        createLabel{Position=UDim2.fromOffset(78,30),Size=UDim2.new(1,-100,0,22),Text=configuration102.LoadingTitle or configuration102.Title or"Airflow",TextSize=20,Parent=canvasGroup}
        local textLabel15=createLabel{Position=UDim2.fromOffset(78,52),Size=UDim2.new(1,-100,0,16),Text=configuration102.LoadingText or configuration102.Subtitle or"Loading",TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=canvasGroup}
        local value173=createInstance(text18,{Position=UDim2.new(0,24,1,-30),Size=UDim2.new(1,-48,0,4),BackgroundColor3=nativeTheme2.Surface3,BorderSizePixel=0,ClipsDescendants=true,Parent=canvasGroup})
        addCorner(value173,UDim.new(1,0))
        local value174=createInstance(text18,{Size=UDim2.fromScale(0,1),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0,Parent=value173})
        addCorner(value174,UDim.new(1,0))
        local value175=createInstance(text18,{Position=UDim2.fromScale(-.4,0),Size=UDim2.fromScale(.4,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.6,BorderSizePixel=0,ZIndex=2,Parent=value173})
        createInstance("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)},Parent=value175})
        animate(canvasGroup,{GroupTransparency=0,Position=UDim2.fromScale(.5,.5)},.4,Enum.EasingStyle.Quint)
        animate(value171,{Scale=1},.5,Enum.EasingStyle.Back)
        animate(imageLabel9,{ImageTransparency=.6},.4)
        local value176=TweenService2:Create(value175,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1),{Position=UDim2.fromScale(1,0)})
        value176:Play()
        animate(value174,{Size=UDim2.fromScale(.85,1)},value170*.8,Enum.EasingStyle.Quart)
        task.spawn(loadLucideIcons)
        local value177=configuration102.LoadingSteps or{"Preparing interface","Loading icons","Almost there"}
        for index29,entry28 in ipairs(value177)do
            task.delay(value170*(index29-1)/#value177,function()
                if canvasGroup.Parent then
                    textLabel15.Text=entry28
                end
            end)
        end
        task.delay(value170,function()
            animate(value174,{Size=UDim2.fromScale(1,1)},.25,Enum.EasingStyle.Quint)
            task.delay(.25,function()
                value176:Cancel()
                for index30,entry29 in ipairs(canvasGroup:GetChildren())do
                    if entry29:IsA"TextLabel"then
                        animate(entry29,{TextTransparency=1},.15)
                    end
                end
                for index31,entry30 in ipairs(value172:GetChildren())do
                    animate(entry30,{ImageTransparency=1},.15)
                end
                animate(value173,{BackgroundTransparency=1},.15)
                animate(value174,{BackgroundTransparency=1},.15)
                animate(value175,{BackgroundTransparency=1},.1)
                local value178=self._fitScale or 1
                local size2=self.Root.Size
                animate(canvasGroup,{Size=UDim2.fromOffset(size2.X.Offset*value178,size2.Y.Offset*value178),Position=UDim2.fromScale(.5,.5)},.5,Enum.EasingStyle.Quint)
                animate(corner,{CornerRadius=UDim.new(0,10)},.5,Enum.EasingStyle.Quint)
                animate(value171,{Scale=1},.5,Enum.EasingStyle.Quint)
                task.delay(.28,function()
                    self:_playIntro(true)
                    animate(canvasGroup,{GroupTransparency=1},.25)
                    animate(stroke10,{Transparency=1},.2)
                    animate(imageLabel9,{ImageTransparency=1},.2)
                end)
                task.delay(.6,function()
                    canvasGroup:Destroy()
                end)
            end)
        end)
    end
    function NativeWindow:_fitToScreen(configuration103)
        local absoluteSize2=self.Gui.AbsoluteSize
        if absoluteSize2.X==0 or absoluteSize2.Y==0 then
            return
        end
        local size3=self.Root.Size
        local value179=math.min(1,(absoluteSize2.X-24)/math.max(size3.X.Offset,1),(absoluteSize2.Y-24)/math.max(size3.Y.Offset,1))
        self._fitScale=math.max(value179,.45)
        if self._introDone and self.Open then
            if configuration103 then
                self.Scale.Scale=self._fitScale
            else
                animate(self.Scale,{Scale=self._fitScale},.2)
            end
        end
    end
    function NativeWindow:_clampToScreen()
        if not self.KeepOnScreen then
            return
        end
        local absoluteSize3=self.Gui.AbsoluteSize
        local root3=self.Root
        local value180=root3.AbsoluteSize/2
        local value181=root3.AbsolutePosition+value180-self.Gui.AbsolutePosition
        local value182=Vector2.new(math.clamp(value181.X,math.min(value180.X,absoluteSize3.X/2),math.max(absoluteSize3.X-value180.X,absoluteSize3.X/2)),math.clamp(value181.Y,math.min(value180.Y,absoluteSize3.Y/2),math.max(absoluteSize3.Y-value180.Y,absoluteSize3.Y/2)))
        if(value182-value181).Magnitude>.5 then
            animate(root3,{Position=UDim2.fromOffset(value182.X,value182.Y)},.25,Enum.EasingStyle.Quint)
        end
    end
    function NativeWindow:_createOpenButton(configuration104)
        local gui2=self.Gui
        local textButton8=createInstance("TextButton",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,14),Size=UDim2.fromOffset(0,40),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=nativeTheme2.Background,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=30,Parent=gui2})
        addCorner(textButton8,UDim.new(1,0))
        addStroke(textButton8,nativeTheme2.Stroke)
        addPadding(textButton8,12,16)
        local imageLabel11=createInstance("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1,ImageColor3=nativeTheme2.Accent,ScaleType=Enum.ScaleType.Fit,ZIndex=31,Parent=textButton8})
        applyIcon(imageLabel11,configuration104.Icon or nativeAssets.Logo)
        createLabel{Position=UDim2.fromOffset(28,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=configuration104.Title or"Airflow",TextSize=13,TextTruncate=Enum.TextTruncate.None,ZIndex=31,Parent=textButton8}
        self.OpenButton=textButton8
        local enabled12,enabled13=false,false
        local zero2=Vector2.zero
        textButton8.InputBegan:Connect(function(configuration105)
            if isPrimaryInput(configuration105)then
                enabled12,enabled13=true,false
                zero2=getPointerPosition()-textButton8.AbsolutePosition
            end
        end)
        table.insert(self._connections,UserInputService.InputChanged:Connect(function(configuration106)
            if not enabled12 then
                return
            end
            if isPointerMovement(configuration106)then
                local value183=getPointerPosition()-zero2-gui2.AbsolutePosition
                if(value183-(textButton8.AbsolutePosition-gui2.AbsolutePosition)).Magnitude>3 then
                    enabled13=true
                end
                textButton8.AnchorPoint=Vector2.new(0,0)
                textButton8.Position=UDim2.fromOffset(math.clamp(value183.X,0,math.max(gui2.AbsoluteSize.X-textButton8.AbsoluteSize.X,0)),math.clamp(value183.Y,0,math.max(gui2.AbsoluteSize.Y-textButton8.AbsoluteSize.Y,0)))
            end
        end))
        table.insert(self._connections,UserInputService.InputEnded:Connect(function(configuration107)
            if enabled12 and isPrimaryInput(configuration107)then
                enabled12=false
                if not enabled13 then
                    self:Toggle()
                end
            end
        end))
    end
    function NativeWindow:_enableResize(configuration108)
        local value184=self.MaxSize or Vector2.new(math.huge,math.huge)
        local frame14=createInstance("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(1,4,1,4),Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,Active=true,ZIndex=20,Parent=self.Root})
        local imageLabel12,enabled14=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,-16,.5,-16),Size=UDim2.fromOffset(96,96),BackgroundTransparency=1,Image="rbxassetid://120997033468887",ImageColor3=nativeTheme2.Accent,ImageTransparency=.8,ZIndex=20,Parent=frame14}),false
        local size4=self.Root.Size
        local zero3=Vector2.zero
        local value185
        frame14.InputBegan:Connect(function(configuration109)
            if isPrimaryInput(configuration109)then
                enabled14=true
                size4=self.Root.Size
                zero3=getPointerPosition()
                animate(imageLabel12,{ImageTransparency=.35},.1)
            end
        end)
        frame14.MouseEnter:Connect(function()
            if not enabled14 then
                animate(imageLabel12,{ImageTransparency=.35},.1)
            end
        end)
        frame14.MouseLeave:Connect(function()
            if not enabled14 then
                animate(imageLabel12,{ImageTransparency=.8},.17)
            end
        end)
        table.insert(self._connections,UserInputService.InputEnded:Connect(function(configuration110)
            if enabled14 and isPrimaryInput(configuration110)then
                enabled14=false
                animate(imageLabel12,{ImageTransparency=.8},.17)
                if value185 then
                    self.Root.Size=UDim2.fromOffset(value185.X,value185.Y)
                    value185=nil
                end
                self:_fitToScreen()
                self:_clampToScreen()
            end
        end))
        table.insert(self._frameSteps,function(configuration111)
            if not enabled14 then
                return
            end
            local value186=(getPointerPosition()-zero3)/self.Scale.Scale
            value185=Vector2.new(math.clamp(size4.X.Offset+value186.X*2,configuration108.X,value184.X),math.clamp(size4.Y.Offset+value186.Y*2,configuration108.Y,value184.Y))
            local value187=Vector2.new(self.Root.Size.X.Offset,self.Root.Size.Y.Offset)
            local value188=1-math.exp(-configuration111*35)
            local value189=value187:Lerp(value185,value188)
            value189=Vector2.new(math.floor(value189.X+.5),math.floor(value189.Y+.5))
            if value189~=value187 then
                self.Root.Size=UDim2.fromOffset(value189.X,value189.Y)
            end
        end)
    end
    local function clampChannel(configuration112,argument52)
        return configuration112.ConfigFolder.."/"..argument52..".json"
    end
    local function roundChannel()
        local text19="function"
        return type(writefile)==text19 and type(readfile)==text19 and type(isfile)==text19
    end
    local function colorToHex(configuration113)
        if type(isfolder)=="function"and type(makefolder)=="function"and not isfolder(configuration113)then
            makefolder(configuration113)
        end
    end
    local function hexToColor(configuration114)
        local _type=configuration114._type
        local value190=configuration114:Get()
        if _type=="Keybind"then
            return{Type=_type,Value=value190 and value190.Name or nil}
        elseif _type=="ColorPicker"then
            return{Type=_type,Value={value190.R,value190.G,value190.B}}
        end
        return{Type=_type,Value=value190}
    end
    local function parseColor(configuration115,argument53,argument54)
        local _type2=configuration115._type
        local value191=argument53.Value
        if _type2=="Keybind"then
            configuration115:Set(value191 and Enum.KeyCode[value191]or nil,argument54)
        elseif _type2=="ColorPicker"then
            if type(value191)=="table"then
                configuration115:Set(Color3.new(value191[1],value191[2],value191[3]),argument54)
            end
        elseif value191~=nil then
            configuration115:Set(value191,argument54)
        end
    end
    function NativeWindow:SaveConfig(configuration116)
        configuration116=configuration116 or self.ConfigName
        if not roundChannel()then
            return false,"file API unavailable"
        end
        colorToHex(self.ConfigFolder)
        local entries21={}
        for index32,entry31 in pairs(NativeLibrary.Flags)do
            if entry31._type and type(entry31.Get)=="function"then
                entries21[index32]=hexToColor(entry31)
            end
        end
        local success7,result6=pcall(function()
            writefile(clampChannel(self,configuration116),HttpService:JSONEncode(entries21))
        end)
        if success7 then
            self.ConfigName=configuration116
        end
        return success7,result6
    end
    function NativeWindow:LoadConfig(configuration117,argument55)
        configuration117=configuration117 or self.ConfigName
        if not roundChannel()then
            return false,"file API unavailable"
        end
        local value192=clampChannel(self,configuration117)
        if not isfile(value192)then
            return false,"no config named "..configuration117
        end
        local success8,result7=pcall(function()
            return HttpService:JSONDecode(readfile(value192))
        end)
        if not success8 or type(result7)~="table"then
            return false,"config is not valid JSON"
        end
        local _autoSaveEnabled=self._autoSaveEnabled
        self._autoSaveEnabled=false
        for index33,entry32 in pairs(result7)do
            local value193=NativeLibrary.Flags[index33]
            if value193 and type(value193.Set)=="function"and type(entry32)=="table"and entry32.Type==value193._type then
                pcall(parseColor,value193,entry32,argument55==true)
            end
        end
        self._autoSaveEnabled=_autoSaveEnabled
        self._autoSaveReady=true
        self.ConfigName=configuration117
        return true
    end
    function NativeWindow:DeleteConfig(configuration118)
        if not roundChannel()or type(delfile)~="function"then
            return false,"file API unavailable"
        end
        local value194=clampChannel(self,configuration118)
        if not isfile(value194)then
            return false,"no config named "..configuration118
        end
        delfile(value194)
        return true
    end
    function NativeWindow:ListConfigs()
        local entries22={}
        if type(listfiles)~="function"or type(isfolder)~="function"or not isfolder(self.ConfigFolder)then
            return entries22
        end
        for index34,entry33 in ipairs(listfiles(self.ConfigFolder))do
            local value195=entry33:match"([^/\\]+)%.json$"
            if value195 then
                table.insert(entries22,value195)
            end
        end
        table.sort(entries22)
        return entries22
    end
    function NativeWindow:_autoSave()
        if not self._autoSaveEnabled or self._destroyed or not self._autoSaveReady then
            return
        end
        if self._autoSavePending then
            return
        end
        self._autoSavePending=true
        task.delay(.5,function()
            self._autoSavePending=false
            if not self._destroyed then
                self:SaveConfig(self.ConfigName)
            end
        end)
    end
    local function createEmptyPage(configuration119,argument56,argument57)
        local frame15=createInstance("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,-10),Size=UDim2.fromOffset(200,70),BackgroundTransparency=1,Parent=configuration119})
        local imageLabel13=createInstance("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,ImageColor3=nativeTheme2.Muted,ImageTransparency=.15,ScaleType=Enum.ScaleType.Fit,Parent=frame15})
        applyIcon(imageLabel13,argument56)
        local textLabel16=createLabel{Position=UDim2.fromOffset(0,36),Size=UDim2.new(1,0,0,16),Text=argument57,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextXAlignment=Enum.TextXAlignment.Center,Parent=frame15}
        return frame15,textLabel16,imageLabel13
    end
    local function createStatisticCard(grid,order2,icon6,title2)
        local frame16=createInstance("Frame",{Size=UDim2.new(.5,-4,0,62),BackgroundColor3=nativeTheme2.Surface2,BorderSizePixel=0,LayoutOrder=order2,Parent=grid})
        addCorner(frame16)
        addStroke(frame16)
        frame16:SetAttribute("NoDrag",true)
        if icon6 then
            createIcon(frame16,icon6,nativeTheme2.Muted,UDim2.new(0,14,0,21))
        end
        createLabel{Position=UDim2.fromOffset(icon6 and 36 or 14,12),Size=UDim2.new(1,-(icon6 and 50 or 28),0,16),Text=title2,TextSize=12,TextColor3=nativeTheme2.Muted,Parent=frame16}
        return createLabel{Position=UDim2.fromOffset(14,34),Size=UDim2.new(1,-28,0,18),Text="…",TextSize=15,Parent=frame16}
    end
    local function revealHomeContent(configuration120)
        local entries23={}
        local function callback44(configuration121)
            for index35,entry34 in ipairs(configuration121:GetChildren())do
                if entry34:IsA"TextLabel"or entry34:IsA"TextButton"or entry34:IsA"TextBox"then
                    table.insert(entries23,{entry34,"TextTransparency",entry34.TextTransparency})
                elseif entry34:IsA"ImageLabel"or entry34:IsA"ImageButton"then
                    table.insert(entries23,{entry34,"ImageTransparency",entry34.ImageTransparency})
                elseif entry34:IsA"UIStroke"then
                    table.insert(entries23,{entry34,"Transparency",entry34.Transparency})
                elseif entry34:IsA"Frame"then
                    table.insert(entries23,{entry34,"BackgroundTransparency",entry34.BackgroundTransparency})
                end
                callback44(entry34)
            end
        end
        if configuration120:IsA"Frame"then
            table.insert(entries23,{configuration120,"BackgroundTransparency",configuration120.BackgroundTransparency})
        end
        callback44(configuration120)
        for index36,entry35 in ipairs(entries23)do
            entry35[1][entry35[2]]=1
            animate(entry35[1],{[entry35[2]]=entry35[3]},.28)
        end
    end
    local function revealPage(configuration122,argument58)
        argument58=argument58 or 0
        configuration122.GroupTransparency=1
        configuration122.Position=UDim2.fromOffset(0,argument58+14)
        configuration122.Visible=true
        animate(configuration122,{GroupTransparency=0,Position=UDim2.fromOffset(0,argument58)},.32,Enum.EasingStyle.Quint)
    end
    function NativeWindow:_buildHome(configuration123)
        local text20,text21,text22,text23="Frame","UIListLayout","NoDrag","Executor"
        local value196=self:Tab{Name=configuration123.Name or"Home",Desc=configuration123.Desc,Icon=configuration123.Icon or"house"}
        local list2=value196.List
        local value197=configuration123.Pages or configuration123.Tabs
        local entries24={}
        local value198
        if type(value197)=="table"and#value197>0 then
            value198=createInstance(text20,{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=1,Parent=list2})
            createInstance(text21,{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=value198})
        end
        local greeting=configuration123.Greeting
        if greeting==nil then
            local value199=tonumber(os.date"%H")or 12
            local value200=value199<12 and"morning"or(value199<18 and"afternoon"or"evening")
            greeting="Good "..value200.."."
        end
        local value201=createInstance(text20,{Size=UDim2.new(1,0,0,58),BackgroundColor3=nativeTheme2.Surface2,BorderSizePixel=0,LayoutOrder=2,Parent=list2})
        value201:SetAttribute(text22,true)
        addCorner(value201)
        addStroke(value201)
        local imageLabel14=createInstance("ImageLabel",{Position=UDim2.fromOffset(12,11),Size=UDim2.fromOffset(36,36),BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value201})
        imageLabel14:SetAttribute("UIUnthemed",true)
        addCorner(imageLabel14,UDim.new(0,8))
        addStroke(imageLabel14)
        task.spawn(function()
            local success9,result8=pcall(function()
                return Players2:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
            end)
            if success9 and result8 then
                imageLabel14.Image=result8
            end
        end)
        createLabel{Position=UDim2.fromOffset(58,11),Size=UDim2.new(1,-72,0,18),Text=(configuration123.Welcome or"Hello, ")..LocalPlayer.DisplayName,TextSize=15,Parent=value201}
        createLabel{Position=UDim2.fromOffset(58,30),Size=UDim2.new(1,-72,0,16),Text=greeting,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=value201}
        if type(configuration123.AccessProvider) == "function" then
            value201.Size = UDim2.new(1, 0, 0, 90)
            local badgeRow = createInstance("Frame", {
        Name = "AccessBadges", Position = UDim2.fromOffset(12, 58), Size = UDim2.new(1, -24, 0, 22),
        BackgroundTransparency = 1, Parent = value201,
    })
            createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6), Parent = badgeRow,
    })
            local function createBadge(name, order)
                local badge = createInstance("Frame", {
            Name = name, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = nativeTheme2.Surface, BorderSizePixel = 0, LayoutOrder = order, Parent = badgeRow,
        })
                addCorner(badge, UDim.new(0, 6))
                addStroke(badge)
                addPadding(badge, 8, 8)
                return createLabel({
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            Text = "", TextSize = 11, TextColor3 = nativeTheme2.Text, TextTruncate = Enum.TextTruncate.None, Parent = badge,
        })
            end
            local accessBadge = createBadge("AccessType", 1)
            local expirationBadge = createBadge("AccessExpiration", 2)
            local function refreshAccess()
                if self._destroyed or not expirationBadge.Parent then
                    return
                end
                local success, metadata = pcall(configuration123.AccessProvider)
                if not success or type(metadata) ~= "table" then
                    metadata = {}
                end
                if metadata.Reason == "KEYLESS" then
                    accessBadge.Text = "Sem chave"
                    expirationBadge.Text = "Sem expiração"
                    return
                end
                accessBadge.Text = metadata.Premium == true and "Premium" or "Gratuito"
                if metadata.Reason ~= "KEY_VALID" then
                    accessBadge.Text = "Acesso indisponível"
                    expirationBadge.Text = "Validade indisponível"
                    return
                end
                local expiresAt = metadata.ExpiresAt
                if expiresAt == nil then
                    expirationBadge.Text = "Permanente"
                elseif type(expiresAt) ~= "number" or expiresAt ~= expiresAt or math.abs(expiresAt) == math.huge then
                    expirationBadge.Text = "Validade indisponível"
                else
                    local remaining = math.max(0, math.floor(expiresAt - os.time()))
                    local days = math.floor(remaining / 86400)
                    local hours = math.floor(remaining % 86400 / 3600)
                    local minutes = math.floor(remaining % 3600 / 60)
                    local seconds = remaining % 60
                    if remaining == 0 then
                        expirationBadge.Text = "Expirado"
                    elseif days > 0 then
                        expirationBadge.Text = string.format("Expira em %dd %02dh", days, hours)
                    elseif hours > 0 then
                        expirationBadge.Text = string.format("Expira em %02dh %02dm", hours, minutes)
                    else
                        expirationBadge.Text = string.format("Expira em %02dm %02ds", minutes, seconds)
                    end
                end
            end
            value196._accessBadges = { Access = accessBadge, Expiration = expirationBadge }
            value196._refreshAccess = refreshAccess
            refreshAccess()
        end
        local value202=createInstance(text20,{Name="SystemInfo",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=3,Parent=list2})
        createInstance(text21,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=value202})
        if configuration123.Sections~=false then
            local value203=createInstance(text20,{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=1,Parent=value202})
            local textLabel17=createLabel{Position=UDim2.fromOffset(2,6),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=uppercasePortuguese(configuration123.SectionName or"System info"),TextSize=12,TextColor3=nativeTheme2.Muted,TextTruncate=Enum.TextTruncate.None,Parent=value203}
            local value204=createInstance(text20,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,0,14),Size=UDim2.new(1,-12,0,1),BackgroundColor3=nativeTheme2.Stroke,BorderSizePixel=0,Parent=value203})
            local function callback45()
                value204.Size=UDim2.new(1,-(textLabel17.AbsoluteSize.X+14),0,1)
            end
            textLabel17:GetPropertyChangedSignal"AbsoluteSize":Connect(callback45)
            task.defer(callback45)
        end
        local value205=createInstance(text20,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Parent=value202})
        createInstance("UIGridLayout",{CellSize=UDim2.new(.5,-4,0,62),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=value205})
        local value206=configuration123.Stats or{"FPS","Ping",text23,"Game","Time"}
        local entries25={}
        for index37,entry36 in ipairs(value206)do
            entries25[entry36]=true
        end
        local count4=0
        local function callback46(configuration124,argument59,argument60)
            if not entries25[configuration124]then
                return nil
            end
            count4+=1
            return createStatisticCard(value205,count4,argument59,(configuration123.Labels or{})[configuration124]or argument60)
        end
        local fPSValueLabel=callback46("FPS","activity","FPS")
        local pingValueLabel=callback46("Ping","wifi","Ping")
        local value207=callback46(text23,"terminal",text23)
        local gameValueLabel=callback46("Game","gamepad-2","Game")
        local timeValueLabel=callback46("Time","clock","Time of day")
        local playersValueLabel=callback46("Players","users","Players")
        local uptimeValueLabel=callback46("Uptime","timer","Session")
        if value207 then
            local executor = detectExecutor()
            value207.Text = executor == "Unknown" and "Indisponível" or executor
        end
        if gameValueLabel then
            gameValueLabel.Text = "Carregando..."
            task.spawn(function()
                local name = detectGameName()
                if not self._destroyed and gameValueLabel.Parent then
                    gameValueLabel.Text = name == "Unknown game" and "Jogo indisponível" or name
                end
            end)
        end
        local frames, elapsed = 0, 0
        local started = os.clock()
        local memoryLabel = callback46("Memory", "cpu", (configuration123.Labels or {}).Memory or "Luau memory")
        local function refresh()
            if self._destroyed or not value196.List.Parent or not value196._page.Parent then
                return
            end
            if value196._refreshAccess then
                value196._refreshAccess()
            end
            if fPSValueLabel then
                fPSValueLabel.Text = elapsed > 0 and tostring(math.floor(frames / elapsed + 0.5)) or "—"
            end
            if pingValueLabel then
                local success, ping = pcall(function()
                    return LocalPlayer:GetNetworkPing()
                end)
                pingValueLabel.Text = success and type(ping) == "number" and tostring(math.floor(ping * 1000 + 0.5)) .. " ms" or "Indisponível"
            end
            if timeValueLabel then
                timeValueLabel.Text = os.date(configuration123.TimeFormat or "%H:%M")
            end
            if playersValueLabel then
                playersValueLabel.Text = #Players2:GetPlayers() .. " / " .. Players2.MaxPlayers
            end
            if uptimeValueLabel then
                local seconds = math.floor(os.clock() - started)
                uptimeValueLabel.Text = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
            end
            if memoryLabel then
                local success, kilobytes = pcall(gcinfo)
                memoryLabel.Text = success and type(kilobytes) == "number" and string.format("%.1f MB", kilobytes / 1024) or "Indisponível"
            end
        end
        value196._homeStatValues = { FPS = fPSValueLabel, Ping = pingValueLabel, Executor = value207, Game = gameValueLabel, Time = timeValueLabel, Players = playersValueLabel, Uptime = uptimeValueLabel, Memory = memoryLabel }
        refresh()
        self:_listen("Render", function(delta)
            if self._destroyed or not value196.List.Parent or not value196._page.Parent then
                return
            end
            if not self.Open or not self.Gui.Enabled or self.CurrentTab ~= value196 then
                frames, elapsed = 0, 0
                return
            end
            frames += 1
            elapsed += math.max(delta or 0, 0)
            if elapsed >= 1 then
                refresh()
                frames, elapsed = 0, 0
            end
        end)
        table.insert(entries24,{Title=configuration123.SectionName or"Details",Icon=configuration123.TabIcon or"layout-grid",Frame=value202})
        if value198 then
            for index38,entry37 in ipairs(value197)do
                local value208=createInstance(text20,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,LayoutOrder=3,Parent=list2})
                createInstance(text21,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=value208})
                if type(entry37.Content)=="string"then
                    local value209=createInstance(text20,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=nativeTheme2.Surface2,BorderSizePixel=0,LayoutOrder=1,Parent=value208})
                    value209:SetAttribute(text22,true)
                    addCorner(value209)
                    addStroke(value209)
                    addPadding(value209,14,14,12,14)
                    createLabel{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=entry37.Content,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=value209}
                end
                if type(entry37.Entries)=="table"then
                    for index39,entry38 in ipairs(entry37.Entries)do
                        local value210=createInstance(text20,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=nativeTheme2.Surface2,BorderSizePixel=0,LayoutOrder=index39,Parent=value208})
                        value210:SetAttribute(text22,true)
                        addCorner(value210)
                        addStroke(value210)
                        addPadding(value210,14,14,12,14)
                        createInstance(text21,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=value210})
                        local value211=createInstance(text20,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=1,Parent=value210})
                        createLabel{Size=UDim2.new(1,-70,1,0),Text=entry38.Title or entry38.Version or"Update",TextSize=14,Parent=value211}
                        if entry38.Date or entry38.Tag then
                            local value212=createInstance(text20,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(0,20),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=nativeTheme2.Surface,BorderSizePixel=0,Parent=value211})
                            addCorner(value212,UDim.new(0,5))
                            addStroke(value212)
                            addPadding(value212,8,8)
                            createLabel{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=entry38.Tag or entry38.Date,TextSize=11,TextColor3=nativeTheme2.Muted,TextTruncate=Enum.TextTruncate.None,Parent=value212}
                        end
                        local value213=entry38.Content or entry38.Body
                        if type(entry38.Changes)=="table"then
                            value213="• "..table.concat(entry38.Changes,"\n• ")
                        end
                        if value213 then
                            createLabel{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=value213,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=value210}
                        end
                    end
                end
                if type(entry37.Build)=="function"then
                    invokeCallback(entry37.Build,value208)
                    for index40,entry39 in ipairs(value208:GetChildren())do
                        if entry39:IsA"GuiObject"then
                            entry39:SetAttribute(text22,true)
                        end
                    end
                end
                table.insert(entries24,{Title=entry37.Name or entry37.Title or"Page",Icon=entry37.Icon,Frame=value208})
            end
            local entries26={}
            local function callback47(configuration125,argument61)
                local value214=self._homeIndex~=configuration125
                self._homeIndex=configuration125
                value201.Visible=configuration125==1
                if configuration125==1 and value214 and not argument61 then
                    revealHomeContent(value201)
                end
                for index41,entry40 in ipairs(entries24)do
                    local value215=index41==configuration125
                    local frame17=entry40.Frame
                    frame17.Visible=value215
                    if value215 and value214 and not argument61 then
                        for index42,entry41 in ipairs(frame17:GetChildren())do
                            if entry41:IsA"GuiObject"then
                                revealHomeContent(entry41)
                            end
                        end
                    end
                    local value216=entries26[index41]
                    if value216 then
                        animate(value216.Frame,{BackgroundTransparency=value215 and 0 or 1},.15)
                        animate(value216.Stroke,{Transparency=value215 and 0 or 1},.15)
                        animate(value216.Label,{TextColor3=value215 and nativeTheme2.Text or nativeTheme2.Muted},.15)
                        if value216.Icon then
                            animate(value216.Icon,{ImageColor3=value215 and nativeTheme2.Accent or nativeTheme2.Muted},.15)
                        end
                    end
                end
            end
            for index43,entry42 in ipairs(entries24)do
                local textButton9=createInstance("TextButton",{Size=UDim2.fromOffset(0,32),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=nativeTheme2.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=index43,Parent=value198})
                addCorner(textButton9,UDim.new(0,7))
                local stroke11=addStroke(textButton9,nativeTheme2.Stroke,1)
                addPadding(textButton9,12,12)
                local value217
                if entry42.Icon then
                    value217=createInstance("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=nativeTheme2.Muted,ScaleType=Enum.ScaleType.Fit,Parent=textButton9})
                    applyIcon(value217,entry42.Icon)
                end
                local textLabel18=createLabel{Position=UDim2.fromOffset(value217 and 20 or 0,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=entry42.Title,TextSize=13,TextColor3=nativeTheme2.Muted,TextTruncate=Enum.TextTruncate.None,Parent=textButton9}
                entries26[index43]={Frame=textButton9,Stroke=stroke11,Label=textLabel18,Icon=value217}
                textButton9.MouseEnter:Connect(function()
                    if self._homeIndex~=index43 then
                        animate(textButton9,{BackgroundTransparency=.4},.12)
                        animate(stroke11,{Transparency=.5},.12)
                    end
                end)
                textButton9.MouseLeave:Connect(function()
                    if self._homeIndex~=index43 then
                        animate(textButton9,{BackgroundTransparency=1},.2)
                        animate(stroke11,{Transparency=1},.2)
                    end
                end)
                textButton9.MouseButton1Click:Connect(function()
                    callback47(index43)
                end)
            end
            callback47(1)
        end
        value196._order=10
        self.Home=value196
        return value196
    end
    function NativeWindow:Tab(configuration126,argument62)
        configuration126=normalizeOptions2(configuration126,{Title="Name",Description="Desc"})
        if argument62~=nil and configuration126.Icon==nil then
            configuration126.Icon=argument62
        end
        local value218=setmetatable({Name=configuration126.Name or"Tab",Window=self,_order=0,_iconThemed=configuration126.IconThemed~=false},NativeTab)
        local textButton10=createInstance("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=nativeTheme2.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=#self.Tabs+1,Parent=self.TabList})
        addCorner(textButton10)
        local stroke12=addStroke(textButton10,nativeTheme2.Stroke,1)
        value218._button=textButton10
        local value219=configuration126.Icon~=nil
        if value219 then
            local imageLabel15=createInstance("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,12,.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=value218._iconThemed and nativeTheme2.Muted or Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit,Parent=textButton10})
            applyIcon(imageLabel15,configuration126.Icon)
            value218._icon=imageLabel15
        end
        value218._label=createLabel{Position=UDim2.fromOffset(value219 and 36 or 14,0),Size=UDim2.new(1,-(value219 and 44 or 22),1,0),Text=value218.Name,TextColor3=nativeTheme2.Muted,Parent=textButton10}
        local frame18=createInstance("Frame",{Name=value218.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,Parent=self.Content})
        value218._page=frame18
        createLabel{Position=UDim2.fromOffset(24,20),Size=UDim2.new(1,-72,0,24),Text=value218.Name,TextSize=22,Parent=frame18}
        if configuration126.Desc then
            createLabel{Position=UDim2.fromOffset(24,44),Size=UDim2.new(1,-72,0,16),Text=configuration126.Desc,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,Parent=frame18}
        end
        local value220=configuration126.Desc and 70 or 58
        local scrollingFrame2=createInstance("ScrollingFrame",{Position=UDim2.fromOffset(0,value220),Size=UDim2.new(1,0,1,-value220),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=nativeTheme2.Accent,ScrollBarImageTransparency=.5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=frame18})
        addPadding(scrollingFrame2,24,24,2,24)
        createInstance("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=scrollingFrame2})
        value218.List=scrollingFrame2
        local value221,count5=createEmptyPage(frame18,configuration126.Icon or"layout-grid",configuration126.EmptyText or"Nothing here yet"),0
        scrollingFrame2.ChildAdded:Connect(function(configuration127)
            if configuration127:IsA"GuiObject"then
                count5+=1
                value221.Visible=false
            end
        end)
        scrollingFrame2.ChildRemoved:Connect(function(configuration128)
            if configuration128:IsA"GuiObject"then
                count5=math.max(count5-1,0)
                value221.Visible=count5<=0
            end
        end)
        value221.Visible=true
        textButton10.MouseEnter:Connect(function()
            if self.CurrentTab~=value218 then
                animate(textButton10,{BackgroundTransparency=.4},.12)
                animate(stroke12,{Transparency=.5},.12)
            end
        end)
        textButton10.MouseLeave:Connect(function()
            if self.CurrentTab~=value218 then
                animate(textButton10,{BackgroundTransparency=1},.2)
                animate(stroke12,{Transparency=1},.2)
            end
        end)
        textButton10.MouseButton1Click:Connect(function()
            self:SelectTab(value218)
        end)
        value218._stroke=stroke12
        if not self._introDone then
            textButton10.Visible=false
        end
        table.insert(self.Tabs,value218)
        if#self.Tabs==1 then
            task.defer(function()
                self:SelectTab(value218)
            end)
        end
        return value218
    end
    NativeWindow.CreateTab=NativeWindow.Tab
    function NativeWindow:Dialog(configuration129)
        local useDefaultButtonStyle=NativeLibrary.ThemeName=="Mono"
        local text24="TextTransparency"
        configuration129=normalizeOptions2(configuration129,{Text="Content",Message="Content"})
        if self._dialog then
            self._dialog.Close()
        end
        local count6=18
        local textButton11=createInstance("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=40,Parent=self.Body})
        local frame19=createInstance("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,10),Size=UDim2.fromOffset(300,120),BackgroundColor3=nativeTheme2.Background,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=41,Parent=textButton11})
        addCorner(frame19,UDim.new(0,16))
        local stroke13=addStroke(frame19,nativeTheme2.Stroke,1)
        local value222=createInstance("UIScale",{Scale=.94,Parent=frame19})
        local entries27,count7={},0
        if configuration129.Icon then
            local iconContainer,iconImage=createIcon(frame19,configuration129.Icon,nativeTheme2.Accent,UDim2.new(0,count6,0,count6+9))
            iconImage.ImageTransparency=1
            iconContainer.ZIndex=42
            iconImage.ZIndex=42
            table.insert(entries27,{iconImage,"ImageTransparency",0})
            count7=24
        end
        local textLabel19=createLabel{Position=UDim2.fromOffset(count6+count7,count6),Size=UDim2.new(1,-(count6*2+count7),0,18),Text=configuration129.Title or"Are you sure?",TextSize=15,TextTransparency=1,ZIndex=42,Parent=frame19}
        table.insert(entries27,{textLabel19,text24,0})
        local count8=0
        if configuration129.Content then
            local textLabel20=createLabel{Position=UDim2.fromOffset(count6,count6+24),Size=UDim2.new(1,-count6*2,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=configuration129.Content,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextWrapped=true,TextTransparency=1,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=42,Parent=frame19}
            table.insert(entries27,{textLabel20,text24,0})
            count8=math.max(textLabel20.TextBounds.Y,16)+6
            textLabel20:GetPropertyChangedSignal"TextBounds":Connect(function()
                local value223=math.max(textLabel20.TextBounds.Y,16)+6
                if value223~=count8 then
                    count8=value223
                    frame19.Size=UDim2.fromOffset(300,count6+24+count8+12+34+count6)
                    local value224=frame19:FindFirstChild"ButtonRow"
                    if value224 then
                        value224.Position=UDim2.fromOffset(count6,count6+24+count8+12)
                    end
                end
            end)
        end
        local frame20=createInstance("Frame",{Name="ButtonRow",Position=UDim2.fromOffset(count6,count6+24+count8+12),Size=UDim2.new(1,-count6*2,0,34),BackgroundTransparency=1,ZIndex=42,Parent=frame19})
        createInstance("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=frame20})
        frame19.Size=UDim2.fromOffset(300,count6+24+count8+12+34+count6)
        local entries28,enabled15={},false
        function entries28.Close()
            if enabled15 then
                return
            end
            enabled15=true
            if self._dialog==entries28 then
                self._dialog=nil
            end
            animate(textButton11,{BackgroundTransparency=1},.18)
            animate(frame19,{BackgroundTransparency=1,Position=UDim2.new(.5,0,.5,8)},.18,Enum.EasingStyle.Quint)
            animate(value222,{Scale=.96},.18,Enum.EasingStyle.Quint)
            animate(stroke13,{Transparency=1},.12)
            for index44,entry43 in ipairs(entries27)do
                animate(entry43[1],{[entry43[2]]=1},.12)
            end
            task.delay(.2,function()
                textButton11:Destroy()
            end)
        end
        for index45,entry44 in ipairs(configuration129.Buttons or{})do
            local value225=entry44.Variant=="Primary"and not useDefaultButtonStyle
            local textButton12=createInstance("TextButton",{Size=UDim2.fromOffset(0,34),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=value225 and nativeTheme2.Accent or nativeTheme2.Surface2,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,LayoutOrder=index45,ZIndex=43,Parent=frame20})
            addCorner(textButton12,UDim.new(0,7))
            local stroke14=addStroke(textButton12,value225 and nativeTheme2.Accent or nativeTheme2.Stroke,1)
            addPadding(textButton12,14,14)
            local textLabel21=createLabel{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=entry44.Title or entry44.Name or"OK",TextSize=13,TextColor3=value225 and nativeTheme2.AccentDark or nativeTheme2.Text,TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=1,ZIndex=44,Parent=textButton12}
            local value226=value225 and.12 or 0
            local value227=value225 and.4 or 0
            table.insert(entries27,{textButton12,"BackgroundTransparency",value226})
            table.insert(entries27,{stroke14,"Transparency",value227})
            table.insert(entries27,{textLabel21,text24,0})
            textButton12.MouseEnter:Connect(function()
                if enabled15 then
                    return
                end
                if value225 then
                    animate(textButton12,{BackgroundTransparency=0},.12)
                    animate(stroke14,{Transparency=0},.12)
                else
                    animate(stroke14,{Color=nativeTheme2.StrokeHover},.12)
                end
            end)
            textButton12.MouseLeave:Connect(function()
                if enabled15 then
                    return
                end
                if value225 then
                    animate(textButton12,{BackgroundTransparency=value226},.2)
                    animate(stroke14,{Transparency=value227},.2)
                else
                    animate(stroke14,{Color=nativeTheme2.Stroke},.2)
                end
            end)
            textButton12.MouseButton1Click:Connect(function()
                entries28.Close()
                invokeCallback(entry44.Callback)
            end)
        end
        if configuration129.CloseOnBackdrop~=false then
            textButton11.MouseButton1Click:Connect(function()
                entries28.Close()
                invokeCallback(configuration129.OnCancel)
            end)
        end
        self._dialog=entries28
        animate(textButton11,{BackgroundTransparency=.45},.25)
        animate(frame19,{BackgroundTransparency=0,Position=UDim2.fromScale(.5,.5)},.3,Enum.EasingStyle.Quint)
        animate(stroke13,{Transparency=0},.25)
        animate(value222,{Scale=1},.4,Enum.EasingStyle.Back)
        for index46,entry45 in ipairs(entries27)do
            animate(entry45[1],{[entry45[2]]=entry45[3]},.25)
        end
        return entries28
    end
    function NativeWindow:Confirm(configuration130)
        configuration130=normalizeOptions2(configuration130,{Text="Content",Message="Content"})
        return self:Dialog{Title=configuration130.Title or"Are you sure?",Content=configuration130.Content,Icon=configuration130.Icon,OnCancel=configuration130.OnCancel,Buttons={{Title=configuration130.CancelText or"Cancel",Callback=configuration130.OnCancel},{Title=configuration130.ConfirmText or"Confirm",Variant="Primary",Callback=configuration130.Callback}}}
    end
    function NativeWindow:_listen(configuration131,argument63,argument64)
        local value228=self._inputListeners[configuration131]
        table.insert(value228,argument63)
        local function callback48()
            for index47,entry46 in ipairs(value228)do
                if entry46==argument63 then
                    table.remove(value228,index47)
                    break
                end
            end
        end
        if argument64 then
            argument64._listeners=argument64._listeners or{}
            table.insert(argument64._listeners,callback48)
        end
        return callback48
    end
    function NativeWindow:_indicatorY(configuration132)
        local tabList=self.TabList
        local scale3=self.Scale.Scale
        return(configuration132._button.AbsolutePosition.Y-tabList.AbsolutePosition.Y+configuration132._button.AbsoluteSize.Y/2)/scale3+tabList.Position.Y.Offset
    end
    function NativeWindow:_placeIndicator(configuration133)
        local indicator2=self.Indicator
        local value229=self:_indicatorY(configuration133)
        if not indicator2.Visible then
            indicator2.Visible=true
            indicator2.Position=UDim2.fromOffset(6,value229)
            indicator2.Size=UDim2.fromOffset(3,0)
        end
        animate(indicator2,{Position=UDim2.fromOffset(6,value229),Size=UDim2.fromOffset(3,18)},.35,Enum.EasingStyle.Back)
    end
    function NativeWindow:SelectTab(configuration134)
        if self.CurrentTab==configuration134 then
            return
        end
        local currentTab=self.CurrentTab
        self.CurrentTab=configuration134
        self:_settleTransition()
        local value230=(self._transitionGeneration or 0)+1
        self._transitionGeneration=value230
        if currentTab then
            animate(currentTab._button,{BackgroundTransparency=1},.2)
            animate(currentTab._stroke,{Transparency=1},.2)
            animate(currentTab._label,{TextColor3=nativeTheme2.Muted},.2)
            if currentTab._icon and currentTab._iconThemed then
                animate(currentTab._icon,{ImageColor3=nativeTheme2.Muted},.2)
            end
            local _outLayer=self._outLayer
            currentTab._page.Parent=_outLayer
            self._outPage=currentTab._page
            _outLayer.GroupTransparency=0
            _outLayer.Position=UDim2.fromOffset(0,0)
            _outLayer.Visible=true
            animate(_outLayer,{GroupTransparency=1,Position=UDim2.fromOffset(0,-10)},.18)
            task.delay(.18,function()
                if self._transitionGeneration==value230 then
                    self:_settleOut()
                end
            end)
        end
        animate(configuration134._button,{BackgroundTransparency=0},.2)
        animate(configuration134._stroke,{Transparency=0},.2)
        animate(configuration134._label,{TextColor3=nativeTheme2.Text},.2)
        if configuration134._icon and configuration134._iconThemed then
            animate(configuration134._icon,{ImageColor3=nativeTheme2.Accent},.2)
        end
        self:_placeIndicator(configuration134)
        local _page=configuration134._page
        _page.Position=UDim2.fromOffset(0,0)
        _page.Visible=true
        _page.Parent=self._inLayer
        self._inPage=_page
        revealPage(self._inLayer)
        task.delay(.32,function()
            if self._transitionGeneration==value230 then
                self:_settleIn()
            end
        end)
    end
    function NativeWindow:_settleOut()
        local _outPage=self._outPage
        if _outPage then
            _outPage.Parent=self.Content
            _outPage.Visible=false
            self._outPage=nil
        end
        self._outLayer.Visible=false
    end
    function NativeWindow:_settleIn()
        local _inPage=self._inPage
        if _inPage then
            _inPage.Parent=self.Content
            _inPage.Position=UDim2.fromOffset(0,0)
            self._inPage=nil
        end
        self._inLayer.Visible=false
    end
    function NativeWindow:_settleTransition()
        self:_settleOut()
        self:_settleIn()
    end
    function NativeWindow:Toggle(configuration135)
        if not self._introDone then
            return
        end
        if configuration135==nil then
            configuration135=not self.Open
        end
        if configuration135==self.Open then
            return
        end
        self.Open=configuration135
        if configuration135 then
            self.Root.Visible=true
            animate(self.Scale,{Scale=self._fitScale or 1},.4,Enum.EasingStyle.Back)
            animate(self.Body,{GroupTransparency=0},.25)
            animate(self.BodyStroke,{Transparency=0},.25)
            animate(self.Shadow,{ImageTransparency=.6},.3)
        else
            animate(self.Scale,{Scale=(self._fitScale or 1)*.94},.2,Enum.EasingStyle.Quint)
            animate(self.Body,{GroupTransparency=1},.16)
            animate(self.BodyStroke,{Transparency=1},.12)
            animate(self.Shadow,{ImageTransparency=1},.16)
            task.delay(.2,function()
                if not self.Open then
                    self.Root.Visible=false
                end
            end)
        end
    end
    function NativeWindow:SetKeepOnScreen(configuration136)
        self.KeepOnScreen=configuration136~=false
        if self.KeepOnScreen then
            self:_clampToScreen()
        end
    end
    function NativeWindow:SetKeybind(configuration137)
        self.Keybind=configuration137
        self._keyChipLabel.Text=formatKeyName(configuration137)
    end
    function NativeWindow:Notify(configuration138)
        local text25="Frame"
        configuration138=normalizeOptions2(configuration138,{Text="Content",Message="Content",Image="Icon"})
        local value231=configuration138.Duration or 4
        local value232=notificationColors[configuration138.Type]or nativeTheme2.Text
        self._notifyOrder+=1
        local value233=createInstance(text25,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,LayoutOrder=self._notifyOrder,Parent=self.NotifyHolder})
        local value234=createInstance(text25,{Position=UDim2.fromOffset(320,0),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=value233})
        local imageLabel16=createInstance("ImageLabel",{Position=UDim2.fromOffset(-20,-20),Size=UDim2.new(1,40,1,40),BackgroundTransparency=1,Image=nativeAssets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=value234})
        local canvasGroup2=createInstance("CanvasGroup",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=nativeTheme2.Background,BorderSizePixel=0,GroupTransparency=1,Parent=value234})
        addCorner(canvasGroup2,UDim.new(0,10))
        local stroke15=addStroke(canvasGroup2,nativeTheme2.Stroke)
        addEdgeHighlight(canvasGroup2)
        addGlow(canvasGroup2,UDim2.fromOffset(260,120),UDim2.new(1,-10,0,-10),.86,90)
        local value235=createInstance(text25,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=canvasGroup2})
        addPadding(value235,16,16,14,24)
        local count9=0
        if configuration138.Icon then
            createIcon(value235,configuration138.Icon,value232==nativeTheme2.Text and nativeTheme2.Accent or value232,UDim2.new(0,0,0,8))
            count9=24
        end
        createLabel{Position=UDim2.fromOffset(count9,0),Size=UDim2.new(1,-28-count9,0,16),Text=configuration138.Title or"Notification",TextSize=14,TextColor3=value232,Parent=value235}
        local textButton13=createInstance("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,6,0,-5),Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,Text="×",TextColor3=nativeTheme2.Muted,TextSize=22,FontFace=nativeFonts.Bold,AutoButtonColor=false,Parent=value235})
        textButton13.MouseEnter:Connect(function()
            animate(textButton13,{TextColor3=nativeTheme2.Text},.15)
        end)
        textButton13.MouseLeave:Connect(function()
            animate(textButton13,{TextColor3=nativeTheme2.Muted},.2)
        end)
        if configuration138.Content then
            createLabel{Position=UDim2.fromOffset(count9,21),Size=UDim2.new(1,-count9,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=configuration138.Content,TextSize=13,FontFace=nativeFonts.Regular,TextColor3=nativeTheme2.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=value235}
        end
        local value236=createInstance(text25,{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-8),Size=UDim2.new(1,-32,0,3),BackgroundColor3=nativeTheme2.Surface3,BorderSizePixel=0,Parent=canvasGroup2})
        addCorner(value236,UDim.new(1,0))
        local value237=createInstance(text25,{Size=UDim2.fromScale(1,1),BackgroundColor3=nativeTheme2.Accent,BorderSizePixel=0,Parent=value236})
        addCorner(value237,UDim.new(1,0))
        task.defer(function()
            if value233.Parent then
                animate(value233,{Size=UDim2.new(1,0,0,canvasGroup2.AbsoluteSize.Y)},.3,Enum.EasingStyle.Quint)
            end
        end)
        animate(value234,{Position=UDim2.fromOffset(0,0)},.5,Enum.EasingStyle.Back)
        animate(canvasGroup2,{GroupTransparency=0},.3)
        animate(imageLabel16,{ImageTransparency=.6},.4)
        animate(value237,{Size=UDim2.fromScale(0,1)},value231,Enum.EasingStyle.Linear)
        local enabled16=false
        local function callback49()
            if enabled16 then
                return
            end
            enabled16=true
            for index48,entry47 in ipairs(self._toasts)do
                if entry47==callback49 then
                    table.remove(self._toasts,index48)
                    break
                end
            end
            animate(value234,{Position=UDim2.fromOffset(320,0)},.3,Enum.EasingStyle.Quint)
            animate(canvasGroup2,{GroupTransparency=1},.2)
            animate(stroke15,{Transparency=1},.15)
            animate(imageLabel16,{ImageTransparency=1},.2)
            task.delay(.22,function()
                value233.ClipsDescendants=true
                animate(value233,{Size=UDim2.new(1,0,0,-4)},.22,Enum.EasingStyle.Quint)
                task.delay(.24,function()
                    value233:Destroy()
                end)
            end)
        end
        task.delay(value231,callback49)
        textButton13.MouseButton1Click:Connect(callback49)
        table.insert(self._toasts,callback49)
        while#self._toasts>self.MaxNotifications do
            local value238=table.remove(self._toasts,1)
            value238()
        end
        return{Dismiss=callback49}
    end
    function NativeWindow:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed=true
        for index49,entry48 in ipairs(NativeLibrary.Windows)do
            if entry48==self then
                table.remove(NativeLibrary.Windows,index49)
                break
            end
        end
        for index50,entry49 in ipairs(self._connections)do
            entry49:Disconnect()
        end
        self._connections={}
        animate(self.Scale,{Scale=.9},.2)
        animate(self.Body,{GroupTransparency=1},.2)
        animate(self.BodyStroke,{Transparency=1},.12)
        animate(self.Shadow,{ImageTransparency=1},.2)
        task.delay(.22,function()
            self.Gui:Destroy()
        end)
    end
    NativeLibrary.UIBridge={ResolveIcon=resolveIcon}
    return NativeLibrary
end)()
local ThemeFactory = (function()
    return function()
        return {
    ["Default"] = {
        Name = "Default",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(20, 16, 20),
        Surface = Color3.fromRGB(24, 19, 24),
        Surface2 = Color3.fromRGB(28, 22, 28),
        Surface3 = Color3.fromRGB(42, 36, 43),
        Stroke = Color3.fromRGB(40, 32, 41),
        StrokeHover = Color3.fromRGB(88, 70, 90),
        Accent = Color3.fromRGB(235, 199, 246),
        AccentDark = Color3.fromRGB(24, 18, 26),
        Text = Color3.fromRGB(233, 229, 234),
        Muted = Color3.fromRGB(138, 127, 139),
        Glow = Color3.fromRGB(226, 218, 230),
    },
    ["Midnight"] = {
        Name = "Midnight",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(14, 16, 22),
        Surface = Color3.fromRGB(18, 21, 28),
        Surface2 = Color3.fromRGB(22, 25, 34),
        Surface3 = Color3.fromRGB(36, 41, 54),
        Stroke = Color3.fromRGB(32, 36, 48),
        StrokeHover = Color3.fromRGB(70, 80, 104),
        Accent = Color3.fromRGB(150, 180, 255),
        AccentDark = Color3.fromRGB(12, 16, 28),
        Text = Color3.fromRGB(226, 230, 240),
        Muted = Color3.fromRGB(122, 131, 153),
        Glow = Color3.fromRGB(210, 220, 240),
    },
    ["Moss"] = {
        Name = "Moss",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(15, 18, 15),
        Surface = Color3.fromRGB(19, 23, 19),
        Surface2 = Color3.fromRGB(23, 28, 23),
        Surface3 = Color3.fromRGB(37, 44, 37),
        Stroke = Color3.fromRGB(33, 40, 33),
        StrokeHover = Color3.fromRGB(72, 88, 72),
        Accent = Color3.fromRGB(176, 222, 170),
        AccentDark = Color3.fromRGB(14, 22, 14),
        Text = Color3.fromRGB(228, 234, 227),
        Muted = Color3.fromRGB(121, 136, 119),
        Glow = Color3.fromRGB(214, 230, 212),
    },
    ["Ember"] = {
        Name = "Ember",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(20, 16, 13),
        Surface = Color3.fromRGB(25, 20, 16),
        Surface2 = Color3.fromRGB(30, 24, 19),
        Surface3 = Color3.fromRGB(46, 37, 30),
        Stroke = Color3.fromRGB(42, 34, 27),
        StrokeHover = Color3.fromRGB(96, 76, 58),
        Accent = Color3.fromRGB(255, 190, 140),
        AccentDark = Color3.fromRGB(28, 18, 10),
        Text = Color3.fromRGB(240, 232, 226),
        Muted = Color3.fromRGB(146, 129, 113),
        Glow = Color3.fromRGB(240, 222, 208),
    },
    ["Rose"] = {
        Name = "Rose",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(21, 14, 17),
        Surface = Color3.fromRGB(26, 18, 21),
        Surface2 = Color3.fromRGB(31, 21, 25),
        Surface3 = Color3.fromRGB(48, 34, 40),
        Stroke = Color3.fromRGB(44, 30, 36),
        StrokeHover = Color3.fromRGB(100, 66, 80),
        Accent = Color3.fromRGB(255, 170, 195),
        AccentDark = Color3.fromRGB(30, 12, 18),
        Text = Color3.fromRGB(240, 228, 232),
        Muted = Color3.fromRGB(149, 124, 133),
        Glow = Color3.fromRGB(240, 214, 222),
    },
    ["Mono"] = {
        Name = "Mono",
        Warning = Color3.fromRGB(240, 176, 108),
        Success = Color3.fromRGB(150, 220, 170),
        Error = Color3.fromRGB(240, 120, 120),
        Background = Color3.fromRGB(16, 16, 17),
        Surface = Color3.fromRGB(20, 20, 21),
        Surface2 = Color3.fromRGB(24, 24, 26),
        Surface3 = Color3.fromRGB(40, 40, 43),
        Stroke = Color3.fromRGB(36, 36, 39),
        StrokeHover = Color3.fromRGB(80, 80, 86),
        Accent = Color3.fromRGB(230, 230, 235),
        AccentDark = Color3.fromRGB(18, 18, 20),
        Text = Color3.fromRGB(232, 232, 236),
        Muted = Color3.fromRGB(130, 130, 136),
        Glow = Color3.fromRGB(220, 220, 226),
    },
    }
    end
end)()
local AdapterFactory = (function()
    return function(Airflow, ThemeFactory, Palette, Runtime)
        local Players = Runtime.GetService("Players")
        local Http = Runtime.GetService("HttpService")
        local TweenService = Runtime.GetService("TweenService")
        local UserInput = Runtime.GetService("UserInputService")
        local parent, parentSource = Runtime.GetUIParent()
        local Bridge = assert(Airflow.UIBridge, "Airflow bridge is missing")
        local Library = {
        Airflow = Airflow,
        Palette = Palette,
        Themes = {},
        Theme = nil,
        TransparencyValue = 0.35,
        _controls = {},
        _connections = {},
        _destroyed = false,
        _parent = parent,
        ParentSource = parentSource,
    }
        local ControlMethods = {}
        local ContainerMethods = {}
        local WindowMethods = {}
        local function connect(signal, callback)
            local connection = signal:Connect(callback)
            Library._connections[connection] = true
            return connection
        end
        local function disconnect(connection)
            if connection then
                Library._connections[connection] = nil
                connection:Disconnect()
            end
        end
        local function new(className, properties, children)
            local object = Instance.new(className)
            for key, value in pairs(properties or {}) do
                if key ~= "Parent" and key ~= "ThemeTag" then
                    object[key] = value
                end
            end
            for _, child in ipairs(children or {}) do
                child.Parent = object
            end
            object.Parent = properties and properties.Parent or nil
            return object
        end
        local function call(callback, ...)
            if type(callback) ~= "function" then
                return
            end
            local success, result = pcall(callback, ...)
            if not success then
            end
            return result
        end
        local function color(value, fallback)
            if typeof(value) == "Color3" then
                return value
            end
            if typeof(value) == "ColorSequence" then
                return value.Keypoints[1].Value
            end
            if type(value) == "table" and value.Color then
                return color(value.Color, fallback)
            end
            return fallback
        end
        local function setIcon(image, value, tint)
            if value == nil or value == "" then
                image.Image = "";
                return
            end
            local asset, offset, size
            if type(value) == "string" and value:match("^rbxthumb://") then
                asset = value
            else
                asset, offset, size = Bridge.ResolveIcon(value)
            end
            image.Image = asset or ""
            image.ImageRectOffset = offset or Vector2.zero
            image.ImageRectSize = size or Vector2.zero
            image.ImageColor3 = tint or Airflow.Theme.Accent
        end
        local function textLabels(frame)
            local labels = {}
            for _, object in ipairs(frame:GetDescendants()) do
                if object:IsA("TextLabel") then
                    object.RichText = true
                    labels[#labels + 1] = object
                end
            end
            return labels
        end
        local function findTextBox(frame)
            return frame:FindFirstChildWhichIsA("TextBox", true)
        end
        local function isLocked(handle)
            if handle.Locked then
                return true
            end
            local parent = handle._context
            while parent do
                if parent.Locked then
                    return true
                end
                parent = parent._context
            end
            return false
        end
        local function optionLabel(value)
            if type(value) == "table" then
                return tostring(value.Title or value.Name or value[1] or "")
            end
            return value ~= nil and tostring(value) or nil
        end
        local function normalizeOptions(values)
            local labels, originals = {}, {}
            for _, value in ipairs(values or {}) do
                local label = optionLabel(value)
                if label then
                    labels[#labels + 1] = label
                    originals[label] = value
                end
            end
            return labels, originals
        end
        local function toNativeSelection(handle, value)
            if handle.Multi then
                local result = {}
                if value ~= nil then
                    local values = type(value) == "table" and not value.Title and value or { value }
                    for _, item in ipairs(values) do
                        result[#result + 1] = optionLabel(item)
                    end
                end
                return result
            end
            return optionLabel(value)
        end
        local function fromNativeSelection(handle, value)
            if handle.Multi then
                local result = {}
                for _, label in ipairs(value or {}) do
                    result[#result + 1] = handle._options[label] or label
                end
                return result
            end
            return value ~= nil and (handle._options[value] or value) or nil
        end
        local function syncValue(handle, value)
            if handle.__type == "Dropdown" then
                handle.Value = fromNativeSelection(handle, value)
            elseif handle.__type == "Slider" then
                handle.Value.Default = tonumber(value) or handle.Value.Default
            elseif handle.__type == "Keybind" then
                handle.Value = typeof(value) == "EnumItem" and value.Name or tostring(value or "Unknown")
            elseif handle.__type == "Colorpicker" then
                handle.Default = value
                handle.Value = value
            else
                handle.Value = value
            end
            if handle._checkbox then
                handle._checkbox.BackgroundColor3 = handle.Value and Airflow.Theme.Accent or Airflow.Theme.Surface3
                handle._checkmark.ImageTransparency = handle.Value and 0 or 1
            end
        end
        local function nativeValue(handle)
            if handle.__type == "Slider" then
                return handle.Value.Default
            end
            if handle.__type == "Dropdown" then
                return toNativeSelection(handle, handle.Value)
            end
            if handle.__type == "Keybind" then
                return Enum.KeyCode[handle.Value] or Enum.KeyCode.Unknown
            end
            if handle.__type == "Colorpicker" then
                return handle.Default
            end
            return handle.Value
        end
        local function dispatch(handle, value, ...)
            if handle._destroyed or Library._destroyed then
                return
            end
            if isLocked(handle) then
                if handle._native and handle._native.Set and handle.__type ~= "Input" then
                    handle._native:Set(nativeValue(handle), true)
                end
                return
            end
            if handle.__type == "Dropdown" and not handle.AllowNone then
                local empty = value == nil or (handle.Multi and #value == 0)
                if empty and handle.Value ~= nil and handle._native then
                    handle._native:Set(nativeValue(handle), true)
                    return
                end
            end
            syncValue(handle, value)
            local returned = handle.__type == "Slider" and handle.Value.Default or handle.Value
            if handle.__type == "Colorpicker" then
                returned = handle.Default
            end
            return call(handle.Callback, returned, ...)
        end
        local function addLeadingIcon(handle, icon, tint)
            if not icon or not handle.UIElements.Title then
                return
            end
            local title = handle.UIElements.Title
            local desc = handle.UIElements.Desc
            local frame = title.Parent
            local image = new("ImageLabel", {
            Name = "UIControlIcon",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 14, 0, title.Position.Y.Offset + 1),
            ScaleType = Enum.ScaleType.Fit,
            Parent = frame,
        })
            setIcon(image, icon, tint)
            title.Position += UDim2.fromOffset(24, 0)
            title.Size -= UDim2.fromOffset(24, 0)
            if desc then
                desc.Position += UDim2.fromOffset(24, 0)
                desc.Size -= UDim2.fromOffset(24, 0)
            end
            handle.UIElements.Icon = image
        end
        local function wrapControl(context, kind, config, native, handle)
            handle = handle or {}
            handle.__type = kind
            handle.Title = config.Title or config.Name or kind
            handle.Desc = config.Desc or config.Description or ""
            handle.Flag = config.Flag
            handle.Callback = handle.Callback or config.Callback
            handle.Locked = config.Locked == true
            handle.LockedTitle = config.LockedTitle
            handle._config = config
            handle._native = native
            handle._context = context
            handle._connections = {}
            handle._children = {}
            local frame = native._frame
            local labels = textLabels(frame)
            handle.Instance, handle.Frame, handle.Holder = frame, frame, frame
            handle.UIElements = { Main = frame, Title = native.TitleLabel or labels[1], Desc = config.Desc and labels[2] or nil, Container = frame }
            if kind == "Slider" or kind == "Input" then
                handle.UIElements.Desc = native.DescriptionLabel
                handle.UIElements.Value = native.ValueLabel or native.ValueInput
            end
            handle[kind .. "Frame"] = { UIElements = handle.UIElements }
            if kind == "Paragraph" then
                handle.UIElements.Desc = labels[2]
            end
            if kind == "Button" then
                handle.ButtonFrame = { UIElements = handle.UIElements }
            end
            setmetatable(handle, {
            __index = function(self, key)
                if key == "Picking" or key == "Listening" then
                    return native.Listening == true
                end
                if key == "Visible" then
                    return frame.Visible
                end
                return ControlMethods[key]
            end,
            __newindex = function(self, key, value)
                if key == "Visible" then
                    frame.Visible = value == true
                else
                    rawset(self, key, value)
                end
            end,
        })
            Library._controls[handle] = true
            context._children[handle] = true
            if config.Flag and context._window then
                context._window.PendingFlags[config.Flag] = handle
            end
            if native.Get then
                syncValue(handle, native:Get())
            end
            if config.Icon and kind ~= "Button" and kind ~= "Input" and kind ~= "Paragraph" then
                addLeadingIcon(handle, config.Icon, config.IconColor)
            end
            if handle.Locked then
                handle:Lock(config.LockedTitle)
            end
            return handle
        end
        local function decorateOptions(handle)
            local native = handle._native
            if not native or not native.UIOptionRows then
                return
            end
            for label, row in pairs(native.UIOptionRows) do
                local entry = handle._options[label]
                local detail = type(entry) == "table" and (entry.Desc or entry.Description) or nil
                local icon = type(entry) == "table" and entry.Icon or nil
                local value239 = icon and 36 or 12
                row.Label.RichText = true
                row.Label.Position = UDim2.fromOffset(value239, detail and 8 or -1)
                row.Label.Size = detail and UDim2.new(1, -value239 - 28, 0, 17) or UDim2.new(1, -value239 - 28, 1, 0)
                local image = row.Frame:FindFirstChild("UIOptionIcon")
                if icon then
                    image = image or new("ImageLabel", {
                    Name = "UIOptionIcon", Size = UDim2.fromOffset(16, 16),
                    BackgroundTransparency = 1, Position = UDim2.fromOffset(12, detail and 9 or 0),
                    AnchorPoint = detail and Vector2.zero or Vector2.new(0, 0.5),
                    Parent = row.Frame,
                })
                    if not detail then
                        image.Position = UDim2.new(0, 12, 0.5, 0)
                    end
                    setIcon(image, icon, Airflow.Theme.Accent)
                elseif image then
                    image:Destroy()
                end
                local description = row.Frame:FindFirstChild("UIOptionDescription")
                if detail then
                    description = description or new("TextLabel", {
                    Name = "UIOptionDescription", BackgroundTransparency = 1,
                    FontFace = Airflow.Fonts.Regular, TextColor3 = Airflow.Theme.Muted,
                    TextSize = 12, RichText = true, TextWrapped = true,
                    TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top, Parent = row.Frame,
                })
                    description.Text = tostring(detail)
                    description.Position = UDim2.fromOffset(value239, 28)
                    description.Size = UDim2.new(1, -value239 - 28, 0, 30)
                    row.Frame.Size = UDim2.new(1, 0, 0, Airflow.Touch and 64 or 60)
                    row.Check.Position = UDim2.new(1, -10, 0, 18)
                else
                    if description then
                        description:Destroy()
                    end
                    row.Frame.Size = UDim2.new(1, 0, 0, Airflow.Touch and 40 or 34)
                    row.Check.Position = UDim2.new(1, -10, 0.5, 0)
                end
            end
            native.UIReflow()
        end
        function ControlMethods:SetTitle(title)
            self.Title = tostring(title or "")
            if self._native and self._native.SetText then
                self._native:SetText(self.Title)
            end
            if self.UIElements.Title then
                self.UIElements.Title.Text = self.Title
            end
            return self
        end
        function ControlMethods:SetDesc(description)
            self.Desc = tostring(description or "")
            if self.__type == "Paragraph" and self._native then
                self._native:Set(self.Desc)
            end
            local label = self.UIElements.Desc
            if not label and self.UIElements.Title then
                local title = self.UIElements.Title
                label = new("TextLabel", {
                Name = "Description", BackgroundTransparency = 1, RichText = true,
                FontFace = Airflow.Fonts.Regular, TextColor3 = Airflow.Theme.Muted,
                TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
                Position = UDim2.new(0, title.Position.X.Offset, 0, title.Position.Y.Offset + 22),
                Size = UDim2.new(1, -80, 0, 18), Parent = title.Parent,
            })
                self.UIElements.Desc = label
                self.Frame.Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, math.max(self.Frame.Size.Y.Offset, 64))
            end
            if label then
                label.Text = self.Desc
            end
            return self
        end
        function ControlMethods:SetIcon(icon)
            if self.UIElements.Icon then
                setIcon(self.UIElements.Icon, icon, self._config.IconColor)
            else
                addLeadingIcon(self, icon, self._config.IconColor)
            end
            self._config.Icon = icon
            return self
        end
        function ControlMethods:Get()
            if self.__type == "Slider" then
                return self.Value.Default
            end
            if self.__type == "Colorpicker" then
                return self.Default
            end
            if self.__type == "Input" and self._native then
                syncValue(self, self._native:Get())
            end
            return self.Value
        end
        function ControlMethods:Set(value, skipCallback)
            if self._destroyed or not self._native then
                return self
            end
            if self.__type == "Dropdown" and self.Flag == "Tema" then
                local name = type(value) == "table" and value.Title or value
                if not Library:GetThemes()[name] then
                    value = Library:GetCurrentTheme()
                end
            end
            local target = value
            if self.__type == "Dropdown" then
                target = toNativeSelection(self, value)
            end
            if self.__type == "Keybind" then
                target = typeof(value) == "EnumItem" and value or Enum.KeyCode[tostring(value)] or Enum.KeyCode.Unknown
                self._native:Set(target, true)
            elseif self.__type == "Paragraph" then
                return self:SetDesc(value)
            elseif self._native.Set then
                self._native:Set(target, skipCallback == true)
            end
            if self._native.Get then
                syncValue(self, self._native:Get())
            end
            if self._textBox then
                self._textBox.Text = tostring(value or "")
            end
            return self
        end
        ControlMethods.SetValue = ControlMethods.Set
        ControlMethods.Select = ControlMethods.Set
        function ControlMethods:Update(value, transparency)
            self.Transparency = transparency or self.Transparency
            return self:Set(value)
        end
        function ControlMethods:SetVisible(visible)
            if not self._destroyed then
                self.Frame.Visible = visible == true
            end
            return self
        end
        function ControlMethods:Lock(title)
            if self._destroyed then
                return self
            end
            self.Locked = true
            if self._native then
                self._native.Listening = false
            end
            if not self._lockOverlay then
                local overlay = new("TextButton", {
                Name = "Locked", Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Airflow.Theme.Background, BackgroundTransparency = 0.18,
                Text = "", AutoButtonColor = false, ZIndex = 80, Parent = self.UIElements.Header or self.Frame,
            })
                new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = overlay })
                self._lockOverlay = overlay
            end
            self._lockOverlay.Text = title or self.LockedTitle or ""
            self._lockOverlay.FontFace = Airflow.Fonts.Medium
            self._lockOverlay.TextSize = 12
            self._lockOverlay.TextColor3 = Airflow.Theme.Muted
            self._lockOverlay.Visible = true
            return self
        end
        function ControlMethods:Unlock()
            self.Locked = false
            if self._lockOverlay then
                self._lockOverlay.Visible = false
            end
            return self
        end
        function ControlMethods:Destroy()
            if self._destroyed then
                return
            end
            self._destroyed = true
            Library._controls[self] = nil
            if self._context then
                self._context._children[self] = nil
            end
            local window = self._context and self._context._window
            if window and self.Flag and window.PendingFlags[self.Flag] == self then
                window.PendingFlags[self.Flag] = nil
            end
            local children = {}
            for child in pairs(self._children or {}) do
                children[#children + 1] = child
            end
            for _, child in ipairs(children) do
                child:Destroy()
            end
            for _, connections in pairs(self._childConnections or {}) do
                for _, connection in ipairs(connections) do
                    disconnect(connection)
                end
            end
            self._childConnections = nil
            for _, connection in ipairs(self._connections or {}) do
                disconnect(connection)
            end
            self._connections = {}
            if self._native and self._native.Destroy then
                self._native:Destroy()
            elseif self.Frame then
                self.Frame:Destroy()
            end
            self.Callback = nil
            self._native = nil
            self._context = nil
        end
        ControlMethods.Delete = ControlMethods.Destroy
        ControlMethods.Remove = ControlMethods.Destroy
        ControlMethods.Clear = ControlMethods.Destroy
        local function provider(context, list)
            return setmetatable({ List = list, Window = context._provider.Window, _order = 0 }, getmetatable(context._provider))
        end
        local function context(parent, nativeProvider, frame)
            local result = {
            _provider = nativeProvider,
            _window = parent._window or parent,
            _context = parent,
            _children = {},
            _connections = {},
            Frame = frame or nativeProvider.List,
            Instance = frame or nativeProvider.List,
            Holder = frame or nativeProvider.List,
            Locked = false,
        }
            result.UIElements = { Main = result.Frame, Container = nativeProvider.List }
            parent._children[result] = true
            return setmetatable(result, {
            __index = function(self, key)
                if key == "Visible" then
                    return self.Frame.Visible
                end
                return ContainerMethods[key] or ControlMethods[key]
            end,
            __newindex = function(self, key, value)
                if key == "Visible" then
                    self.Frame.Visible = value == true
                else
                    rawset(self, key, value)
                end
            end,
        })
        end
        local function basic(context, kind, config)
            config = type(config) == "table" and config or { Title = tostring(config or "") }
            assert(not Library._destroyed, "Airflow window has been destroyed")
            if kind == "Dropdown" and config.Flag == "Tema" and config.Value == nil then
                config = table.clone(config)
                config.Value = Library:GetCurrentTheme()
            end
            if kind == "Keybind" and config.Flag == "KeybindUI" and context._window._onToggleKeyChanged then
                config = table.clone(config)
                config.Value = (context._window._toggleKey or Enum.KeyCode.Z).Name
            end
            local handle = { Callback = config.Callback, __type = kind, Locked = config.Locked == true, _context = context }
            if kind == "Slider" then
                local range = type(config.Value) == "table" and config.Value or {}
                handle.Value = { Min = range.Min or 0, Max = range.Max or 100, Default = range.Default or range.Min or 0 }
            elseif kind == "Dropdown" then
                handle.Multi = config.Multi == true
                handle.AllowNone = config.AllowNone ~= false
                handle.Values = config.Values or {}
                local _, originals = normalizeOptions(handle.Values)
                handle._options = originals
                handle.Value = config.Value
            elseif kind == "Colorpicker" then
                handle.Default = config.Default or Color3.new(1, 1, 1)
            else
                handle.Value = config.Value
            end
            local opts = {
            Name = config.DisplayTitle or config.Title or config.Name or kind,
            Desc = config.DisplayDesc or config.Desc,
            Flag = config.Flag,
            Callback = function(value, ...)
                return dispatch(handle, value, ...)
            end,
        }
            local native
            if kind == "Button" then
                opts.Icon = config.Icon
                opts.Style = config.Style == "Primary" and "Primary" or "Action"
                opts.Color = config.Color
                opts.Danger = config.Style == "Danger"
                opts.Callback = function()
                    if not handle._destroyed and not isLocked(handle) then
                        return call(handle.Callback)
                    end
                end
                native = context._provider:CreateButton(opts)
            elseif kind == "Toggle" then
                opts.CurrentValue = config.Value == true
                native = context._provider:CreateToggle(opts)
            elseif kind == "Slider" then
                opts.Range = { handle.Value.Min, handle.Value.Max }
                opts.CurrentValue = handle.Value.Default
                opts.Increment = config.Step or 1
                native = context._provider:CreateSlider(opts)
            elseif kind == "Dropdown" then
                opts.Options = normalizeOptions(handle.Values)
                opts.CurrentOption = toNativeSelection(handle, config.Value)
                opts.MultipleOptions = handle.Multi
                opts.SearchAfter = config.SearchBarEnabled and 0 or 6
                native = context._provider:CreateDropdown(opts)
            elseif kind == "Input" then
                opts.Icon = config.InputIcon or config.Icon
                opts.PlaceholderText = config.DisplayPlaceholder or config.Placeholder or ""
                opts.CurrentValue = tostring(config.Value or "")
                native = context._provider:CreateInput(opts)
            elseif kind == "Keybind" then
                opts.CurrentKeybind = config.Value or "Unknown"
                opts.OnChanged = function(value)
                    return dispatch(handle, value)
                end
                opts.Callback = config.FireOnBind == false and function(value)
                    return dispatch(handle, value)
                end or nil
                native = context._provider:CreateKeybind(opts)
            elseif kind == "Colorpicker" then
                opts.CurrentValue = handle.Default
                native = context._provider:CreateColorPicker(opts)
            elseif kind == "Paragraph" then
                opts.Content = config.Desc or config.Content or ""
                native = context._provider:CreateParagraph(opts)
            elseif kind == "Label" then
                native = context._provider:CreateLabel({ Text = config.Title or config.Text or "", Color = config.Color })
            else
                error("Unsupported Airflow component: " .. kind)
            end
            handle = wrapControl(context, kind, config, native, handle)
            if kind == "Dropdown" then
                decorateOptions(handle)
            elseif kind == "Button" then
                if config.Color then
                    native._frame.BackgroundColor3 = config.Color
                end
                if config.Style == "Danger" and handle.UIElements.Title then
                    handle.UIElements.Title.TextColor3 = Airflow.Theme.Error
                end
                if config.Justify == "Center" and handle.UIElements.Title then
                    handle.UIElements.Title.TextXAlignment = Enum.TextXAlignment.Center
                end
            elseif kind == "Toggle" and config.Type == "Checkbox" then
                for _, child in ipairs(native._frame:GetChildren()) do
                    if child:IsA("Frame") and child.AnchorPoint.X == 1 then
                        child.Visible = false
                    end
                end
                local box = new("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0),
                Size = UDim2.fromOffset(22, 22), BorderSizePixel = 0, Parent = native._frame,
            })
                new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
                new("UIStroke", { Color = Airflow.Theme.Stroke, Parent = box })
                local mark = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = box })
                setIcon(mark, "check", Airflow.Theme.AccentDark)
                handle._checkbox, handle._checkmark = box, mark
                syncValue(handle, native:Get())
            elseif kind == "Input" then
                local box = findTextBox(native._frame)
                handle._textBox = box
                handle.UIElements.Input = box
                if box and config.Type == "Textarea" then
                    local holder = box.Parent
                    native._frame:SetAttribute("UIMultiline", true)
                    native._frame.Size = UDim2.new(1, 0, 0, 170)
                    holder.AnchorPoint = Vector2.zero
                    holder.Position = UDim2.fromOffset(14, config.Desc and 65 or 42)
                    holder.Size = UDim2.new(1, -28, 1, config.Desc and -79 or -56)
                    box.AnchorPoint = Vector2.zero
                    box.Size = UDim2.new(1, -16, 1, -12)
                    box.Position = UDim2.fromOffset(8, 6)
                    box.MultiLine = true
                    box.TextWrapped = true
                    box.TextYAlignment = Enum.TextYAlignment.Top
                    box.TextXAlignment = Enum.TextXAlignment.Left
                    if handle.UIElements.Title then
                        handle.UIElements.Title.Position = UDim2.fromOffset(14, 12);
                        handle.UIElements.Title.Size = UDim2.new(1, -28, 0, 18)
                    end
                    if handle.UIElements.Desc then
                        handle.UIElements.Desc.Position = UDim2.fromOffset(14, 34);
                        handle.UIElements.Desc.Size = UDim2.new(1, -28, 0, 20)
                    end
                end
            end
            if (config.DisplayTitle or config.DisplayDesc) and kind ~= "Paragraph" then
                local title, description = handle.UIElements.Title, handle.UIElements.Desc
                local baseHeight = handle.Frame.Size.Y.Offset
                local titleHeight = title and title.Size.Y.Offset or 0
                local descriptionHeight = description and description.Size.Y.Offset or 0
                local descriptionPosition = description and description.Position
                local labels = {}
                if title then
                    labels[#labels + 1] = title
                end
                if description then
                    labels[#labels + 1] = description
                end
                for _, label in ipairs(labels) do
                    label.TextWrapped = true;
                    label.TextTruncate = Enum.TextTruncate.None
                end
                local scheduled = false
                local function resizeLabels()
                    if scheduled or handle._destroyed then
                        return
                    end
                    scheduled = true
                    task.defer(function()
                        scheduled = false
                        if handle._destroyed then
                            return
                        end
                        local extraTitle = title and math.max(0, title.TextBounds.Y + 2 - titleHeight) or 0
                        local extraDescription = description and math.max(0, description.TextBounds.Y + 2 - descriptionHeight) or 0
                        if title then
                            title.Size = UDim2.new(title.Size.X.Scale, title.Size.X.Offset, 0, titleHeight + extraTitle)
                        end
                        if description then
                            description.Position = descriptionPosition + UDim2.fromOffset(0, extraTitle)
                            description.Size = UDim2.new(description.Size.X.Scale, description.Size.X.Offset, 0, descriptionHeight + extraDescription)
                        end
                        local size = UDim2.new(handle.Frame.Size.X.Scale, handle.Frame.Size.X.Offset, 0, baseHeight + extraTitle + extraDescription)
                        if not (kind == "Dropdown" and handle._native.Open) and handle.Frame.Size ~= size then
                            handle.Frame.Size = size
                        end
                    end)
                end
                for _, label in ipairs(labels) do
                    handle._connections[#handle._connections + 1] = connect(label:GetPropertyChangedSignal("TextBounds"), resizeLabels)
                end
                handle._connections[#handle._connections + 1] = connect(handle.Frame:GetPropertyChangedSignal("AbsoluteSize"), resizeLabels)
                resizeLabels()
            end
            return handle
        end
        for _, kind in ipairs({ "Button", "Toggle", "Slider", "Dropdown", "Input", "Keybind", "Colorpicker", "Paragraph", "Label" }) do
            ContainerMethods[kind] = function(self, config)
                return basic(self, kind, config)
            end
        end
        ContainerMethods.ColorPicker = ContainerMethods.Colorpicker
        function ControlMethods:Refresh(values, keepSelection)
            assert(self.__type == "Dropdown", "Refresh is only available for dropdowns")
            self.Values = values or {}
            local labels, originals = normalizeOptions(self.Values)
            self._options = originals
            if self._native then
                self._native:Refresh(labels, keepSelection ~= false)
                syncValue(self, self._native:Get())
                decorateOptions(self)
            end
            return self
        end
        function ControlMethods:SetOpen(opened)
            if self._native and self._native.SetOpen then
                self._native:SetOpen(opened)
            end
            return self
        end
        local function makeStack(parent, horizontal, rowConfig)
            local frame = new("Frame", {
            Name = horizontal and "HStack" or "VStack", Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = horizontal and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = parent._provider:_nextOrder(), Parent = parent._provider.List,
        })
            local layout = new("UIListLayout", {
            FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = frame,
        })
            local stack = context(parent, provider(parent, frame), frame)
            stack.__type = horizontal and "HStack" or "VStack"
            stack._connections = {}
            if horizontal then
                stack._childConnections = {}
                local scheduled = false
                local function arrange()
                    if scheduled or stack._destroyed then
                        return
                    end
                    scheduled = true
                    task.defer(function()
                        scheduled = false
                        if stack._destroyed then
                            return
                        end
                        local children, height = {}, 0
                        for _, child in ipairs(frame:GetChildren()) do
                            if child:IsA("GuiObject") and child.Visible then
                                children[#children + 1] = child
                            end
                        end
                        local columns = not rowConfig or frame.AbsoluteSize.X / math.max(parent._provider.Window.Scale.Scale, 0.01)
                        >= (#children * (rowConfig.MinColumnWidth or 210) + 8 * math.max(0, #children - 1))
                        layout.FillDirection = columns and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
                        for _, child in ipairs(children) do
                            local size = columns and UDim2.new(1 / #children, -8 * (#children - 1) / #children, 0, child.Size.Y.Offset)
                            or UDim2.new(1, 0, 0, child.Size.Y.Offset)
                            if child.Size ~= size then
                                child.Size = size
                            end
                            local childHeight = math.max(child.Size.Y.Offset, child.AbsoluteSize.Y / math.max(parent._provider.Window.Scale.Scale, 0.01))
                            height = columns and math.max(height, childHeight) or height + childHeight
                        end
                        if not columns then
                            height += 8 * math.max(0, #children - 1)
                        end
                        local size = UDim2.new(1, 0, 0, height)
                        if frame.Size ~= size then
                            frame.Size = size
                        end
                    end)
                end
                local function watchChild(child)
                    if not stack._destroyed and child:IsA("GuiObject") and not stack._childConnections[child] then
                        stack._childConnections[child] = {
                        connect(child:GetPropertyChangedSignal("Size"), arrange),
                        connect(child:GetPropertyChangedSignal("Visible"), arrange),
                    }
                    end
                    arrange()
                end
                stack._connections[#stack._connections + 1] = connect(frame.ChildAdded, watchChild)
                stack._connections[#stack._connections + 1] = connect(frame.ChildRemoved, function(child)
                    local connections = stack._childConnections and stack._childConnections[child]
                    if connections then
                        for _, connection in ipairs(connections) do
                            disconnect(connection)
                        end
                        stack._childConnections[child] = nil
                    end
                    arrange()
                end)
                for _, child in ipairs(frame:GetChildren()) do
                    watchChild(child)
                end
                if rowConfig then
                    stack._connections[#stack._connections + 1] = connect(frame:GetPropertyChangedSignal("AbsoluteSize"), arrange)
                end
                arrange()
            end
            return stack
        end
        function ContainerMethods:HStack()
            return makeStack(self, true)
        end
        function ContainerMethods:VStack()
            return makeStack(self, false)
        end
        function ContainerMethods:FormRow(config)
            return makeStack(self, true, config or {})
        end
        function ContainerMethods:Group(config)
            config = config or {}
            local frame = new("Frame", {
            Name = "ControlGroup", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = self._provider:_nextOrder(), Parent = self._provider.List,
        })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = frame })
            local header = new("TextLabel", {
            Name = "Title", Text = config.Title or "", FontFace = Airflow.Fonts.Bold, TextSize = 14,
            TextColor3 = Airflow.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 1, Parent = frame,
        })
            if config.Desc then
                new("TextLabel", {
            Name = "Description", Text = config.Desc, FontFace = Airflow.Fonts.Regular, TextSize = 12,
            TextColor3 = Airflow.Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 2, Parent = frame,
        })
            end
            local list = new("Frame", { Name = "Controls", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 3, Parent = frame })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = list })
            local group = context(self, provider(self, list), frame)
            group.__type = "Group"
            group.UIElements.Title, group.UIElements.Container = header, list
            return group
        end
        function ContainerMethods:Space(size)
            local frame = new("Frame", { Size = UDim2.new(1, 0, 0, tonumber(size) or 8), BackgroundTransparency = 1, LayoutOrder = self._provider:_nextOrder(), Parent = self._provider.List })
            return wrapControl(self, "Space", {}, { _frame = frame })
        end
        function ContainerMethods:Divider()
            return wrapControl(self, "Divider", {}, self._provider:CreateDivider())
        end
        function ContainerMethods:Section(config)
            config = type(config) == "table" and config or { Title = tostring(config or "") }
            local frame = new("Frame", {
            Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = self._provider:_nextOrder(), Parent = self._provider.List,
        })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = frame })
            local list = new("Frame", { Name = "Controls", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Visible = config.Opened == true, Parent = frame })
            new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 12), Parent = list })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = list })
            local section = context(self, provider(self, list), frame)
            section.__type = "Section"
            section.Title, section.Desc = config.Title or "Section", config.Desc or ""
            section.Opened = config.Opened == true
            section.Locked = config.Locked == true
            section.LockedTitle = config.LockedTitle
            section._connections = {}
            local headerProvider = provider(self, frame)
            local header = headerProvider:CreateButton({
            Name = section.Title, Desc = config.Desc, Icon = config.Icon, Style = "Section",
            Callback = function()
                if not section._destroyed and not isLocked(section) then
                    section:SetOpened(not section.Opened)
                end
            end,
        })
            header._frame.LayoutOrder = 1
            section._header = header
            local labels = textLabels(header._frame)
            section.UIElements.Title, section.UIElements.Desc = labels[1], config.Desc and labels[2] or nil
            section.UIElements.Header, section.UIElements.Container = header._frame, list
            section._native = { Destroy = function()
                header:Destroy();
                frame:Destroy()
            end }
            local arrow
            for _, child in ipairs(header._frame:GetChildren()) do
                if child:IsA("Frame") and child.Position.X.Scale == 1 then
                    arrow = child:FindFirstChildWhichIsA("ImageLabel")
                end
            end
            function section:SetOpened(opened)
                self.Opened = opened == true
                list.Visible = self.Opened
                if arrow then
                    arrow.Rotation = self.Opened and 90 or 0
                end
                return self
            end
            section.Open = function(self)
                return self:SetOpened(true)
            end
            section.Close = function(self)
                return self:SetOpened(false)
            end
            section.SetOpen = section.SetOpened
            section:SetOpened(section.Opened)
            if section.Locked then
                section:Lock(config.LockedTitle)
            end
            return section
        end
        function ContainerMethods:Code(config)
            config = type(config) == "table" and config or { Code = tostring(config or "") }
            local frame = new("Frame", {
            Name = "Code", Size = UDim2.new(1, 0, 0, 190), BackgroundColor3 = Airflow.Theme.Surface2,
            BorderSizePixel = 0, LayoutOrder = self._provider:_nextOrder(), Parent = self._provider.List,
        })
            frame:SetAttribute("NoDrag", true)
            new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = frame })
            new("UIStroke", { Color = Airflow.Theme.Stroke, Parent = frame })
            local scroll = new("ScrollingFrame", {
            Size = UDim2.new(1, -24, 1, -48), Position = UDim2.fromOffset(12, 36),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = Airflow.Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.XY,
            CanvasSize = UDim2.new(), Parent = frame,
        })
            local box = new("TextBox", {
            Text = tostring(config.Code or ""), RichText = false, MultiLine = true, TextEditable = false,
            ClearTextOnFocus = false, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.fromOffset(0, 0), FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
            TextSize = 12, TextColor3 = Airflow.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, Parent = scroll,
        })
            local copy = new("TextButton", {
            Text = "Copiar código", Size = UDim2.fromOffset(104, 25), Position = UDim2.fromOffset(12, 6),
            BackgroundColor3 = Airflow.Theme.Surface, TextColor3 = Airflow.Theme.Text,
            FontFace = Airflow.Fonts.Medium, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false, Parent = frame,
        })
            new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = copy })
            local handle = wrapControl(self, "Code", config, { _frame = frame })
            handle.Code = tostring(config.Code or "")
            function handle:SetCode(value)
                self.Code = tostring(value or "");
                box.Text = self.Code;
                return self
            end
            handle.Set = handle.SetCode
            handle._connections[#handle._connections + 1] = connect(copy.Activated, function()
                if type(setclipboard) == "function" then
                    setclipboard(handle.Code)
                end
            end)
            return handle
        end
        local createParagraph = ContainerMethods.Paragraph
        function ContainerMethods:Paragraph(config)
            config = type(config) == "table" and config or { Desc = tostring(config or "") }
            local handle = createParagraph(self, config)
            local frame = handle.Frame
            if config.Color then
                frame.BackgroundColor3 = config.Color
            end
            if config.Image then
                local title, desc = handle.UIElements.Title, handle.UIElements.Desc
                local imageSize = typeof(config.ImageSize) == "UDim2" and config.ImageSize or UDim2.fromOffset(28, 28)
                local width = imageSize.X.Offset > 0 and imageSize.X.Offset or 28
                local group = new("Frame", { Name = "ParagraphContent", Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = 1, Parent = frame })
                local content = new("Frame", { Name = "TitleFrame", Position = UDim2.fromOffset(width + 12, 0), Size = UDim2.new(1, -width - 12, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = group })
                new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = content })
                title.Parent = content
                if desc then
                    desc.Parent = content
                end
                local image = new("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Size = imageSize, ScaleType = Enum.ScaleType.Fit, Parent = group })
                setIcon(image, config.Image, Airflow.Theme.Accent)
                local function resize()
                    if handle._destroyed then
                        return
                    end
                    group.Size = UDim2.new(1, 0, 0, math.max(imageSize.Y.Offset, content.AbsoluteSize.Y))
                end
                handle._connections[#handle._connections + 1] = connect(content:GetPropertyChangedSignal("AbsoluteSize"), resize)
                task.defer(resize)
                handle.UIElements.Icon, handle.UIElements.Container = image, group
            end
            if type(config.Buttons) == "table" and #config.Buttons > 0 then
                local paragraphContext = context(self, provider(self, frame), frame)
                self._children[paragraphContext] = nil
                paragraphContext._context = handle
                handle._children[paragraphContext] = true
                local row = paragraphContext:HStack()
                row.Frame.LayoutOrder = 3
                for _, button in ipairs(config.Buttons) do
                    row:Button(button)
                end
            end
            return handle
        end
        local function ensureFolder(path)
            if type(makefolder) ~= "function" then
                return
            end
            local current = ""
            for part in tostring(path):gmatch("[^/\\]+") do
                current = current == "" and part or current .. "/" .. part
                if type(isfolder) ~= "function" or not isfolder(current) then
                    pcall(makefolder, current)
                end
            end
        end
        local function createConfigManager(window, folder)
            local manager = { Folder = folder, Path = "WindUI/" .. tostring(folder) .. "/config/", Configs = {} }
            local function read(path)
                if type(readfile) ~= "function" or (type(isfile) == "function" and not isfile(path)) then
                    return nil
                end
                local success, data = pcall(function()
                    return Http:JSONDecode(readfile(path))
                end)
                return success and type(data) == "table" and data or nil
            end
            local function save(path, data)
                assert(type(writefile) == "function", "Este executor não oferece gravação de arquivos")
                ensureFolder(manager.Path)
                writefile(path, Http:JSONEncode(data))
            end
            local function serialize(control)
                local value = control:Get()
                if control.__type == "Colorpicker" and typeof(value) == "Color3" then
                    value = value:ToHex()
                end
                return { __type = control.__type, value = value, transparency = control.Transparency }
            end
            function manager:SetPath(path)
                self.Path = tostring(path):gsub("[/\\]+$", "") .. "/"
                ensureFolder(self.Path)
                return true
            end
            function manager:AllConfigs()
                local result = {}
                if type(listfiles) ~= "function" then
                    return result
                end
                if type(isfolder) == "function" and not isfolder(self.Path) then
                    ensureFolder(self.Path);
                    return result
                end
                local success, files = pcall(listfiles, self.Path)
                if not success then
                    return result
                end
                for _, filename in ipairs(files) do
                    local name = filename:match("([^/\\]+)%.json$")
                    if name then
                        result[#result + 1] = name
                    end
                end
                table.sort(result)
                return result
            end
            function manager:CreateConfig(name, autoLoad)
                assert(type(name) == "string" and name ~= "" and not name:find("[/\\]"), "Nome de configuração inválido")
                local cached = self.Configs[name]
                if cached then
                    return cached
                end
                local config = { Path = self.Path .. name .. ".json", Elements = {}, CustomData = {}, AutoLoad = autoLoad == true, Version = 1.2 }
                local saved = read(config.Path)
                if saved then
                    config.AutoLoad = saved.__autoload == true;
                    config.CustomData = saved.__custom or {}
                end
                function config:Register(flag, control)
                    self.Elements[flag] = control
                end
                function config:Set(key, value)
                    self.CustomData[key] = value
                end
                function config:Get(key)
                    return self.CustomData[key]
                end
                function config:SetAsCurrent()
                    window.CurrentConfig = self
                end
                function config:GetData()
                    return { elements = self.Elements, custom = self.CustomData, autoload = self.AutoLoad }
                end
                function config:SetAutoLoad(enabled)
                    if enabled then
                        for _, otherName in ipairs(manager:AllConfigs()) do
                            local path = manager.Path .. otherName .. ".json"
                            local other = read(path)
                            if other and other.__autoload then
                                other.__autoload = false;
                                save(path, other)
                            end
                            if manager.Configs[otherName] then
                                manager.Configs[otherName].AutoLoad = false
                            end
                        end
                    end
                    self.AutoLoad = enabled == true
                    local data = read(self.Path)
                    if data then
                        data.__autoload = self.AutoLoad;
                        save(self.Path, data)
                    end
                end
                function config:Save()
                    local old = read(self.Path) or {}
                    local data = {
                    __version = self.Version, __elements = old.__elements or {},
                    __autoload = self.AutoLoad, __custom = self.CustomData,
                }
                    for flag, control in pairs(window.PendingFlags) do
                        self:Register(flag, control)
                    end
                    for flag, control in pairs(self.Elements) do
                        if not control._destroyed then
                            data.__elements[flag] = serialize(control)
                        end
                    end
                    save(self.Path, data)
                    return data
                end
                function config:Load(skipCallbacks)
                    local data = read(self.Path)
                    if not data then
                        return false, "Configuração ausente ou JSON inválido"
                    end
                    for flag, control in pairs(window.PendingFlags) do
                        self:Register(flag, control)
                    end
                    local elements = data.__elements or data
                    for flag, record in pairs(elements) do
                        local control = self.Elements[flag]
                        if control and not control._destroyed and type(record) == "table" then
                            local value = record.value
                            if control.__type == "Colorpicker" and type(value) == "string" then
                                value = Color3.fromHex(value)
                            end
                            control:Set(value, skipCallbacks == true)
                            if not skipCallbacks and (control.__type == "Input" or control.__type == "Keybind") then
                                call(control.Callback, control:Get())
                            end
                            control.Transparency = record.transparency
                        end
                    end
                    self.CustomData = data.__custom or {}
                    return self.CustomData
                end
                function config:Delete()
                    if type(delfile) ~= "function" then
                        return false, "Este executor não permite apagar arquivos"
                    end
                    local success, message = pcall(delfile, self.Path)
                    if not success then
                        return false, tostring(message)
                    end
                    manager.Configs[name] = nil
                    if window.CurrentConfig == self then
                        window.CurrentConfig = nil
                    end
                    return true
                end
                self.Configs[name] = config
                config:SetAsCurrent()
                return config
            end
            function manager:Config(...)
                return self:CreateConfig(...)
            end
            function manager:GetConfig(name)
                return self.Configs[name]
            end
            function manager:DeleteConfig(name)
                return self:CreateConfig(name):Delete()
            end
            function manager:GetAutoLoadConfigs()
                local result = {}
                for _, name in ipairs(self:AllConfigs()) do
                    local data = read(self.Path .. name .. ".json")
                    if data and data.__autoload then
                        result[#result + 1] = name
                    end
                end
                return result
            end
            function manager:Setup()
                for _, name in ipairs(self:AllConfigs()) do
                    self:CreateConfig(name)
                end
                return self
            end
            ensureFolder(manager.Path)
            return manager
        end
        function Library:Gradient(stops, extra)
            local colors, transparencies = {}, {}
            for position, value in pairs(stops or {}) do
                local time = math.clamp(tonumber(position) / 100, 0, 1)
                local hex = type(value) == "table" and (value.Color or value[1]) or value
                local opacity = type(value) == "table" and (value.Transparency or value[2]) or 0
                colors[#colors + 1] = ColorSequenceKeypoint.new(time, typeof(hex) == "Color3" and hex or Color3.fromHex(hex))
                transparencies[#transparencies + 1] = NumberSequenceKeypoint.new(time, opacity or 0)
            end
            table.sort(colors, function(configuration139, argument65)
                return configuration139.Time < argument65.Time
            end)
            table.sort(transparencies, function(configuration140, argument66)
                return configuration140.Time < argument66.Time
            end)
            if #colors == 1 then
                colors[#colors + 1] = ColorSequenceKeypoint.new(1, colors[1].Value)
                transparencies[#transparencies + 1] = NumberSequenceKeypoint.new(1, transparencies[1].Value)
            end
            local gradient = { Color = ColorSequence.new(colors), Transparency = NumberSequence.new(transparencies) }
            for key, value in pairs(extra or {}) do
                gradient[key] = value
            end
            return gradient
        end
        Library.Themes = ThemeFactory(Library)
        local function nativeTheme(theme)
            local current = Airflow.Theme
            return {
            Background = color(theme.Background, current.Background),
            Surface = color(theme.Surface or theme.Dialog or theme.Button, current.Surface),
            Surface2 = color(theme.Surface2 or theme.ElementBackground or theme.Button, current.Surface2),
            Surface3 = color(theme.Surface3 or theme.Hover or theme.Button, current.Surface3),
            Stroke = color(theme.Stroke or theme.Outline, current.Stroke),
            StrokeHover = color(theme.StrokeHover or theme.Primary or theme.Accent, current.StrokeHover),
            Accent = color(theme.Accent, current.Accent),
            AccentDark = color(theme.AccentDark or theme.Black, Color3.fromRGB(8, 8, 8)),
            Text = color(theme.Text, current.Text),
            Muted = color(theme.Muted or theme.Placeholder or theme.Icon, current.Muted),
            Glow = color(theme.Glow, current.Glow or current.Accent),
            Success = color(theme.Success, current.Success),
            Warning = color(theme.Warning, current.Warning),
            Error = color(theme.Danger or theme.Error, current.Error),
        }
        end
        function Library:AddTheme(theme)
            assert(type(theme) == "table" and type(theme.Name) == "string", "Tema inválido")
            self.Themes[theme.Name] = theme
            return theme
        end
        function Library:GetThemes()
            return self.Themes
        end
        function Library:GetCurrentTheme()
            return self.Theme and self.Theme.Name
        end
        local backgroundProperties = { "BackgroundColor3" }
        local themeProperties = {
        UIStroke = { "Color" },
        TextLabel = { "BackgroundColor3", "TextColor3" },
        TextButton = { "BackgroundColor3", "TextColor3" },
        TextBox = { "BackgroundColor3", "TextColor3", "PlaceholderColor3" },
        ImageLabel = { "BackgroundColor3", "ImageColor3" },
        ImageButton = { "BackgroundColor3", "ImageColor3" },
    }
        function Library:SetTheme(name)
            if name == "Airflow" then
                name = "Default"
            end
            if name == "Monokai Pro" then
                name = "Mono"
            end
            local theme = type(name) == "table" and name or self.Themes[name]
            if not theme then
                return false
            end
            local old = table.clone(Airflow.Theme)
            local nextTheme = nativeTheme(theme)
            local background = type(theme.Background) == "table" and theme.Background or nil
            local gradientColor = background and background.Color or nil
            local gradientTransparency = gradientColor and background.Transparency or nil
            local gradientRotation = gradientColor and (background.Rotation or 0) or nil
            local samePalette = true
            for role, value in pairs(nextTheme) do
                if old[role] ~= value then
                    samePalette = false;
                    break
                end
            end
            if samePalette and Airflow.ThemeName == theme.Name
            and self._themeGradientColor == gradientColor
            and self._themeGradientTransparency == gradientTransparency
            and self._themeGradientRotation == gradientRotation then
                self.Theme = theme
                return theme
            end
            local replacements = {}
            for role, previous in pairs(old) do
                local reds = replacements[previous.R]
                if not reds then
                    reds = {};
                    replacements[previous.R] = reds
                end
                local greens = reds[previous.G]
                if not greens then
                    greens = {};
                    reds[previous.G] = greens
                end
                if greens[previous.B] == nil then
                    greens[previous.B] = nextTheme[role]
                end
            end
            for key, value in pairs(nextTheme) do
                Airflow.Theme[key] = value
            end
            self.Theme = theme
            Airflow.ThemeName = theme.Name
            if self.ScreenGui then
                for _, object in ipairs(self.ScreenGui:GetDescendants()) do
                    local properties = themeProperties[object.ClassName]
                    if not properties and object:IsA("GuiObject") then
                        properties = backgroundProperties
                    end
                    if properties then
                        for _, property in ipairs(properties) do
                            if property ~= "ImageColor3" or not object:GetAttribute("UIUnthemed") then
                                local value = object[property]
                                if typeof(value) == "Color3" then
                                    local reds = replacements[value.R]
                                    local greens = reds and reds[value.G]
                                    local replacement = greens and greens[value.B]
                                    if replacement and replacement ~= value then
                                        object[property] = replacement
                                    end
                                end
                            end
                        end
                    end
                end
                local window = self.Window
                if window and window._native then
                    local function refreshActions(context)
                        local native = context._header or context._native
                        if native and native.RefreshStyle and not native._destroyed then
                            native:RefreshStyle()
                        end
                        for child in pairs(context._children or {}) do
                            refreshActions(child)
                        end
                    end
                    refreshActions(window)
                    local body = window._native.Body
                    local gradient = body:FindFirstChild("UIThemeGradient")
                    if type(theme.Background) == "table" and theme.Background.Color then
                        gradient = gradient or new("UIGradient", { Name = "UIThemeGradient", Parent = body })
                        gradient.Color = theme.Background.Color
                        gradient.Transparency = theme.Background.Transparency or NumberSequence.new(0)
                        gradient.Rotation = theme.Background.Rotation or 0
                        body.BackgroundColor3 = Color3.new(1, 1, 1)
                    elseif gradient then
                        gradient:Destroy()
                        body.BackgroundColor3 = Airflow.Theme.Background
                    end
                end
            end
            self._themeGradientColor = gradientColor
            self._themeGradientTransparency = gradientTransparency
            self._themeGradientRotation = gradientRotation
            return theme
        end
        function Library:SetFont(family)
            if type(family) ~= "string" then
                return false
            end
            local success = pcall(function()
                Airflow.Fonts.Regular = Font.new(family, Enum.FontWeight.Regular)
                Airflow.Fonts.Medium = Font.new(family, Enum.FontWeight.Medium)
                Airflow.Fonts.Bold = Font.new(family, Enum.FontWeight.Bold)
            end)
            return success
        end
        function Library:SetParent(parent)
            assert(typeof(parent) == "Instance", "SetParent espera uma Instance")
            self._parent = parent
            if self.ScreenGui then
                self.ScreenGui.Parent = parent
            end
            return true
        end
        function Library:GetParent()
            return self.ScreenGui and self.ScreenGui.Parent or self._parent
        end
        function Library:SetNotificationLower(lower)
            self._notificationsLower = lower ~= false
            if self.Window then
                local holder = self.Window._native.NotifyHolder
                holder.AnchorPoint = Vector2.new(1, self._notificationsLower and 1 or 0)
                holder.Position = UDim2.new(1, -20, self._notificationsLower and 1 or 0, self._notificationsLower and -20 or 20)
                local layout = holder:FindFirstChildOfClass("UIListLayout")
                if layout then
                    layout.VerticalAlignment = self._notificationsLower and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
                end
            end
        end
        function Library:Notify(config)
            if self.Window and not self._destroyed then
                local result = self.Window._native:Notify(config)
                textLabels(self.ScreenGui)
                return result
            end
            self._pendingNotifications = self._pendingNotifications or {}
            self._pendingNotifications[#self._pendingNotifications + 1] = config
        end
        Library.Creator = {
        New = new,
        Icons = {
            Image = function(config)
            local frame = new("Frame", { Size = config.Size or UDim2.fromOffset(16, 16), BackgroundTransparency = 1 })
            local image = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Parent = frame })
            setIcon(image, config.Icon, config.Color or Airflow.Theme.Accent)
            return { IconFrame = frame }
        end,
        },
        Tween = function(object, duration, properties, style, direction)
            return TweenService:Create(object, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
        end,
        AddSignal = connect,
    }
        function WindowMethods:OnOpen(callback)
            self._onOpen = callback;
            return self
        end
        function WindowMethods:OnClose(callback)
            self._onClose = callback;
            return self
        end
        function WindowMethods:OnDestroy(callback)
            self._onDestroy = callback;
            return self
        end
        function WindowMethods:Open()
            self._native:Toggle(true);
            return self
        end
        function WindowMethods:Close()
            self._native:Toggle(false);
            return self
        end
        function WindowMethods:Toggle(open)
            self._native:Toggle(open);
            return self
        end
        function WindowMethods:SetSize(size)
            self._native.Root.Size = size
            self._native:_fitToScreen(true)
            self._native:_clampToScreen()
            return self
        end
        function WindowMethods:SetToTheCenter()
            self._native:_fitToScreen(true)
            self._native.Root.AnchorPoint = Vector2.new(0.5, 0.5)
            self._native.Root.Position = UDim2.fromScale(0.5, 0.5)
            TweenService:Create(self._native.Root, TweenInfo.new(0), {
            Position = UDim2.fromScale(0.5, 0.5),
        }):Play()
            return self
        end
        function WindowMethods:ToggleTransparency(enabled)
            self._native.Body.BackgroundTransparency = enabled and Library.TransparencyValue or 0
            return self
        end
        function WindowMethods:SetTheme(name)
            return Library:SetTheme(name)
        end
        function WindowMethods:SetCurrentConfig(config)
            self.CurrentConfig = config
        end
        function WindowMethods:WaitForChild(...)
            return self._native.Root:WaitForChild(...)
        end
        function WindowMethods:Dialog(config)
            local result = self._native:Dialog(config)
            textLabels(self._native.Gui)
            return result
        end
        function WindowMethods:RequestClose()
            if self._destroyed then
                return
            end
            if self._closeConfirmation and self._native._dialog == self._closeConfirmation then
                return self._closeConfirmation
            end
            self._closeConfirmation = self:Dialog({
            Title = "Fechar interface?",
            Content = "Tem certeza de que deseja fechar? Será necessário executar o script novamente para abrir a interface.",
            CloseOnBackdrop = false,
            Buttons = {
                { Title = "Cancelar", Callback = function()
                self._closeConfirmation = nil
            end },
                { Title = "Fechar", Variant = "Primary", Callback = function()
                self._closeConfirmation = nil
                self:Destroy()
            end },
            },
        })
            return self._closeConfirmation
        end
        function WindowMethods:Notify(config)
            return Library:Notify(config)
        end
        function WindowMethods:SetToggleKey(key)
            self._native:SetKeybind(key);
            return self
        end
        function WindowMethods:UpdateToggleKeyDisplay(key)
            local keyCode = typeof(key) == "EnumItem" and key or Enum.KeyCode[tostring(key)]
            if not keyCode or keyCode == Enum.KeyCode.Unknown then
                return self
            end
            self._toggleKey = keyCode
            if not self._capturingToggleKey then
                self._native._keyChipLabel.Text = keyCode.Name
            end
            return self
        end
        function WindowMethods:ConfigureToggleKey(key, onChanged, onCaptureChanged)
            self._onToggleKeyChanged = onChanged
            self._onToggleKeyCapture = onCaptureChanged
            self._native:SetKeybind(Enum.KeyCode.Unknown)
            return self:UpdateToggleKeyDisplay(key)
        end
        function WindowMethods:_setToggleKeyCapture(capturing)
            if capturing == self._capturingToggleKey then
                return
            end
            self._capturingToggleKey = capturing
            self._native._keyChipLabel.Text = capturing and "Pressione uma tecla" or (self._toggleKey or Enum.KeyCode.Z).Name
            call(self._onToggleKeyCapture, capturing)
        end
        function WindowMethods:CreateTopbarButton(title, icon, callback, order, _, tint, iconSize)
            local button = new("TextButton", {
            Name = title, Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, LayoutOrder = order or 1, Parent = self.UIElements.Topbar.Right,
        })
            button:SetAttribute("NoDrag", true)
            local image = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(iconSize or 16, iconSize or 16), BackgroundTransparency = 1, Parent = button,
        })
            setIcon(image, icon, tint)
            connect(button.Activated, function()
                call(callback)
            end)
            return button
        end
        function WindowMethods:Section(config)
            config = type(config) == "table" and config or { Title = tostring(config or "") }
            self._sidebarOrder += 1
            local group = new("Frame", {
            Name = config.Title or "SidebarSection", Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            LayoutOrder = self._sidebarOrder, Parent = self._native.TabList,
        })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = group })
            local header = new("TextButton", {
            Name = "Header", Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
            Text = "", FontFace = Airflow.Fonts.Bold, TextSize = 12,
            TextColor3 = Airflow.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false, LayoutOrder = 1, Parent = group,
        })
            local title = new("TextLabel", {
            Name = "Title", Text = config.Title or "", Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1, FontFace = Airflow.Fonts.Bold, TextSize = 12,
            TextColor3 = Airflow.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true, Parent = header,
        })
            header:SetAttribute("NoDrag", true)
            local icon = new("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0),
            Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Parent = header,
        })
            setIcon(icon, "chevron-right", Airflow.Theme.Muted)
            local list = new("Frame", {
            Name = "Tabs", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 2, Visible = config.Opened == true, Parent = group,
        })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = list })
            local section = {
            Title = config.Title, Frame = group, Instance = group, Holder = group, _list = list,
            _context = self, _window = self, _children = {}, _connections = {},
            UIElements = { Main = group, Title = title, Header = header, Container = list },
            Locked = config.Locked == true, Opened = config.Opened == true,
        }
            setmetatable(section, { __index = ControlMethods })
            function section:SetOpened(opened)
                self.Opened = opened == true
                list.Visible = self.Opened
                icon.Rotation = self.Opened and 90 or 0
                return self
            end
            section.Open = function(self)
                return self:SetOpened(true)
            end
            section.Close = function(self)
                return self:SetOpened(false)
            end
            section.SetOpen = section.SetOpened
            section:SetOpened(section.Opened)
            section._connections[#section._connections + 1] = connect(header.Activated, function()
                if not section.Locked then
                    section:SetOpened(not section.Opened)
                end
            end)
            self._children[section] = true
            self._sidebarSection = section
            return section
        end
        function WindowMethods:Tab(config)
            config = config or {}
            local iconThemed = config.IconThemed
            if iconThemed == nil then
                iconThemed = not (type(config.Icon) == "string" and (config.Icon:match("^rbxassetid://") or config.Icon:match("^rbxasset://") or config.Icon:match("^rbxthumb://") or config.Icon:match("^https?://")))
            end
            local native = self._native:CreateTab({ Name = config.Title or config.Name, Desc = config.Desc, Icon = config.Icon, IconThemed = iconThemed, EmptyText = config.CustomEmptyPage and config.CustomEmptyPage.Desc or "Preparando os controles" })
            return self:_wrapTab(native, config, iconThemed)
        end
        function WindowMethods:_wrapTab(native, config, iconThemed)
            if native._icon then
                native._icon:SetAttribute("UIUnthemed", not iconThemed)
            end
            local parent = self._sidebarSection
            if parent then
                native._button.Parent = parent._list
            end
            self._sidebarOrder += 1
            native._button.LayoutOrder = parent and #self.TabModule.Tabs + 1 or self._sidebarOrder
            local tab = context(self, native, native._page)
            tab.Title, tab.Name = config.Title or config.Name, config.Title or config.Name
            tab.Index = #self.TabModule.Tabs + 1
            tab._nativeTab = native
            tab._sidebarSection = parent
            tab.UIElements.Button, tab.UIElements.TabButton = native._button, native._button
            tab.UIElements.Title = native._label
            tab.Locked = config.Locked == true
            self.TabModule.Tabs[tab.Index] = tab
            self.TabModule.Containers[tab.Index] = native._page
            self._tabsByNative[native] = tab
            function tab:Select()
                self._window._native:SelectTab(self._nativeTab);
                return self
            end
            function tab:SetTitle(title)
                self.Title = tostring(title);
                self.Name = self.Title;
                native._label.Text = self.Title;
                return self
            end
            if tab.Locked then
                native._button.Interactable = false
                native._label.TextTransparency = 0.6
            end
            return tab
        end
        function WindowMethods:CreateHomeTab(config)
            if self.HomeTab then
                return self.HomeTab
            end
            config = config or {}
            config.Name = config.Title or config.Name or "Início"
            config.Icon = config.Icon or "house"
            config.Welcome = config.Welcome or "Olá, "
            local hour = tonumber(os.date("%H")) or 12
            config.Greeting = config.Greeting or (hour < 12 and "Bom dia." or hour < 18 and "Boa tarde." or "Boa noite.")
            config.SectionName = config.SectionName or "Informações do sistema"
            config.Labels = config.Labels or { FPS = "FPS", Ping = "Ping", Executor = "Executor", Game = "Jogo", Time = "Horário",
            Players = "Jogadores", Uptime = "Tempo de sessão", Memory = "Memória Luau" }
            local native = self._native:_buildHome(config)
            local tab = self:_wrapTab(native, { Title = config.Name, Icon = config.Icon }, true)
            self.HomeTab = tab
            return tab
        end
        function WindowMethods:SelectDefaultTab()
            if self.HomeTab and not self._destroyed then
                self.HomeTab:Select()
            end
            return self
        end
        function WindowMethods:Destroy(external)
            if self._destroyed then
                return
            end
            self:_setToggleKeyCapture(false)
            self._destroyed = true
            Library._destroyed = true
            local children = {}
            for child in pairs(self._children) do
                children[#children + 1] = child
            end
            for _, child in ipairs(children) do
                child:Destroy()
            end
            local controls = {}
            for control in pairs(Library._controls) do
                controls[#controls + 1] = control
            end
            for _, control in ipairs(controls) do
                control:Destroy()
            end
            for connection in pairs(Library._connections) do
                connection:Disconnect()
            end
            Library._connections = {}
            if external then
                self._native._destroyed = true
                for _, connection in ipairs(self._native._connections) do
                    connection:Disconnect()
                end
                self._native._connections = {}
                for index, window in ipairs(Airflow.Windows) do
                    if window == self._native then
                        table.remove(Airflow.Windows, index);
                        break
                    end
                end
            else
                self._native:Destroy()
            end
            self.PendingFlags = {}
            Library.ScreenGui = nil
            call(self._onDestroy)
        end
        function Library:Destroy()
            if self.Window then
                return self.Window:Destroy()
            end
        end
        function Library:CreateWindow(config)
            assert(not self.Window, "Só é possível criar uma janela de UI por instância")
            config = config or {}
            self:SetTheme(config.Theme or self:GetCurrentTheme() or "Dark")
            Airflow.Assets.Logo = config.Icon or "rbxassetid://97170941541314"
            local native = Airflow:CreateWindow({
            Name = config.Title or "Interface", LoadingSubtitle = config.Author,
            Icon = Airflow.Assets.Logo, Size = config.Size, MinSize = config.MinSize, MaxSize = config.MaxSize,
            ToggleUIKeybind = Enum.KeyCode.Unknown, KeepOnScreen = true, OpenButton = false,
            Loading = false, Parent = self._parent, MaxNotifications = 8,
            ConfigurationSaving = { Enabled = false },
        })
            native.Gui.Enabled = false
            self.ScreenGui = native.Gui
            native.Body.Name = "Main"
            local sidebar = native.Body:FindFirstChild("Sidebar")
            local header = sidebar:FindFirstChild("Header")
            local originalLabels = textLabels(header)
            local left = new("Frame", { Name = "Left", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = header })
            local titleGroup = new("Frame", { Name = "Title", Position = UDim2.fromOffset(60, 25), Size = UDim2.new(1, -64, 0, 40), BackgroundTransparency = 1, Parent = left })
            for index, label in ipairs(originalLabels) do
                label.Name = index == 1 and "Title" or "Author"
                label.Parent = titleGroup
                label.Position = UDim2.fromOffset(0, index == 1 and 0 or 20)
                label.Size = UDim2.new(1, 0, 0, index == 1 and 20 or 14)
                label.TextTruncate = Enum.TextTruncate.None
            end
            for _, image in ipairs(header:GetChildren()) do
                if image:IsA("ImageLabel") then
                    image.Parent = left;
                    image.ImageColor3 = Color3.new(1, 1, 1)
                end
            end
            local topbar = new("Frame", { Name = "UITopbar", Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Parent = native.Content })
            local right = new("Frame", { Name = "Right", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = topbar })
            new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = right })
            local window = {
            _native = native, _children = {}, _tabsByNative = {}, _sidebarOrder = 0,
            PendingFlags = {}, Title = config.Title, Folder = config.Folder,
            UIElements = { Main = native.Root, Header = header, Topbar = topbar, Content = native.Content },
            WindUI = self, Airflow = Airflow,
            TabModule = { Tabs = {}, Containers = {}, _listeners = {} },
        }
            window._window = window
            setmetatable(window, {
            __index = function(object, key)
                if key == "CurrentTab" then
                    return object._currentIndex
                end
                if key == "Closed" then
                    return not native.Open
                end
                if key == "Destroyed" then
                    return object._destroyed == true
                end
                return WindowMethods[key]
            end,
            __newindex = function(object, key, value)
                if key == "CurrentTab" then
                    rawset(object, "_currentIndex", value)
                    if value == nil then
                        native:_settleTransition()
                        local previous = native.CurrentTab
                        if previous then
                            previous._button.BackgroundTransparency = 1
                            previous._stroke.Transparency = 1
                            previous._label.TextColor3 = Airflow.Theme.Muted
                            if previous._icon and previous._iconThemed then
                                previous._icon.ImageColor3 = Airflow.Theme.Muted
                            end
                        end
                        native.Indicator.Visible = false
                        native.CurrentTab = nil
                    end
                else
                    rawset(object, key, value)
                end
            end,
        })
            function window.TabModule:OnChange(callback)
                self._listeners[#self._listeners + 1] = callback
                return window
            end
            function window.TabModule:Select(index)
                local tab = self.Tabs[index]
                if tab then
                    native:SelectTab(tab._nativeTab)
                end
            end
            local nativeSelect = native.SelectTab
            native.SelectTab = function(object, selected)
                local tab = window._tabsByNative[selected]
                if window._destroyed or (tab and tab.Locked) then
                    return
                end
                if tab and tab._sidebarSection then
                    tab._sidebarSection:SetOpened(true)
                end
                nativeSelect(object, selected)
                if tab then
                    rawset(window, "_currentIndex", tab.Index)
                    window.TabModule.SelectedTab = tab.Index
                    for _, item in ipairs(window.TabModule.Tabs) do
                        item.Selected = item == tab
                    end
                    for _, callback in ipairs(window.TabModule._listeners) do
                        call(callback, tab.Index)
                    end
                end
            end
            local nativeToggle = native.Toggle
            window._notifiedOpen = false
            local function notifyVisibility()
                if window._destroyed then
                    return
                end
                local opened = native.Open and native.Gui.Enabled
                if not opened and window._capturingToggleKey then
                    window:_setToggleKeyCapture(false)
                end
                if opened == window._notifiedOpen then
                    return
                end
                window._notifiedOpen = opened
                call(opened and window._onOpen or window._onClose)
            end
            native.Toggle = function(object, open)
                if window._destroyed then
                    return
                end
                nativeToggle(object, open)
                notifyVisibility()
            end
            connect(native.Gui:GetPropertyChangedSignal("Enabled"), notifyVisibility)
            connect(native.Gui.Destroying, function()
                if not window._destroyed then
                    window:Destroy(true)
                end
            end)
            window.ConfigManager = createConfigManager(window, config.Folder or "Interface")
            self.Window = window
            window._capturingToggleKey = false
            window:UpdateToggleKeyDisplay(Enum.KeyCode.Z)
            local keyChip = native._keyChipLabel.Parent
            local keyPicker = new("TextButton", {
            Name = "ToggleKeyInput", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, ZIndex = 5, Parent = keyChip,
        })
            keyPicker:SetAttribute("NoDrag", true)
            window.UIElements.ToggleKeyInput = keyPicker
            connect(keyPicker.Activated, function()
                window:_setToggleKeyCapture(not window._capturingToggleKey)
            end)
            connect(UserInput.InputBegan, function(input)
                if window._destroyed or not window._capturingToggleKey or input.UserInputType ~= Enum.UserInputType.Keyboard then
                    return
                end
                local keyCode = input.KeyCode
                if keyCode == Enum.KeyCode.Unknown then
                    return
                end
                native._consumedKey, native._consumedAt = keyCode, os.clock()
                if keyCode ~= Enum.KeyCode.Escape then
                    local accepted = true
                    if window._onToggleKeyChanged then
                        accepted = call(window._onToggleKeyChanged, keyCode.Name)
                    else
                        native:SetKeybind(keyCode)
                    end
                    if accepted ~= false then
                        window:UpdateToggleKeyDisplay(keyCode)
                    end
                end
                window._capturingToggleKey = false
                native._keyChipLabel.Text = (window._toggleKey or Enum.KeyCode.Z).Name
                task.defer(function()
                    if not window._destroyed then
                        call(window._onToggleKeyCapture, false)
                    end
                end)
            end)
            native.RequestClose = function()
                return window:RequestClose()
            end
            local closeButton = native.CloseButton
            closeButton.Name = "Fechar"
            closeButton.Text = ""
            closeButton.AnchorPoint = Vector2.zero
            closeButton.Position = UDim2.fromOffset(0, 0)
            closeButton.Size = UDim2.fromOffset(28, 28)
            closeButton.LayoutOrder = 992
            closeButton:SetAttribute("NoDrag", true)
            closeButton.Parent = right
            local closePadding = closeButton:FindFirstChildOfClass("UIPadding")
            if closePadding then
                closePadding:Destroy()
            end
            for _, rotation in ipairs({ 45, -45 }) do
                new("Frame", {
                Name = "Glyph", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(12, 2), Rotation = rotation, BorderSizePixel = 0,
                BackgroundColor3 = Airflow.Theme.Muted, ZIndex = closeButton.ZIndex + 1, Parent = closeButton,
            })
            end
            window.UIElements.CloseButton = closeButton
            local minimize = window:CreateTopbarButton("Minimizar", "", function()
                window:Close()
            end, 991)
            window.UIElements.MinimizeButton = minimize
            new("Frame", {
            Name = "Glyph", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(12, 2), BorderSizePixel = 0, BackgroundColor3 = Airflow.Theme.Muted,
            ZIndex = minimize.ZIndex + 1, Parent = minimize,
        })
            window:SetToTheCenter()
            self:SetNotificationLower(self._notificationsLower ~= false)
            for _, notification in ipairs(self._pendingNotifications or {}) do
                self:Notify(notification)
            end
            self._pendingNotifications = nil
            return window
        end
        Library:SetTheme("Mono")
        return Library
    end
end)()
return AdapterFactory(Airflow, ThemeFactory, Palette, Runtime)
