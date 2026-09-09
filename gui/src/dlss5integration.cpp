#include "dlss5integration.h"

#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <cstring>

#if defined(Q_OS_WIN)
#include <windows.h>
#endif

namespace
{
bool g_runtime_available = false;
bool g_runtime_loaded = false;
QString g_status = QStringLiteral("Indisponivel nesta plataforma");

#if defined(Q_OS_WIN)
HMODULE g_reshade_module = nullptr;

QString executableDirectory()
{
    std::wstring path(32768, L'\0');
    const DWORD length = GetModuleFileNameW(nullptr, path.data(), static_cast<DWORD>(path.size()));
    if (length == 0 || length >= path.size())
        return {};
    path.resize(length);
    return QFileInfo(QString::fromStdWString(path)).absolutePath();
}
#endif
}

namespace Dlss5Integration
{
#if defined(Q_OS_WIN)
namespace
{
constexpr uint32_t kCommandFloat = 2;
constexpr uint32_t kCommandTechnique = 4;
constexpr uint32_t kCommandNeuralToggle = 6;
constexpr size_t kNameSize = 64;

struct BridgeCommand {
    uint32_t structSize;
    uint32_t type;
    char effect[kNameSize];
    char name[kNameSize];
    uint32_t count;
    int32_t integers[4];
    float floats[4];
};

using BridgeSubmit = int (*)(const BridgeCommand *);

BridgeSubmit bridgeSubmit()
{
    HMODULE bridge = GetModuleHandleW(L"dlss5-bridge.addon64");
    return bridge ? reinterpret_cast<BridgeSubmit>(GetProcAddress(bridge, "DLSS5Bridge_Submit")) : nullptr;
}

void copyName(char (&target)[kNameSize], const char *source)
{
    memset(target, 0, sizeof(target));
    if (source)
        std::strncpy(target, source, kNameSize - 1);
}

bool submit(uint32_t type, const char *effect, const char *name, bool enabled, float value)
{
    BridgeSubmit function = bridgeSubmit();
    if (!function)
        return false;
    BridgeCommand command {};
    command.structSize = sizeof(command);
    command.type = type;
    command.count = 1;
    command.integers[0] = enabled ? 1 : 0;
    command.floats[0] = value;
    copyName(command.effect, effect);
    copyName(command.name, name);
    return function(&command) != 0;
}
}
#endif

void initialize()
{
#if defined(Q_OS_WIN)
    if (qEnvironmentVariableIntValue("ZANIT_DISABLE_DLSS5") != 0) {
        g_status = QStringLiteral("Desativado por ZANIT_DISABLE_DLSS5");
        return;
    }

    const QString base = executableDirectory();
    if (base.isEmpty()) {
        g_status = QStringLiteral("Nao foi possivel localizar a pasta do Zanit");
        return;
    }

    const QStringList required = {
        QStringLiteral("dxgi.dll"),
        QStringLiteral("dlss5-bridge.addon64"),
        QStringLiteral("dlss5-feed.addon64"),
        QStringLiteral("renodx-dlss5.addon64"),
        QStringLiteral("nvngx_dlss.dll"),
        QStringLiteral("nvngx_dlssnr.dll"),
        QStringLiteral("ReShade.ini"),
        QStringLiteral("EnzoDLSS5.ini"),
        QStringLiteral("dlss5-feed.cfg"),
        QStringLiteral("reshade-shaders/Shaders/DLSS5_Feed.fx"),
        QStringLiteral("reshade-shaders/Shaders/lumenite_Kernel.fx")
    };

    QStringList missing;
    const QDir dir(base);
    for (const QString &relative : required) {
        if (!QFileInfo::exists(dir.filePath(relative)))
            missing.append(relative);
    }
    if (!missing.isEmpty()) {
        g_status = QStringLiteral("Componentes ausentes: %1").arg(missing.join(QStringLiteral(", ")));
        return;
    }
    g_runtime_available = true;

    const QString reshadePath = dir.filePath(QStringLiteral("dxgi.dll"));
    // Never process Zanit's own menus with Neural Rendering. The stream view
    // enables it after a PS5 session is present.
    WritePrivateProfileStringW(L"RenoDX.DLSS5", L"NeuralUplift", L"0",
                               reinterpret_cast<LPCWSTR>(dir.filePath(QStringLiteral("ReShade.ini")).utf16()));
    g_reshade_module = LoadLibraryExW(reinterpret_cast<LPCWSTR>(reshadePath.utf16()),
                                      nullptr,
                                      LOAD_WITH_ALTERED_SEARCH_PATH);
    if (!g_reshade_module) {
        g_status = QStringLiteral("Falha ao carregar ReShade (erro Windows %1)")
                       .arg(static_cast<qulonglong>(GetLastError()));
        return;
    }

    g_runtime_loaded = true;
    g_status = QStringLiteral("DLSS 5 / ReShade carregado");
#else
    g_status = QStringLiteral("DLSS 5 esta disponivel apenas no Windows");
#endif
}

bool runtimeAvailable()
{
    return g_runtime_available;
}

bool runtimeLoaded()
{
    return g_runtime_loaded;
}

QString status()
{
    return g_status;
}

bool bridgeAvailable()
{
#if defined(Q_OS_WIN)
    return bridgeSubmit() != nullptr;
#else
    return false;
#endif
}

bool setTechniqueEnabled(const char *effect, const char *technique, bool enabled)
{
#if defined(Q_OS_WIN)
    return submit(kCommandTechnique, effect, technique, enabled, 0.0f);
#else
    Q_UNUSED(effect); Q_UNUSED(technique); Q_UNUSED(enabled); return false;
#endif
}

bool setUniformFloat(const char *effect, const char *name, float value)
{
#if defined(Q_OS_WIN)
    return submit(kCommandFloat, effect, name, false, value);
#else
    Q_UNUSED(effect); Q_UNUSED(name); Q_UNUSED(value); return false;
#endif
}

bool toggleNeuralRendering()
{
#if defined(Q_OS_WIN)
    return submit(kCommandNeuralToggle, nullptr, "NeuralRendering", false, 0.0f);
#else
    return false;
#endif
}

QString getRenoDxConfig(const char *key, const char *fallback)
{
#if defined(Q_OS_WIN)
    using GetConfig = bool (*)(void *, void *, const char *, const char *, char *, size_t *);
    if (!g_reshade_module)
        return QString::fromUtf8(fallback);
    const auto function = reinterpret_cast<GetConfig>(GetProcAddress(g_reshade_module, "ReShadeGetConfigValue"));
    if (!function)
        return QString::fromUtf8(fallback);
    char value[128] {};
    size_t size = sizeof(value);
    return function(nullptr, nullptr, "RenoDX.DLSS5", key, value, &size)
        ? QString::fromUtf8(value) : QString::fromUtf8(fallback);
#else
    Q_UNUSED(key); return QString::fromUtf8(fallback);
#endif
}

bool setRenoDxConfig(const char *key, const char *value)
{
#if defined(Q_OS_WIN)
    using SetConfig = void (*)(void *, void *, const char *, const char *, const char *);
    if (!g_reshade_module)
        return false;
    const auto function = reinterpret_cast<SetConfig>(GetProcAddress(g_reshade_module, "ReShadeSetConfigValue"));
    if (!function)
        return false;
    function(nullptr, nullptr, "RenoDX.DLSS5", key, value);
    return true;
#else
    Q_UNUSED(key); Q_UNUSED(value); return false;
#endif
}
}
