-----------------------------------------------------------------------------------------
--
-- bookMain.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- JSON 파싱
json = require('json')

function parseBreadInfo()
	local filename = system.pathForFile("Content/JSON/breadInfo.json")
	BreadInfo = json.decodeFile(filename)
end

-- BreadInfo는 Data
function parseUBreadInfo()
	local filename = system.pathForFile("Content/JSON/ubreadInfo.json")
	UBreadInfo= json.decodeFile(filename)
end
parseUBreadInfo()
parseBreadInfo()


-- 폰트
Font = { 	
			font_POP = native.newFont("Content/font/ONE Mobile POP.ttf")		}

BackGround = display.newImage("Content/images/main_background.png")
BackGround.x, BackGround.y = display.contentWidth/2, display.contentHeight/2

audio.play(soundTable["backgroundMusic"], { loops = 3 })

function scene:create( event )
	local sceneGroup = self.view

-- 도감 스크롤
	local widget = require( "widget" )
	local function scroll( event )
		if ( event.phase == "began" ) then
			display.getCurrentStage():setFocus( event.target )
			event.target.isFocus = true
			event.target.yStart = event.target.y

		elseif ( event.phase == "moved" ) then
			if ( event.target.isFocus) then
			end
		elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
			if ( event.target.isFocus ) then
			display.getCurrentStage():setFocus( nil )
			event.target.isFocus = false
			end
			display.getCurrentStage():setFocus( nil )
			event.target.isFocus = false
			scrollS:removeSelf()
		end	 
	    -- In the event a scroll limit is reached...
	    if ( event.limitReached ) then
	        if ( event.direction == "up" ) then print( "Reached bottom limit" )
	        elseif ( event.direction == "down" ) then print( "Reached top limit" )
	        end
	    end
	 
	    return true
	end

	local scrollView = widget.newScrollView(
		{
	        horizontalScrollDisabled=true,
	        top = 0,
	        width = 1440,
	        height = 2300,
	        backgroundColor = { 1, 1, 1, 0 }
		}
	)

-- 도감 그룹화 함수
	local allBread = { } 
	local newBread = { }
	local BImage = { }
	local BText = { }
	local BreadGroup
	local index1 = 1
	local index2 = 1

-- 빵 정보창 이동 (빵 클릭)
	local function goInfo(event)
		audio.play(soundTable["clickSound"],  {channel=5})
		print(event.target.id)
		print(event.target.id1)
		print(event.target.id2)
		composer.setVariable("Id1", event.target.id1)
		composer.setVariable("Id2", event.target.id2)
		composer.setVariable("Id", event.target.id)
		composer.removeScene("bookMain")		
		composer.gotoScene( "bookInfo" )
	end

-- 도감 오브젝트 tap이벤트에 넣기	
	local function tapInfo()
		index1, index2 = 1, 1
		local index = 1	
		local jsc = openBread			
		for i = 1, 64 do
			if i == 33 then
				jsc = openUBread
				index1, index2 = 1, 1
				index = 2
			end

			lock = jsc[index1][index2]
			if lock ~= 0 then
				allBread[i]:addEventListener("tap", goInfo)
			end

			allBread[i].id1 = index1
			allBread[i].id2 = index2
			allBread[i].id = index 

			index2 = index2 + 1
			if index2 == 9 then
				index2 = 1
				index1 = index1 + 1
			end
		end
	end
-- [BreadGroup] 도감생성
	local function xy(obj, i1, j)
		if i1 % 3 == 1 then
			obj[i1].x= BackGround.x*0.45
		elseif i1 % 3 == 2 then
			obj[i1].x = BackGround.x
		else
			obj[i1].x = BackGround.x*1.55
		end
		obj[i1].y = BackGround.y*j
	end

-- makeAllBook() -- 전체 도감
	local function makeAllBook()
		BreadGroup = display.newGroup()
		index1, index2 = 1, 1
		local jul = 0.15
		local jsc = openBread
		local js = BreadInfo

		for i = 1, 64 do
			if i == 33 then
				jsc = openUBread
				js = UBreadInfo
				index1, index2 = 1, 1
			end
			lock = jsc[index1][index2]
			-- print(js[index1].breads[index2].image.."는 해금?"..jsc[index1][index2])
			Bimage = js[index1].breads[index2].image
			Bname = js[index1].breads[index2].name

			if i % 3 == 1 then
				jul = jul + 0.33
			end
			if lock ~= 0 then
				if lock == -1 then
					newBread[i] = display.newImageRect(BreadGroup, "Content/images/halo.png", 480, 480)
					xy(newBread, i, jul)
					allBread[i] = display.newImage(BreadGroup, "Content/images/illuGuide_new.png")
				else 
					allBread[i] = display.newImage(BreadGroup, "Content/images/illuGuide_nomal.png")
				end
				xy(allBread, i, jul)
				BText[i]= display.newText(BreadGroup, Bname, allBread[i].x, BackGround.y*(jul+0.09), Font.font_POP, 35)
				BText[i]:setFillColor(0)
				BImage[i] = display.newImageRect(BreadGroup, "Content/images/"..Bimage..".png", 210, 210)
				BImage[i].x, BImage[i].y = allBread[i].x, allBread[i].y
			else
				allBread[i] = display.newImage(BreadGroup, "Content/images/illu_book_secret.png")
				xy(allBread, i, jul)				
			end
	
			index2 = index2 + 1
			if index2 == 9 then
				index2 = 1
				index1 = index1 + 1
			end

		end	
		tapInfo()
		scrollView:insert(BreadGroup)
		scrollView:addEventListener("touch",scroll)
	end

	makeAllBook()	

