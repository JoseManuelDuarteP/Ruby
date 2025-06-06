#===============================================================================
# Mobius' Charge Turn Battle System
# Author: Mobius XVI
# Version: 1.5
# Date: 11 AUG 2023
#===============================================================================
#
# Introduction:
#
#   This script overhauls the default battle system and replaces it with a
#   "CTB" system similar to Final Fantasy Tactics and Final Fantasy X.
#   Battlers now use their speed to charge up a hidden turn gauge, and
#   when it's full, they get a turn immediately. This causes turns to alternate
#   in a semi-predictable order, making for a more strategic battle system.
#
# Instructions:
#
#  - Place this script below all the default scripts but above main.
#
#  - Import the enemy icon pictures into your project, and place them in
#    the "pictures" folder.
#
#  - The customization section below has additional instructions on
#    how you can set certain preferences up to your liking.
#
#  - Below the customization section are additional expansions that you can
#   select along with their own customization options.
#
# Issues/Bugs/Possible Bugs:
#
#   - As this script basically replaces the default battle system, it
#     will likely be incompatible with other battle system scripts.
#
#  Credits/Thanks:
#    - Mobius XVI, author
#    - TheRiotInside, for testing/feedback/suggestions
#    - Mudkicker, for suggesting customizable turn icons
#    - CarlosDavilla, for suggesting customizable element lists
#
#  License
#    This script is licensed under the MIT license, so you can use it for both commercial and non-commercial games!
#    Check the included license file for the full text.
#    Further, if you do decide to use this script in a commercial product, I'd ask that you
#    let me know via a forum post or a PM. Thanks.
#
#==============================================================================
# ** CUSTOMIZATION START
#==============================================================================
module Mobius
 module Charge_Turn_Battle
  # CHARGE_RATE lets you set a formula for how a charge bar will fill.
  # Keep in mind that this will all happen behind the scenes, so it won't
  # effect how "quickly" it will fill in real time.
  # Your formula must be contained between two quotation
  # marks, i.e. "your formula". Formulas are valid provided they make
  # mathematical sense. You can use any integer numbers, mathematical symbols
  # like +, -, *, /, or ** for exponentiation. You can also use the following
  # list of keywords to get a battler's stat:
  # hp = current HP ; sp = current SP ; maxhp = Max HP ; maxsp = Max SP
  # str = strength ; dex = dexterity ; agi = agility ; int = intelligence
  # atk = attack ; pdef = physical defence ; mdef = magical defence ; eva = evasion
  # here are some example formulas
  # "(10 * str) / (agi + 7)"
  # "(maxhp - hp) * 100 / (5 + eva**2)"
  CHARGE_RATE = "(5 + agi/5)"

  # CHARGE_BAR_TOTAL is the numerical amount that the charge bar must reach
  # before a battler gets a turn. Between this and the CHARGE_RATE, you can affect
  # how often a battler gets an "extra" turn. As an example, say you have two battlers
  # A and B with agilities of 5 and 10 respectively. Further, let's say the CHARGE_RATE
  # is just "agi" and the CHARGE_BAR_TOTAL is 100. Both battlers will start with a charge
  # bar of 0, and then fill them up behind the scenes until A has 50 and B has 100.
  # B then gets a turn, and his charge bar resets to 0. The bars fill up until A has 100
  # and B has 100. A gets a turn, then B gets a turn, and both bars reset to 0. So you can
  # see how B will essentially get two turns for every turn that A gets.
  CHARGE_BAR_TOTAL = 100

  # SPEED_FACTORS allow you to set bonuses/penalites for certain actions. Normally,
  # after a battler gets a turn their charge bar gets reset to 0. However, based on what
  # action they just performed, you can adjust it positively or negatively. So if you set
  # a speed factor of 10 for "defend", whenever a battler defended on their turn, their
  # charge bar would get reset to 0 then immediately get 10 points added back to it.
  # This of course would mean they'll get their next turn sooner. You could also apply
  # speed penalties for "slow" attacks. Say you have a skill that deals massive damage,
  # but would fatigue the battler. You could set a speed factor of -10 and then after
  # they executed the attack, their charge bar would get reset to 0 and then immediately
  # have 10 points removed.

  # DEFEND_SPEED_FACTOR sets the bonus/penalty for defending.
  DEFEND_SPEED_FACTOR = 0
  # ESCAPE_SPEED_FACTOR sets the bonus/penalty for attempting to escape and failing.
  ESCAPE_SPEED_FACTOR = 0
  # NOTHING_SPEED_FACTOR sets the bonus/penalty for doing nothing (only used by enemies).
  NOTHING_SPEED_FACTOR = 0
  # WEAPON_SPEED_FACTORS allow you to give individual weapons a bonus/penalty.
  # Note that the speed factor will only be applied when a battler performs a basic attack.
  # To set this up, place the weapon ID followed by an arrow "=>" and then the speed factor
  # inside of the curly brackets. Separate entries by a comma. The entries can span multiple
  # lines so long as all entries are surrounded by the start and end curly brackets.
  # Example: { 1 => 10, 2 => 5 }
  # You don't need to set a speed factor for every weapon if you don't want to. Any weapon
  # not explicitly given a speed factor here will use the "default" value on the next line.
  WEAPON_SPEED_FACTORS = {}
  # The default line sets the speed factor for any weapon not included above.
  WEAPON_SPEED_FACTORS.default = 0
  # SKILL_SPEED_FACTORS is identical in set up to WEAPON_SPEED_FACTORS but for skills.
  SKILL_SPEED_FACTORS = {}
  SKILL_SPEED_FACTORS.default = 0
  # ITEM_SPEED_FACTORS is identical in set up to WEAPON_SPEED_FACTORS but for items.
  ITEM_SPEED_FACTORS = {}
  ITEM_SPEED_FACTORS.default = 0

  # You can designate certain enemies as "bosses". This will change how their names are
  # displayed as well as the icon shown for them in the turn order window.
  # To set this up, all you need to do is list all of the enemies' IDs, separated by commas,
  # inside of the square brackets.
  BOSS_LIST = []

  # The following options all allow you to set display words similar to how you can set
  # custom words in the database for HP, SP, etc.
  ESCAPE_WORD = "Escape"
  BATTLERS_WORD = "Battlers"
  STATUS_WORD = "Status"
  MAXHP_WORD = "MAXHP"
  MAXSP_WORD = "MAXSP"

  # The battle system comes with a collection of turn icons to use. However, you don't
  # have to use those if you don't want. As long as you leave the names unchanged, you
  # can modify them however you want. But keep in mind that only 32x48 (width x height)
  # pixels will be shown. But let's say you'd rather have unique icons for each actor
  # and/or each enemy. Then these options are for you.

  # Set this option to "true" to enable unique icons for each actor.
  USE_ACTOR_PICTURES = false
  # If you've set the above to true, then you need to place an icon for each actor in
  # the "Pictures" folder. The names for each picture should be "ActorNameActorSuffix"
  # You can set the suffix below. The default is "_Turn_Order_Icon". So "Aluxes" icon
  # would need to be named "Aluxes_Turn_Order_Icon". The icons can be any supported image
  # format (i.e. png, jpg, etc). Keep in mind that only 32x48 (width x height) pixels will be shown.
  ACTOR_PICTURES_SUFFIX = "_Turn_Order_Icon"
  # Set this option to "true" to enable unique icons for each enemy.
  USE_ENEMY_PICTURES = false
  # If you've set the above to true, then you need to place an icon for each enemy in
  # the "Pictures" folder. The names for each picture should be "EnemyNameEnemySuffix"
  # You can set the suffix below. The default is "_Turn_Order_Icon". So "Ghost" icon
  # would need to be named "Ghost_Turn_Order_Icon". The icons can be any supported image
  # format (i.e. png, jpg, etc). Keep in mind that only 32x48 (width x height) pixels will be shown.
  ENEMY_PICTURES_SUFFIX = "_Turn_Order_Icon"
  # If any image can't be found, a 32x32 box of the below color will be drawn instead.
  # You can change the numbers to change the color. The numbers are RGB values.
  # I recommend you just leave this black, but I realize that might be hard to see
  # for some people so you can change it if need be.
  MISSING_GRAPHIC_COLOR = Color.new(0, 0, 0)

  # When showing the enemy's name during battle, the battle system can be set to
  # automatically add a prefix based on the enemy's index. This way the player can
  # distinguish between Ghost A and Ghost B for example.
  # Set this to "true" to enable the prefixes; set this to "false" to disable it.
  USE_ENEMY_PREFIX = true
  # If you are using prefixes, you can customize how they are displayed.
  # Simply place your prefixes, separated by commas, in between the quotes.
  # Keep in mind that this is very literal, so spaces count.
  # Also, if you don't have eight different prefixes, then some enemies just
  # won't get a prefix.
  # Lastly, you don't need to worry about this if you've set the above option to false.
  ENEMY_PREFIX = "A: ,B: ,C: ,D: ,E: ,F: ,G: ,H: "
  # If you are using prefixes, you can customize how they are displayed.
  # Any enemy tagged as a "boss" in the "BOSS_LIST" above will get this prefix
  # instead of a normal prefix.
  # Keep in mind that this is very literal, so spaces count.
  # Lastly, you don't need to worry about this if you've set the above option to false.
  ENEMY_BOSS_PREFIX = "Boss: "
 end
end
#==============================================================================
# ** SCAN SKILL SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
 module Scan_Skill
  #==============================================================================
  # Because this battle system is designed to more tactical than the default system, a
  # scan skill is basically a necessity to allow you to track an enemy's HP/SP.
  # To set this up, first create a skill to perform scan in the database. Second,
  # create a state for scan in the database. The skill and state can be configured however
  # you want just make sure that the scan skill applies the scan state to the enemy when used.
  # Once you've done that, set this option to the ID of the scan state that you created.
  # Then whenever an enemy has the scan state applied, you'll be able to see their HP/SP
  # when targeting them.
  SCAN_STATE_ID = 17
  # OPTIONAL: If you would like a pop-up to be displayed when you use the skill for the
  # first time, then you can do the following additional steps. Create a common event
  # called scan, and add a "script" command to it. Inside the script command, put
  # "Mobius.scan_skill_popup" without quotes. Then simply add the common event to the scan skill
  # you created earlier, and you're done!
  #==============================================================================
 end
end
#==============================================================================
# ** STATUS_ICONS SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
 module Status_Icons
  #==============================================================================
  # The STATUS_ICONS expansion will display icons in the status area for users
  # and enemies during battle rather than the default plain text. The icons can
  # be any size, but 24x24 is optimal. Anything taller than 32 pixels will have
  # parts of the top and bottom cutoff as it will center the icon. With a width
  # of 24 pixels, you should be able to fit five icons. Additionally, the states
  # will be displayed with the normal priority set by the database and states with
  # a priority of zero will not be displayed.
  # To enable the "status icons" expansion, set STATUS_ICONS below to "true"
  #==============================================================================
  # Set this option to "true" to enable this expansion
  STATUS_ICONS_ENABLED = false
  # If you've set the above to true, then you need to place an icon for each status in
  # the "Icons" folder by default but this can be changed if desired.
  # The names for each icon should be "StatusNameStatusSuffix"
  # You can set the suffix below. The default is "_Status_Icon". So "Blind" icon
  # would need to be named "Blind_Status_Icon". The icons can be any supported image
  # format (i.e. png, jpg, etc). Keep in mind that only 24x24 (width x height) pixels will be shown.
  STATUS_ICON_SUFFIX = "_Status_Icon"
  # Here you can set the path to the status icons. Note that it is local to the project folder.
  STATUS_ICON_PATH = "Graphics/Icons/"
 end
