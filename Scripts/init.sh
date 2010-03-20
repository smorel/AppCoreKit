CLOUDKITPWD="Frameworks/CloudKit"

if [ -d $CLOUDKITPWD/CloudKit.xcodeproj ]; then
  exit 0
fi

if [ ! -d .git ]; then
  git init
fi

git submodule add git@github.com:kleinman/cloudkit.git $CLOUDKITPWD
git submodule init
git submodule update
