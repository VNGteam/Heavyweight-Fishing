# LUA_INDEX — Kiến trúc `local.lua`

Nguồn: `/Users/vonguyengiap/Documents/script/local.lua`  
Quy mô: **13.271 dòng** (một file duy nhất, script GUI + automation cho Heavyweight Fishing).  
Build tĩnh: `SCRIPT_BUILD_COMMIT = "fix-dialogue-press-timing"` (dòng **104**).

Tài liệu này **không tóm tắt sơ sài**: phạm vi dòng là inclusive, khớp định nghĩa hàm `function` / `local function` / `Name = function` cấp module. Hàm lồng bên trong được ghi riêng ở mục 2.2.

---

## 1. Phân đoạn chức năng theo phạm vi dòng

| Dòng | Phân đoạn | Việc đang xảy ra |
|------|-----------|------------------|
| **1 – 16** | Bootstrap load | `pcall` chờ `game:IsLoaded()`. Auto-kill bản script cũ qua `getgenv()/ _G / shared`: gọi `HeavyweightFishingKill` và `IdenticalHeavyweightFishingUnload` nếu còn sót. |
| **17 – 69** | `CleanOldInstances` + gọi ngay | Xóa GUI trùng tên (`IdenticalHeavyweightFishing`, `HeavyweightFishing`, `FloatingAvatar`, `FloatingCrescent`, `Notifications`) ở `gethui()`, `CoreGui`, `PlayerGui`. Xóa `Workspace.IdenticalESP` và Billboard `ESP_*`. **Gọi ngay dòng 69** trước khi tạo GUI mới. |
| **71 – 111** | Services & runtime flags | Bind `Players`, `Workspace`, `ReplicatedStorage`, `RunService`, `UserInputService`, `TweenService`, `HttpService`, `TeleportService`, `Lighting`, `CoreGui`. Lấy `LocalPlayer` (wait nếu nil), `Camera`. Tắt `GuiService.GuiNavigationEnabled` / `SelectedObject`. Flags: `isRunning`, `activeConnections`, `cleanUpInstances`. `Events = ReplicatedStorage.Events` (spawn WaitForChild 5s nếu chưa có). |
| **113 – 302** | `Config` (bảng cấu hình god-object) | Toàn bộ toggle/slider mặc định: AutoCast, SmartCombo, Train, bait/rod/orb, sell, Octo, farm/secret boss, weather hop, ticket quest, Priority, daily/gacha/craft, movement, ESP, visual, webhook, keybind. `SecretBossTargets` (map tên boss → `true`). `CustomBossSpots`, `HomeFarmSpot`. |
| **304 – 333** | Khôi phục hop từ disk **trước UI** | Đọc `HeavyweightFishing_WeatherHop.json` → `pendingWeatherHopData` và **ghi đè** `Config.AutoWeatherHop` / `TargetWeather` / `WeatherHopAutoFish` / `WeatherHopAlertWebhook`. Đọc `HeavyweightFishing_NPCHop.json` → `pendingNPCHopData` và bật `AutoServerHopTaoist/Maoshan/God`. |
| **335 – 383** | State lõi sớm | `UIControllers = {}`, `PriorityManager = {}`, `comboState = { openerUsedCount, openerDone, loopTargetIndex, loopIndex, lastCastTime, lastActionTime, minigameStartTime, usedTimes[Z/X/C/V], defaultCooldowns, loopWaitStartTime }`. Ba helper combo: `SkillExists`, `FormatCombo`, `GetComboPreview`. |
| **385 – 522** | `ConfigLabelMap` | Map **nhãn tiếng Việt trên GUI** → key `Config`. Nhiều nhãn khác nhau trỏ cùng một key (ví dụ nhiều label → `AutoEquipBestBait`). Dùng để gắn `UIControllers[key]` khi tạo row. |
| **524 – 662** | Persistence config theo account | Thư mục `Identical/HeavyweightFishing/Configs/<SafePlayerName>/`. `GetAccountConfigDir`, `EnsureAccountConfigDir`, `GetSavedConfigList`, `SaveAccountConfig`, `LoadAccountConfig` (decode Enum `__enum`, rồi `UIControllers[k].Set`), `DeleteAccountConfig`. |
| **664 – 804** | Essential config + auto-save **đã tắt** | `Config._essentialKeys` (whitelist ghi file). `_saveEssential` / `_loadEssential` (`essential_config.json`). **Vệ sinh combo C** khi load. `_autoSaveTimer`, `_triggerAutoSave` là **no-op** (792–794). Block auto-load essential bị comment. |
| **806 – 934** | Persistence Smart Combo + Boss Targets | File `HeavyweightFishing_SmartCombo.json` (`SMART_COMBO_KEYS`). `SaveSmartCombo` debounce 0.3s (`_smartComboSavePending`). `LoadSmartComboAndSyncUI` (`Set(..., true)` skip callback). File `HeavyweightFishing_BossTargets.json`. `SaveBossTargets` / `LoadBossTargetsAndSyncUI`. |
| **936 – 1003** | Theme + ScreenGui gốc | `Colors` palette. `getGuiParent()` (`gethui` → CoreGui → PlayerGui). Tạo `screenGui` tên `IdenticalHeavyweightFishing`, parent, `cleanUpInstances`. |
| **1005 – 1044** | Unload / kill switch | `UnloadScript`: `isRunning=false`, disconnect, destroy instances, xóa ESP folder, reset WalkSpeed/Lighting, `CleanOldInstances`, clear `getgenv` hooks. Gán `globalEnv.HeavyweightFishingKill` và `IdenticalHeavyweightFishingUnload`. |
| **1046 – 1326** | Notification + chrome GUI | Container `Notifications`. `FormatWithSpaces`, `ShowNotification`. Floating avatar / crescent, status dot, sidebar, search index `rowSearchIndex`, `tabFrames` / `tabButtons`. |
| **1328 – 1699** | UI toolkit (factory row) | `SwitchTab`, `CreateTab`, `ToggleUiVisibility`. `createCategoryHeader`, `createCardGroup`, `createCollapsibleCardGroup` (`toggle` lồng 1445). `createBaseRow`, `createToggleRow`, `createSliderRow`, `createDropdownRow`, `createButtonRow`, `createInfoRow`, `createInputRow`. Mỗi control có `.Set` / `.Get`; toggle/slider/dropdown ghi `UIControllers[ConfigLabelMap[label]]`. |
| **1701 – 1794** | Comment SECRET BOSS DATABASE + `allRods` + `IsRodOwned` | Danh sách cần. `IsRodOwned` quét pData (FishingRod, FishingRodInventory, Rods/Inventory, Backpack/Character). Wooden Rod luôn true. |
| **1796 – 1986** | `secretBossDatabase` + `secretBossLookup` | Mỗi đảo: `islandName`, `weather`, `patterns`, `weatherPatterns`, `bossPatterns`, `pos`, `lookAt`, `spots[1..]`, `reqPower`. Lookup tên boss → đảo. **Đây là nguồn sự thật cho teleport / chat sniper / weather match.** |
| **1987 – 2745** | Module `Wiki` | `craftMaterialFish`, `rarityColors`, `wikiFishData` (keep/role/use). API lock/unlock Favorite, index, bait ingredients, `temporarilyUnlockedBaitFish`, `ResolveFishIcon`. |
| **2748 – 3022** | State săn boss + gems + webhook + fish detect | `secretBossState` ban đầu. `bossTogglesMap`, `weatherTotems` (tọa độ totem). `sessionStartTime`, cash/fish baseline. `gemTracker`, `fishGemRewardLookup`. `GetFishGemReward`, `GetPlayerCurrentGems`, `TrackCaughtFishForGems`, `SendDiscordWebhook`, `GetPlayerRodPower`, `GetCurrentHookedFishName` (`matchBossName` lồng). |
| **3024 – 3491** | Teleport / server hop / weather-NPC hop | `QueueScriptOnTeleport`, `ServerHop`. `secretBossState.SaveNPCHopState` / `ClearNPCHopState` (file `HeavyweightFishing_NPCHop.json`). `secretBossState.ServerHop = ServerHop`. Flags hop: `isHopping`, `currentVisited`, `lastAttemptedJob`, `hopWatchdog`, `isNormalHopping`. `HandleTeleportError` + hook `TeleportInitFailed`. `IsWeatherMatch`, `HopToNextWeatherServer`, `CheckWeatherHopOnJoin`, `CheckNPCHopOnJoin`. |
| **3493 – 3560** | Khởi tạo `ticketQuestState` (rỗng) + helpers thời gian/cần | `GetServerTimeNow`, `IsFishingActive`, `IsBusyOrInteracting`. `CancelAndRecastRod` (unequip + `ToggleHotbar` + `Fishing:FireServer`). |
| **3562 – 4252** | Secret boss: parse chat/weather, spot, teleport | `DetectWeatherPattern`, `DetectIsland` (bỏ qua “caught”), `FindWaterSpot` (raycast nan hoa), Save/Load CustomSpots & HomeSpot (`HeavyweightFishing_CustomSpots.json` / home trong Config), `ReturnToHome`, island slot CRUD, `ApplyJitter`, `GetChosenSpotForPlayer`, `Teleport`, `DetectWeather`. |
| **4261 – 4706** | Scan NPC God/Taoist/Maoshan + chat sniper | `getCandidateNPCFolders`, `isTaoistText`, `isMaoshanText`, `isNPCModel`. Scan/Get Taoist, Maoshan, GodSpirit (cache). `HandleChatMessage` (despawn vs spawn → `secretBossState.active`). `ScanChatHistory`. |
| **4708 – 4775** | Prompt + parse weight + **gán field `ticketQuestState`** | `TriggerPrompt`, `ParseFishWeightNumber`. `for k,v in pairs({...})` copy toàn bộ field quest (active, quest type, spots mặc định, UI refs) vào `ticketQuestState`. |
| **4777 – 6396** | Ticket Quest engine đầy đủ | Serialize/Load spots file, UI status, tìm NPC, teleport, dialogue GUI, **ClickButtonEntry** (5 lớp kích hoạt), HandleDialogue, InteractNPC, DetectActiveQuest, ScanAndUpdateStatus, ResetCooldown, **Tick** (máy trạng thái vé: hết ngày / priority / cooldown / nhận / làm / trả / bán / mua mồi). |
| **6398 – 6467** | Background ticket + Data.Quest hooks | Loop 1s: `ScanAndUpdateStatus`, `PriorityManager.UpdateUI`, nếu `AutoTicketQuest` thì `Tick()`. Spawn khác: bind `ValueBase.Changed` trong `Data/<uid>/Quest`, hook cooldown value. |
| **6468 – 6574** | Priority Manager | Field `uiStatusRow`, `lastReportedTask`, `cachedTask`, `lastTaskScan`. `IsTaskActive`, `GetTaskPriority`, `GetTaskDisplayName`, `GetActiveTask` (cache 0.5s), `UpdateUI`. Thứ tự candidate: SecretBoss → TicketQuest → GodSpirit → TrainSkill → NormalFarm; số hạng nhỏ hơn = ưu tiên cao hơn. |
| **6577 – 6612** | Tạo tab + card Auto Cast | 12 tab: Câu Cá, Săn Boss, Wiki, Thần Linh, Nhiệm Vụ, Shop & Chế Mồi, Dịch Chuyển, ESP & Đồ Hoạ, Nhân Vật, Cài Đặt, Thử Nghiệm. Switch mặc định “Câu Cá”. Stats info rows + toggle AutoCast/Anchor/Slam/Charge/AntiStuck. |
| **6614 – 6894** | Home Spot UI + Smart Combo UI + Train UI | `GetHomeSpotText`, lưu/xóa home CFrame. Combo: nested `getPresetValue`, `getPresetLabel`, **`applyComboChange`**, `makeQuickBtn`, `appendKey`. Train skill toggles. |
| **6896 – 7673** | Skill text window + export skill DB | `ShowSkillTextWindow`. `builtInSkills` table (từ ~7045). `ExportAllPlayerSkills` (crawl inventory/modules: `CleanSkillName`, `IsSkillItemOwned`, `AddSkill`, `CrawlTable`, `GetFromDb`). |
| **7675 – 8396** | Tab Câu Cá còn lại + Tab Săn Boss (inline `do`) | Equip bait/rod loadout remotes, sell, fish list, Octo, weather hop toggle, secret boss toggles (`bossTogglesMap`), custom spots UI (`GetSpotStats`, `GetSlotStatusText`, `RefreshSpotUI`), farm boss toggles. |
| **8397 – 8959** | Tab Wiki | `initWikiTab` (filter `makeFilterBtn`, `UpdateCardFilter`, `SetFilterMode`, live index `attachFolder`). Gọi `initWikiTab()` dòng 8959. |
| **8961 – 9472** | Tab Thần Linh + Nhiệm Vụ + Shop (inline) | God pray/hop UI, ticket quest UI (gắn `ticketQuestState.ui*`), daily claim, redeem code, craft/buy bait, sage `BuySkill`. |
| **9474 – 9642** | Shop cần câu | `formatNumber`, `UpdateAllRodShopUI`, `rodShopUpdaters`, `rodRecipes` (từ ~8254 vẫn thuộc fishing/shop), nút mua/equip `BuyFishingRod` / `EquipFishingRod`. |
| **9643 – 9985** | Tab Dịch chuyển: đảo / boss realm / player | `GetCurrentLocationName`, `islands`, `bossRealms`, `islandUpdaters`, `UpdateAllIslandStatus`, copy tọa độ, danh sách đảo, `playerLookup`, `BuildPlayerList`, `RefreshPlayerDropdown`, teleport tới player. |
| **9954 – 10130** | Teleport NPC quest | `questNPCList`, `findNPCModel`, nút bay tới NPC. |
| **10131 – 10563** | Tab Visuals + Player + Profiles + Priority UI | `ApplyFullbright`, fog/performance/hide UI, walk/fly/noclip/ESP toggles. Profile save/load dropdown `RefreshProfileDropdown`. `rankToNumber` / `numberToRank` / `applyPriorityPreset` / `onCustomRankChange` + 5 dropdown hạng. |
| **10564 – 10871** | Tab Thử nghiệm + sync Config→UI | `initExperimentalTab`: ghost invis, trait reroll, boat, rod color, exchange, fish tank, plot upgrade. Sau đó spawn 0.2s: `UIControllers[key].Set(Config[key], true)` **bắt buộc skipCallback**. |
| **10873 – 11233** | Combo runtime (đặt muộn, sau UI) | Timers `lastCastTime/Sell/Skill`, `isTrainingBusy`. `comboState.IsSkillReady` / `IsSkillOnCooldown` / `CheckSkillReady`. `GetFishHealth`, `GetPlayerHealth`. `IsCharacterCastingSkill`. **`comboState.CastSkill`** (khóa C, khóa ticket skill, remote + VIM + clickBtn). |
| **11234 – 11309** | Rate-limit timers + auto-favorite inventory | `lastGachaTime`, `lastBaitBuyTime`, `lastQuestTime`, `lastGodPrayTime`, `lastEquipTime`, `lastEquipRodTime`, `lastProgressionTime`, `lastProtectTime`, fishing/minigame trackers. `ProtectInventoryItem` / `ProtectAllInventoryItems` (`FavoriteItem:FireServer`). `Inventory.ChildAdded` hook. |
| **11311 – 12292** | **CORE LOOP: `RunService.Heartbeat`** | Water platform, walkspeed, noclip, auto-equip rod, anti-stuck, **fast-skip secret boss**, train skill cancel, **smart combo / ticket skills**, auto cast `Fishing:FireServer`, auto bait/rod/orb, auto sell, daily/gacha/craft/buy bait, `RhythmHit` Octo. Toàn bộ nằm trong `pcall` mỗi frame. Kết thúc `end)` dòng 12292. |
| **12294 – 12311** | Rainbow rod cycle | Loop 0.25s `SetRodSkinColor` khi `Config.RainbowRodColor`. |
| **12313 – 12349** | `RenderStepped` Fly | `BodyVelocity` + `BodyGyro` WASD/Space/Shift. |
| **12351 – 12407** | `RenderStepped` AnchorBar + Slam/Charge phụ | Ép `BarFrame.Bar` giữa; boss bar theo Hitbox; `Slam("Perfect")`, `Charge(100)`; ẩn Hurt overlay. **Trùng remote với Heartbeat** — rất nhạy. |
| **12408 – 12534** | Input phụ: jump, swim, extra slam connections | Infinite jump, bind Perfect/Charge buttons, v.v. |
| **12536 – 12674** | Anti-AFK đa tầng + NPC hop loop | Tầng 1: `getconnections(LocalPlayer.Idled)` Disable. Tầng 2: Idled → VirtualUser + VIM. Tầng 3: pulse 300s. Spawn hop Taoist/Maoshan/God (dùng `pendingNPCHopData.Visited`). |
| **12676 – 12842** | ESP primitives (`do` block) | Folder `IdenticalESP`, `activeESP`, fish ring adornment. `GetNearestIslandName`, `ResolveBestPart`, `AddESP`, `RemoveESP`. |
| **12844 – 13247** | ESP scan loop + fish ring Heartbeat + `end` của `do` | Scan 1.2s Players/SecretRod/God/Boats/Boss/Taoist/Maoshan. Vòng Heartbeat vẽ vòng đỏ / weight / mutation. `end` dòng 13247 đóng `do` 12677. |
| **13249 – 13256** | Hotkey global | RightControl / `Config.UIKeybind` → `ToggleUiVisibility`. End / `Config.StopKeybind` → `UnloadScript`. |
| **13258 – 13271** | Post-init | Spawn `CheckWeatherHopOnJoin`, `CheckNPCHopOnJoin`. `LoadSmartComboAndSyncUI`, `LoadBossTargetsAndSyncUI`. Notification chào phiên bản. |