end
#==============================================================================
# ** BEASTIARY SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
 module Beastiary
  #==============================================================================
  # The BEASTIARY expansion has two parts - a standalone scene that a player could
  # use to review information on previous foes, and an expanded info window that
  # displays during battle similar to FFXIII. To access the standalone scene,
  # use the script call "$scene = Scene_Beastiary.new". To access the info window,
  # you can set a dedicated button below in the INPUT SETTINGS. Note that a player
  # will have to be selecting an enemy for the button to work.
  # Currently, the beastiary is tightly tied to the scan skill. So if you haven't
  # set one up, please review the instructions above on how to do that.
  # Furthermore, you'll need to add another script call to the scan skill in order
  # for enemies to show up in the standalone beastiary. Inside the script command,
  # put "Mobius.scan_skill" without quotes.
  # For additional setup and configuration, see the below instructions.
  #==============================================================================
  # Set this option to "true" to enable this expansion
  BEASTIARY_ENABLED = true
  # The standalone beastiary has room for 384x384 sprite of the enemy.
  # For most enemies, this is sufficient to display the entire sprite but it
  # may not work for extra large enemies. To work around this, you can create
  # alternate display sprites. The names for each sprite should be "EnemyNameSpriteSuffix".
  # You can set the suffix below. The default is "_Beastiary_Sprite". So "Ghost" sprite
  # would need to be named "Ghost_Beastiary_Sprite". The icons can be any supported image
  # format (i.e. png, jpg, etc). Keep in mind that only 384x384 pixels will be shown.
  # Any enemy without a special sprite will use it's normal one, so you only need
  # to worry about the enemies with really big sprites.
  BEASTIARY_SPRITE_SUFFIX = "_Beastiary_Sprite"
  # By default, the script looks for special sprites in the "Pictures" folder.
  # You can change that by configuring the path below.
  # Note that the path is local to the project directory.
  BEASTIARY_SPRITE_PATH = "Graphics/Pictures/"
  # The beastiary window draws some divider lines which by default are colored
  # white. You can change the color to whatever you want by setting the below
  # numbers to your desired R,G,B values.
  DIVIDER_LINE_COLOR = Color.new(255,255,255)
  # When naming an enemy's stats, the script will use whatever you have set in
  # the database, but there is no place in the database for an "EVA" word, so
  # you can set it below.
  EVASION_WORD = "EVA"
  # When closing the beastiary, it will default to opening the menu.
  # This behavior assumes that you've set up your menu to allow accessing
  # the beastiary (which you can do with my Menu Command Manager).
  # If you'd rather have it exit to the map, you can set this to false
  EXIT_TO_MENU = true
  # Here you can configure the descriptors for the various beastiary pages
  SPRITE_PAGE  = "Image"
  STATS_PAGE   = "Stats/Bio"
  ELEMENT_PAGE = "Elements"
  STATUS_PAGE  = "Statuses"
  # Here you can configure the descriptors for the various element efficiencies
  ELEMENT_WORD_200  = "Helpless"  # Rank A
  ELEMENT_WORD_150  = "Weak"      # Rank B
  ELEMENT_WORD_100  = "Normal"    # Rank C
  ELEMENT_WORD_50   = "Resistant" # Rank D
  ELEMENT_WORD_0    = "Immune"    # Rank E
  ELEMENT_WORD_M100 = "Absorbs"   # Rank F
  # Here you can configure the descriptors for the various status efficiencies
  STATUS_WORD_100   = "Helpless"  # Rank A
  STATUS_WORD_80    = "Weak"      # Rank B
  STATUS_WORD_60    = "Normal"    # Rank C
  STATUS_WORD_40    = "Resistant" # Rank D
  STATUS_WORD_20    = "Hardened"  # Rank E
  STATUS_WORD_0     = "Immune"    # Rank F
  # Set this to true if you want to display a numeric ID before
  # each beast in the beastiary's list e.g. "001: Ghost"
  DISPLAY_ID = true
  # This setting does nothing if DISPLAY_ID is false
  # Set this to true to display a numeric ID that always matches
  # what's in the database. Leave this false to allow the script
  # to automatically determine an appropriate ID.
  # Mostly useful for debugging.
  DISPLAY_DATABASE_ID = false
  # You may want to hide certain beasts from displaying in the beastiary.
  # If that's the case, simply list the IDs of the beasts below,
  # separating them by commas, e.g. [1,2,3]
  HIDDEN_BEASTS = []
  # You may want to hide certain elements from displaying in the beastiary.
  # If that's the case, simply list the IDs of the elements below,
  # separating them by commas, e.g. [1,2,3]
  HIDDEN_ELEMENTS = []
  # You may want to hide certain states from displaying in the beastiary.
  # If that's the case, simply list the IDs of the states below,
  # separating them by commas, e.g. [1,2,3]
  HIDDEN_STATES = []
  # Here you can enter short biographies for each beast.
  # To set this up, place the enemy ID followed by an arrow "=>" and then the bio.
  # The bio can consist of up to 7 lines. All lines should be surrounded with square
  # brackets [] and separated by commas. Keep in mind that lines that are too
  # long will get automatically squished to try and fit.
  BIOGRAPHIES = {
    1 => [
      "Ghosts are the spirits of those who",
      "died with unfinished business in life"
    ],
    4 => [
      "Hellhounds are the guardians of the",
      "underworld who have abandoned their posts.",
      "Now they wander the wilderness preying",
      "upon hapless travellers.",
    ]
  }
  BIOGRAPHIES.default = []
 end
end
#==============================================================================
# ** INPUT SETTINGS
#------------------------------------------------------------------------------
# This section lets you customize input control settings.
#==============================================================================
module Input
 # The battle system has a few additional windows that can be opened/closed/controlled
 # during battle, and therefore need their own buttons. You can customize what
 # those buttons are here. Remember these are not keys on the keyboard but the
 # built-in "buttons". If you press F1 while playing, you can change what keyboard
 # key is linked to what "button". Valid options are A, R, L, X, Y, or Z.
 # The options should be entered with formatting (like they are below).
 BATTLE_STATUS_ACCESS_BUTTON = A
 BEASTIARY_BATTLE_ACCESS_BUTTON = A
 TURN_WINDOW_DRAW_DOWN_BUTTON = R
 TURN_WINDOW_DRAW_UP_BUTTON = L
end
#==============================================================================
# ** CUSTOMIZATION END
#------------------------------------------------------------------------------
# ** EDIT BELOW THIS LINE AT OWN RISK!!!
#==============================================================================
#==============================================================================
# ** Data Check
#------------------------------------------------------------------------------
#  This section runs a check on all customization options to ensure that
#  they are valid.
#==============================================================================
#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  Add two new concepts to the Game_Battler class
#    @charge_gauge
#      This represents how close a battler is to their next turn.
#      Ranges from 0-100.
#      When this value reaches 100, the battler gets a turn.
#    @charge_gauge_dummy
#      This is used to calculate future turns, and isn't "real".
#      We can freely manipulate this value to forecast out turn order.
#  Adjusts how states are removed to be compatible with new turn structure
#==============================================================================
class Game_Battler
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_accessor :charge_gauge             # charge gauge
 attr_accessor :charge_gauge_dummy       # charge gauge dummy
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 alias mobius_ctb_game_battler_initialize initialize
 def initialize
  mobius_ctb_game_battler_initialize
  @charge_gauge = 0
  @charge_gauge_dummy = 0
 end
 #--------------------------------------------------------------------------
 # * Charge -- Increases a battler's actual charge gauge
 #--------------------------------------------------------------------------
 def charge
  @charge_gauge += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)
 end
 #--------------------------------------------------------------------------
 # * Dummy Charge -- Increases a battler's dummy charge gauge for use
 #   in calculating turn order
 #--------------------------------------------------------------------------
 def dummy_charge
  @charge_gauge_dummy += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)
 end
 #--------------------------------------------------------------------------
 # * Dummy Charge Copy -- Sets a battler's dummy gauge equal to normal gauge
 #--------------------------------------------------------------------------
 def dummy_charge_copy
  @charge_gauge_dummy = @charge_gauge
 end
 #--------------------------------------------------------------------------
 # * Charge Reset -- Resets a battler's charge gauge to zero +/- speed_factor
 #--------------------------------------------------------------------------
 def charge_reset
  @charge_gauge -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
  @charge_gauge += speed_factor
 end
 #--------------------------------------------------------------------------
 # * Dummy Charge Reset -- Resets a battler's dummy charge gauge to zero
 #--------------------------------------------------------------------------
 def dummy_charge_reset
  @charge_gauge_dummy -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
 end
 #--------------------------------------------------------------------------
 # * Charge Clear -- Clears out a battler's charge/dummy charge at battle end
 #--------------------------------------------------------------------------
 def charge_clear
  @charge_gauge = 0
  @charge_gauge_dummy = 0
 end
 #--------------------------------------------------------------------------
 # * Speed Factor -- Returns a battler's speed_factor
 #--------------------------------------------------------------------------
 def speed_factor
  case @current_action.kind
   # When basic ( attack / defend / escape / nothing )
  when 0
   case @current_action.basic
    # When attack
   when 0
    # Get speed factor from hash: WEAPON_SPEED_FACTORS
    return Mobius::Charge_Turn_Battle::WEAPON_SPEED_FACTORS[@weapon_id]
    # When defend
   when 1
    return Mobius::Charge_Turn_Battle::DEFEND_SPEED_FACTOR
    # When escape
   when 2
    return Mobius::Charge_Turn_Battle::ESCAPE_SPEED_FACTOR
    # When nothing
   when 3
    return Mobius::Charge_Turn_Battle::NOTHING_SPEED_FACTOR
   end
   # When skill
  when 1
   skill_id = @current_action.skill_id
   # Get speed factor from hash: SKILL_SPEED_FACTORS
   return Mobius::Charge_Turn_Battle::SKILL_SPEED_FACTORS[skill_id]
   # When item
  when 2
   item_id = @current_action.item_id
   # Get speed factor from hash: ITEM_SPEED_FACTORS
   return Mobius::Charge_Turn_Battle::ITEM_SPEED_FACTORS[item_id]
  end
 end
 #--------------------------------------------------------------------------
 # Explanation:
 #  DBS reduces turn count and removes states at end of turn
 #  This fix causes turn count to decrement at end of turn while
 #  state removal happens at beginning of turn
 # TO BE COMPATIBLE WITH MY CTB SYSTEM
 #  "Remove states auto" is still called in phase 4 since the only active battler
 #  in phase 4 is whoever's turn it is, thus they will have there turn count
 #  decrement by one.
 #  "Remove states auto start" is called in phase two after determining whose turn
 #  it is next. That way only the current battler will have their states removed.
 #--------------------------------------------------------------------------
 # * Natural Removal of States (called up each end turn)
 #--------------------------------------------------------------------------
 def remove_states_auto
  for i in @states_turn.keys.clone
   if @states_turn[i] > 0
    @states_turn[i] -= 1
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Natural Removal of States (called up each start turn)
 #--------------------------------------------------------------------------
 def remove_states_auto_start
  for i in @states_turn.keys.clone
   if @states_turn[i] <= 0 and rand(100) < $data_states[i].auto_release_prob
    remove_state(i)
   end
  end
 end
end
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Enemy class
#    @boss
#      This represents if an enemy should be treated as a boss.
#      This affects certain display elements like prefixing the name with "Boss:"
#==============================================================================
class Game_Enemy < Game_Battler
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_reader   :boss  # Boss
 #--------------------------------------------------------------------------
 # * Object Initialization
 #     troop_id     : troop ID
 #     member_index : troop member index
 #--------------------------------------------------------------------------
 alias mobius_ctb_game_enemy_initialize initialize
 def initialize(troop_id, member_index)
  mobius_ctb_game_enemy_initialize(troop_id, member_index)
  @boss = Mobius::Charge_Turn_Battle::BOSS_LIST.include?(id)
 end
 #--------------------------------------------------------------------------
 # * Get Name - May return a prefixed base_name
 #--------------------------------------------------------------------------
 alias base_name name
 def name
  if Mobius::Charge_Turn_Battle::USE_ENEMY_PREFIX
   if @boss
    return Mobius::Charge_Turn_Battle::ENEMY_BOSS_PREFIX + base_name
   else
    prefix_array = Mobius::Charge_Turn_Battle::ENEMY_PREFIX.split(",")
    prefix = prefix_array[@member_index].to_s #convert to string in case it's nil
    return prefix + base_name
   end
  else
   return base_name
  end
 end
end
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Add charge gauge clearing
#==============================================================================
class Game_Party
 #--------------------------------------------------------------------------
 # * Clear All Member Actions and Charge Gauges
 #--------------------------------------------------------------------------
 alias mobius_clear_actions clear_actions
 def clear_actions
  mobius_clear_actions
  # Clear All Member Charge Gauges
  for actor in @actors
   actor.charge_clear
  end
 end

end
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  Adds three utility functions to Window_Base
#==============================================================================
class Window_Base < Window
 #--------------------------------------------------------------------------
 # * Draws a bitmap centered in a rect
 #     bitmap : bitmap to draw
 #     rect   : rectangle to center bitmap in
 #--------------------------------------------------------------------------
 def draw_bitmap_centered(bitmap, rect)
  draw_x = ( (rect.width - bitmap.width) / 2 ) + rect.x
  draw_y = ( (rect.height - bitmap.height) / 2 ) + rect.y
  self.contents.blt(draw_x, draw_y, bitmap, bitmap.rect)
 end
 #--------------------------------------------------------------------------
 # * Draw Actor Name - Adds width parameter
 #     actor : actor
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #     width : text width for the name (defaults to 120)
 #--------------------------------------------------------------------------
 def draw_actor_name(actor, x, y, width = 120)
  self.contents.font.color = normal_color
  self.contents.draw_text(x, y, width, 32, actor.name)
 end
 #--------------------------------------------------------------------------
 # * Draw Icon
 #     icon_name : filename of the icon ("String")
 #     x         : draw spot x-coordinate
 #     y         : draw spot y-coordinate
 #--------------------------------------------------------------------------
 def draw_icon(icon_name, x, y)
  bitmap = RPG::Cache.icon(icon_name)
  src_rect = Rect.new(0, 0, 24, 24)
  self.contents.blt(x, y, bitmap, src_rect)
 end

