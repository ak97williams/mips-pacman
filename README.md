# mips-pacman
A simple version of pacman developed using mips assembly language


Alexander Williams
CS 0447 Spring 2017
Dr. Childers
Zombies readme

ISSUES
1.	Seeking function for code is disabled. everything runs with no known errors other than the lack of seeking.
2.	The seeking function can be reenabled on line 357, but if done so zombies will occasionally backtrack,
	also after a certain number of moves a zombie will teleport to the top left corner and crash the program.

APPROACH
1.	Began by declaring variables and arrays for all the needed data for the program.

2.	There is a loop in the beginning that waits until the b key is pressed, once the b key is pressed the loop
	ends allowing for the game to begin running. First the horizontal and vertical edges of the map are drawn.
	Then, Five drawbox programs run which make the inside part of the maze by loading parts of the maze pattern
	and repeatedly drawing those. A second edge program and a cleanup program run to fix up the corners
	and right edge. Finally, the program puts the players and zombies in their locations.

3.	A poll loop is continually run which, every 500ms, jumps to zombie movement, and also continually checks if
	the user has pressed a valid key, at which point it jumps to player movement. Also, the poll loop continually
	checks if the player has reached the end, or if a player and zombie location match, in which case the game is
	lost. The way the poll checks keys, is it checks if a certain key has been pressed, and if not it jumps to check
	the next key. If a key is pressed, it jumps to the appropriate move function.

4.	The move functions operate by checking if the player is out of bounds for the map, and aborting if that is the
	case. Otherwise, it then checks if that would move the player into a wall, in which case it also goes back to
	poll. Then, it sets the new location to green and reverts the old position to off and updates player location.
	Finally, it adds one to the number of moves performed before jumping back to poll.

5.	When moveZombie runs it adds 500 to the timer to update it, then part 2 loads the zombie location and previous
	location. It checks if the zombie is in a location where it needs to backtrack, in which case it does so by
	swapping the current and previous location and updating leds. Then, it checks which quadrant the player is in
	and sees if the zombie is of that same quadrant. If smartMove is enabled, it will branch if they are in the same
	quadrant, otherwise it will jump to move part 3. move part 3 generates a random number 0-3 and then picks a
	direction based off of the number. It checks if that move would place it out of bounds, into a wall, or if it
	would backtrack the zombie. If any of those are the case, it goes back and generates another number and tries
	again. Once a successfull move is made, it adds to the zombie location arrays and goes through the process with
	another zombie until all four zombies have moved.

6.	smartMove is the attempt to make the zombies move intelligently. It first finds the distance between the player
	and the zombie, then squares it to ensure a positive number. Then it checks different directions to see which
	one yields a smaller distance than the original. If it does, it checks if the move is illegal (i.e. if it
	backtracks or moves out of bounds or into a wall). If the move is legal, it then jumps to the move to that
	specific zombie move direction.

7.	If the player is captured then the game ends and the console prints out the appropriate lose message. Conversely,
	if the player gets to the position (63, 63) then the game ends and prints out the number of moves made along with
	the winning message.

8.	The _getLED and _setLED commands that were provided were used for the modifying of leds and the board and for
	the checking of wall validity.
