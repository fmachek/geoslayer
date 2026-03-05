# project01
This is my Godot project which should, ideally, not take too long to finish and should help me learn some new things. I have made a game in Godot before, but there are some things I know I could do better and stuff I don't know at all.

I have a few things in mind:
1. Simple saving and loading - most likely just permanent progression, not the current map
2. Better use of signals
3. Better overall project structure
4. Simple NPCs - already mostly done
5. Learn Godot workflow better

Of course, these are just a few things I came up with right now. I'll probably learn more stuff along the way.

In the last version of this readme, I mentioned that I had decided on a simple movement system without pathfinding for simplicity. That has changed (kind of), because I have run into an issue where the NPCs eventually occupy the exact same position if they chase you for a long enough time. Therefore, I need to use avoidance at the very least. So I can't completely avoid pathfinding. I have yet to look into how to use avoidance.

## What is this game even about?

Because this is just a project I started in my free time for fun and learning, I don't EXACTLY know what I'm making. I come up with stuff on the go. But to summarize the overall vision: it's a 2D game with simple shapes where you have two abilities which you can unlock and then equip in one of 2 slots, which you then cast to defeat enemies who will, inevitably, shoot at and defeat you. Enemies come in waves. You level up to become stronger and unlock new abilities (level up unlocks aren't implemented yet).

## What have I made so far?
1. Characters (both player and NPCs)
2. Stat system (HP etc)
3. Ability system along with a very simple and yet to be redesigned UI
4. Levels and XP
5. Simple main menu
6. Waves

## Screenshots of the current state
<img width="1152" height="648" alt="menu" src="https://github.com/user-attachments/assets/d9fe2b13-5560-4105-ae91-6bf462073eb2" />

<img width="1152" height="648" alt="ingame" src="https://github.com/user-attachments/assets/17af71e1-2475-45ed-bc0c-06ddae286423" />