end
#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  Updates the set_enemy method to display scanned enemies
#==============================================================================
class Window_Help < Window_Base
 #--------------------------------------------------------------------------
 # * Set Enemy
 #     enemy : name and status displaying enemy
 #--------------------------------------------------------------------------
 alias mobius_ctb_set_enemy set_enemy
 def set_enemy(enemy)
  # If enemy has been scanned
  if enemy.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
   # treat enemy as actor
   set_actor(enemy)
  else
   # treat as enemy
   mobius_ctb_set_enemy(enemy)
  end
 end
end
#==============================================================================
# ** Window_BigBattleStatus
#------------------------------------------------------------------------------
#  This window displays additional information during battle
#==============================================================================
class Window_BigBattleStatus < Window_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize(all_battlers)
  super(0, 0, 640, 320)
  self.contents = Bitmap.new(width - 32, height - 32)
  self.back_opacity = 160
  self.visible = false
  self.z = 100
  @all_battlers = all_battlers
  refresh
 end
 #--------------------------------------------------------------------------
 # * Active Battlers - Returns only the battlers that exist
 #--------------------------------------------------------------------------
 def active_battlers
  return @all_battlers.find_all do | battler |
   battler.exist?
  end
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  self.contents.clear
  self.contents.font.color = system_color
  # Local variables
  battlers = Mobius::Charge_Turn_Battle::BATTLERS_WORD
  status = Mobius::Charge_Turn_Battle::BATTLERS_WORD
  hp = $data_system.words.hp
  maxhp = Mobius::Charge_Turn_Battle::MAXHP_WORD
  sp = $data_system.words.sp
  maxsp = Mobius::Charge_Turn_Battle::MAXSP_WORD
  w = 152
  h = 32
  # Draw labels
  self.contents.draw_text(1 + (0*w), 0, w, h, battlers)
  self.contents.draw_text(1 + (1*w), 0, w, h, status, 1)
  self.contents.draw_text(1 + (2*w), 0, w, h, "#{hp} / #{maxhp}", 2)
  self.contents.draw_text(1 + (3*w), 0, w, h, "#{sp} / #{maxsp}", 2)
  # Draw battlers
  self.contents.font.color = normal_color
  battler_list = active_battlers()
  for i in 0...battler_list.size
   battler = battler_list[i]
   # TODO: Add status icons support?
   state = make_battler_state_text(battler, w, true)
   self.contents.draw_text(1 + (0*w), 22 + (i*22), w, h, battler.name)
   self.contents.draw_text(1 + (1*w), 22 + (i*22), w, h, state, 1)
   # Check to see if the enemy has been scanned
   # If not, then return question mark values
   if battler.is_a?(Game_Enemy) and not battler.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
    self.contents.draw_text(1 + (2*w), 22 + (i*22), w, 32,"???", 2) # HP
    self.contents.draw_text(1 + (3*w), 22 + (i*22), w, 32,"???", 2) # SP
   else
    draw_battler_hp(battler, 1 + (2*w), 22 + (i*22)) #width = 152
    draw_battler_sp(battler, 1 + (3*w), 22 + (i*22)) #width = 152
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Draw HP -- Mobius modified from Window_Base
 #     actor : actor
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #--------------------------------------------------------------------------
 def draw_battler_hp(actor, x, y)
  # Draw HP
  self.contents.font.color = actor.hp <= actor.maxhp / 10 ? knockout_color :
                               actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
  self.contents.draw_text(x, y, 70, 32, actor.hp.to_s, 2)
  # Draw MaxHP
  self.contents.font.color = normal_color
  self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
  self.contents.draw_text(x + 82, y, 70, 32, actor.maxhp.to_s, 2)
 end
 #--------------------------------------------------------------------------
 # * Draw SP -- Mobius modified from Window_Base
 #     actor : actor
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #--------------------------------------------------------------------------
 def draw_battler_sp(actor, x, y)
  # Draw SP
  self.contents.font.color = actor.sp <= actor.maxsp / 10 ? knockout_color :
                               actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
  self.contents.draw_text(x, y, 70, 32, actor.sp.to_s, 2)
  # Draw MaxSP
  self.contents.font.color = normal_color
  self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
  self.contents.draw_text(x + 82, y, 70, 32, actor.maxsp.to_s, 2)
 end
end
#==============================================================================
# ** Window_TurnOrder
#------------------------------------------------------------------------------
#  This window displays the current turn order during battle
#  The window can be scrolled during the command phase
#==============================================================================
class Window_TurnOrder < Window_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize()
  super(640 - 64, 0, 64, 320) # right justified
  self.contents = Bitmap.new(width - 32, (16 * 48)) # 16 battlers tall
  self.back_opacity = 160
  @current_battlers = []
  @turn_order = []
  @first_draw_index = 0
  @drawing_down = false
  @drawing_up = false
  @wait_count = 0
  @actor_index = -1
  @enemy_index = -1
  self.visible = true
  self.z = 100
  update
  refresh
 end
 #--------------------------------------------------------------------------
 # * Update
 #--------------------------------------------------------------------------
 def update(current_battlers = @current_battlers, index = @actor_index)
  @wait_count -= 1 if @wait_count > 0
  if @current_battlers != current_battlers
   @current_battlers = current_battlers
   refresh
  end
  if @actor_index != index
   @actor_index = index
   if index == 3 # If current battler is Actor 4
    self.x = 0
   else
    self.x = 640 - 64
   end
  end
  make_turn_order
  if @drawing_down
   if self.oy == (@first_draw_index * 48)
    @drawing_down = false
   else
    self.oy += 12
   end
   return
  end
  if @drawing_up
   if self.oy == (@first_draw_index * 48)
    @drawing_up = false
   else
    self.oy -= 12
   end
   return
  end
  if Input.repeat?(Input::TURN_WINDOW_DRAW_DOWN_BUTTON)
   shift_draw_down
  end
  if Input.repeat?(Input::TURN_WINDOW_DRAW_UP_BUTTON)
   shift_draw_up
  end
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh(current_battlers = @current_battlers, index = @actor_index)
  self.contents.clear
  draw_turn_order
 end
 #--------------------------------------------------------------------------
 # * Make Turn Order
 #--------------------------------------------------------------------------
 def make_turn_order(current_battlers = @current_battlers)
  if current_battlers != [] and current_battlers != nil
   #initialize dummy gauges
   for battler in current_battlers
    battler.dummy_charge_copy
   end
   #initialize turn order
   turn_order_temp = []
   until turn_order_temp.size >= 16
    #charge dummy gauges
    until dummy_battler_charged?
     for battler in current_battlers
      battler.dummy_charge
     end
    end
    #get the fastest one
    fastest = current_battlers.max \
      {|a,b| a.charge_gauge_dummy <=> b.charge_gauge_dummy }
    #add the fastest to the turn order
    turn_order_temp.push(fastest)
    #reset the fastest
    fastest.dummy_charge_reset
   end
   #compare with set turn order
   unless @turn_order == turn_order_temp
    @turn_order = turn_order_temp
    refresh
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Dummy Battler Charged
 #--------------------------------------------------------------------------
 def dummy_battler_charged?
  for battler in @current_battlers
   return true if battler.charge_gauge_dummy >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
  end
  return false
 end
 #--------------------------------------------------------------------------
 # * Draw Turn Order -- Draws all icons
 #--------------------------------------------------------------------------
 def draw_turn_order
  if @turn_order != []
   for i in 0...@turn_order.size
    battler = @turn_order[i]
    if battler.is_a?(Game_Enemy)
     draw_enemy_graphic(battler, 0, i * 48)
    elsif battler.is_a?(Game_Actor)
     draw_actor_graphic(battler, 0, i * 48)
    end
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Shift Draw Up
 #--------------------------------------------------------------------------
 def shift_draw_up
  if @first_draw_index == 0
   if @wait_count <= 0
    # Play buzzer SE
    $game_system.se_play($data_system.buzzer_se)
    @wait_count = 12
   end
   return #do nothing
  else
   @first_draw_index -= 1
   # Play cursor SE
   $game_system.se_play($data_system.cursor_se)
   #refresh
   @drawing_up = true
  end
 end
 #--------------------------------------------------------------------------
 # * Shift Draw Down
 #--------------------------------------------------------------------------
 def shift_draw_down
  if @first_draw_index == 10
   if @wait_count <= 0
    # Play buzzer SE
    $game_system.se_play($data_system.buzzer_se)
    @wait_count = 12
   end
   return #do nothing
  else
   @first_draw_index += 1
   # Play cursor SE
   $game_system.se_play($data_system.cursor_se)
   #refresh
   @drawing_down = true
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Graphic
 #     actor : actor
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #--------------------------------------------------------------------------
 def draw_actor_graphic(actor, x, y)
  if Mobius::Charge_Turn_Battle::USE_ACTOR_PICTURES
   actor_picture_name = actor.name + Mobius::Charge_Turn_Battle::ACTOR_PICTURES_SUFFIX
   bitmap = RPG::Cache.picture(actor_picture_name)
   cw = bitmap.width / 2
   ch = bitmap.height / 2
  else
   bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
   cw = bitmap.width / 4 / 2
   ch = bitmap.height / 4 / 2
  end
  src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
  self.contents.blt(x, y, bitmap, src_rect)
  return
  # If filename can't be found
 rescue Errno::ENOENT
  rect = Rect.new(x, y, 32, 48)
  self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
 end
 #--------------------------------------------------------------------------
 # * Draw Enemy Graphic
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #--------------------------------------------------------------------------
 def draw_enemy_graphic(enemy, x, y)
  if Mobius::Charge_Turn_Battle::USE_ENEMY_PICTURES
   enemy_picture_name = enemy.base_name + Mobius::Charge_Turn_Battle::ENEMY_PICTURES_SUFFIX
   bitmap = RPG::Cache.picture(enemy_picture_name)
   cw = bitmap.width / 2
   ch = bitmap.height / 2
  else
   if enemy.boss
    bitmap = RPG::Cache.picture("EnemyBoss")
   else
    bitmap = RPG::Cache.picture(sprintf("Enemy%01d", enemy.index + 1))
   end
   cw = bitmap.width / 2
   ch = bitmap.height / 2
  end
  src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
  self.contents.blt(x, y, bitmap, src_rect)
  return
  # If filename can't be found
 rescue Errno::ENOENT
  rect = Rect.new(x, y, 32, 48)
  self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
 end
end
#==============================================================================
# ** Arrow_All_Base
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose multiple battlers
#==============================================================================
class Arrow_All_Base
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_reader   :help_window              # help window
 #--------------------------------------------------------------------------
 # * Object Initialization
 #     viewport : viewport
 #--------------------------------------------------------------------------
 def initialize(viewport)
  @viewport = viewport
  @help_window = nil
  @battlers = []
  @arrows = []
 end
 #--------------------------------------------------------------------------
 # * Frame Update
 #--------------------------------------------------------------------------
 def update
  # Set sprite coordinates
  unless @battlers == [] or @battlers == nil
   for arrow in @arrows
    arrow.update
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Make Helper Arrows
 #--------------------------------------------------------------------------
 def make_helper_arrows
  for i in 0...@battlers.size
   @arrows.push(Arrow_Base.new(@viewport))
   arrow = @arrows[i]
   battler = @battlers[i]
   arrow.x = battler.screen_x
   arrow.y = battler.screen_y
  end
 end
 #--------------------------------------------------------------------------
 # * Set Help Window
 #     help_window : new help window
 #--------------------------------------------------------------------------
 def help_window=(help_window)
  @help_window = help_window
  if @help_window != nil
   update_help
  end
 end
 #--------------------------------------------------------------------------
 # * Help Text Update
 #--------------------------------------------------------------------------
 def update_help
  @help_window.set_text("All", 1)
 end
 #--------------------------------------------------------------------------
 # * Dispose
 #--------------------------------------------------------------------------
 def dispose
  for arrow in @arrows
   arrow.dispose
  end
 end