### 1.1. Lát cắt Heartbeat (11322 – 12292) — không được xem là “một khối vô danh”

| Dòng (xấp xỉ) | Việc trong cùng 1 Heartbeat |
|---------------|------------------------------|
| 11333 – 11354 | WalkSpeed, WalkOnWater / AcidWaterShield (đặt `waterPlatform`), Noclip (`CanCollide=false` mọi BasePart). |
| 11356 – 11370 | Đọc attribute `Fishing` / `Minigame` / `CDForTheNextThrow` / `Swimming`. `shouldAutoFish`. Nếu ticket đang thoại: Unequip + `CancelCast`. |
| 11372 – 11416 | Auto `ToggleHotbar` cầm cần. Reset `comboState` **mỗi lần vào minigame**. Reset `secretBossState.isCatchingTarget` khi rời minigame. |
| 11418 – 11430 | Anti-stuck: 15s fishing không minigame → recast; 22s minigame → recast (trừ khi đang train). |
| 11432 – 11510+ | Fast Skip: `GetCurrentHookedFishName` + `secretBossLookup` + `Config.SecretBossTargets`. Boss → webhook, `isCatchingTarget=true`. Không phải target → `CancelAndRecastRod`. |
| ~11550 – 11780 | AutoTrainSkill: cancel delay, đếm `TrainCurrentCount`, khóa `isTrainingBusy`. |
| ~11780 – 11997 | Smart combo / AutoSkills / ticket `fish_100` / `skill_100` / loop Z,X,V. Gọi `comboState.CastSkill`. Slam/Charge/UpdateFishProgression. |
| 11999 – 12038 | AutoCast: check `InventoryLimit`, `SellFish("All")` sau `ProtectAllInventoryItems`, `Fishing:FireServer(root.CFrame)`. |
| 12041 – 12140 | Equip bait (thứ tự tier Nameless→…→Basic), equip rod/orb. |
| 12140 – 12288 | God pray, ticket không chạy ở đây (chạy loop 1s), sell định kỳ, DailyReward, Gacha, CraftBait, BuyBait, RhythmHit. |

