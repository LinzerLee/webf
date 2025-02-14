/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_API_API_H_
#define WEBF_CORE_API_API_H_

#include <cassert>
#include "include/webf_bridge.h"

namespace webf {

void evaluateScriptsInternal(void* page_,
                             const char* code,
                             uint64_t code_len,
                             uint8_t** parsed_bytecodes,
                             uint64_t* bytecode_len,
                             const char* bundleFilename,
                             int32_t startLine,
                             Dart_Handle dart_handle,
                             EvaluateScriptsCallback result_callback);

void evaluateQuickjsByteCodeInternal(void* page_,
                                     uint8_t* bytes,
                                     int32_t byteLen,
                                     Dart_PersistentHandle persistent_handle,
                                     EvaluateQuickjsByteCodeCallback result_callback);
void parseHTMLInternal(void* page_, const char* code, int32_t length);

void invokeModuleEventInternal(void* page_,
                               void* module_name,
                               const char* eventType,
                               void* event,
                               void* extra,
                               Dart_Handle dart_handle,
                               InvokeModuleEventCallback result_callback);

}  // namespace webf

#endif  // WEBF_CORE_API_API_H_