end
#==============================================================================
# ** Arrow_All_Enemy
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all enemies.
#==============================================================================
class Arrow_All_Enemy < Arrow_All_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #     viewport : viewport
 #--------------------------------------------------------------------------
 def initialize(viewport)
  super(viewport)
  make_enemy_list
  make_helper_arrows
 end
 #--------------------------------------------------------------------------
 # * Make Enemy List
 #--------------------------------------------------------------------------
 def make_enemy_list
  for enemy in $game_troop.enemies
   @battlers.push(enemy) if enemy.exist?
  end
 end
end
#==============================================================================
# ** Arrow_All_Actor
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all actors.
#==============================================================================
class Arrow_All_Actor < Arrow_All_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #     viewport : viewport
 #--------------------------------------------------------------------------
 def initialize(viewport)
  super(viewport)
  make_actor_list
  make_helper_arrows
 end
 #--------------------------------------------------------------------------
 # * Make Actor List
 #--------------------------------------------------------------------------
 def make_actor_list
  for actor in $game_party.actors
   @battlers.push(actor) if actor.exist?
  end
 end
end
#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================
class Scene_Battle
 #--------------------------------------------------------------------------
 # * Main Processing
 #--------------------------------------------------------------------------
 alias mobius_main main
 def main
  # Initialize each kind of temporary battle data
  $game_temp.in_battle = true
  $game_temp.battle_turn = 0
  $game_temp.battle_event_flags.clear
  $game_temp.battle_abort = false
  $game_temp.battle_main_phase = false
  $game_temp.battleback_name = $game_map.battleback_name
  $game_temp.forcing_battler = nil
  # Initialize battle event interpreter
  $game_system.battle_interpreter.setup(nil, 0)
  # Prepare troop
  @troop_id = $game_temp.battle_troop_id
  $game_troop.setup(@troop_id)
  # Make actor command window
  s1 = $data_system.words.attack
  s2 = $data_system.words.skill
  s3 = $data_system.words.guard
  s4 = $data_system.words.item
  s5 = Mobius::Charge_Turn_Battle::ESCAPE_WORD # Mobius Added
  @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4, s5])
  @actor_command_window.y = 128
  @actor_command_window.back_opacity = 160
  @actor_command_window.active = false
  @actor_command_window.visible = false
  # Make other windows
  @party_command_window = Window_PartyCommand.new
  @help_window = Window_Help.new
  #@help_window.back_opacity = 160
  @help_window.back_opacity = 230
  @help_window.z = 200
  @help_window.visible = false
  @status_window = Window_BattleStatus.new
  @message_window = Window_Message.new
  @turn_order_window = Window_TurnOrder.new #Mobius Added
  all_battlers = [].concat($game_party.actors).concat($game_troop.enemies)
  @big_status_window = Window_BigBattleStatus.new(all_battlers)
  if Mobius::Beastiary::BEASTIARY_ENABLED
   @enemy_detail_window = Window_BeastDetail.new #Mobius Added
  end
  # Make sprite set
  @spriteset = Spriteset_Battle.new
  # Initialize wait count
  @wait_count = 0
  # Execute transition
  if $data_system.battle_transition == ""
   Graphics.transition(20)
  else
   Graphics.transition(40, "Graphics/Transitions/" +
                           $data_system.battle_transition)
  end
  # Start pre-battle phase
  start_phase1
  # Main loop
  loop do
   # Update game screen
   Graphics.update
   # Update input information
   Input.update
   # Frame update
   update
   # Abort loop if screen is changed
   if $scene != self
    break
   end
  end
  # Refresh map
  $game_map.refresh
  # Prepare for transition
  Graphics.freeze
  # Dispose of windows
  @actor_command_window.dispose
  @party_command_window.dispose
  @help_window.dispose
  @status_window.dispose
  @message_window.dispose
  @turn_order_window.dispose # Mobius Added
  @big_status_window.dispose # Mobius
  if Mobius::Beastiary::BEASTIARY_ENABLED
   @enemy_detail_window.dispose # Mobius
  end
  if @skill_window != nil
   @skill_window.dispose
  end
  if @item_window != nil
   @item_window.dispose
  end
  if @result_window != nil
   @result_window.dispose
  end
  # Dispose of sprite set
  @spriteset.dispose
  # If switching to title screen
  if $scene.is_a?(Scene_Title)
   # Fade out screen
   Graphics.transition
   Graphics.freeze
  end
  # If switching from battle test to any screen other than game over screen
  if $BTEST and not $scene.is_a?(Scene_Gameover)
   $scene = nil
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update
 #--------------------------------------------------------------------------
 alias mobius_update update
 def update
  if @turn_order_window.visible
   @turn_order_window.update(@current_battlers, @actor_index) # Mobius
  end
  mobius_update
 end
 #--------------------------------------------------------------------------
 # * Start Party Command Phase
 #--------------------------------------------------------------------------
 def start_phase2
  # Shift to phase 2
  @phase = 2
  # Set actor to non-selecting
  @actor_index = -1
  @active_battler = nil
  @action_battlers = []
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  # Clear main phase flag
  $game_temp.battle_main_phase = false
  # Increase Turn Count
  $game_temp.battle_turn += 1
  # Make new array of current battlers
  @current_battlers = []
  for enemy in $game_troop.enemies
   @current_battlers.push(enemy) if enemy.exist?
  end
  for actor in $game_party.actors
   @current_battlers.push(actor) if actor.exist?
  end
 end
 #--------------------------------------------------------------------------
 # * Battler Charged
 #--------------------------------------------------------------------------
 def battler_charged?
  for battler in @current_battlers
   return true if battler.charge_gauge >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
  end
  return false
 end
 #--------------------------------------------------------------------------
 # * Frame Update (party command phase)
 #--------------------------------------------------------------------------
 def update_phase2
  # Charge all the battlers until someone gets an active turn
  until battler_charged?
   for battler in @current_battlers
    battler.charge
   end
  end
  # Set the active battler to the fastest
  @active_battler = @current_battlers.max {|a,b| a.charge_gauge <=> b.charge_gauge}
  # Remove appropiate states automatically
  @active_battler.remove_states_auto_start
  # Refresh Battle Status window
  @status_window.refresh
  # branch according to whether it's an enemy or actor
  if @active_battler.is_a?(Game_Enemy)
   @active_battler.make_action
   start_phase4
  else #if it's an actor
   start_phase3
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (party command phase: escape)
 #--------------------------------------------------------------------------
 def update_phase2_escape
  # Calculate enemy agility average
  enemies_agi = 0
  enemies_number = 0
  for enemy in $game_troop.enemies
   if enemy.exist?
    enemies_agi += enemy.agi
    enemies_number += 1
   end
  end
  if enemies_number > 0
   enemies_agi /= enemies_number
  end
  # Calculate actor agility average
  actors_agi = 0
  actors_number = 0
  for actor in $game_party.actors
   if actor.exist?
    actors_agi += actor.agi
    actors_number += 1
   end
  end
  if actors_number > 0
   actors_agi /= actors_number
  end
  # Determine if escape is successful
  success = rand(100) < 50 * actors_agi / enemies_agi
  # If escape is successful
  if success
   # Play escape SE
   $game_system.se_play($data_system.escape_se)
   # Return to BGM before battle started
   $game_system.bgm_play($game_temp.map_bgm)
   # Battle ends
   battle_end(1)
   # If escape is failure
  else
   # Start main phase
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Start Actor Command Phase
 #--------------------------------------------------------------------------
 def start_phase3
  # Shift to phase 3
  @phase = 3
  @actor_index = $game_party.actors.index(@active_battler)
  @active_battler.blink = true
  if @active_battler.inputable?
   phase3_setup_command_window
  else
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase)
 #--------------------------------------------------------------------------
 def update_phase3
  # If enemy detail is enabled
  if @enemy_detail_window != nil and @enemy_detail_window.visible
   update_enemy_detail_window
   # If enemy arrow is enabled
  elsif @enemy_arrow != nil
   update_phase3_enemy_select
   # If all enemy arrow is enabled
  elsif @all_enemy_arrow != nil
   update_phase3_all_enemy_select
   # If actor arrow is enabled
  elsif @actor_arrow != nil
   update_phase3_actor_select
   # If all actor arrow is enabled
  elsif @all_actor_arrow != nil
   update_phase3_all_actor_select
   # If skill window is enabled
  elsif @skill_window != nil
   update_phase3_skill_select
   # If item window is enabled
  elsif @item_window != nil
   update_phase3_item_select
   # If turn order window is up
  elsif @big_status_window.visible
   update_big_status_window
   # If actor command window is enabled
  elsif @actor_command_window.active
   update_phase3_basic_command
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : basic command)
 #--------------------------------------------------------------------------
 def update_phase3_basic_command
  # If shift is pressed
  if Input.trigger?(Input::BATTLE_STATUS_ACCESS_BUTTON)
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # Start turn order window
   start_big_status_window
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Branch by actor command window cursor position
   case @actor_command_window.index
   when 0  # attack
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.kind = 0
    @active_battler.current_action.basic = 0
    # Start enemy selection
    start_enemy_select
   when 1  # skill
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.kind = 1
    # Start skill selection
    start_skill_select
   when 2  # guard
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.kind = 0
    @active_battler.current_action.basic = 1
    # Go to command input for next actor
    start_phase4
   when 3  # item
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.kind = 2
    # Start item selection
    start_item_select
   when 4  # escape
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # If it's not possible to escape
    if $game_temp.battle_can_escape == false
     # Play buzzer SE
     $game_system.se_play($data_system.buzzer_se)
     return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    #Clear current action
    @active_battler.current_action.clear
    # Escape processing
    update_phase2_escape
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : skill selection)
 #--------------------------------------------------------------------------
 def update_phase3_skill_select
  # Make skill window visible
  @skill_window.visible = true
  # Update skill window
  @skill_window.update
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End skill selection
   end_skill_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Get currently selected data on the skill window
   @skill = @skill_window.skill
   # If it can't be used
   if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
    # Play buzzer SE
    $game_system.se_play($data_system.buzzer_se)
    return
   end
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # Set action
   @active_battler.current_action.skill_id = @skill.id
   # Make skill window invisible
   @skill_window.visible = false
   # If effect scope is single enemy
   if @skill.scope == 1
    # Start enemy selection
    start_enemy_select
    # If effect scope is all enemy - Mobius
   elsif @skill.scope == 2
    # Start all enemy selection
    start_all_enemy_select
    # If effect scope is single ally
   elsif @skill.scope == 3 or @skill.scope == 5
    # Start actor selection
    start_actor_select
    # If effect scope is all ally - Mobius
   elsif @skill.scope == 4 or @skill.scope == 6
    # Start all actor selection
    start_all_actor_select
    # If effect scope is not single
   else
    # End skill selection
    end_skill_select
    # Go to command input for next actor
    start_phase4
   end
   return
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : item selection)
 #--------------------------------------------------------------------------
 def update_phase3_item_select
  # Make item window visible
  @item_window.visible = true
  # Update item window
  @item_window.update
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End item selection
   end_item_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Get currently selected data on the item window
   @item = @item_window.item
   # If it can't be used
   unless $game_party.item_can_use?(@item.id)
    # Play buzzer SE
    $game_system.se_play($data_system.buzzer_se)
    return
   end
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # Set action
   @active_battler.current_action.item_id = @item.id
   # Make item window invisible
   @item_window.visible = false
   # If effect scope is single enemy
   if @item.scope == 1
    # Start enemy selection
    start_enemy_select
    # If effect scope is all enemy - Mobius
   elsif @item.scope == 2
    # Start all enemy selection
    start_all_enemy_select
    # If effect scope is single ally
   elsif @item.scope == 3 or @item.scope == 5
    # Start actor selection
    start_actor_select
    # If effect scope is all ally - Mobius
   elsif @item.scope == 4 or @item.scope == 6
    # Start all actor selection
    start_all_actor_select
    # If effect scope is not single
   else
    # End item selection
    end_item_select
    # Go to command input for next actor
    start_phase4
   end
   return
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : enemy selection)
 #--------------------------------------------------------------------------
 def update_phase3_enemy_select
  # Update enemy arrow
  @enemy_arrow.update
  # If Beastiary is added
  if Mobius::Beastiary::BEASTIARY_ENABLED
   # If Beastiary access button is pressed
   if Input.trigger?(Input::BEASTIARY_BATTLE_ACCESS_BUTTON)
    # Set enemy
    enemy = @enemy_arrow.enemy
    # If enemy has been scanned
    if enemy.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
     # Play decision SE
     $game_system.se_play($data_system.decision_se)
     # Start enemy detail window
     start_enemy_detail_window(enemy)
     return
    else
     # Play buzzer SE
     $game_system.se_play($data_system.buzzer_se)
    end
   end
  end
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End enemy selection
   end_enemy_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # Set action
   @active_battler.current_action.target_index = @enemy_arrow.index
   # End enemy selection
   end_enemy_select
   # If skill window is showing
   if @skill_window != nil
    # End skill selection
    end_skill_select
   end
   # If item window is showing
   if @item_window != nil
    # End item selection
    end_item_select
   end
   # Execute action
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : all enemy selection)
 #--------------------------------------------------------------------------
 def update_phase3_all_enemy_select
  # Update enemy arrow
  @all_enemy_arrow.update
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End enemy selection
   end_all_enemy_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # End enemy selection
   end_all_enemy_select
   # If skill window is showing
   if @skill_window != nil
    # End skill selection
    end_skill_select
   end
   # If item window is showing
   if @item_window != nil
    # End item selection
    end_item_select
   end
   # Execute action
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : actor selection)
 #--------------------------------------------------------------------------
 def update_phase3_actor_select
  # Update actor arrow
  @actor_arrow.update
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End actor selection
   end_actor_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # Set action
   @active_battler.current_action.target_index = @actor_arrow.index
   # End actor selection
   end_actor_select
   # If skill window is showing
   if @skill_window != nil
    # End skill selection
    end_skill_select
   end
   # If item window is showing
   if @item_window != nil
    # End item selection
    end_item_select
   end
   # Execute action
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Frame Update (actor command phase : all actor selection)
 #--------------------------------------------------------------------------
 def update_phase3_all_actor_select
  # Update enemy arrow
  @all_actor_arrow.update
  # If B button was pressed
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End enemy selection
   end_all_actor_select
   return
  end
  # If C button was pressed
  if Input.trigger?(Input::C)
   # Play decision SE
   $game_system.se_play($data_system.decision_se)
   # End enemy selection
   end_all_actor_select
   # If skill window is showing
   if @skill_window != nil
    # End skill selection
    end_skill_select
   end
   # If item window is showing
   if @item_window != nil
    # End item selection
    end_item_select
   end
   # Execute action
   start_phase4
  end
 end
 #--------------------------------------------------------------------------
 # * Start Enemy Selection
 #--------------------------------------------------------------------------
 def start_enemy_select
  # Make enemy arrow
  @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
  # Associate help window
  @enemy_arrow.help_window = @help_window
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * End Enemy Selection
 #--------------------------------------------------------------------------
 def end_enemy_select
  # Dispose of enemy arrow
  @enemy_arrow.dispose
  @enemy_arrow = nil
  # If command is [fight]
  if @actor_command_window.index == 0
   # Enable actor command window
   @actor_command_window.active = true
   @actor_command_window.visible = true
   @turn_order_window.visible = true
   # Hide help window
   @help_window.visible = false
  end
  # If skill window is showing
  if @skill_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
  # If item window is showing
  if @item_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
 end
 #--------------------------------------------------------------------------
 # * Start All Enemy Selection
 #--------------------------------------------------------------------------
 def start_all_enemy_select
  # Make enemy arrow
  @all_enemy_arrow = Arrow_All_Enemy.new(@spriteset.viewport1)
  # Associate help window
  @all_enemy_arrow.help_window = @help_window
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * End All Enemy Selection
 #--------------------------------------------------------------------------
 def end_all_enemy_select
  # Dispose of enemy arrow
  @all_enemy_arrow.dispose
  @all_enemy_arrow = nil
  # If command is [fight]
  if @actor_command_window.index == 0
   # Enable actor command window
   @actor_command_window.active = true
   @actor_command_window.visible = true
   @turn_order_window.visible = true
   # Hide help window
   @help_window.visible = false
  end
  # If skill window is showing
  if @skill_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
  # If item window is showing
  if @item_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
 end
 #--------------------------------------------------------------------------
 # * Start Actor Selection
 #--------------------------------------------------------------------------
 def start_actor_select
  # Make actor arrow
  @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
  @actor_arrow.index = @actor_index
  # Associate help window
  @actor_arrow.help_window = @help_window
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * End Actor Selection
 #--------------------------------------------------------------------------
 def end_actor_select
  # Dispose of actor arrow
  @actor_arrow.dispose
  @actor_arrow = nil
  # If skill window is showing
  if @skill_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
  # If item window is showing
  if @item_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
 end
 #--------------------------------------------------------------------------
 # * Start All Actor Selection
 #--------------------------------------------------------------------------
 def start_all_actor_select
  # Make actor arrow
  @all_actor_arrow = Arrow_All_Actor.new(@spriteset.viewport2)
  # Associate help window
  @all_actor_arrow.help_window = @help_window
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * End All Actor Selection
 #--------------------------------------------------------------------------
 def end_all_actor_select
  # Dispose of enemy arrow
  @all_actor_arrow.dispose
  @all_actor_arrow = nil
  # If command is [fight]
  if @actor_command_window.index == 0
   # Enable actor command window
   @actor_command_window.active = true
   @actor_command_window.visible = true
   @turn_order_window.visible = true
   # Hide help window
   @help_window.visible = false
  end
  # If skill window is showing
  if @skill_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
  # If item window is showing
  if @item_window != nil
   # Hide turn order window
   @turn_order_window.visible = false
  end
 end
 #--------------------------------------------------------------------------
 # * Start Skill Selection
 #--------------------------------------------------------------------------
 alias mobius_ctb_start_skill_select start_skill_select
 def start_skill_select
  mobius_ctb_start_skill_select
  @turn_order_window.visible = false
 end
 #--------------------------------------------------------------------------
 # * End Skill Selection
 #--------------------------------------------------------------------------
 alias mobius_ctb_end_skill_select end_skill_select
 def end_skill_select
  mobius_ctb_end_skill_select
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * Start Item Selection
 #--------------------------------------------------------------------------
 alias mobius_ctb_start_item_select start_item_select
 def start_item_select
  mobius_ctb_start_item_select
  @turn_order_window.visible = false
 end
 #--------------------------------------------------------------------------
 # * End Item Selection
 #--------------------------------------------------------------------------
 alias mobius_ctb_end_item_select end_item_select
 def end_item_select
  mobius_ctb_end_item_select
  @turn_order_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * Start Big Status Window
 #--------------------------------------------------------------------------
 def start_big_status_window
  @big_status_window.refresh
  @big_status_window.visible = true
  @actor_command_window.active = false
  @actor_command_window.visible = false
  @turn_order_window.visible = false
 end
 #--------------------------------------------------------------------------
 # * Update Big Status Window
 #--------------------------------------------------------------------------
 def update_big_status_window
  @big_status_window.update
  if Input.trigger?(Input::A) or Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End Turn Order Window
   end_big_status_window
  end
 end
 #--------------------------------------------------------------------------
 # * End Big Status Window
 #--------------------------------------------------------------------------
 def end_big_status_window
  @big_status_window.visible = false
  @turn_order_window.visible = true
  # Enable actor command window
  @actor_command_window.active = true
  @actor_command_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * Start Enemy Detail Window
 #--------------------------------------------------------------------------
 def start_enemy_detail_window(enemy)
  # Set enemy detail window's enemy
  @enemy_detail_window.enemy = enemy
  # Show enemy detail window
  @enemy_detail_window.visible = true
  # Hide turn order window
  @turn_order_window.visible = false
  # Hide help window
  @help_window.visible = false
 end
 #--------------------------------------------------------------------------
 # * Update Enemy Detail Window
 #--------------------------------------------------------------------------
 def update_enemy_detail_window
  @enemy_detail_window.update
  if Input.trigger?(Input::A) or Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # End Turn Order Window
   end_enemy_detail_window
  end
 end
 #--------------------------------------------------------------------------
 # * End Enemy Detail Window
 #--------------------------------------------------------------------------
 def end_enemy_detail_window
  # Hide enemy detail window
  @enemy_detail_window.visible = false
  # Show turn order window
  @turn_order_window.visible = true
  # Show help window
  @help_window.visible = true
 end
 #--------------------------------------------------------------------------
 # * Start Main Phase
 #--------------------------------------------------------------------------
 def start_phase4
  # Shift to phase 4
  @phase = 4
  @active_battler.blink = false
  @active_battler.charge_reset
  @action_battlers.push(@active_battler)
  # Enemies won't attack on "turn 0" so I moved the turn count increment
  # to start_phase2 so that enemies can take their first turn
  # $game_temp.battle_turn += 1

  # Search all battle event pages
  for index in 0...$data_troops[@troop_id].pages.size
   # Get event page
   page = $data_troops[@troop_id].pages[index]
   # If this page span is [turn]
   if page.span == 1
    # Clear action completed flags
    $game_temp.battle_event_flags[index] = false
   end
  end
  # Set actor as unselectable
  @actor_index = -1
  @active_battler = nil
  # Disable party command window
  @party_command_window.active = false
  @party_command_window.visible = false
  # Disable actor command window
  @actor_command_window.active = false
  @actor_command_window.visible = false
  # Set main phase flag
  $game_temp.battle_main_phase = true

  # Make enemy action -- Moved to start_phase2, and only runs one
  # enemy at a time
  #  for enemy in $game_troop.enemies
  #    enemy.make_action
  #  end
  # Make action orders -- Mobius: No longer used
  # make_action_orders

  # Shift to step 1
  @phase4_step = 1
 end
 #--------------------------------------------------------------------------
 # * Make Basic Action Results
 #--------------------------------------------------------------------------
 alias mobius_make_basic_action_result make_basic_action_result
 def make_basic_action_result
  # If guard
  if @active_battler.current_action.basic == 1
   # Display "Guard" in help window
   @help_window.set_text($data_system.words.guard, 1)
   # Return
   return
  end
  # If escape
  if @active_battler.is_a?(Game_Enemy) and
     @active_battler.current_action.basic == 2
   # Display "Escape" in help window
   @help_window.set_text(Mobius::Charge_Turn_Battle::ESCAPE_WORD, 1)
   # Escape
   @active_battler.escape
   return
  end
  mobius_make_basic_action_result
 end

