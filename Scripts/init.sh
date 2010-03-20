CLOUDKITPWD="Frameworks/CloudKit"

if [ ! -d .git ]; then
  echo "Not a Git repository."
  exit 1
fi

if [ -d $CLOUDKITPWD/CloudKit.xcodeproj ]; then
  exit 0
fi

git submodule add git@github.com:kleinman/cloudkit.git $CLOUDKITPWD
git submodule init
git submodule update
