##################################################################
####						juco.tcl 1.6				      ####
##################################################################
####			Credit to X-poz for MiG TCL.				######
####			Couldn't have put it better myself			######
##################################################################
####	        Bugs? report to julian@juco.co.uk 			######
##################################################################

########################### NOTICE ###############################
### When the script is installed, set a contact email with:
### $BotPrefex set email my@email.here
### This enables users to view it and use it if necessary.
#################################################################

##############################################################
######## You need to edit this section to suit you ###########
##############################################################
#Set Root Administrator (your primary nickname)
set root "juco"

#Set your main bot prefex e.g. foo, foobot
set command1 "foo"

#Set another bot prefex
set command2 "foobot"

#Set a Group command.  This is handy if you have multiple bots
#running this script, you can issue commands to all of them
#at once.
set groupcommand "rbots"
##############################################################

## Services - Register the bots nickname - Default is DALnet ##
#NickServ's nickname
set nsnick "nickserv@services.dal.net"

#ChanServ's nickname
set csnick "chanserv@services.dal.net"

#NickServ Password
set nspass "mys3cr3t3p455"
#################################################################

# Commands made to the bot are logged. Set a file here, and set permission accordingly.
#Set your log file, or leave as default.
set log "bot.log"
#Set the path to your eggdrop
set path "/home/juco/eggdrop"
#################################################################

###### Log dumping is something that's newly implimented to the juco.tcl script,
###### If set to "1" the bot will post all commands issued to logchan.
set dump 1
set logchan "#juco"
#################################################################

###### User cleaning: a Handy tool stolen from salvation.tcl (Corey) -
###### Will del all users not seen for 20 days
bind time - "01 00 * * *" clean
set do_clean "enabled"
#################################################################

###### More so optional variables, leave as default if you please
#Set the message to be displayed when kicking from a +restric channel
set restrictkick "This channel is restricted to users with bot access."

#####################################################################
#####################################################################
####################### SCRIPT STARTS HERE ##########################
#####################################################################
#####################################################################
### What do we need then? ###
global botnick
set mainc "$botnick"
set secc "$altnick"
bind pub - $mainc commands
bind pub - $secc commands
bind pub - $command1 commands
bind pub - $command2 commands
bind pub o $groupcommand commands
bind join - * do_restrict
bind join - * do_opvoice
bind msg - identify identify.proc
bind notc - "*identify*" ident.proc
bind msg - cmd commands
bind need - "% op" op-bot
bind msg - invite unbanme

## These will be handy ##
setudef flag restrict
setudef flag needop
setudef flag voiceall
setudef flag opall
setudef flag snoop

