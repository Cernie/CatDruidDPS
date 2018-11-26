CerniesWonderfulFunctions = {};
CWF_isPlayerInCombat = false;

function CerniesWonderfulFunctions_OnLoad()
	this:RegisterEvent("PLAYER_LOGIN")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")	
	local msg = "Cernie's Wonderful Functions (CWF) loaded. Please see the readme for instructions.";
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end;
function CerniesWonderfulFunctions_OnEvent(event, arg1, arg2, arg3)
	if (event == "PLAYER_REGEN_DISABLED") then
		CWF_isPlayerInCombat = true;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		CWF_isPlayerInCombat = false;
	end;
end;

--One action for using Battleground specific bandages, or use normal bandages if not in a Battleground
function UseBGBandage(wg, ab, av, normal)
--'Warsong Gulch Runecloth Bandage''Alterac Heavy Runecloth Bandage''Arathi Basin Runecloth Bandage''Heavy Runecloth Bandage'
	local zone = GetRealZoneText();
	local msg = nil;
	local wgFound, wgBag, wgSlot = isInBag(wg);
	local abFound, abBag, abSlot = isInBag(ab);
	local avFound, avBag, avSlot = isInBag(av);
	local normalFound, normalBag, normalSlot = isInBag(normal);
	
	if(zone == "Warsong Gulch" and wgFound == true) then UseContainerItem(wgBag, wgSlot); msg = wg;
	elseif(zone == "Alterac Valley" and avFound == true) then UseContainerItem(avBag, avSlot); msg = av;
	elseif(zone == "Arathi Basin" and abFound == true) then UseContainerItem(abBag, abSlot); msg = ab;
	elseif(normalFound) then UseContainerItem(normalBag, normalSlot); msg = normal;
	else msg = "Nothing"; 
	end;
	
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--One action for using Battleground specific biscuits instead of regular food/water
function UseBGBiscuit(wg, ab, av)
--'Warsong Gulch Enriched Ration''Alterac Manna Biscuit''Arathi Basin Enriched Ration'
	local zone = GetRealZoneText();
	local msg = nil;
	local wgFound, wgBag, wgSlot = isInBag(wg);
	local abFound, abBag, abSlot = isInBag(ab);
	local avFound, avBag, avSlot = isInBag(av);
	
	if(zone == "Warsong Gulch" and wgFound == true) then UseContainerItem(wgBag, wgSlot); msg = wg;
	elseif(zone == "Alterac Valley" and avFound == true) then UseContainerItem(avBag, avSlot); msg = av;
	elseif(zone == "Arathi Basin" and abFound == true) then UseContainerItem(abBag, abSlot); msg = ab;
	elseif(avFound == true) then UseContainerItem(avBag, avSlot); msg = av;
	else msg = "Nothing"; 
	end;
	
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--One action for drinking and eating, press twice to do both
function Nom(water, food)
	local waterFound, waterBag, waterSlot = isInBag(water);
	local foodFound, foodBag, foodSlot = isInBag(food);
	local healthPct = UnitHealth("player") / UnitHealthMax("player");
	local manaPct = UnitMana("player") / UnitManaMax("player");
	
	if(CWF_isPlayerInCombat == false) then
		if(isBuffNameActive("Drink") == false and waterFound == true and manaPct ~= 1) then 
			UseContainerItem(waterBag, waterSlot, 1);
		elseif(isBuffNameActive("Food") == false and foodFound == true and healthPct ~= 1) then 
			UseContainerItem(foodBag, foodSlot, 1); 
		end;
	end;
end;

--One action for eating for non mana using classes
function NomFood(food)
	local foodFound, foodBag, foodSlot = isInBag(food);
	local healthPct = UnitHealth("player") / UnitHealthMax("player");
	
	if(CWF_isPlayerInCombat == false) then
		if (isBuffNameActive("Food") == false and foodFound == true and healthPct ~= 1) then 
			UseContainerItem(foodBag, foodSlot, 1);
		end;
	end;
end;

--One action for drinking for mana using classes
function NomWater(water)
	local waterFound, waterBag, waterSlot = isInBag(water);
	local manaPct = UnitMana("player") / UnitManaMax("player");
	
	if(CWF_isPlayerInCombat == false) then
		if (isBuffNameActive("Drink") == false and waterFound == true and manaPct ~= 1) then 
			UseContainerItem(waterBag, waterSlot, 1);
		end;
	end;
end;