end
#================================SCAN SKILL====================================
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Party class
#    @scan_list
#      This is a list of enemy IDs that have been scanned by the party.
#      This list is used by the beastiary to show only scanned enemies.
#==============================================================================
class Game_Party
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_accessor  :scan_list  # ID array of scanned enemies
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 alias mobius_ctb_initialize initialize
 def initialize
  mobius_ctb_initialize
  @scan_list = []
 end

end
#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  Add a public getter for the active battler
#==============================================================================
class Scene_Battle
 # Use $scene.active_battler to get current actor during batttle
 attr_reader :active_battler
end
#==============================================================================
# ** Mobius
#------------------------------------------------------------------------------
#  This module is a collection of various, random methods that don't fit
#  anywhere else, and need to be able to be called from anywhere.
#
#  Usage:
#   All methods are module methods and can be called globally by prefacing the
#   method name with "Mobius", ex. "Mobius.example"
#==============================================================================
module Mobius
 #------------------------------------------------------------------------
 # * Scan Skill - scans an enemy and adds their stats to the beastiary
 #------------------------------------------------------------------------
 def self.scan_skill
  ab = $scene.active_battler
  ti = ab.current_action.target_index
  en = $game_troop.enemies[ti]
  $game_party.scan_list.push(en.id).uniq!
 end
 #------------------------------------------------------------------------
 # * Scan Skill Popup - scans an enemy creates a pop-up window
 #------------------------------------------------------------------------
 def self.scan_skill_popup
  ab = $scene.active_battler
  ti = ab.current_action.target_index
  en = $game_troop.enemies[ti]
  name = en.name
  hp = en.hp ; maxhp = en.maxhp
  sp = en.sp ; maxsp = en.maxsp
  atk = en.atk
  pdef = en.pdef ; mdef = en.mdef
  txt = "#{name} \nHP: #{hp}/#{maxhp}\n"+
        "SP: #{sp}/#{maxsp} \nATK: #{atk} \nPDEF: #{pdef}\n"+
        "MDEF: #{mdef}"
  $game_temp.message_text = txt
  Window_Message.new
 end

end
#==============================SCAN SKILL END==================================

