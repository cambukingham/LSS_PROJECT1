# LSS_PROJECT1
something something robot trajectory or something

basic git commands:


git clone <REMOTE_URL>
- clones the repository, essentially all folders and files into your place

git remote add origin <REMOTE_URL>
connects your current environment to an existing repository, allowing you to push and pull if authorization is allowed

git remote -v
checks if you are connected to the remote URL


git pull <REMOTE_NAME> <BRANCH_NAME>
# Example: git pull origin main
pulls whatever files/folders are currently on the repository into your environment, basically making you up to date


git push -u origin <BRANCH_NAME>
allows you to upload your changes/updates to the repository
the true pipeline is:
 add (git add <file name> or git add . for bulk add) 
commit (git commit -m "message")
push!!




matlab functions:

step - 
% 1. Unit Step Function (u(t) = 1 for t >= 0, else 0)
unitstep = (t >= 0);

ramp - 
% 2. Unit Ramp Function (r(t) = t for t >= 0, else 0)
ramp = t .* unitstep;