--One action to use a Mana potion based on location and item availability
function UseManaPotion()
	local potion = {'Major Mana Draught', 'Major Mana Potion', 'Combat Mana Potion', 'Superior Mana Potion', 'Greater Mana Potion', 'Mana Potion', 'Lesser Mana Potion', 'Minor Mana Potion'};
	local zone = GetRealZoneText();
	local msg = "Nothing";
	local i = nil;
	local potFound, potBag, potSlot = nil;
	local _, duration, _ = nil;
	
	--based on battleground zone use 'Major Mana Draught'
	potFound, potBag, potSlot = isInBag(potion[1]);
	if (potFound == true and (zone == "Warsong Gulch" or zone == "Alterac Valley" or zone == "Arathi Basin")) then
		_, duration, _ = GetContainerItemCooldown(potBag, potSlot);
		if(duration == 0) then
			UseContainerItem(potBag, potSlot, 1); msg = potion[1];
		else
			msg = potion[1] .. ", but it is on Cooldown";
		end;

	--otherwise loop through the rest of the possible potions and use the highest value potion available
	else
		for i = 2, table.getn(potion), 1 do
			potFound, potBag, potSlot = isInBag(potion[i]);
			if(potFound) then
				_, duration, _ = GetContainerItemCooldown(potBag, potSlot);
				if(duration == 0) then
					UseContainerItem(potBag, potSlot, 1); msg = potion[i];
				else
					msg = potion[i] .. ", but it is on Cooldown";
				end;
				break;
			end;
		end;
	end;
	
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--One action to use a Health potion based on location and item availability
function UseHealthPotion()
	local potion = {'Major Healing Draught', 'Major Healing Potion', 'Combat Healing Potion', 'Superior Healing Potion', 'Greater Healing Potion', 'Healing Potion', 'Lesser Healing Potion', 'Minor Healing Potion'};
	local zone = GetRealZoneText();
	local msg = "Nothing";
	local i = nil;
	local potFound, potBag, potSlot = nil;
	local _, duration, _ = nil;
	
	--based on battleground zone use 'Major Healing Draught'
	potFound, potBag, potSlot = isInBag(potion[1]);
	if (potFound == true and (zone == "Warsong Gulch" or zone == "Alterac Valley" or zone == "Arathi Basin")) then
		_, duration, _ = GetContainerItemCooldown(potBag, potSlot);
		if(duration == 0) then
			UseContainerItem(potBag, potSlot, 1); msg = potion[1];
		else
			msg = potion[1] .. ", but it is on Cooldown";
		end;
	
	--otherwise loop through the rest of the possible potions and use the highest value potion available
	else
		for i = 2, table.getn(potion), 1 do
			potFound, potBag, potSlot = isInBag(potion[i]);
			if(potFound) then
				_, duration, _ = GetContainerItemCooldown(potBag, potSlot);
				if(duration == 0) then
					UseContainerItem(potBag, potSlot, 1); msg = potion[i];
				else
					msg = potion[i] .. ", but it is on Cooldown";
				end;
				break;
			end;
		end;
	end;
	
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--Uses available Mana Gem
function UseManaGem()
	local msg = "Nothing";
	local gem = {"Mana Ruby", "Mana Citrine", "Mana Jade", "Mana Agate"};
	local hasGem, gemBag, gemSlot = nil;
	for i=1, 4 do
		hasGem, gemBag, gemSlot = isInBag(gem[i]);
		if(hasGem == true) then 
			UseContainerItem(gemBag, gemSlot, 1);
			msg = gem[i]; 
			break; 
		end;
	end;
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--Uses available Healthstone
function UseHealthstone()
	local msg = "Nothing";
	local healthstone = {"Major Healthstone", "Greater Healthstone", "Healthstone", "Lesser Healthstone", "Minor Healthstone"};
	local hasStone, stoneBag, stoneSlot = nil;
	for i=1, 5 do
		hasStone, stoneBag, stoneSlot = isInBag(healthstone[i]);
		if(hasStone == true) then 
			UseContainerItem(stoneBag, stoneSlot, 1);
			msg = healthstone[i]; 
			break; 
		end;
	end;
	DEFAULT_CHAT_FRAME:AddMessage("CWF: Attempting to use "..msg.."!");
end;

--Decide which spell to cast based on Clearcast proc
function MageDPM(spell1, spell2)
	local clearcast = isBuffNameActive("Clearcasting");

	if(clearcast) then 
		SpellStopCasting(); 
		CastSpellByName(spell1);
	else  
		CastSpellByName(spell2); 
	end;

end;

