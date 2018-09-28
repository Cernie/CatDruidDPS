CatDruidDPS = {};
function CatDruidDPS_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	DEFAULT_CHAT_FRAME:AddMessage("CatDruidDPS addon loaded. Type /catdps for usage.");
	SlashCmdList["CATDRUIDDPS"] = function()
		DEFAULT_CHAT_FRAME:AddMessage("To use CatDruidDPS addon, create a macro that uses the following signature:");
		DEFAULT_CHAT_FRAME:AddMessage("/script CatDruidDPS_main(mainDamage, opener, finisher, isPowerShift, druidBarAddon, isUseConsumables, isSelfInnervate)");
		DEFAULT_CHAT_FRAME:AddMessage("This addon also requires you have the Attack ability somewhere on your action bars.");
		DEFAULT_CHAT_FRAME:AddMessage("");
		DEFAULT_CHAT_FRAME:AddMessage("Description of parameters (inputs to the macro):");
		DEFAULT_CHAT_FRAME:AddMessage("mainDamage");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a string of the ability you wish to use in combo point generation.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Examples are 'Shred', 'Rake', and 'Claw'.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("opener");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a string of the ability to use as an opener ability.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Examples are 'Ravage' and 'Pounce'.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("finisher");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a string of the ability to use as a finishing ability that consumes combo points.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Examples are 'Rip' and 'Ferocious Bite'.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("isPowerShift");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a true or false value that determines if you want to enable powershifting with the macro.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Values are true or false.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the lack of quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("druidBarAddon");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a string of the addon you use that keeps track of mana while shifting.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Value is 'DruidBar', 'Luna', or nil.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("   -You MUST have one of the two addons (DruidBar or Luna Unit Frames) for powershifting to work.");
		DEFAULT_CHAT_FRAME:AddMessage("isUseConsumables");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a true or false value that determines if you want the macro to automatically use mana consumables");
		DEFAULT_CHAT_FRAME:AddMessage("   such as mana potions, demonic runes, or night dragon's breath.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Values are true or false.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the lack of quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("isSelfInnervate");
		DEFAULT_CHAT_FRAME:AddMessage("   -This is a true or false value that determines if you want the macro to automatically use innervate on yourself.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Values are true or false.");
		DEFAULT_CHAT_FRAME:AddMessage("   -Note the lack of quotation marks.");
		DEFAULT_CHAT_FRAME:AddMessage("Example macro:");
		DEFAULT_CHAT_FRAME:AddMessage("   /script CatDruidDPS_main('Shred', 'Ravage', 'Ferocious Bite', true, 'DruidBar', true, true);");
	end;
	SLASH_CATDRUIDDPS1 = "/catdps";
end;

function CatDruidDPS_main(mainDamage, opener, finisher, isPowerShift, druidBarAddon, isUseConsumables, isSelfInnervate)
	local abilities = {"Ferocious Bite", "Rip", "Shred", "Claw", "Rake", "Ravage", "Pounce"};
	local cp = GetComboPoints();
	local cast = CastSpellByName;
	local energy = UnitMana("player");
	local cpMain = nil;
	local cpFinisher = nil;
	local clearcast = CatDruidDPS_isBuffTextureActive("Spell_Shadow_ManaBurn");
	local minEnergy = nil;
	local openerEnergy = 101;
	local ferocityNameTalent, ferocityIcon, ferocityTier, ferocityColumn, ferocityCurrRank, ferocityMaxRank = GetTalentInfo(2,1);
	local impShredNameTalent, impShredIcon, impShredTier, impShredColumn, impShredCurrRank, impShredMaxRank = GetTalentInfo(2,9);
	local natShifterNameTalent, natShifterIcon, natShifterTier, natShifterColumn, natShifterCurrRank, natShifterMaxRank = GetTalentInfo(1,7);
	local trinketLink1 = GetInventoryItemLink("player", 13);
	local trinketLink2 = GetInventoryItemLink("player", 14);
	local runeOfMetamorphosisTrinket = "Rune of Metamorphosis";
	local hasRuneOfMetamorphosisEquipped = nil;
	local runeOfMetamorphosisCooldown = nil;
	local slotId = GetInventorySlotInfo("RangedSlot");
	local itemLink = GetInventoryItemLink("player", slotId);
	local idolFerocity = "Idol of Ferocity";
	local idolCostReduction = 0;
	local canPowerShift = true;
	local shiftCost;
	local currentMana;
	local runeOfMetamorphosis = CatDruidDPS_isBuffTextureActive("INV_Misc_Rune_06");
	local innervateBuff = CatDruidDPS_isBuffTextureActive("Spell_Nature_Lightning");
	local _, innervateCooldown, _ = nil;
	local catForm = nil;
	local prowl = CatDruidDPS_isBuffTextureActive("Ability_Ambush");
	
	if(CatDruidDPS_getSpellId("Innervate") ~= nil) then 
		_, innervateCooldown, _ = GetSpellCooldown(CatDruidDPS_getSpellId("Innervate"), BOOKTYPE_SPELL); end;
	
	--find out if Rune of Metamorphosis is equipped and get its cooldown
	if(trinketLink1 ~= nil and hasRuneOfMetamorphosisEquipped == nil) then
		if(string.find(trinketLink1, runeOfMetamorphosisTrinket)) then 
			hasRuneOfMetamorphosisEquipped = 13;
			_, runeOfMetamorphosisCooldown, _ = GetInventoryItemCooldown("player", hasRuneOfMetamorphosisEquipped);
		end;
	end;
	if(trinketLink2 ~= nil and hasRuneOfMetamorphosisEquipped == nil) then
		if(string.find(trinketLink2, runeOfMetamorphosisTrinket)) then 
			hasRuneOfMetamorphosisEquipped = 14; 
			_, runeOfMetamorphosisCooldown, _ = GetInventoryItemCooldown("player", hasRuneOfMetamorphosisEquipped);
		end;
	end;

	--find out if Idol of Ferocity is equipped and set the reduction cost
	if(itemLink ~=nil) then
		if(string.find(itemLink, idolFerocity)) then idolCostReduction = 3; end;
	end;

	--set canPowerShift based on user inputs of isPowerShift and druidBarAddon
	if (isPowerShift ~= false) then isPowershift = true; end;
	if (druidBarAddon == "DruidBar") then
		shiftCost = DruidBarKey.subtractmana;
		currentMana = DruidBarKey.keepthemana;
		if(shiftCost <= currentMana or runeOfMetamorphosis == true or (isSelfInnervate == true and innervateCooldown == 0) or (isUseConsumables == true and (CatDruidDPS_canUseConsumable("potion") ~= nil or CatDruidDPS_canUseConsumable("nightdragon") ~= nil or CatDruidDPS_canUseConsumable("rune") ~= nil))) then canPowerShift = true;
		else canPowerShift = false; end;
	elseif (druidBarAddon == "Luna") then 
		local baseMana;
		local maxMana;
		local baseint, int = UnitStat("player", 4);
		currentMana, maxMana = LunaUF.DruidManaLib:GetMana();
		baseMana = maxMana - ( min(20, int) + 15*(int - min(20, int) ) );
		shiftCost = math.floor((baseMana * .55) * (1 - (natShifterCurrRank * .10)));
		if(shiftCost <= currentMana or runeOfMetamorphosis == true or (isSelfInnervate == true and innervateCooldown == 0) or (isUseConsumables == true and (CatDruidDPS_canUseConsumable("potion") ~= nil or CatDruidDPS_canUseConsumable("nightdragon") ~= nil or CatDruidDPS_canUseConsumable("rune") ~= nil))) then canPowerShift = true;
		else canPowerShift = false; end;
	end;

	--set energy requirements for main abilities
	if (mainDamage == abilities[3]) then
		cpMain = 60 - (impShredCurrRank * 6);
	elseif (mainDamage == abilities[5]) then
		cpMain = 40 - ferocityCurrRank - idolCostReduction;
	elseif (mainDamage == abilities[4]) then
		cpMain = 45 - ferocityCurrRank - idolCostReduction;
	else cpMain = 40;
	end;
	minEnergy = cpMain - 20;
	
	--set energy requirements for opener
	if(opener == abilities[6]) then openerEnergy = 60;
	elseif (opener == abilities[7]) then openerEnergy = 50;
	end;
	
	--set energy requirements for finisher
	if (finisher == abilities[1]) then cpFinisher = 35;
	else cpFinisher = 30;
	end;

	--get user's current form
	local currentForm = 0;
	for i = 1, GetNumShapeshiftForms(), 1
		do
			_,formName,active = GetShapeshiftFormInfo(i);
			if(formName == "Cat Form") then catForm = i; end;
			if(active ~= nil) then currentForm = i; end;
	end;

	--choose which action to perform
	if (currentForm == catForm and prowl == true and (energy >= openerEnergy or clearcast == true)) then cast(opener);
	elseif (currentForm == catForm and CatDruidDPS_findAttackActionSlot() == 0) then AttackTarget();
	elseif (currentForm == catForm and cp >= 5 and (energy >= cpFinisher or clearcast == true)) then 
		if(finisher == "Rip" and CatDruidDPS_isTargetDebuff("target", "Ability_GhoulFrenzy") == true) then finisher = "Ferocious Bite"; end;
		if(finisher == abilities[1] and energy >= 60) then
			cast(mainDamage);
		else
			cast(finisher);
		end;
	else if (currentForm == catForm and (energy >= cpMain or clearcast == true)) then 
		cast(mainDamage);
		if (currentForm == catForm and CatDruidDPS_findAttackActionSlot() == 0) then AttackTarget(); end;
	elseif (currentForm == catForm and energy < minEnergy and isPowerShift == true and canPowerShift == true) then 
		if(CatDruidDPS_findAttackActionSlot() ~= 0) then AttackTarget(); end;
		CastShapeshiftForm(currentForm);
	elseif (currentForm ~= catForm and currentForm ~= 0) then CastShapeshiftForm(currentForm);
	elseif (currentForm == 0) then 
		if (currentMana ~= nil and shiftCost ~= nil and hasRuneOfMetamorphosisEquipped ~= nil and runeOfMetamorphosisCooldown == 0 and (shiftCost * 1.7) > currentMana) then 
			UseInventoryItem(hasRuneOfMetamorphosisEquipped);
		elseif (currentMana ~= nil and shiftCost ~= nil and isSelfInnervate == true and innervateCooldown == 0 and (shiftCost * 1.7) > currentMana and runeOfMetamorphosis == false) then
			cast("Innervate", 1);
		elseif (currentMana ~= nil and shiftCost ~= nil and isUseConsumables == true and shiftCost > currentMana and innervateBuff == false and runeOfMetamorphosis == false) then 
			if (CatDruidDPS_canUseConsumable("potion")) then CatDruidDPS_UseManaPotion();
			elseif (CatDruidDPS_canUseConsumable("rune")) then CatDruidDPS_UseNightDragonOrRune("rune");
			elseif (CatDruidDPS_canUseConsumable("lily root")) then CatDruidDPS_UseNightDragonOrRune("lily root");
			elseif (CatDruidDPS_canUseConsumable("nightdragon")) then CatDruidDPS_UseNightDragonOrRune("nightdragon");
			end;
		else CastShapeshiftForm(catForm);
		end;
	end; end;	
end;

--returns action bar slot id of Auto Attack if it is currently active (blinking)
function CatDruidDPS_findAttackActionSlot()
	for i = 1, 120, 1
		do
		if(IsAttackAction(i) == 1 and IsCurrentAction(i) == 1) then
		return i; end;
	end;
	return 0;
end;

--returns boolean of whether or not the target is currently affected by a specified debuff
function CatDruidDPS_isTargetDebuff(target, debuff)
	local isDebuff = false;
	for i = 1, 40
		do
		if(strfind(tostring(UnitDebuff(target,i)), debuff)) then isDebuff = true; end;
	end;
	return isDebuff;
end;

--use a Mana Potion based on what is in user's inventory
function CatDruidDPS_UseManaPotion()
	local zone = GetRealZoneText();
	local msg = nil;
	local bag, slot = nil;
	local _, duration, _ = nil;
	local manaPotion = {'Superior Mana Draught', 'Major Mana Potion', 'Combat Mana Potion', 'Superior Mana Potion', 'Greater Mana Potion', 'Mana Potion', 'Lesser Mana Potion', 'Minor Mana Potion'};

	--if in a BG and user has a BG specific Mana Potion, use it
	if (CatDruidDPS_getSlotItemInBag(manaPotion[1]) ~= nil and (zone == "Warsong Gulch" or zone == "Alterac Valley" or zone == "Arathi Basin")) then
		use(manaPotion[1]); msg = tostring(manaPotion[1]);

	--else use the most powerful Mana Potion available
	else
		for i = 2, table.getn(manaPotion), 1
			do
			bag, slot = CatDruidDPS_getSlotItemInBag(manaPotion[i]);
			if(bag ~= nil and slot ~= nil) then
				_, duration, _ = GetContainerItemCooldown(bag, slot);
				if(duration == 0) then use(manaPotion[i]); msg = tostring(manaPotion[i]); break; end;
			end;
		end;		
		if(msg == nil) then msg = "No Mana Potion"; end;
	end;
	
	DEFAULT_CHAT_FRAME:AddMessage("CatDruidDPS: "..msg.." used!");
end;

--use a Night Dragon's Breath or a mana Rune item
function CatDruidDPS_UseNightDragonOrRune(consumableType)
	local nightDragon = "Night Dragon's Breath";
	local lilyRoot = "Lily Root";
	local demonRune = {"Demonic Rune", "Dark Rune"};
	local msg = nil;
	
	if(consumableType == "lily root") then use(lilyRoot); msg = tostring(lilyRoot);
	elseif(consumableType == "nightdragon") then use(nightDragon); msg = tostring(nightDragon);
	elseif(consumableType == "rune") then
		if(CatDruidDPS_getSlotItemInBag(demonRune[1]) ~= nil) then use(demonRune[1]); msg = tostring(demonRune[1]);
		elseif(CatDruidDPS_getSlotItemInBag(demonRune[2]) ~= nil) then use(demonRune[2]); msg = tostring(demonRune[2]);
		end;
	else msg = "No Night Dragon's Breath nor Rune";
	end;	
	DEFAULT_CHAT_FRAME:AddMessage("CatDruidDPS: "..msg.." used!");
end;

--searchs user's inventor and returns the bag and slot of the item if found, else returns nil, nil
function CatDruidDPS_getSlotItemInBag(itemName)
	local found = false;
	local id1 = nil;
	local id2 = nil;
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
					if string.find(name2, itemName) == 1 then id1 = bag; id2 = slot; break; end;
				end;
			end;
		end;
	return id1, id2;	
end;

--based on input of consumableType, returns a string of the item that can be used, nil if not
function CatDruidDPS_canUseConsumable(consumableType)
	local currentHealth = UnitHealth("player");
	local manaPotion = {'Superior Mana Draught', 'Major Mana Potion', 'Combat Mana Potion', 'Superior Mana Potion', 'Greater Mana Potion', 'Mana Potion', 'Lesser Mana Potion', 'Minor Mana Potion'};
	local nightDragon = "Night Dragon's Breath";
	local demonRune = {"Demonic Rune", "Dark Rune"};
	local lilyRoot = "Lily Root";
	
	if(consumableType == "potion") then 
		for i = 1, table.getn(manaPotion), 1
			do
			bag, slot = CatDruidDPS_getSlotItemInBag(manaPotion[i]);
			if(bag ~= nil and slot ~= nil) then
				_, duration, _ = GetContainerItemCooldown(bag, slot);
				if(duration == 0) then return tostring(manaPotion[i]); end;
			end;
		end;
	elseif(consumableType == "nightdragon") then
		bag, slot = CatDruidDPS_getSlotItemInBag(nightDragon);
		if(bag ~= nil and slot ~= nil) then
			_, duration, _ = GetContainerItemCooldown(bag, slot);
			if(duration == 0) then return tostring(nightDragon); end;
		end;
	elseif(consumableType == "lily root") then
		bag, slot = CatDruidDPS_getSlotItemInBag(lilyRoot);
		if(bag ~= nil and slot ~= nil) then
			_, duration, _ = GetContainerItemCooldown(bag, slot);
			if(duration == 0) then return tostring(lilyRoot); end;
		end;
	elseif(consumableType == "rune") then
		for i = 1, table.getn(demonRune), 1
			do
			bag, slot = CatDruidDPS_getSlotItemInBag(demonRune[i]);
			if(bag ~= nil and slot ~= nil) then
				_, duration, _ = GetContainerItemCooldown(bag, slot);
				if(duration == 0 and currentHealth > 1502) then return tostring(demonRune[i]); end;
			end;
		end;
	end;
	return nil;
end;

--returns id of a spell from player's spellbook
function CatDruidDPS_getSpellId(spell)
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

--returns true or false if a buff texture is currently active on the player
function CatDruidDPS_isBuffTextureActive(texture)
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