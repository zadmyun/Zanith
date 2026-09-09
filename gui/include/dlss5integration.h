#pragma once

#include <QString>

namespace Dlss5Integration
{
// Loads the local full-add-on ReShade runtime before any graphics API is
// initialised. The module stays loaded until process termination because the
// add-ons keep hooks and GPU resources alive for the lifetime of the app.
void initialize();

bool runtimeAvailable();
bool runtimeLoaded();
QString status();
bool bridgeAvailable();
bool setTechniqueEnabled(const char *effect, const char *technique, bool enabled);
bool setUniformFloat(const char *effect, const char *name, float value);
bool toggleNeuralRendering();
QString getRenoDxConfig(const char *key, const char *fallback);
bool setRenoDxConfig(const char *key, const char *value);
}