---

## 2. Bảng tra cứu hàm chính (Function Signatures)

Quy ước: `local` = closure module (không global Lua). Tham số đúng như chữ ký trong file. `Line End` là dòng `end` của chính hàm đó.

### 2.1. Hàm cấp module

| Dòng | Chữ ký | Vai trò ngắn |
|------|--------|----------------|
| 17–68 | `local function CleanOldInstances()` | Destroy GUI/ESP bản cũ. |
| 361–364 | `function comboState.SkillExists(sk, fUI)` | `sk` rỗng/`Tắt` → false; **không đọc fUI**. |
| 366–372 | `function comboState.FormatCombo(str)` | Rút Z/X/C/V, join `", "`. |
| 374–383 | `function comboState.GetComboPreview(str)` | Preview `Z ➔ X` + số chiêu. |
| 524–529 | `local function GetAccountConfigDir()` | Path config theo `LocalPlayer.Name` sanitize. |
| 531–541 | `local function EnsureAccountConfigDir()` | `makefolder` cây Identical/…/Configs. |
| 543–560 | `local function GetSavedConfigList()` | `listfiles` → tên `.json`. |
| 562–599 | `local function SaveAccountConfig(cfgName)` | JSON toàn bộ `Config` (Enum → `{__enum}`). Return `ok, msg`. |
| 601–645 | `local function LoadAccountConfig(cfgName)` | Decode, gán Config, `UIControllers[k].Set`. Return `ok, msg`. |
| 647–662 | `local function DeleteAccountConfig(cfgName)` | `delfile`. |
| 725–746 | `Config._saveEssential()` | Ghi whitelist `_essentialKeys` → `essential_config.json`. |
| 748–788 | `Config._loadEssential()` | Nạp whitelist; **strip chữ C khỏi LoopSkills / TicketQuickSkill**. |
| 792–794 | `Config._triggerAutoSave(delaySec)` | **Cố ý rỗng.** `delaySec` bị bỏ. |
| 826–842 | `local function SaveSmartCombo()` | Debounce 0.3s, ghi `SMART_COMBO_KEYS`. |
| 844–885 | `local function LoadSmartComboAndSyncUI()` | Nạp + `Set(v, true)`. |
| 894–909 | `local function SaveBossTargets()` | Ghi `Config.SecretBossTargets`. |
| 911–934 | `local function LoadBossTargetsAndSyncUI()` | Nạp + sync `bossTogglesMap`. |
| 966–982 | `local function getGuiParent()` | Parent an toàn cho ScreenGui. |
| 1005–1039 | `local function UnloadScript()` | Kill toàn script. |
| 1061–1081 | `local function FormatWithSpaces(val)` | `1234567` → `"1 234 567"`. |
| 1083–1113 | `local function ShowNotification(title, text, notifType, duration)` | Toast; `notifType`: SUCCESS/WARN/INFO/… |
| 1328–1348 | `local function SwitchTab(tabName)` | Hiện `tabFrames[tabName]`. |
| 1350–1365 | `local function CreateTab(name)` | Tạo nút + scrolling frame. |
| 1376–1382 | `ToggleUiVisibility = function()` | Ẩn/hiện `screenGui`. |
| 1392–1396 | `local function createCategoryHeader(parent, text)` | Header section. |
| 1398–1404 | `local function createCardGroup(parent)` | Card container. |
| 1406–1456 | `local function createCollapsibleCardGroup(parent, text, defaultOpen)` | Card có collapse. |
| 1458–1470 | `local function createBaseRow(parent, labelText, descText, indexSearch)` | Row + index search. |
| 1472–1511 | `local function createToggleRow(parent, labelText, descText, initialVal, callback, indexSearch)` | **Nếu `initialVal` là function thì shift args** (coi như không có initial). Return `{frame,Set,Get}`. |
| 1513–1553 | `local function createSliderRow(parent, labelText, descText, minVal, maxVal, initialVal, isFloat, suffix, callback, indexSearch)` | Slider + UIControllers. |
| 1555–1629 | `local function createDropdownRow(parent, labelText, descText, options, initialVal, callback, indexSearch)` | Dropdown. |
| 1631–1652 | `local function createButtonRow(parent, labelText, descText, btnText, callback, indexSearch)` | Button. |
| 1654–1658 | `local function createInfoRow(parent, labelText, valueText, indexSearch)` | Label giá trị `.Set`. |
| 1660–1699 | `local function createInputRow(parent, labelText, descText, initialVal, callback, indexSearch, placeholder)` | TextBox. |
| 1738–1794 | `local function IsRodOwned(rodName)` | Sở hữu cần? |
| 2170–2187 | `function Wiki.GetItemRawName(item)` | Tên trước dấu ` \| `. |
| 2189–2215 | `function Wiki.IsItemFavorited(item)` | Child tên chứa `Favorite` / attribute. |
| 2217–2233 | `function Wiki.IsSecretBossFish(item)` | Khớp `secretBossLookup` / `SecretBossTargets`. |
| 2235–2252 | `function Wiki.IsMutatedFish(item)` | Prefix Shiny/Giant/Albino/… |
| 2254–2273 | `function Wiki.IsPlayerIndexUnlocked(fishName)` | Indexlist PlayerGui. |
| 2275–2312 | `function Wiki.GetPlayerFishCount(fishName)` | Đếm inventory. Nested `cleanFishName`, `checkFolder`. |
| 2314–2342 | `function Wiki.IsEssentialKeepItem(item)` | `wikiFishData.keep` + craft map. |
| 2367–2380 | `function Wiki.IsBaitIngredient(fishName, baitName)` | Tra `Wiki.baitIngredients`. |
| 2382–2428 | `function Wiki.UnlockBaitFish(baitName, silent)` | Unfavorite nguyên liệu mồi; ghi `temporarilyUnlockedBaitFish`. |
| 2430–2476 | `function Wiki.LockBaitFish(baitName, silent)` | Favorite lại. |
| 2478–2516 | `function Wiki.UnlockAllKeepFish()` | Unfavorite cá keep. |
| 2519–2555 | `function Wiki.UnlockAllFish()` | Unfavorite tất cả. |
| 2557–2595 | `function Wiki.UnlockAllUnnecessaryFish()` | Unfavorite không keep. |
| 2597–2636 | `function Wiki.LockAllKeepFish()` | Favorite cá keep. |
| 2638–2695 | `function Wiki.ToggleLockSpecificFish(fishName, targetKeepState)` | `targetKeepState` bool. |
| 2697–2745 | `function Wiki.ResolveFishIcon(fishName, defaultIcon)` | Icon từ Indexlist / ReplicatedStorage. |
| 2806–2814 | `local function GetFishGemReward(fishName)` | Lookup + substring. |
| 2816–2876 | `local function GetPlayerCurrentGems()` | Quét ValueBase/Attribute Gems. |
| 2878–2901 | `local function TrackCaughtFishForGems(child)` | Cộng `gemTracker.gained`. |
| 2903–2932 | `local function SendDiscordWebhook(title, description, color, fields)` | `request`/`http_request` POST `Config.WebhookUrl`. |
| 2934–2945 | `local function GetPlayerRodPower()` | Attribute/Value lực cần. |
| 2947–3022 | `local function GetCurrentHookedFishName()` | Attribute + Fishing UI + fuzzy boss. |
| 3024–3031 | `local function QueueScriptOnTeleport()` | `queue_on_teleport` load lại loader. |
| 3033–3084 | `local function ServerHop(avoidServers)` | HTTP server list + TeleportToPlaceInstance / Teleport. |
| 3086–3107 | `function secretBossState.SaveNPCHopState(visitedList)` | Ghi/xóa `HeavyweightFishing_NPCHop.json`. |
| 3109–3127 | `function secretBossState.ClearNPCHopState()` | Tắt 3 hop NPC + sync UI skipCallback + xóa file. |
| 3137–3163 | `secretBossState.HandleTeleportError = function(reason)` | `GuiService:ClearError`; retry weather hop hoặc normal hop. |
| 3197–3213 | `function secretBossState.IsWeatherMatch(currentWeatherName, targetWeather)` | So khớp chuỗi thời tiết (kể cả “Bất Kỳ…Trừ Clear”). |
| 3215–3339 | `function secretBossState.HopToNextWeatherServer(targetWeather, visitedServers)` | Queue script, chọn JobId theo slot, Teleport. |
| 3341–3459 | `function secretBossState.CheckWeatherHopOnJoin()` | Sau join: đo weather, dừng hop hoặc hop tiếp. |
| 3461–3491 | `function secretBossState.CheckNPCHopOnJoin()` | Sau join: có NPC đích thì dừng, không thì hop. |
| 3495–3499 | `function ticketQuestState.GetServerTimeNow()` | `Workspace:GetServerTimeNow()` fallback `os.time()`. |
| 3501–3510 | `function ticketQuestState.IsFishingActive()` | Auto ticket + không completed/interact; cooldown chỉ true nếu đang home farm. |
| 3512–3519 | `function ticketQuestState.IsBusyOrInteracting()` | Dialogue / nhận vé / chưa có quest type. |
| 3521–3560 | `local function CancelAndRecastRod(forceCast)` | `forceCast` bỏ qua busy check. Unequip, hotbar, `Fishing:FireServer`. |
| 3562–3600 | `function secretBossState.DetectWeatherPattern(text)` | Clear vs pattern đảo vs tên boss. |
| 3602–3657 | `function secretBossState.DetectIsland(text)` | Bỏ caught; match boss name → weather → island keyword. |
| 3659–3763 | `function secretBossState.FindWaterSpot(centerPos, preferredLookAt)` | Raycast tìm mép nước; return CFrame đứng. |
| 3765–3776 | `function secretBossState.SaveCustomSpots()` | JSON `Config.CustomBossSpots`. |
| 3778–3792 | `function secretBossState.LoadCustomSpots()` | Đọc file custom spots. |
| 3794–3816 | `function secretBossState.SaveHomeSpot()` | Ghi `Config.HomeFarmSpot` 12 số CFrame. |
| 3818–3831 | `function secretBossState.LoadHomeSpot()` | (nếu còn đọc file/legacy). |
| 3833–3846 | `function secretBossState.ClearHomeSpot()` | `HomeFarmSpot = nil`. |
| 3848–3905 | `function secretBossState.ReturnToHome()` | TP về home + optional recast 1.5s. |
| 3907–3924 | `function secretBossState.GetNearestIsland()` | So `secretBossDatabase.pos`. |
| 3926–3964 | `function secretBossState.GetIslandSpots(islandName)` | Custom + default spots. |
| 3966–3992 | `function secretBossState.GetIslandSlotSpot(islandName, slot)` | Slot 1..n. |
| 3994–4016 | `function secretBossState.SaveIslandSlot(islandName, slot, cfComponents)` | `cfComponents` 12 số. |
| 4018–4045 | `function secretBossState.DeleteIslandSlot(islandName, slot)` | Xóa slot. |
| 4047–4057 | `function secretBossState.ApplyJitter(baseCf)` | Xê dịch ngang `BossTeleportJitterDist`. |
| 4059–4086 | `function secretBossState.GetChosenSpotForPlayer(islandName)` | Mode auto-theo-acc vs slot chọn. |
| 4088–4178 | `function secretBossState.Teleport(matchedIsland, detectedName, reqPower)` | Power check, set `active/standPos`, TP + water part. |
| 4180–4252 | `function secretBossState.DetectWeather()` | Đọc UI/Lighting/chat thời tiết hiện tại. |
| 4261–4274 | `local function getCandidateNPCFolders()` | Workspace NPC folders. |
| 4276–4284 | `local function isTaoistText(str)` | Keyword Đạo Sĩ/Taoist. |
| 4286–4293 | `local function isMaoshanText(str)` | Keyword Maoshan. |
| 4295–4300 | `local function isNPCModel(inst)` | Model có Humanoid/HRP. |
| 4302–4346 | `function secretBossState.ScanForTaoistNPC()` | Scan + cache. |
| 4348–4392 | `function secretBossState.ScanForMaoshanNPC()` | Scan + cache. |
| 4394–4416 | `function secretBossState.GetTaoist()` | Cache hoặc scan. |
| 4418–4440 | `function secretBossState.GetMaoshan()` | Cache hoặc scan. |
| 4442–4489 | `function secretBossState.ScanForGodSpirit()` | Nested `matchesGod`. |
| 4491–4503 | `function secretBossState.GetGodSpirit()` | Cache `cachedGod`. |
| 4505–4596 | `function secretBossState.HandleChatMessage(msg)` | Despawn → `active=false` + home; spawn → DetectIsland + Teleport. |
| 4598–4703 | `function secretBossState.ScanChatHistory()` | Quét log chat đã có. |
| 4708–4719 | `local function TriggerPrompt(prompt)` | `ProximityPrompt` fire. |
| 4721–4734 | `local function ParseFishWeightNumber(val)` | Parse `1.5M` / `K`. |
| 4777–4796 | `function ticketQuestState.SerializeSpot(spot)` | Vector3/CFrame → table. |
| 4798–4810 | `function ticketQuestState.DeserializeSpot(data, defaultCf)` | Ngược lại. |
| 4812–4825 | `function ticketQuestState.SaveSpots()` | File spots vé. |
| 4827–4856 | `function ticketQuestState.LoadSpots()` | Nạp 5 spot + NPC. |
| 4858–4928 | `function ticketQuestState.UpdateUI()` | Ghi các `uiStatus/uiProgress/...`. Nested `getSpotPos`. |
| 4937–4942 | `function ticketQuestState.GetPlayerDataFolder()` | `ReplicatedStorage.Data[UserId]`. |
| 4944–5047 | `function ticketQuestState.FindTicketNPC()` | Nested `extractModelData`. |
| 5049–5066 | `function ticketQuestState.CheckNPCReady()` | NPC có prompt/dialogue. |
| 5068–5106 | `function ticketQuestState.TeleportTo(target)` | HRP CFrame. |
| 5108–5127 | `function ticketQuestState.OrientCameraTo(focusPos, standPos)` | Camera look. |
| 5129–5200 | `function ticketQuestState.TeleportToNPC()` | CancelCast + TP spotNPC. |
| 5203–5217 | `function ticketQuestState.GetDialogueGui()` | MainGui.Menu.Dialogue. |
| 5219–5231 | `function ticketQuestState.IsDialogueOpen()` | Visible. |
| 5234–5258 | `function ticketQuestState.GetDialogueButtons()` | List `{button,index,text,clean}`. |
| 5261–5269 | `function ticketQuestState.ClearUINavigation()` | `SelectedObject=nil`, tắt GuiNavigation. |
| 5272–5372 | `function ticketQuestState.ClickButtonEntry(entry, explicitActionId)` | 5 lớp: require Dialogue module, firesignal, getconnections, VIM Enter/click/touch, `ChooseDialogueOption:FireServer`. |
| 5374–5396 | `function ticketQuestState.CloseDialogue()` | Fire `"Close"` + ẩn GUI. |
| 5399–5407 | `function ticketQuestState.FindAndClickButton(predicate)` | `predicate(entry)`. |
| 5409–5419 | `function ticketQuestState.SelectDialogueOption(optionIndex, optionTextPattern)` | Chọn theo index hoặc regex text. |
| 5423–5436 | `function ticketQuestState.CheckAllQuestsDoneToday()` | Parse text NPC hết vé. |
| 5438–5450 | `function ticketQuestState.IsAllQuestsDoneToday()` | Flag + check. |
| 5459–5571 | `function ticketQuestState.HandleDialogue(isClaiming)` | Máy trạng thái nút Quest/Hard/Claim/Leave. |
| 5573–5705 | `function ticketQuestState.InteractNPC(isClaiming)` | Nested `_execute`: TP, prompt, dialogue, `ClaimQuest:FireServer`. |
| 5707–5923 | `function ticketQuestState.DetectActiveQuest()` | Đọc Quest folder / GUI card; types `fish_15m` / `bait_100` / `skill_100` / `fish_100`. Nested `cleanStr`. |
| 5925–5985 | `function ticketQuestState.ScanAndUpdateStatus()` | Sync progress/cooldown; **dễ ghi đè flag nếu `isAcceptingQuest` không đúng**. |
| 5987–6001 | `function ticketQuestState.ResetCooldown()` | Xóa cd local + UI. |
| 6003–6396 | `function ticketQuestState.Tick()` | **FSM vé**; có `task.wait(0.2)` khi TP home — **block thread caller** (loop 1s, không phải Heartbeat). |
| 6476–6511 | `function PriorityManager.IsTaskActive(taskId)` | `taskId`: `"SecretBoss"\|"TicketQuest"\|"GodSpirit"\|"TrainSkill"\|"NormalFarm"`. |
| 6513–6520 | `function PriorityManager.GetTaskPriority(taskId)` | Số hạng từ Config (1 = cao nhất). |
| 6522–6529 | `function PriorityManager.GetTaskDisplayName(taskId)` | Chuỗi UI. |
| 6531–6565 | `function PriorityManager.GetActiveTask(forceRefresh)` | Cache 0.5s trừ khi `forceRefresh`. |
| 6567–6574 | `function PriorityManager.UpdateUI()` | `forceRefresh=true` khi vẽ. |
| 6617–6623 | `local function GetHomeSpotText()` | Text tọa độ home. |
| 6896–7043 | `local function ShowSkillTextWindow(customText)` | Modal copy skill text. |
| 7216–7673 | `local function ExportAllPlayerSkills(infoRow, ownedOnly)` | `ownedOnly` bool; crawl + điền `infoRow`. |
| 8397–8958 | `local function initWikiTab()` | Dựng toàn bộ wiki cards. |
| 9474–9477 | `local function formatNumber(n)` | Format số shop. |
| 9480–9484 | `local function UpdateAllRodShopUI()` | Chạy `rodShopUpdaters`. |
| 9643–9676 | `local function GetCurrentLocationName()` | Tên đảo theo vị trí. |
| 9695–9703 | `UpdateAllIslandStatus = function()` | Global-ish; cập nhật `islandUpdaters`. |
| 9841–9865 | `local function BuildPlayerList()` | Fill `playerLookup`. |
| 9874–9880 | `local function RefreshPlayerDropdown()` | Refresh dropdown player. |
| 9986–10002 | `local function findNPCModel(npcName, npcPath)` | Tìm model NPC. |
| 10131–10155 | `local function ApplyFullbright(enabled)` | Lighting + optional NoFog. |
| 10408–10412 | `local function rankToNumber(str)` | `"1 (Cao Nhất)"` → 1. |
| 10414–10419 | `local function numberToRank(num)` | Ngược. |
| 10424–10459 | `local function applyPriorityPreset(pName)` | Gán 5 hạng theo preset string. |
| 10465–10477 | `local function onCustomRankChange()` | Đổi preset thành Custom khi user sửa hạng. |
| 10564–10858 | `local function initExperimentalTab()` | Toàn tab thử nghiệm. |
| 10878–10924 | `function comboState.IsSkillReady(sk, fUI)` | CD local `usedTimes` + defaultCooldowns + UI cooldown bar. |
| 10926–10928 | `function comboState.IsSkillOnCooldown(sk, fUI)` | not IsSkillReady. |
| 10930–10935 | `function comboState.CheckSkillReady(sk, fUI, minCooldown)` | Ready với floor CD. |
| 10937–11048 | `local function GetFishHealth(fUI)` | Parse BossFightBar / HP labels. |
| 11050–11074 | `local function GetPlayerHealth(fUI)` | HPPlayer bar. |
| 11076–11113 | `function comboState.IsCharacterCastingSkill()` | Attribute/anim đang cast. |
| 11115–11233 | `function comboState.CastSkill(sk)` | Khóa C + ticket lock + UseSkill/TriggerMinigameSkill + VIM + GUI click. Nested `clickBtn`. |
| 11249–11287 | `local function ProtectInventoryItem(item, showNotify)` | FavoriteItem nếu mutation/boss/material/favourite/keep; tôn trọng `temporarilyUnlockedBaitFish`. |
| 11289–11296 | `local function ProtectAllInventoryItems(showNotify)` | Loop Inventory. |
| 12726–12756 | `function secretBossState.GetNearestIslandName(pos)` | Tên đảo gần `pos`. |
| 12758–12772 | `local function ResolveBestPart(instance)` | PrimaryPart / HRP / BasePart. |
| 12774–12834 | `local function AddESP(instance, name, espCategory, color, icon, explicitPart, customData)` | Billboard trong `IdenticalESP`; `customData.player` / `.fish`. |
| 12836–12842 | `local function RemoveESP(instance)` | Destroy + `activeESP[instance]=nil`. |

