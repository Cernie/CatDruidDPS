# CatDruidDPS
One button feral druid dps macro for vanilla wow

This addon adds macro functions necessary for a druid to use for maximum dps while leveling, in dungeons/raids or for fun. While there are inputs for the user to customize, there are also checks the addon automatically does such as:
- Determines ability costs for the druid based on talents and gear (idol slot).
- Detects and automatically uses Rune of Metamorphosis when low on mana.

To use, create a macro that uses the following signature:
/script CatDruidDPS_main(mainDamage, opener, finisher, isPowerShift, druidBarAddon, isUseConsumables, isSelfInnervate)
- This addon also requires you have the Attack ability somewhere on your action bars.

Description of parameters (inputs to the macro)
- mainDamage
   - This is a string of the ability you wish to use in combo point generation.
   - Examples are "Shred", "Rake", and "Claw".
   - Note the quotation marks.
- opener
  - This is a string of the ability to use as an opener ability.
  - Examples are "Ravage" and "Pounce".
  - Note the quotation marks.
finisher
  - This is a string of the ability to use as a finishing ability that consumes combo points.
  - Examples are "Rip" and "Ferocious Bite".
  - Note the quotation marks.
isPowerShift
  - This is a true or false value that determines if you want to enable powershifting with the macro.
  - Values are true or false.
  - Note the lack of quotation marks.
druidBarAddon
  - This is a string of the addon you use that keeps track of mana while shifting.
  - Value is "DruidBar", "Luna", or nil.
  - Note the quotation marks.
  - You MUST have one of the two addons (DruidBar or Luna Unit Frames) for powershifting to work.
isUseConsumables
  - This is a true or false value that determines if you want the macro to automatically use mana consumables.
    such as mana potions, demonic runes, or night dragon's breath.
  - Values are true or false.
  - Note the lack of quotation marks.
isSelfInnervate
  - This is a true or false value that determines if you want the macro to automatically use innervate on yourself.
  - Values are true or false.
  - Note the lack of quotation marks.
Example macro:
- /script CatDruidDPS_main("Shred", "Ravage", "Ferocious Bite", true, "DruidBar", true, true);