--Equip Fishing pole or begin fishing if a pole is equipped, holding down any modifier (ctrl, alt, shift) will attach the best available lure
function Fish(pole)
	local mainHandLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"));
	local mainHandName = getItemName(mainHandLink);
	local pole_hasPole, pole_bag, pole_slot = isInBag(pole);
	local mod = false;
	local lures = {"Aquadynamic Fish Attractor", "Flesh Eating Worm", "Bright Baubles", "Nightcrawlers", "Shiny Bauble"};
	local i = nil;
	local lureFound, lureBag, lureSlot = nil;
	
	if(IsAltKeyDown() or IsShiftKeyDown() or IsControlKeyDown()) then
		mod = true;
	end;
	
	if(pole_hasPole == true and (mainHandLink == nil or mainHandName ~= pole)) then
		UseContainerItem(pole_bag, pole_slot, 1);
	elseif(mod == true) then
		for i = 1, table.getn(lures), 1 do
			lureFound, lureBag, lureSlot = isInBag(lures[i]);
			if(lureFound) then
				UseContainerItem(lureBag, lureSlot);
				PickupInventoryItem(16);
				break;
			end;
		end;
	elseif(mainHandName ~= nil and mainHandName == pole) then
		CastSpellByName("Fishing");
	end;
end;

--Toggle equipped item slot between two items
function ToggleEquipItemSlot(slot, item1, item2)
	local equippedItem = getItemName(GetInventoryItemLink("player", GetInventorySlotInfo(slot)));
	local item1_hasItem, item1_bag, item1_slot = isInBag(item1);
	local item2_hasItem, item2_bag, item2_slot = isInBag(item2);
	
	if(item1_hasItem == true and (equippedItem == nil or equippedItem ~= item1)) then 
		UseContainerItem(item1_bag, item1_slot, 1);
	elseif(item2_hasItem == true) then
		UseContainerItem(item2_bag, item2_slot, 1); 
	end;
end;

--Druid shapeshift, form is the name of the shape, isPowerShift determines whether to cancel target form and reshift into it, isGCD is true/false to determine if the shift waits until GCD is up.
function Shapeshift(form, isPowerShift, isGCD)
	local targetFormId = 0;
	local currentForm = 0;
	local i = nil;
	local _, formName, active = nil;
	local _, shiftCooldown, _ = nil;
	
	_, formName, active = GetShapeshiftFormInfo(1);	
	_, shiftCooldown, _ = GetSpellCooldown(getSpellId(formName), BOOKTYPE_SPELL);
	
	for i = 1, GetNumShapeshiftForms(), 1
		do
			_, formName, active = GetShapeshiftFormInfo(i);
			if(string.find(formName, form)) then
				targetFormId = i;
			end;
			if(active ~= nil) then
				currentForm = i;
			end;
	end;
	--if already in target form and powershift true or in a different form other than target form, cancelshapeshift
	if((targetFormId == currentForm and isPowerShift == true) or (targetFormId ~= currentForm and currentForm ~= 0)) then
		if((isGCD == false) or (isGCD == true and shiftCooldown == 0)) then
			CastShapeshiftForm(currentForm);
		end;
	--if in human form, shift into target form
	elseif(currentForm == 0) then
		if((isGCD == false) or (isGCD == true and shiftCooldown == 0)) then
			CastShapeshiftForm(targetFormId);
		end;
	end;
end;

--Druid cancel shapeshift
function CancelShapeshift()
	local currentForm = 0;
	local _,formName,active = nil;
	for i = 1, GetNumShapeshiftForms(), 1
		do
			_,formName,active = GetShapeshiftFormInfo(i);
			if(active ~= nil) then currentForm = i; end;
	end;
	if(currentForm ~= 0) then
		CastShapeshiftForm(currentForm);
	end;
end;

--Druid macro for shifting into bear form and using Feral Charge
function FeralCharge()	
	local currentForm = getShapeshiftForm();
	
	if(currentForm == 1) then 
		CastSpellByName("Feral Charge");
	else
		Shapeshift("Bear Form", false, true);
	end;
end;

--Druid macro to return current form id
function getShapeshiftForm()
	local currentForm = 0;
	local _,formName,active = nil;
	for i = 1, GetNumShapeshiftForms(), 1
		do
			_,formName,active = GetShapeshiftFormInfo(i);
			if(active ~= nil) then currentForm = i; end;
	end;
	return currentForm;
end;

--Create Frame to read tooltip
function createTooltipFrame()
    if cernieUsefulFunctions == nil then
        cernieUsefulFunctions = CreateFrame("GameTooltip", "cernieUsefulFunctionsTooltip", nil, "GameTooltipTemplate");
    end;
end;

