<h2>Summary</h2>

<b>AppCoreKit</b> is a library of object-oriented reusable components and an application framework for the iOS platform.

<h3>Motivations</h3>

<p>Developing applications for the iOS platform is a tedious task that takes a lot of time. The iOS framework, even though powerful, offers a lot of features, technologies and components but does not offer a comprehensible, high-level framework for creating applications.</p>
<p>As a results, developers have to put a lot of effort in managing data, resources, assembling the user interface elements and managing the flow of the application.</p>
<p>The goal of the <b>AppCoreKit</b> Framework is to reduce the development time and encourage the reuse of components by providing a technology stack that does the heavy-lifting in all areas needed to creating a full-featured application.</p>

<h3>Non Goals</h3>

<b>AppCoreKit</b> is not designed to solve cross-platform issues (an application won’t run on the Android platform).

<h3>Architecture</h3>

<p>The App/CoreKit architecture is composed of four categories of technologies: Foundations, Networking, Data Management, User Interface and Application Logic.</p>

<img src="Docs/Documentation/CloudKitArchitecture102011.png"/>

<h2>Foundations</h2>

<h3>Support Additions</h3>

<p>Basic additions to the Cocoa Foundations. These additions includes such things as date conversions, string conversions, encodings (ex.: Base64).</p>

<h3>Weak References</h3>

<p>Weak References defines a weak association between two objects. When an object participating in a weak association is deallocated by the Objective-C runtime, the Weak Reference is set to NIL.</p>
<p>The Objective-C framework (until iOS 5.0) does not natively supports this feature, this addition is important to avoid crashing the application if the program tries to access a deallocated objects.</p>
<p>The other interesting feature of the Weak Reference is that it can execute code at the moment of the target object is deallocated.</p>

<h3>Introspection Additions</h3>

<p>Unlike C and C++, Objective-C is a run-time based language. This runtime allows application to change the behavior of programs while running (ex.: changing methods implementation) or discovering and accessing objects properties. These additions simplifies the access to these features and serves as an object-oriented abstraction on top of the runtime system (the runtime system as a C API).</p>
<p>This system also adds Property extended attributes. Extended attributes are an additional set of information linked to a property and that can serve as hints for other part of the system (ex.: hints on how to display this property).</p>

<h3>Cascading Tree</h3>

<p>The Cascading Tree (CT) is a file-format based on the JSON format which allows to generate complex dictionaries (key/value) hierarchies. The CT supports such things as imports, inheritance and templates.</p>
<p>The CT is our basic data format and is used to implement the Object Graph, Mappings and Styles.</p>

<h3>Object Graph</h3>

<p>The Object Graph is a specialization of the Cascading Tree and allow the generation of complex hierarchies of Cocoa Objects (NSObjects). These objects can be of any kind but a classic use case is to generate hierarchies of UIViews.</p>

<h3>Object Mappings</h3>

<p>The role of Object Mappings is to convert a tree of objects to another tree of objects using automatic type conversion if necessary.</p>
<p>The standard use case of Object Mappings is converting a hierarchy of dictionaries to a hierarchy of typed objects.</p>

<h3>Object Bindings</h3>

<p>The Object Bindings allows to “bind” and “synchronize” the property of one object to another. If the property of the former changes at runtime, the property of the later will be updated accordingly, using automatic type conversion if necessary.</p>
<p>Object Bindings are especially useful in the context of the MVC (Model-View-Controller) patterns, where a view (ex.: a label) should reflect the value of a model.</p>

<h3>Conversions</h3>

<p>The Object Conversions are a set of “transformer” functions with a common interface which allows to convert one type to another (ex.: a number to a string, a string representing an URL to a valid NSURL object).</p>
<p>This is especially used by the Object Mappings and the Object Bindings.</p>


<h3>3rd Party Parsers</h3>

<p>For convenience, the Foundation also contains popular Open Source implementation of parsers for JSON and XML formats.</p>

<h2>Data Management</h2>

<h3>Model Objects</h3>

<p>The Model Objects (CKObject) are an implementation of the Value Object pattern. The Model Object automate a number of cumbersome tasks for the developers when implementing such pattern:<i> automated deallocation of referenced objects, automated copy and deep copy, automated serialization/deserialization/migration, or model validation via predicates.</i></p>


<h3>Feed Sources</h3>

<p>Feed Sources provides a common interface to fetch objects from a source. Such source can be the network, or a database. The interface of a Feed Source is asynchronous by design, meaning that the caller will be notified when new objects are available.</p>

<h3>Document and Collections</h3>

<p>The Document provides a central place for the application to hold a collections of Model Objects in use (ex.: a list of items to be displayed). The collections are an abstraction to the storage and fetching of Model Objects.</p>


<h3>Persistent Key/Value Store</h3>

<p>The Persistent Key/Value Store (CKStore) is a simple storage solution to store key/value as strings in a local database. These key/value are associated to items, who are associated to domains.</p>
<p>The CKStore provides a simple and easy way to store information (and serialize objects) without having to specify a static SQL schema. The KVS can be queried for specific properties in order to fetch items.</p>

<h3>Core Data Additions</h3>

<p>Additions to ease the configuration and setup of a Core Data backed-database.</p>


