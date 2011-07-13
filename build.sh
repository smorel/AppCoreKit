# setup environment
SCRIPTPATH=$(cd "$(dirname "$0")"; pwd)
echo $SCRIPTPATH

PROJECT="CloudKit"
echo $PROJECT

MINOR_VERSION_NUMBER=$(git log --pretty=oneline | wc -l | cut -c 5-)
echo $MINOR_VERSION_NUMBER

MAJOR_VERSION="1.6"
echo $MAJOR_VERSION

BUILD_DIR="${SCRIPTPATH}/Build"
echo $BUILD_DIR

CONFIGURATION="release"
echo $CONFIGURATION

SRCROOT="${SCRIPTPATH}"
echo $SRCROOT

DEVELOPER_DIR="/Developer4"
echo $DEVELOPER_DIR

# Assume the target name is the same as the project name
UFW_TARGET=${PROJECT}

if [ -z ${SDK_NAME} ]; then
# Use the latest iphoneos SDK available
UFW_GREP_RESULT=$(xcodebuild -showsdks | grep -o "iphoneos.*$")
while read -r line; do
UFW_SDK_VERSION="${line}"
done <<< "${UFW_GREP_RESULT}"
else
# Use the SDK specified by XCode
UFW_SDK_VERSION="${SDK_NAME}"
fi

UFW_SDK_VERSION=$(echo "${UFW_SDK_VERSION}" | grep -o "[0-9].*$")
UFW_FMWK_DIRNAME="${UFW_TARGET}.framework"
UFW_EXE_PATH="${UFW_FMWK_DIRNAME}/Versions/Current/${UFW_TARGET}"
UFW_IPHONE_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneos"
UFW_SIMULATOR_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator"
UFW_UNIVERSAL_DIR="${HOME}/Dropbox/CloudKitFramework/Versions/${MAJOR_VERSION}"
UFW_DOCUMENTATION_DIR="${UFW_UNIVERSAL_DIR}/${UFW_FMWK_DIRNAME}/Documentation"
UFW_HEADERS_DIR="${UFW_UNIVERSAL_DIR}/${UFW_FMWK_DIRNAME}/Headers"


# versioning

agvtool new-marketing-version ${MAJOR_VERSION}
agvtool new-version -all ${MINOR_VERSION_NUMBER}

# Build Framework


xcodebuild -target "${UFW_TARGET}" -configuration ${CONFIGURATION} -sdk iphoneos${UFW_SDK_VERSION} BUILD_DIR=${BUILD_DIR}  clean build
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi
xcodebuild -target "${UFW_TARGET}" -configuration ${CONFIGURATION} -sdk iphonesimulator${UFW_SDK_VERSION} BUILD_DIR=${BUILD_DIR}  clean build
if [ "$?" != "0" ]; then echo >&2 "Error: xcodebuild failed"; exit 1; fi

if [ ! -f "${UFW_IPHONE_DIR}/${UFW_EXE_PATH}" ]; then
echo "Framework target \"${UFW_TARGET}\" had no source files to build from. Make sure your source files have the correct target membership"
exit 1
fi

echo "AFTER BUILD"

cd 
rm -rf ${UFW_UNIVERSAL_DIR}
echo $UFW_UNIVERSAL_DIR

mkdir -p ${UFW_UNIVERSAL_DIR}
if [ "$?" != "0" ]; then echo >&2 "Error: mkdir failed"; exit 1; fi

echo "copying framework"
echo "UFW_IPHONE_DIR/UFW_FMWK_DIRNAME"
echo ${UFW_IPHONE_DIR}/${UFW_FMWK_DIRNAME}
echo "UFW_UNIVERSAL_DIR/UFW_FMWK_DIRNAME"
echo ${UFW_UNIVERSAL_DIR}/${UFW_FMWK_DIRNAME}
echo "UFW_IPHONE_DIR/UFW_EXE_PATH"
echo ${UFW_IPHONE_DIR}/${UFW_EXE_PATH}
echo "UFW_SIMULATOR_DIR/UFW_EXE_PATH"
echo ${UFW_SIMULATOR_DIR}/${UFW_EXE_PATH}

cp -a ${UFW_IPHONE_DIR}/${UFW_FMWK_DIRNAME} ${UFW_UNIVERSAL_DIR}/${UFW_FMWK_DIRNAME}
if [ "$?" != "0" ]; then echo >&2 "Error: cp failed"; exit 1; fi

echo "BEFORE LIPO"
echo ${UFW_UNIVERSAL_DIR}/${UFW_EXE_PATH}

lipo -create -output ${UFW_UNIVERSAL_DIR}/${UFW_EXE_PATH} ${UFW_IPHONE_DIR}/${UFW_EXE_PATH} ${UFW_SIMULATOR_DIR}/${UFW_EXE_PATH}
if [ "$?" != "0" ]; then echo >&2 "Error: lipo failed"; exit 1; fi


# Generates Documentation
appledoc --create-docset --install-docset --output ${UFW_IPHONE_DIR}/Documentation/output --docset-install-path ${UFW_DOCUMENTATION_DIR} --project-name "${UFW_TARGET}" --project-company "Wherecloud" --company-id "com.wherecloud" --project-version "${MAJOR_VERSION}" --warn-undocumented-object --ignore .m ${SRCROOT}/Classes

echo $UFW_DOCUMENTATION_DIR

cp -R -f ${UFW_DOCUMENTATION_DIR}/com.wherecloud.${UFW_TARGET}.docset ${DEVELOPER_DIR}/Documentation/DocSets