-- [도감 BasicGroup] 도감 메뉴
	local illuBook_BasicGroup = display.newGroup()
	local illuBook_back = display.newImage(illuBook_BasicGroup,"Content/images/main_background1.png")
	illuBook_back.x, illuBook_back.y = BackGround.x, BackGround.y*0.1

	-- 도감, 홈 버튼
	local illuBook_book = display.newImage(illuBook_BasicGroup,"Content/images/book.png")
	illuBook_book.x, illuBook_book.y = BackGround.x*0.25, BackGround.y*0.1
	local illuBook_home = display.newImage(illuBook_BasicGroup,"Content/images/home.png")
	illuBook_home.x, illuBook_home.y = BackGround.x*1.75, BackGround.y*0.1
	local illuBook_bookText = display.newImage(illuBook_BasicGroup,"Content/images/text_Book.png")
	illuBook_bookText.x, illuBook_bookText.y = BackGround.x*0.53, BackGround.y*0.1

	-- 메뉴바
	local illuBook_menu = display.newImage(illuBook_BasicGroup,"Content/images/illuGuide_manu.png")
	illuBook_menu.x, illuBook_menu.y = BackGround.x, BackGround.y/5

	-- 메뉴 선택	
	illuBook_menuC = display.newImage(illuBook_BasicGroup,"Content/images/illuGuide_manuchoice.png")
	illuBook_menuC.x, illuBook_menuC.y = illuBook_menu.x*0.45, illuBook_menu.y*1.22
	-- illuBook_menu[1].x, illuBook_menu[1].x*1.55

	-- 메뉴 이름
	local menuAll = display.newText(illuBook_BasicGroup,"전체", illuBook_menu.x*0.45, illuBook_menu.y, Font.font_POP, 65)
	local menuNomal = display.newText(illuBook_BasicGroup,"일반", illuBook_menu.x, illuBook_menu.y, Font.font_POP, 65)
	local menuRare = display.newText(illuBook_BasicGroup,"레어", illuBook_menu.x*1.55, illuBook_menu.y, Font.font_POP, 65)

-- 도감 이동 함수 
	-- Nomal
	local function Nomal( event )
		audio.play(soundTable["clickSound"],  {channel=5})
		print("Nomal go!!")
		composer.removeScene("bookMain")		
		composer.gotoScene( "bookNomal" )		
	end 
	menuNomal:addEventListener("tap", Nomal)

	-- Rare
	local function Rare( event )
		audio.play(soundTable["clickSound"],  {channel=5})
		print("Rare go!!")
		composer.removeScene("bookMain")		
		composer.gotoScene( "bookRare" )
	end 
	menuRare:addEventListener("tap", Rare)	

	-- All
	local function All( event )
		audio.play(soundTable["clickSound"],  {channel=5})
		BreadGroup:removeSelf()
		makeAllBook()
	end 
	menuAll:addEventListener("tap", All)	


-- 레이어정리
	sceneGroup:insert(BackGround)	
	-- scrollView:insert(BreadGroup)
	-- scrollView:addEventListener("touch",scroll)
	sceneGroup:insert(scrollView)	
	sceneGroup:insert(illuBook_BasicGroup)

-- 홈으로 이동
	local function goHome(event)
		audio.play(soundTable["clickSound"],  {channel=5})	
		print("goHome!!")
		composer.removeScene("bookMain")
		---------showCoin 관련 수정
		showCoin.isVisible = true
		showCoin.x, showCoin.y = display.contentWidth*0.545, display.contentHeight*0.04
		showCoin.text = coinNum
		composer.gotoScene( "home" )
	end
	illuBook_home:addEventListener("tap",goHome)


	-------------------엔딩보기------------
	--빵 도감 채운 개수 전역변수
	breadBook_count = 0
	--업그레이드 빵 도감 채운 개수
	breadBookUP_count = 0
	for n = 1, 4 do
		for m = 1, 8 do	
			if openBread[n][m] ~= 0 then
				breadBook_count = breadBook_count + 1
			end
		end
	end
	for n = 1, 4 do
		for m = 1, 8 do
			if openUBread[n][m] ~= 0 then
				breadBookUP_count = breadBookUP_count + 1
			end
		end
	end
	if breadBook_count + breadBookUP_count >= 64 then 
		local endingButton = display.newImage("Content/images/아웃트로/togoEnd.png", display.contentWidth*0.5, display.contentHeight*0.95)
		local ending = display.newText("엔딩보기", display.contentWidth*0.5, display.contentHeight*0.95, "Content/font/ONE Mobile POP.ttf", 75)
		--ending:setFillColor(0.5)

		function gotoEnding(event)
		----------------showCoin관련 수정
			showCoin.isVisible = false
			composer.gotoScene("outtro")
		end
		endingButton:addEventListener("tap", gotoEnding)
		sceneGroup:insert(endingButton)
		sceneGroup:insert(ending)
	end
	-------------------------------------
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
	elseif phase == "did" then
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene