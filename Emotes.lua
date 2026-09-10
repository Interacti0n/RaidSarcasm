local addonName, ns = ...

-- Lost Tank
local lostTanks = {
    "fires a flare gun at %t so they can finally find their way back to the boss.",
    "asks %t if the wall they are currently staring at said something offensive.",
    "opens a map of Azeroth and tries to point out to %t where the raid is.",
    "hands %t a GPS navigation system because their tanking style looks like orienteering.",
    "drops a trail of gold coins to lure %t back into the active combat zone.",
    "asks %t if they need directions or just a moment to enjoy the scenery.",
    "marks the boss on %t's map in very large friendly letters.",
    "wonders whether %t is tanking a completely different encounter.",
    "sends a search party to recover %t from the far side of the room.",
    "reminds %t that the boss is usually found near the rest of the raid."
}

-- Low DPS
local lowDps = {
    "applauds %t for a flawless dance in the mechanics, though it's a shame they are only tickling the boss.",
    "checks to see if %t accidentally equipped a foam sword from the Darkmoon Faire.",
    "gently reminds %t that the boss is not immune to damage, so they are free to start hitting it.",
    "notes that %t's damage meter looks like the heart monitor of someone who is legally dead.",
    "hands %t a small bell to shake, since it would contribute more to the fight than their current rotation.",
    "checks whether %t's damage meter is displaying values in single digits.",
    "assures %t that auto-attack is only the beginning of the rotation.",
    "asks %t if their damage cooldowns are being saved for the next raid.",
    "praises %t for giving the boss such a gentle and relaxing fight.",
    "looks closely at the meters to confirm that %t is actually connected."
}

-- No Threat
local zeroThreat = {
    "admires %t's absolute invincibility, even if their DPS looks like an aggressive pillow fight.",
    "suggests %t try hitting the boss next time, rather than just glaring at it judgmentally from behind a shield.",
    "asks %t if they are saving their threat-generating abilities for the next expansion.",
    "hands %t a calculator to show them that 0 damage equals 0 threat.",
    "whispers to %t: 'The boss isn't afraid of your shield, they are just confused by your lack of threat.'",
    "asks the boss to please notice %t standing bravely nearby.",
    "checks whether %t selected the invisible threat talent.",
    "offers %t a strongly worded sign saying 'Please attack me'.",
    "watches the boss walk past %t without even asking for directions.",
    "reminds %t that looking intimidating is not part of the threat formula."
}

-- Standing in Fire
local standingInFire = {
    "offers %t a chair, since they seem determined to stay in the fire for a while.",
    "asks %t whether the glowing floor comes with a loyalty program.",
    "watches %t discover that standing in fire is, in fact, bad for their health.",
    "checks whether %t mistook the fire for a personal haste buff.",
    "politely informs %t that the red circle is not a summoning portal to better DPS.",
    "asks %t if the fire is warm enough or if they would like another stack.",
    "watches %t test whether the healer has unlimited mana.",
    "points out the many excellent places where %t could stand that are not on fire.",
    "awards %t a loyalty card for their tenth visit to the same fire patch.",
    "reminds %t that orange is a warning color, not a parking spot."
}

-- Missed Interrupt
local missedInterrupt = {
    "checks whether %t left their interrupt in the bank.",
    "congratulates %t on giving the boss enough time to finish their entire presentation.",
    "asks %t if their interrupt button is purely decorative.",
    "watches %t respect the boss's right to uninterrupted spellcasting.",
    "hands %t a calendar so they can schedule the next interrupt in advance.",
    "asks %t whether the cast bar was moving too quickly to notice.",
    "thanks %t for letting the boss express themselves without interruption.",
    "checks whether %t's interrupt is still safely wrapped in its original packaging.",
    "wonders if %t is waiting for the cast bar to ask nicely.",
    "reminds %t that interrupting the boss will not hurt the boss's feelings."
}

