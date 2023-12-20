# Prompt
# This function prompts the user to fill fields that have to be specified
Check_point = function(Message){
  Variables_set = askYesNo(msg = Message)
  stopifnot("Make sure the fields are filled!" = isTRUE(Variables_set))
}

