//
//  NDWebController.mm
//  NDWebKit
//
//  Created by Nguyen Duc Hiep on 6/24/20.
//  Copyright © 2020 Nguyen Duc Hiep. All rights reserved.
//

#import <NDWebKit/NDWebController.h>

#import <NDLog/NDLog.h>
#import <NDModificationOperators/NDModificationOperators.h>
#import <NDUtils/NDUtils.h>
#import <NDWebKit/NSString+NDWebKit.h>

using namespace nd::objc;

@interface NDWebController () <WKNavigationDelegate,
                               WKScriptMessageHandler,
                               UIScrollViewDelegate>
@end

@implementation NDWebController {
  id<NSObject> _contentSizeObservation;
  id<NSObject> _canGoBackObservation;
  id<NSObject> _canGoForwardObservation;
  NSMutableDictionary<NSString*,
                      void (^)(__kindof NDWebController*, WKScriptMessage*)>*
      _messageHandlers;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _webView = [[WKWebView alloc]
        initWithFrame:CGRectZero
        configuration:[[[WKWebViewConfiguration alloc]
                          init] nd_modify:^(WKWebViewConfiguration* config) {
          config.websiteDataStore = WKWebsiteDataStore.defaultDataStore;
        }]];
    _webView.navigationDelegate = self;
    _messageHandlers = [[NSMutableDictionary alloc] init];

    _webView.scrollView.delegate = self;
  }
  return self;
}

// MARK:- contenSizeValueChangedHandler
- (void)setContenSizeValueChangedHandler:
    (void (^)(__kindof NDWebController*, CGSize))contenSizeValueChangedHandler {
  if (SameOrEquals(contenSizeValueChangedHandler,
                   self.contenSizeValueChangedHandler)) {
    return;
  }

  _contenSizeValueChangedHandler = [contenSizeValueChangedHandler copy];

  if (contenSizeValueChangedHandler) {
    @weakify(self);
    _contentSizeObservation = [self.webView.scrollView
        nd_observeKeyPath:NSStringFromSelector(@selector(contentSize))
                  options:kNilOptions
            changeHandler:^(id obj, NSDictionary*) {
              @strongify(self);
              if (!self || obj != self.webView.scrollView) {
                return;
              }
              NDCallIfCan(self.contenSizeValueChangedHandler, self,
                          self.webView.scrollView.contentSize);
            }];
  } else {
    _contentSizeObservation = nil;
  }
}

// MARK:- canGoBackValueChangedHandler
- (void)setCanGoBackValueChangedHandler:
    (void (^)(__kindof NDWebController*, BOOL))canGoBackValueChangedHandler {
  if (SameOrEquals(canGoBackValueChangedHandler,
                   self.canGoBackValueChangedHandler)) {
    return;
  }

  _canGoBackValueChangedHandler = [canGoBackValueChangedHandler copy];

  if (canGoBackValueChangedHandler) {
    @weakify(self);
    _canGoBackObservation = [self.webView
        nd_observeKeyPath:NSStringFromSelector(@selector(canGoBack))
                  options:kNilOptions
            changeHandler:^(id obj, NSDictionary*) {
              @strongify(self);
              if (!self || obj != self.webView) {
                return;
              }
              NDCallIfCan(self.canGoBackValueChangedHandler, self,
                          self.webView.canGoBack);
            }];
  } else {
    _canGoBackObservation = nil;
  }
}

// MARK:- canGoForwardValueChangedHandler
- (void)setCanGoForwardValueChangedHandler:
    (void (^)(__kindof NDWebController*, BOOL))canGoForwardValueChangedHandler {
  if (SameOrEquals(canGoForwardValueChangedHandler,
                   self.canGoForwardValueChangedHandler)) {
    return;
  }

  _canGoForwardValueChangedHandler = [canGoForwardValueChangedHandler copy];

  if (canGoForwardValueChangedHandler) {
    @weakify(self);
    _canGoForwardObservation = [self.webView
        nd_observeKeyPath:NSStringFromSelector(@selector(canGoForward))
                  options:kNilOptions
            changeHandler:^(id obj, NSDictionary*) {
              @strongify(self);
              if (!self || obj != self.webView) {
                return;
              }
              NDCallIfCan(self.canGoForwardValueChangedHandler, self,
                          self.webView.canGoForward);
            }];
  } else {
    _canGoForwardObservation = nil;
  }
}