-- Early Pull
local earlyPull = {
    "thanks %t for starting the fight before everyone was burdened by being ready.",
    "asks %t which part of the countdown sounded like 'go now'.",
    "admires %t's confidence in treating the ready check as optional reading.",
    "notes that %t has once again confused patience with a DPS loss.",
    "awards %t first place in the race nobody knew had started.",
    "checks whether %t's pull timer only has one number: now.",
    "thanks %t for testing how quickly the raid can panic.",
    "asks %t if waiting three seconds caused unacceptable emotional damage.",
    "notes that %t has discovered a bold new alternative to communication.",
    "watches %t pull first and prepare the explanation second."
}

-- Floor Inspector
local floorInspector = {
    "thanks %t for conducting another thorough inspection of the dungeon floor.",
    "asks %t to report whether the floor texture looks better up close.",
    "places a tiny plaque beside %t reading: 'Here lies another learning opportunity.'",
    "notes that %t has achieved excellent uptime on being dead.",
    "checks whether %t is waiting for the floor boss to drop loot.",
    "asks %t to move over so the living players can see the mechanic.",
    "congratulates %t on finding the safest possible rotation: none at all.",
    "checks whether %t's new role is decorative raid marker.",
    "reminds %t that lying down is usually reserved for after the raid.",
    "asks %t if the floor has shared any useful strategy advice yet."
}

-- Raid Tourist
local raidTourist = {
    "offers %t a souvenir after their guided tour of every avoidable mechanic.",
    "asks %t to stop taking screenshots and help with the boss.",
    "welcomes %t to the raid and reminds them that participation is included in the ticket price.",
    "watches %t admire the scenery while the rest of the raid handles the encounter.",
    "hands %t a brochure titled 'Things to Do Here Besides Watching'.",
    "asks %t whether the boss fight is included in their sightseeing package.",
    "points %t toward the gift shop after their scenic lap around the room.",
    "checks whether %t came for the raid or simply enjoyed the loading screen.",
    "invites %t to try the interactive part of the encounter.",
    "thanks %t for observing the raid in its natural habitat."
}

-- Missed Mechanic
local missedMechanic = {
    "asks %t if the mechanic was too subtle with all the flashing lights and warnings.",
    "watches %t discover the encounter one mechanic at a time.",
    "hands %t a strategy guide with the important part highlighted in bright red.",
    "congratulates %t on finding the one mechanic everyone agreed to avoid.",
    "checks whether %t interpreted 'move away' as a personal suggestion.",
    "asks %t if the giant warning needed a few more exclamation marks.",
    "notes that %t has chosen the experimental version of the strategy.",
    "watches %t turn a simple mechanic into an exciting raid event.",
    "reminds %t that boss abilities are instructions, not collectibles.",
    "awards %t bonus points for experiencing the mechanic at maximum intensity."
}

-- AFK Moment
local afkMoment = {
    "waves a hand in front of %t to check whether anyone is home.",
    "asks %t to press any key to continue participating in the raid.",
    "checks whether %t has entered an extremely focused meditation.",
    "places a small loading icon above %t and waits patiently.",
    "wonders whether %t is fighting the boss through the power of positive thinking.",
    "reminds %t that being present is the first step of doing damage.",
    "asks %t if their keyboard has entered sleep mode too.",
    "checks whether %t is buffering in real life.",
    "thanks %t for providing a reliable reference point in the moving raid.",
    "offers %t a complimentary wake-up call before the next pull."
}

-- Both the menu and slash commands are generated from this ordered registry.
ns.categories = {
    { id = "losttank", label = "Lost Tank", command = "/losttank", messages = lostTanks },
    { id = "lowdps", label = "Low DPS", command = "/badplay", messages = lowDps },
    { id = "nothreat", label = "No Threat", command = "/nothreat", messages = zeroThreat },
    { id = "fire", label = "Standing in Fire", command = "/rsfire", messages = standingInFire },
    { id = "interrupt", label = "Missed Interrupt", command = "/rsinterrupt", messages = missedInterrupt },
    { id = "earlypull", label = "Early Pull", command = "/rspull", messages = earlyPull },
    { id = "floor", label = "Floor Inspector", command = "/rsdead", messages = floorInspector },
    { id = "tourist", label = "Raid Tourist", command = "/rstourist", messages = raidTourist },
    { id = "mechanic", label = "Missed Mechanic", command = "/rsmechanic", messages = missedMechanic },
    { id = "afk", label = "AFK Moment", command = "/rsafk", messages = afkMoment },
}
