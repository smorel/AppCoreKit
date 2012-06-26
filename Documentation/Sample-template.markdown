<h2>Summary</h2>

<p>This sample illustrate how we can create a Twitter client displaying the public time that is fetched from the web asynchronously.</p>

<h2>Defining the Document</h2>

<p>First, we need to define our document models that will represents our data. Our client will represent a timeline that is a collection of Tweets displaying the avatar image, the name of the user and its message.</p>

<i>Document.h</i>

    @interface Tweet : CKObject
    @property(nonatomic,copy) NSURL* imageUrl;
    @property(nonatomic,copy) NSString* name;
    @property(nonatomic,copy) NSString* message;
    @end

    @interface Timeline : CKObject
    @property(nonatomic,retain) CKArrayCollection* tweets;
    @end


<i>Document.m</i>

    @implementation Tweet
    @synthesize imageUrl,name,message;
    @end

    @implementation Timeline
    @synthesize tweets;
    @end


<h2>Setupping the Collection View Controller</h2>

<p>Using the <b>AppCoreKit</b> advanced collection view controllers, we can display a collection of objects easilly. Each object in this collection be get backuped by a cell controller that will manage the connection between the document object and the collection cell. We dont need to do extra management for updates in the collection as collection view controllers embbed a mechanism that watches changes in this collection and automatically updates its content reflecting this changes.</p>
<p>What we need to do is basically create the collection view controller passing the collection of objects and a factory that allow to create cell controllers at runtime when updates are catched by the controller.</p>
<p><b>AppCoreKit</b> offers extremelly customizable view controllers that can be setupped using blocks and avoid to inheritance. As a good practice, we prefer using factory methods steupping view controllers instead of inheritance. That limits the developper to respect the scope that is offered by the controller class. It avoid errors and hacks. For example, the developper will not be able to add a bunch of booleans or properties that polute the code.</b>
<p></p>
<p>In this particular case, we want to display our collection using a table view controller. We'll use a form that allow to manage sections manages TableViewCellControllers. <b>AppCoreKit</b> provides a lot of helpers to create standards cell controllers that can be visually customized using stylesheets or programatically.</p>

<i>ViewControllers.h</i>

    @interface ViewControllers : NSObject
    + (CKViewController*)viewControllerForTimeline:(Timeline*)timeline;
    @end


<i>ViewControllers.m</i>

    @implementation ViewControllers

    + (CKViewController*)viewControllerForTimeline:(Timeline*)timeline{

        CKCollectionCellControllerFactory* tweetsFactory = [CKCollectionCellControllerFactory factory];
        [tweetsFactory addItemForObjectOfClass:[Tweet class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
            Tweet* tweet = (Tweet*)object;
            CKTableViewCellController* cellController =  [CKTableViewCellController cellControllerWithTitle:tweet.name subtitle:tweet.message defaultImage:[UIImage imageNamed:@"default_avatar"] imageURL:tweet.imageUrl imageSize:CGSizeMake(40,40) action:nil];
            return cellController;
        }];

        CKFormTableViewController* form = [CKFormTableViewController controller];

        CKFormBindedCollectionSection* section = [CKFormBindedCollectionSection sectionWithCollection:timeline.tweets factory:tweetsFactory appendSpinnerAsFooterCell:YES];
        [form addSections:[NSArray arrayWithObject:section]];
        return form;
    }

    @end



<h2>Displaying the view controller</h2>

<p>In this sample, we'll only display this view controller in a navigation controller in the main window of the application. Here, we'll create a timeline singleton and a view controller displaying this timeline. Lets setup the Application delegate to do so:</b>

<i>AppDelegate.h</i>

    @interface AppDelegate : UIResponder -ApplicationDelegate-
    @property (strong, nonatomic) UIWindow *window;
    @end
        
<i>AppDelegate.m</i>

    #import "AppDelegate.h"
    #import "ViewControllers.h"
        
    @implementation AppDelegate
        
    - (void)dealloc{
        [_window release];
        [super dealloc];
    }
        
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
        Timeline* timeline = [Timeline sharedInstance];
        
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        self.window.rootViewController = [[[UINavigationController alloc]initWithRootViewController:[ViewControllers viewControllerForTimeline:timeline]]autorelease];
        [self.window makeKeyAndVisible];
        return YES;
    }
        
    @end
        
<p>Here we're done for the first part of the sample. We have a fully functionnal document and a form that can display the twitter timeline content asynchronously. We now need to get some data from the web.</b>


<h2>Fetching data from the web</h2>

<p><b>AppCoreKit</b> provides the FeedSource mechanism. Connected to a Collection, collection view controller will be able to fetch range of data as needed when scrolling for example. FeedSource provides an easy way to define Web API with paging that will automatically populate a document's collection when they are connected together. That means, if your collection view controller display a collection associated to a feed source, the UI Interface and your document collection will automatically get synched at any time and get as much data as your FeedSource can provide automatically and asynchronously.<p>
<p>WebSource is a particular FeedSource allowing data to be fetched using WebRequests. WebRequests are fully multi-threaded using GCD that allow non bloquant web requests.<p>
<p>Lets implements your first WebSource for the twitter public timeline. Like viewControllers, we like to create FeedSources using factory methods instead of inheritance as it provides block based interface.</p>
<p></p>
<p>Like cell controllers, <b>AppCoreKit</b> provides factory method to build advanced WebRequests. We'll use one of these in this sample that use our Mappings system to convert the received JSON payload to an array of instance defined in our document. This method will fetch the paged data from twitter. When the data will get received, it will automatically transform the data as a dictionary by parsing the JSON content. This dictionary is named rawData. We specify that the data that has to be transformed by mappings is the array that we received. The mappingContextIdentifier is an id that we'll define in a .mappings file describing how each dictionary in the array must be transform to a Tweet instance.</p>