#===========================STATUS ICONS EXPANSION=============================
if Mobius::Status_Icons::STATUS_ICONS_ENABLED
 #==============================================================================
 # ** Window_Base
 #------------------------------------------------------------------------------
 #  Overwrites the draw_actor_state method
 #==============================================================================
 class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw State
  #     battler : battler
  #     x       : draw spot x-coordinate
  #     y       : draw spot y-coordinate
  #     width   : draw spot width
  # This version will draw icons for the statuses rather than text
  #--------------------------------------------------------------------------
  def draw_actor_state(battler, x, y, width = 125)
   # create temp array for storing bitmaps
   icon_bitmaps = get_status_icon_bitmaps(battler)
   # draw all bitmaps that fit
   width_sum = 0
   icon_bitmaps.each do |bitmap|
    # draw icon centered in height but as wide as it is
    w = bitmap.width
    ch = bitmap.height / 2
    src_rect = Rect.new(0, ch - 16, w, 32)
    # only draw next icon if it'll fit
    if (width_sum + w) <= width
     self.contents.blt(x + width_sum, y, bitmap, src_rect)
     # add padding of 1 pixel to separate icons
     width_sum += (w + 1)
    else
     break
    end
   end
  end
  #--------------------------------------------------------------------------
  # * Get Status Icon Bitmaps - Takes a Game_Battler and returns an array of
  #   bitmaps for drawing their current statuses
  #--------------------------------------------------------------------------
  def get_status_icon_bitmaps(battler)
   icon_bitmaps = []
   # for every state ID in battler's states array (which is sorted by priority)
   for id in battler.states
    # if it should be displayed
    if $data_states[id].rating >= 1
     # load icon bitmap
     bitmap = get_status_icon_bitmap(id)
     # store in temp array
     icon_bitmaps.push(bitmap)
    end
   end
   return icon_bitmaps
  end
  #--------------------------------------------------------------------------
  # * Get Status Icon Bitmap - Takes a Game_Battler and returns an array of bitmaps
  #   for drawing their current statuses
  #--------------------------------------------------------------------------
  def get_status_icon_bitmap(id)
   # get associated icon name
   icon_base_name = $data_states[id].name
   # get suffix
   suffix = Mobius::Status_Icons::STATUS_ICON_SUFFIX
   # create filename
   icon_name = icon_base_name + suffix
   # load icon bitmap
   return RPG::Cache.status_icon(icon_name)
  rescue Errno::ENOENT
   rect = Rect.new(0,0,24,24)
   color = Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR
   bitmap = Bitmap.new(24,24)
   bitmap.fill_rect(rect, color)
   return bitmap
  end

 end
 #==============================================================================
 # ** Window_Help
 #------------------------------------------------------------------------------
 #  Adds status icons to unscanned enemies
 #==============================================================================
 class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Set Enemy
  #     enemy : name and status displaying enemy
  #--------------------------------------------------------------------------
  alias mobius_status_icons_set_enemy mobius_ctb_set_enemy # unused alias
  def mobius_ctb_set_enemy(enemy)
   if enemy.states.any? { |id| $data_states[id].rating >= 1 }
    # treat enemy as mostly actor
    self.contents.clear
    draw_actor_name(enemy, 140, 0, 120)
    draw_actor_state(enemy, 344, 0, 120)
    @actor = enemy
    @text = nil
    self.visible = true
   else
    # draw only name
    text = enemy.name
    set_text(text, 1)
   end
  end

 end
end # If STATUS_ICONS end
#==========================STATUS ICONS EXPANSION END==========================

#===========================BEASTIARY EXPANSION================================
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Enemy class
#    element_ranks
#      This lets us easily look up an enemy's element affinities
#==============================================================================
class Game_Enemy < Game_Battler
 #--------------------------------------------------------------------------
 # * Get Element Efficiency - Human readable string
 #     element_id : Element ID
 #--------------------------------------------------------------------------
 def element_efficiency(element_id)
  return $data_enemies[@enemy_id].element_efficiency(element_id)
 end
 #--------------------------------------------------------------------------
 # * Get All Elements Effectiveness
 #--------------------------------------------------------------------------
 def element_ranks
  return $data_enemies[@enemy_id].element_ranks
 end
 #--------------------------------------------------------------------------
 # * Get Elements that the enemy is strong versus
 #--------------------------------------------------------------------------
 def strong_elements
  return $data_enemies[@enemy_id].strong_elements
 end
 #--------------------------------------------------------------------------
 # * Get Elements that the enemy is strong versus
 #--------------------------------------------------------------------------
 def weak_elements
  return $data_enemies[@enemy_id].weak_elements
 end
 #--------------------------------------------------------------------------
 # * Get State Efficiency - Human readable string
 #     state_id : State ID
 #--------------------------------------------------------------------------
 def state_efficiency(state_id)
  $data_enemies[@enemy_id].state_efficiency(state_id)
 end
 #--------------------------------------------------------------------------
 # * Get States that the enemy is strong versus
 #--------------------------------------------------------------------------
 def strong_states
  return $data_enemies[@enemy_id].strong_states
 end
 #--------------------------------------------------------------------------
 # * Get States that the enemy is strong versus
 #--------------------------------------------------------------------------
 def weak_states
  return $data_enemies[@enemy_id].weak_states
 end
end
#==============================================================================
# ** Window_BeastList
#------------------------------------------------------------------------------
#  This window displays a selectable list of beasts
#==============================================================================
class Window_BeastList < Window_Selectable
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize()
  # called in super @item_max = 1
  # called in super @column_max = 1
  # called in super @index = -1
  #super(0, 0, 256, 480)
  super(0, 0, 222, 416)
  # The $data_enemies starts at index 1 and has an empty entry in the 0 position
  num_of_enemies = $data_enemies.size - 1
  @data = $data_enemies.slice(1, num_of_enemies)
  @data.delete_if do |enemy|
   Mobius::Beastiary::HIDDEN_BEASTS.include?(enemy.id)
  end
  @item_max = @data.size
  self.contents = Bitmap.new(width - 32, row_max * 32)
  refresh
  self.visible = true
  self.active = true
  self.index = 0
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  self.contents.clear
  for i in 0...@item_max
   draw_item(i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Item
 #     index : item number
 #     color : text color
 #--------------------------------------------------------------------------
 def draw_item(index)
  rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
  enemy = @data[index]
  if Mobius::Beastiary::DISPLAY_ID
   if Mobius::Beastiary::DISPLAY_DATABASE_ID
    enemy_id = enemy.id
   else
    enemy_id = index + 1
   end
   enemy_id_text = ("%03d" % enemy_id) + ": "
  else
   enemy_id_text = ""
  end
  enemy_name = $game_party.scan_list.include?(enemy_id) ? enemy.name : "???"
  text = enemy_id_text + enemy_name
  self.contents.draw_text(rect, text)
 end
 #--------------------------------------------------------------------------
 # * Get Enemy
 #--------------------------------------------------------------------------
 def enemy
  return @data[self.index]
 end

end
#==============================================================================
# ** Window_BeastMode
#------------------------------------------------------------------------------
#  This window allows changing what's displayed in the beastiary
#  like the beast's sprite, stats, elements, or status affinities
#==============================================================================
class Window_BeastMode < Window_Selectable
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize()
  # called in super @item_max = 1
  # called in super @column_max = 1
  # called in super @index = -1
  super(0, 480 - 64, 640, 64)
  @data = [
    Mobius::Beastiary::SPRITE_PAGE,
    Mobius::Beastiary::STATS_PAGE,
    Mobius::Beastiary::ELEMENT_PAGE,
    Mobius::Beastiary::STATUS_PAGE,
  ]
  @item_max = @data.size
  @column_max = 4
  self.contents = Bitmap.new(width - 32, row_max * 32)
  refresh
  self.visible = true
  self.active = true
  self.index = 0
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  self.contents.clear
  for i in 0...@item_max
   draw_item(i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Item
 #     index : item number
 #--------------------------------------------------------------------------
 def draw_item(index)
  text = @data[index]
  x = 4 + index % @column_max * ( width / @column_max)
  y = index / @column_max * 32
  self.contents.draw_text(x, y, ( width / @column_max), 32, text)
 end

end
#==============================================================================
# ** Window_BeastInformation
#------------------------------------------------------------------------------
#  This window serves as a base class for all the beast information windows
#==============================================================================
class Window_BeastInformation < Window_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize(x = 222, y = 0, w = 416, h = 416)
  super(x, y, w, h)
  self.contents = Bitmap.new(width - 32, height - 32)
  self.visible = false
  @enemy = nil
  @max_oy = 0
  @wait_count = 0
 end
 #--------------------------------------------------------------------------
 # * Update - Scroll the page
 #--------------------------------------------------------------------------
 def update
  super
  if (@wait_count > 0)
   @wait_count -= 1
   return
  end
  if (self.oy < (@max_oy - 1))
   self.oy += 1
  elsif (self.oy < @max_oy)
   @wait_count = 80
   self.oy += 1
  else
   @wait_count = 80
   self.oy = 0
  end
 end
 #--------------------------------------------------------------------------
 # * Set Enemy - Calls refresh as needed
 #--------------------------------------------------------------------------
 def enemy=(new_enemy)
  if @enemy != new_enemy
   @enemy = new_enemy
   refresh
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Enemy Parameter
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #     w     : draw spot width
 #     h     : draw spot height
 #     type  : parameter type (0-9)
 #--------------------------------------------------------------------------
 def draw_enemy_parameter(x, y, w, h, type)
  case type
  when 0
   parameter_name = $data_system.words.hp
   parameter_value = @enemy ? @enemy.maxhp : "???"
  when 1
   parameter_name = $data_system.words.sp
   parameter_value = @enemy ? @enemy.maxsp : "???"
  when 2
   parameter_name = $data_system.words.pdef
   parameter_value = @enemy ? @enemy.pdef : "???"
  when 3
   parameter_name = $data_system.words.mdef
   parameter_value = @enemy ? @enemy.mdef : "???"
  when 4
   parameter_name = $data_system.words.atk
   parameter_value = @enemy ? @enemy.atk : "???"
  when 5
   parameter_name = $data_system.words.str
   parameter_value = @enemy ? @enemy.str : "???"
  when 6
   parameter_name = $data_system.words.dex
   parameter_value = @enemy ? @enemy.dex : "???"
  when 7
   parameter_name = $data_system.words.agi
   parameter_value = @enemy ? @enemy.agi : "???"
  when 8
   parameter_name = $data_system.words.int
   parameter_value = @enemy ? @enemy.int : "???"
  when 9
   parameter_name = Mobius::Beastiary::EVASION_WORD
   parameter_value = @enemy ? @enemy.eva : "???"
  end
  # draw stat name
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, parameter_name)
  # draw stat value
  self.contents.font.color = normal_color
  self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
 end
 #--------------------------------------------------------------------------
 # * Draw Element
 #     x           : draw spot x-coordinate
 #     y           : draw spot y-coordinate
 #     w           : draw spot width
 #     h           : draw spot height
 #     element_id  : element_id corresponds to database value
 #--------------------------------------------------------------------------
 def draw_element(x, y, w, h, element_id)
  # draw name
  name = $data_system.elements[element_id]
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, name, 0)
  # draw element rank
  self.contents.font.color = normal_color
  if @enemy
   element_efficiency = @enemy.element_efficiency(element_id)
   self.contents.draw_text(x, y, w, h, element_efficiency, 2)
  else
   self.contents.draw_text(x, y, w, h, "???", 2)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw State
 #     x           : draw spot x-coordinate
 #     y           : draw spot y-coordinate
 #     w           : draw spot width
 #     h           : draw spot height
 #     state_id    : state_id corresponds to database value
 #--------------------------------------------------------------------------
 def draw_state(x, y, w, h, state_id)
  # get name
  name = $data_states[state_id].name
  # draw name
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, name, 0)
  # draw state rank
  self.contents.font.color = normal_color
  if @enemy
   state_efficiency = @enemy.state_efficiency(state_id)
   self.contents.draw_text(x, y, w, h, state_efficiency, 2)
  else
   self.contents.draw_text(x, y, w, h, "???", 2)
  end
 end
 #--------------------------------------------------------------------------
 # * Filters out any element IDs that should be hidden from display
 #--------------------------------------------------------------------------
 def filter_elements(elements)
  Mobius::Beastiary::HIDDEN_ELEMENTS.each do |id|
   elements.delete(id)
  end
 end
 #--------------------------------------------------------------------------
 # * Filters out any state IDs that should be hidden from display
 #--------------------------------------------------------------------------
 def filter_states(states)
  Mobius::Beastiary::HIDDEN_STATES.each do |id|
   states.delete(id)
  end
  states.delete_if do |id|
   $data_states[id].rating < 1
  end
 end
end
#==============================================================================
# ** Window_BeastSprite
#------------------------------------------------------------------------------
#  This window displays the sprite of the selected beast
#==============================================================================
class Window_BeastSprite < Window_BeastInformation
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  # Clear contents
  self.contents.clear
  if @enemy == nil
   w = self.contents.width
   h = self.contents.height
   self.contents.draw_text(0, 0, w, h, "???", 1)
  else
   # Get sprite bitmap
   enemy_bitmap = RPG::Cache.beastiary_sprite(self.get_filename)
   rect = Rect.new(0, 0, contents.width, contents.height)
   # Draw sprite
   draw_bitmap_centered(enemy_bitmap, rect)
  end
  return
  # If filename can't be found, use default battler sprite
 rescue Errno::ENOENT
  enemy_bitmap = RPG::Cache.battler(@enemy.battler_name, @enemy.battler_hue)
  rect = Rect.new(0, 0, contents.width, contents.height)
  draw_bitmap_centered(enemy_bitmap, rect)
 end
 #--------------------------------------------------------------------------
 # * Get Filename - Returns filename for sprite
 #--------------------------------------------------------------------------
 def get_filename
  return @enemy.base_name + Mobius::Beastiary::BEASTIARY_SPRITE_SUFFIX
 end
