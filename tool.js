// ============================================================
// 🆔 TOOL TÌM KIẾM ID BANG HỘI - GTD GUILD FINDER 🆔
// ============================================================

const crypto = require("crypto");
const http = require("http");
const readline = require("readline");

// ==================== CẤU HÌNH MÀU SẮC ====================
const C = {
    r: "\x1b[31m", g: "\x1b[32m", y: "\x1b[33m", b: "\x1b[34m",
    m: "\x1b[35m", c: "\x1b[36m", w: "\x1b[37m", rs: "\x1b[0m",
    bold: "\x1b[1m"
};

// ==================== SETUP READLINE ====================
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const question = (query) => new Promise(resolve => rl.question(query, resolve));

// ==================== HÀM MÃ HÓA ====================
function encryptWithKey(data, key, iv) {
    const cipher = crypto.createCipheriv("aes-128-cbc", key, iv);
    let jsonStr = JSON.stringify(data).replace(/\s+/g, "");
    return encodeURIComponent(cipher.update(jsonStr, "utf8", "base64") + cipher.final("base64"));
}

// ==================== HÀM GỬI REQUEST ====================
function sendRequest(url, data) {
    return new Promise((resolve) => {
        const postData = `DATA=${data}`;
        const urlObj = new URL(url);
        const options = {
            hostname: urlObj.hostname,
            port: urlObj.port || 80,
            path: urlObj.pathname,
            method: "POST",
            headers: {
                "User-Agent": "app",
                "X-Requested-With": "busidol.mobile.tower",
                "Content-Type": "application/x-www-form-urlencoded",
                "Content-Length": Buffer.byteLength(postData)
            }
        };
        const req = http.request(options, (res) => {
            let body = "";
            res.on("data", (d) => body += d);
            res.on("end", () => resolve(body));
        });
        req.on("error", () => resolve(null));
        req.write(postData);
        req.end();
    });
}

// ==================== LOADING ====================
function loading(text) {
    return new Promise((resolve) => {
        process.stdout.write(`\r  ${C.c}${text}...${C.rs}`);
        setTimeout(resolve, 1500);
    });
}

// ==================== BANNER ====================
function showBanner() {
    console.clear();
    console.log(`${C.bold}${C.c}╔════════════════════════════════════════════════════════════════╗${C.rs}`);
    console.log(`${C.bold}${C.c}║  ${C.bold}${C.y}🆔 TOOL TÌM KIẾM ID BANG HỘI - GUILD FINDER 🆔${C.c}    ║${C.rs}`);
    console.log(`${C.bold}${C.c}╠════════════════════════════════════════════════════════════════╣${C.rs}`);
    console.log(`${C.bold}${C.c}║  ${C.w}Tìm kiếm bang hội qua tên - Hiển thị ID, Chủ Bang, Điểm  ${C.c}║${C.rs}`);
    console.log(`${C.bold}${C.c}╚════════════════════════════════════════════════════════════════╝${C.rs}`);
}

