#! /usr/bin/env bash
#
# ***** SHOWTRACKER *****
# Tracks where you have got up to in your tv shows, podcasts, etc.
# type "showtracker list" to list your shows, or "showtracker NAME-OF-SHOW to watch that show."

# before you run this, make a directory in your home directory called .showtracker

# Colors:
red='\033[0;31m'                                       
nc='\033[0m' # No Color           
yellow='\033[1;33m'                                       

function start_up {
    # Gets ready.
    # make a note of the current working directory, so we can return to it afterwards.
    working_directory="$(pwd)"
    # cd into the .showtracker directory:
    cd ~/.showtracker
}

function get_out {
    # exits the script cleanly.
    cd "$working_directory"
    echo ""
    exit
}

function check_for_quit {
    # gets out if the variable passed is "q"
    if [ "$1" = "q" ]; then
	echo "Goodbye."
	get_out
    fi
}

function list_shows {
    # Lists all the available shows.
    echo ""
    cd ~/.showtracker
    listoffiles=$(ls)
    for file in $listoffiles; do
	showtitle="$(head -1 $file)"
	printf "$file:  $red$showtitle$nc\n"
    done
}

function print_title {
    # Prints the first line of the show file, = the title.
    title="$(head -1 $show)"
    printf "$red$title$nc\n"
}

function watch_preexisting_show {
    echo ""
    echo "You want to watch:"
    print_title
    if [ "$(get_episode_state)" = "WATCHED" ] ; then
	last_episode_was_watched
	watch_another_p
    elif [ "$(get_episode_state)" = "UNWATCHED" ] ; then
	last_episode_was_unwatched
	watched_p
    else
	last_episode_was_partially_watched
	watched_p
    fi
    get_out
}

function last_episode_was_watched {
    echo "Last time, you finished watching:"
    get_episode_name
    echo ""
}

function last_episode_was_unwatched {
    echo "You need to watch:"
    get_episode_name
}

function last_episode_was_partially_watched {
    episode="$(get_episode_name)"
    resume_at="$(get_episode_state)"
    echo "You need to watch:"
    echo $episode
    echo "From:"
    printf  "$red$resume_at$nc\n"
}

function get_episode_name {
    name="$(tail -2 $show | head -1)"
    printf "$red$name$nc"
}

function get_episode_state {
    # prints the current state of the last episode entered
    state="$(get_last_line)"
    echo $state
}

function get_last_line {
    tail -n 1 $show
}

function watch_new_show {
    echo -n "Do you want to watch a new show? (y/n/q): "
    read answer
    if [ "$answer" = "y" ]; then
	name_new_show
	get_out
    else
	echo "No, you don't, or something else."
	get_out
    fi
    get_out
}

function name_new_show {
    printf "What is the full name of the show you want to refer to as $red$show$nc? (q quits)\n"
    read answer
    check_for_quit $answer
    echo ""
    printf "Opening a new file: $red$show$nc\n"
    touch $show
    printf "For the show:       $red$answer$nc\n"
    echo $answer >> $show
    name_new_episode
}

function name_new_episode {
    echo ""
    echo "What is the name of the next episode?"
#    echo "(e.g. S01E01 The Foo Menace.)"
    read episode_name
    correct_p
    echo $episode_name >> $show
    echo "UNWATCHED" >> $show
    watched_p
}

function correct_p {
    # Asks if the previous line is correct, and quits if not.
    echo -n "Correct? (y/q): "
    read answer
    check_for_quit $answer
}

function watched_p {
    echo ""
    echo -n "Have you finished this episode yet? (y/n/q): "
    read answer
    check_for_quit $answer
    if [ "$answer" = "y" ]; then
	mark_watched
    else
	mark_partially_watched
    fi
}

function mark_watched {
    echo "Marking episode WATCHED."
    remove_last_line
    echo "WATCHED" >> $show
    #    cat $show
    watch_another_p
}

function remove_last_line {
    # Removes the last line of the file $show
    head -n -1 $show > .temp ; mv .temp $show
}

function mark_partially_watched {
    echo "You have partially watched it."
    echo "Where should you resume this episode from?"
    read resumption
    correct_p
    remove_last_line
    echo $resumption >> $show
    echo ""
    echo "Until next time..."
    get_out
}

function watch_another_p {
    echo ""
    echo -n "Watch another episode of this? (y/q): "
    read answer
    check_for_quit $answer
    name_new_episode
}

function list_shows_p {
    # do you just want to list the shows? if so, print them out, then exit.
    if [ "$show" = "list" ]; then
	list_shows
	get_out
    elif [ "$show" = "" ]; then
	list_shows
	get_out
    fi    
}

function new_or_existing_show_p {
    # If the user does not just want to list shows, then he must want either to watch an existing show, or enter a new show.
    # we can establish which by seeing if the show is the name of one of the files in the .showtracker directory:
    if ls | grep -q -x "$show" ; then
	watch_preexisting_show
    else
	watch_new_show
    fi
}




# *******MAIN**********
# the input to showtracker:
show=$1

# functions to run:
start_up
list_shows_p
new_or_existing_show_p
