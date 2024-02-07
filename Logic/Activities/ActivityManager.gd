class_name ActivityManagerSingleton extends Node

signal activity_popped(activity: Activity)
signal activity_pushed(activity: Activity)

var activity_stack: Array[Activity] = []

func push(activity: Activity):
	activity_stack.append(activity)
	activity_pushed.emit(activity)

func substitute(activity: Activity):
	pop()
	push(activity)

func pop():
	var activity = activity_stack.pop_back()
	activity_popped.emit(activity)
	return activity

func peek():
	return activity_stack[len(activity_stack) - 1]