### 2.2. Hàm lồng (không cấp module) — vẫn phải biết khi sửa parent

| Dòng | Parent | Chữ ký | Ghi chú |
|------|--------|--------|---------|
| 1445 | `createCollapsibleCardGroup` | `local function toggle()` | Đổi `Visible` + mũi tên. |
| 1484 | `createToggleRow` | `local function updateVisuals()` | Tween knob. |
| 1499 | `createToggleRow` | `Set(val, skipCallback)` | **`skipCallback=true` khi sync từ file/Config.** |
| 1525 | `createSliderRow` | `local function updateFromX(x)` | Kéo slider. |
| 1575 | `createDropdownRow` | `local function populate(opts)` | Rebuild options. |
| 2282 / 2290 | `Wiki.GetPlayerFishCount` | `cleanFishName(str)`, `checkFolder(folder)` | |
| 2951 | `GetCurrentHookedFishName` | `local function matchBossName(rawText)` | Fuzzy bỏ prefix mutation. |
| 4444 | `ScanForGodSpirit` | `local function matchesGod(str)` | |
| 4901 | `ticketQuestState.UpdateUI` | `local function getSpotPos(p)` | |
| 4955 | `FindTicketNPC` | `local function extractModelData(model)` | |
| 5577 | `InteractNPC` | `local function _execute()` | Toàn bộ interact; đừng tách nửa. |
| 5821 | `DetectActiveQuest` | `local function cleanStr(s)` | |
| 6429 | spawn Quest hook | `local function bindQuestDescendant(desc)` | |
| 6453 | spawn Quest hook | `local function hookCd(val)` | TicketQuestCooldown. |
| 6720 / 6735 / 6751 | Combo UI | `getPresetValue`, `getPresetLabel`, **`applyComboChange(newVal, source)`** | `source` tránh loop dropdown↔input. Gọi `SaveSmartCombo`. |
| 6804 / 6821 | Combo UI | `makeQuickBtn`, `appendKey(k)` | |
| 7221–7338 | `ExportAllPlayerSkills` | `CleanSkillName`, `IsSkillItemOwned`, `AddSkill`, `CrawlTable(t, parentKey, depth)`, `GetFromDb` | Crawl sâu table — dễ treo nếu sửa depth. |
| 8028–8058 | Boss spots UI | `GetSpotStats`, `GetSlotStatusText`, `RefreshSpotUI` | |
| 8505–8570 | `initWikiTab` | `makeFilterBtn`, `UpdateCardFilter`, `SetFilterMode` | |
| 8932–8934 | `initWikiTab` | `attachFolder` / `onChanged` | Live index. |
| 9551 | rod shop row | `updateRowVisuals` | |
| 9719 | island row | `updateVisuals(curLocName)` | |
| 10299 | Profiles | `RefreshProfileDropdown(preferredSelect)` | |
| 10569 | Experimental | `ApplyGhostInvisibility(state)` | `ToggleInvisibility:InvokeServer`. |
| 10616 / 10624 | Experimental | `UpdateTraitRerollInfo`, `RunAutoRerollTrait` | RerollTrait + LockTrait. |
| 10709 / 10791 | Experimental | `SpawnBoatNow(boatName)`, `ApplyRodColor(c3)` | |
| 11199 | `CastSkill` | `local function clickBtn(btn)` | firesignal + getconnections. |

