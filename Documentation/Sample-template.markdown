<h2>Summary</h2>

<p>This sample illustrates how to create a simple Twitter client displaying the public timeline.</p>

 - The data is fetched from the web asynchronously. 
 - The results are displayed in a table view with custom appearance.

<h2>Defining the Document</h2>

<p>First, we need to define our UI document models that will help representing our data. Our client is a timeline with a collection of Tweets displaying the avatar image, the name of the user and its message.</p>

<i>Document.h</i>

    @interface Tweet : CKObject
    @property(nonatomic,copy) NSURL* imageUrl;
    @property(nonatomic,copy) NSString* name;
    @property(nonatomic,copy) NSString* message;
    @end

    @interface Timeline : CKDocument
    @property(nonatomic,retain) CKArrayCollection* tweets;
    @end


<i>Document.m</i>

    @implementation Tweet
    @synthesize imageUrl,name,message;
    @end

    @implementation Timeline
    @synthesize tweets;
    @end


<h2>Setuping the Collection View Controller</h2>

<p>Using the <b>AppCoreKit</b> advanced collection view controllers, we can display a collection of objects easilly. Each object in this collection is backed-up by a cell controller that manages the connection between the document models and the collection view cells. We dont need to do extra management for asynchronous updates as collection view controllers embbed a mechanism that watches changes in this collection and automatically updates their content.</p>
<p>We need to create the collection view controller with:</p>
 - The collection of objects.
 - A factory allowing to create cell controllers at runtime when the collection gets updated.

<p>In this particular case, we want to display our collection using a table view controller. We'll use a form wich allow to manage sections with TableViewCellControllers. <b>AppCoreKit</b> provides a lot of helpers to create standards cell controllers wich appearance can be customized using stylesheets or programatically.</p>

<i>ViewControllers.h</i>

    @interface ViewControllers : NSObject
    + (CKViewController*)viewControllerForTimeline:(Timeline*)timeline;
    @end


<i>ViewControllers.m</i>

    @implementation ViewControllers

    + (CKViewController*)viewControllerForTimeline:(Timeline*)timeline{
        UIImage* default_avatar = [UIImage imageNamed:@"default_avatar"] ;

        CKCollectionCellControllerFactory* tweetsFactory = [CKCollectionCellControllerFactory factory];
        [tweetsFactory addItemForObjectOfClass:[Tweet class] withControllerCreationBlock:
            ^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
            Tweet* tweet = (Tweet*)object;
            CKTableViewCellController* cellController =  [CKTableViewCellController cellControllerWithTitle:tweet.name 
                                                                                                   subtitle:tweet.message 
                                                                                               defaultImage:default_avatar
                                                                                                   imageURL:tweet.imageUrl 
                                                                                                  imageSize:CGSizeMake(40,40) 
                                                                                                     action:nil];
            return cellController;
        }];

        CKFormTableViewController* form = [CKFormTableViewController controller];

        CKFormBindedCollectionSection* section = [CKFormBindedCollectionSection sectionWithCollection:timeline.tweets 
                                                                                              factory:tweetsFactory 
                                                                            appendSpinnerAsFooterCell:YES];
        [form addSections:[NSArray arrayWithObject:section]];
        return form;
    }

    @end

<p><b>Note:</b><i> AppCoreKit offers extremelly customizable views and cell controllers that can be setup using blocks wich avoids inheritance. As a good practice, we prefer using factory methods to setup view controllers instead of inheritance. That limits the developper to respect the scope offered by the controller class. It avoids errors and hacks. For example, the developper will not be able to add a bunch of booleans or properties that polute the code and creates connection between components that should be independant.</i></p>

<h2>Displaying the view controller</h2>

<p>In this sample, we'll only display this view controller in a navigation controller in the main window of the application. We create a Timeline singleton and the view controller displaying this timeline. Lets setup the Application delegate to do so:</b>

<i>AppDelegate.h</i>

    @interface AppDelegate : UIResponder < ApplicationDelegate >
    @property (strong, nonatomic) UIWindow *window;
    @end
        
<i>AppDelegate.m</i>

    @implementation AppDelegate
        
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
        Timeline* timeline = [Timeline sharedInstance];
        
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        self.window.rootViewController = [[[UINavigationController alloc]initWithRootViewController:
             [ViewControllers viewControllerForTimeline:timeline]]autorelease];
        [self.window makeKeyAndVisible];
        return YES;
    }
        
    @end
        
