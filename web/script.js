// ===================================================================================
// NEXT FPS BOOSTER - Modern NUI Script
// Handles dynamic locales, presets, live FPS widget, and responsive switches
// ===================================================================================

function getResourceName() {
    return typeof window.GetParentResourceName === 'function' ? GetParentResourceName() : 'next-fpsmenu';
}

// -----------------------------------------------------------------------------------
// Lua Veri İletişim Yardımcısı (Fetch + JSON Content-Type garantisi)
// -----------------------------------------------------------------------------------
function sendNuiData(event, data) {
    let url = `https://${getResourceName()}/${event}`;
    try {
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(data || {})
        }).catch(function(err) {});
    } catch (e) {
        try {
            $.post(url, JSON.stringify(data || {}));
        } catch (e2) {}
    }
}

// -----------------------------------------------------------------------------------
// Dil / Locale Uygulayıcı
// -----------------------------------------------------------------------------------
function applyLocale(localeData) {
    if (!localeData) return;

    $("[data-loc]").each(function() {
        let key = $(this).attr("data-loc");
        if (localeData[key]) {
            $(this).text(localeData[key]);
        }
    });

    $("[data-loc-title]").each(function() {
        let key = $(this).attr("data-loc-title");
        if (localeData[key]) {
            $(this).attr("title", localeData[key]);
        }
    });
}

// -----------------------------------------------------------------------------------
// Switch Durumunu Güncelleyici (Kaydırma ve Renkler)
// -----------------------------------------------------------------------------------
function updateSwitchState(key, isEnabled) {
    let indicator = $(`#${key}`);
    let onBtn = $(`#${key}ON`);
    let offBtn = $(`#${key}OFF`);

    if (!indicator.length) return;

    if (isEnabled) {
        indicator.css("margin-left", "-1px");
        offBtn.removeClass("selectedOFF");
        onBtn.addClass("selectedON");
    } else {
        indicator.css("margin-left", "39px");
        offBtn.addClass("selectedOFF");
        onBtn.removeClass("selectedON");
    }
}

// -----------------------------------------------------------------------------------
// Canlı FPS - client.lua'dan gelen gerçek oyun içi FPS değerini ekrana basar
// -----------------------------------------------------------------------------------
function resetFpsDisplay() {
    $("#fpsVal").text("--");
}

// -----------------------------------------------------------------------------------
// Switch Tıklama Olayı (Bireysel Ayarlar)
// -----------------------------------------------------------------------------------
$(document).on("click", ".switchOption", function() {
    let id = $(this).attr("id");
    if (!id) return;

    let isEnabled = id.includes("ON");
    let optionKey = isEnabled ? id.replace("ON", "") : id.replace("OFF", "");

    updateSwitchState(optionKey, isEnabled);
    $(".presetCard").removeClass("active");

    // Ultra Gerçekçi Anahtarı Açıldığında Arayüzü Senkronize Et
    if (optionKey === "realismMaster") {
        if (isEnabled) {
            updateSwitchState("realismLod", true);
            updateSwitchState("realismModels", true);
            updateSwitchState("realismLights", true);
            updateSwitchState("realismShadows", true);

            let degradations = ["peds", "vehicles", "objects", "particles", "broken", "ped", "unnecessary", "rain", "shadows", "lights", "lowTexture"];
            degradations.forEach(function(d) {
                updateSwitchState(d, false);
            });
            $("#presetRealism").addClass("active");
        } else {
            updateSwitchState("realismLod", false);
            updateSwitchState("realismModels", false);
            updateSwitchState("realismLights", false);
            updateSwitchState("realismShadows", false);
            $("#presetRealism").removeClass("active");
        }
    }

    sendNuiData("changeOption", {
        option: optionKey,
        boolean: isEnabled
    });
});

// -----------------------------------------------------------------------------------
// Sayfa Değiştirme (Tabs: Booster vs Grafik Paketi)
// -----------------------------------------------------------------------------------
$(document).on("click", ".navTab", function() {
    let tab = $(this).attr("data-tab");
    if (!tab) return;

    $(".navTab").removeClass("active");
    $(this).addClass("active");

    if (tab === "booster") {
        $("#pageRealism").hide();
        $("#pageBooster").fadeIn(180);
    } else if (tab === "realism") {
        $("#pageBooster").hide();
        $("#pageRealism").fadeIn(180);
    }
});

