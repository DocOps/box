#!/usr/bin/env bash

# Stage 1: This function checks if an upstream repo exists, fetches it, and syncs it with base branch 
function sync_with_upstream() {
	# Check if an upstream repository exists
	echo "Checking if upstream exists..."
	git remote -v

	if ! git remote | grep -q upstream; then
		echo "Error: upstream not found. Please add upstream repository using 'git remote add upstream git@github.com:<upstream/repo>.git' or 'git remote add upstream <upstream/url>.git' and re-execute the script."
		exit 1
	fi

	# Fetch upstream changes
	echo "Fetching upstream..."
	git fetch upstream

	if [ $? -ne 0 ]; then
		echo "Error: can't fetch upstream due to a network issue or permission error"
		exit 1
	fi

	# Sync upstream changes to base branch
	echo "Syncing upstream changes to your base branch"
	if git ls-remote --exit-code --heads upstream main > /dev/null; then
		upstream_branch="main"
	elif git ls-remote --exit-code --heads upstream master > /dev/null; then
		upstream_branch="master"
	else
		echo "Error: Can't sync upstream changes to your base branch because the base branch for upstream is neither set to 'main' nor 'master'"
		exit 1
	fi
	git rebase upstream/$upstream_branch

	# Check for rebase conflicts
	while [ $? -ne 0 ]; do
		echo "Conflict encountered during rebase process. Resolve conflicts by pressing 'y' to continue or just press 'n' to abort rebase process."	
		read user_input
		if [ "$user_input" == "y" ]; then
			git rebase --continue
		else 
			git rebase --abort
			break
		fi
	done

	echo "Rebase successful. Now select 2 to create a local branch, skip if you want to commit directly to base branch."
}

# Stage 2: This function creates a new branch
function create_new_branch() {
	read -p "Enter the name of your new branch: " new_branch
	echo "Creating and switching to branch $new_branch..."
	git checkout -b "$new_branch"
	if [ $? -eq 0 ]; then
		echo "Now in branch $new_branch. Select 3 when you are ready to add and commit changes."
	else
		echo "Error: can't create $new_branch. Either there is a permission error or $new_branch already exists."
	fi	
}

# Function to display the file selection menu and stage the selected files
stage_files() {
  # Get the list of tracked and untracked files from git status --porcelain
  mapfile -t files < <(git status --porcelain | grep -E '^(A|M|\?\?)' | awk '{print $2}')

  if [ ${#files[@]} -eq 0 ]; then
    echo "No files to stage."
    exit 0
  fi

  echo "Select files to stage (space-separated numbers), or press Enter to finish:"
  
  # Display menu with numbered options
  for i in "${!files[@]}"; do
    echo "$((i+1)). ${files[$i]}"
  done

  # Prompt for user input (space-separated numbers)
  read -p "Enter file numbers to stage: " -a selections

  # Check if the user provided selections
  if [ ${#selections[@]} -eq 0 ]; then
    echo "No files selected. Exiting."
    exit 0
  fi

  # Stage the selected files
  for selection in "${selections[@]}"; do
    if [[ $selection =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#files[@]} ]; then
      git add "${files[$((selection-1))]}"
      echo "Staged: ${files[$((selection-1))]}"
    else
      echo "Invalid selection: $selection"
    fi
  done

  echo "Staging complete."
}

# Stage 3: This function adds and commit changes
function add_and_commit_changes() {
  stage_files
	git status

	# Ensure that users can add another file by creating a loop that prompts them to add another until they enter 'n'
	while true; do
		echo "Do you still need to add a file? [y/n]"
		read add_choice
		if [ "$add_choice" == "y" ]; then
			read -p "Enter another file to add (only specify a single file): " another_file_to_add
			git add "$another_file_to_add"
			git status
		elif [ "$add_choice" == "n" ]; then
			break
		else
			echo "Invalid input, please enter 'y' or 'n'"
		fi
	done

	read -p "Enter your commit message: " commit_msg
	read -p "Enter an additional commit message (optional, press enter to skip): " additional_commit_msg

	if 	[ -z "$commit_msg" ];then
		echo "Error: You have to input a commit message"
	elif [ -z "$additional_commit_msg" ]; then
		git commit -m "$commit_msg"
	else
		git commit -m "$commit_msg" -m "$additional_commit_msg"
	fi

	git status
	echo "Select 4 to sync your current branch with upstream changes. If you do not want to, select 5 to exit and push."
}

# Stage 4: This function syncs your current branch with upstream
function sync_branch_with_upstream() {
	echo "Fetching the latest changes from upstream..."
	git fetch upstream 

	if [ $? -ne 0 ]; then
	echo "Error: can't fetch upstream due to a network issue or permission error. You can re-execute the script and select option 4 to start the syncing process again."
		exit 1
	fi

	# Sync upstream changes to current branch
	echo "Syncing upstream changes to current branch"
	if git ls-remote --exit-code --heads upstream main > /dev/null; then
		upstream_branch="main"
	elif git ls-remote --exit-code --heads upstream master > /dev/null; then
		upstream_branch="master"
	else
		echo "Error: Can't sync upstream changes to current branch because the base branch for upstream is neither set to 'main' nor 'master'"
		exit 1
	fi
	git rebase upstream/$upstream_branch

	# Check for rebase conflicts again
	while [ $? -ne 0 ]; do
		echo "Conflict encountered during rebase process. Resolve conflicts, then press 'y' to continue or 'n' to abort."	
		read user_input
		if [ "$user_input" == "y" ]; then
			git rebase --continue
		else 
			git rebase --abort
			echo "You can now exit and push"
			break
		fi
	done

	echo "Press 5 to exit. Then Use 'git push origin <branch_name> -f' if you encountered conflicts during rebase and normal push command if you did not."
}

# Main script
echo "You've now executed the Git automation script!"
PS3="Please choose an option:"
options=("Sync base branch with upstream" "Create a new branch" "Add and commit changes" "Sync current branch with upstream" "Exit")
select opt in "${options[@]}"
do
	case $opt in
		"Sync base branch with upstream")
			sync_with_upstream
			;;
		"Create a new branch")
			create_new_branch
			;;
		"Add and commit changes")
			add_and_commit_changes
			;;
		"Sync current branch with upstream")
			sync_branch_with_upstream
			;;
		"Exit")
			break
			;;
		*) echo "Invalid option $REPLY";;
	esac
done