---

## 3. Biến trạng thái / State Table dùng chung

### 3.1. God objects (sửa 1 field = side-effect toàn file)

| Vị trí khai báo | Tên | Side-effect |
|-----------------|-----|-------------|
| 99 | `isRunning` | Mọi loop Heartbeat/RenderStepped/task.spawn thoát khi false. Unload đặt false **trước** destroy GUI. |
| 100 | `activeConnections` | Mọi `:Connect` phải `table.insert` vào đây, không thì leak khi Unload. |
| 101 | `cleanUpInstances` | GUI, water platform, fly BV/BG, ESP folder, fish ring. |
| 6, 1041–1043 | `globalEnv` + 2 hook unload | Script mới gọi hook này. Đổi tên hàm Unload mà quên gán lại = **hai GUI chồng**. |
| 106–110 | `Events` | Có thể còn **nil** vài giây đầu. Mọi `Events:FindFirstChild` phải nil-check (đã có phần lớn). |
| **113–302** | **`Config`** | Nguồn sự thật UI + logic. Heartbeat đọc mỗi frame. File hop ghi đè **trước khi UI dựng**. |
| 335 | `UIControllers` | Map key Config → control `{Set,Get}`. Sync 10862–10870. Key phụ thuộc `ConfigLabelMap` (trùng nhãn = **ghi đè controller**). |
| 336, 6471–6474 | `PriorityManager` | `cachedTask` (0.5s) có thể **giữ task cũ** nửa giây — Ticket.Tick và Heartbeat có thể lệch nhịp. |
| **338–359** | **`comboState`** | Reset khi **vào** minigame (11398–11406). `usedTimes` quyết định CD client-side **không phải** CD server. |
| 385–522 | `ConfigLabelMap` | Đổi text label GUI mà quên map → control không vào UIControllers, LoadConfig không sync. |
| 664–723 | `Config._essentialKeys` | Whitelist; `_triggerAutoSave` đang chết nên ít ghi, nhưng `_loadEssential` vẫn strip C. |
| 825 | `_smartComboSavePending` | Debounce; spam toggle có thể mất lần ghi cuối nếu unload giữa 0.3s. |
| 1305 | `rowSearchIndex` | Search GUI. |
| 1325–1326 | `tabFrames`, `tabButtons` | SwitchTab. |
| 1376 | `ToggleUiVisibility` | Forward-declared; gán 1376. Hotkey 13251 gọi nếu non-nil. |

