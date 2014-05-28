# Description:
#   Simple todo app to help keep the mind clear
#
# Dependencies:
#
# Configuration:
#   None
#
# Commands:
#   /todos add <description> - Add a new todo with a basic description
#   /todos finish[ed] <item number | all> - Remove a todo item from the list
#   /todos list - List your tasks
#   /todos help - Get help with this plugin
#
# Author:
#   Harry Wincup <harry@harrywincup.co.uk>

class Todos
	constructor: (@robot) ->
		@robot.brain.data.todos = {}

		@robot.hear /^\/todos add (.*)$/i, @addItem
		@robot.hear /^\/todos finish(?:ed)? ([0-9+]|all)/i, @removeItem
		@robot.hear /^\/todos list$/i, @listItems
		@robot.hear /^\/todos help$/i, @help

	help: (msg) =>
		commands = @robot.helpCommands()
		commands = (command for command in commands when command.match(/\/todos/))

		msg.send commands.join("\n")

	addItem: (msg) =>
		user 	   = msg.message.user
		description = msg.match[1]

		@robot.brain.data.todos[user.id] ?= []
		@robot.brain.data.todos[user.id].push(description)

		totalItems = @getItems(user).length
		multiple   = totalItems isnt 1

		message = "#{totalItems} item" + (if multiple then 's' else '') + " in your list\n\n"
		message += @createListMessage(user)

		msg.send message

	removeItem: (msg) =>
		user 	  = msg.message.user
		item       = msg.match[1]
		items      = @getItems(user)
		totalItems = items.length

		if item isnt 'all' and item > totalItems
			if totalItems > 0
				message = "That item doesn't exist."
				message += " Here's what you've got:\n\n"
				message += @createListMessage(user)
			else
				message = "There's nothing on your list at the moment"

			msg.send message

			return

		if item is 'all'
			@clearAllItems(user)
		else
			@robot.brain.data.todos[user.id].splice(item - 1, 1)

		message = "Good stuff!"

		remainingItems = @getItems(user)
		multiple 	  = remainingItems.length isnt 1

		if remainingItems.length > 0
			message += " #{remainingItems.length} item" + (if multiple then 's' else '') + " left:\n\n"

			message += @createListMessage(user)
		else
			message += " You're all done :)"

		msg.send message

	clearAllItems: (user) => @robot.brain.data.todos[user.id].length = 0

	createListMessage: (user) =>
		items = @getItems(user)

		message = ""

		if items.length > 0
			for todo, index in items
				message += "#{index + 1}) #{todo}\n"
		else
			message += "Nothing to do at the moment!"

		return message

	getItems: (user) => return @robot.brain.data.todos[user.id] or []

	listItems: (msg) =>
		user   	= msg.message.user
		totalItems = @getItems(user).length
		multiple   = totalItems isnt 1

		message = ""

		if totalItems > 0
			message += "#{totalItems} item" + (if multiple then 's' else '') + " in your list\n\n"

		message += @createListMessage(user)

		msg.send message

module.exports = (robot) -> new Todos(robot)
