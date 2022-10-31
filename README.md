# coin-dispenser
A coin dispenser machine is used to exchange bank notes for equal values of coins. The coin dispenser is configurable in such a way it dispenses two or three denominations of coins for notes Rs.10, Rs.20, Rs.50, Rs.100 & Rs.200.
Coin vending machine dispenses coins in denominations of Rs.5, Rs.2 & Rs.1.
Coin vending machine useful for dispensing coins at dispensing coins at needy locations.
This design aims to only dispense the least number of coins necessary depending on the denomination and the number of coins in the machine.A 

/* 					-------------------------------------- COIN DISPENSER --------------------------------
 * 
 * This design is the implementation of coin dispenser which dispense Rs.5, Rs.2, Rs.1 coins based on note which is inserted.
 * This Coin Dispenser only accepts the notes which are less than or equal to 200
 * User can have an ability to select the denomination type of the coins in but should be in 2 or more denominations.
 * So, Output coins denominations can be of
 	- 5 coins, 2 coins & 1 coins
	- 5 coins & 2 coins
	- 5 coins & 1 coins
	- 2 coins & 1 coins
 * 					---------------------------------- PINS & DESCRIPTION --------------------------------
	________________________________________________________________________________________________________________________________________________
	|	PIN NAME	|	PIN TYPE	|		PIN DESCRIPTION									|
	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	clk_in		|	INPUT		|	Time Clock										|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	rst_in		|	INPUT		|	Asynchronous Active Low Reset								|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|    note_inserted_in	|	INPUT		|	To acknoledge system that note as inserted						|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	note_code_in	|	INPUT		|	Describes the value of note through a predefined code					|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	den_5_2_1_in	|	INPUT		|	Selection Switch to user, incase if user needs denomination in Rs.5, Rs.2 & Rs.1 coins	|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	den_5_2_in	|	INPUT		|	Selection Switch to user, incase if user needs denomination in Rs.5 & Rs.2 only		|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	den_5_1_in	|	INPUT		|	Selection Switch to user, incase if user needs denomination in Rs.5 & Rs.1 only		|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	den_2_1_in	|	INPUT		|	Selection Switch to user, incase if user needs denomination in Rs.2 & Rs.1 only		|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|    insert_note_out	|	OUTPUT		|	To acknowledge user that system is ready to accept notes				|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	rs5_coins_out	|	OUTPUT		|	Output variable for number of Rs.5 coins have to dispense				|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	rs2_coins_out	|	OUTPUT		|	Output variable for number of Rs.2 coins have to dispense				|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	rs1_coins_out	|	OUTPUT		|	Output variable for number of Rs.1 coins have to dispense				|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|    invalid_note_out	|	OUTPUT		|	Signal Asserts if note value is greater than 200					|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|select_denominaiton_out|	OUTPUT		|	Signal Asserts to acknowledge that note was accepted and asks for denomination selection|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|invalid_denomination_out|	OUTPUT		|	Signal Asserts if note is Rs.10 and denomination selected as de_5_2			|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|	processing_out	|	OUTPUT		|	Signal Asserts while system is in processing state					|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	|    collect_coins_out	|	OUTPUT		|	Signal Asserts to acknowledge user to collect coins					|
 	|-----------------------|-----------------------|-----------------------------------------------------------------------------------------------|
 	| coins_insufficent_out	|	OUTPUT		|	Signal Asserts to acknowldge that system has insufficient coins				|
 	|_______________________|_______________________|_______________________________________________________________________________________________|
 
* The agenda of this model is to dispense minimum number of coins in the respective denomination.
*/
