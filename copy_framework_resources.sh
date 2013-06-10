# !/bin/sh
# build script

function echo_usage_and_exit() {
echo "Usage: `basename $0` --system-developer-dir <SYSTEM_DEVELOPER_DIR> --executable-name <EXECUTABLE_NAME> --frameworks-dir <FRAMEWORKS_DIR> --target-build-dir <TARGET_BUILD_DIR> --project <PROJECT> --project-dir <PROJECT_DIR>"
exit 1
}

if [ $# -eq 0 ]
then
echo_usage_and_exit
fi


while [ $# -gt 0 ]; do

   PARAM=$1
   VALUE=$2
   echo "PARAM : \"$PARAM\""
   echo " VALUE : \"$VALUE\""

   case $PARAM in
      --system-developer-dir) SYSTEM_DEVELOPER_DIR=$VALUE;;
      --executable-name)      EXECUTABLE_NAME=$VALUE;;
      --frameworks-dir)       FRAMEWORKS_DIR=$VALUE;;
      --target-build-dir)     TARGET_BUILD_DIR=$VALUE;;
      --project)              PROJECT=$VALUE;;
      --project-dir)          PROJECT_DIR=$VALUE;;
      --help)                 echo_usage_and_exit;;
   esac

   shift
   shift

done

echo "CURRENT PATH : $PWD"
echo "SYSTEM_DEVELOPER_DIR: $SYSTEM_DEVELOPER_DIR"
echo "EXECUTABLE_NAME: $EXECUTABLE_NAME"
echo "TARGET_BUILD_DIR: $TARGET_BUILD_DIR"
echo "PROJECT: $PROJECT"
echo "PROJECT_DIR: $PROJECT_DIR"
echo "FRAMEWORKS_DIR: $FRAMEWORKS_DIR"


#needed environment variables
BUILD_DIR="$TARGET_BUILD_DIR"
APP_NAME="${EXECUTABLE_NAME}"
XCODE_DIR="${SYSTEM_DEVELOPER_DIR}"

#script
export PATH=$PATH:"${SYSTEM_DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer/usr/bin:${SYSTEM_DEVELOPER_DIR}/usr/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${SYSTEM_DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer/Library/Xcode/PrivatePlugIns/iPhoneOS Build System Support.xcplugin/Contents/Resources/"
export XCODE_DEVELOPER_USR_PATH=$XCODE_DEVELOPER_USR_PATH:${SYSTEM_DEVELOPER_DIR}/usr/bin/..
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"

cd "$FRAMEWORKS_DIR"
FRAMEWORKS=$(find . -name "*.framework")

cd "$PROJECT_DIR/"
PROJ_FILE=$(find . -path "*${PROJECT}.xcodeproj/project.pbxproj")
echo "PROJECT_FILE: $PROJ_FILE"

for f in ${FRAMEWORKS}
do
    TMP_PATH=$(echo "$f" | cut -b 3-)
    echo $TMP_PATH

    TMP_NAME=$(basename $f)
    echo $TMP_NAME

    #search if this framework version is used in the project
    grep "$TMP_PATH" "$PROJECT_DIR/$PROJ_FILE"
    if [ $? -eq 0 ]
    then
        echo "${TMP_PATH} ${TMP_NAME}"

        TMP_BUILD_FRAMEWORK_PATH="${BUILD_DIR}/${TMP_NAME}"
        if [ -d "$TMP_BUILD_FRAMEWORK_PATH" ] 
        then
            TMP_RESOURCESPATH="$TMP_BUILD_FRAMEWORK_PATH/Resources"
        else 
            TMP_RESOURCESPATH="${FRAMEWORKS_DIR}/${TMP_PATH}/Resources"
        fi

        echo $TMP_RESOURCESPATH
        cd "$TMP_RESOURCESPATH"

        #copy image by crunching them
        IMAGES=$(find . -name "*.png")
        for img in ${IMAGES}
        do
            DIRECTORY=$(dirname "$APP_PATH/$img")
            mkdir -p "$DIRECTORY"
            copypng -compress "" "$TMP_RESOURCESPATH/$img" "$APP_PATH/$img" 
        done

        #compile and copy the core data models
        CORE_DATA_MODELS=$(find . -name "*.xcdatamodeld")
        for cdm in ${CORE_DATA_MODELS}
        do
            #find the name without extension
            TMP_CMD_NAME=$(basename $cdm)
            CDM_NAME=$(echo "$TMP_CMD_NAME" | cut -d'.' -f1)
            echo "${CDM_NAME}"


            DIRECTORY=$(dirname "$APP_PATH/$CDM_NAME.momd")
            mkdir -p "$DIRECTORY"

            momc -compress "" "$TMP_RESOURCESPATH/$cdm" "$APP_PATH/$CDM_NAME.momd"
        done

       #compile and copy the xib files
       XIBFILES=$(find . -name "*.xib")
       for xib in ${XIBFILES}
       do
           #find the name without extension
           TMP_XIB_NAME=$(basename $cdm)
           XIB_NAME=$(echo "$TMP_XIB_NAME" | cut -d'.' -f1)
           echo "${XIB_NAME}"


          DIRECTORY=$(dirname "$APP_PATH/$CDM_NAME.nib")
          mkdir -p "$DIRECTORY"

          ibtool --errors --warnings --notices --output-format human-readable-text --compile "$APP_PATH/$CDM_NAME.nib" "$TMP_RESOURCESPATH/$xib" --sdk ${SDKROOT}
      done


      #simply copy the rest of the files and folders
      rsync -avz --exclude "*.png" --exclude "*.xcdatamodeld" --exclude "Info.plist" --exclude "*.xib" "$TMP_RESOURCESPATH/" "$APP_PATH/"
    fi
done