### 3.2. Wiki / inventory

| Dòng | Tên | Rủi ro |
|------|-----|--------|
| 1987+ | `Wiki` | `wikiFishData.keep` quyết định auto-lock. Sai `keep` = bán nhầm boss hoặc không bán cá rác. |
| 2344–2365 | `Wiki.baitIngredients`, `allBaitFishSet`, **`temporarilyUnlockedBaitFish`** | Unlock mồi để craft/sell; `ProtectInventoryItem` **cố ý bỏ qua** các tên trong bảng này. Quên `LockBaitFish` = mất nguyên liệu. |

### 3.3. Secret boss — dễ nổ nhất sau Config

| Dòng | Field | Rủi ro |
|------|-------|--------|
| 2748–2760, +3130–3135, +runtime | `secretBossState.active` | Bật = Heartbeat coi là đang săn (fast skip, bait boss, auto fish). Chat despawn / HandleChatMessage gán false. |
| | `standPos`, `currentMap`, `targetIsland`, `requiredPower` | Teleport ghi. Fast skip + ReturnToHome đọc. |
| | `isCatchingTarget`, `minigameStartTime`, `webhookSentForCurrent` | Reset khi rời minigame. Sai reset = skip nhầm boss hoặc spam webhook. |
| | `isHopping`, `currentVisited`, `lastAttemptedJob`, `hopWatchdog`, `isNormalHopping` | TeleportInitFailed retry. `hopWatchdog` không reset đúng = hop vô hạn. |
| | `currentTargetWeather`, `weatherHopToggle` | Toggle UI ref; ClearNPCHopState không đụng weather. |
| 305–317 / 321–332 | `pendingWeatherHopData`, `pendingNPCHopData` | Chỉ hydrate 1 lần lúc load. |
| 2763 | `bossTogglesMap` | Sync file BossTargets. |
| 1956 | `secretBossLookup` | Fast skip + GetCurrentHookedFishName. Đổi tên boss trong DB phải rebuild lookup. |
| 2765 | `weatherTotems` | Tọa độ hardcode. |