// MARK: - setMessageHandler
- (void)setMessageHandlerWithName:(NSString*)name
                          handler:(void (^)(__kindof NDWebController*,
                                            WKScriptMessage*))handler {
  if (!name) {
    NDAssertionFailure(@"Can not setMessageHandler with name: '%@'.", name);
    return;
  }

  if (SameOrEquals(_messageHandlers[name], handler)) {
    return;
  }

  if (handler) {
    [self.webView.configuration.userContentController
        addScriptMessageHandler:self
                           name:name];
  } else {
    [self.webView.configuration.userContentController
        removeScriptMessageHandlerForName:name];
  }
  _messageHandlers[name] = handler;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
  if (self.webView.configuration.userContentController !=
      userContentController) {
    NDAssertionFailure(@"Misused of '%@' as '%@' scriptMessageHandler.", self,
                       userContentController);
    return;
  }
  NDCallIfCan(_messageHandlers[message.name], self, message);
}

// MARK: - didFinishNavigationHandler
- (void)webView:(WKWebView*)webView
    didFinishNavigation:(WKNavigation*)navigation {
  if (self.webView != webView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' navigationDelegate.", self,
                       webView);
    return;
  }
  NDCallIfCan(self.didFinishNavigationHandler, self, navigation);
}

// MARK: - decidePolicyForNavigationActionHandler
- (void)webView:(WKWebView*)webView
    decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:
                        (void (^)(WKNavigationActionPolicy))decisionHandler {
  if (self.webView != webView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' navigationDelegate.", self,
                       webView);
    decisionHandler(WKNavigationActionPolicyAllow);
  } else {
    NDCallAndReturnIfCan(self.decidePolicyForNavigationActionHandler, self,
                         navigationAction, decisionHandler);
  }

  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView*)webView
    didFailProvisionalNavigation:(WKNavigation*)navigation
                       withError:(NSError*)error {
  if (self.webView != webView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' navigationDelegate.", self,
                       webView);
    return;
  }
  NDCallAndReturnIfCan(self.didFailProvisionalNavigationWithErrorHandler, self,
                       navigation, error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView*)webView {
  if (self.webView != webView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' navigationDelegate.", self,
                       webView);
    return;
  }
  NDCallAndReturnIfCan(self.webContentProcessDidTerminateHandler, self);
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didScrollHandler, self);
  }
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didZoomHandler, self);
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.willBeginDraggingHandler, self);
  }
}

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint*)targetContentOffset {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(
        self.willEndDraggingWithVelocityTargetContentOffsetHandler, self,
        velocity, targetContentOffset);
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didEndDraggingWillDecelerateHandler, self,
                         decelerate);
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.willBeginDeceleratingHandler, self);
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didEndDeceleratingHandler, self);
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didEndScrollingAnimationHandler, self);
  }
}

- (nullable UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.viewForZoomingHandler, self);
  }
  return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView*)scrollView
                          withView:(nullable UIView*)view {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.willBeginZoomingWithViewHandler, self, view);
  }
}
- (void)scrollViewDidEndZooming:(UIScrollView*)scrollView
                       withView:(nullable UIView*)view
                        atScale:(CGFloat)scale {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didEndZoomingWithViewAtScaleHandler, self, view,
                         scale);
  }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.shouldScrollToTopHandler, self);
  }
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didScrollToTopHandler, self);
  }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView*)scrollView {
  if (self.webView.scrollView != scrollView) {
    NDAssertionFailure(@"Misused of '%@' as '%@' delegate.", self, scrollView);
  } else {
    NDCallAndReturnIfCan(self.didChangeAdjustedContentInsetHandler, self);
  }
}

