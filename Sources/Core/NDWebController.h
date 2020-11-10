//
//  NDWebController.h
//  NDWebKit
//
//  Created by Nguyen Duc Hiep on 6/24/20.
//  Copyright © 2020 Nguyen Duc Hiep. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDWebController : NSObject

@property(nonatomic, readonly, strong) WKWebView* webView;

@property(nonatomic, copy, nullable) void (^contenSizeValueChangedHandler)
    (__kindof NDWebController*, CGSize);
@property(nonatomic, copy, nullable) void (^canGoBackValueChangedHandler)
    (__kindof NDWebController*, BOOL);
@property(nonatomic, copy, nullable) void (^canGoForwardValueChangedHandler)
    (__kindof NDWebController*, BOOL);

// MARK: - webView's navigationDelegate handlers
/*! @abstract Decides whether to allow or cancel a navigation.
@param webView The web view invoking the delegate method.
@param navigationAction Descriptive information about the action
triggering the navigation request.
@param decisionHandler The decision handler to call to allow or cancel the
navigation. The argument is one of the constants of the enumerated type
WKNavigationActionPolicy.
@discussion If you do not implement this method, the web view will load the
request or, if appropriate, forward it to another application.
*/
@property(nonatomic, copy, nullable)
    void (^decidePolicyForNavigationActionDecisionHandlerHandler)
        (__kindof NDWebController*,
         WKNavigationAction*,
         void (^)(WKNavigationActionPolicy));

/*! @abstract Decides whether to allow or cancel a navigation after its
response is known.
@param webView The web view invoking the delegate method.
@param navigationResponse Descriptive information about the navigation
response.
@param decisionHandler The decision handler to call to allow or cancel the
navigation. The argument is one of the constants of the enumerated type
WKNavigationResponsePolicy.
@discussion If you do not implement this method, the web view will allow the
response, if the web view can show it.
*/
@property(nonatomic, copy, nullable)
    void (^decidePolicyForNavigationResponseDecisionHandlerHandler)
        (__kindof NDWebController*,
         WKNavigationResponse*,
         void (^)(WKNavigationResponsePolicy));

/*! @abstract Invoked when a main frame navigation starts.
@param webView The web view invoking the delegate method.
@param navigation The navigation.
*/
@property(nonatomic, copy, nullable)
    void (^didStartProvisionalNavigationHandler)
        (__kindof NDWebController*, WKNavigation* _Null_unspecified);

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
@property(nonatomic, copy, nullable)
    void (^didReceiveServerRedirectForProvisionalNavigationHandler)
        (__kindof NDWebController*, WKNavigation* _Null_unspecified);

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
@property(nonatomic, copy, nullable)
    void (^didFailProvisionalNavigationWithErrorHandler)
        (__kindof NDWebController*, WKNavigation* _Null_unspecified, NSError*);

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
@property(nonatomic, copy, nullable) void (^didCommitNavigationHandler)
    (__kindof NDWebController*, WKNavigation* _Null_unspecified);

/*! @abstract Invoked when a main frame navigation completes.
@param webView The web view invoking the delegate method.
@param navigation The navigation.
*/
@property(nonatomic, copy, nullable) void (^didFinishNavigationHandler)
    (__kindof NDWebController*, WKNavigation* _Null_unspecified);

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
// MARK: didFailNavigationWithErrorHandler
@property(nonatomic, copy, nullable) void (^didFailNavigationWithErrorHandler)
    (__kindof NDWebController*, WKNavigation* _Null_unspecified, NSError*);

/*! @abstract Invoked when the web view needs to respond to an authentication
 challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to
 the challenge. The disposition argument is one of the constants of the
 enumerated type NSURLSessionAuthChallengeDisposition. When disposition is
 NSURLSessionAuthChallengeUseCredential, the credential argument is the
 credential to use, or nil to indicate continuing without a credential.
 @discussion If you do not implement this method, the web view will respond to
 the authentication challenge with the
 NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
// MARK: didReceiveAuthenticationChallengeCompletionHandlerHandler
@property(nonatomic, copy, nullable)
    void (^didReceiveAuthenticationChallengeCompletionHandlerHandler)
        (__kindof NDWebController*,
         NSURLAuthenticationChallenge*,
         void (^)
             (NSURLSessionAuthChallengeDisposition, NSURLCredential* _Nullable))
            ;

/*! @abstract Invoked when the web view's web content process is terminated.
@param webView The web view whose underlying web content process was terminated.
*/
@property(nonatomic, copy, nullable)
    void (^webContentProcessDidTerminateHandler)(__kindof NDWebController*);

