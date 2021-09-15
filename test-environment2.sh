#! /bin/bash
sudo rm -fr madesoft1
git clone https://github.com/jandresh/madesoft1
cd madesoft1/
for branch in `git branch -r | grep -v HEAD`;do echo -e `git show --format="%ci" $branch | head -n 1` \\t$branch; done | sort -r | head -n 1 | grep -o -P '(?<=origin/).*(?=)' > branch.txt
export LAST_BRANCH=$(cat branch.txt)
git checkout $LAST_BRANCH
sudo docker-compose down
cd kompose
sudo docker-compose up -d