<p>We're done for the first part of the sample! We have a fully functionnal document and a form displaying the twitter timeline content asynchronously but we see nothing in the table view... Our document is empty, we need to get some data from the web.</b>


<img src="Twitter-sample-document-view.png"/>


<h2>Fetching data from the web</h2>

<p><b>AppCoreKit</b> provides a FeedSource mechanism. Connected to a Collection, collection view controllers are able to fetch range of data as needed (when scrolling for example). FeedSources provide an easy way to define where and how to retrieve our data with paging, and automatically populate document collections when they are connected together. That means, if your collection view controller displays a collection associated to a FeedSource, the UI Interface and your document collections will get synched at any time and get as much data as your FeedSource can provide, automatically and asynchronously.<p>
<p>WebSource is a particular FeedSource allowing data to be fetched using WebRequests. WebRequests are fully multi-threaded using GCD wich allow non-blocking requests.<p>
<p>Lets implements your first WebSource for the twitter public timeline. Like view controllers, we like to create FeedSources using factory methods instead inheritance using their block based interface.</p>
<p></p>
<p><b>AppCoreKit</b> provides helpers to build advanced WebRequests. We'll use one of these in this sample wich uses our Mappings system to convert the received JSON payload to an array of models defined in our document. This method will fetch the paged data from twitter. When the data gets received, it will automatically transform the data as a dictionary by parsing the JSON content. This dictionary is named rawData. The mappingContextIdentifier represents a collection of keypath to keypath conversions and class name for the instances we want to create.</p>
<p>Mappings can be defined in a .mappings file based on CascadingTree. CascadingTree is JSON file format allowing template definition, inheritance, imports and more. This is the base file format for mappings, stylesheets, object graphs and mock objects definition.</p>


<i>FeedSources.h</i>

    @interface FeedSources : NSObject
    + (CKFeedSource*)feedSourceForTweets;
    @end

<i>FeedSources.m</i>

    @implementation FeedSources

    + (CKFeedSource*)feedSourceForTweets{
        CKWebSource* webSource = [[[CKWebSource alloc]init]autorelease];
        webSource.requestBlock = ^(NSRange range){
            NSURL* tweetsAPIUrl = [NSURL URLWithString: @"https://api.twitter.com/1/statuses/public_timeline.json" ];
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%d",range.length],@"count",
                @"true",@"include_entities", 
                nil];

            CKWebRequest* request = [CKWebRequest requestForObjectsWithUrl:tweetsAPIUrl
                                                                    params:params
                                                                      body:nil
                                                  mappingContextIdentifier:@"$Tweet"
                                                          transformRawData:nil
                                                                completion:nil 
                                                                     error:nil];
           return request;
        };
        return webSource;
    }

    @end


<p>Now lets define the mappings.</b>
<p>The mapping system is based on runtime and our conversion technology. As we said previously, it allows to define keypath to keypath conversions and specify the class of instances we want to create. Here we have a simple example but this system allows much more complex transformations using custom transformer methods, objects and collection properties mapping and more.</p>

<i>TwitterTimeline.mappings</i>


    {
        "$Tweet" : {
            "@class" : "Tweet",
            "imageUrl" : "user.profile_image_url",
            "name" : "user.name",
            "message" : "text"
        }
    }

<p>We now need to load this file in the Mapping context manager. We generally do this when the appDelegate gets created. We also need to associate this FeedSource to our Timeline's Tweets collection.</p>


<i>AppDelegate.m</i>

    - (id)init{
        self = [super init];
        [CKMappingContext loadContentOfFileNamed:@"TwitterTimeline"];
        return self;
    }

    //Adds this when creating the Timeline Object
    Timeline* timeline = [Timeline sharedInstance];
    timeline.tweets.feedSource = [FeedSources feedSourceForTweets];


<p>We now have a fully functional twitter client application. The public timeline is displayed in subtitle style table view cells that are asynchronously created when data gets fetched from the web using paging. It's time to customize the appearance.</p>


<img src="Twitter-sample-web-source.png"/>


<h2>Customizing the appearance</h2>

<p><b>AppCoreKit</b> provides a CSS-like technology based on runtime, our conversion system and CascadingTree. This allows to target and customize any controllers, views and any of their properties that are KVC compliant. You can define templates that can be inherited by specific selectors targeting you objects. Objects can be targetted using class name or property name, and specialized using any of their property values. You don't need to write code as any of the <b>AppCoreKit</b> controllers and views are able to find their specific style and apply it to their hierarchy when needed.</p>
<p>When running the app in the simulator, as soon as you change and save a .style file, your application is automatically updated at runtime. This avoid to change/compile/run and saves a LOT of time especially when you're debugging a view controller that is deep in that navigation workflow. This mechanism is also integrated in any of our technologies based on CascadingTree, .string files and images loaded with imageNamed:.</p>
<p>As we want to target our view controller specifically in stylesheets, we'll set its name property that we generally use for this purpose.</p>

