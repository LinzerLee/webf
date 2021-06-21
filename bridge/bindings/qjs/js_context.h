/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include <memory>
#include "kraken_foundation.h"
#include <quickjs/quickjs.h>

using QjsContext = JSContext;
using QjsRuntime = JSRuntime;

namespace kraken::binding::qjs {

class JSContext {
public:
  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  KRAKEN_EXPORT bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  KRAKEN_EXPORT bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);

  KRAKEN_EXPORT bool isValid();

  KRAKEN_EXPORT JSValue global();
  KRAKEN_EXPORT QjsContext* context();

  KRAKEN_EXPORT int32_t getContextId();

  KRAKEN_EXPORT void *getOwner();

  KRAKEN_EXPORT bool handleException(JSValue *exc);

  KRAKEN_EXPORT void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  QjsContext *m_ctx{nullptr};
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);

}


#endif // KRAKENBRIDGE_JS_CONTEXT_H