<h2>Networking</h2>

<h3>Web Requests</h3>

<p>Web Requests abstracts the issue of doing HTTP requests through the network. This implementation sits on top of Cocoa Networking classes and provide a better and ease to use programming interface.</p>
<p>Web Requests are multithreaded and handles the heaving lifting of creating the underlying network calls, managing authentication, getting back the results and parsing the response in a comprehensible format by the application (ex.: JSON, XML or an image).</p>

<h3>Web Services</h3>

<p>Web Services provides a programming interface for creating “facade” to Web API (ex.: Twitter). The Web Services itself has no concrete implementation, but it provides the building blocks for the developer to create it custom implementation.</p>

<h3>Web Sources</h3>

<p>Web Sources are an implementation of Feed Sources. They provides an abstraction for getting objects from the network. Web Sources provides the building blocks for creating Objective-C objects from responses of HTTP requests. It works with Web Services.</p>



<h2>User Interface</h2>

<h3>Custom UI Components</h3>

<p>The framework provides some custom UI components that are often required in application but not found in the Cocoa Touch Framework. These components includes: custom controls, custom alerts view, sheets, splitter, etc.</p>
<p>Some UI components also include custom controllers (in the MVC pattern) ready to be used in the application (ex.: Web View Controller).</p>

<h3>Collection View Controller</h3>

<p>The Collection View Controller is an abstraction (and a set of inherited classes) that ease the management and display of items. The Collection View Controller acts as a middleman between the models representing the data and the actual representation on the screen.</p>
<p>￼Collection View Controllers have different implementation and can control the display of data in a table, a grid, a carousel or a map with an unified interface based on cell controllers. This programming interface is designed to be extensible, so that only the way data is represented can be changed, or the underlying storage without impacting each other.</p>
<p>Please refer to the Application Architecture Summary below for more informations on how these components interact with each other.</p>


<h3>Forms</h3>


<p>Forms are a programming interface for creating forms and tables where the data represented can change dynamically. The Cocoa Touch framework provides a low-level programming interface and UI components to display information in a table. Unfortunately, these components are complicated to use, even though they are probably the most widely used of the framework.</p>
<p>Forms abstract all the complexity for managing such tables. Using Data Management and Model Controllers, Forms provides an easy to use interface for creating and interacting with tables. They do all the heavy-lifting for display hierarchies of items (via sections), display cells of variable height or managing interaction with the table (ex.: responses to touch events).</p>
<p>Forms also provide a collection of ready to use cells for displaying standard text or images.</p>

<h3>Property Grids</h3>

<p>Property Grids are Forms specialized in displaying an object (NSObject or Model Object) automatically. By using the introspection mechanics of the framework, Property Grids detects the type of each properties of an object and will automatically generate a form to display and edit the information.</p>
<p>Using Property Extended attributes and stylesheets, the developer can give hints on how this property should be displayed.</p>
<p>This is a very convenient framework to quickly display information represented by an object without having to manage anything from the display perspective.</p>
<p>According to the access type of properties (ex.: read only or read write), a Property Grid will automatically support the edition of such properties by presenting the user with a control specialized (ex.: text view, date picker).</p>

<h3>Cascading Stylesheets</h3>

<p>Customizing the appearance (ex.: colors, background images) of an iOS application is complex. The Cocoa Touch lacks the interface and the flexibility to do so. Most of the time, the developer has to use custom API to achieve customization.</p>
<p>Cascading Stylesheets abstracts this complexity by decoupling the code from the definition of the style itself.</p>
<p>Cascading Stylesheets are similar system to the one found in web browser technologies (CSS). Styles are defined in a file format (see Cascading Tree) organized in hierarchy, from the most general to the more specialized. UI components can be “selected” for customization by class or properties value so that the style can be applied accordingly. As it is based on runtime, any property that is KVC complient can be used as a filter to specialize the selector for a style.</p>
<p>Cascading Stylesheets are a very flexible system that avoid custom code for customizing the appearance of the user interface. Styles can be reused between application and templates can be created to avoid duplication of the same information.</p>
<p>Contrary to the CSS found in web browser, Cascading Stylesheet are actually more flexible and allow the developer to basically change any property of the object “selected.” Even though used primary for styling, they can be used to “configure” objects.</p>


<h3>Object Inspectors</h3>

<p>Object Inspectors (Inline Debugger) are a debugging tool that can be called on any object and have its properties displayed and editable in a Property Grids. Since any object can be represented (and edited) at runtime, Object Inspectors are particularly useful to debug information about views. A quick access to view controller, view and class hierarchy as well as applied stylesheet gives the power to quickly and easilly isolate where your problem is.</p>


<h2>Application Architecture</h2>

<p><b>AppCoreKit</b> provides helpers to easilly manage redondant tasks. Here is a summary on how things can be assembled together to manage complex behaviour such as displaying a collection of objects that is asynchronously populated from the web. You just need to assemble (describe) how the objects should be represented and all the updates will get done automatically as described bellow:

<img src="Docs/Documentation/CloudKitApplicationArchitecture.png"  WIDTH="1024" HEIGHT="470" />

<p>Here is a Sample code illustrating this architecture</p>