end
#==============================================================================
# ** Window_BeastStats
#------------------------------------------------------------------------------
#  This window displays the stats of the selected beast
#==============================================================================
class Window_BeastStats < Window_BeastInformation
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  # Clear contents
  self.contents.clear
  # Draw all stats
  column_max = 2
  padding = 8
  height = 32
  width = self.contents.width / column_max
  for i in 0..9
   x = i % column_max * (width + padding)
   y = i / column_max * height
   draw_enemy_parameter(x, y, width - padding, height, i)
  end
  # Draw separating line
  color = Mobius::Beastiary::DIVIDER_LINE_COLOR
  self.contents.fill_rect(0, 168, contents.width, 1, color)
  # Draw bio
  if @enemy
   draw_bio
  else
   draw_empty_bio
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Bio
 #--------------------------------------------------------------------------
 def draw_bio
  bio = Mobius::Beastiary::BIOGRAPHIES[@enemy.id]
  bio.each_with_index  do |line, index|
   y = index * 32 + 176
   self.contents.draw_text(4, y, contents.width, 32, line)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Empty Bio
 #--------------------------------------------------------------------------
 def draw_empty_bio
  self.contents.draw_text(0, 176, contents.width, 224, "???", 1)
 end
end
#==============================================================================
# ** Window_BeastElements
#------------------------------------------------------------------------------
#  This window displays the elemental affinities of the selected beast
#==============================================================================
class Window_BeastElements < Window_BeastInformation
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
  super()
  # The $data_system.elements starts at index 1 and has an empty entry in the 0 position
  # What we're doing here is creating an array of element IDs from the base system
  # and then removing IDs that we want to hide in the beastiary
  num_of_elements = $data_system.elements.size - 1
  @element_ids = (1..num_of_elements).to_a
  filter_elements(@element_ids)
  # Create a bitmap big enough to hold all the elements
  self.contents = Bitmap.new(width - 32, @element_ids.size * 32)
  # If the bitmap is bigger than the window's display height (h-32),
  # Than enable automatic scrolling by setting @max_oy > 0
  @max_oy = self.contents.height - (self.height - 32)
  @wait_count = 80
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  # Clear contents
  self.contents.clear
  # draw all elements
  padding = 0
  height = 32
  width = self.contents.width - padding
  for i in 0...@element_ids.size
   draw_element(padding, i * height, width, height, @element_ids[i])
  end
 end
end
#==============================================================================
# ** Window_BeastStates
#------------------------------------------------------------------------------
#  This window displays the status affinities of the selected beast
#==============================================================================
class Window_BeastStates < Window_BeastInformation
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
  super()
  # The $data_states starts at index 1 and has an empty entry in the 0 position
  # What we're doing here is creating an array of state IDs from the base system
  # and then removing IDs that we want to hide in the beastiary
  num_of_states = $data_states.size - 1
  @state_ids = (1..num_of_states).to_a
  filter_states(@state_ids)
  # Create a bitmap big enough to hold all the elements
  self.contents = Bitmap.new(width - 32, @state_ids.size * 32)
  # If the bitmap is bigger than the window's display height (h-32),
  # Than enable automatic scrolling by setting @max_oy > 0
  @max_oy = self.contents.height - (self.height - 32)
  @wait_count = 80
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def refresh
  # Clear contents
  self.contents.clear
  padding = 0
  height = 32
  width = self.contents.width - padding
  # draw all elements
  for i in 0...@state_ids.size
   draw_state(padding, i * height, width, height, @state_ids[i])
  end
 end

