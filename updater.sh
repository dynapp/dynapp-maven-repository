#!/usr/bin/env bash
echo "Starting clean..."
rm -rf temp && mkdir $_ && cd $_
echo "Downloading Robocore..."
curl -sS https://raw.githubusercontent.com/ftctechnh/ftc_app/master/FtcRobotController/libs/RobotCore-release.aar > robotcore.aar
echo "Finding Source..."
find . -name '*.aar' -exec sh -c 'unzip -d `dirname {}` {} classes.jar' \; &> /dev/null
echo "Decompiling..."
java -jar ../decompile.jar classes.jar src &> /dev/null
echo "Moving..."
cd ..
mv temp/classes.jar robotcore-latest.jar
read -p "Version: " version 
mvn install:install-file -DgroupId=com.qualcomm -DartifactId=robotcore -Dversion=$version -Dpackaging=jar -Dfile=robotcore-latest.jar -DlocalRepositoryPath=repo
rm -rf temp
sed -e "s/\${version}/$version/" readme.template > README.md

if ! git diff-index --quiet HEAD --; then
	echo "Code changes detected!"
	read -n1 -p "[y,n] Update:" update 
	if [[ $update == "Y" || $update == "y" ]]; then
		echo "Updating..."
		git add .
		git commit -m "Updated Code..."
		git push
	else
		echo "Canceling update..."
	fi
else
	echo "No code changes detected!"
fi