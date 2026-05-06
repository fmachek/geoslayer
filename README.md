# Geoslayer
This is my project I started simply to improve at developing games in Godot Engine, but it has actually turned out to be a bit more than that.

## Technologies used
* Godot Engine 4.6
* GDScript

## About the game

Geoslayer is a 2D wave-based survival game with simple graphics. You use your 2 abilities to defeat incoming enemies. Beat the boss who spawns at the end to win.

Unlock abilities from chests you get for surviving waves, pick and choose which ones you want to use. Currently there are 15 player abilities in total.

You get XP by defeating enemies or opening chests. When you level up, you gain a few points you can use to upgrade your stats. When you win the game by defeating the boss and you exit the arena, the XP you earned is converted into permanent XP. When you increase your permanent level, you also gain stat points similar to the ones you earned in-game. These permanent stat points can also occasionally drop from enemies.

Your permament level is important when entering different worlds. Every world other than World 1 (and World 0, a testing world) will have a level requirement.

### Gameplay showcase
![Gameplay](./assets/screenshots/gameplay.gif)

### Player abilities
There are currently 15 abilities unlockable by the player. Their types are essentially their themes.
Earlier worlds have a more limited drop pool of abilities. For example, World 1 only drops regular abilities. World 2 adds magical abilities on top of that.

| Ability name | Ability description | Type |
| ------------ | ------------------- | ------------------- |
| Shoot        | Basic starter ability, fires a projectile | Regular |
| Doubleshot   | Fires two projectiles in parallel | Regular |
| Cannonball   | Fires a large and high-damage but slow projectile, it also applies a huge knockback | Regular |
| Blast        | Fires projectiles with huge knockback in all directions | Regular |
| Flurry       | Fires multiple projectiles with recoil in quick succession | Regular |
| Wideshot     | Fires multiple projectiles in a cone | Regular |
| Pierce       | Fires a high-damage fast piercing projectile, but requires a cast | Regular |
| Explosive    | Fires a projectile which explodes into more smaller projectiles on impact | Regular |
| Lifesteal    | Fires 3 projectiles which heal the caster for a portion of the damage dealt | Regular |
| Shred        | Close range cone attack which applies an armor and speed buff to the caster if the projectiles hit a target | Regular |
| Swipe        | Performs a swipe melee attack | Regular |
| Smash        | Deals damage to, stuns and knocks enemies around the caster back | Regular |
| Storm        | Spawns an area which damages and slows enemies down while they're standing in it | Magical |
| Summon       | Spawns multiple minions who fight alongside the player | Magical |
| Teleport     | Teleports the caster | Magical |

## Credits
* Kenney (some assets): https://kenney.nl/