## And here's the main proc ##
proc do_restrict {nick uhost hand chan} {
global botnick restrictkick
if {[string match "*+restrict*" [channel info $chan]] && ![matchattr $hand f|f $chan] && $nick != $botnick} {
putserv "mode $chan +b [maskhost [getchanhost $nick $chan]]"
putserv "kick $chan $nick :$restrictkick"
}}
proc do_opvoice {nick uhost hand chan} {
global botnick
if {[string match "*+voiceall*" [channel info $chan]] && ![matchattr $hand a|a $chan] && $nick != $botnick} {
putserv "mode $chan +v $nick"
} elseif {[string match "*+opall*" [channel info $chan]] && ![matchattr $hand a|a $chan] && $nick != $botnick} {
putserv "mode $chan +o $nick"
}}
proc commands {nick uhost hand chan text} {
set text [split $text]
if {[matchattr $hand S]} { writetolog "Denied command issued by frozen user $nick / *$hand*" ; return 0 }
switch [string tolower [lindex $text 0]] {
"" { if {![validuser $nick]} { writetolog "Unknown command issued by unknown user $nick" } else {
writetolog "Unknown command issued by $nick / *$hand*"
}}
"rehash" { if {[matchattr $hand n]} {rehash; putserv "privmsg $chan :Rehashing.. " ; writetolog ">> Rehash on request of: $nick / *$hand*"} }
"say" { if {[matchattr $hand o] || [matchattr $hand |o $chan]} {
if {[string range [lindex $text 1] 0 0] == "#"} { set thechan [lindex $text 1]
putserv "privmsg $thechan :[lrange $text 2 end]" ; writetolog "Said [lrange $text 2 end] in $thechan from $chan on request of $nick / *$hand*" } else {
putserv "privmsg $chan :[lrange $text 1 end]"
writetolog "Said: [lrange $text 1 end] in $chan on request of $nick / *$hand*"
}}}
"act" { if {[matchattr $hand o] || [matchattr $hand |o $chan]} { putact $chan [lrange $text 1 end]
writetolog "Acted [lrange $text 1 end] in $chan on request of $nick / *$hand*"
} }
"jump" { if {[matchattr $hand n]} {
set jump [lindex $text 1] ; putserv "privmsg $chan :Jumping to $jump"
writetolog "Jumped to $jump on request of $nick / *$hand*"
jump $jump
}}
"save" { if {[matchattr $hand n] || [matchattr $hand |n $chan] } { save
 putserv "privmsg $chan :Saved channel and user database."
writetolog ">> Saved User & Chan file on request of $nick / *$hand*" }}
"reload" { if {[matchattr $hand n] || [matchattr $hand |n $chan] } { reload }
 putserv "privmsg $chan :Reloaded." ; writetolog ">> Reloaded User & Chan file on request of $nick / *$hand*"}
"kick" { if {[matchattr $hand o|o $chan]} {
global botnick
set banie [lindex $text 1]
set reason [lrange $text 2 end]
if {$reason == ""} { set reason "No reason specified" }
if {[matchattr $banie f|f $chan]} { putserv "privmsg $chan :$banie is exempt from kicking."
writetolog "$nick attempted to kick $banie from $chan but they were exempted." ; return 0}
if {$banie == $botnick} { putserv "privmsg $chan :Nice try"
writetolog "$nick attempt to make me kick myself from $chan but I refused." ; return 0}
putserv "kick $chan $banie :$reason <Requested by: $nick>" ; writetolog "Kicked $banie from $chan on request of $nick / *$hand*"}}
"op" { if {[matchattr $hand o] || [matchattr $hand |o $chan]} { if {[string length [lindex $text 1]] > 0} {
pushmode $chan +o [lindex $text 1] ; writetolog "Opped [lindex $text 1] in $chan on request of $nick / *$hand*"
} else { pushmode $chan +o $nick  ; writetolog "Self Op used in $chan on request of $nick / *$hand*" } } }
"deop" { if {[matchattr $hand o] || [matchattr $hand |o $chan]} {
# if {$nick == $botnick} { putserv "privmsg $chan :I will not deop myself."
# 	writetolog "$nick attempted to deop me! / *$hand*"
#	return 0
# }
if {[string length [lindex $text 1]] > 0} {
pushmode $chan -o [lindex $text 1] ; writetolog "Deopped [lindex $text 1] in $chan on request of $nick / *$hand*"
} else { pushmode $chan -o $nick ; writetolog "Self Deop used in $chan on request of $nick / *$hand*" } } }
"die" { if {[matchattr $hand n]} { die
putserv "privmsg $chan :Dieing on request of $nick / *$hand* ..."
writetolog "Died on request of $nick"
die "$nick - [lrange $text 1 end]" }}
"addchan" { if {[matchattr $hand n]} { set beep [lindex $text 1]
putserv "privmsg $chan :$beep added to my channel list." ; writetolog "Added $beep to chan list on request of $nick / *$hand*" ; channel add $beep}}
"restart" { if {[matchattr $hand n]} { putserv "privmsg $chan :Restarting on request of $nick"
writetolog "Restarted on request of $nick / *$hand*" ; restart }}
"delchan" { if {[matchattr $hand n]} { set meep [lindex $text 1]
channel remove $meep ; putserv "privmsg $chan :$meep removed from my channel list." ; writetolog "Removed $meep from chan list. Requested by $nick"
}}
"clean" { if {[matchattr $hand n]} { clean putserv "privmsg $chan :Running a user clean..." ; writetolog "User Cleaning requested by $hand" }}
"ban" { global botnick ; if {[matchattr $hand o|o $chan]} { set banie [lindex $text 1] ; set reason [lrange $text 2 end]
if {$reason == ""} { set reason "No reason specified" }
if {[matchattr $banie f|f $chan]} { putserv "privmsg $chan :$banie is exempt from banning." ; return 0}
if {$banie == $botnick} { putserv "privmsg $chan :Ummm, no?" ; return 0}
if {[onchan $banie $chan]} { set host [getchanhost $banie $chan] ; putserv "mode $chan +b $host" ; putserv "kick $chan $banie :$reason <Requested by: $nick>"
writetolog "Banned $host / $banie in $chan on request of $nick"
} else { putserv "mode $chan +b $banie" ; writetolog "Banned $banie on $chan on request of $nick" } }}
"unban" {
if {[matchattr $hand n]} {
if {[string range [lindex $text 1] 0 0] == "#"} { set thechan [lindex $text 1] } else { set thechan $chan }
putserv "mode $chan -b [lindex $text 1]" ; writetolog "Unbanned [lindex $text 1] in $thechan on request of $nick"
} elseif {![matchhatr $hand n] && [matchattr $hand o|o]} {
putserv "mode $chan -b [lindex $text 1]" ; writetolog "Unbanned [lindex $text 1] in $chan on request of $nick" }}

"voice" { if {[matchattr $hand o|o $chan] || [matchattr $hand o|o $chan]} { if {[string length [lindex $text 1]] > 0} {
pushmode $chan +v [lindex $text 1] ; writetolog "Voiced [lindex $text 1] in $chan on request of $nick"
} else { pushmode $chan +v $nick ; writetolog "Voiced $nick in $chan" } } }
"devoice" { if {[matchattr $hand o|o $chan] || [matchattr $hand o|o $chan]} { if {[string length [lindex $text 1]] > 0} {
pushmode $chan -v [lindex $text 1] } else { pushmode $chan -v $nick } } }
"trout" { if {[matchattr $hand v|v $chan] || [matchattr $hand o|o $chan]} { putact $chan "slaps [lindex $text 1] around a bit with a large trout"
writetolog "Trouted [lindex $text 1] in $chan on request of $nick"}}
"chanmode" { if {[matchattr $hand o|o $chan]} { putserv "mode $chan [lindex $text 1]"
writetolog "Channel modes for $chan changed to [lindex $text 1] on request of $nick / *$hand*" } }
"raw" { if {[matchattr $hand n]} { putserv "[lrange $text 1 end]" ; writetolog "raw [lrange $text 1 end] performed by $nick / *$hand*"}}
"delhost" { if {[matchattr $hand n]} {
delhost [lindex $text 1] [lrange $text 2 end] ; putserv "privmsg $chan :Removed host [lrange $text 2 end] from [lindex $text 1]"
writetolog "Deleted ([lrange $text 2 end]) from handle [lindex $text 1] on request of $nick / *$hand*" }}
"adduser" { global botnick ; if {[matchattr $hand n] && ![validuser [lindex $text 1]]} {
if {[onchan [lindex $text 1] $chan]} {
set meep [lindex $text 1]
set ahost [maskhost [getchanhost $meep $chan]]
adduser $meep $ahost ; putserv "privmsg $chan :Added $meep to channel list ($ahost)"
putserv "notice $meep :You have been added to my user base by $nick. Please set a password and remember it for further use."
putserv "notice $meep :/msg $botnick pass <password>"
writetolog "Added $meep ($host) On request of $hand"
} else {
set meep [lindex $text 1]
set ahost [lindex $text 2]
adduser $meep $ahost
putserv "privmsg $chan :Added $meep ($ahost)" ; writetolog "Added user $meep ($ahost) by $nick"
writetolog "Added $meep ($ahost) on request of $hand"
} } }
"chattr" {
if {[matchattr $hand n]} {
set channel "[lindex $text 3]"
set domodes "[lindex $text 2]"
if {![validuser [lindex $text 1]]} { putserv "privmsg $chan :[lindex $text 1] is not a valid user" ;return 0 }
if {$channel != ""} { set domodes "|$domodes" ;set modesdone [chattr [lindex $text 1] $domodes $channel] } else { set modesdone [chattr [lindex $text 1] $domodes] }
 if {$channel == "" && $modesdone != "-"} { putserv "privmsg $chan :global user flags for [lindex $text 1] are now $modesdone"
} elseif {$channel != "" && [lindex [split $modesdone "|"] 1] == "-"} { putserv "privmsg $chan :[lindex $text 1] no longer has any channel user flags on $channel"
} elseif {$channel != "" && $modesdone != "-"} { set modesdone [lindex [split $modesdone "|"] 1] ;putserv "privmsg $chan :channel user flags for [lindex $text 1] on $channel are now $modesdone"
} elseif {$channel == "" && $modesdone == "-"} { putserv "privmsg $chan :[lindex $text 1] no longer has any global user flags"
}
}
}
"credits" {
putserv "privmsg $chan :\002*** juco.tcl credits\002"
putserv "privmsg $chan :jucotcl-v1.6 created by Hoze"
putserv "privmsg $chan :Big thanx to X-Poz and MiG TCL"
writetolog "Credits requested by $nick"
}
"access" {
global root botnick
if {[lindex $text 1] == ""} {
set host [getchanhost $nick $chan]
writetolog "Personal access level requested by $nick / *$hand* ($host) in $chan"
if {$hand == $root} { putserv "privmsg $chan :Access for $nick ($host) is \002Root Administrator\002" ; return 0 }
if {[matchattr $hand B]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Sister Bot\002" ;return 0 }
if {[matchattr $hand n]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Global Owner\002" ;return 0 }
if {[matchattr $hand m]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Global Master\002" ;return 0}
if {[matchattr $hand o]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Global AOp\002" ;return 0 }
if {[matchattr $hand v]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Global Voice\002" ; return 0 }
if {[matchattr $hand |n $chan]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Channel Founder\002 on $chan" ;return 0 }
if {[matchattr $hand |m $chan]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Master\002 on $chan" ;return 0}
if {[matchattr $hand |o $chan]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* AOp\002 on $chan" ;return 0 }
if {[matchattr $hand |v $chan]} { putserv "privmsg $chan :Access for $nick ($host) is \002*$hand* Auto Voice\002 on $chan" ;  } else {
putserv "privmsg $chan :Access for $nick ($host) is \002Basic\002"
putserv "notice $nick :To identify use: /msg $botnick identify <handle> <password>" }
} else {
set name [lindex $text 1]
set moo [finduser "*![getchanhost $name $chan]"]
set ahost [getchanhost $name $chan]
set meep [nick2hand $name]
writetolog "Access for $name / $meep ($ahost) requested in $chan by $nick"
if {![onchan [lindex $text 1]]} { putserv "privmsg $chan :[lindex $text 1] is not currently on the channel." ; return 0 }
if {$meep == $root} { putserv "privmsg $chan :Access for $name ($ahost) is \002Root Administrator\002" ; return 0 }
if {[matchattr $meep S]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Frozen\002" ; return 0 }
if {[matchattr $meep B]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Sister Bot\002" ;return 0 }
if {[matchattr $meep n]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Global Owner\002" ;return 0 }
if {[matchattr $meep m]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Global Master\002" ;return 0}
if {[matchattr $meep o]} {  putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Global AOp\002" ; return 0}
if {[matchattr $meep v]} {  putserv "privmsg $chan :Access for $name ($ahost) is \002* $moo * Global Voice\002" ; return 0 }
if {[matchattr $meep |n $chan]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Channel Founder\002 on $chan" ;return 0 }
if {[matchattr $meep |m $chan]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Master\002 on $chan" ;return 0}
if {[matchattr $meep |o $chan]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* AOp\002 on $chan" ;return 0 }
if {[matchattr $meep |v $chan]} { putserv "privmsg $chan :Access for $name ($ahost) is \002*$moo* Auto Voice\002 on $chan" ; return 0  }
if {[validuser $meep] && [matchattr $meep -|- $chan]} { putserv "privmsg $chan :$name ($ahost) is a known user with no flags in this channel" ; return 0 } else {
putserv "privmsg $chan :Access for $name ($ahost) is \002Basic\002" ; return 0 }
#putserv "notice $name :To identify use: /msg $botnick identify <handle> <password>"
}
}
"chaninfo" { if {[matchattr $hand n|n $chan]} {
set cinfo "[channel info $chan]" ;putserv "notice $nick :chanmode: [lindex $cinfo 0]" ;putserv "notice $nick :idle-kick: [lindex $cinfo 1]" ;putserv "notice $nick :stopnethack: [lindex $cinfo 2]" ;putserv "notice $nick :revenge-mode: [lindex $cinfo 3]" ;putserv "notice $nick :need-op: [lindex $cinfo 4]" ;putserv "notice $nick :need-invite: [lindex $cinfo 5]" ;putserv "notice $nick :need-key: [lindex $cinfo 6]" ;putserv "notice $nick :need-unban: [lindex $cinfo 7]" ;putserv "notice $nick :need-limit: [lindex $cinfo 8]" ;putserv "notice $nick :flood-chan: [lindex $cinfo 9] flood-ctcp: [lindex $cinfo 10] flood-join: [lindex $cinfo 11] flood-kick: [lindex $cinfo 12] flood-deop: [lindex $cinfo 13] flood-nick: [lindex $cinfo 14]" ;putserv "notice $nick :aop-delay: [lindex $cinfo 15] ban-time: [lindex $cinfo 16] exempt-time: [lindex $cinfo 17] invite-time: [lindex $cinfo 18]" ;putserv "notice $nick :Flags: [lrange $cinfo 19 end]"
writetolog "Channel info for $chan requested by $nick" }}
"chansuspend" { if {[matchattr $hand n]} { if {[string range [lindex $text 1] 0 0] == "#"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :Specify a reason for suspending that channel" ; return 0}
set dchan "[lindex $text 1]" } else { set dchan "$chan" }
if {[string match "*+inactive*" [channel info $dchan]]} { putserv "privmsg $chan :$dchan is already suspended" ;return 0
}
putquick "part $dchan :channel management suspended by administration"
channel set $dchan +inactive ;putserv "privmsg $chan :$dchan has been suspended"
writetolog "Channel $dchan Suspended - Reason: [lrange $text 2 end] - on request of $nick / *$hand*"
}}
"chanunsuspend" { if {[matchattr $hand n]} {
set dchan [lindex $text 1]
channel set $dchan -inactive ;putserv "privmsg $chan :$dchan has been unsuspended" ; writetolog "Channel $dchan is no longer suspended suspended on request of $hand" }}

#Notes System, buggy as.  Needs a fix :)
"note" {
set action [string tolower [lindex $text 1]]
if {$action == ""} { putserv "privmsg $chan :Syntax: note send <handle> <message>" } elseif {$action == "send"} {
set to [lindex $text 2]
sendnote $nick $to [lrange $text 3 end]
putserv "privmsg $chan :Note sent to $to"
} elseif {$action == "list"} {
listnotes $nick 1-10
} elseif {$action == "read"} {
notes $nick [lindex $text 2]
}}
"addban" { if {[matchattr $hand n]} {
set theban [lindex $text 1]
set time [lindex $text 2]
set option [lindex $text 3]
set reason [lrange $text 4 end]
if {$time == "-"} { set timeh "perm" }
if {$option == "sticky"} {
putserv "privmsg $chan :Global ban set for $theban time: $timeh options: $option Reason: $reason"
newban $theban $nick $reason $time $option ; writetolog "Placed Global ban on $theban by $nick for $timeh options: $option reason: $reason"
} else {
putserv "privmsg $chan :Global ban set for $theban time: $timeh Reason: $reason"
newban $theban $nick $reason $time ; writetolog "Placed Global ban on $theban by $nick for $timeh Reason: $reason" }
}}
"flushlog" { if {[matchattr $hand n]} {
global log
file delete $log ; putserv "privmsg $chan :Command log flushed."
writetolog "Commands log file flushed by $nick / *$hand*"}}
"addignore" { if {[matchattr $hand n]} {
set who [lindex $text 1]
set time [lindex $text 2]
set reason [lrange $text 3 end]
if {$time == "-"} { putserv "privmsg $chan :Ignore added for $who time: perm reason: $reason" ; newignore $who $nick $reason $time ; writetolog "Added ignore for $who time: $time reason: $reason request of: $nick" } else {
putserv "privmsg $chan :Ignore added for $who time: $time reason: $reason"
newignore $who $nick $reason $time ; writetolog "Added ignore for $who time: $time reason: $reason request of: $nick"
}}}
"delignore" { if {[matchattr $hand n]} {
set who [lindex $text 1]
putserv "privmsg $chan :Removed ignore on $who" ; killignore $who ; writetolog "Removed ignore for $who request of $nick" }}
"delban" { if {[matchattr $hand n]} {
set kban [lindex $text 1]
putserv "privmsg $chan :Removed global ban on $kban"
killban $kban ; putlog "removed ban on $kban by $nick" ; writetolog "Removed global ban for $kban by $nick" }}
#newban $banh $nick $reasonh $timeh $option
"stick" { if {[matchattr $hand n] && [lindex $text 2] == ""} { putserv "privmsg $chan :Stuck ban on $chan" } elseif {[matchattr $hand n] && [lindex $text 2] != ""} { putserv "privmsg $chan :Stuck ban on [lindex $text 2]" } elseif { [matchattr $hand n $chan] && [lindex $text 2] == ""} { putserv "privmsg $chan :Stuck ban on $chan" } elseif {[matchattr $hand n $chan] && [lindex $text 2] != ""} { putserv "privmsg $chan :Stuck ban on [lindex $text 2]" }}
"sendlog" { if {[matchattr $hand n]} {
global botnick path log
putserv "privmsg $chan :Sending Log to $nick..."
writetolog "Sent command log to $nick"
set x [dccsend "$path/$log" $nick]
}}

"help" {
global botnick command1 command2 groupcommand
set action [string tolower [lindex $text 1]]
if {$action == ""} {
putserv "notice $nick :\002*** Help Menu ***\002"
putserv "notice $nick :All Access levels are listed below. You may only view help on your access level and lower"
putserv "notice $nick :To issue a command use: $command1 <command>"
putserv "notice $nick :\002$command1 help basic\002 - Help for basic level. (Everyone)"
putserv "notice $nick :\002$command1 help avoice\002 - Help for Auto-Voice level"
putserv "notice $nick :\002$command1 help aop\002 - Help for Auto-Op level"
putserv "notice $nick :\002$command1 help master\002 - Help for Master level"
putserv "notice $nick :\002$command1 help founder\002 - Help for Founder level"
putserv "notice $nick :\002$command1 help gowner\002 - Help for Global Owner level"
putserv "notice $nick :For a more extensive explanation to commands see:"
putserv "notice $nick :http://bots4u.juco.co.uk"
putserv "notice $nick :\002*** End of Help ***\002"
writetolog "Help Menu requested by $nick on $chan"
} elseif {$action == "gowner"} {
if {![matchattr $hand n]} { putserv "notice $nick :You do not have access to this level." } else {
putserv "notice $nick :\002*** Global Owner:\002"
putserv "notice $nick :\002restart\002 -> Will restart the bot"
putserv "notice $nick :\002die\002 -> Will cause the bot to die"
putserv "notice $nick :\002freeze <handle> <reason>\002 -> Will freeze that users access"
putserv "notice $nick :\002unfreeze <handle>\002 -> Will unfreeze that users access"
putserv "notice $nick :\002frozen list\002 -> Will list all the frozen users"
putserv "notice $nick :\002adduser <nickname> <host(optional)>\002 -> Add that user to the bot"
putserv "notice $nick :\002deluser <handle>\002 -> Delete that user from the bot"
putserv "notice $nick :\002addignore <IP/host> <time> <reason>\002 -> Adds that user to the ignore list"
putserv "notice $nick :\002delignore <IP/host>\002 -> Remove the ignore set on that user"
putserv "notice $nick :\002addhost <handle> <host>\002 -> Add that hostname to that user"
putserv "notice $nick :\002delhost <handle> <host>\002 -> Delete that hostname from that user"
putserv "notice $nick :\002wipehosts <handle>\002 -> Wipe all hosts for that user"
putserv "notice $nick :\002addban <host> <time> <option> <reason>\002 -> Add that hostname to the Global Ban list"
putserv "notice $nick :\002delban <host>\002 -> Delete that ban from the list"
putserv "notice $nick :\002banslist\002 -> Will list all global bans"
putserv "notice $nick :\002rehash\002 -> Will rehash the bots config file"
putserv "notice $nick :\002aset <user> <setting> <option>\002 -> Change a users settings"
putserv "notice $nick :\002flushlog\002 -> Delete the bots command log file"
putserv "notice $nick :\002sendlog\002 -> Will DCC send bot command log file"
putserv "notice $nick :\002chansuspend <channel> <reason>\002 -> Suspend that channel and retain users/settings"
putserv "notice $nick :\002chanunsuspend <channel>\002 -> Unsuspend that channel"
putserv "notice $nick :\002save\002 -> Save the user and channel file"
putserv "notice $nick :\002reload\002 -> Reload the user and channel file"
putserv "notice $nick :\002sbot add/del <nickname>\002 -> Adds and removes a Sister Bot"
putserv "notice $nick :\002sbot list\002 -> list all Sister Bots"
putserv "notice $nick :\002founder add/del <nickname> -> Add and removes a channel founder"
putserv "notice $nick :\002founder list\002 -> List the channels founder(s)"
putserv "notice $nick :\002userlist <chan>\002 -> Will list all users for that channel"
putserv "notice $nick :\002chanlist\002 -> Will list the channel in which the bot is on"
putserv "notice $nick :\002clean\002 - UserClean all users that the bot has not seen within 20 days"
putserv "notice $nick :\002*** End of Help***\002"
writetolog "Global Owner help requested by $nick on $chan"
}} elseif {$action == "founder"} {
if {![matchattr $hand n|n $chan]} { putserv "notice $nick :You do not have access to this level." } else {
putserv "notice $nick :\002*** Founder Help ***\002"
putserv "notice $nick :\002chaninfo\002 -> Will display the channel settings for the current channel"
putserv "notice $nick :\002chanset <settings>\002 -> Change channel settings, possibilities found with chaninfo"
putserv "notice $nick :\002master add/del <nickname>\002 -> Add or remove a channel master"
putserv "notice $nick :\002master list\002 -> Will list all channel masters"
putserv "notice $nick :\002restrict\002 -> Will restrict the channel so only users with access may join"
putserv "notice $nick :\002unrestrict\002 -> Will remove the restriction on the channel"
putserv "notice $nick :\002*** End of Help***\002"
writetolog "Founder help requested by $nick on $chan"
}} elseif {$action == "master"} {
if {![matchattr $hand m|m $chan]} { putserv "notice $nick :You do not have access to this level." } else {
putserv "notice $nick :\002*** Master Help:\002"
putserv "notice $nick :\002cycle\002 -> Will cycle the current channel"
putserv "notice $nick :\002aop add/del <nickname>\002 -> Will add or delete a channel Aop"
putserv "notice $nick :\002aop list\002 -> Will list all channel Aop's"
putserv "notice $nick :\002akick add <hostname> <time> <reason>\002 -> Add an akick on that channel"
putserv "notice $nick :\002akick del <hostname>\002 -> Remove an akick on that channel"
putserv "notice $nick :\002akick list\002 -> Will list all akicks for that channel"
putserv "notice $nick :\002*** End of Help***\002"
writetolog "Master help requested by $nick on $chan"
}} elseif {$action == "aop"} {
if {![matchattr $hand o|o $chan]} { putserv "notice $nick :You do not have access to this level." } else {
putserv "notice $nick :\002*** Auto-Op Help:\002"
putserv "notice $nick :\002say <message>\002 -> Will have me say that message to the channel"
putserv "notice $nick :\002act <message>\002 -> Will have me act that message to the channel"
putserv "notice $nick :\002kick <nickname> <reason>\002 -> Will kick that user from the channel"
putserv "notice $nick :\002ban <nickname> <reason>\002 -> Will ban that user from the channel"
putserv "notice $nick :\002handle <nickname>\002 -> Will display that users handle on the bot"
putserv "notice $nick :\002op <nickname(optional)\002 -> Ops you or if specified, that user"
putserv "notice $nick :\002deop <nickname(optional)>\002 -> Deops you or if specified, that user"
putserv "notice $nick :\002voice <nickname(optional)>\002 -> Voice you or if specified, that user"
putserv "notice $nick :\002devoice <nickname(optional)>\002 -> Devoice you or if specified, that user"
putserv "notice $nick :\002chanmode <+/-modes>\002 -> Change the channel modes"
putserv "notice $nick :\002avoice add/del <nickname>\002 -> Adds that nickname to the Auto-Voice list"
putserv "notice $nick :\002avoice list\002 -> Lists all Auto-Voices in that channel"
putserv "notice $nick :\002whois <nickname>\002 -> Displays all information regarding that user"
putserv "notice $nick :\002/msg $botnick INVITE <channel>\002 -> Invite you to a channel if banned"
putserv "notice $nick :\002*** End of Help***\002"
writetolog "Aop help requested by $nick on $chan"
}} elseif {$action == "avoice"} {
if {![matchattr $hand v|v $chan] && ![matchattr $hand o|o $chan]} {
putserv "notice $nick :You do not have access to this level." } else {
putserv "notice $nick :\002*** Auto-voice Help:\002"
putserv "notice $nick :\002voiceme\002 -> Will voice you in the channel"
putserv "notice $nick :\002devoiceme\002 -> Will devoice you in the channel"
putserv "notice $nick :\002trout <nickname>\002 -> Will slap that user with a trout"
putserv "notice $nick :\002set <option> <setting>\002 -> Will set that setting to your nickname. For help with set see \002help set\002"
putserv "notice $nick :\002*** End of Help***\002"
writetolog "Auto-Voice help requested by $nick on $chan"
}} elseif {$action == "basic"} {
putserv "notice $nick :\002Basic Help:\002"
putserv "notice $nick :\002version\002 -> Will display the bot version"
putserv "notice $nick :\002credits\002 -> Will display the bot credits"
putserv "notice $nick :\002status\002 -> Will display the current bot status"
putserv "notice $nick :\002uptime\002 -> Will display the bot and system uptime"
putserv "notice $nick :\002access\002 <nickname(optional)> -> Will display your or specified that users access"
putserv "notice $nick :\002*** End of Help ***\002"
writetolog "Basic help requested by $nick on $chan"
} elseif {$action == "set"} {
putserv "notice $nick :\002Set Help:\002"
putserv "notice $nick :Use the set command with: $command1 set <setting> <option> The possible options are:"
putserv "notice $nick :\002email\002 -> Your email address"
putserv "notice $nick :\002url\002 -> Your website"
putserv "notice $nick :\002dob\002 -> Your date of birth"
putserv "notice $nick :\002bf\002 -> Your boyfriend"
putserv "notice $nick :\002gf\002 -> Your girlfriend"
putserv "notice $nick :\002info\002 -> Your channel info"
putserv "notice $nick :\002ginfo\002 -> Your global info"
putserv "notice $nick :\002*** End of Help ***\002"
writetolog "Set help requested by $nick on $chan"
}
}

"chanlist" { if {[matchattr $hand n]} {
putserv "notice $nick :\002*** Channel list ***\002"
foreach chan [channels] { if {[string match "*+inactive*" [channel info $chan]]} { putserv "notice $nick :*** $chan \002Suspended\002" } else {
putserv "notice $nick :*** $chan" }}
putserv "notice $nick :\002*** End of list ***\002"
writetolog "Channel list requested by $nick"
}}
"globalmsg" { if {[matchattr $hand n]} {
set msg [lrange [cleanarg $text] 1 end]
  foreach channel [channels] {
   putserv "privmsg $channel :\002***GLOBAL MESSAGE***\002: $msg \(from $nick\)."
  }
  writetolog "Global message issued by $nick / *$hand*"
}}
"suspendlist" {
if {[matchattr $hand n]} {
set cinfo "[channel info $chan]"
putserv "privmsg $chan :$cinfo"
}}
"voiceme" { if {[matchattr $hand v|v $chan] || [matchattr $hand o|o $chan]} { pushmode $chan +v $nick ; writetolog "Voiceme used in $chan by $nick"}}
"devoiceme" { if {[matchattr $hand v|v $chan] || [matchattr $hand o|o $chan]} { pushmode $chan -v $nick ; writetolog "Devoiceme used in $chan by $nick"}}
"cycle" { if {[matchattr $hand m|m $chan]} {
if {[string range [lindex $text 1] 0 0] == "#"} { set thechan [lindex $text 1] } else { set thechan $chan }
putserv "part $thechan :Cycling on request of $nick" ; writetolog "Cycled $thechan on request of $nick / *$hand*"}}
"deluser" {
if {[matchattr $hand n]} {
set user [lindex $text 1]
if {![validuser $user]} {
putserv "privmsg $chan :$user is not a valid user."
} else {
deluser $user
putserv "privmsg $chan :Deleted $user from database." ; writetolog "Deleted $user from database by $nick / *$hand*"
} } }
"addhost" { if {[matchattr $hand n]} {
set person [lindex $text 1]
set tehost [lrange $text 2 end]
if {![validuser $person]} {
putserv "privmsg $chan :$person is not a valid user."
} else { putserv "privmsg $chan :Added host ($tehost) to $person"
setuser $person HOSTS $tehost ; writetolog "Added host ($tehost) to handle $person on request of $nick / *$hand*"
} } }
"version" {
putserv "privmsg $chan :Current tcl version: jucotcl-v1.6.tcl" ;
writetolog "Version request received by $nick"
}
"status" {
global root botnick uptime command1 command2 groupcommand dump
set rootemail [getuser $root XTRA email]
putserv "notice $nick :\002Status for $botnick\002"
putserv "notice $nick :My root Administrator: $root - $rootemail"
putserv "notice $nick :Bot commands: $command1, $command2, $groupcommand, $botnick"
putserv "notice $nick :My uptime: [duration [expr [unixtime] - $uptime]]"
if {![catch {set shell [exec uptime]}]} {
putserv "notice $nick :System Uptime: [lindex $shell 2] [lindex $shell 3]\
[string trimright [lindex $shell 4] ","]"
if {$dump == 1} { putserv "notice $nick :Log Dumping and file writting is active" } else {
putserv "notice $nick :Logs are written to a file only" }
writetolog "Status command used by $nick / *$hand*"
}}
"uptime" {
global uptime
putserv "privmsg $chan :My current uptime is: [duration [expr [unixtime] - $uptime]]"
if {![catch {set shell [exec uptime]}]} {
putserv "privmsg $chan :System Uptime: [lindex $shell 2] [lindex $shell 3]\
[string trimright [lindex $shell 4] ","]"
writetolog "Uptime requested by $nick / *$hand*"
}}
"wipehosts" {
if {[matchattr $hand n]} {
set momoo [lindex $text 1]
foreach host [getuser $momoo hosts] {
	delhost $momoo $host
}
putserv "privmsg $chan :All hosts removed for $momoo."
writetolog "All hosts removed for handle $momoo on request of $nick / *$hand*"
}}
"whois" { if {[matchattr $hand o|o $chan]} {
global root
set bah [lindex $text 1]
set meep [nick2hand $bah]
if {![onchan $bah $chan] && ![validuser $bah]} {
putserv "privmsg $chan :$bah is not a valid handle and are not on the channel" ; writetolog "Whois attempted on $bah on $chan, but that is not a known handle. - Request by: $nick / *$hand*"
} elseif {![onchan $bah $chan] && [validuser $bah]} {
writetolog "Whois requested for *$bah* who is not currently on any channels I monitor, so resolved by handle - Requested by: $nick / *$hand*"
putserv "notice $nick :*** Whois for $bah:"
putserv "notice $nick :*** Handle: $bah"
if {$bah == $root} { putserv "notice $nick :***\002 $bah is my Root Administrator" }
if {[matchattr $bah S]} { putserv "notice $nick :*** \002$bah is Frozen\002" }
if {[matchattr $bah n]} { putserv "notice $nick :*** \002$bah is a Global Owner" }
if {[matchattr $bah B]} { putserv "notice $nick :*** \002$bah is a Sister Bot" }
if {[matchattr $bah m] && ![matchattr $bah n]} { putserv "notice $nick :*** \002 $bah is a Global Master" }
if {[matchattr $bah o] && ![matchattr $bah m] && ![matchattr $bah B] && ![matchattr $bah S]} { putserv "notice $nick :***\002 $bah is a Global Aop" }
putserv "notice $nick :*** Hosts: [getuser $bah hosts]"
putserv "notice $nick :*** Global flags: [chattr [nick2hand $bah]]"
set chanflags [split [chattr $bah $chan] |]
putserv "notice $nick :*** Channel flags: $chanflags"
if {[getuser $bah info] == ""} {
putserv "notice $nick :*** Global info: <empty>"
} else {
putserv "notice $nick :*** Global info: [getuser $bah info]" }
if {[getchaninfo $bah $chan] == ""} {
putserv "notice $nick :*** Channel info: <empty>"
} else {
 putserv "notice $nick :*** Channel info: [getchaninfo $bah $chan]" }
if {[getuser $bah XTRA url] != ""} {
putserv "notice $nick :*** URL: [getuser $bah XTRA url]" }
if {[getuser $bah XTRA email] != ""} {
putserv "notice $nick :*** Email: [getuser $bah XTRA email]" }
if {[getuser $bah XTRA dob] != ""} {
putserv "notice $nick :*** D.O.B: [getuser $bah XTRA dob]" }
if {[getuser $bah XTRA gf] != ""} {
putserv "notice $nick :*** Girl Friend: [getuser $bah XTRA gf]" }
if {[getuser $bah XTRA bf] != ""} {
putserv "notice $nick :*** Boy Friend: [getuser $bah XTRA bf]" }
if {[getuser $bah LASTON] != ""} { set laston "[getuser $bah LASTON]"; putserv "notice $nick :last on: [ctime [lindex $laston 0]] on [lrange $laston 1 end]" }
putserv "notice $nick :*** End of Whois"
set meep [nick2hand $bah]
} elseif {[onchan $bah $chan] && $meep == "*"} { putserv "privmsg $chan :$bah is an unknown user." ; writetolog "Whois request for $bah on $chan but they have no access or are not identified. - Requested by: $nick / *$hand*"
} elseif {[onchan $bah $chan] && [validuser $meep]} {
putserv "notice $nick :*** Whois for $bah"
putserv "notice $nick :*** Handle: [nick2hand $bah]"
if {$bah == $root || $meep == $root} { putserv "notice $nick :***\002 $bah is my Root Administrator" }
if {[matchattr $meep S]} { putserv "notice $nick :***\002 $bah is Frozen\002" }
if {[matchattr $meep n]} { putserv "notice $nick :***\002 $bah is a Global Owner" }
if {[matchattr $meep B]} { putserv "notice $nick :*** \002$bah is a Sister Bot" }
if {[matchattr $meep m] && ![matchattr $meep n]} { putserv "notice $nick :***\002 $bah is a Global Master" }
if {[matchattr $meep o] && ![matchattr $meep m] && ![matchattr $meep B] && ![matchattr $meep S]} { putserv "notice $nick :***\002 $bah is a Global Aop" }
putserv "notice $nick :*** Hosts: [getuser [nick2hand $bah] hosts]"
putserv "notice $nick :*** Global flags: [chattr [nick2hand $meep]]"
set chanflags [split [chattr [nick2hand $bah] $chan] |]
putserv "notice $nick :*** Channel flags: $chanflags"
if {[getuser [nick2hand $bah] info] == ""} {
putserv "notice $nick :*** Global info: <empty>"
} else {
putserv "notice $nick :*** Global info: [getuser [nick2hand $bah] info]" }
if {[getchaninfo [nick2hand $bah] $chan] == ""} {
putserv "notice $nick :*** Channel info: <empty>"
} else {
 putserv "notice $nick :*** Channel info: [getchaninfo [nick2hand $bah] $chan]" }
if {[getuser [nick2hand $bah] XTRA url] != ""} {
putserv "notice $nick :*** URL: [getuser [nick2hand $bah] XTRA url]" }
if {[getuser [nick2hand $bah] XTRA email] != ""} {
putserv "notice $nick :*** Email: [getuser [nick2hand $bah] XTRA email]" }
if {[getuser [nick2hand $bah] XTRA dob] != ""} {
putserv "notice $nick :*** D.O.B: [getuser [nick2hand $bah] XTRA dob]" }
if {[getuser [nick2hand $bah] XTRA gf] != ""} {
putserv "notice $nick :*** Girl Friend: [getuser [nick2hand $bah] XTRA gf]" }
if {[getuser [nick2hand $bah] XTRA bf] != ""} {
putserv "notice $nick :*** Boy Friend: [getuser [nick2hand $bah] XTRA bf]" }
if {[getuser [nick2hand $bah] LASTON] != ""} { set laston "[getuser [nick2hand $bah] LASTON]"; putserv "notice $nick :last on: [ctime [lindex $laston 0]] on [lrange $laston 1 end]" }
putserv "notice $nick :*** End of Whois"
writetolog "Whois request for $bah / *[nick2hand $bah]* on $chan. Requested by $nick / *$hand*"
}
}
}
"chanset" { if {[matchattr $hand n|n $chan]} {
if {[llength $text] > "2"} {
writetolog "Channel settings for $chan changed to: [lindex $text 1] [lrange $text 2 end] by $nick / *$hand*"
channel set $chan [lindex $text 1] [lrange $text 2 end] ; putserv "privmsg $chan :Channel settings changed to [lindex $text 1] [lrange $text 2 end]"
} else {
writetolog "Channel settings for $chan changed to: [lindex $text 1] on request of $nick / *$hand*"
channel set $chan [lindex $text 1] ;putserv "privmsg $chan :Channel settings changed to [lindex $text 1]"

}
}
}
"restrict" { if {[matchattr $hand n|n $chan]} {
putserv "privmsg $chan :Channel now restricted" ; channel set $chan +restrict ; writetolog "Restricted $chan by $nick"}}
"unrestrict" { if {[matchattr $hand n|n $chan]} {
putserv "privmsg $chan :Channel now unrestricted" ; channel set $chan -restrict ; writetolog "Unrestricted $chan by $nick"}}
"identify" { if {[matchattr $hand n]} {
global nsnick nspass botnick
putserv "privmsg $nsnick :identify $nspass" ; putlog "identify request to $nsnick request by $nick"
writetolog "Identification request sent to $nsnick for $botnick" }}
"set" { if {[matchattr $hand v|v $chan] || [matchattr $hand o|o $chan]} {
writetolog "$nick changed their personal user settings"
if {[lindex $text 1] == ""} {
putserv "privmsg $chan :You must specify something to set."
} elseif {[lindex $text 1] != ""} {
set setit [string tolower [lindex $text 1]]
if {$setit == "ginfo"} { if {[lindex $text 2] == ""} { set say "<empty>" ; set info ""} else { set info [lrange $text 2 end] ; set say [lrange $text 2 end]}
putserv "privmsg $chan :Global info line set to: $say" ; setuser $hand INFO $info }
if {$setit == "info"} { if {[lindex $text 2] == ""} { set say "<empty>" ; set info ""} else { set info [lrange $text 2 end] ; set say [lrange $text 2 end]}
putserv "privmsg $chan :Channel info line set to: $say" ; setchaninfo $hand $chan $info }
if {$setit == "email"} { putserv "privmsg $chan :Email Address set to: [lindex $text 2]" ; setuser $hand XTRA email [lindex $text 2] }
if {$setit == "url"} { putserv "privmsg $chan :URL set to: [lindex $text 2]" ; setuser $hand XTRA url [lindex $text 2]}
if {$setit == "gf"} { putserv "privmsg $chan :Girl Friend set to: [lindex $text 2]" ; setuser $hand XTRA gf [lindex $text 2]}
if {$setit == "bf"} { putserv "privmsg $chan :Boy Friend set to: [lindex $text 2]" ; setuser $hand XTRA bf [lindex $text 2]}
if {$setit == "dob"} { putserv "privmsg $chan :D.O.B set to: [lindex $text 2]" ; setuser $hand XTRA dob [lindex $text 2]}
if {$setit == "aop" } { if {[matchattr $hand o|o $chan]} {
set moo [lindex $text 2]
set poo [nick2hand $nick]
if {$moo == "on"} { chattr $poo +a ; putserv "privmsg $chan :Auto-Op setting for $nick set to ON" } elseif {$moo == "off"} { chattr $poo -a ; putserv "privmsg $chan :Auto-Op setting for $nick set to OFF" }
}}
}}}
"aset" { if {[matchattr $hand n]} {
if {[lindex $text 1] == ""} {
putserv "privmsg $chan :You must specify something to set."
} elseif {[lindex $text 1] != ""} {
set setit [string tolower [lindex $text 1]]
set person [lindex $text 2]
if {![validuser $person]} { putserv "privmsg $chan :$person is not a known handle" ; return 0 }
writetolog "Aset used in order to change personal settings for $person on request of $nick"
if {$setit == "ginfo"} { if {[lindex $text 3] == ""} { set say "<empty>" ; set info ""} else { set info [lrange $text 3 end] ; set say [lrange $text 3 end]}
putserv "privmsg $chan :Global info line for $person set to: $say" ; setuser $person INFO $info }
if {$setit == "info"} { if {[lindex $text 3] == ""} { set say "<empty>" ; set info ""} else { set info [lrange $text 3 end] ; set say [lrange $text 3 end]}
putserv "privmsg $chan :Channel info for $person set to: $say" ; setchaninfo $person $chan $info }
if {$setit == "email"} { putserv "privmsg $chan :Email Address for $person set to: [lindex $text 3]" ; setuser $person XTRA email [lindex $text 3]}
if {$setit == "url"} { putserv "privmsg $chan :URL for $person set to: [lindex $text 3]" ; setuser $person XTRA url [lindex $text 3]}
if {$setit == "gf"} { putserv "privmsg $chan :Girl Friend for $person set to: [lindex $text 3]" ; setuser $person XTRA gf [lindex $text 3]}
if {$setit == "bf"} { putserv "privmsg $chan :Boy Friend for $person set to: [lindex $text 3]" ; setuser $person XTRA bf [lindex $text 3]}
if {$setit == "dob"} { putserv "privmsg $chan :D.O.B for $person set to: [lindex $text 3]" ; setuser $person XTRA dob [lindex $text 3]}
}}}
"banslist" {
if {[matchattr $hand n]} {
putserv "notice $nick :\002Global Bans list:\002"
foreach ban [banlist] {
set banexpiretime "[ctime [lindex $ban 2]]"
if {[lindex $ban 2] == "0"} { set banexpiretime "\002Never\002" }
putserv "notice $nick :Banmask: [lindex $ban 0] Reason: [lindex $ban 1] Expires: $banexpiretime Banned by: [lindex $ban 5]" }
}}

"handle" { if {[matchattr $hand o|o $chan]} {
set poo [lindex $text 1]
set moo [nick2hand [lindex $text 1]]
if {![onchan $poo $chan]} { putserv "privmsg $chan :$poo is not on the channel."
} else { if {![validuser $moo]} { putserv "privmsg $chan :$poo is not a known user." ; return 0 }
putserv "privmsg $chan :Handle for $poo is: [nick2hand $poo]"
} } }
"freeze" { if {[matchattr $hand n]} {
global root
if {[lindex $text 2] == ""} { putserv "privmsg $chan :Specify a reason for freezing" ; return 0}
set meep [lindex $text 1]
if {$meep != $root} {
if {![validuser $meep]} { putserv "privmsg $chan :$meep is not a valid handle." } else {
setuser $meep XTRA AUTH "DEAD" ; putserv "privmsg $chan :Frozen access for $meep" ; chattr $meep +S ; chattr $meep -nmoaptjlx
writetolog "Frozen access for $meep - Reason: [lrange $text 2 end] - by $nick"
}}}}
"unfreeze" { if {[matchattr $hand n]} {
set meep [lindex $text 1]
if {![validuser $meep]} { putserv "privmsg $chan $meep is not a valid handle." } else {
setuser $meep XTRA AUTH 0 ; putserv "privmsg $chan :Unfrozen access for $meep" ; chattr $meep -S+f
writetolog "unfrozen access for $meep by $nick"
} } }
"getpass" { putserv "notice $nick :Password : [getuser [lindex $text 1] PASS]" ; writetolog "getpass used by $nick"}
"topic" { if {[matchattr $hand o|o $chan]} { putserv "topic $chan :[lrange $text 1 end]" }}
"frozen" { if {[matchattr $hand n]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :frozen must have an action." } else {
set action [string tolower [lindex $text 1]]
if {$action == "list"} {
putserv "notice $nick :*** \002Frozen access list\002"
if {[userlist S] == ""} { putserv "notice $nick :*** Frozen list \002empty\002"
putserv "notice $nick :\002*** End of list\002" } else {
foreach user [userlist S] { putserv "notice $nick :*** $user" }
putserv "notice $nick :\002*** End of list\002"
writetolog "Frozen access list request by $nick"
}}}}}
"userlist" { if {[matchattr $hand n]} {
set place [lindex $text 1]
if {$place == ""} { putserv "privmsg $chan :Specify a channel to list the users." ; return 0}
putserv "notice $nick :\002*** Userlist for $place ***\002"
putserv "notice $nick :\002Founder(s):\002"
foreach user [userlist |n $place] {
if {$user == ""} {
putserv "notice $nick :\002 Empty \002"
} else {
putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002Master(s):\002"
foreach user [userlist |m $place] { if {![matchattr $user |n $place]} {putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002Auto-Ops:"
foreach user [userlist |o $place] { if {![matchattr $user |m $place]} { putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002Auto-Voice:"
foreach user [userlist |v $place] { if {![matchattr $user |o $place]} { putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002*** End of list ***\002"
writetolog "Channel user list for $place requested by $nick"
}}
"founder" { if {[matchattr $hand n]} {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
set them [lindex $text 2]
if {![onchan $them $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $them ($host) as a Founder of $chan"
adduser $them $host
set blah [nick2hand $them]
chattr $blah |+omnf $chan
writetolog "Added $them to the Founder list of $chan on request of $nick"
} elseif {$action == "del"} {
set them [lindex $text 2]
if {![validuser $them]} { putserv "privmsg $chan :$them is not a known Founder" } else {
putserv "privmsg $chan :Deleted $them as a channel Founder of $chan"
chattr $them |-nmof $chan
writetolog "Deleted $them from the Founder list of $chan on request of $nick"
}} elseif {$action == "list"} {
putserv "notice $nick :\002*** Founder list ***\002"
if {[userlist |n $chan] == ""} { putserv "notice $nick :Founder list is \002empty\002" }
foreach user [userlist |n $chan] { putserv "notice $nick :*** $user" }
putserv "notice $nick :\002*** End of list ***\002"
writetolog "Listed all Founders in $chan on request of $nick"
}
}}

"avoice" { if {[matchattr $hand o|o $chan]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :Avoice must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nickname to add." } else {
set user [lindex $text 2]
if {![onchan $user $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Auto-Voice list of $chan"
adduser $user $host
set blah [nick2hand $user]
chattr $blah |+vf $chan
pushmode $chan +v $user
putlog "added $user ($host) as AVoice on $chan - $nick"
putserv "notice $user :You have been added Auto-Voice of $chan  by $nick. Please set a password and remember it for further use."
putserv "notice $user :/msg $botnick pass <password>"
writetolog "Added $user ($host) to the Auto-Voice list of $chan on request of $nick"
}} elseif {$action == "del"} {
set user [lindex $text 2]
if {$user == ""} { putserv "privmsg $chan :You must specify a user to remove" } else {
if {![validuser $user]} { putserv "privmsg $chan :$user is not a valid user" } else {
chattr $user |-vf $chan
putserv "privmsg $chan :$user Removed from Avoice list of $chan"
writetolog "Deleted $user from the Auto-Voice list of $chan on request of $nick"
}}} elseif {$action == "list"} {
putserv "notice $nick :*** \002Avoice\002 list for $chan"
if {[userlist |v $chan] == ""} { putserv "notice $nick :*** Avoice list \002empty\002" } else {
foreach user [userlist |v $chan] { putserv "notice $nick :*** $user" }
putserv "notice $nick :\002*** End of list\002"
writetolog "Listed all Auto-Voice users for $chan on request of $nick"
}}} }}
"gowner" {
global root
set rootit [nick2hand $nick]
if {[matchattr $hand n] && $rootit == $root} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :gowner (Global owner) must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nickname to add." } else {
set user [lindex $text 2]
if {![onchan $user $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Global Owner list"
adduser $user $host
chattr $user +nf
pushmode $chan +o $user
putlog "added $user ($host) as Global Owner - $nick"
putserv "notice $user :You have been added as Global Owner. Please set a password and remember it for further use"
putserv "notice $user :/msg $botnick pass <password>"
writetolog "Added $user ($host) to the Global Owner list on request of $nick"
}} elseif {$action == "del"} {
set user [lindex $text 2]
if {$user == ""} { putserv "privmsg $chan :You must specify a user to remove" } else {
if {![validuser $user]} { putserv "privmsg $chan :$user is not a valid user" } else {
chattr $user -fhjmnoptx
putserv "privmsg $chan :$user Removed from Global Owner list"
writetolog "Deleted $user from the Global Owner list on request of $nick"
}}} elseif {$action == "list"} {
putserv "notice $nick :*** Global Owner list"
if {[userlist +n] == ""} { putserv "notice $nick :*** Global Owner list \002empty\002" } else {
foreach user [userlist +n] { putserv "notice $nick :*** $user" }
putserv "notice $nick :\002*** End of list\002"
writetolog "Listed all Global Owners on request of $nick
}}} }}
"sbot" { if {[matchattr $hand n]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :Sbot (sister Bot) must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nickname to add." } else {
set user [lindex $text 2]
if {![onchan $user $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Sister Bot list"
adduser $user $host
set blah [nick2hand $user]
chattr $blah +Bof
pushmode $chan +o $user
putlog "added $user ($host) as Sister Bot - $nick"
putserv "notice $user :You have been added as Sister Bot. Please set a password and remember it for further use"
putserv "notice $user :/msg $botnick pass <password>"
writetolog "Added $user to the Sister-Bot list in $chan on request of $nick"
}} elseif {$action == "del"} {
set user [lindex $text 2]
if {$user == ""} { putserv "privmsg $chan :You must specify a user to remove" } else {
if {![validuser $user]} { putserv "privmsg $chan :$user is not a valid user" } else {
chattr $user -B
putserv "privmsg $chan :$user Removed from Sister Bot list"
writetolog "Deleted $user from the Sister Bot list on request of $nick"
}}} elseif {$action == "list"} {
putserv "notice $nick :\002*** Sister Bot list\002"
if {[userlist +B] == ""} { putserv "notice $nick :*** Sister Bot list \002empty\002" } else {
foreach user [userlist +B] { putserv "notice $nick :*** $user" }
putserv "notice $nick :\002*** End of list\002"
writetolog "Listed all Sister Bots on request of $nick"
}}} }}
"master" { if {[matchattr $hand n|n $chan]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :Master must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nickname to add." } else {
set user [lindex $text 2]
if {![onchan $user $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Master list of $chan"
adduser $user $host
set blah [nick2hand $user]
chattr $blah |+ofm-v $chan
pushmode $chan +o $user
putlog "added $user ($host) as Master on $chan - $nick"
putserv "notice $user :You have been added as Master of $chan by $nick. Please set a password and remember it for urther use."
putserv "notice $user :/msg $botnick pass <password>"
writetolog "Added $user ($host) to the Master list of $chan on request of $nick"
}} elseif {$action == "del"} {
set user [lindex $text 2]
if {$user == ""} { putserv "privmsg $chan :You must specify a user to remove" } else {
if {![validuser $user]} { putserv "privmsg $chan :$user is not a valid user" } else {
chattr $user |-oafm $chan
putserv "privmsg $chan :$user Removed from Master list of $chan"
writetolog "Deleted $user from the Master list of $chan on request of $nick"
}}} elseif {$action == "list"} {
putserv "notice $nick :*** \002Master list for $chan\002"
if {[userlist |m $chan] == ""} { putserv "notice $nick :*** Master list \002empty\002" } else {
foreach user [userlist |m $chan] { if { ![matchattr $user |n $chan]} { putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002*** End of list\002"
writetolog "Listed all Masters in $chan on request of $nick"
}}}} }
"akick" { if {[matchattr $hand m|m $chan]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :Akick must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nick/hostname to add." } else {
set user [lindex $text 2]
set reason [lrange $text 4 end]
set time [lindex $text 3]
if {![onchan $user $chan]} { putserv "privmsg $chan :Added $user to akick list of $chan" ; newchanban $chan $user $nick $reason 0; writetolog "Added akick on $chan for $user by $nick" } else {
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Akick list of $chan"
newchanban $chan $host $nick $reason
putserv "kick $chan $user :$reason"
putlog "added $user ($host) as akick on $chan - $nick"
writetolog "Added $user ($host) on the akick list of $chan on request of $nick"
}}} elseif {$action == "del"} { killchanban $chan [lindex $text 2] ; putserv "privmsg $chan :Removed ban on [lindex $text 2]"
writetolog "Deleted akick for [lindex $text 2] on $chan on request of $nick"
} elseif {$action == "list" } {
putserv "notice $nick :\002*** Akick list for $chan:\002"
if {[banlist $chan] == ""} { putserv "notice $nick :Akick list for $chan \002Empty\002" }
foreach ban [banlist $chan] {
set banexpiretime "[ctime [lindex $ban 2]]"
if {[lindex $ban 2] == "0"} { set banexpiretime "\002Never\002" }
putserv "notice $nick :Banmask: [lindex $ban 0] Reason: [lindex $ban 1] Expires: $banexpiretime Banned by: [lindex $ban 5]" }
putserv "notice $nick :*** \002End of list\002 ***"
writetolog "Listed all akicks in $chan on request of $nick"
}
}}}
"aop" { if {[matchattr $hand m|m $chan]} {
global botnick
if {[lindex $text 1] == ""} { putserv "privmsg $chan :Aop must have an action, either: Add/Del/List" } else {
set action [string tolower [lindex $text 1]]
if {$action == "add"} {
if {[lindex $text 2] == ""} { putserv "privmsg $chan :You must specify a nickname to add." } else {
set user [lindex $text 2]
if {![onchan $user $chan]} { putserv "privmsg $chan :$user is not on the channel." ; return 0 }
set host [maskhost [getchanhost [lindex $text 2] $chan]]
putserv "privmsg $chan :Added $user ($host) to the Aop list of $chan"
adduser $user $host
set blah [nick2hand $user]
chattr $blah |+of-v $chan
pushmode $chan +o $user
putlog "added $user (Handle: $blah) ($host) as Aop on $chan - $nick"
putserv "notice $user :You have been added as Aop of $chan by $nick. Please set a password and remember it for further use."
putserv "notice $user :/msg $botnick pass <password>"
writetolog "Added $user ($host) to the Aop list of $chan on request of $nick"
}} elseif {$action == "del"} {
set user [lindex $text 2]
if {$user == ""} { putserv "privmsg $chan :You must specify a user to remove" } else {
if {![validuser $user]} { putserv "privmsg $chan :$user is not a valid user" } else {
chattr $user |-aof $chan
putserv "privmsg $chan :$user Removed from Aop list of $chan"
writetolog "Deleted $user from the Aop list of $chan on request of $nick"
}}} elseif {$action == "list"} {
putserv "notice $nick :*** \002Aop\002 list for $chan"
if {[userlist |o $chan] == ""} { putserv "notice $nick :*** Aop list \002empty\002" } else {
foreach user [userlist |o $chan] { if {
![matchattr $user v|v $chan] && ![matchattr $user m|m $chan] && ![matchattr $user n|n $chan]} {
putserv "notice $nick :*** $user" }}
putserv "notice $nick :\002*** End of list\002" ; writetolog "Listed all Aops for $chan on request of $nick"}}}}
}}}

proc identify.proc {nick uhost hand text} {
if {[passwdok [lindex $text 0] [lindex $text 1]]} {
if {[maskhost [getchanhost $nick]] == "*!*@"} { putserv "notice $nick :Please join a channel I monitor before identifying..." ; writetolog ">> $nick attempted to identify to \002* [lindex $text 0] *\002 but I failed to grab their hostname." } else {
setuser [lindex $text 0] HOSTS [maskhost [getchanhost $nick]]
putserv "notice $nick :You are now recognised as [lindex $text 0] / $nick" ; putlog ">> $nick identify [lindex $text 0] " ; writetolog ">> $nick identified as \002* [lindex $text 0] *\002 with host: ([maskhost [getchanhost $nick]])" }} else {
putserv "notice $nick :no such user or bad password" ; writetolog ">> $nick failed to identify" ; return 0 }}

proc unbanme {nick uhost hand text} {
set dachan [lindex $text 0]
if {[matchattr $hand o|o $dachan]} {
putserv "invite $nick $dachan"
putserv "notice $nick :Invited you to $dachan.  This request has been logged."
writetolog "Invited $nick in to $dachan"
}}

proc ident.proc {nick uhost hand text dest} {
global botnick nsnick nspass
if {[string tolower $nick] == "nickserv"} {
putserv "privmsg $nsnick :identify $nspass"
writetolog "Nickname identification sent to $nsnick for $botnick"
putlog "Identify command issued to $nsnick"
}
}

proc writetolog {text} {
global log dump logchan
  set file [open "$log" "a"]
  puts $file "\[[clock format [clock seconds] -format "%D %T"]\] $text"
  flush $file
  close $file
#Test Dump purpose
if {$dump == 1} {
putserv "privmsg $logchan :\002*** Log Dump: \002* $text *"
}}

proc clean args { global do_clean ;if {$do_clean == "enabled"} { save; putlog "Clean Started";foreach user [userlist] { if {[matchattr $user n] ||
[matchattr $user B]} { continue }; if {[getuser $user LASTON] == "" || [expr [unixtime] -[lindex [split [getuser $user LASTON]] 0]] >= 1728000} { if {[expr [unixtime] -[getuser $user XTRA "created"]] < "864000"} { continue }
deluser $user; putlog "$user has been deleted from userlist for being gone over 20 days"
writetolog "Removed $user from the userlist due to inactivity"}}; putlog "Clean Finished" ; writetolog "UserCleaning completed on [clock format [clock seconds] -format "%D %T"]."}}

putlog "jucotcl-v1.6.tcl loaded"
proc op-bot {channel type} { global csnick botnick; if {[string match "*+needop*" [channel info $channel]]} { putserv "privmsg $csnick :op $channel $botnick" ; writetolog "Had to opself in $channel" ; putlog "** Request op in $channel" ; return 0 }}

set global-chanset {
	-restrict	+needop		-voiceall	-opall
}