<i>ViewControllers.m</i>

    CKFormTableViewController* form = [CKFormTableViewController controller];
    form.name = @"Timeline";
    
<i>TwitterTimeline.style</i>

    {
        "$big_font" : {
            "fontSize" : 20
        },
    
        "$transparent" : {
            "backgroundColor" : "clearColor"
        },
    
        "$lightGradient" : {
            "backgroundGradientColors" : [ "0.986 0.986 0.986 1", "0.884 0.884 0.884 1" ],
            "backgroundGradientLocations" : [ "0","1" ],
            "embossTopColor" : "0.986 0.986 0.986 0.5",
            "embossBottomColor" : "whiteColor"
        },
    
        "UIViewController[name=Timeline]" : {
            "rowInsertAnimation" : "UITableViewRowAnimationTop",
            "style" : "UITableViewStyleGrouped",
    
            "tableView" : {
                "backgroundColor" : "blackColor"
            },
    
            "CKTableViewCellController" : {
                "cellStyle" : "CKTableViewCellStyleSubtitle2",
                "contentInsets" : "10 10 10 10",
                "UITableViewCell" : {
                    "backgroundView" : {
                        "@inherits" : [ "$lightGradient" ],
                        "borderColor" : "darkGrayColor",
                        "borderWidth" : 2
                    },
                    "textLabel,detailTextLabel" : {
                        "@inherits" : [ "$big_font", "$transparent" ]
                    },
                    "imageView" : {
                        "backgroundColor" : "blackColor",
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
    
        "$navigation_title_label" : {
            "fontName" : "Helvetica-Bold",
            "fontSize" : "18",
            "textColor" : "whiteColor"
        },
    
        "UINavigationController" : {
            "navigationBar" : {
                "backgroundImage" : "background_nav",
                "layer" : {
                    "shadowColor" : "blackColor",
                    "shadowRadius" : 4,
                    "shadowOffset" : "0 2",
                    "shadowOpacity" : "0.8"
                },
    
                "titleView" : {
                    "@inherits" : [ "$navigation_title_label" ],
                    "backgroundColor" : "clearColor",
                    "shadowColor" : "darkGrayColor",
                    "shadowOffset" : "0 -1"
                }
            }
        }
    }



<p>Lets load this file in the Style manager.</p>
    
    
<i>AppDelegate.m</i>
    
    - (id)init{
        self = [super init];
        [CKMappingContext loadContentOfFileNamed:@"TwitterTimeline"];
        [[CKStyleManager defaultManager]loadContentOfFileNamed:@"TwitterTimeline"];
        return self;
    }


<img src="Twitter-sample-stylesheet.png"/>


<h2>Refining the layout</h2>

<p>We'd like to have the image aligned on top left of the cells like classical twitter clients. <b>AppCoreKit</b> provides block based interface to customize layouts of cell controllers, compute its size dynamically, creates and setup its view hierarchy and more. In our previous viewController factory, lets add a piece of code when creating the table view cell controller as follow:</b>


<i>ViewControllers.m</i>

    [cellController setLayoutBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
        //This calls the standard layout method of cell controller.
        [controller performLayout]; 

        //This overrides the imageview frame.
        cell.imageView.frame = CGRectMake(controller.contentInsets.left,controller.contentInsets.top,40,40);
    }];


<img src="Twitter-sample-layout.png"/>


<h2>Localizing your Application</h2>

<p><b>AppCoreKit</b> provides helpers to localize your application easilly. There are two really nice features when using this system.</p>

 - First, .string files are also reloaded at runtime when you save it. Like stylesheets, mappings, object graphs or mock files, you can run the app in the simulator, edit your files in XCode and see the changes instantaneously at runtime.
 - Second, our system allows to change the language at runtime just by setting the language property of the CKLocalizationManager.

<p>Lets add a localized title to our view controller</p>

<i>ViewControllers.m</i>

    CKFormTableViewController* form = [CKFormTableViewController controller];
    form.title = _(@"kTimelineTitle");

<i>TwitterTimeline.strings</i>

    "kTimelineTitle" = "Timeline  Public";


<img src="Twitter-sample-localization.png"/>