// -----------------------------------------------------------------------------------
// Paket (Pack) & Görsel Stil Seçimi - Canlı Model/Prop Değişimi
// -----------------------------------------------------------------------------------
function updateActiveStyle(style) {
    $(".styleCard").removeClass("active");
    let target = $(`.styleCard[data-style="${style}"]`);
    if (target.length) {
        target.addClass("active");
    } else {
        $("#styleVibrant").addClass("active");
    }
}

$(document).on("click", ".styleCard", function() {
    let pack = $(this).attr("data-style") || $(this).attr("data-pack");
    if (!pack) return;

    updateActiveStyle(pack);

    // Pakete tıklandığında Ultra Gerçekçi modunu UI'da anında aktif et
    updateSwitchState("realismMaster", true);
    updateSwitchState("realismLod", true);
    updateSwitchState("realismModels", true);
    updateSwitchState("realismLights", true);
    updateSwitchState("realismShadows", true);

    let degradations = ["peds", "vehicles", "objects", "particles", "broken", "ped", "unnecessary", "rain", "shadows", "lights", "lowTexture"];
    degradations.forEach(function(d) {
        updateSwitchState(d, false);
    });

    $("#presetRealism").addClass("active");

    // Lua'ya veriyi anında ilet
    sendNuiData("changeGraphicPack", {
        pack: pack
    });
    sendNuiData("changeRealismStyle", {
        style: pack
    });
});

// -----------------------------------------------------------------------------------
// Hazır Profil (Preset) Tıklama Olayı
// -----------------------------------------------------------------------------------
$(document).on("click", ".presetCard", function() {
    let preset = $(this).attr("data-preset");
    if (!preset) return;

    $(".presetCard").removeClass("active");
    $(this).addClass("active");

    if (preset === "realism") {
        $(".navTab").removeClass("active");
        $("#tabRealism").addClass("active");
        $("#pageBooster").hide();
        $("#pageRealism").fadeIn(180);

        // Ultra Gerçekçi seçildiğinde arayüzdeki tüm ayarları anında en yükseğe senkronize et
        updateSwitchState("realismMaster", true);
        updateSwitchState("realismLod", true);
        updateSwitchState("realismModels", true);
        updateSwitchState("realismLights", true);
        updateSwitchState("realismShadows", true);

        let degradations = ["peds", "vehicles", "objects", "particles", "broken", "ped", "unnecessary", "rain", "shadows", "lights", "lowTexture"];
        degradations.forEach(function(d) {
            updateSwitchState(d, false);
        });
    }

    sendNuiData("applyPreset", {
        preset: preset
    });
});

// -----------------------------------------------------------------------------------
// Ayarları Arayüze Toplu Dağıtma Fonksiyonu
// -----------------------------------------------------------------------------------
function applyAllSettings(settings) {
    if (!settings) return;

    for (let k in settings) {
        if (typeof settings[k] === "boolean") {
            updateSwitchState(k, settings[k]);
        }
    }

    if (settings.realismStyle) {
        updateActiveStyle(settings.realismStyle);
    }

    if (settings.realismMaster === true) {
        $("#presetRealism").addClass("active");
    }
}

// -----------------------------------------------------------------------------------
// Lua Mesaj Dinleyicisi (OpenMenu, UpdateSettings, SetLocale)
// -----------------------------------------------------------------------------------
window.addEventListener('message', function (event) {
    let data = event.data;
    if (!data) return;

    // Dil Paketi Güncelleme
    if (data.locale) {
        applyLocale(data.locale);
    }

    // Başlık Güncelleme (Config.MenuTitle)
    if (data.title) {
        $("#headerTitle").text(data.title);
    }

    // Menüyü Aç
    if (data.action === "openMenu") {
        if (data.settings) {
            applyAllSettings(data.settings);
        }

        resetFpsDisplay();
        $(".hider").fadeIn(220);
    }

    // Gerçek Oyun İçi FPS Güncellemesi (client.lua'dan gelen)
    if (data.action === "updateFps") {
        if (data.fps !== undefined) {
            $("#fpsVal").text(data.fps);
        }
    }

    // Toplu Ayar Güncelleme (Preset Seçildiğinde)
    if (data.action === "updateSettings") {
        if (data.settings) {
            applyAllSettings(data.settings);
        }
    }
});

// -----------------------------------------------------------------------------------
// Menüyü Kapatma (ESC Tuşu ve Kapat Butonu)
// -----------------------------------------------------------------------------------
function closeMenu() {
    resetFpsDisplay();
    $(".hider").fadeOut(200);

    sendNuiData("exitMenu", {});
}

$(document).keyup(function(e) {
    if (e.keyCode === 27) {
        closeMenu();
    }
});

$("#closeBtn").click(function() {
    closeMenu();
});