--Reads unit's buffs and returns isBuffActive, buffIndex, numBuffs
function isBuffNameActive(buff, unit)
	createTooltipFrame();
	local isBuffActive = false;
	local buffIndex = -1;
	local i = 1;
	local numBuffs = nil;
	local g=UnitBuff;
	local textleft1 = nil;
	unit = unit or "player";
	while not(g(unit, i) == -1 or g(unit, i) == nil)
		do
		cernieUsefulFunctionsTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
		cernieUsefulFunctionsTooltip:SetUnitBuff(unit, i);
		textleft1 = getglobal(cernieUsefulFunctionsTooltip:GetName().."TextLeft1");		

		if(textleft1 ~= nil and string.find(string.lower(textleft1:GetText()), string.lower(buff))) then 
			isBuffActive = true;
			buffIndex = i - 1;
			cernieUsefulFunctionsTooltip:Hide();
			break;
		end;
		cernieUsefulFunctionsTooltip:Hide();
		i=i+1;
	end;
	if(buffIndex == -1) then
		numBuffs = 0;
	else
		numBuffs = i;
	end;
	return isBuffActive, buffIndex, numBuffs;
end;

--Reads unit's debuffs and returns isDebuffActive, debuffIndex, numDebuffs
function isDebuffNameActive(debuff, unit)
	createTooltipFrame();
	local isDebuffActive = false;
	local debuffIndex = -1;
	local i = 1;
	local numDebuffs = nil;
	local g=UnitDebuff;
	local textleft1 = nil;
	unit = unit or "player";
	while not(g(unit, i) == -1 or g(unit, i) == nil)
		do
		cernieUsefulFunctionsTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
		cernieUsefulFunctionsTooltip:SetUnitDebuff(unit, i);
		textleft1 = getglobal(cernieUsefulFunctionsTooltip:GetName().."TextLeft1");		

		if(textleft1 ~= nil and string.find(string.lower(textleft1:GetText()), string.lower(debuff))) then 
			isDebuffActive = true;
			debuffIndex = i - 1;
			cernieUsefulFunctionsTooltip:Hide();
			break;
		end;
		cernieUsefulFunctionsTooltip:Hide();
		i=i+1;
	end;
	if(debuffIndex == -1) then
		numDebuffs = 0;
	else
		numDebuffs = i;
	end;
	return isDebuffActive, debuffIndex, numDebuffs;
end;

--find auto attack, returns action slot id (0 if not found)
function findAttackActionSlot()
	for i = 1, 120, 1
		do
		if(IsAttackAction(i) == 1 and IsCurrentAction(i) == 1) then
		return i; end;
	end;
	return 0;
end;

--find auto ranged attack, returns action slot id (0 if not found)
function findAutoRangedActionSlot()
	for i = 1, 120, 1
		do
		if(IsAutoRepeatAction(i) == 1) then
		return i; end;
	end;
	return 0;
end;

--find a debuff on target, returns true or false
function isTargetDebuff(target, debuff)
	local isDebuff = false;
	for i = 1, 40
		do
		if(strfind(tostring(UnitDebuff(target,i)), debuff)) then isDebuff = true; end;
	end;
	return isDebuff;
end;

--Cast a spell based on modifiers
function ModifySpellAction(options)
	local shiftDown = IsShiftKeyDown();
	local ctrlDown = IsControlKeyDown();
	local altDown = IsAltKeyDown();
	local cast = CastSpellByName;
	
	if(shiftDown and options.shift ~= nil) then cast(options.shift);
	elseif(ctrlDown and options.ctrl ~= nil) then cast(options.ctrl);
	elseif(altDown and options.alt ~= nil) then cast(options.alt);
	elseif (options.unmod ~= nil) then cast(options.unmod);
	end;
end;

--Use a script based on modifiers. This is more generic than ModifySpellAction but requires more input.
function ModifyKeyAction(options)
	local shiftDown = IsShiftKeyDown();
	local ctrlDown = IsControlKeyDown();
	local altDown = IsAltKeyDown();
	
	if(shiftDown and options.shift ~= nil) then RunScript(options.shift);
	elseif(ctrlDown and options.ctrl ~= nil) then RunScript(options.ctrl);
	elseif(altDown and options.alt ~= nil) then RunScript(options.alt);
	elseif (options.unmod ~= nil) then RunScript(options.unmod);
	end;
end;

--Uses your normal mount or AQ40 mount if inside AQ40
function MountAQ(normal, aq)
	local normalFound, normalBag, normalSlot = isInBag(normal);
	local aqFound, aqBag, aqSlot = isInBag(aq);
	local zone = GetRealZoneText();
	
	if(zone == "Temple of Ahn'Qiraj" and aqFound == true) then
		UseContainerItem(aqBag, aqSlot, 1);
	elseif(normalFound) then
		UseContainerItem(normalBag, normalSlot, 1);
	end;