// MARK: - executeScript
- (void)executeScriptWithString:(NSString*)string {
  if (!string) {
    NDAssertionFailure(@"Can not excute script with string: '%@'.", string);
    return;
  }

  [self.webView
      evaluateJavaScript:string
       completionHandler:^(id, NSError* error) {
         if (error) {
           NDLogInfo(@"Excute script: '%@', error: '%@'.", string, error);
         }
       }];
}

- (void)executeScriptWithURL:(NSURL*)url {
  if (!url) {
    NDAssertionFailure(@"Can not excute script with url: '%@'.", url);
    return;
  }

  NSError* err = nil;
  auto string = [NSString stringWithContentsOfURL:url
                                     usedEncoding:nullptr
                                            error:&err];
  if (string && !err) {
    [self executeScriptWithString:string];
  } else {
    NDLogInfo(@"Can not fetch from url: '%@', string: '%@' error: '%@'.", url,
              string, err);
  }
}

- (void)executeScriptWithURLs:(NSArray<NSURL*>*)urls {
  if (!urls) {
    NDAssertionFailure(@"Can not excute script with urls: '%@'.", urls);
    return;
  }

  [urls enumerateObjectsUsingBlock:^(NSURL* url, NSUInteger, BOOL*) {
    [self executeScriptWithURL:url];
  }];
}

- (void)executeScriptWithResourceNamed:(NSString*)name {
  if (!name) {
    NDAssertionFailure(@"Can not excute script with resource name: '%@'.",
                       name);
    return;
  }

  [self executeScriptWithString:[NSString nd_stringNamed:name]];
}

- (void)executeScriptWithResourceNameds:(NSArray<NSString*>*)names {
  if (!names) {
    NDAssertionFailure(@"Can not excute script with resource names: '%@'.",
                       names);
    return;
  }

  [names enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger, BOOL*) {
    [self executeScriptWithResourceNamed:obj];
  }];
}

// MARK: - insertCss
- (void)insertCssWithString:(NSString*)string {
  if (!string) {
    NDAssertionFailure(@"Can not insert css with string: '%@'.", string);
    return;
  }

  [self executeScriptWithString:
            [NSString stringWithFormat:
                          @"(function() {\n"
                          @"  let style = document.createElement('style');\n"
                          @"  style.innerHTML = %@;\n"
                          @"  document.head.appendChild(style);\n"
                          @"})();",
                          string.nd_jsEquivalent]];
}

- (void)insertCssWithURL:(NSURL*)url {
  if (!url) {
    NDAssertionFailure(@"Can not insert css with url: '%@'.", url);
    return;
  }

  NSError* err = nil;
  auto string = [NSString stringWithContentsOfURL:url
                                     usedEncoding:nullptr
                                            error:&err];
  if (string && !err) {
    [self insertCssWithString:string];
  } else {
    NDLogInfo(@"Can not fetch from url: '%@', string: '%@' error: '%@'.", url,
              string, err);
  }
}

- (void)insertCssWithURLs:(NSArray<NSURL*>*)urls {
  if (!urls) {
    NDAssertionFailure(@"Can not insert css with urls: '%@'.", urls);
    return;
  }

  [urls enumerateObjectsUsingBlock:^(NSURL* url, NSUInteger, BOOL*) {
    [self insertCssWithURL:url];
  }];
}

- (void)insertCssWithResourceNamed:(NSString*)name {
  if (!name) {
    NDAssertionFailure(@"Can not insert css with resource name: '%@'.", name);
    return;
  }

  [self insertCssWithString:[NSString nd_stringNamed:name]];
}

- (void)insertCssWithResourceNameds:(NSArray<NSString*>*)names {
  if (!names) {
    NDAssertionFailure(@"Can not insert css with resource names: '%@'.", names);
    return;
  }

  [names enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger, BOOL*) {
    [self insertCssWithResourceNamed:obj];
  }];
}

@end
