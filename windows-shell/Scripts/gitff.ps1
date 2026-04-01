$branch = git rev-parse --abbrev-ref HEAD
git fetch --all -p
git checkout develop
git merge --ff-only
git checkout master
git merge --ff-only
git checkout $branch