// ==================== HÀM CHÍNH ====================
async function findGuild() {
    const k = Buffer.from("gksekfidjrqjfwk1", "utf8");
    const iv = Buffer.from("towerdefense_amo", "utf8");
    
    const defaultUniqId = "TDM252591fXQ";
    const defaultHostId = "gtdvip25@gmail.com";
    
    showBanner();
    
    // Chọn server
    console.log(`\n  ${C.c}┎────────── Chọn Server ──────────┒${C.rs}`);
    console.log(`  ${C.c}┃ ${C.w}[1] ${C.g}Server AMO (Mobile)       ${C.c}┃${C.rs}`);
    console.log(`  ${C.c}┃ ${C.w}[2] ${C.m}Server ATV (Android TV)   ${C.c}┃${C.rs}`);
    console.log(`  ${C.c}┖─────────────────────────────────┚${C.rs}`);
    const serverChoice = await question(`\n  ${C.y}👉 Chọn server: ${C.w}`);
    const isATV = serverChoice === "2";
    const platform = isATV ? "ATV" : "AMO";
    
    const gicDefault = isATV ? "선택된서버:한국서버 ping:205ms" : "선택된서버:베트남서버 ping:67ms";
    
    await loading("📡 Đang kết nối server và lấy GICHAPO");
    
    // Lấy GICHAPO
    const getUrl = isATV 
        ? "http://211.253.26.47:8093/TOWERDEFENCE_ATV/get_user_data_all_AES2.php"
        : "http://211.253.26.47:8093/TOWERDEFENCE_AMO/get_user_data_all_AES2.php";
    
    const getData = { 
        "UNIQ_ID": defaultUniqId, 
        "HOST_ID": defaultHostId, 
        "MOBILE_CONNECT": "", 
        "ANDROID_AD": "", 
        "GICHAPO": gicDefault, 
        "LOCAL_KEY": null 
    };
    if (isATV) getData.MODEL_NAME = "BeyondTV";
    
    const getEnc = encryptWithKey(getData, k, iv);
    const getResponse = await sendRequest(getUrl, getEnc);
    
    if (!getResponse) {
        console.log(`\n  ${C.r}❌ Không thể kết nối server!${C.rs}`);
        rl.close();
        return;
    }
    
    let gic = null;
    let userName = "N/A";
    let userLevel = 0;
    
    try {
        const decipher = crypto.createDecipheriv("aes-128-cbc", k, iv);
        let dec = decipher.update(getResponse, "base64", "utf8") + decipher.final("utf8");
        const data = JSON.parse(dec);
        const v = data.VALUE || {};
        
        userName = v.normal?.value?.USER_NAME || "N/A";
        userLevel = v.normal?.value?.SO_CODE || 0;
        
        const findGichapo = (obj) => {
            if (typeof obj !== 'object' || obj === null) return null;
            if (obj.gichapo && obj.gichapo.length >= 😎 return obj.gichapo;
            for (let key in obj) {
                let res = findGichapo(obj[key]);
                if (res) return res;
            }
            return null;
        };
        
        gic = findGichapo(data);
        
        if (gic) {
            console.log(`  ${C.g}✅ Đã lấy GICHAPO: ${C.y}${gic}${C.rs}`);
        } else {
            console.log(`  ${C.r}⚠️ Không tìm thấy GICHAPO!${C.rs}`);
            gic = await question(`  ${C.y}🔑 Nhập GICHAPO thủ công (8 ký tự): ${C.w}`);
            if (gic.length !== 😎 {
                console.log(`\n  ${C.r}❌ GICHAPO phải có 8 ký tự!${C.rs}`);
                rl.close();
                return;
            }
        }
    } catch(e) {
        console.log(`  ${C.r}⚠️ Lỗi: ${e.message}${C.rs}`);
        gic = await question(`  ${C.y}🔑 Nhập GICHAPO thủ công (8 ký tự): ${C.w}`);
        if (gic.length !== 😎 {
            console.log(`\n  ${C.r}❌ GICHAPO phải có 8 ký tự!${C.rs}`);
            rl.close();
            return;
        }
    }
    
    // Hiển thị thông tin
    console.log(`\n  ${C.bold}${C.c}╔════════════════════════════════════════════════════════════════╗${C.rs}`);
    console.log(`  ${C.bold}${C.c}║  ${C.bold}${C.w}📱 PLATFORM   : ${C.y}${platform}${" ".repeat(35)}${C.c}║${C.rs}`);
    console.log(`  ${C.bold}${C.c}║  ${C.bold}${C.w}👤 TÊN        : ${C.g}${userName}${" ".repeat(38)}${C.c}║${C.rs}`);
    console.log(`  ${C.bold}${C.c}║  ${C.bold}${C.w}🔑 GICHAPO    : ${C.y}${gic}${" ".repeat(38)}${C.c}║${C.rs}`);
    console.log(`  ${C.bold}${C.c}╚════════════════════════════════════════════════════════════════╝${C.rs}`);
    
    // Tìm kiếm
    let searching = true;
    
    while (searching) {
        console.log(`\n  ${C.bold}${C.y}${"─".repeat(60)}${C.rs}`);
        const searchWord = await question(`  ${C.y}🔍 Nhập tên bang muốn tìm (hoặc "exit" để thoát): ${C.w}`);
        
        if (searchWord.toLowerCase() === "exit") {
            searching = false;
            break;
        }
        
        if (searchWord.trim() === "") {
            console.log(`  ${C.r}❌ Vui lòng nhập tên bang!${C.rs}`);
            continue;
        }
        
        await loading(`🔎 Đang tìm kiếm "${searchWord}"`);
        
        const searchPayload = {
            "PLATFORM": platform,
            "UNIQ_ID": defaultUniqId,
            "SEARCH_WORD": searchWord,
            "GUILD_BUNHO": 0,
            "MOBILE_CONNECT": "",
            "GICHAPO": gic
        };
        
        const searchEnc = encryptWithKey(searchPayload, k, iv);
        const searchUrl = "http://211.253.26.47:8093/TOWERDEFENCE_COMMON/GUILD/get_guild_list_AES2.php";
        const searchResponse = await sendRequest(searchUrl, searchEnc);
        
        showBanner();
        console.log(`\n  ${C.bold}${C.c}╔════════════════════════════════════════════════════════════════╗${C.rs}`);
        console.log(`  ${C.bold}${C.c}║  ${C.bold}${C.y}🔍 KẾT QUẢ: "${searchWord}"${C.c}${" ".repeat(60 - searchWord.length - 15)}║${C.rs}`);
        console.log(`  ${C.bold}${C.c}╚════════════════════════════════════════════════════════════════╝${C.rs}`);
        
        if (searchResponse && searchResponse.length > 10) {
            try {
                const decipher = crypto.createDecipheriv("aes-128-cbc", k, iv);
                let dec = decipher.update(searchResponse, "base64", "utf8") + decipher.final("utf8");
                const jsonRes = JSON.parse(dec);
                
                if (jsonRes.list && Object.keys(jsonRes.list).length > 0) {
                    let count = 0;
                    console.log(`\n  ${C.g}✅ Tìm thấy ${C.y}${Object.keys(jsonRes.list).length}${C.g} bang hội!${C.rs}`);
                    
                    for (const [key, guild] of Object.entries(jsonRes.list)) {
                        count++;
                        const master = typeof guild.master === "string" ? JSON.parse(guild.master) : guild.master;
                        
                        console.log(`\n  ${C.bold}${C.g}┌──────────────────────────────────────────────────────────────┐${C.rs}`);
                        console.log(`  ${C.bold}${C.g}│${C.bold}${C.w} ${count}. 🏰 ${C.y}${guild.guild_name || "N/A"}${C.w} [ID: ${C.c}${guild.guild_bunho || "?"}${C.w}]${" ".repeat(40 - (guild.guild_name?.length || 0))}${C.g}│${C.rs}`);
                        console.log(`  ${C.bold}${C.g}├──────────────────────────────────────────────────────────────┤${C.rs}`);
                        console.log(`  ${C.bold}${C.g}│${C.w} 👑 Chủ Bang   : ${C.g}${master.name || "N/A"}${C.w} (LV: ${C.y}${master.level || "?"}${C.w})${" ".repeat(35)}${C.g}│${C.rs}`);
                        console.log(`  ${C.bold}${C.g}│${C.w} 🆔 ID Chủ     : ${C.c}${master.uniq_id || master.un || "N/A"}${" ".repeat(40)}${C.g}│${C.rs}`);
                        console.log(`  ${C.bold}${C.g}│${C.w} 📊 Điểm War   : ${C.m}${(guild.tot_score || 0).toLocaleString()}${" ".repeat(40)}${C.g}│${C.rs}`);
                        console.log(`  ${C.bold}${C.g}│${C.w} 👥 Thành viên : ${C.y}${guild.member || 0}${C.w}/${C.y}${guild.max_member || 0}${" ".repeat(40)}${C.g}│${C.rs}`);
                        console.log(`  ${C.bold}${C.g}└──────────────────────────────────────────────────────────────┘${C.rs}`);
                    }
                } else {
                    console.log(`\n  ${C.r}❌ Không tìm thấy bang hội nào!${C.rs}`);
                }
            } catch(e) {
                console.log(`\n  ${C.r}❌ Lỗi: ${e.message}${C.rs}`);
            }
        } else {
            console.log(`\n  ${C.r}❌ Server trả về trống! Kiểm tra GICHAPO.${C.rs}`);
        }
        
        console.log(`\n  ${C.bold}${C.y}${"─".repeat(60)}${C.rs}`);
        const cont = await question(`  ${C.y}⏎ Nhấn Enter để tìm tiếp, "exit" để thoát: ${C.w}`);
        if (cont.toLowerCase() === "exit") {
            searching = false;
        }
    }
    
    console.log(`\n  ${C.y}👋 Cảm ơn bạn đã sử dụng Tool!${C.rs}`);
    rl.close();
}

// ==================== CHẠY ====================
findGuild().catch(console.error);
