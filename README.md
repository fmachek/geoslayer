# Geoslayer

This is the repository for my game: Geoslayer. I am currently working on version 0.2.1. The game is not completely finished yet, because I'd like to add more features. It is definitely playable though.

To play the game, you can download the latest release [here](https://github.com/fmachek/geoslayer/releases/tag/v0.2.0).

## Technologies used

* Godot Engine 4.7
* GDScript

## Overview

Geoslayer is a 2D wave survival game with simple graphics. You use your 2 abilities to defeat incoming enemies. You also have a dashing ability you can use to dodge incoming attacks. Beat the boss who spawns at the end to win.

Unlock abilities from chests you get for surviving waves, pick the ones you want to use. Currently there are 22 player abilities in total.

You get XP by defeating enemies or opening chests. When you level up, you gain a few points you can use to upgrade your stats. When you win the game by defeating the boss and you exit the arena, the XP you earned is converted into permanent XP. When you increase your permanent level, you also gain stat points similar to the ones you earned in-game. These permanent stat points can also occasionally drop from enemies.

Your permament level is important when entering different worlds. Worlds after World 1 require you to have be at a certain level to enter.

### Gameplay showcase

![Gameplay](./docs/media/gameplay.gif)

### Player abilities

There are currently 22 abilities usable by the player. Abilities are unlocked from chests. Each ability has a "theme", for example magical. Regular abilities with no particular theme (the abilities with a regular gray background in their icon) are unlockable in World 1, whereas magical abilities are unlockable in World 2. Regular abilities are unlockable in World 2 as well - the magical abilities are added into the drop pool on top of the World 1 drop pool.

The player also always has a dodge ability alongside the two abilities they equip.

## Credits

Here is some of the stuff I used:

* Kenney: https://kenney.nl/
    * Some assets, such as UI icons
* Sora: https://fonts.google.com/specimen/Sora
    * This is the main font the game uses