<i>FeedSources.h</i>

    @interface FeedSources : NSObject
    + (CKFeedSource*)feedSourceForTweets;
    @end

<i>FeedSources.m</i>

    @implementation FeedSources

    + (CKFeedSource*)feedSourceForTweets{
        CKWebSource* webSource = [[[CKWebSource alloc]init]autorelease];
        webSource.requestBlock = ^(NSRange range){
            NSURL* tweetsAPIUrl = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/public_timeline.json"];
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",range.length],@"count",@"true",@"include_entities", nil];

            CKWebRequest* request = [CKWebRequest requestForObjectsWithUrl:tweetsAPIUrl
                                                                    params:(NSDictionary*)params
                                                                      body:nil
                                                  mappingContextIdentifier:@"$Tweet"
                                                          transformRawData:^(id value){ return (NSArray*)value; }
                                                                completion:^(NSArray* objects){} 
                                                                     error:^(id value, NSHTTPURLResponse* response, NSError* error){}];
           return request;
        };
        return webSource;
    }

    @end


<p>Now lets define the mappings.</b>
<p>The mapping system is based on runtime and our conversion technology. It allow to define keypath to keypath conversion and specifying the class of instances we want to create. Here we have a simple example but this system allow much more complex transformations using templates, inheritance, custom transformer methods and more.</p>

<i>TwitterTimeline.mappings</i>


    {
        "$Tweet" : {
            "@class" : "Tweet",
            "imageUrl" : "user.profile_image_url",
            "name" : "user.name",
            "message" : "text"
        }
    }

<p>We also need to load this file in the Mapping context manager. We generally do this when the appDelegate gets created</p>


<i>AppDelegate.m</i>

    - (id)init{
        self = [super init];
        [CKMappingContext loadContentOfFileNamed:@"TwitterTimeline"];
        return self;
    }


<p>Here we have a fully functional twitter client application. The public timeline is displayed in subtitle style table view cell that are asynchronously created when data is fetched from the web using paging. It's time to add some eye candy and localization.</b>


<h2>Localizing your Application</h2>

<p><b>AppCoreKit</b> provides helpers to localize your application easilly. There are two cool features with this system. First, when running the app in the simulator, as soon as you change and save a .string file, your application is automatically updated at runtime. This avoid to change/compile and run that saves a LOT of time expecially when your debugging a view that is deep in that navigation workflow. Second, our system allow to change the language at runtime just by setiing the language property of the CKLocalizationManager.</p>
<p>Lets add a localized title to our view controller</p>

<i>ViewControllers.m</i>

    CKFormTableViewController* form = [CKFormTableViewController controller];
    form.title = _(@"kTimelineTitle");

<i>TwitterTimeline.strings</i>

    "kTimelineTitle" = "Timeline  Public";


<h2>Customizing the appearance</h2>

<p><b>AppCoreKit</b> provides a CSS like technology based on runtime and our conversion system. This allow to target and customize any controllers and views and customize any of their properties that are KVC complient. This system allow to define template that can be inherited by specific selector targeting you objects. Objects can be targetted using their class name, property name and specialized using any of their proerty values. You don't need to write code as any of the <b>AppCoreKit</b> controllers and views are able to find their specific style and apply it to their properties, controller view hierarchy. Style definition repect the controller hierachy wich allow you to specify specific style for controllers that contained by other controllers and specific style for views that are contained in views and controllers. This is a very powerfull tool!</p>
<p>As we want to target our view controller specifically in stylesheets, we'll set its name property that we generally use for this purpose</p>

<i>ViewControllers.m</i>

    CKFormTableViewController* form = [CKFormTableViewController controller];
    form.name = @"Timeline";
    
<i>TwitterTimeline.style</i>

    {
        "$big_font" : {
            "fontSize" : 20
        },
    
        "$background" : {
            "backgroundColor" : "whiteColor"
        },
    
        "UIViewController[name=Timeline]" : {
            "rowInsertAnimation" : "UITableViewRowAnimationTop",
            "style" : "UITableViewStyleGrouped",
    
            "CKTableViewCellController" : {
                "cellStyle" : "CKTableViewCellStyleSubtitle2",
                "contentInsets" : "10 10 10 10",
                "UITableViewCell" : {
                    "backgroundView" : {
                        "@inherits" : [ "$background" ],
                    },
                    "selectedBackgroundView" : {
                        "backgroundColor" : "blueColor"
                    },
                    "textLabel,detailTextLabel" : {
                        "@inherits" : [ "$big_font", "$background" ],
                        "backgroundColor" : "whiteColor",
                    },
                    "imageView" : {
                        "@inherits" : [ "$background" ],
                        "clipsToBounds" : 0,
                        "opaque" : 1,
                        "layer" : {
                            "shadowColor" : "blackColor",
                            "shadowRadius" : 2,
                            "shadowOffset" : "0 2",
                            "shadowOpacity" : "0.8"
                        }
                    }
                }
            }
        },
    
        "UINavigationController" : {
            "navigationBar" : {
                "titleView" : {
                    "fontName" : "Helvetica-Bold",
                    "fontSize" : "18",
                    "textColor" : "whiteColor",
                    "backgroundColor" : "clearColor",
                    "shadowColor" : "darkGrayColor",
                    "shadowOffset" : "0 -1"
                }
            }
        }
    }


<p>We also need to load this file in the Style manager. We generally do this when the appDelegate gets created</p>
    
    
<i>AppDelegate.m</i>
    
    - (id)init{
        self = [super init];
        [CKMappingContext loadContentOfFileNamed:@"TwitterTimeline"];
        [[CKStyleManager defaultManager]loadContentOfFileNamed:@"TwitterTimeline"];
        return self;
    }