// MARK: - webView's uiDelegate handlers
/*! @abstract Creates a new web view.
@param webView The web view invoking the delegate method.
@param configuration The configuration to use when creating the new web
view. This configuration is a copy of webView.configuration.
@param navigationAction The navigation action causing the new web view to
be created.
@param windowFeatures Window features requested by the webpage.
@result A new web view or nil.
@discussion The web view returned must be created with the specified
configuration. WebKit will load the request in the returned web view.

If you do not implement this method, the web view will cancel the navigation.
*/
@property(nonatomic, copy, nullable) WKWebView* _Nullable (
    ^createWebViewWithConfigurationForNavigationActionWindowFeaturesHandler)
    (__kindof NDWebController*,
     WKWebViewConfiguration*,
     WKNavigationAction*,
     WKWindowFeatures*);

// MARK: - script message handlers
- (void)setMessageHandlerWithName:(NSString*)name
                          handler:(void (^_Nullable)(__kindof NDWebController*,
                                                     WKScriptMessage*))handler
    NS_SWIFT_NAME(setMessageHandler(name:handler:));

// MARK: - webView's scroll delegate handlers
/// any offset changes
@property(nonatomic, copy) void (^_Nullable didScrollHandler)
    (__kindof NDWebController*);

/// any zoom scale changes
@property(nonatomic, copy) void (^_Nullable didZoomHandler)
    (__kindof NDWebController*);

/// called on start of dragging (may require some time and or distance to move)
@property(nonatomic, copy) void (^_Nullable willBeginDraggingHandler)
    (__kindof NDWebController*);

/// called on finger up if the user dragged. velocity is in points/millisecond.
/// targetContentOffset may be changed to adjust where the scroll view comes to
/// rest
@property(nonatomic, copy)
    void (^_Nullable willEndDraggingWithVelocityTargetContentOffsetHandler)
        (__kindof NDWebController*, CGPoint, CGPoint*);

/// called on finger up if the user dragged. decelerate is true if it will
/// continue moving afterwards
@property(nonatomic, copy) void (^_Nullable didEndDraggingWillDecelerateHandler)
    (__kindof NDWebController*, BOOL);

/// called on finger up as we are moving
@property(nonatomic, copy) void (^_Nullable willBeginDeceleratingHandler)
    (__kindof NDWebController*);

/// called when scroll view grinds to a halt
@property(nonatomic, copy) void (^_Nullable didEndDeceleratingHandler)
    (__kindof NDWebController*);

/// called when setContentOffset/scrollRectVisible:animated: finishes. not
/// called if not animating
@property(nonatomic, copy) void (^_Nullable didEndScrollingAnimationHandler)
    (__kindof NDWebController*);

/// return a view that will be scaled. if delegate returns nil, nothing happens
@property(nonatomic, copy) UIView* _Nullable (^_Nullable viewForZoomingHandler)
    (__kindof NDWebController*);

/// called before the scroll view begins zooming its content
@property(nonatomic, copy) void (^_Nullable willBeginZoomingWithViewHandler)
    (__kindof NDWebController*, UIView* _Nullable);

/// scale between minimum and maximum. called after any 'bounce' animations
@property(nonatomic, copy) void (^_Nullable didEndZoomingWithViewAtScaleHandler)
    (__kindof NDWebController*, UIView* _Nullable, CGFloat);

/// return a yes if you want to scroll to the top. if not defined, assumes YES
@property(nonatomic, copy) BOOL (^_Nullable shouldScrollToTopHandler)
    (__kindof NDWebController*);

/// called when scrolling animation finished. may be called immediately if
/// already at top
@property(nonatomic, copy) void (^_Nullable didScrollToTopHandler)
    (__kindof NDWebController*);

/// Also see -[UIScrollView adjustedContentInsetDidChange]
@property(nonatomic, copy)
    void (^_Nullable didChangeAdjustedContentInsetHandler)
        (__kindof NDWebController*);

- (void)executeScriptWithString:(NSString*)string;
- (void)executeScriptWithURL:(NSURL*)url;
- (void)executeScriptWithURLs:(NSArray<NSURL*>*)urls;
- (void)executeScriptWithResourceNamed:(NSString*)name;
- (void)executeScriptWithResourceNameds:(NSArray<NSString*>*)names;
- (void)insertCssWithString:(NSString*)string;
- (void)insertCssWithURL:(NSURL*)url;
- (void)insertCssWithURLs:(NSArray<NSURL*>*)urls;
- (void)insertCssWithResourceNamed:(NSString*)name;
- (void)insertCssWithResourceNameds:(NSArray<NSString*>*)names;

@end

NS_ASSUME_NONNULL_END