### 3.4. Ticket quest — side-effect lớn nhất (FSM)

Khởi tạo rỗng **3493**, gán field **4736–4775**:

| Field | Ý nghĩa | Dễ lỗi |
|-------|---------|--------|
| `active` | Có quest | ScanStatus vs Tick đua. |
| `currentQuestType` | `"none"\|"fish_15m"\|"bait_100"\|"skill_100"\|"fish_100"` | **CastSkill đọc cái này mỗi lần ấn chiêu.** Sai type = chặn Z/X/V hoặc spam sai chiêu. |
| `currentProgress` / `targetProgress` / `isCompleted` | | Tick hủy cooldown nếu `progress >= target`. |
| **`isCooldown` / `cooldownEnd` / `readyForNewQuest` / `isAcceptingQuest`** | | Comment 4755–4756: ScanStatus **set nhầm cooldown** nếu thiếu `isAcceptingQuest`. |
| `isInteracting` / `isBusyRoutine` / `lastNpcInteract` | | Heartbeat unequip cần khi busy. Kẹt true = **không bao giờ AutoCast**. |
| `isAtHomeSpot` | | Tick TP home; AutoCastAtHome. Không reset khi user TP tay. |
| `cachedCard` | Cache GUI dialogue | Reset khi hết CD (6102). Cache cũ = click nhầm nút. |
| `spot100Fish`, `spot100Bait`, `spot100Skill`, `spot15MFish`, `spotNPC` | | File override. TP sai map. |
| `uiStatus`…`uiNPCSpot` | | Nil trước khi tab nhiệm vụ dựng. |

Loop 6398–6418 **luôn** `ScanAndUpdateStatus` mỗi 1s kể cả khi tắt AutoTicketQuest.

### 3.5. Timers Heartbeat (11234–11245, 10873–10876)

`lastCastTime`, `lastSellTime`, `lastSkillTime`, **`isTrainingBusy`**, `lastGachaTime`, `lastBaitBuyTime`, `lastQuestTime`, `lastGodPrayTime`, `lastEquipTime`, `lastEquipRodTime`, `lastProgressionTime`, `lastProtectTime`, `fishingStartTime`, `wasFishing`, `minigameDurationTracker`, `wasMinigame`.

`isTrainingBusy` chặn auto-fish/equip. Kẹt true = đứng hình.

### 3.6. ESP / movement / fly

| Dòng | Tên |
|------|-----|
| 11311–11320 | `waterPlatform` (`IdenticalWaterPlatform`) — Tick **cũng có thể tạo Part cùng tên** (6025–6034). Hai hệ thống đua `CanCollide`. |
| 12313 | `flyBV`, `flyBG` |
| 12682 | `activeESP` |
| 2772–2775 | `sessionStartTime`, `initialCash`, `initialFishCaught`, `lastWebhookStatsTime` |
| 2777–2783 | `gemTracker` |
| 9479 / 9694 / 9838 | `rodShopUpdaters`, `islandUpdaters`, `playerLookup` |

### 3.7. Ranking side-effect (chạm trước khi sửa)

1. **`ticketQuestState.currentQuestType` + `isInteracting` + `isCooldown` + `isAcceptingQuest`** — CastSkill, Heartbeat unequip, Tick, ScanStatus.  
2. **`secretBossState.active` + `isCatchingTarget` + `Config.SecretBossTargets`** — fast skip bán/thả nhầm boss.  
3. **`Config` + `UIControllers` + `ConfigLabelMap`** — lệch UI vs logic.  
4. **`comboState.usedTimes` / opener flags** — spam skill hoặc không bao giờ skill.  
5. **`isTrainingBusy` / `isRunning`**.  
6. **`Wiki.temporarilyUnlockedBaitFish`**.  
7. **`PriorityManager.cachedTask`**.  
8. **`waterPlatform` vs Tick home platform**.  
9. File hop JSON (ghi đè Config lúc boot).  
10. **`Events` nil** lúc join.

---

## 4. Cạm bẫy (Gotchas) — không tùy tiện chạm

### 4.1. Máy trạng thái vé & thoại (nặng nhất)

- **`ticketQuestState.ClickButtonEntry` (5272–5372)** và **`HandleDialogue` / `InteractNPC`**: timing `task.wait(0.04/0.06)` khớp `SCRIPT_BUILD_COMMIT = "fix-dialogue-press-timing"`. Đổi thứ tự 5 lớp (require ClientModule.Dialogue → firesignal → getconnections → VIM Return → FireServer) dễ **nhận Easy thay Hard**, kẹt dialogue, hoặc bắn `ChooseDialogueOption` hai lần.  
- **`ClearUINavigation` / đầu file GuiService**: bật lại `GuiNavigationEnabled` hoặc để `SelectedObject` kẹt = click nhầm UI game.  
- **`ScanAndUpdateStatus` vs `isAcceptingQuest`**: comment trong file đã cảnh báo. Sửa scan mà không giữ flag = cooldown 20 phút giả.  
- **`DetectActiveQuest` bị gọi bên trong `CastSkill`** (11138–11141, 11155–11158) trên hot path. Làm nặng/scan sai type ngay lúc minigame.  
- **`Tick` có `task.wait` khi TP home** (6038, 6141): caller là loop 1s, chấp nhận được; **không gọi Tick từ Heartbeat**.

### 4.2. Khóa chiêu C và khóa ticket trong `CastSkill`

- Dòng **11120–11133**: chiêu **C bị chặn 100%** trừ khi user chọn C ở ticket/train/combo. `_loadEssential` còn **tự xóa C khỏi LoopSkills**. Thêm C vào default `"Z, X, V"` mà không sửa cả hai chỗ = C không bao giờ ra.  
- Dòng **11136–11173**: khi `fish_100` / `skill_100`, mọi chiêu khác return false — kể cả SmartCombo Heartbeat. Đổi tên quest type ở DetectActiveQuest phải sửa CastSkill đồng bộ.

### 4.3. Fast Skip Secret Boss (Heartbeat ~11432+)

- Điều kiện săn: `(AutoHuntBoss or AutoChatSecretBoss) and secretBossState.active`.  
- Tên cá: fuzzy `secretBossLookup` + alias Heavenpiercer / Heaven Piercer. Sai DB = **skip boss thật** hoặc **không skip cá rác**.  
- `FastSkipNonBoss` tắt khi `AutoTrainSkill` hoặc `isTicketActive`. Đổi thứ tự if = train/ticket giật cần liên tục.  
- Webhook `webhookSentForCurrent` reset khi rời minigame; đừng reset sớm hơn.

### 4.4. Hai vòng Slam/Charge

- Heartbeat (~11746+, ~11854+) **và** RenderStepped AnchorBar (12373–12377) đều `Slam:FireServer("Perfect")` / `Charge:FireServer(100)`. Sửa một bên, bên kia vẫn bắn. Gỡ AnchorBar không gỡ Heartbeat và ngược lại.

### 4.5. AutoCast / CancelCast / Fishing remote

- Cast: `Events.Fishing:FireServer(root.CFrame)` (và `CancelAndRecastRod`).  
- Anti-stuck 15s/22s.  
- Ticket busy → `CancelCast` mỗi Heartbeat khi đang cầm cần — dễ **hủy quest fishing** nếu `IsBusyOrInteracting` false-positive.  
- `ProtectAllInventoryItems` **trước** `SellFish("All")`. Bỏ protect = bán mutation/boss.

### 4.6. UI sync `Set(..., true)`

