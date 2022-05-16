import os

print("Welcome to the MOVSYS program. This program is for VIRTUAL MACHINES only. (In it's current version)")
print("This updates the system, deleting older commands, replacing them with newer ones. You may always downgrade back.")
user = input("Enter the OS directory to update: ")
os.system("rm -vrf",user)
os.system("git clone ")