end;

--Uses a container item based on item name, self ensures the item is used on the player
function UseItemInBag(itemName, self)
	local found, bag, slot = nil;
	self = self or 0;
	
	found, bag, slot = isInBag(itemName);
	if(found) then
		if(self == 0) then
			UseContainerItem(bag, slot);
		else
			UseContainerItem(bag, slot, 1);
		end;
	end;
end;

--returns id of a spell from player's spellbook
function getSpellId(spell)
	local i = 1
	while true do
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   if not spellName then
		  do break end
	   end
	   if spellName == spell then
	   return i; end;
	   i = i + 1
	end
end;

--Function to determine if spell or ability is on Cooldown, returns true or false
function isSpellOnCd(spell)
	local gameTime = GetTime();
	local start,duration,_ = GetSpellCooldown(getSpellId(spell), BOOKTYPE_SPELL);
	local cdT = start + duration - gameTime;
	return (duration ~= 0);
end;

--Function to determine if a container item is on Cooldown, returns true or false
function isContainerItemOnCd(itemName)
	local found, bag, slot = isInBag(itemName);
	local isOnCd = nil;
	local start, duration, enabled = nil;
	
	if(found) then
		start, duration, enabled = GetContainerItemCooldown(bag, slot);
		if(enabled ~= 1 or (enabled == 1 and duration == 0)) then
			isOnCd = false;
		elseif(enabled == 1 and duration ~= 0) then
			isOnCd = true;
		end;
	end;
	return isOnCd;
end;

--Helper function to find the action slot id based on texture
function findActionSlot(spellTexture)	
	for i = 1, 120, 1
		do
		if(GetActionTexture(i) ~= nil) then 
			if(strfind(GetActionTexture(i), spellTexture)) then 
				return i; 
			end; 
		end;
	end;
	return 0;
end;

--Function to toggle auto attack "on" or "off"
function ToggleAutoAttack(switch)
	if(switch == "off") then
		if(findAttackActionSlot() ~= 0) then
			AttackTarget();
		end;
	elseif(switch == "on") then
		if(findAttackActionSlot() == 0) then
			AttackTarget();
		end;
	end;
end;

--Helper function to determine if an item is in the player's bags, returns boolean of if found and bag and slot ids
function isInBag(itemName)
	local found = false;
	local itemBag, itemSlot = nil;
	local name2 = nil;
	local index1 = nil;
	local index2 = nil;
	local bracketStart = "|h";
	local bracketEnd = "]";
	for bag = 0, 4, 1
		do 
			for slot = 1, GetContainerNumSlots(bag), 1
				do local name = GetContainerItemLink(bag,slot)
				if name and string.find(name, itemName) then
					local index1 = string.find(name, bracketStart);
					local index2 = string.find(name, bracketEnd);
					local name2 = string.sub(name, index1 + 3, index2 - 1);
					if string.find(name2, itemName) == 1 then 
						found = true;
						itemBag = bag;
						itemSlot = slot;
						return found, itemBag, itemSlot;
					end;
				end;
			end;
		end;
	return found, itemBag, itemSlot;
end;

--Helper function to get an item name given an item link
function getItemName(itemLink)
	local name = nil;
	local index1 = nil;
	local index2 = nil;
	local bracketStart = "|h";
	local bracketEnd = "]";
	
	if(itemLink ~= nil) then
		local index1 = string.find(itemLink, bracketStart);
		local index2 = string.find(itemLink, bracketEnd);
		name = string.sub(itemLink, index1 + 3, index2 - 1);
	end;
	return name;
end;

--Helper function to determine if a specific buff texture is active on the player
function isBuffTextureActive(texture)
	local i=0;
	local g=GetPlayerBuff;
	local isBuffActive = false;

	while not(g(i) == -1)
	do
		if(strfind(GetPlayerBuffTexture(g(i)), texture)) then isBuffActive = true; end;
		i=i+1
	end;	
	return isBuffActive;
end;

--Helper function for a user to determine buff texture names
function getBuffTextures()
	local i = 0; 
	local g = GetPlayerBuff;
	while not(g(i) == -1)
		do
			local buffName = string.split(GetPlayerBuffTexture(g(i)), "Icons\\");
			DEFAULT_CHAT_FRAME:AddMessage(""..i..": "..buffName[2].."");
		i=i+1 
	end;
end;

--Function to split a string
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end