- `LoadSmartComboAndSyncUI`, `LoadBossTargetsAndSyncUI`, `LoadAccountConfig`, `ClearNPCHopState`, boot sync 10862.  
- Thiếu `skipCallback` → callback gán Config + `SaveSmartCombo` đệ quy / ghi file / hop.  
- `createToggleRow`: nếu truyền nhầm function vào `initialVal`, **mất giá trị ban đầu**.

### 4.7. ConfigLabelMap trùng key

Nhiều label Việt → cùng `AutoEquipBestBait`, `AutoChatSecretBoss`, `LoopSkills`, v.v. `UIControllers[key]` chỉ giữ **row tạo sau cùng**. LoadConfig chỉ sync được 1 widget.

### 4.8. Hop JSON hydrate trước UI (304–333)

File `Active=true` **bật Config hop** rồi mới dựng toggle. CheckWeatherHopOnJoin/CheckNPCHopOnJoin spawn **cuối file** (13258). Xóa logic file mà giữ CheckOnJoin = state lệch. `HandleTeleportError` `ClearError` — đụng TeleportService/GuiService rất dễ văng client.

### 4.9. `IdenticalWaterPlatform`

Heartbeat tạo 1 part (11311). `Tick` có thể `Instance.new` part **cùng Name** nếu không tìm thấy (6025). Unload chỉ destroy `cleanUpInstances` — part do Tick tạo có thể **sót trong Workspace** (`CanCollide=true` dưới chân).

### 4.10. Noclip Heartbeat

Mỗi frame `part.CanCollide = false` trên mọi BasePart character. Tắt Noclip **không restore** collide (trừ respawn). Đừng “tối ưu” bằng cách set một lần.

### 4.11. `CleanOldInstances` / Unload

Destroy theo **Name** cố định. Đổi `screenGui.Name` mà quên CleanOld = GUI chồng. Unload **không** xóa `HeavyweightFishing_WeatherHop.json` / NPCHop — join lại vẫn hop.

### 4.12. Wiki FavoriteItem

Mọi Unlock/Lock/Protect đều `Events.FavoriteItem:FireServer(item)`. Sai `item` instance (folder vs child) = không khóa. Cấu trúc `"FishName | ID"` + `"Weight | Favorite"` (comment 2192–2195) là contract game; đừng parse tên khác đi.

### 4.13. Priority cache 0.5s

`GetActiveTask()` không force → Ticket.Tick có thể nghĩ SecretBoss vẫn active 0.5s sau khi `active=false`. `UpdateUI` dùng `forceRefresh=true`; Heartbeat thì không gọi GetActiveTask trực tiếp nhưng Tick thì có (6068).

### 4.14. `initWikiTab` / `ExportAllPlayerSkills` / `initExperimentalTab`

Hàm cực dài, closure bắt `Config` và folder Data. Tách file mà không chuyển upvalue = nil Events/Wiki. `CrawlTable` đệ quy — tăng depth không kiểm soát.

### 4.15. Experimental remotes

`ToggleInvisibility`, `RerollTrait`, `LockTrait`, `SpawnBoat`, `Exchange`, `SetRodSkinColor`, `AddFishToFishTank`, `UpgradePlot` — không liên quan fishing core; sửa nhầm argument dễ lỗi server/UI.

### 4.16. Anti-AFK `getconnections(LocalPlayer.Idled)`

Disable connection gốc Roblox. Gọi Unload **không enable lại**. Re-execute script: CleanOld + hook mới. Đừng `Disconnect` thêm chỗ khác.

### 4.17. ESP `do … end` (12677–13247)

`AddESP`/`RemoveESP`/`activeESP` là local của block. Hàm ngoài block **không thấy**. Fish ring Heartbeat nằm trong cùng `do`.

### 4.18. Thứ tự khai báo hàm

`comboState.CastSkill` nằm **sau** toàn bộ UI (~11115) nhưng Heartbeat (~11322) nằm sau CastSkill — OK. `ShowNotification` dùng từ hop functions (trước GUI notif?) — notif container tạo **1046**, hop functions **3024+** — OK. `LoadSmartCombo` gọi cuối file vì cần `UIControllers` đã fill.

### 4.19. `secretBossState` bị gán lại field sau Teleport alias

Dòng 3128 `secretBossState.ServerHop = ServerHop`. 3130 **ghi đè** `isHopping = false` dù 2757 đã set từ `pendingWeatherHopData`. Weather hop pending dựa vào `CheckWeatherHopOnJoin` đọc file, không chỉ field `isHopping` ban đầu.

### 4.20. Default combo vs train C

Config mặc định `LoopSkills = "Z, X, V"`, `Train_C = true`, `Train_V = true`. Train C bật mặc định nhưng CastSkill chặn C trừ TrainSkill chứa C. Lẫn `Train_C` boolean với `TrainSkill` string.

---

## 5. File disk mà logic phụ thuộc

| File | Ai đọc/ghi |
|------|------------|
| `Identical/HeavyweightFishing/Configs/<acc>/*.json` | Save/Load/DeleteAccountConfig |
| `…/essential_config.json` | `_saveEssential` / `_loadEssential` (auto-load đang comment) |
| `HeavyweightFishing_SmartCombo.json` | Save/Load SmartCombo |
| `HeavyweightFishing_BossTargets.json` | Save/Load boss toggles |
| `HeavyweightFishing_WeatherHop.json` | Boot 306; HopToNextWeatherServer |
| `HeavyweightFishing_NPCHop.json` | Boot 322; SaveNPCHopState |
| Custom spots / ticket spots (trong SaveCustomSpots / SaveSpots) | secretBossState / ticketQuestState |

---

## 6. Remote / service touch list (để biết “ai gọi gì”, không phải để chỉnh payload)

`FavoriteItem`, `ToggleHotbar`, `Fishing`, `CancelCast`, `ChooseDialogueOption`, `ClaimQuest`, `SellFish`, `BuyBait`, `EquipBait`, `EquipFishingRod`, `EquipOrb`, `BuyFishingRod`, `BuySkill`, `UseSkill`, `TriggerMinigameSkill`, `Slam`, `Charge`, `UpdateFishProgression`, `DailyReward`, `RedeemCode`, `Gacha`, `CraftBait`, `RhythmHit`, `SetRodSkinColor`, `ResetRodSkinColor`, `ToggleInvisibility`, `RerollTrait`, `LockTrait`, `SpawnBoat` / `bShop.Spawn|Buy`, `Exchange`, `AddFishToFishTank`, `UpgradePlot`.  
Cộng: `TeleportService`, `queue_on_teleport`, `VirtualInputManager`, `VirtualUser`, `GuiService`, `require(ReplicatedStorage.ClientModule.Dialogue)`.

Mọi thay đổi chữ ký remote hoặc thứ tự wait trong các hàm mục 4 là thay đổi hành vi production.

---

## 7. Gợi ý điều hướng khi sửa

| Muốn sửa | Vào dòng |
|----------|----------|
| Flag mặc định | `Config` 113–302 |
| Combo Z/X/C/V | UI 6678–6876 + runtime 10878–11233 + Heartbeat minigame ~11780 |
| Vé nhiệm vụ | State 4736 + engine 4777–6396 + loop 6398 + CastSkill lock 11136 |
| Secret boss / chat / TP đảo | DB 1796 + state 2748 + detect/teleport 3562–4178 + chat 4505 + Heartbeat skip 11432 |
| Weather/NPC hop | 304–333, 3024–3491, 12603+, 13258 |
| Auto cast / slam / bait / sell | Heartbeat 11322–12292 + RenderStepped 12351 |
| Wiki cá keep | `Wiki.wikiFishData` + Protect 11249 |
| GUI theme/row | 936 Colors, 1392–1699 toolkit |
| Unload / trùng script | 5–69, 1005–1044, 13253 |

---

*Index sinh từ đọc toàn bộ `local.lua` (parser chữ ký + đối chiếu `end` từng hàm có tên + đọc tay các khối Heartbeat, Tick, CastSkill, ClickButtonEntry, hop, Unload). Nếu thêm hàm mới, cập nhật mục 1 và 2 cùng một commit.*