end
#==============================================================================
# ** Window_BeastDetail
#------------------------------------------------------------------------------
#  This window displays detailed information on scanned beasts
#==============================================================================
class Window_BeastDetail < Window_BeastInformation
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize()
  super(0, 0, 640, 320)
  self.z = 98
  self.back_opacity = 240
  refresh
 end
 #--------------------------------------------------------------------------
 # * refresh
 #--------------------------------------------------------------------------
 def refresh
  # Clear contents
  self.contents.clear
  return if @enemy == nil
  # Set up drawing variables
  color = Mobius::Beastiary::DIVIDER_LINE_COLOR
  w3 = contents.width / 3
  # Draw name
  self.contents.draw_text(4, 0, w3, 32, @enemy.name)
  # Draw header line
  self.contents.fill_rect(0, 32, w3, 1, color)
  # Draw divider lines
  self.contents.fill_rect(w3, 0, 1, 320 - 32, color)
  self.contents.fill_rect(w3, (5 * 32), (2 * w3), 1, color)
  # Draw stats
  draw_stats
  # Draw Elements
  draw_elements
  # Draw States
  draw_states
 end
 #--------------------------------------------------------------------------
 # * Draw all stats
 #--------------------------------------------------------------------------
 def draw_stats
  column_max = 2
  padding = 4
  height = 32
  width = contents.width / 3
  offset = width + 4
  for i in 0..9
   x = i % column_max * (width + padding) + offset
   y = i / column_max * height
   draw_enemy_parameter(x, y, width - (2 * padding), height, i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw top/bottom elements
 #--------------------------------------------------------------------------
 def draw_elements
  padding = 4
  w3 = contents.width / 3
  width = w3 - padding
  height = 32
  self.contents.font.color = system_color
  self.contents.draw_text(0, 32, width, height, "Strong Elements", 1)
  strong = strong_elements()
  draw_element(0, 2*32, width, height, strong[0]) if strong[0]
  draw_element(0, 3*32, width, height, strong[1]) if strong[1]
  draw_element(0, 4*32, width, height, strong[2]) if strong[2]
  self.contents.font.color = system_color
  self.contents.draw_text(0, 5*32, width, height, "Weak Elements", 1)
  weak = weak_elements()
  draw_element(0, 6*32, width, height, weak[0]) if weak[0]
  draw_element(0, 7*32, width, height, weak[1]) if weak[1]
  draw_element(0, 8*32, width, height, weak[2]) if weak[2]
 end
 #--------------------------------------------------------------------------
 # * Draw top/bottom states
 #--------------------------------------------------------------------------
 def draw_states
  padding = 4
  w3 = contents.width / 3
  width = w3 - padding
  height = 32
  x = w3 + padding
  x2 = (2 * w3) + padding
  self.contents.font.color = system_color
  self.contents.draw_text(x, 5*32, width, height, "Strong States", 1)
  strong = strong_states()
  draw_state(x, 6*32, width, height, strong[0]) if strong[0]
  draw_state(x, 7*32, width, height, strong[1]) if strong[1]
  draw_state(x, 8*32, width, height, strong[2]) if strong[2]
  self.contents.font.color = system_color
  self.contents.draw_text(x2, 5*32, w3, height, "Weak States", 1)
  weak = weak_states()
  draw_state(x2, 6*32, width, height, weak[0]) if weak[0]
  draw_state(x2, 7*32, width, height, weak[1]) if weak[1]
  draw_state(x2, 8*32, width, height, weak[2]) if weak[2]
 end
 #--------------------------------------------------------------------------
 # * Get a set of IDs while applying a filter
 #--------------------------------------------------------------------------
 def filter(original)
  copy = original.dup
  yield(copy)
  return copy
 end
 #--------------------------------------------------------------------------
 # * Get the enemies strong elements filtering out hidden elements
 #--------------------------------------------------------------------------
 def strong_elements
  return filter(@enemy.strong_elements) {|arr| filter_elements(arr)}
 end
 #--------------------------------------------------------------------------
 # * Get the enemies weak elements filtering out hidden elements
 #--------------------------------------------------------------------------
 def weak_elements
  return filter(@enemy.weak_elements) {|arr| filter_elements(arr)}
 end
 #--------------------------------------------------------------------------
 # * Get the enemies strong states filtering out hidden elements
 #--------------------------------------------------------------------------
 def strong_states
  return filter(@enemy.strong_states) {|arr| filter_states(arr)}
 end
 #--------------------------------------------------------------------------
 # * Get the enemies weak states filtering out hidden elements
 #--------------------------------------------------------------------------
 def weak_states
  return filter(@enemy.weak_states) {|arr| filter_states(arr)}
 end

end
#==============================================================================
# ** Window_BeastSubDetail
#------------------------------------------------------------------------------
#  This window allows for separate scrolling of beast details
#==============================================================================
class Window_BeastSubDetail < Window_Selectable
 #--------------------------------------------------------------------------
 # * Object Initialization
 #  type - 1, 2, 3 --> 1=stats, 2=elements, 3=states
 #--------------------------------------------------------------------------
 def initialize(enemy, in_battle, type)
  # Configuration values - change these two to configure the three windows
  padding = 4
  overlap = 29
  # Calculated values - derived from above two
  w = (640 + (2 * overlap) - (2 * padding)) / 3    # Window Width
  h = 320 - 32                                     # Window Height
  x1 = padding                                     # Stat Window x-coordinate
  x2 = padding + w - overlap                       # Element Window x-coordinate
  x3 = padding + (2 * w) - (2 * overlap)           # State Window x-coordinate
  if in_battle
   y = 4 + 32                                   # All Window y-coordinate
  else
   y = 4 + 160 + 32                             # All Window y-coordinate
  end
  case type
  when 1 ; x = x1
  when 2 ; x = x2
  when 3 ; x = x3
  end
  # Use calculated values to create window
  super(x, y, w, h)
  # Initialize variables
  @enemy = enemy
  @in_battle = in_battle
  @type = type
  @index = 0
  @item_max = 0
  self.active = false
  self.opacity = 0
  self.back_opacity = 0
  self.contents = Bitmap.new(w - 32, h - 32)
  refresh
 end
 #--------------------------------------------------------------------------
 # * refresh
 #--------------------------------------------------------------------------
 def refresh
  # dispose contents
  if self.contents != nil
   self.contents.dispose
  end
  # reset index
  self.index = 0
  # reset number of items
  @item_max = 0
  unless @enemy == nil
   case @type
   when 1 ; draw_stats
   when 2 ; draw_elements
   when 3 ; draw_states
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Set Enemy - Calls refresh as needed
 #--------------------------------------------------------------------------
 def enemy=(enemy)
  if @enemy != enemy
   @enemy = enemy
   refresh
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Stats - draws an enemy's stats
 #--------------------------------------------------------------------------
 def draw_stats
  # configuration
  padding = 2
  @item_max = 10
  # create bitmap
  self.contents = Bitmap.new(width - 32, @item_max * 32)
  w = self.contents.width - (2 * padding)
  # draw all stats
  for i in 0..9
   draw_enemy_parameter(@enemy, padding, i * 32, w, 32, i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Enemy Parameter
 #     enemy : enemy
 #     x     : draw spot x-coordinate
 #     y     : draw spot y-coordinate
 #     w     : draw spot width
 #     h     : draw spot height
 #     type  : parameter type (0-9)
 #--------------------------------------------------------------------------
 def draw_enemy_parameter(enemy, x, y, w, h, type)
  case type
  when 0
   parameter_name = $data_system.words.hp
   parameter_value = enemy.maxhp
  when 1
   parameter_name = $data_system.words.sp
   parameter_value = enemy.maxsp
  when 2
   parameter_name = $data_system.words.atk
   parameter_value = enemy.atk
  when 3
   parameter_name = $data_system.words.pdef
   parameter_value = enemy.pdef
  when 4
   parameter_name = $data_system.words.mdef
   parameter_value = enemy.mdef
  when 5
   parameter_name = $data_system.words.str
   parameter_value = enemy.str
  when 6
   parameter_name = $data_system.words.dex
   parameter_value = enemy.dex
  when 7
   parameter_name = $data_system.words.agi
   parameter_value = enemy.agi
  when 8
   parameter_name = $data_system.words.int
   parameter_value = enemy.int
  when 9
   parameter_name = Mobius::Beastiary::EVASION_WORD
   parameter_value = enemy.eva
  end
  # draw stat name
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, parameter_name)
  # draw stat value
  self.contents.font.color = normal_color
  self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
 end
 #--------------------------------------------------------------------------
 # * Draw Elements - draws an enemy's elemental strengths/weaknesses
 #--------------------------------------------------------------------------
 def draw_elements
  # configuration
  padding = 2
  @item_max = $data_system.elements.size - 1
  # create bitmap
  self.contents = Bitmap.new(width - 32, @item_max * 32)
  # draw all elements
  for i in 1...$data_system.elements.size
   draw_element(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Element
 #     x           : draw spot x-coordinate
 #     y           : draw spot y-coordinate
 #     w           : draw spot width
 #     h           : draw spot height
 #     element_id  : element_id corresponds to database value
 #--------------------------------------------------------------------------
 def draw_element(x, y, w, h, element_id)
  # get element name
  name = $data_system.elements[element_id]
  # draw name
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, name, 0)
  # get element rank
  element_rank = element_rank_decode(@enemy.element_ranks[element_id])
  # draw element rank
  self.contents.font.color = normal_color
  self.contents.draw_text(x, y, w, h, element_rank, 2)
 end
 #--------------------------------------------------------------------------
 # * Element Rank Decode - converts integer to string based on customization
 #--------------------------------------------------------------------------
 def element_rank_decode(element_rank)
  case element_rank
  when 1 # Very Weak = 200%
   return Mobius::Beastiary::ELEMENT_WORD_200
  when 2 # Weak = 150%
   return Mobius::Beastiary::ELEMENT_WORD_150
  when 3 # Normal = 100%
   return Mobius::Beastiary::ELEMENT_WORD_100
  when 4 # Resistant = 50%
   return Mobius::Beastiary::ELEMENT_WORD_50
  when 5 # Immune = 0%
   return Mobius::Beastiary::ELEMENT_WORD_0
  when 6 # Absorb = -100%
   return Mobius::Beastiary::ELEMENT_WORD_M100
  end
 end
 #--------------------------------------------------------------------------
 # * Draw States - draws an enemy's status strengths/weaknesses
 #--------------------------------------------------------------------------
 def draw_states
  # configuration
  padding = 2
  @item_max = $data_states.size - 1
  # create bitmap
  self.contents = Bitmap.new(width - 32, @item_max * 32)
  # draw all states
  for i in 1...$data_states.size
   draw_state(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw State
 #     x           : draw spot x-coordinate
 #     y           : draw spot y-coordinate
 #     w           : draw spot width
 #     h           : draw spot height
 #     state_id    : state_id corresponds to database value
 #--------------------------------------------------------------------------
 def draw_state(x, y, w, h, state_id)
  # get name
  name = $data_states[state_id].name
  # draw name
  self.contents.font.color = system_color
  self.contents.draw_text(x, y, w, h, name, 0)
  # get state rank
  state_rank = state_rank_decode(@enemy.state_ranks[state_id])
  # draw state name
  self.contents.font.color = normal_color
  self.contents.draw_text(x, y, w, h, state_rank, 2)
 end
 #--------------------------------------------------------------------------
 # * State Rank Decode - converts integer to string based on customization
 #--------------------------------------------------------------------------
 def state_rank_decode(state_rank)
  case state_rank
  when 1 # Very Weak = 100%
   return Mobius::Beastiary::STATUS_WORD_100
  when 2 # Weak = 80%
   return Mobius::Beastiary::STATUS_WORD_80
  when 3 # Normal = 60%
   return Mobius::Beastiary::STATUS_WORD_60
  when 4 # Resistant = 40%
   return Mobius::Beastiary::STATUS_WORD_40
  when 5 # Very Resistant = 20%
   return Mobius::Beastiary::STATUS_WORD_20
  when 6 # Immune = 0%
   return Mobius::Beastiary::STATUS_WORD_0
  end
 end
end
#==============================================================================
# ** Scene_Beastiary
#------------------------------------------------------------------------------
#  This class performs beastiary screen processing.
#==============================================================================
class Scene_Beastiary
 #--------------------------------------------------------------------------
 # * Create Windows
 #--------------------------------------------------------------------------
 def create_windows
  @Window_BeastList = Window_BeastList.new
  @Window_BeastMode = Window_BeastMode.new
  @Window_BeastSprite = Window_BeastSprite.new
  @Window_BeastSprite.visible = true
  @Window_BeastStats = Window_BeastStats.new
  @Window_BeastElements = Window_BeastElements.new
  @Window_BeastStates = Window_BeastStates.new
 end
 #--------------------------------------------------------------------------
 # * Update Windows
 #--------------------------------------------------------------------------
 def update_windows
  @Window_BeastList.update
  @Window_BeastMode.update
  @Window_BeastSprite.update
  @Window_BeastStats.update
  @Window_BeastElements.update
  @Window_BeastStates.update
 end
 #--------------------------------------------------------------------------
 # * Dispose Windows
 #--------------------------------------------------------------------------
 def dispose_windows
  @Window_BeastList.dispose
  @Window_BeastMode.dispose
  @Window_BeastSprite.dispose
  @Window_BeastStats.dispose
  @Window_BeastElements.dispose
  @Window_BeastStates.dispose
 end
 #--------------------------------------------------------------------------
 # * Main Processing
 #--------------------------------------------------------------------------
 def main
  # Create windows
  create_windows
  # Execute transition
  Graphics.transition
  # Main loop
  loop do
   # Update game screen
   Graphics.update
   # Update input information
   Input.update
   # Frame update
   update
   # Abort loop if screen is changed
   if $scene != self
    break
   end
  end
  # Prepare for transition
  Graphics.freeze
  # Dispose of windows
  dispose_windows
 end
 #--------------------------------------------------------------------------
 # * update
 #--------------------------------------------------------------------------
 def update
  update_windows
  update_list
  update_mode
 end
 #--------------------------------------------------------------------------
 # * Update List
 #--------------------------------------------------------------------------
 def update_list
  enemy = @Window_BeastList.enemy
  # Set enemy in windows if the party has scanned it
  if $game_party.scan_list.include?(enemy.id)
   @Window_BeastSprite.enemy = enemy
   @Window_BeastStats.enemy = enemy
   @Window_BeastElements.enemy = enemy
   @Window_BeastStates.enemy = enemy
  else
   @Window_BeastSprite.enemy = nil
   @Window_BeastStats.enemy = nil
   @Window_BeastElements.enemy = nil
   @Window_BeastStates.enemy = nil
  end
  # When cancel
  if Input.trigger?(Input::B)
   # Play cancel SE
   $game_system.se_play($data_system.cancel_se)
   # Exit to menu by default
   if Mobius::Beastiary::EXIT_TO_MENU
    $scene = Scene_Menu.new
   else
    $scene = Scene_Map.new
   end
  end
 end
 #--------------------------------------------------------------------------
 # * Update Mode
 #--------------------------------------------------------------------------
 def update_mode
  # Hide all mode windows
  @Window_BeastSprite.visible = false
  @Window_BeastStats.visible = false
  @Window_BeastElements.visible = false
  @Window_BeastStates.visible = false
  # Show only selected window
  case @Window_BeastMode.index
   # When Sprite
  when 0
   @Window_BeastSprite.visible = true
   # When Stats
  when 1
   @Window_BeastStats.visible = true
   # When Elements
  when 2
   @Window_BeastElements.visible = true
   # When States
  when 3
   @Window_BeastStates.visible = true
  end
 end

end
#=========================BEASTIARY EXPANSION END==============================

#===============================RGSS CHANGES===================================
#==============================================================================
# ** RPG::Enemy changes
#==============================================================================
module RPG
 class Enemy
  alias base_name name
  #--------------------------------------------------------------------------
  # * Get IDs bundled with their Ranks
  #--------------------------------------------------------------------------
  def id_with_rank(rank_array)
   size = rank_array.xsize - 1
   result = []
   for id in 1..size
    rank = rank_array[id]
    if yield(rank)
     result.push([id, rank])
    end
   end
   return result
  end
  #--------------------------------------------------------------------------
  # * Get Strong Elements
  #--------------------------------------------------------------------------
  def strong_elements
   strong_element_array = id_with_rank(element_ranks) { |rank| rank > 3 }
   strong_element_array.sort! do |a,b|
    b[1] <=> a[1] # Sort greater rank (6) to front of array (lower index)
   end
   return strong_element_array.map do |tuple|
    tuple[0] # return just the ID
   end
  end
  #--------------------------------------------------------------------------
  # * Get Weak Elements
  #--------------------------------------------------------------------------
  def weak_elements
   weak_element_array = id_with_rank(element_ranks) { |rank| rank < 3 }
   weak_element_array.sort! do |a,b|
    a[1] <=> b[1] # Sort lower rank (1) to front of array (lower index)
   end
   return weak_element_array.map do |tuple|
    tuple[0] # return just the ID
   end
  end
  #--------------------------------------------------------------------------
  # * Get Element Efficiency - Human readable string
  #     element_id : Element ID
  #--------------------------------------------------------------------------
  def element_efficiency(element_id)
   element_rank = element_ranks[element_id]
   return element_rank_decode(element_rank)
  end
  #--------------------------------------------------------------------------
  # * Element Rank Decode - converts integer to string based on customization
  #--------------------------------------------------------------------------
  def element_rank_decode(element_rank)
   case element_rank
   when 1 # Very Weak = 200%
    return Mobius::Beastiary::ELEMENT_WORD_200
   when 2 # Weak = 150%
    return Mobius::Beastiary::ELEMENT_WORD_150
   when 3 # Normal = 100%
    return Mobius::Beastiary::ELEMENT_WORD_100
   when 4 # Resistant = 50%
    return Mobius::Beastiary::ELEMENT_WORD_50
   when 5 # Immune = 0%
    return Mobius::Beastiary::ELEMENT_WORD_0
   when 6 # Absorb = -100%
    return Mobius::Beastiary::ELEMENT_WORD_M100
   end
  end
  #--------------------------------------------------------------------------
  # * Get Strong States
  #--------------------------------------------------------------------------
  def strong_states
   strong_state_array = id_with_rank(state_ranks) { |rank| rank > 3 }
   strong_state_array.sort do |a,b|
    aID = a[0]
    aRank = a[1]
    aRating = $data_states[aID].rating
    bID = b[0]
    bRank = b[1]
    bRating = $data_states[bID].rating
    # Sort greater rank (6) to front of array (lower index)
    # If ranks are equal, sort higher rating to front
    [bRank, bRating] <=> [aRank, aRating]
   end
   return strong_state_array.map do |tuple|
    tuple[0] # return just the ID
   end
  end
  #--------------------------------------------------------------------------
  # * Get Weak States
  #--------------------------------------------------------------------------
  def weak_states
   weak_state_array = id_with_rank(state_ranks) { |rank| rank < 3 }
   weak_state_array.sort! do |a,b|
    aID = a[0]
    aRank = a[1]
    aRating = $data_states[aID].rating
    bID = b[0]
    bRank = b[1]
    bRating = $data_states[bID].rating
    # Sort lower rank (1) to front of array (lower index)
    # If ranks are equal, sort higher rating to front
    [aRank, bRating] <=> [bRank, aRating]
   end
   return weak_state_array.map do |tuple|
    tuple[0] # return just the ID
   end
  end
  #--------------------------------------------------------------------------
  # * Get State Efficiency - Human readable string
  #     state_id : State ID
  #--------------------------------------------------------------------------
  def state_efficiency(state_id)
   state_rank = state_ranks[state_id]
   return state_rank_decode(state_rank)
  end
  #--------------------------------------------------------------------------
  # * State Rank Decode - converts integer to string based on customization
  #--------------------------------------------------------------------------
  def state_rank_decode(state_rank)
   case state_rank
   when 1 # Very Weak = 100%
    return Mobius::Beastiary::STATUS_WORD_100
   when 2 # Weak = 80%
    return Mobius::Beastiary::STATUS_WORD_80
   when 3 # Normal = 60%
    return Mobius::Beastiary::STATUS_WORD_60
   when 4 # Resistant = 40%
    return Mobius::Beastiary::STATUS_WORD_40
   when 5 # Very Resistant = 20%
    return Mobius::Beastiary::STATUS_WORD_20
   when 6 # Immune = 0%
    return Mobius::Beastiary::STATUS_WORD_0
   end
  end
 end
end
#==============================================================================
# ** RPG::Cache changes
#==============================================================================
module RPG::Cache
 #--------------------------------------------------------------------------
 # * Status icon loading from cache
 #--------------------------------------------------------------------------
 def self.status_icon(filename)
  path = Mobius::Status_Icons::STATUS_ICON_PATH
  self.load_bitmap(path, filename)
 end
 #--------------------------------------------------------------------------
 # * Beastiary sprite loading from cache
 #--------------------------------------------------------------------------

 def self.beastiary_sprite(filename)
  path = Mobius::Beastiary::BEASTIARY_SPRITE_PATH
  self.load_bitmap(path, filename)
 end
end
#=============================RGSS CHANGES END=================================

